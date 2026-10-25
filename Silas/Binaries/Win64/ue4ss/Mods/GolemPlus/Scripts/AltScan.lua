local Log = require("Log")
local Scheduler = require("Scheduler")
local Settings = require("Settings")

local HighlightClassPath = "/Game/AI/Components/HighlightComponent.HighlightComponent_C"
local HighlightMaterialPath = "/Game/Materials/M_EnemyHighlight.M_EnemyHighlight"
local MaterialLibraryPath = "/Script/Engine.Default__KismetMaterialLibrary"
local TeamLibraryPath = "/Script/Sigil.Default__SigilFunctionLibrary"
local MeshClassPath = "/Script/Engine.MeshComponent"
local EnemyClassName = "SilasAICharacterBase"
local CollectibleClassNames = { "BP_RelicFragment_C", "BP_CodexEntry_C" }
local ScanRadius = 2500
local HighlightSeconds = 10.0
local CollectibleOverlayMilliseconds = 5000
local DisplayStartToleranceSeconds = 0.5
local PollMilliseconds = 200
local ScanThrottleSeconds = 1.0

local overlayToken = 0
local lastScanTime = -ScanThrottleSeconds
local wasDisplayStarting = false

local function SquaredDistance(a, b)
    local dx, dy, dz = a.X - b.X, a.Y - b.Y, a.Z - b.Z
    return dx * dx + dy * dy + dz * dz
end

local function IsInRange(actor, origin)
    return SquaredDistance(actor:K2_GetActorLocation(), origin) <= ScanRadius * ScanRadius
end

local function IsAlly(pawn, enemy)
    local ok, sameTeam = pcall(function()
        return StaticFindObject(TeamLibraryPath):IsSameTeam(pawn, enemy)
    end)
    return ok and sameTeam
end

local function HighlightEnemy(enemy)
    local highlightClass = StaticFindObject(HighlightClassPath)
    local component = enemy:GetComponentByClass(highlightClass)
    if not (component and component:IsValid()) then
        local transform = {
            Rotation = { X = 0, Y = 0, Z = 0, W = 1 },
            Translation = { X = 0, Y = 0, Z = 0 },
            Scale3D = { X = 1, Y = 1, Z = 1 },
        }
        component = enemy:AddComponentByClass(highlightClass, false, transform, false)
    end
    local hasMeshes, meshCount = pcall(function() return #component.Meshes end)
    if not hasMeshes or meshCount == 0 then
        pcall(function() component:Initialize() end)
    end
    component:HighlightForDuration(HighlightSeconds)
end

local function HighlightEnemies(origin, pawn)
    for _, enemy in ipairs(FindAllOf(EnemyClassName) or {}) do
        if enemy:IsValid() and not enemy.bIsDead and not IsAlly(pawn, enemy) and IsInRange(enemy, origin) then
            local ok, errorMessage = pcall(HighlightEnemy, enemy)
            if not ok then
                Log.Error("AltScan enemy " .. tostring(errorMessage))
            end
        end
    end
end

local function CreateHighlightMaterial(worldContext)
    local parent = StaticFindObject(HighlightMaterialPath)
    local library = StaticFindObject(MaterialLibraryPath)
    local ok, instance = pcall(function()
        return library:CreateDynamicMaterialInstance(worldContext, parent, FName("None"), 0)
    end)
    if ok and instance and instance:IsValid() then
        instance:SetScalarParameterValue(FName("Alpha"), 1.0)
        return instance
    end
    return parent
end

local function SetCollectibleOverlay(collectible, material)
    local meshes = collectible:K2_GetComponentsByClass(StaticFindObject(MeshClassPath))
    for _, entry in ipairs(meshes) do
        pcall(function() entry:get():SetOverlayMaterial(material) end)
    end
end

local function OutlineCollectibles(origin, worldContext)
    local material = CreateHighlightMaterial(worldContext)
    local outlined = {}
    for _, className in ipairs(CollectibleClassNames) do
        for _, collectible in ipairs(FindAllOf(className) or {}) do
            if collectible:IsValid() and not collectible.bHidden and IsInRange(collectible, origin) then
                local ok, errorMessage = pcall(SetCollectibleOverlay, collectible, material)
                if ok then
                    outlined[#outlined + 1] = collectible
                else
                    Log.Error("AltScan collectible " .. tostring(errorMessage))
                end
            end
        end
    end
    overlayToken = overlayToken + 1
    local token = overlayToken
    ExecuteWithDelay(CollectibleOverlayMilliseconds, function()
        ExecuteInGameThread(function()
            if token ~= overlayToken then
                return
            end
            for _, collectible in ipairs(outlined) do
                if collectible:IsValid() then
                    pcall(SetCollectibleOverlay, collectible, nil)
                end
            end
        end)
    end)
end

local function IsDisplayStarting()
    local controller = FindFirstOf("BP_PlayerController_C")
    local tracker = controller and controller.QuestTracker
    if not (tracker and tracker:IsValid()) then
        return false
    end
    return tracker.CurrentDisplayTimeRemaining >= tracker.DisplayDuration - DisplayStartToleranceSeconds
end

local function Scan()
    local pawn = FindFirstOf("BP_PlayerPawn_C")
    if not (pawn and pawn:IsValid()) then
        return
    end
    local origin = pawn:K2_GetActorLocation()
    HighlightEnemies(origin, pawn)
    OutlineCollectibles(origin, pawn)
end

local function PollScan()
    local ok, starting = pcall(IsDisplayStarting)
    starting = ok and starting
    local started = starting and not wasDisplayStarting
    wasDisplayStarting = starting
    if not (started and Settings.IsEnabled("AltScan")) then
        return
    end
    local now = os.clock()
    if now - lastScanTime < ScanThrottleSeconds then
        return
    end
    lastScanTime = now
    Scan()
end

Scheduler.EveryInGameThread(PollMilliseconds, PollScan)
