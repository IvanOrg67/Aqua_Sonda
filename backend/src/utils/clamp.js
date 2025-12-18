'use strict';

function clampInt(value, def, min, max) {
  const n = Number.parseInt(value ?? def, 10);
  if (Number.isNaN(n)) return def;
  return Math.max(min, Math.min(max, n));
}

module.exports = { clampInt };
