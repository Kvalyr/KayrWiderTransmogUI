-- ====================================================================================================================
-- =	KayrWiderTransmogUI
-- =	Copyright (c) Kvalyr - 2020-2021 - All Rights Reserved
-- ====================================================================================================================
local C_Timer = _G["C_Timer"]
local CreateFrame = _G["CreateFrame"]

local function Round(number, decimals)
    local power = 10 ^ decimals
    return math.floor(number * power) / power
end

-- Debugging
local KLib = _G["KLib"]
if not KLib then
    KLib = {Con = function() end, Warn = function() end, Print = print} -- No-Op if KLib not available
end

-- --------------------------------------------------------------------------------------------------------------------
-- Addon class
-- --------------------------------------------------------
KayrWiderTransmogUI = CreateFrame("Frame", "KayrWiderTransmogUI", UIParent)
KayrWiderTransmogUI.initDone = false

-- --------------------------------------------------------------------------------------------------------------------
-- Listen for Blizz Collections UI being loaded
-- --------------------------------------------------------
function KayrWiderTransmogUI:ADDON_LOADED(event, addon)
    KLib:Con("KayrWiderTransmogUI.ADDON_LOADED", event, addon)
    if addon == "Blizzard_Collections" then
        KayrWiderTransmogUI:Init()
    end
end

-- --------------------------------------------------------------------------------------------------------------------
-- Debugging: Dump current frame widths & positions
-- --------------------------------------------------------
function KayrWiderTransmogUI.Dump()
    if not KLib.DebugFramePoints then return end
    local WardrobeFrame = _G["WardrobeFrame"]
    local WardrobeTransmogFrame = _G["WardrobeTransmogFrame"]

    KLib:Con("KayrWiderTransmogUI", "WardrobeFrame:GetWidth()", WardrobeFrame:GetWidth())
    KLib:Con("KayrWiderTransmogUI", "WardrobeTransmogFrame:GetWidth()", WardrobeTransmogFrame:GetWidth())

    KLib:Con("KayrWiderTransmogUI", "WardrobeTransmogFrame.Inset GetWidth()", WardrobeTransmogFrame.Inset:GetWidth())
    KLib:Con("KayrWiderTransmogUI", "WardrobeTransmogFrame.Inset.Bg GetWidth()", WardrobeTransmogFrame.Inset.Bg:GetWidth())
    KLib:Con("KayrWiderTransmogUI", "WardrobeTransmogFrame.Inset.BG GetWidth()", WardrobeTransmogFrame.Inset.BG:GetWidth())

    KLib:Con("KayrWiderTransmogUI", "WardrobeTransmogFrame.ModelScene GetWidth()", WardrobeTransmogFrame.ModelScene:GetWidth())

    KLib:Con("KayrWiderTransmogUI", "ModelScene SlotButtons: ----------------")
    for key, val in pairs(WardrobeTransmogFrame.ModelScene.SlotButtons) do
        KLib:Con("KayrWiderTransmogUI", "ModelScene SlotButtons", key, val, val.slotID, val.slot)
        KLib.DebugFramePoints(val)
    end
end

-- --------------------------------------------------------------------------------------------------------------------
-- Adjust WardrobeFrame & WardrobeTransmogFrame widths, then reposition the slot buttons
-- --------------------------------------------------------
function KayrWiderTransmogUI.Adjust()
    local WardrobeFrame = _G["WardrobeFrame"]
    local WardrobeTransmogFrame = _G["WardrobeTransmogFrame"]
    local initialParentFrameWidth = WardrobeFrame:GetWidth() -- Expecting 965
    local desiredParentFrameWidth = 1200
    local parentFrameWidthIncrease = desiredParentFrameWidth - initialParentFrameWidth
    WardrobeFrame:SetWidth(desiredParentFrameWidth)

    local initialTransmogFrameWidth = WardrobeTransmogFrame:GetWidth()
    local desiredTransmogFrameWidth = initialTransmogFrameWidth + parentFrameWidthIncrease
    WardrobeTransmogFrame:SetWidth(desiredTransmogFrameWidth)

    -- These frames are built using absolute sizes instead of relative points for some reason. Let's stick with that..
    local insetWidth = Round(initialTransmogFrameWidth - WardrobeTransmogFrame.ModelScene:GetWidth(), 0)
    WardrobeTransmogFrame.Inset.BG:SetWidth(WardrobeTransmogFrame.Inset.Bg:GetWidth() - insetWidth)
    WardrobeTransmogFrame.ModelScene:SetWidth(WardrobeTransmogFrame:GetWidth() - insetWidth)

    -- 1 == HEADSLOT
    -- 9 == HANDSSLOT
    -- 13 == MAINHANDSLOT
    -- 14 == SECONDARYHANDSLOT

    -- Move HEADSLOT -- Other slots in the left column are attached relative to it
    WardrobeTransmogFrame.ModelScene.SlotButtons[1]:SetPoint("TOP", -235, -40)

    -- Move HANDSSLOT -- Other slots in the right column are attached relative to it
    WardrobeTransmogFrame.ModelScene.SlotButtons[9]:SetPoint("TOP", 238, -118)

    local weaponSlotOffset = 25

    -- Move MAINHANDSLOT
    local mainHandPoint, _, _, mainHandXOffset, mainHandYOffset = WardrobeTransmogFrame.ModelScene.SlotButtons[13]:GetPoint("BOTTOM")
    local mainHandEnchantPoint, _, _, mainHandEnchantXOffset, mainHandEnchantYOffset = WardrobeTransmogFrame.ModelScene.SlotButtons[15]:GetPoint()
    WardrobeTransmogFrame.ModelScene.SlotButtons[13]:SetPoint(mainHandPoint, mainHandXOffset, mainHandYOffset - weaponSlotOffset)
    WardrobeTransmogFrame.ModelScene.SlotButtons[15]:SetPoint(mainHandEnchantPoint, mainHandEnchantXOffset, mainHandEnchantYOffset - weaponSlotOffset)

    -- Move SECONDARYHANDSLOT
    local offHandPoint, _, _, offHandXOffset, offHandYOffset = WardrobeTransmogFrame.ModelScene.SlotButtons[14]:GetPoint("BOTTOM")
    local offHandEnchantPoint, _, _, offHandEnchantXOffset, offHandEnchantYOffset = WardrobeTransmogFrame.ModelScene.SlotButtons[16]:GetPoint()
    WardrobeTransmogFrame.ModelScene.SlotButtons[14]:SetPoint(offHandPoint, offHandXOffset, offHandYOffset - weaponSlotOffset)
    WardrobeTransmogFrame.ModelScene.SlotButtons[16]:SetPoint(offHandEnchantPoint, offHandEnchantXOffset, offHandEnchantYOffset - weaponSlotOffset)

    -- Ease constraints on zooming out
    -- Default probably varies by player race but who cares, just let the player zoom out
    local function ExtendZoomDistance()
        WardrobeTransmogFrame.ModelScene.activeCamera.maxZoomDistance = 5
    end
    WardrobeTransmogFrame.ModelScene:SetScript("OnShow", function() C_Timer.After(0.25, ExtendZoomDistance) end)
    -- WardrobeTransmogFrame.ModelScene.activeCamera.maxZoomDistance = 5
end

-- --------------------------------------------------------------------------------------------------------------------
-- Init
-- --------------------------------------------------------
function KayrWiderTransmogUI:Init()
    -- KLib:Con("KayrWiderTransmogUI.Init")
    -- KayrWiderTransmogUI.Dump()

    KayrWiderTransmogUI.Adjust()
    KayrWiderTransmogUI.initDone = true

end

KayrWiderTransmogUI:RegisterEvent("ADDON_LOADED")
KayrWiderTransmogUI:SetScript("OnEvent", KayrWiderTransmogUI.ADDON_LOADED)
