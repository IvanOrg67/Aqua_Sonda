'use strict';

const clients = new Set();

function registerClient(socket, filter) {
  const entry = { socket, filter };
  clients.add(entry);
  socket.on('close', () => clients.delete(entry));
  return entry;
}

function broadcastLectura(payload) {
  for (const c of clients) {
    if (c.socket.readyState !== 1) continue;

    const { sensorInstaladoId, instalacionId } = c.filter;

    const matchSensor = sensorInstaladoId && payload.sensor_instalado_id === sensorInstaladoId;
    const matchInst = instalacionId && payload.instalacion_id === instalacionId;

    if (matchSensor || matchInst) {
      c.socket.send(JSON.stringify({
        type: 'lectura.created',
        data: payload,
      }));
    }
  }
}

module.exports = { registerClient, broadcastLectura };
