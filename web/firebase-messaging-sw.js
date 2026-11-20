
importScripts('https://www.gstatic.com/firebasejs/13.3.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/13.3.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyBDu6WbiCa-E2rSrBug7gdVRzXchV-q02Q',
  appId: '1:889337249212:web:dc0daf5aeec8b9efc13fb9',
  messagingSenderId: '889337249212',
  projectId: 'flutter-ui-fundamentals-pert9',
  authDomain: 'flutter-ui-fundamentals-pert9.firebaseapp.com',
  storageBucket: 'flutter-ui-fundamentals-pert9.firebasestorage.app'
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Background message received:', payload);

  const notificationTitle =
    payload.notification?.title || 'KosFinder';

  const notificationOptions = {
    body:
      payload.notification?.body ||
      'Ada notifikasi baru untuk pengujian Praktik 10',
  };

  return self.registration.showNotification(
    notificationTitle,
    notificationOptions,
  );
});
