local skynet = require("skynet")
local cluster = require("skynet.cluster")
local nodename = skynet.getenv("nodename")

local function start_node_service(node)
end

skynet.start(function ()
    skynet.error(string.format("===>>> launch %s node for version %s", node, VERSION))

    -- 集群信息
    local node_cluster = skynet.getenv("node_cluster")
    if node_cluster then
        cluster.reload(cjson.decode(node_cluster))
        cluster.open(nodename)
    end

    -- 后台模式
    local daemon = skynet.getenv("daemon")
    if not daemon then
		skynet.newservice("console")
    end

    -- 调试控制台
    local debug_console = skynet.getenv("debug_console")
    local debug_console_port = skynet.getenv("debug_console_port")
    if debug_console and debug_console_port then
        skynet.uniqueservice("debug_console", debug_console_port)
    end

    skynet.exit()
end)