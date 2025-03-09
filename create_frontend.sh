#!/bin/bash
set -e

# Expects one parameter: PROJECT_DIR
PROJECT_DIR="$1"

cd "${PROJECT_DIR}/frontend"

# If package.json does not exist, create a new Next.js project
if [ ! -f package.json ]; then
  echo "Creating a new Next.js project..."
  npx create-next-app@latest . --typescript --eslint --import-alias "@/components/*"
  # Remove any extraneous files or adjust as needed
fi

# Overwrite package.json with our desired configuration
cat <<EOF > package.json
{
  "name": "frontend",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "export": "next export"
  },
  "dependencies": {
    "react": "^19.0.0",
    "react-dom": "^19.0.0",
    "next": "15.2.0"
  },
  "devDependencies": {
    "typescript": "^5",
    "@types/node": "^20",
    "@types/react": "^19",
    "@types/react-dom": "^19",
    "@tailwindcss/postcss": "^4",
    "tailwindcss": "^4",
    "eslint": "^9",
    "eslint-config-next": "15.2.0",
    "@eslint/eslintrc": "^3"
  }
}
EOF
echo "Frontend package.json updated."

# Overwrite next.config.ts with our desired configuration
cat <<EOF > next.config.ts
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: 'export',
  assetPrefix: '',
};

export default nextConfig;
EOF
echo "Frontend next.config.ts updated."
