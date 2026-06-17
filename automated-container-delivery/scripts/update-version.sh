#!/usr/bin/env bash
set -euo pipefail

CURRENT_VERSION="$(node -p "require('./package.json').version")"

IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"
NEW_PATCH=$((PATCH + 1))
NEW_VERSION="$MAJOR.$MINOR.$NEW_PATCH"

node -e "
const fs = require('fs');
const pkg = require('./package.json');
pkg.version = '$NEW_VERSION';
fs.writeFileSync('package.json', JSON.stringify(pkg, null, 2) + '\n');
"

sed -i "s/version: \"[0-9]\+\.[0-9]\+\.[0-9]\+\"/version: \"$NEW_VERSION\"/" app.js

npm install --package-lock-only

echo "Updated version from $CURRENT_VERSION to $NEW_VERSION"
