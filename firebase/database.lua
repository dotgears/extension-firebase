Database = {}

function Database:new(project_id)
	--
	-- saving info 
	--
	local obj = {}
	local token = nil
	local project_id = project_id
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
			print("database -- token=" .. token)
			callback()
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