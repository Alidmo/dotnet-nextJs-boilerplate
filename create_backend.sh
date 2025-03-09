#!/bin/bash
set -e

# Expects two parameters: PROJECT_DIR and projectName
PROJECT_DIR="$1"
projectName="$2"

# Navigate to backend folder
cd "${PROJECT_DIR}/backend"

# If no C# project exists, create a new Web API project (using 'backend' as project name)
if ! ls *.csproj 1> /dev/null 2>&1; then
  echo "Creating new .NET Web API project..."
  dotnet new webapi -n backend --no-https
  # Move generated files up to the backend folder and remove the subfolder
  mv backend/* .
  rmdir backend
fi

# Create or overwrite Dockerfile for backend
cat <<'EOF' > Dockerfile
# Use the official .NET SDK image to build the app
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src
# Copy the project file and restore dependencies
COPY *.csproj ./
RUN dotnet restore
# Copy the remaining source code and publish
COPY . ./
RUN dotnet publish -c Release -o /app

# Use the official ASP.NET Core runtime image for the final container
FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app
COPY --from=build /app .
ENTRYPOINT ["dotnet", "backend.dll"]
EOF

echo "Backend project and Dockerfile created in ${PROJECT_DIR}/backend"
