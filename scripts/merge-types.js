const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '..');
const current = fs.readFileSync(path.join(root, 'lib/database.types.ts'), 'utf8');
const generated = fs.readFileSync(path.join(root, 'lib/database.types.ts.gen'), 'utf8');

// Find the "export const Constants" trailing closure `} as const` end
const endMarker = '} as const';
const endIdx = generated.lastIndexOf(endMarker);
if (endIdx === -1) throw new Error('Cannot find end marker in generated types');

const headEnd = endIdx + endMarker.length;
const prefix = generated.slice(0, headEnd);

// Extract alias lines from current file
const aliasStart = current.indexOf('export type Note');
if (aliasStart === -1) throw new Error('Cannot find aliases in current types');
const aliases = current.slice(aliasStart);

const merged = prefix + '\n\n' + aliases + '\n';
fs.writeFileSync(path.join(root, 'lib/database.types.ts'), merged);
console.log('Merged. New size:', merged.length);
console.log('Contains user_activity_logs:', merged.includes('user_activity_logs'));
console.log('Contains current_streak:', merged.includes('current_streak'));
console.log('Contains export type Note:', merged.includes('export type Note'));
