#!/bin/bash

# Deployment script untuk CRS Trial
# Usage: ./deploy.sh [start|stop|restart|logs|update]

set -e

COMPOSE_FILE="docker-compose.prod.yaml"
ENV_FILE=".env"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if .env file exists
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${RED}Error: .env file not found!${NC}"
    echo "Please create .env file first. Run: ./setup-env.sh"
    echo "Or see DEPLOYMENT.md for details."
    exit 1
fi

# Validate required environment variables
source "$ENV_FILE" 2>/dev/null || true

if [ -z "$SESSION_SECRET" ] || [ "$SESSION_SECRET" = "CHANGE_THIS_TO_RANDOM_SECRET_KEY" ] || [ "$SESSION_SECRET" = "change-this-secret-key" ]; then
    echo -e "${RED}Error: SESSION_SECRET is not set or using default value!${NC}"
    echo "Please set a secure SESSION_SECRET in .env file"
    echo "Generate one with: openssl rand -base64 32"
    exit 1
fi

if [ -z "$POSTGRES_PASSWORD" ] || [ "$POSTGRES_PASSWORD" = "CHANGE_THIS_TO_SECURE_PASSWORD" ]; then
    echo -e "${RED}Error: POSTGRES_PASSWORD is not set or using default value!${NC}"
    echo "Please set a secure POSTGRES_PASSWORD in .env file"
    exit 1
fi

if [ -z "$NEXT_PUBLIC_APP_URL" ]; then
    echo -e "${YELLOW}Warning: NEXT_PUBLIC_APP_URL is not set, using default${NC}"
fi

if [ -z "$COOKIE_SECURE" ]; then
    echo -e "${YELLOW}Warning: COOKIE_SECURE is not set, defaulting to false${NC}"
fi

case "$1" in
    start)
        echo -e "${GREEN}Starting services...${NC}"
        docker-compose -f $COMPOSE_FILE --env-file $ENV_FILE up -d --build
        echo -e "${GREEN}Services started!${NC}"
        echo -e "${YELLOW}Don't forget to run: docker exec -it crs-trial npx prisma db push${NC}"
        ;;
    stop)
        echo -e "${YELLOW}Stopping services...${NC}"
        docker-compose -f $COMPOSE_FILE --env-file $ENV_FILE down
        echo -e "${GREEN}Services stopped!${NC}"
        ;;
    restart)
        echo -e "${YELLOW}Restarting services...${NC}"
        docker-compose -f $COMPOSE_FILE --env-file $ENV_FILE restart
        echo -e "${GREEN}Services restarted!${NC}"
        ;;
    logs)
        docker-compose -f $COMPOSE_FILE --env-file $ENV_FILE logs -f
        ;;
    update)
        echo -e "${GREEN}Updating application...${NC}"
        docker-compose -f $COMPOSE_FILE --env-file $ENV_FILE up -d --build app
        echo -e "${GREEN}Application updated!${NC}"
        ;;
    status)
        echo -e "${GREEN}Container status:${NC}"
        docker ps --filter "name=crs-trial"
        ;;
    setup-db)
        echo -e "${GREEN}Setting up database schema...${NC}"
        docker exec -it crs-trial npx prisma db push
        echo -e "${GREEN}Database schema setup complete!${NC}"
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|logs|update|status|setup-db}"
        echo ""
        echo "Commands:"
        echo "  start      - Start all services"
        echo "  stop       - Stop all services"
        echo "  restart    - Restart all services"
        echo "  logs       - View logs (follow mode)"
        echo "  update     - Update and rebuild app container"
        echo "  status     - Show container status"
        echo "  setup-db   - Setup database schema"
        exit 1
        ;;
esac
