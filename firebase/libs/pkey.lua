
local hmac = require "firebase.libs.hmac"
local Stream = require "firebase.util.stream"
local sha2_sha256 = require "firebase.libs.sha2_256"

local M = {}

function M.sign(pkey, string_to_sign)
	return hmac().setDigest(sha2_sha256).setKey(pkey).init().update(Stream.fromString(string_to_sign)).finish().asHex()
end

return M
