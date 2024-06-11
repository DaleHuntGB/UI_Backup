RLU = LibStub("AceAddon-3.0"):NewAddon("RLU")
RLU_GUI = LibStub("AceGUI-3.0")
local ADDON_NAME = C_AddOns.GetAddOnMetadata("RaidLeaderUtility", "Title")
local BUTTON_W = 100
local BUTTON_H = 32
local BG_TEXTURE = "Interface\\Buttons\\WHITE8X8"
local BORDER_TEXTURE = "Interface\\Buttons\\WHITE8X8"
local EDGE_SIZE = 1
local BG_INSET = 0
local UNIT_FRAME_W = 120
local UNIT_FRAME_H = 32
local UNIT_FRAME_SPACING = 1
local ICON_SIZE = 32
local CONTAINER_SIZE = (UNIT_FRAME_W + 2) + ((ICON_SIZE + 2 ) * 9) + 2
local RAID_CLASSES = {}
local EVOKER, MAGE, WARRIOR, DRUID, PRIEST, WARLOCK = false, false, false, false, false, false
RLU.UnitFrames = RLU.UnitFrames or {}
local FoodBuffs = {
    [382145] = "|cFF40FF40Yes|r - |cFF999999Haste|r",
    [382150] = "|cFF40FF40Yes|r - |cFF999999Mastery|r",
    [382146] = "|cFF40FF40Yes|r - |cFF999999Critical Strike|r",
    [382149] = "|cFF40FF40Yes|r - |cFF999999Versatility|r",
    [396092] = "|cFF40FF40Yes|r - |cFF999999Primary Stat|r",
    [382246] = "|cFF40FF40Yes|r - |cFF999999Stamina [60]|r",
    [382247] = "|cFF40FF40Yes|r - |cFF999999Stamina [90]|r",
    [382152] = "|cFF40FF40Yes|r - |cFF999999Haste / Critical Strike|r",
    [382153] = "|cFF40FF40Yes|r - |cFF999999Haste / Versatility|r",
    [382157] = "|cFF40FF40Yes|r - |cFF999999Versatility / Mastery|r",
    [382230] = "|cFF40FF40Yes|r - |cFF999999Stamina / Strength|r",
    [382231] = "|cFF40FF40Yes|r - |cFF999999Stamina / Agility|r",
    [382232] = "|cFF40FF40Yes|r - |cFF999999Stamina / Intellect|r",
    [382154] = "|cFF40FF40Yes|r - |cFF999999Haste / Mastery|r",
    [382155] = "|cFF40FF40Yes|r - |cFF999999Critical Strike / Versatility|r",
    [382156] = "|cFF40FF40Yes|r - |cFF999999Critical Strike / Mastery|r",
    [382234] = "|cFF40FF40Yes|r - |cFF999999Stamina / Strength|r",
    [382235] = "|cFF40FF40Yes|r - |cFF999999Stamina / Agility|r",
    [382236] = "|cFF40FF40Yes|r - |cFF999999Stamina / Intellect|r",
}
local FlaskBuffs = {
    [374000] = "|cFF40FF40Yes|r - |cFF999999Iced Phial of Corrupting Rage|r",
    [371354] = "|cFF40FF40Yes|r - |cFF999999Phial of the Eye in the Storm|r",
    [371204] = "|cFF40FF40Yes|r - |cFF999999Phial of Still Air|r",
    [370661] = "|cFF40FF40Yes|r - |cFF999999Phial of Icy Preservation|r",
    [371386] = "|cFF40FF40Yes|r - |cFF999999Phial of Charged Isolation|r",
    [373257] = "|cFF40FF40Yes|r - |cFF999999Phial of Glacial Fury|r",
    [370652] = "|cFF40FF40Yes|r - |cFF999999Phial of Static Empowerment|r",
    [371172] = "|cFF40FF40Yes|r - |cFF999999Phial of Tepid Versatility|r",
    [371186] = "|cFF40FF40Yes|r - |cFF999999Charged Phial of Alacrity|r",
    [371339] = "|cFF40FF40Yes|r - |cFF999999Phial of Elemental Chaos|r",
}
local RuneBuffs = {
    [393438] = "|cFF40FF40Yes|r - |cFF999999Draconic Augmentation|r",
}
function RLU:PrettyPrint(MSG)
    print(ADDON_NAME .. ":|r " .. MSG)
end
function RLU:OnInitialize()
    RLU:PrettyPrint("Loaded")
    RLU:DrawAnchorFrame()
    RLU:DrawButton("ReadyCheckButton", BUTTON_W, BUTTON_H, "LEFT", 2, 0, "Ready Check")
    RLU:DrawButton("PullTimerButton", BUTTON_W, BUTTON_H, "LEFT", BUTTON_W + 3, 0, "Pull Timer")
    RLU:DrawButton("CombatLoggingButton", BUTTON_W, BUTTON_H, "LEFT", (BUTTON_W + 2) * 2, 0, RLU:CombatLoggingStatus())
end
function RLU:CombatLoggingStatus()
    return LoggingCombat() and "Logging: |cFF40FF40On|r" or "Logging: |cFFFF4040Off|r"
end
function RLU:DrawAnchorFrame()
    local AnchorFrame = CreateFrame("Frame", "RLU_AnchorFrame", UIParent, "BackdropTemplate")
    AnchorFrame:SetSize((BUTTON_W + 2) * 3, BUTTON_H + 4)
    AnchorFrame:SetPoint("CENTER", 0, 0)
    AnchorFrame:SetBackdrop({
        bgFile = BG_TEXTURE,
        edgeFile = BORDER_TEXTURE,
        edgeSize = EDGE_SIZE,
        insets = {left = BG_INSET, right = BG_INSET, top = BG_INSET, bottom = BG_INSET}
    })
    AnchorFrame:SetBackdropColor(20/255, 20/255, 20/255, 1.0)
    AnchorFrame:SetBackdropBorderColor(0, 0, 0, 1)
    AnchorFrame:SetMovable(true)
    AnchorFrame:EnableMouse(true)
    AnchorFrame:RegisterForDrag("LeftButton")
    AnchorFrame:SetScript("OnDragStart", AnchorFrame.StartMoving)
    AnchorFrame:SetScript("OnDragStop", AnchorFrame.StopMovingOrSizing)
    AnchorFrame:Show()
end
function RLU:DrawButton(buttonFrameName, buttonW, buttonH, buttonAnchor, buttonX, buttonY, buttonLabel)
    local ButtonTemplate = CreateFrame("Button", "RLU_" .. buttonFrameName, RLU_AnchorFrame, "UIPanelButtonTemplate")
    ButtonTemplate:SetSize(buttonW, buttonH)
    ButtonTemplate:SetPoint(buttonAnchor, buttonX, buttonY)
    ButtonTemplate:SetText(buttonLabel)
end
function RLU:SetupScripts()
    if RLU_ReadyCheckButton then
        RLU_ReadyCheckButton:SetScript("OnMouseDown", function(_,  button)
            if button == "LeftButton" then
                RLU:PrettyPrint("Ready Check - Left Click")
            elseif button == "RightButton" then
                RLU:PrettyPrint("Ready Check - Right Click")
                RLU:CreateRaidInformationFrame()
            end
        end)
    end
    if RLU_PullTimerButton then
        RLU_PullTimerButton:SetScript("OnMouseDown", function(_,  button)
            if button == "LeftButton" then
                RLU:PrettyPrint("Pull Timer - Left Click")
            elseif button == "RightButton" then
                RLU:PrettyPrint("Pull Timer - Right Click")
            end
        end)
    end
    if RLU_CombatLoggingButton then
        RLU_CombatLoggingButton:SetScript("OnMouseDown", function(_,  button)
            if button == "LeftButton" then
                RLU:PrettyPrint("Combat Logging - Left Click")
            elseif button == "RightButton" then
                RLU:PrettyPrint("Combat Logging - Right Click")
            end
        end)
    end
end
function RLU:ApplyElvUISkin()
    if C_AddOns.IsAddOnLoaded("ElvUI") then
        local E, L, V, P, G = unpack(ElvUI)
        local S = E:GetModule("Skins")
        S:HandleButton(RLU_ReadyCheckButton)
        S:HandleButton(RLU_PullTimerButton)
        S:HandleButton(RLU_CombatLoggingButton)
    end
end
function RLU:ClassColourName(unit)
    local _, class = UnitClass(unit)
    local unitName = UnitName(unit)
    local colour = RAID_CLASS_COLORS[class]
    return "|c" .. colour.colorStr .. unitName .. "|r"
end
function RLU:FetchRaidClasses()
    RAID_CLASSES = {}
    EVOKER, MAGE, WARRIOR, DRUID, PRIEST, WARLOCK = false, false, false, false, false, false
    for i = 1, 40 do
        local unitName, _, _, _, class = GetRaidRosterInfo(i)
        if not unitName then break end
        table.insert(RAID_CLASSES, class)
    end
    for _, class in ipairs(RAID_CLASSES) do
        if class == "Mage" then MAGE = true end
        if class == "Warrior" then WARRIOR = true end
        if class == "Druid" then DRUID = true end
        if class == "Priest" then PRIEST = true end
        if class == "Evoker" then EVOKER = true end
        if class == "Warlock" then WARLOCK = true end
    end
    return RAID_CLASSES
end
function RLU:CreateRaidInformationFrame()
    local TitleFrame = CreateFrame("Frame", "RLU_RaidInformationFrame_TitleFrame", UIParent, "BackdropTemplate")
    TitleFrame:SetSize(CONTAINER_SIZE - 23, 24)
    TitleFrame:SetPoint("CENTER", 0, 1141 / 2)
    TitleFrame:SetBackdrop({
        bgFile = BG_TEXTURE,
        edgeFile = BORDER_TEXTURE,
        edgeSize = EDGE_SIZE,
        insets = {left = BG_INSET, right = BG_INSET, top = BG_INSET, bottom = BG_INSET}
    })
    TitleFrame:SetBackdropColor(15/255, 15/255, 15/255, 1.0)
    TitleFrame:SetBackdropBorderColor(0, 0, 0, 1)
    TitleFrame:SetMovable(true)
    TitleFrame:EnableMouse(true)
    TitleFrame:RegisterForDrag("LeftButton")
    TitleFrame:SetScript("OnDragStart", TitleFrame.StartMoving)
    TitleFrame:SetScript("OnDragStop", TitleFrame.StopMovingOrSizing)
    local TitleFrameText = TitleFrame:CreateFontString(nil, "OVERLAY")
    TitleFrameText:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
    TitleFrameText:SetPoint("CENTER", 0, 0)
    TitleFrameText:SetText("|cFF8080FFRaid Information|r")
    local ContainerFrame = CreateFrame("Frame", "RLU_RaidInformationFrame", TitleFrame, "BackdropTemplate")
    ContainerFrame:SetSize(CONTAINER_SIZE, (UNIT_FRAME_H + UNIT_FRAME_SPACING) * 30 + 6)
    ContainerFrame:SetPoint("TOPLEFT", TitleFrame, "BOTTOMLEFT", 0, 1)
    ContainerFrame:SetBackdrop({
        bgFile = BG_TEXTURE,
        edgeFile = BORDER_TEXTURE,
        edgeSize = EDGE_SIZE,
        insets = {left = BG_INSET, right = BG_INSET, top = BG_INSET, bottom = BG_INSET}
    })
    ContainerFrame:SetBackdropColor(20/255, 20/255, 20/255, 1.0)
    ContainerFrame:SetBackdropBorderColor(0, 0, 0, 1)
    ContainerFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    ContainerFrame:SetScript("OnUpdate", function(self, elapsed) self.elapsed = (self.elapsed or 0) + elapsed if self.elapsed < 5 then return end self.elapsed = 0 RLU:FetchRaidClasses() RLU:UpdateUnitFrames() end)
    ContainerFrame:SetScript("OnEvent", function(self, event, ...) if event == "GROUP_ROSTER_UPDATE" then RLU:FetchRaidClasses() RLU:UpdateUnitFrames() end end)
    ContainerFrame:SetScript("OnHide", function(self)
        RLU.UnitFrames = {}
        RLU.UnitFrameNames = {}
        self:SetScript("OnUpdate", nil)
    end)
    local CloseButton = CreateFrame("Button", "RLU_RaidInformationFrame_CloseButton", TitleFrame, "BackdropTemplate")
    CloseButton:SetSize(24, 24)
    CloseButton:SetPoint("BOTTOMRIGHT", ContainerFrame, "TOPRIGHT", 0, -1)
    CloseButton:SetBackdrop({
        bgFile = BG_TEXTURE,
        edgeFile = BORDER_TEXTURE,
        edgeSize = EDGE_SIZE,
        insets = {left = BG_INSET, right = BG_INSET, top = BG_INSET, bottom = BG_INSET}
    })
    CloseButton:SetBackdropColor(15/255, 15/255, 15/255, 1.0)
    CloseButton:SetBackdropBorderColor(0, 0, 0, 1)
    local CloseButtonTexture = CloseButton:CreateTexture(nil, "ARTWORK")
    CloseButtonTexture:SetAllPoints()
    CloseButtonTexture:SetAtlas("uitools-icon-close")
    CloseButton:SetScript("OnMouseDown", function()
        TitleFrame:Hide()
        CloseButton:Hide()
        ContainerFrame:Hide()
    end)
    CloseButton:SetScript("OnEnter", function() CloseButton:SetBackdropColor(30/255, 30/255, 30/255, 1.0) end)
    CloseButton:SetScript("OnLeave", function() CloseButton:SetBackdropColor(15/255, 15/255, 15/255, 1.0) end)
    RLU.UnitFrames = RLU.UnitFrames or {}
    RLU.UnitFrameNames = RLU.UnitFrameNames or {}
    function RLU:UpdateUnitFrames()
        local CurrentUnitNames = {}
        for i = 1, 40 do
            local unitName, _, unitGroup, _, unitClass = GetRaidRosterInfo(i)
            local unitRole = UnitGroupRolesAssigned(unitName)
            local hasFoodBuff, hasFlaskBuff, hasRuneBuff, hasSoulstoneBuff, hasSourceOfMagicBuff, hasStaminaBuff, hasMarkOfTheWildBuff, hasBlessingOfTheBronzeBuff, hasBattleShoutBuff, hasIntellectBuff = false, false, false, false, false, false, false, false, false, false
            local foodDur, flaskDur, runeDur, soulstoneDur, sourceOfMagicDur, staminaDur, markOfTheWildDur, blessingOfTheBronzeDur, battleShoutDur, intellectDur = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
            local foodIcon, flaskIcon, runeIcon = 136000, 4620669, 134078
            if not unitName then break end
            CurrentUnitNames[unitName] = true
            for j = 1, 40 do
                local unitAura = C_UnitAuras.GetAuraDataByIndex(unitName, j, "HELPFUL")
                local spellID = unitAura and unitAura.spellId
                local auraDur = unitAura and unitAura.expirationTime - GetTime()
                local auraIcon = unitAura and unitAura.icon
                if not spellID then break end
                if FoodBuffs[spellID] then hasFoodBuff = true foodDur = math.ceil(auraDur / 60) foodIcon = auraIcon or 136000 end
                if FlaskBuffs[spellID] then hasFlaskBuff = true flaskDur = math.ceil(auraDur / 60) flaskIcon = auraIcon or 4620669 end
                if RuneBuffs[spellID] then hasRuneBuff = true runeDur = math.ceil(auraDur / 60) runeIcon = auraIcon or 134078 end
                if spellID == 20707 then hasSoulstoneBuff = true soulstoneDur = math.ceil(auraDur / 60) end
                if spellID == 369459 then hasSourceOfMagicBuff = true sourceOfMagicDur = math.ceil(auraDur / 60) end
                if spellID == 21562 then hasStaminaBuff = true staminaDur = math.ceil(auraDur / 60) end
                if spellID == 1126 then hasMarkOfTheWildBuff = true markOfTheWildDur = math.ceil(auraDur / 60) end
                if unitAura and unitAura.name and unitAura.name:match("Blessing of the Bronze") then hasBlessingOfTheBronzeBuff = true blessingOfTheBronzeDur = math.ceil(auraDur / 60) end
                if spellID == 6673 then hasBattleShoutBuff = true battleShoutDur = math.ceil(auraDur / 60) end
                if spellID == 1459 then hasIntellectBuff = true intellectDur = math.ceil(auraDur / 60) end
            end
            local UnitFrame = RLU.UnitFrames[unitName]
            if not UnitFrame then
                UnitFrame = CreateFrame("Frame", "RLU_RaidInformationFrame_UnitFrame_" .. i, ContainerFrame, "BackdropTemplate")
                UnitFrame:SetSize(UNIT_FRAME_W, UNIT_FRAME_H)
                UnitFrame:SetFrameStrata("MEDIUM")
                UnitFrame:SetBackdrop({ bgFile = BG_TEXTURE, edgeFile = BORDER_TEXTURE, edgeSize = EDGE_SIZE, insets = {left = BG_INSET, right = BG_INSET, top = BG_INSET, bottom = BG_INSET} })
                local _, class = UnitClass(unitName)
                local colour = RAID_CLASS_COLORS[class]
                UnitFrame:SetBackdropColor(colour.r, colour.g, colour.b, 1.0)
                UnitFrame:SetBackdropBorderColor(0, 0, 0, 1)
                UnitFrame:SetScript("OnEnter", function() UnitFrame:SetBackdropColor(colour.r + 0.1, colour.g + 0.1, colour.b + 0.1, 1.0) end)
                UnitFrame:SetScript("OnLeave", function() UnitFrame:SetBackdropColor(colour.r, colour.g, colour.b, 1.0) end)
                UnitFrame.UnitFrameLabel = UnitFrame:CreateFontString(nil, "OVERLAY")
                UnitFrame.UnitFrameLabel:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
                UnitFrame.UnitFrameLabel:SetPoint("CENTER", 0, 0)
                UnitFrame.UnitFrameWellFedIcon = UnitFrame:CreateTexture(nil, "OVERLAY")
                UnitFrame.UnitFrameWellFedIcon:SetSize(ICON_SIZE, ICON_SIZE)
                UnitFrame.UnitFrameWellFedIcon:SetPoint("LEFT", UnitFrame, "RIGHT", 1, 0)
                UnitFrame.UnitFrameWellFedDuration = UnitFrame:CreateFontString(nil, "OVERLAY")
                UnitFrame.UnitFrameWellFedDuration:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
                UnitFrame.UnitFrameWellFedDuration:SetPoint("CENTER", UnitFrame.UnitFrameWellFedIcon, "CENTER", 0, 0)
                UnitFrame.UnitFrameFlaskIcon = UnitFrame:CreateTexture(nil, "OVERLAY")
                UnitFrame.UnitFrameFlaskIcon:SetSize(ICON_SIZE, ICON_SIZE)
                UnitFrame.UnitFrameFlaskIcon:SetPoint("LEFT", UnitFrame.UnitFrameWellFedIcon, "RIGHT", 1, 0)
                UnitFrame.UnitFrameFlaskDuration = UnitFrame:CreateFontString(nil, "OVERLAY")
                UnitFrame.UnitFrameFlaskDuration:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
                UnitFrame.UnitFrameFlaskDuration:SetPoint("CENTER", UnitFrame.UnitFrameFlaskIcon, "CENTER", 0, 0)
                UnitFrame.UnitFrameRuneIcon = UnitFrame:CreateTexture(nil, "OVERLAY")
                UnitFrame.UnitFrameRuneIcon:SetSize(ICON_SIZE, ICON_SIZE)
                UnitFrame.UnitFrameRuneIcon:SetPoint("LEFT", UnitFrame.UnitFrameFlaskIcon, "RIGHT", 1, 0)
                UnitFrame.UnitFrameRuneDuration = UnitFrame:CreateFontString(nil, "OVERLAY")
                UnitFrame.UnitFrameRuneDuration:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
                UnitFrame.UnitFrameRuneDuration:SetPoint("CENTER", UnitFrame.UnitFrameRuneIcon, "CENTER", 0, 0)
                RLU.UnitFrames[unitName] = UnitFrame
                table.insert(RLU.UnitFrameNames, unitName)
            end
            local colour = RAID_CLASS_COLORS[select(2, UnitClass(unitName))]
            UnitFrame:SetBackdropColor(colour.r, colour.g, colour.b, 1.0)
            UnitFrame.UnitFrameLabel:SetText(UnitName(unitName))
            UnitFrame.UnitFrameWellFedIcon:SetTexture(foodIcon)
            if hasFoodBuff then UnitFrame.UnitFrameWellFedIcon:SetDesaturated(false) else UnitFrame.UnitFrameWellFedIcon:SetDesaturated(true) end
            UnitFrame.UnitFrameWellFedDuration:SetText(foodDur .. "m")
            UnitFrame.UnitFrameFlaskIcon:SetTexture(flaskIcon)
            if hasFlaskBuff then UnitFrame.UnitFrameFlaskIcon:SetDesaturated(false) else UnitFrame.UnitFrameFlaskIcon:SetDesaturated(true) end
            UnitFrame.UnitFrameFlaskDuration:SetText(flaskDur .. "m")
            UnitFrame.UnitFrameRuneIcon:SetTexture(runeIcon)
            if hasRuneBuff then UnitFrame.UnitFrameRuneIcon:SetDesaturated(false) else UnitFrame.UnitFrameRuneIcon:SetDesaturated(true) end
            UnitFrame.UnitFrameRuneDuration:SetText(runeDur .. "m")
            if unitRole == "HEALER" then
                if WARLOCK then
                    if not UnitFrame.UnitFrameSoulstoneIcon then
                        UnitFrame.UnitFrameSoulstoneIcon = UnitFrame:CreateTexture(nil, "OVERLAY")
                        UnitFrame.UnitFrameSoulstoneIcon:SetSize(ICON_SIZE, ICON_SIZE)
                        UnitFrame.UnitFrameSoulstoneIcon:SetPoint("LEFT", UnitFrame.UnitFrameRuneIcon, "RIGHT", 1, 0)
                        UnitFrame.UnitFrameSoulstoneIcon:SetTexture("Interface\\Icons\\spell_shadow_soulgem")
                        UnitFrame.UnitFrameSoulstoneDuration = UnitFrame:CreateFontString(nil, "OVERLAY")
                        UnitFrame.UnitFrameSoulstoneDuration:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
                        UnitFrame.UnitFrameSoulstoneDuration:SetPoint("CENTER", UnitFrame.UnitFrameSoulstoneIcon, "CENTER", 0, 0)
                    end
                    UnitFrame.UnitFrameSoulstoneIcon:SetTexture("Interface\\Icons\\spell_shadow_soulgem")
                    if hasSoulstoneBuff then UnitFrame.UnitFrameSoulstoneIcon:SetDesaturated(false) else UnitFrame.UnitFrameSoulstoneIcon:SetDesaturated(true) end
                    UnitFrame.UnitFrameSoulstoneDuration:SetText(soulstoneDur .. "m")
                end
                if EVOKER then
                    if not UnitFrame.UnitFrameSourceOfMagicIcon then
                        UnitFrame.UnitFrameSourceOfMagicIcon = UnitFrame:CreateTexture(nil, "OVERLAY")
                        UnitFrame.UnitFrameSourceOfMagicIcon:SetSize(ICON_SIZE, ICON_SIZE)
                        if WARLOCK then UnitFrame.UnitFrameSourceOfMagicIcon:SetPoint("LEFT", UnitFrame.UnitFrameSoulstoneIcon, "RIGHT", 1, 0) else UnitFrame.UnitFrameSourceOfMagicIcon:SetPoint("LEFT", UnitFrame.UnitFrameRuneIcon, "RIGHT", 1, 0) end
                        UnitFrame.UnitFrameSourceOfMagicIcon:SetTexture("Interface\\Icons\\ability_evoker_blue_01")
                        UnitFrame.UnitFrameSourceOfMagicDuration = UnitFrame:CreateFontString(nil, "OVERLAY")
                        UnitFrame.UnitFrameSourceOfMagicDuration:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
                        UnitFrame.UnitFrameSourceOfMagicDuration:SetPoint("CENTER", UnitFrame.UnitFrameSourceOfMagicIcon, "CENTER", 0, 0)
                    end
                    UnitFrame.UnitFrameSourceOfMagicIcon:SetTexture("Interface\\Icons\\ability_evoker_blue_01")
                    if hasSourceOfMagicBuff then UnitFrame.UnitFrameSourceOfMagicIcon:SetDesaturated(false) else UnitFrame.UnitFrameSourceOfMagicIcon:SetDesaturated(true) end
                    UnitFrame.UnitFrameSourceOfMagicDuration:SetText(sourceOfMagicDur .. "m")
                end
            else
                if UnitFrame.UnitFrameSoulstoneIcon then
                    UnitFrame.UnitFrameSoulstoneIcon:Hide()
                    UnitFrame.UnitFrameSoulstoneIcon:SetParent(nil)
                    UnitFrame.UnitFrameSoulstoneDuration:Hide()
                    UnitFrame.UnitFrameSoulstoneDuration:SetParent(nil)
                    UnitFrame.UnitFrameSoulstoneIcon = nil
                    UnitFrame.UnitFrameSoulstoneDuration = nil
                end
                if UnitFrame.UnitFrameSourceOfMagicIcon then
                    UnitFrame.UnitFrameSourceOfMagicIcon:Hide()
                    UnitFrame.UnitFrameSourceOfMagicIcon:SetParent(nil)
                    UnitFrame.UnitFrameSourceOfMagicDuration:Hide()
                    UnitFrame.UnitFrameSourceOfMagicDuration:SetParent(nil)
                    UnitFrame.UnitFrameSourceOfMagicIcon = nil
                    UnitFrame.UnitFrameSourceOfMagicDuration = nil
                end
            end
            if PRIEST then
                if not UnitFrame.UnitFrameStaminaIcon then
                    UnitFrame.UnitFrameStaminaIcon = UnitFrame:CreateTexture(nil, "OVERLAY")
                    UnitFrame.UnitFrameStaminaIcon:SetSize(ICON_SIZE, ICON_SIZE)
                    if unitRole == "HEALER" then 
                        if WARLOCK then 
                            UnitFrame.UnitFrameStaminaIcon:SetPoint("LEFT", UnitFrame.UnitFrameSoulstoneIcon, "RIGHT", 1, 0) 
                        elseif EVOKER then 
                            UnitFrame.UnitFrameStaminaIcon:SetPoint("LEFT", UnitFrame.UnitFrameSourceOfMagicIcon, "RIGHT", 1, 0) 
                        else
                            UnitFrame.UnitFrameStaminaIcon:SetPoint("LEFT", UnitFrame.UnitFrameRuneIcon, "RIGHT", 1, 0) 
                        end
                    else
                        UnitFrame.UnitFrameStaminaIcon:SetPoint("LEFT", UnitFrame.UnitFrameRuneIcon, "RIGHT", 1, 0) 
                    end
                    UnitFrame.UnitFrameStaminaIcon:SetTexture("Interface\\Icons\\spell_holy_wordfortitude")
                    UnitFrame.UnitFrameStaminaDuration = UnitFrame:CreateFontString(nil, "OVERLAY")
                    UnitFrame.UnitFrameStaminaDuration:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
                    UnitFrame.UnitFrameStaminaDuration:SetPoint("CENTER", UnitFrame.UnitFrameStaminaIcon, "CENTER", 0, 0)
                end
                UnitFrame.UnitFrameStaminaIcon:SetTexture("Interface\\Icons\\spell_holy_wordfortitude")
                if hasStaminaBuff then UnitFrame.UnitFrameStaminaIcon:SetDesaturated(false) else UnitFrame.UnitFrameStaminaIcon:SetDesaturated(true) end
                UnitFrame.UnitFrameStaminaDuration:SetText(staminaDur .. "m")
            else
                if UnitFrame.UnitFrameStaminaIcon then
                    UnitFrame.UnitFrameStaminaIcon:Hide()
                    UnitFrame.UnitFrameStaminaIcon:SetParent(nil)
                    UnitFrame.UnitFrameStaminaDuration:Hide()
                    UnitFrame.UnitFrameStaminaDuration:SetParent(nil)
                    UnitFrame.UnitFrameStaminaIcon = nil
                    UnitFrame.UnitFrameStaminaDuration = nil
                end
            end
            if DRUID then
                if not UnitFrame.UnitFrameMarkOfTheWildIcon then
                    UnitFrame.UnitFrameMarkOfTheWildIcon = UnitFrame:CreateTexture(nil, "OVERLAY")
                    UnitFrame.UnitFrameMarkOfTheWildIcon:SetSize(ICON_SIZE, ICON_SIZE)
                    if PRIEST then 
                        UnitFrame.UnitFrameMarkOfTheWildIcon:SetPoint("LEFT", UnitFrame.UnitFrameStaminaIcon, "RIGHT", 1, 0) 
                    elseif unitRole == "HEALER" then 
                        if WARLOCK then 
                            UnitFrame.UnitFrameMarkOfTheWildIcon:SetPoint("LEFT", UnitFrame.UnitFrameSoulstoneIcon, "RIGHT", 1, 0)
                        elseif EVOKER then 
                            UnitFrame.UnitFrameMarkOfTheWildIcon:SetPoint("LEFT", UnitFrame.UnitFrameSourceOfMagicIcon, "RIGHT", 1, 0) 
                        else 
                            UnitFrame.UnitFrameMarkOfTheWildIcon:SetPoint("LEFT", UnitFrame.UnitFrameRuneIcon, "RIGHT", 1, 0) 
                        end 
                    else 
                        UnitFrame.UnitFrameMarkOfTheWildIcon:SetPoint("LEFT", UnitFrame.UnitFrameRuneIcon, "RIGHT", 1, 0) 
                    end
                    UnitFrame.UnitFrameMarkOfTheWildIcon:SetTexture("Interface\\Icons\\spell_nature_regeneration")
                    UnitFrame.UnitFrameMarkOfTheWildDuration = UnitFrame:CreateFontString(nil, "OVERLAY")
                    UnitFrame.UnitFrameMarkOfTheWildDuration:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
                    UnitFrame.UnitFrameMarkOfTheWildDuration:SetPoint("CENTER", UnitFrame.UnitFrameMarkOfTheWildIcon, "CENTER", 0, 0)
                end
                UnitFrame.UnitFrameMarkOfTheWildIcon:SetTexture("Interface\\Icons\\spell_nature_regeneration")
                if hasMarkOfTheWildBuff then UnitFrame.UnitFrameMarkOfTheWildIcon:SetDesaturated(false) else UnitFrame.UnitFrameMarkOfTheWildIcon:SetDesaturated(true) end
                UnitFrame.UnitFrameMarkOfTheWildDuration:SetText(markOfTheWildDur .. "m")
            else
                if UnitFrame.UnitFrameMarkOfTheWildIcon then
                    UnitFrame.UnitFrameMarkOfTheWildIcon:Hide()
                    UnitFrame.UnitFrameMarkOfTheWildIcon:SetParent(nil)
                    UnitFrame.UnitFrameMarkOfTheWildDuration:Hide()
                    UnitFrame.UnitFrameMarkOfTheWildDuration:SetParent(nil)
                    UnitFrame.UnitFrameMarkOfTheWildIcon = nil
                    UnitFrame.UnitFrameMarkOfTheWildDuration = nil
                end
            end
            if WARRIOR then
                if not UnitFrame.UnitFrameBattleShoutIcon then
                    UnitFrame.UnitFrameBattleShoutIcon = UnitFrame:CreateTexture(nil, "OVERLAY")
                    UnitFrame.UnitFrameBattleShoutIcon:SetSize(ICON_SIZE, ICON_SIZE)
                    if DRUID then 
                        UnitFrame.UnitFrameBattleShoutIcon:SetPoint("LEFT", UnitFrame.UnitFrameMarkOfTheWildIcon, "RIGHT", 1, 0)
                    elseif PRIEST then
                        UnitFrame.UnitFrameBattleShoutIcon:SetPoint("LEFT", UnitFrame.UnitFrameStaminaIcon, "RIGHT", 1, 0)
                    elseif unitRole == "HEALER" then
                        if WARLOCK then 
                            UnitFrame.UnitFrameBattleShoutIcon:SetPoint("LEFT", UnitFrame.UnitFrameSoulstoneIcon, "RIGHT", 1, 0)
                        elseif EVOKER then 
                            UnitFrame.UnitFrameBattleShoutIcon:SetPoint("LEFT", UnitFrame.UnitFrameSourceOfMagicIcon, "RIGHT", 1, 0)
                        else 
                            UnitFrame.UnitFrameBattleShoutIcon:SetPoint("LEFT", UnitFrame.UnitFrameRuneIcon, "RIGHT", 1, 0)
                        end
                    else 
                        UnitFrame.UnitFrameBattleShoutIcon:SetPoint("LEFT", UnitFrame.UnitFrameRuneIcon, "RIGHT", 1, 0)
                    end
                    UnitFrame.UnitFrameBattleShoutIcon:SetTexture("Interface\\Icons\\ability_warrior_battleshout")
                    UnitFrame.UnitFrameBattleShoutDuration = UnitFrame:CreateFontString(nil, "OVERLAY")
                    UnitFrame.UnitFrameBattleShoutDuration:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
                    UnitFrame.UnitFrameBattleShoutDuration:SetPoint("CENTER", UnitFrame.UnitFrameBattleShoutIcon, "CENTER", 0, 0)
                end
                UnitFrame.UnitFrameBattleShoutIcon:SetTexture("Interface\\Icons\\ability_warrior_battleshout")
                if hasBattleShoutBuff then UnitFrame.UnitFrameBattleShoutIcon:SetDesaturated(false) else UnitFrame.UnitFrameBattleShoutIcon:SetDesaturated(true) end
                UnitFrame.UnitFrameBattleShoutDuration:SetText(battleShoutDur .. "m")
            else
                if UnitFrame.UnitFrameBattleShoutIcon then
                    UnitFrame.UnitFrameBattleShoutIcon:Hide()
                    UnitFrame.UnitFrameBattleShoutIcon:SetParent(nil)
                    UnitFrame.UnitFrameBattleShoutDuration:Hide()
                    UnitFrame.UnitFrameBattleShoutDuration:SetParent(nil)
                    UnitFrame.UnitFrameBattleShoutIcon = nil
                    UnitFrame.UnitFrameBattleShoutDuration = nil
                end
            end
            if MAGE then
                if not UnitFrame.UnitFrameIntellectIcon then
                    UnitFrame.UnitFrameIntellectIcon = UnitFrame:CreateTexture(nil, "OVERLAY")
                    UnitFrame.UnitFrameIntellectIcon:SetSize(ICON_SIZE, ICON_SIZE)
                    if WARRIOR then 
                        UnitFrame.UnitFrameIntellectIcon:SetPoint("LEFT", UnitFrame.UnitFrameBattleShoutIcon, "RIGHT", 1, 0)
                    elseif DRUID then
                        UnitFrame.UnitFrameIntellectIcon:SetPoint("LEFT", UnitFrame.UnitFrameMarkOfTheWildIcon, "RIGHT", 1, 0)
                    elseif PRIEST then
                        UnitFrame.UnitFrameIntellectIcon:SetPoint("LEFT", UnitFrame.UnitFrameStaminaIcon, "RIGHT", 1, 0)
                    elseif unitRole == "HEALER" then
                        if WARLOCK then 
                            UnitFrame.UnitFrameIntellectIcon:SetPoint("LEFT", UnitFrame.UnitFrameSoulstoneIcon, "RIGHT", 1, 0)
                        elseif EVOKER then 
                            UnitFrame.UnitFrameIntellectIcon:SetPoint("LEFT", UnitFrame.UnitFrameSourceOfMagicIcon, "RIGHT", 1, 0)
                        else 
                            UnitFrame.UnitFrameIntellectIcon:SetPoint("LEFT", UnitFrame.UnitFrameRuneIcon, "RIGHT", 1, 0)
                        end
                    else 
                        UnitFrame.UnitFrameIntellectIcon:SetPoint("LEFT", UnitFrame.UnitFrameRuneIcon, "RIGHT", 1, 0)
                    end
                    UnitFrame.UnitFrameIntellectIcon:SetTexture("Interface\\Icons\\spell_holy_magicalsentry")
                    UnitFrame.UnitFrameIntellectDuration = UnitFrame:CreateFontString(nil, "OVERLAY")
                    UnitFrame.UnitFrameIntellectDuration:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
                    UnitFrame.UnitFrameIntellectDuration:SetPoint("CENTER", UnitFrame.UnitFrameIntellectIcon, "CENTER", 0, 0)
                end
                UnitFrame.UnitFrameIntellectIcon:SetTexture("Interface\\Icons\\spell_holy_magicalsentry")
                if hasIntellectBuff then UnitFrame.UnitFrameIntellectIcon:SetDesaturated(false) else UnitFrame.UnitFrameIntellectIcon:SetDesaturated(true) end
                UnitFrame.UnitFrameIntellectDuration:SetText(intellectDur .. "m")
            else
                if UnitFrame.UnitFrameIntellectIcon then
                    UnitFrame.UnitFrameIntellectIcon:Hide()
                    UnitFrame.UnitFrameIntellectIcon:SetParent(nil)
                    UnitFrame.UnitFrameIntellectDuration:Hide()
                    UnitFrame.UnitFrameIntellectDuration:SetParent(nil)
                    UnitFrame.UnitFrameIntellectIcon = nil
                    UnitFrame.UnitFrameIntellectDuration = nil
                end
            end
            UnitFrame:Show()
        end
        for unitName, unitFrame in pairs(RLU.UnitFrames) do
            if not CurrentUnitNames[unitName] then
                unitFrame:Hide()
                unitFrame:SetParent(nil)
                RLU.UnitFrames[unitName] = nil
                for i, name in ipairs(RLU.UnitFrameNames) do
                    if name == unitName then
                        table.remove(RLU.UnitFrameNames, i)
                        break
                    end
                end
            end
        end
        for i, unitName in ipairs(RLU.UnitFrameNames) do
            local UnitFrame = RLU.UnitFrames[unitName]
            UnitFrame:ClearAllPoints()
            UnitFrame:SetPoint("TOPLEFT", 2, -2 - (UNIT_FRAME_H + UNIT_FRAME_SPACING) * (i - 1))
        end
    end
    RLU:FetchRaidClasses()
end
function RLU:OnEnable()
    RLU:ApplyElvUISkin()
    RLU:SetupScripts()
end