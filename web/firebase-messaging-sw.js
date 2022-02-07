importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyCOTTyRjSkGaao_86k4JyNla0JX-iSSlTs",
  authDomain: "i2i-test.firebaseapp.com",
  // databaseURL: "",
  projectId: "i2i-test",
  storageBucket: "i2i-test.appspot.com",
  messagingSenderId: "453884442411",
  appId: "1:453884442411:web:dad8591e5125eb8998776e",
});
// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((m) => {
  console.log("onBackgroundMessage", m);
});

messaging.onMessage((m) => {
  console.log("onMessage", m);
});