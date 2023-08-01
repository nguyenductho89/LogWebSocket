const socket = new WebSocket('ws://localhost:9999');

function showMessageDetail(message) {
  const messageText = document.getElementById('message-text');
  messageText.textContent = message;
}

socket.onmessage = function (event) {
  const message = event.data;
  const currentDate = new Date();
  const hours = currentDate.getHours().toString().padStart(2, '0');
  const minutes = currentDate.getMinutes().toString().padStart(2, '0');
  const seconds = currentDate.getSeconds().toString().padStart(2, '0');
  const milliseconds = currentDate.getMilliseconds().toString().padStart(3, '0');

  const timestamp = `${hours}:${minutes}:${seconds}.${milliseconds}`;
  // Create message row with timestamp and message type
  const messageRow = document.createElement('div');
  messageRow.className = `message-row`;
  messageRow.innerHTML = `${message}`;

  // Add click event listener to show full message in detail panel
  messageRow.addEventListener('click', function () {
    const messageDetail = document.getElementById('message-detail');
    messageDetail.innerHTML = '';

    // Remove the active class from all rows
    const messageRows = document.getElementsByClassName('message-row');
    for (let i = 0; i < messageRows.length; i++) {
      messageRows[i].classList.remove('active');
    }

    // Toggle the active class on the selected row
    messageRow.classList.toggle('active');

    // Determine the content type and format accordingly
    if (message.startsWith('<') && message.endsWith('>')) {
      // XML content
      messageDetail.textContent = message;
    } else if (message.startsWith('{') && message.endsWith('}')) {
      // JSON content
      const formattedJSON = prettyPrintJson.toHtml(message);
      messageDetail.innerHTML = formattedJSON;
    } else {
      // Plain text content
      messageDetail.innerHTML = message;
    }
  });

  const messageList = document.getElementById('message-list');

  // Insert message row at the beginning of message list container
  messageList.prepend(messageRow);
};

function filterMessages() {
  const searchText = document.getElementById('search-text').value.toLowerCase();
  const messages = document.getElementsByClassName('message-row');

  for (let i = 0; i < messages.length; i++) {
    const message = messages[i];
    const messageText = message.textContent.toLowerCase();

    if (messageText.includes(searchText)) {
      message.style.display = 'block';
    } else {
      message.style.display = 'none';
    }
  }
}
