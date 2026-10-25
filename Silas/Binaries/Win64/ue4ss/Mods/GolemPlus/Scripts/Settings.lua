local Locale = require("Locale")

local Settings = {}

local ConfigFileName = "settings.cfg"

local Items = {
    { kind = "toggle", name = "SprintKeepsGrab" },
    { kind = "toggle", name = "PullableStims" },
    { kind = "toggle", name = "KillMarker" },
    { kind = "toggle", name = "NoAdsSlowdown" },
    { kind = "toggle", name = "AltScan" },
    { kind = "toggle", name = "PunchSwap" },
    {
        kind = "choice",
        name = "PunchKey",
        options = {
            { id = "Mouse4", key = Key.XBUTTON_ONE },
            { id = "Mouse5", key = Key.XBUTTON_TWO },
            { id = "Mouse3", key = Key.MIDDLE_MOUSE_BUTTON },
            { id = "V", key = Key.V },
            { id = "F", key = Key.F },
        },
    },
}

local values = {}
local listeners = {}

local function ResolveConfigPath()
    local source = debug.getinfo(1, "S").source
    local scriptsDirectory = source:match("^@(.*)[/\\][^/\\]+$")
    if scriptsDirectory then
        return scriptsDirectory .. "/../" .. ConfigFileName
    end
    return ConfigFileName
end

local configPath = ResolveConfigPath()

local function FindOptionIndex(item, id)
    for index, option in ipairs(item.options) do
        if option.id == id then
            return index
        end
    end
    return nil
end

local function Load()
    for _, item in ipairs(Items) do
        if item.kind == "toggle" then
            values[item.name] = true
        else
            values[item.name] = item.options[1].id
        end
    end
    local file = io.open(configPath, "r")
    if not file then
        return
    end
    for line in file:lines() do
        local name, value = line:match("^(%w+)=(%w+)$")
        for _, item in ipairs(Items) do
            if item.name == name then
                if item.kind == "toggle" then
                    values[name] = value == "1"
                elseif FindOptionIndex(item, value) then
                    values[name] = value
                end
            end
        end
    end
    file:close()
end

local function Save()
    local file = io.open(configPath, "w")
    if not file then
        return
    end
    for _, item in ipairs(Items) do
        local value = values[item.name]
        if item.kind == "toggle" then
            value = value and "1" or "0"
        end
        file:write(item.name .. "=" .. value .. "\n")
    end
    file:close()
end

function Settings.GetItems()
    return Items
end

function Settings.IsEnabled(name)
    return values[name]
end

function Settings.GetChoice(name)
    return values[name]
end

function Settings.GetTitle(item)
    return Locale.Text(item.name)
end

function Settings.GetValueText(item)
    if item.kind == "toggle" then
        return Locale.Text(values[item.name] and "On" or "Off")
    end
    return Locale.Text(values[item.name])
end

function Settings.OnChanged(name, callback)
    listeners[name] = callback
end

function Settings.Activate(item)
    if item.kind == "toggle" then
        values[item.name] = not values[item.name]
    else
        local index = FindOptionIndex(item, values[item.name]) % #item.options + 1
        values[item.name] = item.options[index].id
    end
    Save()
    local listener = listeners[item.name]
    if listener then
        pcall(listener, values[item.name])
    end
end

Load()

return Settings
