local L = setmetatable({}, { __index = function(t, k)
	local v = tostring(k)
	rawset(t, k, v)
	return v
end })

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

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UPDATE_WEB_TICKET")

	local t = 0
	self:SetScript("OnUpdate", function(self, elapsed)
		t = t - elapsed
		if t <= 0 then
			GetWebTicket()
			t = GMTICKET_CHECK_INTERVAL
		end
	end)
end

function addon:PLAYER_ENTERING_WORLD()
	--print("PLAYER_ENTERING_WORLD")
	GetWebTicket()
end

function addon:UPDATE_WEB_TICKET(hasTicket, numTickets, ticketStatus, caseIndex, waitTime, waitMsg)
	--print("UPDATE_WEB_TICKET", hasTicket, numTickets, ticketStatus, caseIndex, waitTime, waitMsg)

	self.hasTicket = nil
	self.hasResponse = nil
	self.hasSurvey = nil
	self.caseIndex = nil

	if not hasTicket then
		-- No ticket
		self.titleText = HELP_TICKET_OPEN -- Open a ticket.
		self.obj.text = self.db.textNoTicket and titleText or ""
	else
		-- Has a ticket
		self.hasTicket = true

		if ticketStatus == LE_TICKET_STATUS_NMI then
			-- Ticket needs more info
			self.caseIndex = caseIndex
			self.titleText = TICKET_STATUS -- "You have an open ticket."
			self.statusText = TICKET_STATUS_NMI -- "Your ticket requires additional information"
			self.obj.text = L["Needs more info!"]

		elseif ticketStatus == LE_TICKET_STATUS_RESPONSE then
			-- Ticket has a response
			self.hasResponse = true
			self.caseIndex = caseIndex
			self.titleText = GM_RESPONSE_ALERT -- "You have received a GM response! Click here to read it."
			self.obj.text = L["Response!"]

		elseif ticketStatus == LE_TICKET_STATUS_OPEN then
			-- Ticket is open
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

		elseif ticketStatus == LE_TICKET_STATUS_SURVEY and numTickets == 1 then
			-- Survey is available
			self.hasSurvey = true
			self.caseIndex = caseIndex
			self.titleText = CHOSEN_FOR_GMSURVEY -- "You have been chosen to fill out a GM survey."
			self.obj.text = L["Survey!"]
		end
	end
end

addon.obj = LibStub("LibDataBroker-1.1"):NewDataObject("TicketStatus", {
	type = "data source",
	icon = "Interface\\HelpFrame\\HelpIcon-OpenTicket",
	name = L["Ticket Status"],
	text = HELP_TICKET_OPEN, -- Open a Ticket

	OnTooltipShow = function(GameTooltip)
		local self = addon
		GameTooltip:AddLine(L["Ticket Status"])
		if self.hasTicket then
			GameTooltip:AddLine(self.titleText, 1, 1, 1)
			if self.statusText then
				GameTooltip:AddLine(self.statusText, 1, 1, 1)
			end
			if self.caseIndex then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(HELPFRAME_TICKET_CLICK_HELP, 0.8, 0.8, 0.8) -- "Click here to open your ticket."
			end
		else
			GameTooltip:AddLine(L["Click to open a new ticket."], 1, 1, 1)
		end
		GameTooltip:AddLine(L["Right-click for options."], 0.8, 0.8, 0.8)
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
			HelpBrowser:NavigateHome("GMTicketStatus")
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