#!/bin/bash
set -e

# Expects two parameters: PROJECT_DIR and projectName
PROJECT_DIR="$1"
projectName="$2"

cat <<EOF > "${PROJECT_DIR}/docker-compose.yml"
version: '3.8'
services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: ${projectName}-backend
    ports:
      - "5000:80"
    environment:
      - ASPNETCORE_ENVIRONMENT=Development
    networks:
      mynetwork:

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: ${projectName}-frontend
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
    volumes:
      - ./frontend:/app
    command: npm run dev
    networks:
      mynetwork:
        aliases:
          - frontend

  mysql:
    image: mysql:8
    container_name: ${projectName}-mysql
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: ${projectName}
    ports:
      - "3307:3306"
    volumes:
      - mysql-data:/var/lib/mysql
    networks:
      mynetwork:

  apache:
    image: httpd:2.4
    container_name: ${projectName}-apache
    ports:
      - "80:80"
    volumes:
      - ./apache/httpd.conf:/usr/local/apache2/conf/httpd.conf:ro
    depends_on:
      - frontend
      - backend
    command: httpd-foreground -f /usr/local/apache2/conf/httpd.conf
    networks:
      mynetwork:

volumes:
  mysql-data:

networks:
  mynetwork:
    driver: bridge
EOF

echo "Docker Compose file generated at ${PROJECT_DIR}/docker-compose.yml."
