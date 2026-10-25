local World = {}

local ReadySeconds = 3.0

local readyPawnName = nil
local readySince = 0

local function Check()
    local pawn = FindFirstOf("BP_PlayerPawn_C")
    if not (pawn and pawn:IsValid()) then
        readyPawnName = nil
        return false
    end
    local name = pawn:GetFullName()
    if name ~= readyPawnName then
        readyPawnName = name
        readySince = os.clock()
    end
    return os.clock() - readySince >= ReadySeconds
end

function World.IsReady()
    local ok, ready = pcall(Check)
    return ok and ready
end

return World
