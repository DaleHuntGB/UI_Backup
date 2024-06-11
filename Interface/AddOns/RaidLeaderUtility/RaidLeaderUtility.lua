RLU = RLU or {}
local isRIFShown = false
local BUTTON_SIZE = {100, 24}
local raidClasses = {}
local hasEvoker, hasMage, hasWarrior, hasDruid, hasPriest, hasWarlock = false, false, false, false, false, false

USER_OPTIONS = {
    ANCHOR_POSITION = 4 -- 1 = TOP (Horizontal), 2 = BOTTOM (Horizontal), 3 = LEFT (Vertical), 4 = RIGHT (Vertical)
}

local foodTypes = {
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

local flaskTypes = {
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

local runeTypes = {
    [393438] = "|cFF40FF40Yes|r - |cFF999999Draconic Augmentation|r",
}

local RaidLeaderUtility = CreateFrame("Frame")
RaidLeaderUtility:RegisterEvent("PLAYER_LOGIN")
RaidLeaderUtility:RegisterEvent("PLAYER_ENTERING_WORLD")

function RLU:SkinButton(button)
    if C_AddOns.IsAddOnLoaded("ElvUI") then
        local E = unpack(ElvUI)
        local S = E:GetModule('Skins')
        S:HandleButton(button)
    end
end

RaidLeaderUtility:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        RLU:SetupReadyCheck()
        RLU:SetupCombatLogging()
        RLU:SetupPullTimer()
        RLU:SkinButton(ReadyCheckButton)
        RLU:SkinButton(PullTimerButton)
        RLU:SkinButton(CombatLoggingButton)
    end
end)

function RLU:CombatLoggingStatus()
    return LoggingCombat() and "|cFFFFFFFFLogging|r: |cFF40FF40On|r" or "|cFFFFFFFFLogging|r: |cFFFF4040Off|r"
end

function RLU:SetupCombatLogging()
    SetCVar("advancedCombatLogging", 1)

    if not CombatLoggingButton then
        CombatLoggingButton = CreateFrame("Button", "CombatLoggingButton", UIParent, "UIPanelButtonTemplate")
        CombatLoggingButton:SetSize(BUTTON_SIZE[1], BUTTON_SIZE[2])
        CombatLoggingButton:SetText(RLU:CombatLoggingStatus())
        if USER_OPTIONS.ANCHOR_POSITION == 1 or USER_OPTIONS.ANCHOR_POSITION == 2 then 
            CombatLoggingButton:SetPoint("RIGHT", ReadyCheckButton, "LEFT", -1, 0)
        elseif USER_OPTIONS.ANCHOR_POSITION == 3 or USER_OPTIONS.ANCHOR_POSITION == 4 then
            CombatLoggingButton:SetPoint("BOTTOM", ReadyCheckButton, "TOP", 0, 1)
        end
        CombatLoggingButton:SetAlpha(0.5)
    end

    CombatLoggingButton:SetScript("OnClick", function()
        if InCombatLockdown() then return end
        if LoggingCombat() then
            LoggingCombat(false)
            CombatLoggingButton:SetText("|cFFFFFFFFLogging|r: |cFFFF4040Off|r")
        else
            LoggingCombat(true)
            CombatLoggingButton:SetText("|cFFFFFFFFLogging|r: |cFF40FF40On|r")
        end
    end)

    CombatLoggingButton:SetScript("OnEnter", function(self)
        CombatLoggingButton:SetAlpha(1.0)
    end)

    CombatLoggingButton:SetScript("OnLeave", function(self)
        CombatLoggingButton:SetAlpha(0.5)
    end)

    return CombatLoggingButton
end

function RLU:ClassColourName(unit)
    local _, class = UnitClass(unit)
    local colour = RAID_CLASS_COLORS[class]
    return "|c" .. colour.colorStr .. UnitName(unit) .. "|r"
end

function RLU:FetchRaidClasses()
    raidClasses = {}
    hasEvoker, hasMage, hasWarrior, hasDruid, hasPriest, hasWarlock = false, false, false, false, false, false

    for i = 1, 40 do
        local unitName, _, _, _, class = GetRaidRosterInfo(i)
        if not unitName then break end
        table.insert(raidClasses, class)
    end

    for _, class in ipairs(raidClasses) do
        if class == "Mage" then hasMage = true end
        if class == "Warrior" then hasWarrior = true end
        if class == "Druid" then hasDruid = true end
        if class == "Priest" then hasPriest = true end
        if class == "Evoker" then hasEvoker = true end
        if class == "Warlock" then hasWarlock = true end
    end

    return raidClasses
end

local function CreateRaidInfoFrame()
    isRIFShown = true
    local RaidInfoTitle = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    RaidInfoTitle:SetSize(460, 24)
    RaidInfoTitle:SetBackdrop({bgFile = "Interface/Buttons/WHITE8X8", edgeFile = "Interface/Buttons/WHITE8X8", edgeSize = 1})
    RaidInfoTitle:SetBackdropColor(20/255, 20/255, 20/255, 1.0)
    RaidInfoTitle:SetBackdropBorderColor(0, 0, 0, 1.0)
    RaidInfoTitle:SetMovable(true)
    RaidInfoTitle:EnableMouse(true)
    RaidInfoTitle:RegisterForDrag("LeftButton")
    RaidInfoTitle:SetScript("OnDragStart", RaidInfoTitle.StartMoving)
    RaidInfoTitle:SetScript("OnDragStop", RaidInfoTitle.StopMovingOrSizing)
    RaidInfoTitle:SetPoint("CENTER", UIParent, "CENTER", 0, 109)

    local RaidInfoTitleText = RaidInfoTitle:CreateFontString(nil, "OVERLAY")
    RaidInfoTitleText:SetPoint("CENTER", RaidInfoTitle, "CENTER", 0, 0)
    RaidInfoTitleText:SetFont("Fonts/FRIZQT__.ttf", 12, "OUTLINE")
    RaidInfoTitleText:SetText("|cFF8080FFRaid Information|r")

    local RaidInfoFrame = CreateFrame("Frame", "RaidInfoFrame", RaidInfoTitle, "BackdropTemplate")
    RaidInfoFrame:SetSize(510, 191)
    RaidInfoFrame:SetPoint("TOP", RaidInfoTitle, "BOTTOM", 0, -1)
    RaidInfoFrame:EnableMouse(true)
    RaidInfoFrame:SetMovable(true)
    RaidInfoFrame:SetBackdrop({bgFile = "Interface/Buttons/WHITE8X8", edgeFile = "Interface/Buttons/WHITE8X8", edgeSize = 1})
    RaidInfoFrame:SetBackdropColor(20/255, 20/255, 20/255, 1.0)
    RaidInfoFrame:SetBackdropBorderColor(0, 0, 0, 1.0)

    RaidInfoFrame:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed < 5 then return end
        self.elapsed = 0
        RLU:FetchRaidClasses()
        UpdateGrid()
    end)

    RaidInfoFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    RaidInfoFrame:SetScript("OnEvent", function(self)
        RLU:FetchRaidClasses()
        UpdateGrid()
    end)

    RaidInfoFrame:SetScript("OnHide", function(self)
        self:SetScript("OnUpdate", nil)
        isRIFShown = false
    end)

    local RaidInfoGrid = CreateFrame("Frame", nil, RaidInfoFrame)
    RaidInfoGrid:SetPoint("TOPLEFT", 3, -3)
    RaidInfoGrid:SetPoint("BOTTOMRIGHT", -3, 3)
    RaidInfoGrid:SetSize(1, 1)

    local CloseButton = CreateFrame("Button", "RaidInfoCloseButton", RaidInfoFrame, "BackdropTemplate")
    CloseButton:SetSize(24, 24)
    CloseButton:SetBackdrop({bgFile = "Interface/Buttons/WHITE8X8", edgeFile = "Interface/Buttons/WHITE8X8", edgeSize = 1})
    CloseButton:SetBackdropColor(255/255, 64/255, 64/255, 1.0)
    CloseButton:SetBackdropBorderColor(0, 0, 0, 1.0)
    CloseButton:SetPoint("BOTTOMRIGHT", RaidInfoFrame, "TOPRIGHT", 0, 1)
    CloseButton:SetScript("OnEnter", function(self) self:SetBackdropColor(255/255, 84/255, 84/255, 1.0) end)
    CloseButton:SetScript("OnLeave", function(self) self:SetBackdropColor(255/255, 64/255, 64/255, 1.0) end)
    CloseButton:SetScript("OnClick", function(self) RaidInfoTitle:Hide() RaidInfoFrame:Hide() end)

    local CloseButtonTexture = CloseButton:CreateTexture(nil, "ARTWORK")
    CloseButtonTexture:SetPoint("CENTER", CloseButton, "CENTER", 0, 0)
    CloseButtonTexture:SetAtlas("uitools-icon-close")
    CloseButtonTexture:SetSize(16,16)

    local RefreshButton = CreateFrame("Button", "RaidInfoRefreshButton", RaidInfoFrame, "BackdropTemplate")
    RefreshButton:SetSize(24, 24)
    RefreshButton:SetBackdrop({bgFile = "Interface/Buttons/WHITE8X8", edgeFile = "Interface/Buttons/WHITE8X8", edgeSize = 1})
    RefreshButton:SetBackdropColor(20/255, 20/255, 20/255, 1.0)
    RefreshButton:SetBackdropBorderColor(0, 0, 0, 1.0)
    RefreshButton:SetPoint("BOTTOMLEFT", RaidInfoFrame, "TOPLEFT", 0, 1)
    RefreshButton:SetScript("OnEnter", function(self) self:SetBackdropColor(40/255, 40/255, 40/255, 1.0) end)
    RefreshButton:SetScript("OnLeave", function(self) self:SetBackdropColor(20/255, 20/255, 20/255, 1.0) end)
    RefreshButton:SetScript("OnClick", function(self) RLU:FetchRaidClasses() UpdateGrid() end)

    local RefreshButtonTexture = RefreshButton:CreateTexture(nil, "ARTWORK")
    RefreshButtonTexture:SetAtlas("uitools-icon-refresh")
    RefreshButtonTexture:SetSize(16, 16)
    RefreshButtonTexture:SetPoint("CENTER", RefreshButton, "CENTER", 0, 0)

    function UpdateGrid()
        local maxColumns = 5
        local numUnits = 40
        local numRows = math.ceil(numUnits / maxColumns)

        RaidInfoGrid:SetSize(maxColumns * 100, numRows * 30)

        for _, child in ipairs({RaidInfoGrid:GetChildren()}) do
            child:Hide()
        end

        for j = 1, numUnits do
            local unitName, _, subGroup = GetRaidRosterInfo(j)
            if not unitName then break end
            local unitRole = UnitGroupRolesAssigned("raid" .. j)
            local hasFood, hasFlask, hasRune, hasVantus, hasSOM, hasStam, hasAP, hasInt, hasMOTW, hasBlessingofBronze, hasSoulstone = false, false, false, false, false, false, false, false, false, false, false
            local foodType, flaskType, vantusType, runeType, somSource, foodDuration, flaskDuration, somDuration, soulstoneSource = "|cFFFF4040No|r", "|cFFFF4040No|r", "|cFFFF4040No|r", "|cFFFF4040No|r", "|cFFFF4040No|r", 0, 0, 0, "|cFFFF4040No|r"

            for i = 1, 40 do
                local unitAura = C_UnitAuras.GetAuraDataByIndex(unitName, i, "HELPFUL")
                local spellID = unitAura and unitAura.spellId
                local sourceName = unitAura and unitAura.sourceUnit
                local auraDur = unitAura and unitAura.expirationTime - GetTime()
                if not spellID then break end
                if foodTypes[spellID] then
                    hasFood = true
                    foodType = foodTypes[spellID]
                    foodDuration = math.ceil(auraDur / 60)
                end
                if flaskTypes[spellID] then
                    hasFlask = true
                    flaskType = flaskTypes[spellID]
                    flaskDuration = math.ceil(auraDur / 60)
                end
                if unitAura and unitAura.name and unitAura.name:match("Vantus Rune") then
                    hasVantus = true
                    vantusType = unitAura.name
                end
                if runeTypes[spellID] then
                    hasRune = true
                    runeType = runeTypes[spellID]
                end
                if spellID == 369459 then
                    hasSOM = true
                    somSource = sourceName or "|cFFFF4040No|r"
                    somDuration = math.ceil(auraDur / 60) 
                end
                if spellID == 21562 then 
                    hasStam = true
                end
                if spellID == 1126 then
                    hasMOTW = true
                end
                if unitAura and unitAura.name and unitAura.name:match("Blessing of the Bronze") then
                    hasBlessingofBronze = true
                end
                if spellID == 6673 then
                    hasAP = true
                end
                if spellID == 1459 then
                    hasInt = true
                end
                if spellID == 20707 then
                    hasSoulstone = true
                    soulstoneSource = sourceName or "|cFFFF4040No|r"
                end
            end

            local unitFrame = CreateFrame("Frame", nil, RaidInfoGrid, "BackdropTemplate")
            unitFrame:SetSize(100, 30)
            unitFrame:SetPoint("TOPLEFT", ((j - 1) % maxColumns) * 101, -math.floor((j - 1) / maxColumns) * 31)
            unitFrame:SetBackdrop({bgFile = "Interface/Buttons/WHITE8X8", edgeFile = "Interface/Buttons/WHITE8X8", edgeSize = 1})
            unitFrame:SetBackdropColor(50 / 255, 50 / 255, 50 / 255, 1.0)
            unitFrame:SetBackdropBorderColor(0, 0, 0, 1.0)
            local isFullyBuffed = hasFood and hasFlask

            if hasWarrior then
                isFullyBuffed = isFullyBuffed and hasAP
            end

            if hasDruid then
                isFullyBuffed = isFullyBuffed and hasMOTW
            end

            if hasPriest then
                isFullyBuffed = isFullyBuffed and hasStam
            end

            if hasMage then
                isFullyBuffed = isFullyBuffed and hasInt
            end

            if hasEvoker then
                isFullyBuffed = isFullyBuffed and hasBlessingofBronze
            end

            if not isFullyBuffed then
                unitFrame:SetBackdropColor(255 / 255, 128 / 255, 128 / 255, 0.5)
            end

            local unitText = unitFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            unitText:SetPoint("CENTER", 0, 0)
            unitText:SetFont("Fonts/FRIZQT__.ttf", 12, "OUTLINE")
            unitText:SetShadowColor(0, 0, 0, 0.0)
            unitText:SetText(RLU:ClassColourName(unitName))

            local soulstoneTexture = unitFrame:CreateTexture(nil, "OVERLAY")
            soulstoneTexture:SetSize(14, 14)
            soulstoneTexture:SetPoint("TOPRIGHT", unitFrame, "TOPRIGHT", -1, -1)
            soulstoneTexture:SetTexture("Interface\\Icons\\spell_shadow_soulgem")
            soulstoneTexture:Hide()

            local somTexture = unitFrame:CreateTexture(nil, "OVERLAY")
            somTexture:SetSize(14, 14)
            somTexture:SetPoint("TOPRIGHT", unitFrame, "TOPRIGHT", -1, -15)
            somTexture:SetTexture("Interface\\Icons\\ability_evoker_blue_01")
            somTexture:Hide()

            if unitRole == "HEALER" then
                if hasEvoker then
                    somTexture:Show()
                    if hasSOM then
                        somTexture:SetDesaturated(false)
                    else
                        somTexture:SetDesaturated(true)
                    end
                end
                if hasWarlock then
                    soulstoneTexture:Show()
                    if hasSoulstone then
                        soulstoneTexture:SetDesaturated(false)
                    else 
                        soulstoneTexture:SetDesaturated(true)
                    end
                end
            end

            unitFrame:SetScript("OnEnter", function(self)
                unitFrame:SetBackdropColor(100 / 255, 100 / 255, 100 / 255, 1.0)
                GameTooltip:SetOwner(RaidInfoFrame, "ANCHOR_NONE", 0, 0)
                GameTooltip:SetPoint("TOPLEFT", RaidInfoFrame, "TOPRIGHT", 1, 0)
                GameTooltip:AddLine("|cFF8080FFPersonal Buffs|r")
                GameTooltip:AddLine("|cFFFFFFFFName|r: " .. RLU:ClassColourName(unitName))
                GameTooltip:AddLine("|cFFFFFFFFGroup|r: " .. subGroup)
                if foodDuration > 0 then
                    GameTooltip:AddLine("|cFFFFFFFFFood|r: " .. foodType .. " [" .. foodDuration .. "m]") 
                else
                    GameTooltip:AddLine("|cFFFFFFFFFood|r: " .. foodType)
                end
                if flaskDuration > 0 then
                    GameTooltip:AddLine("|cFFFFFFFFFlask|r: " .. flaskType .. " [" .. flaskDuration .. "m]")
                else
                    GameTooltip:AddLine("|cFFFFFFFFFlask|r: " .. flaskType)
                end
                GameTooltip:AddLine("|cFFFFFFFFVantus|r: " .. vantusType:gsub("Vantus Rune: ", ""))
                GameTooltip:AddLine("|cFFFFFFFFRune|r: " .. runeType)
                if hasWarrior or hasMage or hasPriest or hasEvoker or hasDruid then
                    GameTooltip:AddLine("|cFF8080FFRaid Buffs|r")
                end
                if hasWarrior then 
                    GameTooltip:AddLine("|cFFC69B6DBattle Shout:|r" .. (hasAP and " |cFF40FF40Yes|r" or " |cFFFF4040No|r"))
                end
                if hasDruid then
                    GameTooltip:AddLine("|cFFFF7C0AMark of the Wild:|r" .. (hasMOTW and " |cFF40FF40Yes|r" or " |cFFFF4040No|r"))
                end
                if hasPriest then
                    GameTooltip:AddLine("|cFFFFFFFFPower Word: Fortitude:|r" .. (hasStam and " |cFF40FF40Yes|r" or " |cFFFF4040No|r"))
                end
                if hasMage then
                    GameTooltip:AddLine("|cFF3FC7EBArcane Intellect:|r" .. (hasInt and " |cFF40FF40Yes|r" or " |cFFFF4040No|r"))
                end
                if hasEvoker then
                    GameTooltip:AddLine("|cFF33937FBlessing of Bronze:|r" .. (hasBlessingofBronze and " |cFF40FF40Yes|r" or " |cFFFF4040No|r"))
                end
                if unitRole == "HEALER" then
                    if hasEvoker then
                        GameTooltip:AddLine("|cFF33937FSource of Magic|r: " .. (hasSOM and RLU:ClassColourName(somSource) .. " [" .. somDuration .. "m]" or "|cFFFF4040No|r"))
                    end
                    if hasWarlock then
                        GameTooltip:AddLine("|cFF8788EESoulstone|r: " .. (hasSoulstone and RLU:ClassColourName(soulstoneSource) or "|cFFFF4040No|r"))
                    end
                end

                GameTooltip:Show()
            end)

            unitFrame:SetScript("OnLeave", function(self)
                if not isFullyBuffed then
                    unitFrame:SetBackdropColor(255 / 255, 128 / 255, 128 / 255, 0.5)
                else
                    unitFrame:SetBackdropColor(50 / 255, 50 / 255, 50 / 255, 1.0)
                end
                GameTooltip:Hide()
            end)
        end
    end

    RLU:FetchRaidClasses()
    UpdateGrid()
end

function RLU:SetupReadyCheck()
    if not ReadyCheckButton then
        ReadyCheckButton = CreateFrame("Button", "ReadyCheckButton", UIParent, "UIPanelButtonTemplate")
        ReadyCheckButton:SetSize(BUTTON_SIZE[1], BUTTON_SIZE[2])
        ReadyCheckButton:SetText("|cFFFFFFFFReady Check|r")
        if USER_OPTIONS.ANCHOR_POSITION == 1 then 
            ReadyCheckButton:SetPoint("TOP", UIParent, "TOP", 0, -1)
        elseif USER_OPTIONS.ANCHOR_POSITION == 2 then
            ReadyCheckButton:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 1)
        elseif USER_OPTIONS.ANCHOR_POSITION == 3 then
            ReadyCheckButton:SetPoint("LEFT", UIParent, "LEFT", 1, 0)
        elseif USER_OPTIONS.ANCHOR_POSITION == 4 then
            ReadyCheckButton:SetPoint("RIGHT", UIParent, "RIGHT", -1, 0)
        end
        ReadyCheckButton:SetAlpha(0.5)
    end

    ReadyCheckButton:SetScript("OnMouseDown", function(self, btn)
        if InCombatLockdown() then return end
        if btn == "RightButton" then
            if isRIFShown then return else CreateRaidInfoFrame() end
        elseif btn == "LeftButton" then
            DoReadyCheck()
        elseif btn == "MiddleButton" then
            if InCombatLockdown() then return end
            local EB = ChatEdit_ChooseBoxForSend()
            ChatEdit_ActivateChat(EB)
            EB:SetText("/rt inv")
            ChatEdit_OnEnterPressed(EB)
        end
    end)

    ReadyCheckButton:SetScript("OnEnter", function(self)
        ReadyCheckButton:SetAlpha(1.0)
        GameTooltip:SetOwner(self, "ANCHOR_NONE", 0, 0)
        if USER_OPTIONS.ANCHOR_POSITION == 1 then
            GameTooltip:SetPoint("TOP", ReadyCheckButton, "BOTTOM", 0, -1)
        elseif USER_OPTIONS.ANCHOR_POSITION == 2 then
            GameTooltip:SetPoint("BOTTOM", ReadyCheckButton, "TOP", 0, 1)
        elseif USER_OPTIONS.ANCHOR_POSITION == 3 then
            GameTooltip:SetPoint("LEFT", ReadyCheckButton, "RIGHT", 1, 0)
        elseif USER_OPTIONS.ANCHOR_POSITION == 4 then
            GameTooltip:SetPoint("RIGHT", ReadyCheckButton, "LEFT", -1, 0)
        end
        GameTooltip:AddLine("|cFF8080FFRight-Click|r: Raid Information")
        GameTooltip:AddLine("|cFF8080FFMiddle-Click|r: Invite Raid Team")
        GameTooltip:Show()
    end)

    ReadyCheckButton:SetScript("OnLeave", function(self)
        ReadyCheckButton:SetAlpha(0.5)
        GameTooltip:Hide()
    end)

    return ReadyCheckButton
end

function RLU:SetupPullTimer()
    if not PullTimerButton then
        PullTimerButton = CreateFrame("Button", "PullTimerButton", UIParent, "UIPanelButtonTemplate")
        PullTimerButton:SetSize(BUTTON_SIZE[1], BUTTON_SIZE[2])
        PullTimerButton:SetText("|cFFFFFFFFPull|r")
        if USER_OPTIONS.ANCHOR_POSITION == 1 or USER_OPTIONS.ANCHOR_POSITION == 2 then 
            PullTimerButton:SetPoint("LEFT", ReadyCheckButton, "RIGHT", 1, 0)
        elseif USER_OPTIONS.ANCHOR_POSITION == 3 or USER_OPTIONS.ANCHOR_POSITION == 4 then
            PullTimerButton:SetPoint("TOP", ReadyCheckButton, "BOTTOM", 0, -1)
        end
        PullTimerButton:SetAlpha(0.5)
    end

    PullTimerButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_NONE", 0, 0)
        if USER_OPTIONS.ANCHOR_POSITION == 1 then
            GameTooltip:SetPoint("TOP", PullTimerButton, "BOTTOM", 0, -1)
        elseif USER_OPTIONS.ANCHOR_POSITION == 2 then
            GameTooltip:SetPoint("BOTTOM", PullTimerButton, "TOP", 0, 1)
        elseif USER_OPTIONS.ANCHOR_POSITION == 3 then
            GameTooltip:SetPoint("LEFT", PullTimerButton, "RIGHT", 1, 0)
        elseif USER_OPTIONS.ANCHOR_POSITION == 4 then
            GameTooltip:SetPoint("RIGHT", PullTimerButton, "LEFT", -1, 0)
        end
        GameTooltip:AddLine("|cFF8080FFLeft-Click|r: 10s")
        GameTooltip:AddLine("|cFF8080FFRight-Click|r: 20s")
        GameTooltip:AddLine("|cFF8080FFMiddle-Click|r: |cFFFF4040Cancel|r")
        PullTimerButton:SetAlpha(1.0)
        GameTooltip:Show()
    end)

    PullTimerButton:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
        self:SetAlpha(0.5)
    end)

    PullTimerButton:SetScript("OnMouseDown", function(self, btn)
        if InCombatLockdown() then return end
        local EB = ChatEdit_ChooseBoxForSend()
        ChatEdit_ActivateChat(EB)
        if btn == "LeftButton" then
            EB:SetText("/pull 10")
        elseif btn == "RightButton" then
            EB:SetText("/pull 20")
        elseif btn == "MiddleButton" then
            EB:SetText("/pull 0")
        end
        ChatEdit_OnEnterPressed(EB)
    end)

    return PullTimerButton
end