#!/usr/bin/env bash
# Run Zalo-TG bridge with Homebrew/system Node.js.
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
cd "$(dirname "$0")"
exec node node_modules/.bin/tsx watch src/index.ts
