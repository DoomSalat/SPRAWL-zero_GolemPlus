local Log = require("Log")
local Settings = require("Settings")

local SettleMilliseconds = 400
local PunchHoldMilliseconds = 120
local AttemptMilliseconds = 60
local RetryGapMilliseconds = 30
local MaximumWaitMilliseconds = 900
local PunchDurationMilliseconds = 650
local GlovesClassName = "BP_Weapon_GravityGloves_C"
local WeaponSlot = 0
local FireActionPath = "/Game/Player/InputActions/IA_PrimaryFire.IA_PrimaryFire"
local FireEventNames = {
    "InpActEvt_IA_PrimaryFire_K2Node_EnhancedInputActionEvent_17",
    "InpActEvt_IA_PrimaryFire_K2Node_EnhancedInputActionEvent_18",
}
local PressElapsedSeconds = 0.004
local PressedValue = { Value = { X = 1.0, Y = 0.0, Z = 0.0 }, ValueType = 0 }
local PickupClassName = "WeaponPickup"

local busy = false
local knownPickups = {}

local function CollectPickupNames()
    local names = {}
    for _, pickup in ipairs(FindAllOf(PickupClassName) or {}) do
        if pickup:IsValid() then
            names[pickup:GetFullName()] = true
        end
    end
    return names
end

local function FindDroppedPickup()
    for _, pickup in ipairs(FindAllOf(PickupClassName) or {}) do
        if pickup:IsValid() and not knownPickups[pickup:GetFullName()] then
            return pickup
        end
    end
    return nil
end

local function HeldClassName(inventory)
    local ok, name = pcall(function() return inventory.HeldWeapon:GetClass():GetFName():ToString() end)
    return ok and name or ""
end

local function IsFiring(inventory)
    local ok, firing = pcall(function() return inventory.HeldWeapon:GetIsFiring() end)
    return ok and firing
end

local function SendFireEvents(pawn, elapsedSeconds)
    local source = StaticFindObject(FireActionPath)
    for _, eventName in ipairs(FireEventNames) do
        local ok, errorMessage = pcall(function()
            pawn[eventName](PressedValue, elapsedSeconds, elapsedSeconds, source)
        end)
        if not ok then
            Log.Error("PunchSwap " .. eventName .. " " .. tostring(errorMessage))
        end
    end
end

local function SetFirePressed(pawn, inventory, pressed)
    SendFireEvents(pawn, pressed and PressElapsedSeconds or PunchHoldMilliseconds / 1000)
    pcall(function() inventory.HeldWeapon.WantsToFire = pressed end)
end

local function HidePickup(pickup)
    pcall(function() pickup.bAllowGrab = false end)
    pcall(function() pickup:SetActorHiddenInGame(true) end)
    pcall(function() pickup:SetActorEnableCollision(false) end)
end

local function Restore(inventory, pickup)
    local ok, errorMessage = pcall(function()
        inventory:SetSlot(WeaponSlot, pickup.WeaponClass, pickup.WeaponSnapshot, true)
    end)
    if ok then
        HidePickup(pickup)
    else
        Log.Error("PunchSwap could not return the weapon: " .. tostring(errorMessage))
    end
    busy = false
end

local function Punch(pawn, inventory, pickup)
    local startedAt = os.clock()
    local function Finish()
        ExecuteWithDelay(PunchDurationMilliseconds, function()
            ExecuteInGameThread(function()
                SetFirePressed(pawn, inventory, false)
                if pickup:IsValid() then
                    Restore(inventory, pickup)
                else
                    busy = false
                end
            end)
        end)
    end
    local function Attempt()
        if (os.clock() - startedAt) * 1000 > MaximumWaitMilliseconds then
            Finish()
            return
        end
        SetFirePressed(pawn, inventory, true)
        ExecuteWithDelay(AttemptMilliseconds, function()
            ExecuteInGameThread(function()
                if IsFiring(inventory) then
                    Finish()
                    return
                end
                SetFirePressed(pawn, inventory, false)
                ExecuteWithDelay(RetryGapMilliseconds, function()
                    ExecuteInGameThread(Attempt)
                end)
            end)
        end)
    end
    Attempt()
end

local function FireOnly(pawn)
    busy = true
    SendFireEvents(pawn, PressElapsedSeconds)
    ExecuteWithDelay(PunchHoldMilliseconds, function()
        ExecuteInGameThread(function()
            SendFireEvents(pawn, PunchHoldMilliseconds / 1000)
            busy = false
        end)
    end)
end

local function StartPunch()
    if busy then
        return
    end
    local pawn = FindFirstOf("BP_PlayerPawn_C")
    local inventory = pawn and pawn.InventoryManager
    if not (inventory and inventory:IsValid()) or pawn.Dead then
        return
    end
    if HeldClassName(inventory) == GlovesClassName then
        FireOnly(pawn)
        return
    end
    busy = true
    knownPickups = CollectPickupNames()
    local swapped, swapError = pcall(function()
        inventory:SetSlot(WeaponSlot, inventory.EmptyWeaponClass, {}, true)
    end)
    if not swapped then
        Log.Error("PunchSwap could not equip the gloves: " .. tostring(swapError))
        busy = false
        return
    end
    ExecuteWithDelay(SettleMilliseconds, function()
        ExecuteInGameThread(function()
            local pickup = FindDroppedPickup()
            if pickup and pickup:IsValid() then
                Punch(pawn, inventory, pickup)
            else
                busy = false
            end
        end)
    end)
end

for _, item in ipairs(Settings.GetItems()) do
    if item.name == "PunchKey" then
        for _, option in ipairs(item.options) do
            if option.key then
                RegisterKeyBind(option.key, function()
                    if Settings.IsEnabled("PunchSwap") and Settings.GetChoice("PunchKey") == option.id then
                        ExecuteInGameThread(function()
                            pcall(StartPunch)
                        end)
                    end
                end)
            else
                Log.Error("PunchSwap: key " .. option.id .. " is not available in this UE4SS build")
            end
        end
    end
end
