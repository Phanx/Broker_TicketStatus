local ticketQueueActive
local haveTicket
local haveResponse
local ticketTimer

local refreshTime = 0

local TicketStatusBroker = CreateFrame("Frame")
TicketStatusBroker:SetScript("OnEvent", function(self, event, ...) return self[event] and self[event](self, ...) end)
TicketStatusBroker:RegisterEvent("PLAYER_LOGIN")
TicketStatusBroker:RegisterEvent("PLAYER_ENTERING_WORLD")
TicketStatusBroker:RegisterEvent("GMGRESPONSE_RECEIVED")
TicketStatusBroker:RegisterEvent("GMSURVEY_DISPLAY")
TicketStatusBroker:RegisterEvent("UPDATE_GM_STATUS")
TicketStatusBroker:RegisterEvent("UPDATE_TICKET")

function TicketStatusBroker:PLAYER_LOGIN()
	print("PLAYER_LOGIN")
	GetGMStatus()
end

function TicketStatusBroker:PLAYER_ENTERING_WORLD()
	print("PLAYER_ENTERING_WORLD")
	GetGMTicket()
end

function TicketStatusBroker:UPDATE_TICKET(category, ticketText, ticketOpenTime, oldestTicketTime, updateTime, assignedToGM, openedByGM, waitTimeOverrideMessage, waitTimeOverrideMinutes)
	print("UPDATE_TICKET")
	print("  [1] category:", category or "nil")
	print("  [2] ticketText:", ticketText or "nil")
	print("  [3] ticketOpenTime:", ticketOpenTime or "nil")
	print("  [4] oldestTicketTime:", oldestTicketTime or "nil")
	print("  [5] updateTime:", updateTime or "nil")
	print("  [6] assignedToGM:", assignedToGM or "nil")
	print("  [7] openedByGM:", openedByGM or "nil")
	print("  [8] waitTimeOverrideMessage:", waitTimeOverrideMessage or "nil")
	print("  [9] waitTimeOverrideMinutes:", waitTimeOverrideMinutes or "nil")

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
					self.statusText = waitTimeOverrideMessage:format(SecondsToTime(waitTimeOverrideMinutes * 60, 1))
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
				-- Averate ticket wait time: %s
				self.statusText = GM_TICKET_WAIT_TIME:gsub("\n", ""):format(SecondsToTime(estimatedWaitTime, 1))
			else
				-- Your ticket will be serviced soon.
				self.statusText = GM_TICKET_SERVICE_SOON
			end
		end

		haveTicket = true
		haveResponse = false
	else
		-- The player does not have a ticket.
		haveTicket = false
		haveResponse = false

		-- Open a Ticket
		self.titleText = HELP_TICKET_OPEN
		self.statusText = nil
	end
	self.dataObject.text = self.titleText
end

function TicketStatusBroker:UPDATE_GM_STATUS(status)
	print("UPDATE_GM_STATUS")
	print("  [1] status:", status or "nil")
	if status == GMTICKET_QUEUE_STATUS_ENABLED then
		ticketQueueActive = true
	else
		ticketQueueActive = nil
		if status == GMTICKET_QUEUE_STATUS_DISABLED then
			-- "GM Help Tickets are currently unavailable."
		end
	end
end

function TicketStatusBroker:GMRESPONSE_RECEIVED(ticketText, responseText)
	print("GMRESPONSE_RECEIVED")
	print("  [1] ticketText:", ticketText or "nil")
	print("  [2] responseText:", responseText or "nil")

	haveResponse = true
	haveTicket = nil

	-- "You have received a ticket response. Click here to read it."
	self.titleText = "GM Response!"
	self.statusText = GM_RESPONSE_ALERT

	self.dataObject.text = self.titleText
end

function TicketStatusBroker:GMSURVEY_DISPLAY(...)
	printEvent("GMSURVEY_DISPLAY", ...)

	haveGMSurvey = true
	haveResponse = nil
	haveTicket = nil

	-- You have been chosen to fill out a GM survey.
	self.titleText = "GM Survey!"
	self.statusText = CHOSEN_FOR_GMSURVEY

	self.dataObject.text = self.titleText
end

function TicketStatusBroker:OnUpdate(e)
	refreshTime = refreshTime - e
	if refreshTime <= 0 then
		refreshTime = GMTICKET_CHECK_INTERVAL
		GetGMTicket()
	end

	GameTooltip:SetText("Ticket Status")
	GameTooltip:AddLine(self.titleText, 1, 1, 1)
	if self.statusText then
		GameTooltip:AddLine(self.statusText)
		if ticketTimer then
			ticketTimer = ticketTimer - elapsed
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(GM_TICKET_WAIT_TIME:format(SecondsToTime(ticketTimer, 1)), 1, 1, 1)
		end
	end
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(HELPFRAME_TICKET_CLICK_HELP, 0.8, 0.8, 0.8)
	GameTooltip:AddLine("Right-click for options.", 0.8, 0.8, 0.8)
	GameTooltip:Show()
end

TicketStatusBroker.dataObject = LibStub("LibDataBroker-1.1"):NewDataObject("Ticket Status", {
	type = "data",
	icon = "Interface\\HelpFrame\\HelpIcon-OpenTicket",
	name = "Ticket Status",
	text = HELP_TICKET_OPEN, -- Open a Ticket
	OnEnter = function(dataObject)
		GameTooltip:SetOwner(dataObject, "ANCHOR_TOP")
		if haveTicket then
			TicketStatusBroker:SetScript("OnUpdate", TicketStatusBroker.OnUpdate)
		else
			GameTooltip:SetText("Ticket Status")
			if haveResponse then
				GameTooltip:AddLine(GM_RESPONSE_ALERT, 1, 1, 1)
			elseif haveGMSurvey then
				GameTooltip:AddLine(CHOSEN_FOR_GMSURVEY, 1, 1, 1)
			else
				GameTooltip:AddLine("Click here to open a new ticket.", 0.8, 0.8, 0.8)
			end
			GameTooltip:AddLine("Right-click for options.", 0.8, 0.8, 0.8)
			GameTooltip:Show()
		end
	end,
	OnLeave = function(dataObject)
		TicketStatusBroker:SetScript("OnUpdate", nil)
		GameTooltip:Hide()
		pluginFrame = nil
	end,
	OnClick = function(dataObject, button)
		if button == "RightButton" then
			-- TODO: open options
		elseif haveTicket and button == "MiddleButton" then
			StaticPopup_Show("HELP_TICKET_ABANDON_CONFIRM")
		else
			if haveGMSurvey then
				GMSurveyFrame_LoadUI()
				ShowUIPanel(GMSurveyFrame)
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