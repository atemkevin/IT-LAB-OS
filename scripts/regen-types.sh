#!/usr/bin/env bash
# scripts/regen-types.sh
#
# Regenerate lib/database.types.ts from the linked Supabase project and
# merge in the project's hand-maintained type aliases.
set -euo pipefail

cd "$(dirname "$0")/.."

# 1. Dump the live schema to a temp file
npx supabase gen types typescript --linked > lib/database.types.ts.gen

# 2. Merge aliases using scripts/merge-types.js
node scripts/merge-types.js

# 3. Clean up
rm lib/database.types.ts.gen

echo "Type regeneration complete."
