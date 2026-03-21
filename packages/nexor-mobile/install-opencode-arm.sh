#!/data/data/com.termux/files/usr/bin/bash

# OpenCode Manual Installation Script for Termux (ARM)
# This bypasses the official install script which blocks ARM

echo "🚀 Installing OpenCode on ARM (Termux)..."
echo ""

# Step 1: Update packages
echo "📦 Step 1/5: Updating packages..."
pkg update -y && pkg upgrade -y

# Step 2: Install Node.js
echo "📦 Step 2/5: Installing Node.js..."
if ! command -v node &> /dev/null; then
    pkg install -y nodejs
fi

echo "✅ Node.js version: $(node --version)"
echo "✅ npm version: $(npm --version)"

# Step 3: Try installing OpenCode via npm
echo "📦 Step 3/5: Installing OpenCode via npm..."
npm install -g opencode-ai 2>&1 | tee /tmp/opencode-install.log

# Check if installation succeeded
if command -v opencode &> /dev/null; then
    echo "✅ OpenCode installed successfully!"
    echo "✅ OpenCode version: $(opencode --version 2>&1 || echo 'version check failed')"
else
    echo "⚠️  npm install failed, trying alternative method..."
    
    # Step 4: Try installing from GitHub directly
    echo "📦 Step 4/5: Cloning OpenCode from GitHub..."
    
    # Install git if not present
    if ! command -v git &> /dev/null; then
        pkg install -y git
    fi
    
    cd ~
    if [ -d "opencode" ]; then
        rm -rf opencode
    fi
    
    git clone https://github.com/anomalyco/opencode.git
    cd opencode
    
    # Install dependencies
    echo "📦 Installing dependencies..."
    npm install
    
    # Try to build
    echo "🔨 Building OpenCode..."
    npm run build 2>&1 | tee /tmp/opencode-build.log
    
    # Create symlink
    echo "🔗 Creating symlink..."
    mkdir -p ~/.local/bin
    ln -sf ~/opencode/packages/opencode/bin/opencode ~/.local/bin/opencode
    
    # Add to PATH if not already there
    if ! grep -q "export PATH=\$HOME/.local/bin:\$PATH" ~/.bashrc; then
        echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
    fi
    
    source ~/.bashrc
fi

# Step 5: Test OpenCode
echo ""
echo "🧪 Step 5/5: Testing OpenCode..."
if command -v opencode &> /dev/null; then
    echo "✅ SUCCESS! OpenCode is installed!"
    echo ""
    echo "📝 To start OpenCode, run:"
    echo "   opencode --port 4096"
    echo ""
    echo "🎯 Or create a startup script:"
    echo "   echo 'opencode --port 4096' > ~/start-opencode.sh"
    echo "   chmod +x ~/start-opencode.sh"
else
    echo "❌ Installation failed. Check logs:"
    echo "   /tmp/opencode-install.log"
    echo "   /tmp/opencode-build.log"
    echo ""
    echo "📋 System info:"
    echo "   OS: $(uname -s)"
    echo "   Arch: $(uname -m)"
    echo "   Node: $(node --version)"
    echo ""
    echo "Please share these logs for debugging."
fi
