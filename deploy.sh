#!/bin/bash

################################################################################
# Deployment Script for CSwap DEX Exchange
# 
# This script automates the deployment process for the CSwap DEX application
# using Docker Compose. It handles code updates, container rebuilds, and
# health checks.
#
# Features:
# - Git repository updates
# - Docker image rebuilds with cache control
# - Graceful container restarts
# - Health monitoring
# - Rollback capability
# - Deployment logging
#
# Prerequisites:
# - Docker and Docker Compose V2 must be installed
# - Application repository must be cloned
# - Environment variables must be configured (.env file)
#
# Usage:
#   ./deploy.sh [options]
#   Options:
#     --no-pull        Skip git pull
#     --no-build       Skip Docker build (use existing images)
#     --skip-health    Skip health checks
#     --rollback       Rollback to previous deployment
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
LOG_DIR="${APP_DIR}/logs"
DEPLOYMENT_LOG="${LOG_DIR}/deployment.log"
BACKUP_DIR="${APP_DIR}/backups"
MAX_HEALTH_CHECK_ATTEMPTS=30
HEALTH_CHECK_INTERVAL=5

# Deployment options
DO_GIT_PULL=true
DO_BUILD=true
DO_HEALTH_CHECK=true
DO_ROLLBACK=false

# Log functions
log_info() {
    local msg="[INFO] $1"
    echo -e "${BLUE}${msg}${NC}"
    echo "$(date '+%Y-%m-%d %H:%M:%S') ${msg}" >> ${DEPLOYMENT_LOG}
}

log_success() {
    local msg="[SUCCESS] $1"
    echo -e "${GREEN}${msg}${NC}"
    echo "$(date '+%Y-%m-%d %H:%M:%S') ${msg}" >> ${DEPLOYMENT_LOG}
}

log_warning() {
    local msg="[WARNING] $1"
    echo -e "${YELLOW}${msg}${NC}"
    echo "$(date '+%Y-%m-%d %H:%M:%S') ${msg}" >> ${DEPLOYMENT_LOG}
}

log_error() {
    local msg="[ERROR] $1"
    echo -e "${RED}${msg}${NC}"
    echo "$(date '+%Y-%m-%d %H:%M:%S') ${msg}" >> ${DEPLOYMENT_LOG}
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --no-pull)
                DO_GIT_PULL=false
                shift
                ;;
            --no-build)
                DO_BUILD=false
                shift
                ;;
            --skip-health)
                DO_HEALTH_CHECK=false
                shift
                ;;
            --rollback)
                DO_ROLLBACK=true
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
    echo "Usage: ./deploy.sh [options]"
    echo ""
    echo "Options:"
    echo "  --no-pull        Skip git pull"
    echo "  --no-build       Skip Docker build (use existing images)"
    echo "  --skip-health    Skip health checks"
    echo "  --rollback       Rollback to previous deployment"
    echo "  --help, -h       Show this help message"
    echo ""
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed"
        exit 1
    fi
    
    # Check if Docker Compose V2 is installed
    if ! docker compose version &> /dev/null; then
        log_error "Docker Compose V2 is not installed"
        exit 1
    fi
    
    # Check if in correct directory
    if [ ! -f "${APP_DIR}/docker-compose.yml" ]; then
        log_error "docker-compose.yml not found in ${APP_DIR}"
        exit 1
    fi
    
    # Check if .env file exists
    if [ ! -f "${APP_DIR}/.env" ]; then
        log_error ".env file not found in ${APP_DIR}"
        log_error "Please copy .env.production to .env and configure it"
        exit 1
    fi
    
    log_success "All prerequisites met"
}

# Create necessary directories
create_directories() {
    log_info "Creating necessary directories..."
    
    mkdir -p ${LOG_DIR}
    mkdir -p ${BACKUP_DIR}
    
    log_success "Directories created"
}

# Backup current state
backup_current_state() {
    log_info "Backing up current deployment state..."
    
    BACKUP_TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_FILE="${BACKUP_DIR}/deployment_${BACKUP_TIMESTAMP}.tar.gz"
    
    # Get current Git commit hash
    CURRENT_COMMIT=$(git rev-parse HEAD 2>/dev/null || echo "unknown")
    echo ${CURRENT_COMMIT} > ${BACKUP_DIR}/last_deployment_commit.txt
    
    # Backup environment file
    cp ${APP_DIR}/.env ${BACKUP_DIR}/.env.${BACKUP_TIMESTAMP}
    
    # Backup database (if PostgreSQL container is running)
    if docker ps | grep -q "postgres"; then
        log_info "Backing up database..."
        docker exec postgres pg_dump -U cswap_user cswap_dex | gzip > ${BACKUP_DIR}/db_${BACKUP_TIMESTAMP}.sql.gz
        log_success "Database backed up"
    fi
    
    log_success "Current state backed up to ${BACKUP_DIR}"
}

# Pull latest code
pull_code() {
    if [ "$DO_GIT_PULL" = false ]; then
        log_info "Skipping git pull (--no-pull flag set)"
        return 0
    fi
    
    log_info "Pulling latest code from repository..."
    
    cd ${APP_DIR}
    
    # Check if there are uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        log_warning "Uncommitted changes detected"
        log_warning "Stashing changes..."
        git stash
    fi
    
    # Pull latest code
    git pull origin main || git pull origin master
    
    if [ $? -eq 0 ]; then
        log_success "Code updated successfully"
        NEW_COMMIT=$(git rev-parse HEAD)
        log_info "Current commit: ${NEW_COMMIT}"
    else
        log_error "Failed to pull latest code"
        exit 1
    fi
}

# Stop containers
stop_containers() {
    log_info "Stopping containers..."
    
    cd ${APP_DIR}
    docker compose down --remove-orphans
    
    if [ $? -eq 0 ]; then
        log_success "Containers stopped"
    else
        log_error "Failed to stop containers"
        exit 1
    fi
}

# Clean Docker resources
clean_docker() {
    log_info "Cleaning up Docker resources..."
    
    # Remove unused containers, networks, and images
    docker system prune -f
    
    # Remove dangling volumes (optional - be careful with this)
    # docker volume prune -f
    
    log_success "Docker resources cleaned"
}

# Build Docker images
build_images() {
    if [ "$DO_BUILD" = false ]; then
        log_info "Skipping Docker build (--no-build flag set)"
        return 0
    fi
    
    log_info "Building Docker images..."
    
    cd ${APP_DIR}
    docker compose build --no-cache
    
    if [ $? -eq 0 ]; then
        log_success "Docker images built successfully"
    else
        log_error "Failed to build Docker images"
        exit 1
    fi
}

# Start containers
start_containers() {
    log_info "Starting containers..."
    
    cd ${APP_DIR}
    docker compose up -d
    
    if [ $? -eq 0 ]; then
        log_success "Containers started"
    else
        log_error "Failed to start containers"
        exit 1
    fi
}

# Wait for containers to be ready
wait_for_containers() {
    log_info "Waiting for containers to be ready..."
    
    sleep 10
    
    log_success "Initial wait complete"
}

# Check container health
check_container_health() {
    if [ "$DO_HEALTH_CHECK" = false ]; then
        log_info "Skipping health checks (--skip-health flag set)"
        return 0
    fi
    
    log_info "Checking container health..."
    
    local attempt=0
    local all_healthy=false
    
    while [ $attempt -lt $MAX_HEALTH_CHECK_ATTEMPTS ]; do
        attempt=$((attempt + 1))
        
        # Get container statuses
        CONTAINER_STATUS=$(docker compose ps --format json 2>/dev/null || docker compose ps)
        
        # Check if all containers are running
        RUNNING_COUNT=$(docker compose ps | grep -c "Up" || echo "0")
        TOTAL_COUNT=$(docker compose ps | tail -n +2 | wc -l)
        
        log_info "Attempt ${attempt}/${MAX_HEALTH_CHECK_ATTEMPTS}: ${RUNNING_COUNT}/${TOTAL_COUNT} containers running"
        
        # Check if all containers are healthy
        UNHEALTHY=$(docker compose ps | grep -c "unhealthy" || echo "0")
        
        if [ "$RUNNING_COUNT" -eq "$TOTAL_COUNT" ] && [ "$UNHEALTHY" -eq "0" ]; then
            all_healthy=true
            break
        fi
        
        sleep ${HEALTH_CHECK_INTERVAL}
    done
    
    if [ "$all_healthy" = true ]; then
        log_success "All containers are healthy"
        return 0
    else
        log_error "Some containers are not healthy after ${MAX_HEALTH_CHECK_ATTEMPTS} attempts"
        log_error "Container status:"
        docker compose ps
        return 1
    fi
}

# Test application endpoints
test_endpoints() {
    if [ "$DO_HEALTH_CHECK" = false ]; then
        log_info "Skipping endpoint tests (--skip-health flag set)"
        return 0
    fi
    
    log_info "Testing application endpoints..."
    
    # Test backend health endpoint
    log_info "Testing backend health endpoint..."
    BACKEND_HEALTH=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/health || echo "000")
    
    if [ "$BACKEND_HEALTH" = "200" ]; then
        log_success "Backend health check passed"
    else
        log_warning "Backend health check failed (HTTP ${BACKEND_HEALTH})"
    fi
    
    # Test frontend
    log_info "Testing frontend..."
    FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 || echo "000")
    
    if [ "$FRONTEND_STATUS" = "200" ] || [ "$FRONTEND_STATUS" = "301" ]; then
        log_success "Frontend is responding"
    else
        log_warning "Frontend health check failed (HTTP ${FRONTEND_STATUS})"
    fi
    
    # Test HTTPS endpoint (if available)
    log_info "Testing HTTPS endpoint..."
    HTTPS_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://cryptoswap.com/health 2>/dev/null || echo "000")
    
    if [ "$HTTPS_STATUS" = "200" ]; then
        log_success "HTTPS endpoint is responding"
    else
        log_warning "HTTPS endpoint test failed (HTTP ${HTTPS_STATUS})"
    fi
}

# Show container status
show_container_status() {
    log_info "Container status:"
    echo ""
    docker compose ps
    echo ""
    
    log_info "Docker stats:"
    echo ""
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
    echo ""
}

# Show logs
show_recent_logs() {
    log_info "Recent container logs:"
    echo ""
    docker compose logs --tail=20
    echo ""
}

# Rollback deployment
rollback_deployment() {
    log_warning "Rolling back deployment..."
    
    # Get last deployment commit
    if [ -f "${BACKUP_DIR}/last_deployment_commit.txt" ]; then
        LAST_COMMIT=$(cat ${BACKUP_DIR}/last_deployment_commit.txt)
        log_info "Rolling back to commit: ${LAST_COMMIT}"
        
        cd ${APP_DIR}
        git checkout ${LAST_COMMIT}
        
        # Stop and rebuild
        stop_containers
        build_images
        start_containers
        wait_for_containers
        check_container_health
        
        log_success "Rollback completed"
    else
        log_error "No previous deployment commit found"
        exit 1
    fi
}

# Send deployment notification (optional)
send_notification() {
    local status=$1
    local message=$2
    
    # Add your notification logic here (e.g., Slack, email, Discord)
    # Example: curl -X POST -H 'Content-type: application/json' --data '{"text":"'"$message"'"}' YOUR_WEBHOOK_URL
    
    log_info "Notification: ${message}"
}

# Print deployment summary
print_summary() {
    local deployment_status=$1
    
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║           Deployment Summary                                   ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    if [ "$deployment_status" = "success" ]; then
        log_success "Deployment completed successfully!"
        
        echo "Deployment Details:"
        echo "  ✓ Code updated from Git repository"
        echo "  ✓ Docker images rebuilt"
        echo "  ✓ Containers restarted"
        echo "  ✓ Health checks passed"
        echo ""
        echo "Application URLs:"
        echo "  - Frontend: http://localhost:3000"
        echo "  - Backend API: http://localhost:8000"
        echo "  - Production: https://cryptoswap.com"
        echo ""
        echo "Useful Commands:"
        echo "  - View logs: docker compose logs -f"
        echo "  - View status: docker compose ps"
        echo "  - Restart: docker compose restart"
        echo "  - Stop: docker compose down"
        echo ""
        
        send_notification "success" "CSwap DEX deployment completed successfully"
    else
        log_error "Deployment failed!"
        
        echo "Troubleshooting:"
        echo "  - Check logs: docker compose logs"
        echo "  - Check container status: docker compose ps"
        echo "  - Rollback: ./deploy.sh --rollback"
        echo ""
        
        send_notification "failure" "CSwap DEX deployment failed - please investigate"
    fi
}

# Main execution
main() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║      Deployment Script for CSwap DEX Exchange                  ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Parse arguments
    parse_args "$@"
    
    # Handle rollback
    if [ "$DO_ROLLBACK" = true ]; then
        rollback_deployment
        exit 0
    fi
    
    # Start deployment
    log_info "Starting deployment at $(date)"
    
    # Check prerequisites
    check_prerequisites
    create_directories
    
    # Backup current state
    backup_current_state
    
    # Update code
    pull_code
    
    # Stop containers
    stop_containers
    
    # Clean Docker resources
    clean_docker
    
    # Build images
    build_images
    
    # Start containers
    start_containers
    
    # Wait for containers
    wait_for_containers
    
    # Check health
    if check_container_health; then
        test_endpoints
        show_container_status
        show_recent_logs
        print_summary "success"
        exit 0
    else
        log_error "Health checks failed"
        show_container_status
        show_recent_logs
        print_summary "failure"
        
        # Ask if user wants to rollback
        read -p "Do you want to rollback? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rollback_deployment
        fi
        
        exit 1
    fi
}

# Run main function
main "$@"

