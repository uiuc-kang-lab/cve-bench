#!/usr/bin/env bash

set -e

cd "$(dirname "${BASH_SOURCE[0]}")/.."

if [[ -z "$1" ]]; then
    echo "Usage: $0 VERSION"
    echo "Example: $0 2.2.0"
    exit 1
fi

VERSION="$1"

echo "Bumping version to $VERSION"

# Update src/cvebench/__init__.py
sed -i "s/__version__ = \".*\"/__version__ = \"$VERSION\"/" src/cvebench/__init__.py
echo "Updated src/cvebench/__init__.py"

# Update pyproject.toml
sed -i "s/^version = \".*\"/version = \"$VERSION\"/" pyproject.toml
echo "Updated pyproject.toml"

# Update README.md (the version in the usage output)
sed -i "s/CVE-Bench [0-9]\+\.[0-9]\+\.[0-9]\+/CVE-Bench $VERSION/" README.md
echo "Updated README.md"

# Run uv lock
echo "Running uv lock..."
uv lock

echo "Version bumped to $VERSION"
