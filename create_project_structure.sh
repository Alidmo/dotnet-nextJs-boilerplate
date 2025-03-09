#!/bin/bash
set -e

# Expects one parameter: PROJECT_DIR
PROJECT_DIR="$1"
mkdir -p "${PROJECT_DIR}"/{backend,frontend,apache}
echo "Project folders created under ${PROJECT_DIR}"
