import consumer from "channels/consumer"

consumer.subscriptions.create("VideoNotificationsChannel", {
  connected() {
    console.log("Connected to video notifications");
  },

  disconnected() {
    console.log("Disconnected from video notifications");
  },

  received(data) {
    console.log("Received data:", data);
    const currentUserMetaTag = document.querySelector('meta[name="current-user-id"]');
    const currentUserId = currentUserMetaTag ? currentUserMetaTag.getAttribute('content') : null;

    console.log("Current user:", currentUserId, "Creator:", data.current_user_id);

    if (data.type === 'new_video') {
      if (!currentUserId || currentUserId !== data.current_user_id.toString()) {
        this.appendNotification(data.html);
      }
      this.appendCardToContainer(data.card);
    }
    else if (data.type === 'error') {
      if (data.client_type === 'rails') {
        this.appendNotification(data.html);
      }
    }
  },

  appendCardToContainer(card) {
    const videoContainer = document.getElementById('video-container');
    if (videoContainer) {
      videoContainer.insertAdjacentHTML('afterbegin', card);
    }
  },

  appendNotification(html) {
    console.log("Appending notification");
    const tempDiv = document.createElement('div');
    tempDiv.innerHTML = html;
    document.body.appendChild(tempDiv);

    setTimeout(() => {
      tempDiv.remove();
    }, 5000);
  }
});
