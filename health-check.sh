#!/bin/bash

################################################################################
# Health Check Script for CSwap DEX Exchange
# 
# This script monitors the health of all services, containers, and system
# resources for the CSwap DEX application.
#
# Features:
# - Container status monitoring
# - HTTP endpoint health checks
# - Database connectivity tests
# - SSL certificate validation
# - System resource monitoring (CPU, memory, disk)
# - Alerting on failures
# - Detailed logging
#
# Usage:
#   ./health-check.sh [options]
#   Options:
#     --verbose, -v    Show detailed output
#     --quiet, -q      Only show errors
#     --json          Output in JSON format
#     --alert         Send alerts on failures
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_DIR="/opt/cswap-dex"
LOG_FILE="/var/log/cswap-health.log"
ALERT_EMAIL="admin@cryptoswap.com"
DOMAIN="cryptoswap.com"

# Health check options
VERBOSE=false
QUIET=false
JSON_OUTPUT=false
SEND_ALERTS=false

# Health status tracking
OVERALL_HEALTH="healthy"
ISSUES=()

# Log functions
log_info() {
    if [ "$QUIET" = false ]; then
        echo -e "${BLUE}[INFO]${NC} $1"
    fi
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $1" >> ${LOG_FILE}
}

log_success() {
    if [ "$QUIET" = false ]; then
        echo -e "${GREEN}[✓]${NC} $1"
    fi
    echo "$(date '+%Y-%m-%d %H:%M:%S') [SUCCESS] $1" >> ${LOG_FILE}
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [WARNING] $1" >> ${LOG_FILE}
    OVERALL_HEALTH="degraded"
    ISSUES+=("WARNING: $1")
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $1" >> ${LOG_FILE}
    OVERALL_HEALTH="unhealthy"
    ISSUES+=("ERROR: $1")
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --verbose|-v)
                VERBOSE=true
                shift
                ;;
            --quiet|-q)
                QUIET=true
                shift
                ;;
            --json)
                JSON_OUTPUT=true
                shift
                ;;
            --alert)
                SEND_ALERTS=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Show help
show_help() {
    echo "Usage: ./health-check.sh [options]"
    echo ""
    echo "Options:"
    echo "  --verbose, -v    Show detailed output"
    echo "  --quiet, -q      Only show errors"
    echo "  --json          Output in JSON format"
    echo "  --alert         Send alerts on failures"
    echo "  --help, -h      Show this help message"
    echo ""
}

# Check Docker service
check_docker_service() {
    log_info "Checking Docker service..."
    
    if systemctl is-active --quiet docker; then
        log_success "Docker service is running"
        return 0
    else
        log_error "Docker service is not running"
        return 1
    fi
}

# Check container status
check_containers() {
    log_info "Checking container status..."
    
    if [ ! -f "${APP_DIR}/docker-compose.yml" ]; then
        log_error "docker-compose.yml not found at ${APP_DIR}"
        return 1
    fi
    
    cd ${APP_DIR}
    
    # Get all containers
    CONTAINERS=$(docker compose ps -q)
    
    if [ -z "$CONTAINERS" ]; then
        log_error "No containers are running"
        return 1
    fi
    
    # Check each container
    local all_healthy=true
    
    for container in $(docker compose ps --format "{{.Name}}"); do
        STATUS=$(docker inspect --format='{{.State.Status}}' $container 2>/dev/null)
        HEALTH=$(docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}no_healthcheck{{end}}' $container 2>/dev/null)
        
        if [ "$STATUS" != "running" ]; then
            log_error "Container $container is not running (status: $STATUS)"
            all_healthy=false
        elif [ "$HEALTH" = "unhealthy" ]; then
            log_error "Container $container is unhealthy"
            all_healthy=false
        else
            if [ "$VERBOSE" = true ]; then
                log_success "Container $container is running (health: $HEALTH)"
            fi
        fi
    done
    
    if [ "$all_healthy" = true ]; then
        log_success "All containers are running"
        return 0
    else
        return 1
    fi
}

# Check frontend health
check_frontend() {
    log_info "Checking frontend service..."
    
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 || echo "000")
    
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
        log_success "Frontend is responding (HTTP $HTTP_CODE)"
        return 0
    else
        log_error "Frontend health check failed (HTTP $HTTP_CODE)"
        return 1
    fi
}

# Check backend health
check_backend() {
    log_info "Checking backend API service..."
    
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/health || echo "000")
    
    if [ "$HTTP_CODE" = "200" ]; then
        log_success "Backend API is responding (HTTP $HTTP_CODE)"
        
        # Check API response content
        if [ "$VERBOSE" = true ]; then
            RESPONSE=$(curl -s http://localhost:8000/health)
            echo "API Response: $RESPONSE"
        fi
        
        return 0
    else
        log_error "Backend API health check failed (HTTP $HTTP_CODE)"
        return 1
    fi
}

# Check database connectivity
check_database() {
    log_info "Checking database connectivity..."
    
    # Check if PostgreSQL container is running
    if docker ps | grep -q postgres; then
        # Test database connection
        if docker exec postgres pg_isready -U cswap_user -d cswap_dex > /dev/null 2>&1; then
            log_success "Database is accepting connections"
            
            if [ "$VERBOSE" = true ]; then
                # Get database size
                DB_SIZE=$(docker exec postgres psql -U cswap_user -d cswap_dex -t -c "SELECT pg_size_pretty(pg_database_size('cswap_dex'));" 2>/dev/null | xargs)
                echo "Database size: $DB_SIZE"
                
                # Get connection count
                CONNECTIONS=$(docker exec postgres psql -U cswap_user -d cswap_dex -t -c "SELECT count(*) FROM pg_stat_activity WHERE datname = 'cswap_dex';" 2>/dev/null | xargs)
                echo "Active connections: $CONNECTIONS"
            fi
            
            return 0
        else
            log_error "Database is not accepting connections"
            return 1
        fi
    else
        log_error "PostgreSQL container is not running"
        return 1
    fi
}

# Check Redis connectivity
check_redis() {
    log_info "Checking Redis connectivity..."
    
    # Check if Redis container is running
    if docker ps | grep -q redis; then
        # Test Redis connection
        if docker exec redis redis-cli ping > /dev/null 2>&1; then
            log_success "Redis is responding"
            
            if [ "$VERBOSE" = true ]; then
                # Get Redis info
                REDIS_CLIENTS=$(docker exec redis redis-cli info clients | grep connected_clients | cut -d: -f2 | tr -d '\r')
                echo "Redis connected clients: $REDIS_CLIENTS"
                
                REDIS_MEMORY=$(docker exec redis redis-cli info memory | grep used_memory_human | cut -d: -f2 | tr -d '\r')
                echo "Redis memory usage: $REDIS_MEMORY"
            fi
            
            return 0
        else
            log_error "Redis is not responding"
            return 1
        fi
    else
        log_error "Redis container is not running"
        return 1
    fi
}

# Check SSL certificate
check_ssl_certificate() {
    log_info "Checking SSL certificate..."
    
    CERT_PATH="/etc/letsencrypt/live/${DOMAIN}/fullchain.pem"
    
    if [ ! -f "$CERT_PATH" ]; then
        log_warning "SSL certificate not found at $CERT_PATH"
        return 1
    fi
    
    # Check certificate expiration
    EXPIRY_DATE=$(openssl x509 -enddate -noout -in $CERT_PATH | cut -d= -f2)
    EXPIRY_TIMESTAMP=$(date -d "$EXPIRY_DATE" +%s)
    CURRENT_TIMESTAMP=$(date +%s)
    DAYS_UNTIL_EXPIRY=$(( ($EXPIRY_TIMESTAMP - $CURRENT_TIMESTAMP) / 86400 ))
    
    if [ $DAYS_UNTIL_EXPIRY -lt 7 ]; then
        log_error "SSL certificate expires in $DAYS_UNTIL_EXPIRY days!"
        return 1
    elif [ $DAYS_UNTIL_EXPIRY -lt 30 ]; then
        log_warning "SSL certificate expires in $DAYS_UNTIL_EXPIRY days"
        return 0
    else
        log_success "SSL certificate is valid (expires in $DAYS_UNTIL_EXPIRY days)"
        return 0
    fi
}

# Check HTTPS endpoint
check_https_endpoint() {
    log_info "Checking HTTPS endpoint..."
    
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://${DOMAIN} 2>/dev/null || echo "000")
    
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "301" ] || [ "$HTTP_CODE" = "302" ]; then
        log_success "HTTPS endpoint is responding (HTTP $HTTP_CODE)"
        return 0
    else
        log_warning "HTTPS endpoint check failed (HTTP $HTTP_CODE)"
        return 1
    fi
}

# Check system resources
check_system_resources() {
    log_info "Checking system resources..."
    
    # Check CPU usage
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    CPU_USAGE_INT=${CPU_USAGE%.*}
    
    if [ "$CPU_USAGE_INT" -gt 90 ]; then
        log_error "High CPU usage: ${CPU_USAGE}%"
    elif [ "$CPU_USAGE_INT" -gt 75 ]; then
        log_warning "Elevated CPU usage: ${CPU_USAGE}%"
    else
        if [ "$VERBOSE" = true ]; then
            log_success "CPU usage: ${CPU_USAGE}%"
        fi
    fi
    
    # Check memory usage
    MEMORY_USAGE=$(free | grep Mem | awk '{print ($3/$2) * 100.0}')
    MEMORY_USAGE_INT=${MEMORY_USAGE%.*}
    
    if [ "$MEMORY_USAGE_INT" -gt 90 ]; then
        log_error "High memory usage: ${MEMORY_USAGE}%"
    elif [ "$MEMORY_USAGE_INT" -gt 80 ]; then
        log_warning "Elevated memory usage: ${MEMORY_USAGE}%"
    else
        if [ "$VERBOSE" = true ]; then
            log_success "Memory usage: ${MEMORY_USAGE}%"
        fi
    fi
    
    # Check disk usage
    DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
    
    if [ "$DISK_USAGE" -gt 90 ]; then
        log_error "Critical disk usage: ${DISK_USAGE}%"
    elif [ "$DISK_USAGE" -gt 80 ]; then
        log_warning "High disk usage: ${DISK_USAGE}%"
    else
        if [ "$VERBOSE" = true ]; then
            log_success "Disk usage: ${DISK_USAGE}%"
        fi
    fi
    
    # Check load average
    LOAD_AVG=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    
    if [ "$VERBOSE" = true ]; then
        echo "Load average: $LOAD_AVG"
    fi
}

# Check Docker stats
check_docker_stats() {
    if [ "$VERBOSE" = true ]; then
        log_info "Docker container statistics:"
        echo ""
        docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
        echo ""
    fi
}

# Send alert
send_alert() {
    if [ "$SEND_ALERTS" = false ]; then
        return 0
    fi
    
    local subject="CSwap DEX Health Alert: $OVERALL_HEALTH"
    local body="Health check completed with status: $OVERALL_HEALTH\n\n"
    body+="Issues detected:\n"
    
    for issue in "${ISSUES[@]}"; do
        body+="- $issue\n"
    done
    
    body+="\nTimestamp: $(date)\n"
    body+="Server: $(hostname)\n"
    
    # Send email (requires mailutils or sendmail to be configured)
    if command -v mail &> /dev/null; then
        echo -e "$body" | mail -s "$subject" $ALERT_EMAIL
        log_info "Alert sent to $ALERT_EMAIL"
    else
        log_warning "Mail command not available, cannot send alert"
    fi
    
    # Alternative: Use curl to send to webhook (e.g., Slack, Discord)
    # curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$body\"}" YOUR_WEBHOOK_URL
}

# Output JSON report
output_json() {
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    cat <<EOF
{
  "timestamp": "$timestamp",
  "overall_health": "$OVERALL_HEALTH",
  "checks": {
    "docker_service": "$(check_docker_service &>/dev/null && echo 'healthy' || echo 'unhealthy')",
    "containers": "$(check_containers &>/dev/null && echo 'healthy' || echo 'unhealthy')",
    "frontend": "$(check_frontend &>/dev/null && echo 'healthy' || echo 'unhealthy')",
    "backend": "$(check_backend &>/dev/null && echo 'healthy' || echo 'unhealthy')",
    "database": "$(check_database &>/dev/null && echo 'healthy' || echo 'unhealthy')",
    "redis": "$(check_redis &>/dev/null && echo 'healthy' || echo 'unhealthy')",
    "ssl_certificate": "$(check_ssl_certificate &>/dev/null && echo 'healthy' || echo 'unhealthy')",
    "https_endpoint": "$(check_https_endpoint &>/dev/null && echo 'healthy' || echo 'unhealthy')"
  },
  "issues": $(printf '%s\n' "${ISSUES[@]}" | jq -R . | jq -s .)
}
EOF
}

# Print summary
print_summary() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║           Health Check Summary                                 ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    case $OVERALL_HEALTH in
        healthy)
            echo -e "${GREEN}Overall Status: HEALTHY${NC}"
            ;;
        degraded)
            echo -e "${YELLOW}Overall Status: DEGRADED${NC}"
            ;;
        unhealthy)
            echo -e "${RED}Overall Status: UNHEALTHY${NC}"
            ;;
    esac
    
    echo ""
    
    if [ ${#ISSUES[@]} -gt 0 ]; then
        echo "Issues detected:"
        for issue in "${ISSUES[@]}"; do
            echo "  - $issue"
        done
        echo ""
    fi
    
    echo "Timestamp: $(date)"
    echo ""
}

# Main execution
main() {
    # Parse arguments
    parse_args "$@"
    
    if [ "$JSON_OUTPUT" = false ] && [ "$QUIET" = false ]; then
        echo ""
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║      Health Check for CSwap DEX Exchange                      ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo ""
    fi
    
    # Run health checks
    check_docker_service
    check_containers
    check_frontend
    check_backend
    check_database
    check_redis
    check_ssl_certificate
    check_https_endpoint
    check_system_resources
    check_docker_stats
    
    # Output results
    if [ "$JSON_OUTPUT" = true ]; then
        output_json
    else
        print_summary
    fi
    
    # Send alerts if needed
    if [ "$OVERALL_HEALTH" != "healthy" ]; then
        send_alert
    fi
    
    # Exit with appropriate code
    case $OVERALL_HEALTH in
        healthy)
            exit 0
            ;;
        degraded)
            exit 1
            ;;
        unhealthy)
            exit 2
            ;;
    esac
}

# Run main function
main "$@"

