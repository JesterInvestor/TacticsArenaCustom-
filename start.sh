#!/bin/sh

# Wait for DynamoDB to be ready
echo "Waiting for DynamoDB to be ready..."
max_attempts=30
attempt=0
while [ $attempt -lt $max_attempts ]; do
  if nc -z dynamodb-local 8000 2>/dev/null; then
    echo "DynamoDB is ready!"
    break
  fi
  attempt=$((attempt + 1))
  echo "Waiting for DynamoDB... attempt $attempt/$max_attempts"
  sleep 2
done

if [ $attempt -eq $max_attempts ]; then
  echo "DynamoDB did not become ready in time, continuing anyway..."
fi

echo "Checking dependencies..."
if [ ! -d "node_modules" ]; then
  echo "Installing dependencies..."
  npm install --legacy-peer-deps --prefer-offline --no-audit
else
  echo "Dependencies already installed, skipping..."
fi

echo "Compiling TypeScript..."
npm run compile || true

echo "Building assets and watching for file changes..."
npm run watch &

echo "Starting app..."
# Wait for the node server to terminate
exec node --es-module-specifier-resolution=node --require dotenv/config src/server.js
