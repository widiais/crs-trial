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
    echo "Please create .env file first. See DEPLOYMENT.md for details."
    exit 1
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
