var admin = require("firebase-admin");

var serviceAccount = require("./private_key.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://bool-8ba6d.firebaseio.com"
});

let uid = "something"

admin.auth().createCustomToken(uid)
.then(function(customToken) {
    console.log(customToken)
})
.catch(function(error) {
  console.log('Error creating custom token:', error);
})

