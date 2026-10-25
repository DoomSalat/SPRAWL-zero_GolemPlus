local StimAim = {}

local StimClassName = "BP_HealthPickup_C"
local MinimumDot = 0.95
local MaximumDistance = 2500

function StimAim.FindAimedStim(pawn)
    local camera = pawn.Camera
    local origin = camera:K2_GetComponentLocation()
    local forward = camera:GetForwardVector()
    local bestStim = nil
    local bestDot = MinimumDot
    for _, stim in ipairs(FindAllOf(StimClassName) or {}) do
        if stim:IsValid() then
            local location = stim:K2_GetActorLocation()
            local dx, dy, dz = location.X - origin.X, location.Y - origin.Y, location.Z - origin.Z
            local squaredDistance = dx * dx + dy * dy + dz * dz
            if squaredDistance < MaximumDistance * MaximumDistance then
                local dot = (dx * forward.X + dy * forward.Y + dz * forward.Z) / math.sqrt(squaredDistance)
                if dot > bestDot then
                    bestDot = dot
                    bestStim = stim
                end
            end
        end
    end
    return bestStim
end

return StimAim
