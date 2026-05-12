#!/bin/bash

###############################################################################
# Actual Budget REST API - Deploy Helper Script
# 
# This script helps manage deployment of the API for production use
# Supports both SQLite and PostgreSQL configurations
#
# Usage: ./deploy.sh [command] [options]
###############################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DEFAULT_DB_TYPE="sqlite"
DEFAULT_PORT=3010
ENV_FILE=".env"
DOCKER_COMPOSE_SQLITE="docker-compose.prod.sqlite.yml"
DOCKER_COMPOSE_POSTGRES="docker-compose.prod.postgres.yml"

###############################################################################
# Functions
###############################################################################

print_header() {
    echo -e "${BLUE}
╔════════════════════════════════════════════════════════════════╗
║     Actual Budget REST API - Deploy Helper (Port 3010)        ║
╚════════════════════════════════════════════════════════════════╝${NC}
"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
    exit 1
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

show_usage() {
    cat << EOF
Usage: ./deploy.sh [command] [options]

Commands:
  up              Start the application (default: SQLite)
  down            Stop the application
  logs            Show application logs
  ps              Show running containers
  restart         Restart the application
  health          Check application health status
  config          Validate configuration
  init            Initialize data directories and .env file
  help            Show this help message

Options:
  -d, --db        Database type: sqlite (default) or postgres
  -f, --follow    Follow logs in real-time (for logs command)
  -n, --lines     Number of log lines (default: 100)

Examples:
  ./deploy.sh up                          # Start with SQLite
  ./deploy.sh up --db postgres            # Start with PostgreSQL
  ./deploy.sh logs -f                     # Follow logs
  ./deploy.sh health                      # Check health
  ./deploy.sh down                        # Stop application
EOF
}

# Detect which docker-compose file to use
get_compose_file() {
    local db_type=${1:-$DEFAULT_DB_TYPE}
    
    if [ "$db_type" = "postgres" ]; then
        echo "$DOCKER_COMPOSE_POSTGRES"
    else
        echo "$DOCKER_COMPOSE_SQLITE"
    fi
}

# Check if .env file exists
check_env_file() {
    if [ ! -f "$ENV_FILE" ]; then
        print_warning "$ENV_FILE not found. Creating from .env.example..."
        
        if [ -f ".env.example" ]; then
            cp .env.example "$ENV_FILE"
            print_success "$ENV_FILE created from .env.example"
            print_warning "Please edit $ENV_FILE with your configuration"
            return 1
        else
            print_error ".env.example not found either"
        fi
    fi
    return 0
}

# Validate .env file
validate_env() {
    print_info "Validating environment configuration..."
    
    local required_vars=(
        "ADMIN_PASSWORD"
        "JWT_SECRET"
        "JWT_REFRESH_SECRET"
        "SESSION_SECRET"
        "ACTUAL_SERVER_URL"
        "ACTUAL_PASSWORD"
        "ACTUAL_SYNC_ID"
    )
    
    local missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if ! grep -q "^${var}=" "$ENV_FILE"; then
            missing_vars+=("$var")
        fi
    done
    
    if [ ${#missing_vars[@]} -gt 0 ]; then
        print_error "Missing required variables in $ENV_FILE: ${missing_vars[*]}"
    fi
    
    # Check secret lengths
    local jwt_secret=$(grep "^JWT_SECRET=" "$ENV_FILE" | cut -d'=' -f2 | sed 's/^[" '"'"']//;s/[" '"'"']$//')
    local session_secret=$(grep "^SESSION_SECRET=" "$ENV_FILE" | cut -d'=' -f2 | sed 's/^[" '"'"']//;s/[" '"'"']$//')
    
    if [ ${#jwt_secret} -lt 32 ]; then
        print_warning "JWT_SECRET should be at least 32 characters (currently: ${#jwt_secret})"
    fi
    
    if [ ${#session_secret} -lt 32 ]; then
        print_warning "SESSION_SECRET should be at least 32 characters (currently: ${#session_secret})"
    fi
    
    print_success "Environment validation passed"
}

# Initialize data directories
init_directories() {
    print_info "Initializing data directories..."
    
    mkdir -p data/prod/actual-api
    mkdir -p data/prod/redis
    mkdir -p data/prod/postgres
    
    chmod 755 data/prod/*
    
    print_success "Data directories initialized"
}

# Start the application
start_app() {
    local db_type=${1:-$DEFAULT_DB_TYPE}
    local compose_file=$(get_compose_file "$db_type")
    
    print_info "Starting Actual Budget REST API (port $DEFAULT_PORT) with $db_type..."
    
    if ! check_env_file; then
        print_warning "Please configure $ENV_FILE first"
        return 1
    fi
    
    validate_env
    init_directories
    
    docker-compose -f "$compose_file" --env-file "$ENV_FILE" up -d
    
    print_success "Application started"
    print_info "Waiting for services to be ready (30 seconds)..."
    sleep 30
    
    # Try to check health
    print_info "Checking health status..."
    check_health
}

# Stop the application
stop_app() {
    local db_type=${1:-$DEFAULT_DB_TYPE}
    local compose_file=$(get_compose_file "$db_type")
    
    print_info "Stopping application..."
    docker-compose -f "$compose_file" down
    
    print_success "Application stopped"
}

# Show logs
show_logs() {
    local db_type=${1:-$DEFAULT_DB_TYPE}
    local follow=${2:-false}
    local lines=${3:-100}
    local compose_file=$(get_compose_file "$db_type")
    
    if [ "$follow" = "true" ]; then
        docker-compose -f "$compose_file" logs -f --tail="$lines" actual-rest-api
    else
        docker-compose -f "$compose_file" logs --tail="$lines" actual-rest-api
    fi
}

# Show ps
show_ps() {
    local db_type=${1:-$DEFAULT_DB_TYPE}
    local compose_file=$(get_compose_file "$db_type")
    
    docker-compose -f "$compose_file" ps
}

# Restart the application
restart_app() {
    local db_type=${1:-$DEFAULT_DB_TYPE}
    
    stop_app "$db_type"
    sleep 2
    start_app "$db_type"
}

# Check health
check_health() {
    print_info "Checking API health at http://localhost:$DEFAULT_PORT/v2/health..."
    
    if command -v curl &> /dev/null; then
        local response=$(curl -s -w "\n%{http_code}" http://localhost:$DEFAULT_PORT/v2/health 2>/dev/null || echo "error\n000")
        local body=$(echo "$response" | head -n -1)
        local http_code=$(echo "$response" | tail -n 1)
        
        if [ "$http_code" = "200" ]; then
            print_success "API is healthy (HTTP $http_code)"
            print_info "Response: $body"
        else
            print_warning "API returned HTTP $http_code"
            print_info "Response: $body"
        fi
    else
        print_warning "curl not found. Cannot check health status."
        print_info "Manually check: curl http://localhost:$DEFAULT_PORT/v2/health"
    fi
}

# Validate configuration
validate_config() {
    local db_type=${1:-$DEFAULT_DB_TYPE}
    local compose_file=$(get_compose_file "$db_type")
    
    print_info "Validating docker-compose configuration..."
    
    if docker-compose -f "$compose_file" config > /dev/null 2>&1; then
        print_success "Configuration is valid"
        print_info "Preview:"
        docker-compose -f "$compose_file" config | head -40
        echo "..."
    else
        print_error "Configuration is invalid"
    fi
}

# Initialize setup
init_setup() {
    print_header
    print_info "Initializing deployment setup..."
    
    if [ ! -f "$ENV_FILE" ]; then
        if [ -f ".env.example" ]; then
            cp .env.example "$ENV_FILE"
            print_success "$ENV_FILE created"
            print_warning "⚠️  IMPORTANT: Edit $ENV_FILE with your actual configuration before deploying!"
        fi
    fi
    
    init_directories
    
    print_success "Initialization complete!"
    print_info "Next steps:"
    echo "  1. Edit $ENV_FILE with your configuration"
    echo "  2. Run: ./deploy.sh up"
    echo "  3. Check health: ./deploy.sh health"
}

###############################################################################
# Main Script
###############################################################################

main() {
    print_header
    
    # Parse arguments
    local command="${1:-help}"
    local db_type="$DEFAULT_DB_TYPE"
    local follow=false
    local lines=100
    
    # Parse options
    shift || true
    while [ $# -gt 0 ]; do
        case "$1" in
            -d|--db)
                db_type="$2"
                shift 2
                ;;
            -f|--follow)
                follow=true
                shift
                ;;
            -n|--lines)
                lines="$2"
                shift 2
                ;;
            *)
                break
                ;;
        esac
    done
    
    # Execute command
    case "$command" in
        up|start)
            start_app "$db_type"
            ;;
        down|stop)
            stop_app "$db_type"
            ;;
        logs|log)
            show_logs "$db_type" "$follow" "$lines"
            ;;
        ps|list)
            show_ps "$db_type"
            ;;
        restart)
            restart_app "$db_type"
            ;;
        health)
            check_health
            ;;
        config)
            validate_config "$db_type"
            ;;
        init)
            init_setup
            ;;
        help|--help|-h)
            show_usage
            ;;
        *)
            print_error "Unknown command: $command"
            ;;
    esac
}

# Run main if script is executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
