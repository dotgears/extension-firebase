Database = {}

function Database:new(project_id)
	--
	-- saving info 
	--
	local obj = {}
	obj.token = nil 				-- for Anonymous signup
	obj.access_token = nil		-- for Auth Service Account
	local project_id = project_id
	--
	-- Auth by Service Account of Firebase,
	-- more secured than anonymous signup.
	--
	function obj:auth_service_account(path, exp_time, callback)
		token = nil
		local serv = {}
		if path and type(path) == 'string' then
			local private_key = sys.load_resource(path)
			if not private_key then error(string.format('Can\'t open file %s', path)) end 
			serv = cjson.decode(private_key) -- saving private_key data to this table
		else
			error('Empty or wrong path format.')
		end
		-- LIBRARY: 
		local json    = cjson
		-- local crypto  = require 'crypto.crypto'
		local base64  = require 'firebase.libs.base64'
		--
		-- URL for Google OAuth v2
		--
		local url = 'https://www.googleapis.com/oauth2/v4/token'
		--
		-- Really important:
		-- https://firebase.google.com/docs/database/rest/auth#generate_an_access_token
		--
		local scopes = {
			"https://www.googleapis.com/auth/firebase.database", 
			"https://www.googleapis.com/auth/userinfo.email"
		}
		local header = {
			alg = 'RS256',
			typ = 'JWT'
		}
		local payloads = {
			iss = serv.client_email or session.CLIENT_EMAIL,
			scope = table.concat(scopes, ' '),
			aud = url,
			exp = os.time() + exp_time,
			iat = os.time(),
		}
		local signature = nil
		local key = serv.private_key or session.PRIVATE_KEY
		--
		-- ensure { headers . payloads } is base64url :
		--
		header = assert(base64.encode(json.encode(header)))
		payloads = assert(base64.encode(json.encode(payloads)))
		signature = assert(rsa.sign_pkey(header .. '.' .. payloads, key))
		local jwt = header .. '.' .. payloads .. '.' .. signature
		--
		-- into assertions:
		--
		local assertions = {
			assertion   = jwt,
			grant_type  = 'urn:ietf:params:oauth:grant-type:jwt-bearer'
		}
		--
		-- Take this simple and easy, inspired from clean node.js implementation:
		-- https://www.mmbyte.com/article/62717.html
		--
		http.request(url, 'POST', function(self,_,res)
			if res.status == 200 then
				local result = cjson.decode(res.response)
				obj.access_token = result.access_token
				print("database -- Granted Access. Expire in " .. math.floor(result.expires_in/60) .. " minutes")
			else
				print("database -- " .. res.status .. ": " .. cjson.decode(res.response).error_description)
			end
			callback(res)
		end,
		nil, cjson.encode(assertions), nil)
	end
	--
	-- Sample curl to test :
	--
	-- curl 'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=API_KEY' \
	-- -H 'Content-Type: application/json' --data-binary '{"returnSecureToken":true}'
	--
	function obj:auth_by_apikey(api_key, callback)
		access_token = nil -- clean up to avoid mistaken between 2 type of auth.
		local token_url = 'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=' .. api_key
		local headers = {
			['Content-Type'] = 'application/json'
		}
		local post_data = { ["returnSecureToken"] = true }
		
		local req_token = http.request(token_url, 'POST', function(self,_,res)
			print("database -- got res: " .. res.response)
			token = cjson.decode(res.response)["idToken"]
			if token then 
				print("database -- token=" .. token)
				callback()
			else
				print("database -- token: nil")
			end
		end,
	    headers, cjson.encode(post_data), nil)
	end
	
	local function base_request(project_id, path, callback, data, method)
		local headers = nil 
		if not (obj.token or obj.access_token) then 
			print("database -- nil token")
			return 
		end
		local token = obj.token and '?auth=' .. obj.token or '?access_token=' .. obj.access_token
		local url = 'https://' .. project_id .. '.firebaseio.com' .. path ..  '.json' .. token
		-- print(url)
		
		http.request(url, method, function(self,_, response)
			-- print(response.response)
			callback(response)
		end, 
		headers, cjson.encode(data), option)
		-- http.request(url, method, callback, headers, post_data, option)
	end
	--
	-- OBJ -> GET
	--
	function obj:get(path, callback)
		base_request(project_id, path, callback, nil, 'GET')
	end
	--
	-- OBJ -> PUT
	--
	function obj:put(path, callback, data)
		base_request(project_id, path, callback, data, 'PUT')
	end
	--
	-- OBJ -> POST
	--
	function obj:post(path, callback, post_data)
		base_request(project_id, path, callback, post_data, 'POST')
	end
	--
	-- OBJ -> PATCH
	--
	function obj:patch(path, callback, post_data)
		base_request(project_id, path, callback, post_data, 'PATCH')
	end
	--
	-- OBJ -> DELETE
	--
	function obj:delete(path, callback)
		base_request(project_id, path, callback, nil, 'DELETE')
	end
	-- 
	-- assign obj -> Database
	--
	setmetatable(obj, self)
	self.__index = self
	return obj
end

return Database