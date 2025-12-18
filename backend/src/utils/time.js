'use strict';

// Convierte Date -> { fecha: 'YYYY-MM-DD', hora: 'HH:MM:SS' } en UTC
function toDatePartsUTC(date) {
  const iso = date.toISOString(); // YYYY-MM-DDTHH:MM:SS.sssZ
  const [ymd, rest] = iso.split('T');
  const hms = rest.split('.')[0];
  return { fecha: ymd, hora: hms };
}

module.exports = { toDatePartsUTC };
