-- ====================================================================================================================
-- =	KayrWiderTransmogUI
-- =	Copyright (c) Kvalyr - 2020-2021 - All Rights Reserved
-- ====================================================================================================================
local hooksecurefunc = _G["hooksecurefunc"]
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

    KLib.DebugFramePoints(WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox)

    local slotButtons = WardrobeTransmogFrame.SlotButtons
    if not slotButtons then
        KLib:Con("KayrWiderTransmogUI", "ModelScene SlotButtons: NIL")
        return
    end

    KLib:Con("KayrWiderTransmogUI", "ModelScene SlotButtons: ----------------")
    for key, val in pairs(slotButtons) do
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

    -- Move HEADSLOT -- Other slots in the left column are attached relative to it
    WardrobeTransmogFrame.HeadButton:SetPoint("TOP", -235, -40)

    -- Move HANDSSLOT -- Other slots in the right column are attached relative to it
    WardrobeTransmogFrame.HandsButton:SetPoint("TOP", 238, -118)

    -- -- Move MAINHANDSLOT
    WardrobeTransmogFrame.MainHandButton:SetPoint("BOTTOM", -26, 23)
    WardrobeTransmogFrame.MainHandEnchantButton:SetPoint("CENTER", -26, -230)

    -- -- Move SECONDARYHANDSLOT
    WardrobeTransmogFrame.SecondaryHandButton:SetPoint("BOTTOM", 27, 23)
    WardrobeTransmogFrame.SecondaryHandEnchantButton:SetPoint("CENTER", 27, -230)

    -- Move Separate Shoulder checkbox
    WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox:SetPoint("BOTTOMLEFT", WardrobeTransmogFrame, "BOTTOMLEFT", 580, 15)

    -- Ease constraints on zooming out
    -- Default probably varies by player race but who cares, just let the player zoom out
    local function ExtendZoomDistance()
        WardrobeTransmogFrame.ModelScene.activeCamera.maxZoomDistance = 5
    end
    WardrobeTransmogFrame.ModelScene:SetScript("OnShow", function() C_Timer.After(0.25, ExtendZoomDistance) end)
end

-- --------------------------------------------------------------------------------------------------------------------
-- Init
-- --------------------------------------------------------
function KayrWiderTransmogUI:Init()
    local WardrobeTransmogFrame = _G["WardrobeTransmogFrame"]
    hooksecurefunc(WardrobeTransmogFrame, "Update", KayrWiderTransmogUI.Adjust)
    KayrWiderTransmogUI.initDone = true
end

KayrWiderTransmogUI:RegisterEvent("ADDON_LOADED")
KayrWiderTransmogUI:SetScript("OnEvent", KayrWiderTransmogUI.ADDON_LOADED)
