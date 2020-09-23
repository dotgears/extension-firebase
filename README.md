### Firebase Extension
The extension can be used on macOS, iOS, Android, win32 and HTML5 because it use [lua-firebase](https://github.com/mopo3ilo/lua-firebase) instead of native extension like the other defold extension for iOS/Android using native SDK.

### Usage

Add to `game.project`: https://github.com/thetrung/extension-firebase/archive/master.zip

Import firebase 

	firebase = require('extensions.firebase')

Create Firebase instance

	fb = firebase:new('YOUR_PROJECT_ID')

Auth with legacy Firebase database token

	fb.auth:auth_legacy('YOUR_TOKEN')

Read database 

	users = fb.database:read('/users')
  
Write database 

    fb.database:new('your_db_path')
    fb.database:write('your_final_path', data_table)

More details from this [wiki](https://github.com/mopo3ilo/lua-firebase/wiki/Examples)

### Credit
The extension was built as the sum of below extensions : 
- [lua-firebase](https://github.com/mopo3ilo/lua-firebase)
- [defold-cjson](https://github.com/Melsoft-Games/defold-cjson)
- [defold-cryto](https://github.com/sonountaleban/defold-crypto)
- And part of [defold-luasocket](https://github.com/britzl/defold-luasocket)(ltn12, socket, url)
