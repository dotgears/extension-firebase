--
-- Test -> PUT
--
local function test_get()
	local url = 'https://bool-8ba6d.firebaseio.com/users/000.json?auth=' .. AUTH_TOKEN
	print(url)
	http.request(url, 'GET', function(self,_, response)
		print(response.response)
	end, 
	nil, nil, nil)
end
--
-- Test -> PUT
--
local function test_put()
	local post_data = '{ "005" : {"session_id": "004", "text":"TEST_POST"}}'
	local url = 'https://bool-8ba6d.firebaseio.com/users/000/sessions.json?auth=' .. AUTH_TOKEN
	http.request(url, 'PUT', function(self,_, response)
		print(response.response)
	end, 
	nil, post_data, nil)
end
--
-- Test -> POST
--
local function test_post()
	local post_data = '{"session_id": "004", "text":"TEST_POST"}'
	local url = 'https://bool-8ba6d.firebaseio.com/users/000/sessions.json?auth=' .. AUTH_TOKEN
	http.request(url, 'POST', function(self,_, response)
		print(response.response)
	end, 
	nil, post_data, nil)
end
--
-- Test -> DELETE
--
local function test_delete()
	local url = 'https://bool-8ba6d.firebaseio.com/users/000/sessions.json'
	http.request(url, 'DELETE', function(self,_, response)
		print(response.response)
	end, 
	nil, nil, nil)
end