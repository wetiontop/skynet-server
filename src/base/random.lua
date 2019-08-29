local skynet = require "skynet"

local random = {}

local random_seed = os.time() + skynet.self()

function random.rand(i, j)
    random_seed = random_seed + 1
    math.randomseed(random_seed)
    return math.random(i, j)
end

function random.one(list)
    return list[random.rand(1, #list)]
end

function random.shuffle(list)
    local len = #list
    for i=1, len do
        local ndx0 = random.rand(1, len)
        list[ndx0], list[i] = list[i], list[ndx0]
    end
    return list
end

return random
