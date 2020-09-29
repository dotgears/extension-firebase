
Messaging = {}

function Messaging:new(session)
	local obj = {}
	local session = session

	function obj:request(method, path, data, callback)

		local headers = {}
		if session.ID_TOKEN then
			headers.authorization = string.format('Firebase %s', session.ID_TOKEN)
		end
		if session.ACCESS_TOKEN then
			headers.authorization = string.format('Bearer %s', session.ACCESS_TOKEN)
		end

		if method == 'POST' then
			if not type(data) == 'table' then
				print('data -- Incorrect data argument' .. type(data))
			end

			local src = cjson.encode(data)

			headers['content-type']    = 'application/json'
			headers['content-length']  = src:len()
		end

		local url = string.format('https://fcm.googleapis.com/v1/projects/%s/messages%s', session.PROJECT_ID, path)
		print(url)
		print(headers.authorization)
		local callback = function(self,_, res)
			local c = res.status
			if c == 200 or c == 204 then
				callback(res.response)
				print(res.response) -- Logging
			end
			if c == 401 or c == 403 or c == 400 then
				print("messaging -- can't send message: " .. res.response)
			end
		end
		
		http.request(url, method, callback, headers, source, option)
	end

	function obj:send(message)
		return obj:request('POST', ':send', message)
	end

	function obj:take(message_id)
		return obj:request('GET', '/' .. tostring(message_id))
	end

	setmetatable(obj, self)
	self.__index = self
	return obj
end

return Messaging
