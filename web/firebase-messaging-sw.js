// Please see this file for the latest firebase-js-sdk version:
// https://github.com/firebase/flutterfire/blob/master/packages/firebase_core/firebase_core_web/lib/src/firebase_sdk_version.dart
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

firebase.initializeApp({
    apiKey: "AIzaSyDB-zHTFy8ZAudG-jIMsqv-DYn_cGGCuPE",
    projectId: "karanda-384102",
    messagingSenderId: "859571346515",
    appId: "1:859571346515:web:54c791ab5688ed4a33baa6",
});

firebase.messaging();
//const messaging = firebase.messaging();

// Optional:
/*messaging.onBackgroundMessage((message) => {
    console.log("onBackgroundMessage", message);

    const notificationTitle = message.notification.title;
    const notificationOptions = {
        body: message.notification.body,
        icon: '/icons/android-chrome-512x512.png',
        badge: '/icons/android-chrome-192x192.png',
        data: message.data,
        click_action: message.notification.click_action,
    };

    self.registration.showNotification(notificationTitle, notificationOptions);
});

self.addEventListener("notificationclick", (event) => {
    clients.openWindow('https://www.karanda.kr');
    event.notification.close();
});*/
