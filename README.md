### Firebase Extension
The extension can be used on all platforms because it use only `http.request` function inside Defold.

### Usage
(WIP)
- To test on firebase request :

      curl -X POST -d '{"id": "123", "text":"test"}' 'https://PROJECT_ID.firebaseio.com/users/uid/data.json?auth=AUTH_TOKEN'

### TODO
- Add functions for firestore : All
- Add functions for realtime database : Authenticate by TOKEN
