// Firebase Cloud Messaging Service Worker
importScripts('https://www.gstatic.com/firebasejs/9.2.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.2.0/firebase-messaging-compat.js');

// Initialize Firebase
firebase.initializeApp({
  apiKey: 'AIzaSyDdGyJVoNZCso9ZxhdI0W_29i--B2alJnk',
  authDomain: 'panel-monitor-691c6.firebaseapp.com',
  projectId: 'panel-monitor-691c6',
  storageBucket: 'panel-monitor-691c6.firebasestorage.app',
  messagingSenderId: '152632355525',
  appId: '1:152632355525:web:141400ddd77c9507369eac'
});

// Retrieve Firebase Messaging object.
const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage(function(payload) {
  console.log('Received background message ', payload);
  // Customize notification here
  const notificationTitle = payload.notification?.title || 'Background Message Title';
  const notificationOptions = {
    body: payload.notification?.body || 'Background Message body.',
    icon: '/firebase-logo.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
