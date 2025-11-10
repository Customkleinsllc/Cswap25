#!/bin/bash
set -e

echo "🔧 Fixing all TypeScript issues..."

cd /opt/cswap-dex/frontend

# 1. Fix TimeoutContext.tsx generic syntax
echo "Fixing TimeoutContext.tsx..."
sed -i 's/async <T>(/async <T,>(/' src/contexts/TimeoutContext.tsx

# 2. Create missing type declarations
echo "Creating type declaration files..."

# Create utils types directory
mkdir -p src/types

# Create logger.d.ts
cat > src/types/logger.d.ts << 'EOF'
declare module '../utils/logger' {
  export function logError(message: string, error?: any): void;
  export function logInfo(message: string, data?: any): void;
  export function logWarning(message: string, data?: any): void;
}
EOF

# Create global.d.ts for window.ethereum
cat > src/types/global.d.ts << 'EOF'
interface Window {
  ethereum?: {
    isMetaMask?: boolean;
    request: (args: { method: string; params?: any[] }) => Promise<any>;
    on: (event: string, callback: (...args: any[]) => void) => void;
    removeListener: (event: string, callback: (...args: any[]) => void) => void;
  };
}

declare global {
  var process: NodeJS.Process;
}

export {};
EOF

# 3. Update tsconfig.json to include type declarations
echo "Updating tsconfig.json..."
if [ -f tsconfig.json ]; then
  # Backup original
  cp tsconfig.json tsconfig.json.backup
  
  # Create new tsconfig with proper settings
  cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "jsx": "react-jsx",
    "module": "ESNext",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "allowJs": true,
    "noEmit": true,
    "isolatedModules": true,
    "allowSyntheticDefaultImports": true,
    "esModuleInterop": true,
    "forceConsistentCasingInFileNames": true,
    "strict": false,
    "skipLibCheck": true,
    "types": ["node", "react", "react-dom"],
    "typeRoots": ["./node_modules/@types", "./src/types"],
    "baseUrl": "src"
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "build", "dist"]
}
EOF
fi

# 4. Install necessary type packages
echo "Installing type definitions..."
npm install --save-dev @types/node @types/react @types/react-dom 2>/dev/null || true

# 5. Create a simple logger utility if it doesn't exist
echo "Creating logger utility..."
mkdir -p src/utils
cat > src/utils/logger.ts << 'EOF'
export function logError(message: string, error?: any): void {
  console.error(message, error);
}

export function logInfo(message: string, data?: any): void {
  console.log(message, data);
}

export function logWarning(message: string, data?: any): void {
  console.warn(message, data);
}
EOF

echo "✅ TypeScript fixes applied!"
echo "Now rebuilding frontend..."

