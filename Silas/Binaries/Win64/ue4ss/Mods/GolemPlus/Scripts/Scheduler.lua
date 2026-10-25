local World = require("World")

local Scheduler = {}

local TickMilliseconds = 200

local tasks = {}
local busy = false
local started = false

local function RunDueTasks()
    if not World.IsReady() then
        return
    end
    local now = os.clock()
    for _, task in ipairs(tasks) do
        if now >= task.nextRun then
            task.nextRun = now + task.interval
            pcall(task.callback)
        end
    end
end

local function Tick()
    pcall(RunDueTasks)
    busy = false
end

local function Start()
    started = true
    LoopAsync(TickMilliseconds, function()
        if not busy then
            busy = true
            ExecuteInGameThread(Tick)
        end
        return false
    end)
end

function Scheduler.EveryInGameThread(milliseconds, callback)
    tasks[#tasks + 1] = { interval = milliseconds / 1000, callback = callback, nextRun = 0 }
    if not started then
        Start()
    end
end

return Scheduler
