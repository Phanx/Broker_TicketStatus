--[[--------------------------------------------------------------------
	Broker: Ticket Status
	DataBroker plugin to monitor the status of your GM ticket.
	Copyright (c) 2012 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info-BrokerTicketStatus.html
	http://www.curse.com/addons/wow/broker-ticketstatus
----------------------------------------------------------------------]]

local L = {}
do
	local LOCALE = GetLocale()
	if LOCALE == "deDE" then
		--------------------------------------------------------
		--	Deutsch
		--	Last updated 2012-07-04 by Phanx
		--------------------------------------------------------
		L["Ticket Status"] = "Ticketstatus"
		L["Response!"] = "Antwort!"
		L["You have received a GM ticket response!"] = "Sie haben eine Antwort auf Ihr Ticket erhalten."
		L["Survey!"] = "Umfrage!"
		L["Click to open a new ticket."] = "Linksklick um ein Ticket eröffnen."
		L["Right-click for options."] = "Rechtsklick für Optionen."
		L["Show text without ticket"] = "Text ohne offenes Ticket anzeigen"
		L["Show status change alerts"] = "Statusänderungsbenachrichtigungen zeigen"
		L["Alert color"] = "Benachrichtigungenfarbe"

	elseif LOCALE == "esES" or LOCALE == "esMX" then
		--------------------------------------------------------
		--	Español
		--	Last updated 2012-07-04 by Phanx
		--------------------------------------------------------
		L["Ticket Status"] = "Estado consulta"
		L["Response!"] = "Respuesta!"
		L["You have received a GM ticket response!"] = "Has recibido una respuesta a tu consulta."
		L["Survey!"] = "Encuesta!"
		L["Click to open a new ticket."] = "Haz clic para abrir una consulta,"
		L["Right-click for options."] = "Haz clic derecho para obtener opciones."
		L["Show text without ticket"] = "Mostrar texto sin consulta abierta"
		L["Show status change alerts"] = "Mostrar alertas para cambios de estado"
		L["Alert color"] = "Color de alertas"

	elseif LOCALE == "frFR" then
		--------------------------------------------------------
		--	Français
		--	Last updated YYYY-MM-DD by NAME
		--------------------------------------------------------
	--	L["Ticket Status"] = ""
	--	L["Response!"] = ""
	--	L["You have received a GM ticket response!"] = ""
	--	L["Survey!"] = ""
	--	L["Click to open a new ticket."] = ""
	--	L["Right-click for options."] = ""
	--	L["Show text without ticket"] = ""
	--	L["Show status change alerts"] = ""
	--	L["Alert color"] = ""

	elseif LOCALE == "itIT" then
		--------------------------------------------------------
		--	Italiano
		--	Last updated YYYY-MM-DD by NAME
		--------------------------------------------------------
	--	L["Ticket Status"] = ""
	--	L["Response!"] = ""
	--	L["You have received a GM ticket response!"] = ""
	--	L["Survey!"] = ""
	--	L["Click to open a new ticket."] = ""
	--	L["Right-click for options."] = ""
	--	L["Show text without ticket"] = ""
	--	L["Show status change alerts"] = ""
	--	L["Alert color"] = ""

	elseif LOCALE == "ptBR" then
		--------------------------------------------------------
		--	Português (Brasil)
		--	Last updated YYYY-MM-DD by NAME
		--------------------------------------------------------
		L["Ticket Status"] = "Estado de consulta"
		L["Response!"] = "Reposta!"
		L["You have received a GM ticket response!"] = "A sua consulta foi respondida!"
		L["Survey!"] = "Pesquisa!"
		L["Click to open a new ticket."] = "Clique para abrir uma nova consulta."
		L["Right-click for options."] = "Clique com o botão direito para opções."
		L["Show text without ticket"] = "Texto quando não há consultar"
		L["Show status change alerts"] = "Alertas de mudanças de estado da consulta"
		L["Alert color"] = "Cor de alertas"

	elseif LOCALE == "ruRU" then
		--------------------------------------------------------
		--	Русский
		--	Last updated YYYY-MM-DD by NAME
		--------------------------------------------------------
	--	L["Ticket Status"] = ""
	--	L["Response!"] = ""
	--	L["You have received a GM ticket response!"] = ""
	--	L["Survey!"] = ""
	--	L["Click to open a new ticket."] = ""
	--	L["Right-click for options."] = ""
	--	L["Show text without ticket"] = ""
	--	L["Show status change alerts"] = ""
	--	L["Alert color"] = ""

	elseif LOCALE == "koKR" then
		--------------------------------------------------------
		--	한국어
		--	Last updated YYYY-MM-DD by NAME
		--------------------------------------------------------
	--	L["Ticket Status"] = ""
	--	L["Response!"] = ""
	--	L["You have received a GM ticket response!"] = ""
	--	L["Survey!"] = ""
	--	L["Click to open a new ticket."] = ""
	--	L["Right-click for options."] = ""
	--	L["Show text without ticket"] = ""
	--	L["Show status change alerts"] = ""
	--	L["Alert color"] = ""

	elseif LOCALE == "zhCN" then
		--------------------------------------------------------
		--	简体中文
		--	Last updated YYYY-MM-DD by NAME
		--------------------------------------------------------
	--	L["Ticket Status"] = ""
	--	L["Response!"] = ""
	--	L["You have received a GM ticket response!"] = ""
	--	L["Survey!"] = ""
	--	L["Click to open a new ticket."] = ""
	--	L["Right-click for options."] = ""
	--	L["Show text without ticket"] = ""
	--	L["Show status change alerts"] = ""
	--	L["Alert color"] = ""

	elseif LOCALE == "zhTW" then
		--------------------------------------------------------
		--	繁體中文
		--	Last updated YYYY-MM-DD by NAME
		--------------------------------------------------------
	--	L["Ticket Status"] = ""
	--	L["Response!"] = ""
	--	L["You have received a GM ticket response!"] = ""
	--	L["Survey!"] = ""
	--	L["Click to open a new ticket."] = ""
	--	L["Right-click for options."] = ""
	--	L["Show text without ticket"] = ""
	--	L["Show status change alerts"] = ""
	--	L["Alert color"] = ""
	end
	setmetatable(L, { __index = function(t, k)
		local v = tostring(k)
		rawset(t, k, v)
		return v
	end })
end

------------------------------------------------------------------------

local db

local ticketQueueActive
local haveTicket, haveResponse, haveGMSurvey
local ticketTimer

local lastAlert
local lastAlertTime = 0

local refreshTime = 0

local BrokerTicketStatus = CreateFrame("Frame")
BrokerTicketStatus:SetScript("OnEvent", function(self, event, ...) return self[event] and self[event](self, ...) end)
BrokerTicketStatus:RegisterEvent("ADDON_LOADED")

------------------------------------------------------------------------

function BrokerTicketStatus:ADDON_LOADED(addon)
	if addon ~= "Broker_TicketStatus" then return end
	-- print("ADDON_LOADED", addon)

	local defaults = {
		alert = true,
		alertColor = { r = 0.25, g = 0.8, b = 1 },
		textNoTicket = true,
	}
	local function initDB(defaults, db)
		if type(defaults) ~= "table" then return {} end
		if type(db) ~= "table" then db = {} end
		for k, v in pairs(defaults) do
			if type(v) == "table" then
				db[k] = initDB(v, db[k])
			elseif type(v) ~= type(db[k]) then
				db[k] = v
			end
		end
		return db
	end
	db = initDB(defaults, BrokerTicketStatusDB)
	BrokerTicketStatusDB = db

	self:UnregisterEvent("ADDON_LOADED")
	self.ADDON_LOADED = nil

	if IsLoggedIn() then
		self:PLAYER_LOGIN()
	else
		self:RegisterEvent("PLAYER_LOGIN")
	end
end

function BrokerTicketStatus:PLAYER_LOGIN()
	-- print("PLAYER_LOGIN")

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("GMRESPONSE_RECEIVED")
	self:RegisterEvent("GMSURVEY_DISPLAY")
	self:RegisterEvent("UPDATE_GM_STATUS")
	self:RegisterEvent("UPDATE_TICKET")

	self:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil

	TicketStatusFrame:HookScript("OnShow", TicketStatusFrame.Hide)
	TicketStatusFrame:Hide()

	GetGMStatus()
end

function BrokerTicketStatus:PLAYER_ENTERING_WORLD()
	-- print("PLAYER_ENTERING_WORLD")
	GetGMTicket()
end

function BrokerTicketStatus:UPDATE_TICKET(category, ticketText, ticketOpenTime, oldestTicketTime, updateTime, assignedToGM, openedByGM, waitTimeOverrideMessage, waitTimeOverrideMinutes)
	-- print("UPDATE_TICKET")
--[[
	if category then
		-- print("  [1] category:", category)
		-- print("  [2] ticketText:", ticketText or "nil")
		-- print("  [3] ticketOpenTime:", ticketOpenTime or "nil")
		-- print("  [4] oldestTicketTime:", oldestTicketTime or "nil")
		-- print("  [5] updateTime:", updateTime or "nil")
		-- print("  [6] assignedToGM:", assignedToGM or "nil")
		-- print("  [7] openedByGM:", openedByGM or "nil")
		-- print("  [8] waitTimeOverrideMessage:", waitTimeOverrideMessage or "nil")
		-- print("  [9] waitTimeOverrideMinutes:", waitTimeOverrideMinutes or "nil")
	end
]]
	if (category or hasGMSurvey) and not (GMChatStatusFrame and GMChatStatusFrame:IsShown()) then
		-- You have an open ticket.
		self.titleText = TICKET_STATUS

		ticketTimer = nil
		if openedByGM == GMTICKET_OPENEDBYGM_STATUS_OPENED then
			-- Ticket has been opened by a GM then
			if assignedToGM == GMTICKET_ASSIGNEDTOGM_STATUS_ESCALATED then
				-- Your ticket has been escalated.
				self.statusText = GM_TICKET_ESCALATED
			else
				-- Your ticket will be serviced soon.
				self.statusText = GM_TICKET_SERVICE_SOON
			end
		else
			local estimatedWaitTime = oldestTicketTime - ticketOpenTime
			if estimatedWaitTime < 0 then
				estimatedWaitTime = 0
			end
			if #waitTimeOverrideMessage > 0 then
				if waitTimeOverrideMinutes then
					self.statusText = format(waitTimeOverrideMessage, SecondsToTime(waitTimeOverrideMinutes * 60, 1))
				else
					self.statusText = waitTimeOverrideMessage
				end
				estimatedWaitTime = waitTimeOverrideMinutes * 60
			elseif oldestticketTime < 0 or updateTime < 0 or updateTime > 3600 then
				-- Wait time currently unavailable.
				self.statusText = GM_TICKET_UNAVAILABLE
			elseif estimatedWaitTime > 7200 then
				-- We are currently experiencing a high volume of petitions.
				self.statusText = GM_TICKET_HIGH_VOLUME
			elseif estimatedWaitTime > 300 then
				-- Average ticket wait time: %s
				self.statusText = format(gsub(GM_TICKET_WAIT_TIME, "\n", ""), SecondsToTime(estimatedWaitTime, 1))
			else
				-- Your ticket will be serviced soon.
				self.statusText = GM_TICKET_SERVICE_SOON
			end
		end

		haveTicket = true
		haveResponse = false

		self.dataObject.text = self.titleText
	else
		-- The player does not have a ticket.
		haveTicket = false
		haveResponse = false
		ticketTimer = nil

		-- Open a Ticket
		self.titleText = HELP_TICKET_OPEN
		self.statusText = nil

		self.dataObject.text = db.textNoTicket and self.titleText or ""
	end
end

function BrokerTicketStatus:UPDATE_GM_STATUS(status)
	-- print("UPDATE_GM_STATUS")
	-- print("  [1] status:", status or "nil")
	if status == GMTICKET_QUEUE_STATUS_ENABLED then
		ticketQueueActive = true
	else
		ticketQueueActive = nil
		if status == GMTICKET_QUEUE_STATUS_DISABLED then
			-- "GM Help Tickets are currently unavailable."
			-- HELP_TICKET_QUEUE_DISABLED
		end
	end
end

function BrokerTicketStatus:GMRESPONSE_RECEIVED(ticketText, responseText)
	-- print("GMRESPONSE_RECEIVED")
	-- print("  [1] ticketText:", ticketText or "nil")
	-- print("  [2] responseText:", responseText or "nil")

	haveResponse = true
	haveTicket = nil

	-- "You have received a ticket response. Click here to read it."
	self.titleText = L["Response!"]
	self.statusText = GM_RESPONSE_ALERT

	if db.alert and (lastAlert ~= "GMRESPONSE_RECEIVED" or GetTime() - lastAlertTime > 10) then
		RaidNotice_AddMessage(RaidWarningFrame, L["You have received a GM ticket response!"], db.alertColor)
		lastAlert, lastAlertTime = "GMRESPONSE_RECEIVED", GetTime()
	end

	self.dataObject.text = self.titleText
end

function BrokerTicketStatus:GMSURVEY_DISPLAY(...)
	-- print("GMSURVEY_DISPLAY", ...)

	haveGMSurvey = true
	haveResponse = nil
	haveTicket = nil

	-- You have been chosen to fill out a GM survey.
	self.titleText = L["Survey!"]
	self.statusText = CHOSEN_FOR_GMSURVEY

	if db.alert and (lastAlert ~= "GMSURVEY_DISPLAY" or GetTime() - lastAlertTime > 10)  then
		RaidNotice_AddMessage(RaidWarningFrame, CHOSEN_FOR_GMSURVEY, db.alertColor)
		lastAlert, lastAlertTime = "GMSURVEY_DISPLAY", GetTime()
	end

	self.dataObject.text = self.titleText
end

function BrokerTicketStatus:OnUpdate(elapsed)
	refreshTime = refreshTime - elapsed
	if refreshTime <= 0 then
		refreshTime = 300 -- GMTICKET_CHECK_INTERVAL -- 600
		GetGMTicket()
	end

	GameTooltip:SetText(L["Ticket Status"])
	GameTooltip:AddLine(self.titleText, 1, 1, 1)
	if self.statusText then
		GameTooltip:AddLine(self.statusText, 1, 1, 1)
	end
	if ticketTimer then
		ticketTimer = ticketTimer - elapsed
		local waitTime = format(gsub(GM_TICKET_WAIT_TIME, "\\n", " "), SecondsToTime(ticketTimer, 1))
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(waitTime, 1, 1, 1)
	end
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(HELPFRAME_TICKET_CLICK_HELP, 0.8, 0.8, 0.8)
	GameTooltip:AddLine(L["Right-click for options."], 0.8, 0.8, 0.8)
	GameTooltip:Show()
end

BrokerTicketStatus.dataObject = LibStub("LibDataBroker-1.1"):NewDataObject("TicketStatus", {
	type = "data source",
	icon = "Interface\\HelpFrame\\HelpIcon-OpenTicket",
	name = L["Ticket Status"],
	text = HELP_TICKET_OPEN, -- Open a Ticket
	OnEnter = function(self)
		-- print("OnEnter")
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:ClearAllPoints()
		local cx, cy = self:GetCenter()
		if cy < GetScreenHeight() / 2 then
			GameTooltip:SetPoint("BOTTOM", self, "TOP", dx, dy)
		else
			GameTooltip:SetPoint("TOP", self, "BOTTOM", dx, dy)
		end

		if haveTicket then
			BrokerTicketStatus:SetScript("OnUpdate", BrokerTicketStatus.OnUpdate)
		else
			GameTooltip:SetText(L["Ticket Status"])
			if haveResponse then
				GameTooltip:AddLine(GM_RESPONSE_ALERT, 1, 1, 1)
			elseif haveGMSurvey then
				GameTooltip:AddLine(CHOSEN_FOR_GMSURVEY, 1, 1, 1)
			elseif ticketQueueActive then
				GameTooltip:AddLine(L["Click to open a new ticket."], 1, 1, 1)
			else
				GameTooltip:AddLine(HELP_TICKET_QUEUE_DISABLED, 1, 0.6, 0.6)
			end
			GameTooltip:AddLine(L["Right-click for options."], 0.6, 0.6, 0.6)
			GameTooltip:Show()
		end
	end,
	OnLeave = function(dataObject)
		-- print("OnLeave")
		BrokerTicketStatus:SetScript("OnUpdate", nil)
		GameTooltip:Hide()
	end,
	OnClick = function(dataObject, button)
		-- print("OnClick", button)
		if button == "RightButton" then
			ToggleDropDownMenu(nil, nil, BrokerTicketStatusMenu, dataObject, 0, 0, nil, nil, 10)
		elseif not ticketQueueActive then
			return
		elseif haveTicket and button == "MiddleButton" then
			StaticPopup_Show("HELP_TICKET_ABANDON_CONFIRM")
		else
			if haveGMSurvey then
				GMSurveyFrame_LoadUI()
				ShowUIPanel(GMSurveyFrame)
				----------------------------------------------------
				-- This is kind of a hack, and I don't like it,
				-- but I can't think of a better solution right now,
				-- since GMSURVEY_DISPLAY doesn't fire again once
				-- the survey is no longer available. :(
				----------------------------------------------------
				if not BrokerTicketStatus.hookedGMSurveyFrame then
					GMSurveyFrame:HookScript("OnHide", function()
						haveGMSurvey = nil
						BrokerTicketStatus:UPDATE_TICKET()
					end)
					BrokerTicketStatus.hookedGMSurveyFrame = true
				end
			elseif StaticPopup_Visible("HELP_TICKET_ABANDON_CONFIRM") then
				StaticPopup_Hide("HELP_TICKET_ABANDON_CONFIRM")
			elseif StaticPopup_Visible("HELP_TICKET") then
				StaticPopup_Hide("HELP_TICKET")
			elseif StaticPopup_Visible("GM_RESPONSE_NEED_MORE_HELP") then
				StaticPopup_Hide("GM_RESPONSE_NEED_MORE_HELP")
			elseif StaticPopup_Visible("GM_RESPONSE_RESOLVE_CONFIRM") then
				StaticPopup_Hide("GM_RESPONSE_RESOLVE_CONFIRM")
			elseif StaticPopup_Visible("GM_RESPONSE_CANT_OPEN_TICKET") then
				StaticPopup_Hide("GM_RESPONSE_CANT_OPEN_TICKET")
			elseif haveResponse then
				HelpFrame_SetFrameByKey(HELPFRAME_OPEN_TICKET)
				if not HelpFrame:IsShown() then
					ShowUIPanel(HelpFrame)
				end
			else
				HelpFrame_SetFrameByKey(HELPFRAME_SUBMIT_TICKET)
				if not HelpFrame:IsShown() then
					ShowUIPanel(HelpFrame)
				end
			end
		end
	end,
})

------------------------------------------------------------------------

do
	local menu = CreateFrame("Frame", "BrokerTicketStatusMenu", nil, "UIDropDownMenuTemplate")
	menu.displayMode = "MENU"

	local textNoTicket_func = function()
		local show = not BrokerTicketStatusDB.textNoTicket
		BrokerTicketStatusDB.textNoTicket = show

		local obj = BrokerTicketStatus.dataObject
		if obj.text == HELP_TICKET_OPEN and not show then
			obj.text = ""
		elseif show and obj.text == "" then
			obj.text = HELP_TICKET_OPEN
		end
	end
	local textNoTicket_checked = function()
		return BrokerTicketStatusDB.textNoTicket
	end

	local alert_func = function()
		BrokerTicketStatusDB.alert = not BrokerTicketStatusDB.alert
	end
	local alert_checked = function()
		return BrokerTicketStatusDB.alert
	end

	local alertColor_swatchFunc = function()
		BrokerTicketStatusDB.alertColor.r, BrokerTicketStatusDB.alertColor.g, BrokerTicketStatusDB.alertColor.b = ColorPickerFrame:GetColorRGB()
	end
	local alertColor_cancelFunc = function(previous)
		if type(previous) == "table" and previous.r then
			BrokerTicketStatusDB.alertColor.r, BrokerTicketStatusDB.alertColor.g, BrokerTicketStatusDB.alertColor.b = previous.r, previous.g, previous.b
		end
	end

	local close_func = function()
		return CloseDropDownMenus()
	end

	local info = {}
	menu.initialize = function(menu, level)
		if not level then return end
		local info = wipe(info)

		info.text = L["Ticket Status"]
		info.isTitle = 1
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info, level)

		info.isTitle = nil

		info.text = " "
		info.disabled = 1
		info.notCheckable = 1
		UIDropDownMenu_AddButton(info, level)

		info.disabled = nil
		info.notCheckable = nil

		info.keepShownOnClick = 1

		info.text = L["Show text without ticket"]
		info.func = textNoTicket_func
		info.checked = textNoTicket_checked
		UIDropDownMenu_AddButton(info, level)

		info.text = L["Show status change alerts"]
		info.func = alert_func
		info.checked = alert_checked
		UIDropDownMenu_AddButton(info, level)

		info.checked = nil
		info.notCheckable = 1

		info.text = L["Alert color"]
		info.func = UIDropDownMenuButton_OpenColorPicker
		info.hasColorSwatch = true
		info.swatchFunc = alertColor_swatchFunc
		info.cancelFunc = alertColor_cancelFunc
		info.r = BrokerTicketStatusDB.alertColor.r
		info.g = BrokerTicketStatusDB.alertColor.g
		info.b = BrokerTicketStatusDB.alertColor.b
		UIDropDownMenu_AddButton(info, level)

		info.func = nil
		info.hasColorSwatch = nil
		info.swatchFunc = nil
		info.cancelFunc = nil
		info.r, info.g, info.b = nil, nil, nil

		info.text = " "
		info.disabled = 1
		UIDropDownMenu_AddButton(info, level)

		info.disabled = nil
		info.keepShownOnClick = nil

		info.text = CLOSE
		info.func = close_func
		UIDropDownMenu_AddButton(info, level)
	end

	BrokerTicketStatus.menu = menu
end