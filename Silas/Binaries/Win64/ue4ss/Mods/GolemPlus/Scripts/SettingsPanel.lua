local Log = require("Log")
local Locale = require("Locale")
local Settings = require("Settings")
local UiText = require("UiText")

local OpenKey = Key.F1
local UpKey = Key.UP_ARROW
local DownKey = Key.DOWN_ARROW
local ActivateKey = Key.RETURN
local FontPath = "/Game/UI/Fonts/Oxanium-Regular_Font.Oxanium-Regular_Font"
local FontSize = 12
local AnchorY = 0.4
local OffsetX = 24
local Color = { R = 1.0, G = 1.0, B = 1.0, A = 1.0 }
local Title = "Golem Plus"
local SelectedMarker = "> "
local UnselectedMarker = "   "

local widget = nil
local widgetHudName = nil
local isOpen = false
local selected = 1

local function EnsureWidget()
    local hud = UiText.FindHud()
    if not hud then
        return nil
    end
    local hudName = hud:GetFullName()
    if widget and widget:IsValid() and widgetHudName == hudName then
        return widget
    end
    local text, slot = UiText.Create(hud, "GolemPlusPanel")
    slot:SetAnchors({ Minimum = { X = 0.0, Y = AnchorY }, Maximum = { X = 0.0, Y = AnchorY } })
    slot:SetAlignment({ X = 0.0, Y = 0.5 })
    slot:SetAutoSize(true)
    slot:SetPosition({ X = OffsetX, Y = 0 })
    UiText.ApplyFont(text, FontPath, FontSize)
    text:SetColorAndOpacity({ SpecifiedColor = Color, ColorUseRule = 0 })
    text:SetRenderOpacity(0.0)
    widget = text
    widgetHudName = hudName
    return widget
end

local function BuildText()
    local lines = { Title, Locale.Text("PanelHint"), "" }
    for index, item in ipairs(Settings.GetItems()) do
        local marker = index == selected and SelectedMarker or UnselectedMarker
        lines[#lines + 1] = marker .. Settings.GetTitle(item) .. ": " .. Settings.GetValueText(item)
    end
    return table.concat(lines, "\n")
end

local function Refresh()
    local ok, errorMessage = xpcall(function()
        if not EnsureWidget() then
            return
        end
        widget:SetText(FText(BuildText()))
        widget:SetRenderOpacity(isOpen and 1.0 or 0.0)
    end, debug.traceback)
    if not ok then
        Log.Error("SettingsPanel " .. tostring(errorMessage))
    end
end

local function Bind(key, name, action)
    if not key then
        Log.Error("SettingsPanel: key " .. name .. " is not available in this UE4SS build")
        return
    end
    RegisterKeyBind(key, function()
        ExecuteInGameThread(function()
            local ok, errorMessage = xpcall(action, debug.traceback)
            if not ok then
                Log.Error("SettingsPanel action " .. tostring(errorMessage))
            end
            Refresh()
        end)
    end)
end

Bind(OpenKey, "F1", function()
    isOpen = not isOpen
end)

Bind(UpKey, "UP_ARROW", function()
    if isOpen then
        selected = (selected - 2) % #Settings.GetItems() + 1
    end
end)

Bind(DownKey, "DOWN_ARROW", function()
    if isOpen then
        selected = selected % #Settings.GetItems() + 1
    end
end)

Bind(ActivateKey, "RETURN", function()
    if isOpen then
        Settings.Activate(Settings.GetItems()[selected])
    end
end)
