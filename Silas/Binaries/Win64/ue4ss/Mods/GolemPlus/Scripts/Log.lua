local Log = {}

local Prefix = "[GolemPlus] "

function Log.Info(text)
    print(Prefix .. text .. "\n")
end

function Log.Error(text)
    print(Prefix .. "ERROR " .. text .. "\n")
end

return Log
