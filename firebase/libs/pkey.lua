
local hmac = require "firebase.libs.hmac"
local Stream = require "firebase.util.stream"
local sha2_sha256 = require "firebase.libs.sha2_256"

local M = {}

function M.sign(key, msg)
	return hmac().setDigest(sha2_sha256).setKey(key).init().update(Stream.fromString(msg)).finish().asHex()
end

return M
