--[[--------------------------------------------------------------------
	Broker: Ticket Status
	DataBroker plugin to monitor the status of your GM ticket.
	by Phanx <addons@phanx.net>
	Copyright © 2012 Phanx. Some rights reserved. See LICENSE.txt for details.
	http://www.wowinterface.com/downloads/info-BrokerTicketStatus.html
	http://www.curse.com/addons/wow/broker-ticketstatus
----------------------------------------------------------------------]]

local L = setmetatable({}, { __index = function(t, k)
	local v = tostring(k)
	rawset(t, k, v)
	return v
end })

------------------------------------------------------------------------

local db

local ticketQueueActive
local haveTicket
local haveResponse
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
		print("  [1] category:", category)
		-- print("  [2] ticketText:", ticketText or "nil")
		print("  [3] ticketOpenTime:", ticketOpenTime or "nil")
		print("  [4] oldestTicketTime:", oldestTicketTime or "nil")
		print("  [5] updateTime:", updateTime or "nil")
		print("  [6] assignedToGM:", assignedToGM or "nil")
		print("  [7] openedByGM:", openedByGM or "nil")
		print("  [8] waitTimeOverrideMessage:", waitTimeOverrideMessage or "nil")
		print("  [9] waitTimeOverrideMinutes:", waitTimeOverrideMinutes or "nil")
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
				-- Average ticket wait time: %s
				self.statusText = GM_TICKET_WAIT_TIME:gsub("\n", ""):format(SecondsToTime(estimatedWaitTime, 1))
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
	self.titleText = L["GM Response!"]
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
	self.titleText = L["GM Survey!"]
	self.statusText = CHOSEN_FOR_GMSURVEY

	if db.alert and (lastAlert ~= "GMSURVEY_DISPLAY" or GetTime() - lastAlertTime > 10)  then
		RaidNotice_AddMessage(RaidWarningFrame, L["You have been chosen to fill out a GM survey!"], db.alertColor)
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
		local waitTime = GM_TICKET_WAIT_TIME:gsub("\\n", " "):format(SecondsToTime(ticketTimer, 1))
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(waitTime, 1, 1, 1)
	end
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(HELPFRAME_TICKET_CLICK_HELP, 0.8, 0.8, 0.8)
	GameTooltip:AddLine(L["Right-click for options."], 0.8, 0.8, 0.8)
	GameTooltip:Show()
end

BrokerTicketStatus.dataObject = LibStub("LibDataBroker-1.1"):NewDataObject("Ticket Status", {
	type = "data",
	icon = "Interface\\HelpFrame\\HelpIcon-OpenTicket",
	name = L["Ticket Status"],
	text = HELP_TICKET_OPEN, -- Open a Ticket
	OnEnter = function(self)
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
				GameTooltip:AddLine(L["Click here to open a new ticket."], 1, 1, 1)
			else
				GameTooltip:AddLine(HELP_TICKET_QUEUE_DISABLED, 1, 0.6, 0.6)
			end
			GameTooltip:AddLine(L["Right-click for options."], 0.6, 0.6, 0.6)
			GameTooltip:Show()
		end
	end,
	OnLeave = function(dataObject)
		BrokerTicketStatus:SetScript("OnUpdate", nil)
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

local opt