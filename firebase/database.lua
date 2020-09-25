Database = {}

function Database:new(project_id)
	--
	-- saving info 
	--
	local obj = {}
	local token = nil
	local project_id = project_id
	--
	-- 
	--
	function obj:auth_service_account(path)
		local tools = require 'firebase.tools'
		local serv = {}
		if path then
			if not type(path) == 'string' then
				error('Empty path argument')
			end
			local private_key = sys.load_resource('/private_key.json')
			-- print(private_key)
			if not private_key then
				error(string.format('Can\'t open file %s', path))
			end
			serv = cjson.decode(private_key)
		elseif tools.is_string(session.CLIENT_EMAIL) and tools.is_string(session.PRIVATE_KEY) then
			serv.client_email = session.CLIENT_EMAIL
			serv.private_key = session.PRIVATE_KEY
		else
			error('Empty path argument')
		end
		-- for k,v in pairs(serv) do print(k .. " -- " .. v) end 

		local json    = cjson
		local crypto  = require 'crypto.crypto'
		-- local ltn12   = require 'firebase.libs.ltn12'
		local basexx  = require 'firebase.libs.basexx'
		local pkey    = require 'firebase.libs.pkey'

		local scopes = {
			'https://www.googleapis.com/auth/firebase'
			-- ,'https://www.googleapis.com/auth/userinfo.email'
			-- ,'https://www.googleapis.com/auth/cloud-platform'
			-- ,'https://www.googleapis.com/auth/devstorage.full_control'
		}

		local header = {
			alg = 'RS256',
			typ = 'JWT'
		}
		header = assert(basexx.to_url64(json.encode(header)))

		local payloads = {
			iss = serv.client_email or session.CLIENT_EMAIL,
			-- sub = serv.client_email or session.CLIENT_EMAIL,
			-- aud = "https://identitytoolkit.googleapis.com/google.identity.identitytoolkit.v1.IdentityToolkit",
			scope = table.concat(scopes, ' '),
			-- scope = "https://www.googleapis.com/auth/firebase.database",
			aud = 'https://www.googleapis.com/oauth2/v4/token',
			iat = os.time(),
			exp = os.time() + 60
			-- ,uid = "something"
		}
		payloads = assert(basexx.to_url64(json.encode(payloads)))

		local jwt = header .. '.' .. payloads
		-- print(jwt)
		-- local dig = crypto.digest(crypto.sha256, jwt, 'SHA256')
		local signature = basexx.to_url64(pkey.sign(serv.private_key or session.PRIVATE_KEY, jwt))
		local jwt = jwt .. '.' .. signature

		local test = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzY29wZSI6Imh0dHBzOlwvXC93d3cuZ29vZ2xlYXBpcy5jb21cL2F1dGhcL2ZpcmViYXNlIiwiaWF0IjoxNjAxMDMyOTE5LCJpc3MiOiJmaXJlYmFzZS1hZG1pbnNkay15cnFkdUBib29sLThiYTZkLmlhbS5nc2VydmljZWFjY291bnQuY29tIiwiYXVkIjoiaHR0cHM6XC9cL3d3dy5nb29nbGVhcGlzLmNvbVwvb2F1dGgyXC92NFwvdG9rZW4iLCJleHAiOjE2MDEwMzI5Nzl9.DEjpuJAmYzq2ngdj56CR21deYx_Nyp3sAK7CFmAZEBHnxzvKcJTbtEvIZVjfManI6D9X0P1uO5CQYE2JDjogFHrwaizSDHRYFLUX22CtZJS5VYoo42smVgZI1CmCSqfaMsmaJn2-ZfdBr4a7AQGlQQXfWdQ2Lqdw60PrH8O3H-J3DbhzBwf86ULulSrFGAGGMhUzn9bF3n5-o6yvikcPAlLCGdBQ7xIgR6lVVur1861zvK-8zEaDAD6-pIIr9_dWSwmAKnMyz3bzUDLqUkz8MGclI6s4-3opVfM2j0PGlhOP4dRV8tjfLcdezmiZCnNiXiySaTMgud-lymyMGK3CuQ"
		
		jwt = test
		
		print(jwt)
		
		local assertions = tools.build_query({
			grant_type  = 'urn:ietf:params:oauth:grant-type:jwt-bearer',
			assertion   = jwt
		})
		-- print(assertions)
		
		local headers = {
			['content-type']    = 'application/x-www-form-urlencoded'
			-- ,['content-length']  = tostring(assertions:len())
		}

		local url = 'https://www.googleapis.com/oauth2/v4/token'
		
		http.request(url, 'POST', function(self,_,res)
			print(res.response)
			print(res.status)
			-- if res.status == 200 then
			-- 	local body = {}
			-- 	local t = tools.json2table(table.concat(body))
			-- 	t.type = 'service_account'
			-- 	t.client_email = serv.client_email
			-- 	t.private_key = serv.private_key
			-- 	tools.write_in_session(t, session)
			-- 	if session.PROJECT_FN then
			-- 		return tools.save_json(session.PROJECT_FN, t)
			-- 	end
			-- 	return t
			-- else
			-- 	print("database -- ERROR")
			-- end
		end,
		headers, assertions, nil)

	end
	--
	-- Sample curl:
	--
	-- curl 'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=API_KEY' \
	-- -H 'Content-Type: application/json' --data-binary '{"returnSecureToken":true}'
	function obj:request_token(api_key, callback)
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
		local url = 'https://' .. project_id .. '.firebaseio.com' .. path ..  '.json' .. '?auth=' .. token
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