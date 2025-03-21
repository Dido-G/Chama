function toggleChat() {
    const chatPopup = document.getElementById("chat-popup");
    chatPopup.classList.toggle('show');
}

function sendMessage(event) {
    if (event && event.key !== "Enter") return;
    
    const inputField = document.getElementById("chat-input");
    const message = inputField.value.trim();
    if (!message) return;

    const chatBody = document.getElementById("chat-body");
    chatBody.innerHTML += `<div class="user-message">${message}</div>`;
    inputField.value = "";

    fetch("/chat", {
        method: "POST",
        body: new URLSearchParams({ message }),
        headers: { "Content-Type": "application/x-www-form-urlencoded" }
    })
    .then(response => response.json())
    .then(data => {
        chatBody.innerHTML += `<div class="bot-message">${data.response || "Error: No response"}</div>`;
        chatBody.scrollTop = chatBody.scrollHeight;
    })
    .catch(() => {
        chatBody.innerHTML += `<div class="bot-message">Error contacting AI</div>`;
    });
}

document.addEventListener('DOMContentLoaded', () => {
    document.addEventListener('DOMContentLoaded', () => {
        document.querySelectorAll('.flash-message').forEach(message => {
            setTimeout(() => {
                message.style.transition = "opacity 0.5s ease-out";
                message.style.opacity = 0;
            }, 750);
        });
    });
    

    document.querySelectorAll('.close-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            btn.parentElement.style.transition = "opacity 0.5s ease-out";
            btn.parentElement.style.opacity = "0";
            setTimeout(() => {
                btn.parentElement.style.display = "none";
            }, 500);
        });
    });
});