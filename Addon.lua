--[[--------------------------------------------------------------------
	Broker_TicketStatus
	Shows the status of your GM Help Ticket on your DataBroker display.
	Copyright (c) 2011-2016 Phanx <addons@phanx.net>. All rights reserved.
	https://www.wowinterface.com/downloads/info20888-BrokerTicketStatus.html
	https://mods.curse.com/addons/wow/broker-ticketstatus
	https://github.com/Phanx/Broker_TicketStatus
----------------------------------------------------------------------]]

local ADDON, L = ...

local addon = CreateFrame("Frame", ADDON)
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

	local function poll()
		GetWebTicket()
		C_Timer.After(GMTICKET_CHECK_INTERVAL or 600, poll)
	end
	C_Timer.After(5, poll)
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
