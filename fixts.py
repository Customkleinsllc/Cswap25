#!/usr/bin/env python3
import sys

file_path = '/opt/cswap-dex/frontend/src/contexts/TimeoutContext.tsx'

with open(file_path, 'r') as f:
    content = f.read()

# Fix the TypeScript generic syntax
content = content.replace('async <T>(promise: Promise<T>', 'async <T,>(promise: Promise<T>')

with open(file_path, 'w') as f:
    f.write(content)

print('Fixed TimeoutContext.tsx - changed <T> to <T,>')

