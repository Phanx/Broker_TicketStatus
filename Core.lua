--[[--------------------------------------------------------------------
	Broker_LFG
	GM ticket status monitor for your DataBroker display.
	Written by Phanx <addons@phanx.net>
	See the accompanying README file for more information.
	http://www.wowinterface.com/downloads/info20888-BrokerTicketStatus
	http://www.curse.com/addons/wow/broker-ticketstatus
----------------------------------------------------------------------]]

local L = {
	["Open a ticket"] = gsub(HELP_TICKET_OPEN, "|n", " "), -- deDE includes a line break -_-
}
do
	local LOCALE = GetLocale()
	if LOCALE == "deDE" then
		--------------------------------------------------------
		--	Deutsch
		--	Last updated 2014-01-27 by Phanx
		--------------------------------------------------------
		L["Ticket Status"] = "Ticketstatus"
		L["Open"] = "Offene"
		L["Needs more info!"] = "Mehr Info benötigt!"
		L["Response!"] = "Antwort!"
		L["Survey!"] = "Umfrage!"
		L["Click to open a new ticket."] = "Linksklick, um ein Ticket eröffnen."
		L["Click to edit your ticket."] = "Linksklick, um Ihr Ticket bearbeiten."
		L["Middle-click to abandon your ticket."] = "Mittellick, um Ihr Ticket verlassen."
		L["Right-click for options."] = "Rechtsklick für Optionen."
		L["Show text without ticket"] = "Text ohne offenes Ticket"
		L["Show status change alerts"] = "Statusänderungsbekanntmachungen"
		L["Alert color"] = "Bekanntmachungsfarbe"

	elseif LOCALE == "esES" or LOCALE == "esMX" then
		--------------------------------------------------------
		--	Español
		--	Last updated 2014-01-27 by Phanx
		--------------------------------------------------------
		L["Ticket Status"] = "Estado de consulta"
		L["Open"] = "Abierta"
		L["Needs more info!"] = "Requiere más info!"
		L["Response!"] = "¡Respuesta!"
		L["Survey!"] = "¡Encuesta!"
		L["Click to open a new ticket."] = "Clic para abrir una nueva consulta."
		L["Click to edit your ticket."] = "Clic para editar tu consulta."
		L["Middle-click to abandon your ticket."] = "Clic medio para abandonar tu consulta."
		L["Right-click for options."] = "Clic derecho para opciones."
		L["Show text without ticket"] = "Texto sin consulta abierta"
		L["Show status change alerts"] = "Avisos para cambios de estado"
		L["Alert color"] = "Color de avisos"

	elseif LOCALE == "frFR" then
		--------------------------------------------------------
		--	Français
		--	Last updated YYYY-MM-DD by NAME
		--------------------------------------------------------
		--L["Ticket Status"] = ""
		--L["Open"] = ""
		--L["Needs more info!"] = ""
		--L["Response!"] = ""
		--L["Survey!"] = ""
		--L["Click to open a new ticket."] = ""
		--L["Click to edit your ticket."] = ""
		--L["Middle-click to abandon your ticket."] = ""
		--L["Right-click for options."] = ""
		--L["Show text without ticket"] = ""
		--L["Show status change alerts"] = ""
		--L["Alert color"] = ""

	elseif LOCALE == "itIT" then
		--------------------------------------------------------
		--	Italiano
		--	Last updated YYYY-MM-DD by NAME
		--------------------------------------------------------
		--L["Ticket Status"] = ""
		--L["Open"] = ""
		--L["Needs more info!"] = ""
		--L["Response!"] = ""
		--L["Survey!"] = ""
		--L["Click to open a new ticket."] = ""
		--L["Click to edit your ticket."] = ""
		--L["Middle-click to abandon your ticket."] = ""
		--L["Right-click for options."] = ""
		--L["Show text without ticket"] = ""
		--L["Show status change alerts"] = ""
		--L["Alert color"] = ""

	elseif LOCALE == "ptBR" then
		--------------------------------------------------------
		--	Português (Brasil)
		--	Last updated 2013-10-02 by Phanx
		--------------------------------------------------------
		L["Ticket Status"] = "Estado de consulta"
		L["Open"] = "Aberta"
		L["Needs more info!"] = "Necessária mais info!"
		L["Response!"] = "Reposta!"
		L["Survey!"] = "Pesquisa!"
		L["Click to open a new ticket."] = "Clique para abrir uma nova consulta."
		--L["Click to edit your ticket."] = ""
		--L["Middle-click to abandon your ticket."] = ""
		L["Right-click for options."] = "Clique com o botão direito para opções."
		L["Show text without ticket"] = "Texto quando não há consultar"
		L["Show status change alerts"] = "Alertas de mudanças de estado da consulta"
		L["Alert color"] = "Cor de alertas"

	elseif LOCALE == "ruRU" then
		--------------------------------------------------------
		--	Русский
		--	Last updated 2013-10-06 by deltor95
		--------------------------------------------------------
		L["Ticket Status"] = "Статус запроса"
		L["Open"] = "Открыть"
		L["Needs more info!"] = "Нужно больше информации!"
		L["Response!"] = "Вам ответили!"
		L["Survey!"] = "Опрос!"
		L["Click to open a new ticket."] = "Нажмите чтобы ввести новый запрос"
		--L["Click to edit your ticket."] = ""
		--L["Middle-click to abandon your ticket."] = ""
		L["Right-click for options."] = "Щелкните ПКМ чтобы открыть настройки"
		L["Show text without ticket"] = "Показать текст без запроса"
		L["Show status change alerts"] = "Уведомить об изменении статуса"
		L["Alert color"] = "Цвет оповещений"

	elseif LOCALE == "koKR" then
		--------------------------------------------------------
		--	한국어
		--	Last updated YYYY-MM-DD by NAME
		--------------------------------------------------------
		--L["Ticket Status"] = ""
		--L["Open"] = ""
		--L["Needs more info!"] = ""
		--L["Response!"] = ""
		--L["Survey!"] = ""
		--L["Click to open a new ticket."] = ""
		--L["Click to edit your ticket."] = ""
		--L["Middle-click to abandon your ticket."] = ""
		--L["Right-click for options."] = ""
		--L["Show text without ticket"] = ""
		--L["Show status change alerts"] = ""
		--L["Alert color"] = ""

	elseif LOCALE == "zhCN" then
		--------------------------------------------------------
		--	简体中文
		--	Last updated 2013-07-08 by zhTW
		--------------------------------------------------------
		L["Ticket Status"] = "回报单状态"
		L["Open"] = "开启"
		L["Needs more info!"] = "需要更多信息!"
		L["Response!"] = "回应!"
		L["Survey!"] = "调查中!"
		L["Click to open a new ticket."] = "点击开启一个新的回报单。"
		--L["Click to edit your ticket."] = ""
		--L["Middle-click to abandon your ticket."] = ""
		L["Right-click for options."] = "右键点击开启选项。"
		L["Show text without ticket"] = "显示无回报单文字"
		L["Show status change alerts"] = "显示状态变化提示"
		L["Alert color"] = "提示颜色"

	elseif LOCALE == "zhTW" then
		--------------------------------------------------------
		--	繁體中文
		--	Last updated 2013-07-08 by zhTW
		--------------------------------------------------------
		L["Ticket Status"] = "回報單狀態"
		L["Open"] = "開啟"
		L["Needs more info!"] = "需要更多資訊!"
		L["Response!"] = "回應!"
		L["Survey!"] = "調查中!"
		L["Click to open a new ticket."] = "點擊開啟一個新的回報單。"
		--L["Click to edit your ticket."] = ""
		--L["Middle-click to abandon your ticket."] = ""
		L["Right-click for options."] = "右鍵點擊開啟選項。"
		L["Show text without ticket"] = "顯示無回報單文字"
		L["Show status change alerts"] = "顯示狀態變化提示"
		L["Alert color"] = "提示顏色"
	end
	setmetatable(L, { __index = function(t, k)
		local v = tostring(k)
		rawset(t, k, v)
		return v
	end })
end

------------------------------------------------------------------------

local addon = CreateFrame("Frame")
addon:SetScript("OnEvent", function(self, event, ...) return self[event] and self[event](self, ...) end)
addon:RegisterEvent("PLAYER_LOGIN")

function addon:PLAYER_LOGIN()
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
	self.db = initDB(defaults, BrokerTicketStatusDB)
	BrokerTicketStatusDB = self.db

	TicketStatusFrame:Hide()
	TicketStatusFrame:HookScript("OnShow", TicketStatusFrame.Hide)

	HelpOpenWebTicketButton:Hide()
	HelpOpenWebTicketButton:HookScript("OnShow", HelpOpenWebTicketButton.Hide)

	self:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil

	self.obj.text = self.db.textNoTicket and L["Open a ticket"] or ""
	-- UPDATE_WEB_TICKET doesn't fire on the PTR, but UPDATE_GM_STATUS
	-- indicates the ticket system is available.
	-- Could use GMQuickTicketSystemEnabled() instead?

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UPDATE_GM_STATUS")
	self:RegisterEvent("UPDATE_WEB_TICKET")

	local t = 5
	self:SetScript("OnUpdate", function(self, elapsed)
		t = t - elapsed
		if t <= 0 then
			GetWebTicket()
			t = GMTICKET_CHECK_INTERVAL
		end
	end)
end

function addon:PLAYER_ENTERING_WORLD()
	-- print("PLAYER_ENTERING_WORLD")
	GetGMStatus()
	GetWebTicket()
end

------------------------------------------------------------------------

function addon:UPDATE_GM_STATUS(status)
	-- print("UPDATE_GM_STATUS", status)
	if status == GMTICKET_QUEUE_STATUS_ENABLED then
		self.ticketQueueActive = true
	else
		self.ticketQueueActive = false
		self.obj.text = ADDON_DISABLED
	end
end
		
function addon:UPDATE_WEB_TICKET(hasTicket, numTickets, ticketStatus, caseIndex, waitTime, waitMsg)
	-- print("UPDATE_WEB_TICKET", hasTicket, numTickets, ticketStatus, caseIndex, waitTime, waitMsg)

	self.hasTicket = nil
	self.hasResponse = nil
	self.hasSurvey = nil
	self.caseIndex = nil

	if hasTicket and (numTickets > 1 or ticketStatus ~= LE_TICKET_STATUS_SURVEY) then
		-- Has a ticket
		self.hasTicket = true

		if ticketStatus == LE_TICKET_STATUS_NMI then
			-- print("Ticket needs more info")
			self.caseIndex = caseIndex
			self.titleText = TICKET_STATUS -- "You have an open ticket."
			self.statusText = TICKET_STATUS_NMI -- "Your ticket requires additional information"
			self.obj.text = L["Needs more info!"]
			return

		elseif ticketStatus == LE_TICKET_STATUS_RESPONSE then
			-- print("Ticket has a response")
			self.hasResponse = true
			self.caseIndex = caseIndex
			self.titleText = GM_RESPONSE_ALERT -- "You have received a GM response! Click here to read it."
			self.obj.text = L["Response!"]
			return

		elseif ticketStatus == LE_TICKET_STATUS_OPEN then
			-- print("Ticket is open")
			self.caseIndex = caseIndex
			self.titleText = TICKET_STATUS -- "You have an open ticket."

			if waitMsg and waitTime > 0 then
				self.statusText = format(waitMsg, SecondsToTime(waitTime * 60))
			elseif waitMsg then
				self.statusText = waitMsg
			elseif waitTime > 120 then
				self.statusText = GM_TICKET_HIGH_VOLUME -- "We are currently experiencing a high volume of petitions."
			elseif waitTime > 0 then
				self.statusText = format(GM_TICKET_WAIT_TIME, SecondsToTime(waitTime * 60)) -- "Average ticket wait time:\n%s"
			else
				self.statusText = GM_TICKET_UNAVAILABLE -- "Wait time currently unavailable."
			end
			self.obj.text = L["Open"]
			return
		end
	end

	-- No ticket
	-- print("No ticket")
	self.titleText = nil
	self.obj.text = self.ticketQueueActive and (self.db.textNoTicket and L["Open a ticket"] or "") or ADDON_DISABLED
end

function addon:GMSURVEY_DISPLAY()
	-- print("Survey is available")
	self.hasSurvey = true
	self.titleText = CHOSEN_FOR_GMSURVEY -- "You have been chosen to fill out a GM survey."
	self.obj.text = L["Survey!"]
end

hooksecurefunc(StaticPopupDialogs["TAKE_GM_SURVEY"], "OnCancel", function()
	addon.hasSurvey = false
	GetWebTicket()
end)

------------------------------------------------------------------------

addon.obj = LibStub("LibDataBroker-1.1"):NewDataObject("TicketStatus", {
	type = "data source",
	icon = "Interface\\HelpFrame\\HelpIcon-OpenTicket",
	name = L["Ticket Status"],
	text = HELP_TICKET_OPEN, -- Open a Ticket

	OnTooltipShow = function(GameTooltip)
		local self = addon
		GameTooltip:AddLine(L["Ticket Status"])
		if self.hasTicket then
			if self.titleText then
				GameTooltip:AddLine(self.titleText, 1, 1, 1)
			end
			if self.statusText then
				GameTooltip:AddLine(self.statusText, 1, 1, 1)
			end
			if self.caseIndex then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(L["Click to edit your ticket."], 1, 1, 1)
				GameTooltip:AddLine(L["Middle-click to abandon your ticket."], 1, 1, 1)
			end
		else
			GameTooltip:AddLine(L["Click to open a new ticket."], 1, 1, 1)
		end
		GameTooltip:AddLine(L["Right-click for options."], 1, 1, 1)
		GameTooltip:Show()
	end,

	OnClick = function(this, button)
		local self = addon
		if button == "RightButton" then
			-- Show menu
			ToggleDropDownMenu(nil, nil, self.menu, this, 0, 0, nil, nil, 10)
		elseif self.hasTicket and button == "MiddleButton" then
			-- Abandon ticket
			if not StaticPopup_Visible("HELP_TICKET_ABANDON_CONFIRM") then
				StaticPopup_Show("HELP_TICKET_ABANDON_CONFIRM")
			end

		elseif self.hasSurvey then
			-- Show survey
			GMSurveyFrame_LoadUI()
			ShowUIPanel(GMSurveyFrame)
			----------------------------------------------------
			-- This is kind of a hack, and I don't like it,
			-- but I can't think of a better solution right now,
			-- since GMSURVEY_DISPLAY doesn't fire again once
			-- the survey is no longer available. :(
			----------------------------------------------------
			if not self.hookedGMSurveyFrame then
				GMSurveyFrame:HookScript("OnHide", function()
					self.hasSurvey = nil
					GetGMTicket()
				end)
				self.hookedGMSurveyFrame = true
			end

		elseif StaticPopup_Visible("HELP_TICKET_ABANDON_CONFIRM") then
			StaticPopup_Hide("HELP_TICKET_ABANDON_CONFIRM")
		elseif StaticPopup_Visible("HELP_TICKET") then
			StaticPopup_Hide("HELP_TICKET")
		elseif StaticPopup_Visible("GM_RESPONSE_NEED_MORE_HELP") then
			StaticPopup_Hide("GM_RESPONSE_NEED_MORE_HELP");
		elseif StaticPopup_Visible("GM_RESPONSE_RESOLVE_CONFIRM") then
			StaticPopup_Hide("GM_RESPONSE_RESOLVE_CONFIRM")
		elseif StaticPopup_Visible("GM_RESPONSE_CANT_OPEN_TICKET") then
			StaticPopup_Hide("GM_RESPONSE_CANT_OPEN_TICKET")

		elseif self.caseIndex then
			-- Open the ticket
			HelpFrame_ShowFrame(HELPFRAME_SUBMIT_TICKET)
			HelpBrowser:OpenTicket(self.caseIndex)

		else
			-- Open form to submit new ticket
			HelpFrame_ShowFrame(HELPFRAME_SUBMIT_TICKET)
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

		local obj = addon.obj
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

	addon.menu = menu
end