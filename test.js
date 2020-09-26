const privateKeyFile = require("./KEY.json");
const cryptor = require("crypto");
const request = require("request");

const scopes = ["https://www.googleapis.com/auth/firebase.database", "https://www.googleapis.com/auth/userinfo.email"];
const url = "https://www.googleapis.com/oauth2/v4/token";
const header = {
  alg: "RS256",
  typ: "JWT",
}
const now = Math.floor(Date.now() / 1000);
const claim = {
  iss: privateKeyFile.client_email,
  scope: scopes.join(" "),
  aud: url,
  exp: (now + 3600).toString(),
  iat: now.toString(),
}

const signature = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzY29wZSI6Imh0dHBzOlwvXC93d3cuZ29vZ2xlYXBpcy5jb21cL2F1dGhcL2ZpcmViYXNlLmRhdGFiYXNlIGh0dHBzOlwvXC93d3cuZ29vZ2xlYXBpcy5jb21cL2F1dGhcL3VzZXJpbmZvLmVtYWlsIiwiZXhwIjoxNjAxMDk0NDk3LCJpc3MiOiJmaXJlYmFzZS1hZG1pbnNkay15cnFkdUBib29sLThiYTZkLmlhbS5nc2VydmljZWFjY291bnQuY29tIiwiYXVkIjoiaHR0cHM6XC9cL3d3dy5nb29nbGVhcGlzLmNvbVwvb2F1dGgyXC92NFwvdG9rZW4iLCJpYXQiOjE2MDEwOTQxOTd9"
  // Buffer.from(JSON.stringify(header)).toString("base64") +
  // "." + 
  // Buffer.from(JSON.stringify(claim)).toString("base64")


  var sign = cryptor.createSign("RSA-SHA256")


sign.update(signature)

const jwt = signature + "." + sign.sign(privateKeyFile.private_key, "base64");

console.log(jwt)

request(
  {
    method: "post",
    url: url,
    body: JSON.stringify({
      assertion: jwt,
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
    }),
  },
  (err, res, body) => {
    if (err) {
      console.log(err);
      return;
    }
    console.log(body);
  }
);