local Log = require("Log")
local Scheduler = require("Scheduler")
local Settings = require("Settings")

local FeatureName = "NoAdsSlowdown"
local ParamsPropertyName = "ADSCameraBehaviourParams"
local TargetSpeedMultiplier = 1.0
local SweepMilliseconds = 2000

local originals = {}

local function ApplyToObject(object, enabled)
    local name = object:GetFullName()
    local current = object[ParamsPropertyName].MovementSpeedMultiplier
    if enabled then
        if current ~= TargetSpeedMultiplier then
            originals[name] = originals[name] or current
            object[ParamsPropertyName].MovementSpeedMultiplier = TargetSpeedMultiplier
        end
    elseif originals[name] ~= nil then
        object[ParamsPropertyName].MovementSpeedMultiplier = originals[name]
        originals[name] = nil
    end
end

local function ApplyWeapon(weapon)
    if type(weapon) ~= "userdata" or not weapon:IsValid() then
        return
    end
    local enabled = Settings.IsEnabled(FeatureName)
    local ok, errorMessage = pcall(ApplyToObject, weapon, enabled)
    if not ok then
        Log.Error("WeaponTweaks " .. tostring(errorMessage))
    end
    pcall(function() ApplyToObject(weapon:GetClass():GetCDO(), enabled) end)
end

local function ApplyAllWeapons()
    for _, weapon in ipairs(FindAllOf("WeaponBase") or {}) do
        ApplyWeapon(weapon)
    end
end

Settings.OnChanged(FeatureName, ApplyAllWeapons)
ApplyAllWeapons()
Scheduler.EveryInGameThread(SweepMilliseconds, ApplyAllWeapons)
