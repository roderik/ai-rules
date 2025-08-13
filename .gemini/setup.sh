#!/bin/bash

# Gemini CLI Setup Script
# This script sets up the Gemini CLI configuration in your home directory

set -e

echo "Setting up Gemini CLI configuration..."

# Create global .gemini directory
mkdir -p ~/.gemini

# Copy configuration files
cp -i GEMINI.md ~/.gemini/GEMINI.md
cp -i settings.json ~/.gemini/settings.json
cp -i commands.toml ~/.gemini/commands.toml

