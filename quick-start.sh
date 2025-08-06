#!/bin/bash

# Quick Start Script for Bug Tracking System
# This script automates the entire setup process

set -e  # Exit on any error

echo "=== Bug Tracking System - Quick Start ==="
echo "This script will set up the complete system"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
print_status "Checking prerequisites..."

# Check Java
if ! command -v java &> /dev/null; then
    print_error "Java is not installed or not in PATH"
    exit 1
fi

# Check JBOSS_HOME
if [ -z "$JBOSS_HOME" ]; then
    print_error "JBOSS_HOME environment variable is not set"
    echo "Please set JBOSS_HOME to your JBoss installation directory"
    exit 1
fi

# Check if JBoss exists
if [ ! -d "$JBOSS_HOME" ]; then
    print_error "JBoss installation not found at $JBOSS_HOME"
    exit 1
fi

# Check Ant
if ! command -v ant &> /dev/null; then
    print_error "Apache Ant is not installed or not in PATH"
    exit 1
fi

print_status "Prerequisites check passed!"

# Check if Oracle database is accessible
print_status "Checking Oracle database connection..."
if command -v sqlplus &> /dev/null; then
    if sqlplus -s bugtracker/bugtracker123@localhost:1521:xe <<< "SELECT 1 FROM dual;" &> /dev/null; then
        print_status "Database connection successful!"
    else
        print_warning "Cannot connect to database. Please ensure Oracle is running and configured."
        echo "You may need to run the database setup manually:"
        echo "  ./setup-database.sh"
    fi
else
    print_warning "SQL*Plus not found. Please ensure Oracle Database is installed."
fi

# Build the application
print_status "Building application..."
if ant clean compile war; then
    print_status "Build successful!"
else
    print_error "Build failed!"
    exit 1
fi

# Deploy to JBoss
print_status "Deploying to JBoss..."
if ant deploy; then
    print_status "Deployment successful!"
else
    print_error "Deployment failed!"
    exit 1
fi

# Check if JBoss is running
print_status "Checking JBoss status..."
if curl -s http://localhost:8080 &> /dev/null; then
    print_status "JBoss is running!"
else
    print_warning "JBoss does not appear to be running."
    echo "Please start JBoss manually:"
    echo "  $JBOSS_HOME/bin/standalone.sh"
fi

echo ""
echo "=== Setup Complete! ==="
echo ""
echo "Application URL: http://localhost:8080/BugTrackingSystem"
echo ""
echo "Default credentials:"
echo "  Admin: admin@bugtracker.com / admin123"
echo "  Manager: manager@bugtracker.com / manager123"
echo "  Developer: dev1@bugtracker.com / dev123"
echo ""
echo "Next steps:"
echo "1. Start JBoss if not already running"
echo "2. Open the application URL in your browser"
echo "3. Login with the default credentials"
echo "4. Change default passwords for production use"
echo ""
echo "For troubleshooting, see INSTALL.md" 