### Firebase Extension
The extension can be used on all platforms because it use only `http.request` function inside Defold.

### Usage
(WIP)
- To test on firebase request :

      curl -X POST -d '{"id": "123", "text":"test"}' 'https://PROJECT_ID.firebaseio.com/users/uid/data.json?auth=AUTH_TOKEN'


- Note from Google OAuth :

      Once you have a service account key file, you can use one of the Google API client libraries to generate a Google OAuth2 access token with the following required scopes:

          https://www.googleapis.com/auth/userinfo.email
          https://www.googleapis.com/auth/firebase.database


- Actual step of what this extension doing : 

      :: Process of Firebase Secured Access with Google OAuth v2: 

      1 - Generate Private Key from Firebase Realtime Database 
      + JSON

      2 - Create JWT ( json web tokens ) from Private Key information : 
      + Headers 
      + Payloads

      3 - Sign Headers+Payloads with RSA-SHA256 of private-key

      4 - Construct request Body information with :
      + grant_type 
      + assertion ( signed data above )

      5 - Send POST request with Body  >> google oauth to retrieve ACCESS_TOKEN
      6 - Send RESTful request again with access_token to access database API


### TODO
- Find library or add function to Defold Engine to have RSA signing key ability.
