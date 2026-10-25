local Log = require("Log")
local Scheduler = require("Scheduler")
local Settings = require("Settings")
local StimAim = require("StimAim")

local SprintDefaultPath = "/Game/Player/Actions/Action_PlayerSprint.Default__Action_PlayerSprint_C"
local SprintClassName = "Action_PlayerSprint_C"
local StimClassName = "BP_HealthPickup_C"
local GloveTargetClassPath = "/Script/Silas.GravityGloveTargetComponent"
local GrabTag = "Action.Grab"
local UnusedTag = "Action.Unused"
local SweepMilliseconds = 1000
local GlovesActionPath = "/Game/Player/InputActions/IA_GravityGloves.IA_GravityGloves"
local GlovesKeyRefreshMilliseconds = 2000
local DefaultGlovesKeyName = "ThumbMouseButton2"

local glovesKeyNames = { [DefaultGlovesKeyName] = true }
local keyNameLogged = false
local failedStims = {}

local function IsDefaultObject(object)
    return object:GetFName():ToString():find("Default__", 1, true) == 1
end

local function ReplaceTag(container, oldTag, newTag)
    container.GameplayTags:ForEach(function(index, element)
        local tag = element:get()
        if tag.TagName:ToString() == oldTag then
            tag.TagName = FName(newTag)
        end
    end)
end

local function PatchSprintAction(action, enabled)
    local from = enabled and GrabTag or UnusedTag
    local to = enabled and UnusedTag or GrabTag
    pcall(ReplaceTag, action.CancelActionsWithTag, from, to)
end

local function ApplySprintPatch(enabled)
    local defaults = StaticFindObject(SprintDefaultPath)
    if defaults and defaults:IsValid() then
        PatchSprintAction(defaults, enabled)
    end
    for _, action in ipairs(FindAllOf(SprintClassName) or {}) do
        PatchSprintAction(action, enabled)
    end
end

local function MakeStimPullable(pickup)
    local gloveTargetClass = StaticFindObject(GloveTargetClassPath)
    local hasTarget, component = pcall(function() return pickup:GetComponentByClass(gloveTargetClass) end)
    if not (hasTarget and component and component:IsValid()) then
        local transform = {
            Rotation = { X = 0, Y = 0, Z = 0, W = 1 },
            Translation = { X = 0, Y = 0, Z = 0 },
            Scale3D = { X = 1, Y = 1, Z = 1 },
        }
        local added, newComponent = pcall(function()
            return pickup:AddComponentByClass(gloveTargetClass, false, transform, false)
        end)
        component = added and newComponent or nil
    end
    return component ~= nil and component:IsValid()
end

local function AttractStim(stim, pawn)
    local ok, errorMessage = pcall(function() stim:ReceiveActorBeginOverlap(pawn) end)
    if not ok then
        Log.Error("PullableStims " .. tostring(errorMessage))
    end
end

local function ResolveKeys()
    local resolved = {
        LeftMouseButton = Key.LEFT_MOUSE_BUTTON,
        RightMouseButton = Key.RIGHT_MOUSE_BUTTON,
        MiddleMouseButton = Key.MIDDLE_MOUSE_BUTTON,
        ThumbMouseButton = Key.XBUTTON_ONE,
        ThumbMouseButton2 = Key.XBUTTON_TWO,
        SpaceBar = Key.SPACE,
        LeftShift = Key.LEFT_SHIFT,
        LeftControl = Key.LEFT_CONTROL,
        LeftAlt = Key.LEFT_ALT,
        Tab = Key.TAB,
        One = Key.ONE,
        Two = Key.TWO,
        Three = Key.THREE,
        Four = Key.FOUR,
        Five = Key.FIVE,
    }
    for code = string.byte("A"), string.byte("Z") do
        local letter = string.char(code)
        resolved[letter] = Key[letter]
    end
    return resolved
end

local function RefreshGlovesKeys()
    local subsystem = FindFirstOf("EnhancedInputLocalPlayerSubsystem")
    local action = StaticFindObject(GlovesActionPath)
    if not (subsystem and subsystem:IsValid() and action and action:IsValid()) then
        return
    end
    local names = {}
    local ok = pcall(function()
        subsystem:QueryKeysMappedToAction(action):ForEach(function(index, element)
            names[element:get().KeyName:ToString()] = true
        end)
    end)
    if ok and next(names) then
        glovesKeyNames = names
        if not keyNameLogged then
            keyNameLogged = true
            local list = {}
            for name in pairs(names) do
                list[#list + 1] = name
            end
            Log.Info("gravity gloves keys: " .. table.concat(list, ", "))
        end
    end
end

local function OnGlovesButton()
    if not Settings.IsEnabled("PullableStims") then
        return
    end
    local pawn = FindFirstOf("BP_PlayerPawn_C")
    if not (pawn and pawn:IsValid()) then
        return
    end
    local stim = StimAim.FindAimedStim(pawn)
    if stim then
        AttractStim(stim, pawn)
    end
end

local function BindGlovesKeys()
    for name, key in pairs(ResolveKeys()) do
        if key then
            RegisterKeyBind(key, function()
                if glovesKeyNames[name] then
                    ExecuteInGameThread(function()
                        pcall(OnGlovesButton)
                    end)
                end
            end)
        end
    end
end

local function SweepStims()
    for _, stim in ipairs(FindAllOf(StimClassName) or {}) do
        if stim:IsValid() and not IsDefaultObject(stim) then
            local name = stim:GetFullName()
            if not failedStims[name] then
                local ok, added = pcall(MakeStimPullable, stim)
                if not (ok and added) then
                    failedStims[name] = true
                end
            end
        end
    end
end

local function Sweep()
    if Settings.IsEnabled("SprintKeepsGrab") then
        ApplySprintPatch(true)
    end
    if Settings.IsEnabled("PullableStims") then
        SweepStims()
    end
end

Settings.OnChanged("SprintKeepsGrab", ApplySprintPatch)
BindGlovesKeys()
Scheduler.EveryInGameThread(GlovesKeyRefreshMilliseconds, RefreshGlovesKeys)
Scheduler.EveryInGameThread(SweepMilliseconds, Sweep)
