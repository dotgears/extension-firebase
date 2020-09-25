Database = {}

function Database:new(project_id)
	--
	-- saving info 
	--
	local obj = {}
	local token = nil 				-- for Anonymous signup
	local access_token = nil		-- for Auth Service Account
	local project_id = project_id
	--
	-- Auth by Service Account of Firebase,
	-- more secured than anonymous signup.
	--
	function obj:auth_service_account(path, exp_time)
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
		local crypto  = require 'crypto.crypto'
		local basexx  = require 'firebase.libs.basexx'
		local pkey    = require 'firebase.libs.pkey'
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
			exp = os.time() + exp_time, -- 5 mins
			iat = os.time(),
		}
		-- ensure { headers . payloads } is base64url :
		--
		header = assert(basexx.to_url64(json.encode(header)))
		payloads = assert(basexx.to_url64(json.encode(payloads)))
		local jwt = header .. '.' .. payloads
		print(jwt)
		--
		-- It's still right until here 
		--
		local jwt = jwt .. '.' .. assert(basexx.to_url64(
		pkey.sign(serv.private_key or session.PRIVATE_KEY, jwt)))
		--
		-- The problem is here : 
		-- As pkey.sign was wrong, so wrong if using hmac/SHA256 !
		local jwt = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzY29wZSI6Imh0dHBzOlwvXC93d3cuZ29vZ2xlYXBpcy5jb21cL2F1dGhcL2ZpcmViYXNlLmRhdGFiYXNlIGh0dHBzOlwvXC93d3cuZ29vZ2xlYXBpcy5jb21cL2F1dGhcL3VzZXJpbmZvLmVtYWlsIiwiZXhwIjoxNjAxMDQ3MjMwLCJpc3MiOiJmaXJlYmFzZS1hZG1pbnNkay15cnFkdUBib29sLThiYTZkLmlhbS5nc2VydmljZWFjY291bnQuY29tIiwiYXVkIjoiaHR0cHM6XC9cL3d3dy5nb29nbGVhcGlzLmNvbVwvb2F1dGgyXC92NFwvdG9rZW4iLCJpYXQiOjE2MDEwNDY5MzB9.EF8XEKEAV8k/zYQhNEuo8rCVD2wtMknBhwEDKD/mvdXnqGXD9uuSKZ8hxanamIwSMv3HjaUYCHjGVKXPk7pfF7Xde1a78B6wXnUTjWndC56e0cwniGS1EiyQWGu2MmnCRb5EReR6yBZq11SlEpX+kYuWFh2YrpaBsZ8hzfFuqbrWL5cMs8fbFoL2eHJ/gIFfXf1hqKmAHoSggaRt8X/hgQdp10p3W7+S307IfeyssRcBnVwJzW/uH6dS1E5ooIsHhl/lbVnhnhD1k/ZIvFbzAJeJosjRljKCSPLliIDu7tnvYoyOqeGTmt4uakzOBBEsM8xXFZsh8UFrUkwH1DXNJQ=="
		
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
				access_token = result.access_token
				print("database -- access_token granted: " .. access_token)
				print("database -- expire in " .. math.floor(result.expires_in/60) .. " minutes")
			else
				print("database -- " .. res.status .. ": " .. cjson.decode(res.response).error_description)
			end
		end,
		nil, cjson.encode(assertions), nil)
	end
	--
	-- Sample curl to test :
	--
	-- curl 'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=API_KEY' \
	-- -H 'Content-Type: application/json' --data-binary '{"returnSecureToken":true}'
	--
	function obj:request_token(api_key, callback)
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
		local token = token and '?auth=' .. token or '?access_token=' .. access_token
		local url = 'https://' .. project_id .. '.firebaseio.com' .. path ..  '.json' .. token
		print(url)
		
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