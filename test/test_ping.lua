local skynet = require("skynet")

local CMD = {}

skynet.start(function ()
    skynet.dispatch("lua", function(_, source, cmd, ...)
        local func = assert(CMD[cmd], cmd .. " not found")
        if func then
            func(source, ...)
        end
	end)
end)