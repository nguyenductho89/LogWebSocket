const http = require('http');
const fs = require('fs');
const WebSocket = require('ws');
const colors = require('colors');

const server = http.createServer((req, res) => {
  if (req.url === '/') {
    req.url = '/index.html'; // Set default route to index.html
  }

  fs.readFile(`.${req.url}`, (err, data) => {
    if (err) {
      res.writeHead(404);
      res.end('File not found');
    } else {
      res.writeHead(200, { 'Content-Type': 'text/html' });
      res.end(data);
    }
  });
});

const wss = new WebSocket.Server({ noServer: true });

wss.on('connection', (ws) => {
  ws.on('message', (message) => {
    console.log('Received message:', message.toString());
    
    // Save the message to a file
    fs.appendFile('messages.txt', message.toString() + '\n', (err) => {
      if (err) {
        console.error('Error saving message:'.red, err);
      } else {
        console.log('Message saved to disk successfully.'.green);
      }
    });
    
    // Broadcast the message to all connected clients
    wss.clients.forEach((client) => {
      if (client !== ws && client.readyState === WebSocket.OPEN) {
        client.send(message.toString());
      }
    });
  });
});

server.on('upgrade', (request, socket, head) => {
  wss.handleUpgrade(request, socket, head, (ws) => {
    wss.emit('connection', ws, request);
  });
});

server.listen(9999, () => {
  console.log('Server listening on port 9999'.cyan);
});
