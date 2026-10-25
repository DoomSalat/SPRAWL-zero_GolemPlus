local UiText = {}

local TextBlockClassPath = "/Script/UMG.TextBlock"
local HudClassName = "W_PlayerHUD_C"
local NameScale = 1000

function UiText.FindHud()
    for _, hud in ipairs(FindAllOf(HudClassName) or {}) do
        if hud:IsValid() and hud:IsInViewport() then
            return hud
        end
    end
    return nil
end

function UiText.Create(hud, prefix)
    for _, previous in ipairs(FindAllOf("TextBlock") or {}) do
        if previous:IsValid() and previous:GetFName():ToString():find(prefix, 1, true) == 1 then
            pcall(function() previous:RemoveFromParent() end)
        end
    end
    local name = FName(prefix .. "_" .. tostring(math.floor(os.clock() * NameScale)))
    local text = StaticConstructObject(StaticFindObject(TextBlockClassPath), hud.WidgetTree, name)
    local slot = hud.MainCanvas:AddChildToCanvas(text)
    return text, slot
end

function UiText.ApplyFont(text, fontPath, size)
    local font = text.Font
    font.FontObject = StaticFindObject(fontPath)
    font.Size = size
    text:SetFont(font)
end

return UiText
