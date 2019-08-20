local skynet = require("skynet")
local cluster = require("skynet.cluster")
local nodename = skynet.getenv("nodename")
local daemon = skynet.getenv("daemon")


local function start_node_service(node)
end

skynet.start(function ()
    log.info("===>>> launch %s node for version %s", nodename, VERSION)

    -- 集群信息
    cluster.reload(NODE.cluster)
    cluster.open(nodename)

    -- 后台模式
    if not daemon then
		skynet.newservice("console")
    end

    -- 可配置节点的服务
    for i,node in ipairs(NODE.list) do
        if nodename == node.name then
            start_node_service(node)
        end
    end

    skynet.exit()
end)