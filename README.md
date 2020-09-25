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



### TODO
- Add functions for firestore : All
- Add functions for realtime database : Authenticate by TOKEN
