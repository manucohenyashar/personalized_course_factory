#!/usr/bin/env node
/**
 * verify/check-completeness.js
 * Checks that all TODO blocks in the starter file have been replaced.
 *
 * Usage: node verify/check-completeness.js <path-to-starter-file>
 *
 * Exit 0: all TODOs replaced and checkpoint has all 3 required fields.
 * Exit 1: one or more TODOs remain or required fields are missing.
 *
 * Environment: node 22.12.x
 */

'use strict';

const fs = require('fs');
const path = require('path');

const filePath = process.argv[2];

if (!filePath) {
  console.error('Usage: node check-completeness.js <path-to-starter-file>');
  process.exit(1);
}

const absolutePath = path.resolve(filePath);

if (!fs.existsSync(absolutePath)) {
  console.error(`File not found: ${absolutePath}`);
  process.exit(1);
}

const content = fs.readFileSync(absolutePath, 'utf8');
const lines = content.split('\n');

// Check 1: No remaining TODO tokens
const todoLines = lines
  .map((line, i) => ({ line: line.trim(), num: i + 1 }))
  .filter(({ line }) => /\bTODO\b/.test(line));

if (todoLines.length > 0) {
  console.error('FAIL: The following lines still contain TODO markers:');
  todoLines.forEach(({ line, num }) => console.error(`  Line ${num}: ${line}`));
  process.exit(1);
}

// Check 2: Checkpoint specification has all 3 fields
const requiredFields = ['**Trigger:**', '**Review format:**', '**Approval action:**'];
const missingFields = requiredFields.filter(field => !content.includes(field));

if (missingFields.length > 0) {
  console.error('FAIL: Checkpoint specification is missing required fields:');
  missingFields.forEach(f => console.error(`  Missing: ${f}`));
  console.error('  Each checkpoint must specify: Trigger, Review format, and Approval action.');
  process.exit(1);
}

// Check 3: RSTRM verdict is present
if (!content.includes('RSTRM Verdict')) {
  console.error('FAIL: Overall RSTRM Verdict section not found.');
  process.exit(1);
}

console.log('PASS: All TODO blocks filled. Checkpoint specification complete. RSTRM verdict present.');
console.log('Note: This script checks completeness only. Quality of reasoning is assessed by rubric.');
process.exit(0);
