const express = require('express');
const http = require('http');
const fs = require('fs');
const WebSocket = require('ws');
const colors = require('colors');

const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

app.use(express.static(__dirname));

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

server.listen(9999, () => {
  console.log('Server listening on port 9999'.cyan);
});
