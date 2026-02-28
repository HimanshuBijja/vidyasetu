#!/bin/bash

# ═══════════════════════════════════════════════════════════════
# vidyasetu - Local Development Startup Script
# Starts backend (Express) and frontend (Vite) servers
# ═══════════════════════════════════════════════════════════════

set -e

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKEND_DIR="$ROOT_DIR/backend"
FRONTEND_DIR="$ROOT_DIR/frontend"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# PIDs to track background processes
BACKEND_PID=""
FRONTEND_PID=""

cleanup() {
    echo ""
    echo -e "${YELLOW}Shutting down vidyasetu...${NC}"
    if [ -n "$BACKEND_PID" ] && kill -0 "$BACKEND_PID" 2>/dev/null; then
        kill "$BACKEND_PID" 2>/dev/null
        echo -e "${RED}Backend stopped${NC}"
    fi
    if [ -n "$FRONTEND_PID" ] && kill -0 "$FRONTEND_PID" 2>/dev/null; then
        kill "$FRONTEND_PID" 2>/dev/null
        echo -e "${RED}Frontend stopped${NC}"
    fi
    exit 0
}

trap cleanup SIGINT SIGTERM

echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo -e "${CYAN}       vidyasetu - Starting Up           ${NC}"
echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo ""

# ── Install dependencies if needed ──
if [ ! -d "$BACKEND_DIR/node_modules" ]; then
    echo -e "${YELLOW}Installing backend dependencies...${NC}"
    cd "$BACKEND_DIR" && npm install
    echo -e "${GREEN}Backend dependencies installed${NC}"
fi

if [ ! -d "$FRONTEND_DIR/node_modules" ]; then
    echo -e "${YELLOW}Installing frontend dependencies...${NC}"
    cd "$FRONTEND_DIR" && npm install
    echo -e "${GREEN}Frontend dependencies installed${NC}"
fi

# ── Start Backend ──
echo -e "${CYAN}Starting backend server (port 5001)...${NC}"
cd "$BACKEND_DIR"
npm run dev &
BACKEND_PID=$!

# Wait a moment for backend to initialize
sleep 3

# Verify backend is running
if curl -s http://localhost:5001/ > /dev/null 2>&1; then
    echo -e "${GREEN}Backend is running on http://localhost:5001${NC}"
else
    echo -e "${YELLOW}Backend is starting up (may take a few seconds)...${NC}"
fi

# ── Start Frontend ──
echo -e "${CYAN}Starting frontend dev server (port 5173)...${NC}"
cd "$FRONTEND_DIR"
npm run dev &
FRONTEND_PID=$!

# Wait for frontend to be ready
sleep 4

echo ""
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}       vidyasetu is running!             ${NC}"
echo -e "${GREEN}═══════════════════════════════════════${NC}"
echo ""
echo -e "  Frontend:  ${CYAN}http://localhost:5173${NC}"
echo -e "  Backend:   ${CYAN}http://localhost:5001${NC}"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop all servers${NC}"
echo ""

# Keep script running and wait for child processes
wait
