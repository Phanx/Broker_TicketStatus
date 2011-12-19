--[[--------------------------------------------------------------------
	Broker_TicketStatus
	DataBroker plugin to replace the ticket status frame.
	by Phanx <addons@phanx.net>
	Copyright © 2010–2011 Phanx. Some rights reserved. See LICENSE.txt for details.
	http://www.wowinterface.com/downloads/info-BrokerTicketStatus.html
	http://wow.curse.com/downloads/wow-addons/details/broker-ticketstatus.aspx
----------------------------------------------------------------------]]

local L = setmetatable({}, { __index = function(t, k)
	if k == nil then return "" end
	local v = tostring(k)
	t[k] = v
	return v
end })

------------------------------------------------------------------------

local BrokerTicketStatus = CreateFrame("Frame")
BrokerTicketStatus:SetScript("OnEvent", function(self, event, ...) return self[event] and self[event] (self, ...) end)
BrokerTicketStatus:RegisterEvent("PLAYER_LOGIN")

function BrokerTicketStatus:PLAYER_LOGIN()
	local function copyTable(src, dst)
		if type(src) ~= "table" then return {} end
		if type(dst) ~= "table" then dst = {} end
		for k, v in pairs(src) do
			if type(v) == "table" then
				dst[k] = copyTable(v, dst[k])
			elseif type(v) ~= type(dst[k]) then
				dst[k] = v
			end
		end
		return dst
	end
	
	local defaults = {
	}
	
	BrokerTicketStatusDB = BrokerTicketStatusDB or {}
	db = copyTable(defaults, BrokerTicketStatusDB)

	TicketStatusFrame:Hide()
	TicketStatusFrame:HookScript("OnShow", function(self)
		return self:Hide()
	end)

	self:RegisterEvent("TICKET_UPDATE")
	self:RegisterEvent("GMRESPONSE_RECEIVED")
	
	GetGMTicket()
end

------------------------------------------------------------------------

local hasTicket, hasResponse, hasSurvey

function BrokerTicketStatus:TICKET_UPDATE(category, ticketDescription, ticketOpenTime, oldestTicketTime, updateTime, assignedToGM, openedByGM, waitTimeOverrideMessage, waitTimeOverrideMinutes)
	if (category or hasSurvey) and (not GMChatStatusFrame or not GMChatStatusFrame:IsShown()) then
		self.tooltipTitle = TICKET_STATUS
		self.ticketTimer = nil
		if openedByGM = GMTICKET_OPENEDBYGM_STATUS_OPENED then
			if assignedToGM then
				self.tooltipText = GM_TICKET_ESCALATED
				self.dataObject.text = L["Escalated"]
			else
				self.tooltipText = GM_TICKET_SERVICE_SOON
				self.dataObject.text = L["Soon"]
			end
		else
			local estimatedWaitTime = oldestTicketTime - ticketOpenTime
			if estimatedWaitTime < 0 then
				estmatedWaitTime = 0
			end
			if #waitTimeOverrideMessage > 0 then
				estimatedWaitTime = waitTimeOverrideMinutes * 60
				if waitTimeOverrideMinutes then
					self.tooltipText = waitTimeOverrideMessage:format(SecondsToTime(estimatedWaitTime, 1))
				else
					self.tooltipText = waitTimeOverrideMessage
				end
				self.dataObject.text = L["Queued"]
			elseif oldestTicketTime < 0 or updateTime < 0 or updateTime > 3600 then
				self.tooltipText = GM_TICKET_UNAVAILABLE
				self.dataObject.text = L["Queued"]
			elseif estimatedWaitTime > 7200 then
				self.tooltipText = GM_TICKET_HIGH_VOLUME
				self.dataObject.text = L["Queued"]
			elseif estimatedWaitTime > 300 then
				self.tooltipText = GM_TICKET_WAIT_TIME:format(SecondsToTime(estimatedWaitTime, 1))
				self.dataObject.text = SecondsToTime(estimatedWaitTime, 1)
			else
				self.tooltipText = GM_TICKET_SERVICE_SOON
				self.dataObject.text = L["Soon"]
			end
		end
		hasTicket = true
		hasResponse = false
		hasSurvey = false
	else
		hasTicket = false
		hasResponse = false
		hasSurvey = false
		self.dataObject.text = L["Open a Ticket"]
	end
end

function BrokerTicketStatus:GMRESPONSE_RECEIVED()
	hasSurvey = true
end

------------------------------------------------------------------------

local function OnTooltipShow(tooltip)
	tooltip:AddLine(BTS.tooltipTitle)
	tooltip:AddLine(BTS.tooltipText)
end

local function OnClick(self, button)
	if hasSurvey then
		GMSurveyFrame_LoadUI()
		ShowUIPanel(GMSurveyFrame)
		BrokerTicketStatus.dataObject.text = L["Open a Ticket"]
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
	end
end

BrokerTicketStatus.dataObject = LibStub("LibDataBroker-1.1"):NewDataObject("TicketStatus", {
	type = "data source",
	icon = [[Interface\HelpFrame\OpenTicketIcon]],
	label = L["Ticket Status"],
	text = L["Open a Ticket"],
	OnTooltipShow = OnTooltipShow,
	OnClick = OnClick,
})