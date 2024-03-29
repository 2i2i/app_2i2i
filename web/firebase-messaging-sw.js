importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

// main
firebase.initializeApp({
  apiKey: "AIzaSyDx8E8sAtlaDZveourRnfJcQkpJCF3pPcc",
  authDomain: "app-2i2i.firebaseapp.com",
  // databaseURL: "",
  projectId: "app-2i2i",
  storageBucket: "app-2i2i.appspot.com",
  messagingSenderId: "347734179578",
  appId: "1:347734179578:web:f9c11616c64e12c643d343",
});

// test
// firebase.initializeApp({
//   apiKey: "AIzaSyDx8E8sAtlaDZveourRnfJcQkpJCF3pPcc",
//   authDomain: "app-2i2i.firebaseapp.com",
//   // databaseURL: "",
//   projectId: "app-2i2i",
//   storageBucket: "app-2i2i.appspot.com",
//   messagingSenderId: "347734179578",
//   appId: "1:347734179578:web:f9c11616c64e12c643d343",
// });

// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((m) => {
  console.log("onBackgroundMessage", m);
});

// messaging.onMessage((m) => {
//   console.log("onMessage", m);
// });