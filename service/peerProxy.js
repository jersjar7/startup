const { WebSocketServer } = require('ws');

function peerProxy(httpServer) {
  const wss = new WebSocketServer({ noServer: true });

  // Handle upgrade from HTTP to WebSocket
  httpServer.on('upgrade', (request, socket, head) => {
    wss.handleUpgrade(request, socket, head, function done(ws) {
      wss.emit('connection', ws, request);
    });
  });

  // Keep track of all connections
  let connections = [];
  let id = 0;

  wss.on('connection', (ws) => {
    const connection = { id: id++, alive: true, ws: ws };
    connections.push(connection);

    // Forward messages to all other clients
    ws.on('message', function message(data) {
      connections.forEach((c) => {
        if (c.id !== connection.id && c.ws.readyState === 1) {
          c.ws.send(data);
        }
      });
    });

    // Remove closed connections
    ws.on('close', () => {
      connections = connections.filter((c) => c.id !== connection.id);
    });

    // Respond to pong messages
    ws.on('pong', () => {
      connection.alive = true;
    });
  });

  // Ping every 10 seconds to keep connections alive
  setInterval(() => {
    connections.forEach((c) => {
      if (!c.alive) {
        c.ws.terminate();
      } else {
        c.alive = false;
        c.ws.ping();
      }
    });
  }, 10000);
}

module.exports = { peerProxy };
