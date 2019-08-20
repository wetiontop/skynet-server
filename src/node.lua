-- 通用服务配置
local dbproxy_common = {
    {db_name = "account", db_type = "mongodb", host = "127.0.0.1"}, -- host,port,username,password,authmod
    {db_name = "game", db_type = "mongodb", host = "127.0.0.1"},
    {db_name = "global", db_type = "mongodb", host = "127.0.0.1"},
    {db_name = "log", db_type = "mongodb", host = "127.0.0.1"}
}
local agentpool_common = {maxnum = 10, recyremove = 1, brokecachelen = 1}

NODE = {
    -- 通信协议
    prototype = "tcp",  -- tcp/ws
    protopack = "spb",   -- pb/spb/xpb/

    -- 集群地址配置
    cluster = {
        admin = "127.0.0.1:2527", -- 后台交互节点
        node1 = "127.0.0.1:2528",
        node2 = "127.0.0.1:2529",
    },

    -- 各个节点服务配置
    list = {
        {
            name = "admin",
            debug_console = {port = 8000}
        },
        {
            name = "node1",
            debug_console = {port = 8001},
            dbproxy = dbproxy_common,
            agentpool = agentpool_common,
            gateway = {port = 8888, maxclient = 1024, nodelay = true},
            login = {},
            game = {},
            global = {},
            center = {}
        },
        {
            name = "node2",
            debug_console = {port = 8002},
            dbproxy = dbproxy_common,
            agentpool = agentpool_common,
            gateway = {port = 8889, maxclient = 1024, nodelay = true},
            login = {},
            game = {},
            global = {},
            center = {}
        }
    }
}