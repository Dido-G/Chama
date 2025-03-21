document.addEventListener('DOMContentLoaded', function() {
    // Show chatbox when clicking on the open chat button
    document.getElementById('open-chat').addEventListener('click', function() {
        document.getElementById('chatbox').style.display = 'block';
    });

    // Close chatbox when clicking on the close button
    document.getElementById('close-chat').addEventListener('click', function() {
        document.getElementById('chatbox').style.display = 'none';
    });

    // Send user message to the backend
    document.getElementById('send-message').addEventListener('click', function() {
        const userMessage = document.getElementById('user-message').value;
        if (userMessage.trim()) {
            // Add user message to chat
            const chatContent = document.getElementById('chat-content');
            const userMessageDiv = document.createElement('div');
            userMessageDiv.classList.add('chat-message', 'user-message');
            userMessageDiv.textContent = userMessage;
            chatContent.appendChild(userMessageDiv);

            // Clear the input field
            document.getElementById('user-message').value = '';

            // Send user message to the backend
            fetch('/chat', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ 'message': userMessage })
            })
            .then(response => response.json())
            .then(data => {
                if (data.response) {
                    // Add AI response to chat
                    const aiMessageDiv = document.createElement('div');
                    aiMessageDiv.classList.add('chat-message', 'ai-message');
                    aiMessageDiv.textContent = data.response;
                    chatContent.appendChild(aiMessageDiv);

                    // Scroll to the bottom of the chat
                    chatContent.scrollTop = chatContent.scrollHeight;
                } else {
                    console.error('AI response not received');
                }
            })
            .catch(error => console.error('Error:', error));
        }
    });

    // Popup message disappear after 1 second
    const flashMessages = document.querySelectorAll('.flash-message');
    flashMessages.forEach(function(message) {
        setTimeout(function() {
            message.style.display = 'none'; // Hide message after 1 second
        }, 1000);
    });
});
