#!/bin/bash

################################################################################
# Vultr Server Provisioning Script for CSwap DEX Exchange
# 
# This script automates the creation of a Vultr server instance using the
# Vultr API v2. It provisions a server with the following specs:
# - Plan: vc2-2c-4gb (2 vCPU, 4GB RAM, 80GB SSD)
# - Region: Seattle (US West)
# - OS: Ubuntu 22.04 LTS
# 
# Prerequisites:
# - VULTR_API_KEY environment variable must be set
# - curl and jq must be installed
#
# Usage:
#   export VULTR_API_KEY="your-api-key-here"
#   ./vultr-provision.sh
################################################################################

set -e  # Exit on error
set -u  # Exit on undefined variable

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
VULTR_API_BASE="https://api.vultr.com/v2"
PLAN_ID="vc2-2c-4gb"
REGION_ID="sea"  # Seattle, US West
OS_ID=1743       # Ubuntu 22.04 LTS x64
HOSTNAME="cryptoswap-dex"
LABEL="CSwap DEX Exchange Server"
ENABLE_BACKUPS="true"
ENABLE_IPV6="true"
ENABLE_DDOS_PROTECTION="false"

# Log functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    if [ -z "${VULTR_API_KEY:-}" ]; then
        log_error "VULTR_API_KEY environment variable is not set"
        echo "Please set it with: export VULTR_API_KEY='your-api-key-here'"
        exit 1
    fi
    
    if ! command -v curl &> /dev/null; then
        log_error "curl is not installed. Please install it first."
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        log_error "jq is not installed. Please install it first."
        echo "Install with: sudo apt-get install jq (Ubuntu) or brew install jq (Mac)"
        exit 1
    fi
    
    log_success "All prerequisites met"
}

# Verify Vultr API key
verify_api_key() {
    log_info "Verifying Vultr API key..."
    
    response=$(curl -s -w "\n%{http_code}" \
        -H "Authorization: Bearer ${VULTR_API_KEY}" \
        "${VULTR_API_BASE}/account")
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" != "200" ]; then
        log_error "Invalid API key or API error (HTTP $http_code)"
        echo "$body" | jq '.' 2>/dev/null || echo "$body"
        exit 1
    fi
    
    log_success "API key verified"
}

# Check if plan is available
verify_plan() {
    log_info "Verifying plan availability..."
    
    response=$(curl -s -w "\n%{http_code}" \
        -H "Authorization: Bearer ${VULTR_API_KEY}" \
        "${VULTR_API_BASE}/plans")
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" != "200" ]; then
        log_error "Failed to fetch plans (HTTP $http_code)"
        exit 1
    fi
    
    plan_exists=$(echo "$body" | jq -r ".plans[] | select(.id == \"${PLAN_ID}\") | .id")
    
    if [ -z "$plan_exists" ]; then
        log_error "Plan ${PLAN_ID} not found"
        exit 1
    fi
    
    log_success "Plan ${PLAN_ID} is available"
}

# Check if region is available
verify_region() {
    log_info "Verifying region availability..."
    
    response=$(curl -s -w "\n%{http_code}" \
        -H "Authorization: Bearer ${VULTR_API_KEY}" \
        "${VULTR_API_BASE}/regions")
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" != "200" ]; then
        log_error "Failed to fetch regions (HTTP $http_code)"
        exit 1
    fi
    
    region_exists=$(echo "$body" | jq -r ".regions[] | select(.id == \"${REGION_ID}\") | .id")
    
    if [ -z "$region_exists" ]; then
        log_error "Region ${REGION_ID} not found"
        exit 1
    fi
    
    log_success "Region ${REGION_ID} (Seattle) is available"
}

# Create firewall group
create_firewall_group() {
    log_info "Creating firewall group..."
    
    firewall_data=$(cat <<EOF
{
    "description": "CSwap DEX Firewall Rules"
}
EOF
)
    
    response=$(curl -s -w "\n%{http_code}" \
        -X POST \
        -H "Authorization: Bearer ${VULTR_API_KEY}" \
        -H "Content-Type: application/json" \
        -d "$firewall_data" \
        "${VULTR_API_BASE}/firewalls")
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" != "201" ]; then
        log_warning "Failed to create firewall group (HTTP $http_code) - may already exist"
        return 0
    fi
    
    firewall_group_id=$(echo "$body" | jq -r '.firewall_group.id')
    log_success "Firewall group created: ${firewall_group_id}"
    
    # Add firewall rules
    add_firewall_rules "$firewall_group_id"
    
    echo "$firewall_group_id"
}

# Add firewall rules
add_firewall_rules() {
    local firewall_group_id=$1
    log_info "Adding firewall rules..."
    
    # SSH (22)
    curl -s -X POST \
        -H "Authorization: Bearer ${VULTR_API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{"ip_type":"v4","protocol":"tcp","subnet":"0.0.0.0","subnet_size":0,"port":"22","notes":"SSH"}' \
        "${VULTR_API_BASE}/firewalls/${firewall_group_id}/rules" > /dev/null
    
    # HTTP (80)
    curl -s -X POST \
        -H "Authorization: Bearer ${VULTR_API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{"ip_type":"v4","protocol":"tcp","subnet":"0.0.0.0","subnet_size":0,"port":"80","notes":"HTTP"}' \
        "${VULTR_API_BASE}/firewalls/${firewall_group_id}/rules" > /dev/null
    
    # HTTPS (443)
    curl -s -X POST \
        -H "Authorization: Bearer ${VULTR_API_KEY}" \
        -H "Content-Type: application/json" \
        -d '{"ip_type":"v4","protocol":"tcp","subnet":"0.0.0.0","subnet_size":0,"port":"443","notes":"HTTPS"}' \
        "${VULTR_API_BASE}/firewalls/${firewall_group_id}/rules" > /dev/null
    
    log_success "Firewall rules added"
}

# Create instance
create_instance() {
    log_info "Creating Vultr instance..."
    
    instance_data=$(cat <<EOF
{
    "region": "${REGION_ID}",
    "plan": "${PLAN_ID}",
    "os_id": ${OS_ID},
    "label": "${LABEL}",
    "hostname": "${HOSTNAME}",
    "enable_ipv6": ${ENABLE_IPV6},
    "backups": "enabled",
    "ddos_protection": ${ENABLE_DDOS_PROTECTION},
    "tags": ["cswap", "dex", "production"]
}
EOF
)
    
    response=$(curl -s -w "\n%{http_code}" \
        -X POST \
        -H "Authorization: Bearer ${VULTR_API_KEY}" \
        -H "Content-Type: application/json" \
        -d "$instance_data" \
        "${VULTR_API_BASE}/instances")
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" != "202" ]; then
        log_error "Failed to create instance (HTTP $http_code)"
        echo "$body" | jq '.' 2>/dev/null || echo "$body"
        exit 1
    fi
    
    instance_id=$(echo "$body" | jq -r '.instance.id')
    log_success "Instance created: ${instance_id}"
    
    echo "$instance_id"
}

# Wait for instance to be ready
wait_for_instance() {
    local instance_id=$1
    log_info "Waiting for instance to be ready (this may take 2-5 minutes)..."
    
    local max_attempts=60
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        response=$(curl -s -w "\n%{http_code}" \
            -H "Authorization: Bearer ${VULTR_API_KEY}" \
            "${VULTR_API_BASE}/instances/${instance_id}")
        
        http_code=$(echo "$response" | tail -n1)
        body=$(echo "$response" | sed '$d')
        
        if [ "$http_code" != "200" ]; then
            log_error "Failed to get instance status (HTTP $http_code)"
            exit 1
        fi
        
        status=$(echo "$body" | jq -r '.instance.status')
        server_status=$(echo "$body" | jq -r '.instance.server_status')
        
        if [ "$status" == "active" ] && [ "$server_status" == "ok" ]; then
            log_success "Instance is ready!"
            echo "$body" | jq '.instance'
            return 0
        fi
        
        echo -n "."
        sleep 5
        attempt=$((attempt + 1))
    done
    
    log_error "Instance did not become ready in time"
    exit 1
}

# Get instance details
get_instance_details() {
    local instance_id=$1
    
    response=$(curl -s -w "\n%{http_code}" \
        -H "Authorization: Bearer ${VULTR_API_KEY}" \
        "${VULTR_API_BASE}/instances/${instance_id}")
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" != "200" ]; then
        log_error "Failed to get instance details (HTTP $http_code)"
        exit 1
    fi
    
    echo "$body"
}

# Print server information
print_server_info() {
    local instance_details=$1
    
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║           CSwap DEX Server Successfully Provisioned           ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    instance_id=$(echo "$instance_details" | jq -r '.instance.id')
    main_ip=$(echo "$instance_details" | jq -r '.instance.main_ip')
    default_password=$(echo "$instance_details" | jq -r '.instance.default_password')
    hostname=$(echo "$instance_details" | jq -r '.instance.hostname')
    label=$(echo "$instance_details" | jq -r '.instance.label')
    
    echo "Server Details:"
    echo "  Instance ID: ${instance_id}"
    echo "  Label: ${label}"
    echo "  Hostname: ${hostname}"
    echo "  IP Address: ${main_ip}"
    echo "  Default Password: ${default_password}"
    echo ""
    echo "SSH Connection:"
    echo "  ssh root@${main_ip}"
    echo "  Password: ${default_password}"
    echo ""
    echo "Next Steps:"
    echo "  1. Update DNS records for cryptoswap.com to point to ${main_ip}"
    echo "     - A record: cryptoswap.com -> ${main_ip}"
    echo "     - A record: www.cryptoswap.com -> ${main_ip}"
    echo ""
    echo "  2. SSH into the server and run the initialization script:"
    echo "     ssh root@${main_ip}"
    echo "     curl -o server-init.sh https://raw.githubusercontent.com/your-repo/server-init.sh"
    echo "     chmod +x server-init.sh"
    echo "     ./server-init.sh"
    echo ""
    echo "  3. Follow the deployment guide in VULTR_DEPLOYMENT.md"
    echo ""
    
    # Save server info to file
    echo "$instance_details" | jq '.instance' > vultr-server-info.json
    log_success "Server information saved to vultr-server-info.json"
}

# Main execution
main() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║        Vultr Server Provisioning for CSwap DEX Exchange       ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    check_prerequisites
    verify_api_key
    verify_plan
    verify_region
    
    # Create firewall group (optional, may already exist)
    firewall_group_id=$(create_firewall_group)
    
    # Create instance
    instance_id=$(create_instance)
    
    # Wait for instance to be ready
    wait_for_instance "$instance_id"
    
    # Get final instance details
    instance_details=$(get_instance_details "$instance_id")
    
    # Print server information
    print_server_info "$instance_details"
    
    log_success "Provisioning complete!"
}

# Run main function
main

