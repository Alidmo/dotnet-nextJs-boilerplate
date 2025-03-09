#!/bin/bash
set -e

echo "=== Starting environment setup ==="

# --- SYSTEM UPDATES & INSTALLATIONS ---
echo "[1/5] Updating system packages..."
sudo apt-get update && sudo apt-get upgrade -y

# Install prerequisites (curl, wget, build-essential)
sudo apt-get install -y curl wget build-essential

# --- INSTALL NVM & NODE ---
if [ -z "$(command -v nvm)" ]; then
  echo "[2/5] Installing NVM (Node Version Manager)..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
  # Load nvm into current session (adjust the path if needed)
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

echo "[2/5] Installing Node.js version 18..."
nvm install 18
nvm use 18
# Confirm node and npm versions:
echo "Node version: $(node -v)"
echo "npm version: $(npm -v)"

# --- INSTALL DOTNET SDK ---
if ! command -v dotnet &> /dev/null; then
  echo "[3/5] Installing .NET SDK 9.0..."
  # Download Microsoft package repository configuration
  wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
  sudo dpkg -i packages-microsoft-prod.deb
  rm packages-microsoft-prod.deb
  sudo apt-get update
  sudo apt-get install -y apt-transport-https
  sudo apt-get update
  sudo apt-get install -y dotnet-sdk-9.0
fi

# --- SET PERMISSIONS FOR CHILD SCRIPTS ---
for script in create_project_structure.sh create_backend.sh create_frontend.sh create_docker_compose.sh create_apache_conf.sh update_hosts.sh; do
  if [ -f "$script" ]; then
    chmod +x "$script"
  fi
done

# --- GET INPUT PARAMETERS ---
projectName="${1:-portal}"
destinationPath="${2:-$(dirname "$(pwd)")}"

echo "Using project name: ${projectName}"
echo "Using destination path: ${destinationPath}"

# Create destination path if it doesn't exist
mkdir -p "${destinationPath}"

# Set the project directory (inside the provided path)
PROJECT_DIR="${destinationPath}/${projectName}"
echo "Creating project directories under ${PROJECT_DIR}"

# --- CALL MODULAR SCRIPTS ---
./create_project_structure.sh "${PROJECT_DIR}"
./create_backend.sh "${PROJECT_DIR}" "${projectName}"
./create_frontend.sh "${PROJECT_DIR}"
./create_docker_compose.sh "${PROJECT_DIR}" "${projectName}"
./create_apache_conf.sh "${PROJECT_DIR}" "${projectName}"
./update_hosts.sh "${projectName}"

# --- CREATE INSTRUCTIONS FILE ---
cat <<EOF > "${PROJECT_DIR}/instructions.txt"
=== VSCode Environment Setup ===
1. Open VSCode and install the 'Remote - WSL' extension if not already installed.
2. Open the folder '${PROJECT_DIR}' in VSCode.
3. From the project root, run:
   docker-compose -f docker-compose.yml up --build
4. Open your browser and go to http://my.${projectName}.local to view your website.
EOF

echo "Project structure and configuration files generated at ${PROJECT_DIR}."
echo "See instructions.txt in the project directory for further setup steps."
