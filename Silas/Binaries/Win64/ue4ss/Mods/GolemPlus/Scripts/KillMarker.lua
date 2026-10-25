local Log = require("Log")
local Scheduler = require("Scheduler")
local Settings = require("Settings")
local UiText = require("UiText")

local EnemyClassName = "SilasAICharacterBase"
local FontPath = "/Game/UI/Fonts/Oxanium-Regular_Font.Oxanium-Regular_Font"
local KillSoundPath = "/Game/FMOD/Events/Player/Player_TimeBonus.Player_TimeBonus"
local MarkerText = "LIQUIDATED"
local MarkerFontSize = 14
local MarkerOffsetX = -48
local MarkerOffsetY = 0
local MarkerColor = { R = 2.0, G = 0.1, B = 0.1, A = 1.0 }
local FadeDurationSeconds = 1.4
local FadeStepMilliseconds = 80
local DuplicateDeathWindowSeconds = 0.5
local DeathPollMilliseconds = 200

local markerWidget = nil
local markerHudName = nil
local fadeToken = 0
local lastDeathTime = {}
local deathStates = {}

local function EnsureMarkerWidget()
    local hud = UiText.FindHud()
    if not hud then
        return nil
    end
    local hudName = hud:GetFullName()
    if markerWidget and markerWidget:IsValid() and markerHudName == hudName then
        return markerWidget
    end
    local text, slot = UiText.Create(hud, "GolemPlusKillMarker")
    slot:SetAnchors({ Minimum = { X = 0.5, Y = 0.5 }, Maximum = { X = 0.5, Y = 0.5 } })
    slot:SetAlignment({ X = 1.0, Y = 0.5 })
    slot:SetAutoSize(true)
    slot:SetPosition({ X = MarkerOffsetX, Y = MarkerOffsetY })
    text:SetText(FText(MarkerText))
    UiText.ApplyFont(text, FontPath, MarkerFontSize)
    text:SetColorAndOpacity({ SpecifiedColor = MarkerColor, ColorUseRule = 0 })
    text:SetRenderOpacity(0.0)
    markerWidget = text
    markerHudName = hudName
    return markerWidget
end

local function PlayKillSound()
    local sound = StaticFindObject(KillSoundPath)
    local statics = StaticFindObject("/Script/FMODStudio.Default__FMODBlueprintStatics")
    local pawn = FindFirstOf("BP_PlayerPawn_C")
    if sound and sound:IsValid() and statics and pawn and pawn:IsValid() then
        statics:PlayEvent2D(pawn, sound, true)
    end
end

local function StartFade()
    fadeToken = fadeToken + 1
    local token = fadeToken
    local startedAt = os.clock()
    LoopAsync(FadeStepMilliseconds, function()
        if token ~= fadeToken then
            return true
        end
        local progress = (os.clock() - startedAt) / FadeDurationSeconds
        local finished = progress >= 1.0
        local alpha = finished and 0.0 or (1.0 - progress) * (1.0 - progress)
        ExecuteInGameThread(function()
            if markerWidget and markerWidget:IsValid() then
                markerWidget:SetRenderOpacity(alpha)
            end
        end)
        return finished
    end)
end

local function ShowKillMarker(enemyName)
    local now = os.clock()
    if lastDeathTime[enemyName] and now - lastDeathTime[enemyName] < DuplicateDeathWindowSeconds then
        return
    end
    lastDeathTime[enemyName] = now
    local ok, errorMessage = pcall(function()
        if EnsureMarkerWidget() then
            PlayKillSound()
            StartFade()
        end
    end)
    if not ok then
        Log.Error("KillMarker " .. tostring(errorMessage))
    end
end

local function PollEnemyDeaths()
    local alive = {}
    for _, enemy in ipairs(FindAllOf(EnemyClassName) or {}) do
        if enemy:IsValid() then
            local enemyName = enemy:GetFullName()
            local dead = enemy.bIsDead
            alive[enemyName] = true
            if dead and deathStates[enemyName] == false and Settings.IsEnabled("KillMarker") then
                ShowKillMarker(enemyName)
            end
            deathStates[enemyName] = dead
        end
    end
    for enemyName in pairs(deathStates) do
        if not alive[enemyName] then
            deathStates[enemyName] = nil
        end
    end
end

Scheduler.EveryInGameThread(DeathPollMilliseconds, PollEnemyDeaths)
