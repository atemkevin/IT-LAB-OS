#!/usr/bin/env bash
# scripts/regen-types.sh
#
# Regenerate lib/database.types.ts from the linked Supabase project.
#
# The schema portion is generated; the project's enums and Row aliases live in
# scripts/db-type-aliases.txt and are re-appended by scripts/merge-types.js so
# regeneration can never silently drop them.
set -euo pipefail

cd "$(dirname "$0")/.."

npx supabase gen types typescript --linked > lib/database.types.ts.gen
node scripts/merge-types.js
rm -f lib/database.types.ts.gen

echo "Type regeneration complete."
