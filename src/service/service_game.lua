local skynet = require("skynet")
local nodename = skynet.getenv("nodename")

local CMD = {}

skynet.start(function ()
    log.info("===>>> start %s node game service", nodename)

    skynet.dispatch("lua", function(_, source, cmd, ...)
        local func = assert(CMD[cmd], cmd .. " not found")
        if func then
            func(source, ...)
        end
	end)
end)