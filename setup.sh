#!/bin/bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
ARCH="amd64"
PORT="6160"
CONFIG_FILE="snell-server.conf"
CONTAINER_NAME="snell-server"
IMAGE_TAG="latest"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
    -a, --arch ARCH         Target architecture (amd64, arm64) [default: amd64]
    -p, --port PORT         Port to expose [default: 6160]
    -c, --config FILE       Configuration file path [default: snell-server.conf]
    -n, --name NAME         Container name [default: snell-server]
    -t, --tag TAG           Image tag [default: latest]
    -h, --help              Show this help message

Examples:
    $0                      # Build and run with defaults
    $0 -a arm64 -p 8080     # Build for ARM64 and expose port 8080
    $0 --config ./my.conf   # Use custom configuration file
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--arch)
            ARCH="$2"
            shift 2
            ;;
        -p|--port)
            PORT="$2"
            shift 2
            ;;
        -c|--config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        -n|--name)
            CONTAINER_NAME="$2"
            shift 2
            ;;
        -t|--tag)
            IMAGE_TAG="$2"
            shift 2
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate architecture
case "$ARCH" in
    amd64|arm64)
        ;;
    *)
        print_error "Unsupported architecture: $ARCH"
        print_status "Supported architectures: amd64, arm64"
        exit 1
        ;;
esac

print_status "Starting Snell Server setup..."
print_status "Architecture: $ARCH"
print_status "Port: $PORT"
print_status "Container name: $CONTAINER_NAME"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if configuration file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    print_warning "Configuration file '$CONFIG_FILE' not found."

    if [[ -f "snell-server.conf.example" ]]; then
        print_status "Creating configuration file from example..."
        cp snell-server.conf.example "$CONFIG_FILE"

        # Generate a random PSK
        if command -v openssl &> /dev/null; then
            PSK=$(openssl rand -base64 32)
            sed -i.bak "s/your-pre-shared-key-here/$PSK/" "$CONFIG_FILE"
            rm -f "$CONFIG_FILE.bak"
            print_success "Generated random PSK: $PSK"
        else
            print_warning "OpenSSL not found. Please manually set the PSK in $CONFIG_FILE"
        fi

        print_warning "Please review and edit '$CONFIG_FILE' before continuing."
        read -p "Press Enter to continue or Ctrl+C to exit..."
    else
        print_error "No configuration file found. Please create '$CONFIG_FILE' or run from the project directory."
        exit 1
    fi
fi

# Stop existing container if running
if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
    print_status "Stopping existing container..."
    docker stop "$CONTAINER_NAME" || true
fi

# Remove existing container if exists
if docker ps -aq -f name="$CONTAINER_NAME" | grep -q .; then
    print_status "Removing existing container..."
    docker rm "$CONTAINER_NAME" || true
fi

# Build the image
print_status "Building Docker image for $ARCH..."
docker build --build-arg SNELL_VERSION=v5.0.0b3 -t "snell-server:$IMAGE_TAG" .

if [[ $? -eq 0 ]]; then
    print_success "Docker image built successfully!"
else
    print_error "Failed to build Docker image"
    exit 1
fi

# Run the container
print_status "Starting Snell Server container..."
docker run -d \
    --name "$CONTAINER_NAME" \
    -p "$PORT:6160" \
    -v "$(pwd)/$CONFIG_FILE:/etc/snell-server.conf:ro" \
    --restart unless-stopped \
    "snell-server:$IMAGE_TAG" \
    snell-server -c /etc/snell-server.conf

if [[ $? -eq 0 ]]; then
    print_success "Snell Server started successfully!"
    print_status "Container name: $CONTAINER_NAME"
    print_status "Listening on port: $PORT"
    print_status "Configuration: $CONFIG_FILE"

    # Show container status
    echo
    print_status "Container status:"
    docker ps -f name="$CONTAINER_NAME"

    echo
    print_status "To view logs: docker logs $CONTAINER_NAME"
    print_status "To stop: docker stop $CONTAINER_NAME"
    print_status "To restart: docker restart $CONTAINER_NAME"
else
    print_error "Failed to start Snell Server container"
    exit 1
fi
