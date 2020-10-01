### Firebase Extension
The extension can be used on all platforms because it use only `http.request` function inside Defold.

### Notes

- To test on firebase request :

      curl 'https://PROJECT_ID.firebaseio.com/users/uid/data.json?auth=AUTH_TOKEN'


- Note from Google OAuth :

      Once you have a service account key file, 
      you can use one of the Google API client libraries 
      to generate a Google OAuth2 access token with the following required scopes:

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


### Usage 

1. Create Auth :

       local firebase_auth = require('firebase.auth')
	 local auth = firebase_auth:new('PROJECT_ID')
      
2. Create database :

       local firebase_database = require('firebase.database')
      
3. Authenticate with firebase Service Account Private Key & send request :

       auth:auth_service_account('/KEY.json', 60 * 60, function(session)
            --
            -- What happen when we authenticated successfully ?
            -- Save 'session' object to reuse later, before it expire.
            --
            
            database:get('/users/000', function(res)
			print('test_get: ' .. res.status)
		end)
            
            database:put('/users/000', function(res)
			print('test_put: ' .. res.status)
		end, { ['test_put'] = true })

		database:post('/users/000', function(res)
			print('test_post: ' .. res.status)
		end, { ['test_post'] = true })

		database:delete('/users/000/test_put', function(res)
			print('test_delete: ' .. res.status)
		end)
            
       end)
      
