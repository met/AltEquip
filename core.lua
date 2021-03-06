--[[
Copyright (c) 2019 Martin Hassman

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
--]]

local cYellow = "\124cFFFFFF00";
local cWhite = "\124cFFFFFFFF";
local cRed = "\124cFFFF0000";
local cLightBlue = "\124cFFadd8e6";
local cGreen1 = "\124cFF38FFBE";

local primaryProfessions = {"Alchemy", "Blacksmithing", "Enchanting", "Engineering", "Herbalism", "Leatherworking", "Mining", "Skinning", "Tailoring"};
local secondaryProfessions = {"Cooking", "First Aid", "Fishing"};

local function contains(table, val)
   for i = 1,#table do
      if table[i] == val then 
         return true
      end
   end
   return false
end



SLASH_ALTEQUIP1 = "/alte";
SLASH_ALTEQUIP2 = "/altequip";

-- usage /alte charname
SlashCmdList["ALTEQUIP"] = function(msg)

	if msg == "" then
		print("Which character do you want to list?");
		printSavedCharacters();
	else
		if AltEquipSettings[msg] == nil then
			print("Do not know character ", msg, ".");
		else
			if AltEquipSettings[msg].items == nil then
				print("Character ", msg, " has no saved equipment.");
			else
				print(cYellow.."Equipment of "..msg..":");
				for k,v in pairs(AltEquipSettings[msg].items) do
					print(k, " ", v);
				end
			end
		end
	end

end 

SLASH_ALTITEM1 = "/alti";
SLASH_ALTITEM2 = "/altitem";
-- usage /altitem NECK # display neck item for all known alts
SlashCmdList["ALTITEM"] = function(msg)

	if msg == "" then
		print("Which slot do you want to show?");
		print("ammo, head, neck, shoulder, shirt, chest, belt, legs, feet, wrist, gloves, finger0, finger1, trinket0, trinket1, back, mainhand, secondaryhand, ranged, tabard");

	else
		-- for wrong slot names script just fails here
		local slotid = GetInventorySlotInfo(msg.."slot");

			print(cYellow.."Equipment in ", msg, ":");
			for name in pairs(AltEquipSettings) do
				if AltEquipSettings[name]["items"] ~= nil then
					print(cYellow, name, cWhite, " l", AltEquipSettings[name]["level"], " ", AltEquipSettings[name]["class"], " ", AltEquipSettings[name]["items"][slotid]);
				end
			end

	end
end

SLASH_ALTSHOW1 = "/alts";
SLASH_ALTSHOW2 = "/altshow";
-- usage /altshow # display all known alts
SlashCmdList["ALTSHOW"] = function(msg)

	print(cYellow.."Found these alts:");
	printSavedCharacters();

end 

SLASH_ALTSKILLS1 = "/altsk";
SLASH_ALTSKILLS2 = "/altskills";
-- usage /altshow # display all known alts
SlashCmdList["ALTSKILLS"] = function(msg)

	if msg == "" then
		print(cYellow.."Found these alts skills:");
		printSavedSkills();
	elseif msg == "me" then
		printMySavedSkills();
	else
		print(cYellow.."Found these alts skills:");
		printSavedSkills(msg);
	end
end 

SLASH_ALTPROFS1 = "/altp";
SLASH_ALTPROFS2 = "/altprofs";
-- usage /altp # display all alts professions
SlashCmdList["ALTPROFS"] = function(msg)

	if msg == "me" then
		printMySavedProfessions();
	else
		print(cYellow.."Found these alts professions:");
		printSavedProfessions();
	end
end 

SLASH_ALTBAGS1 = "/altb";
SLASH_ALTBAGS2 = "/altbags";
-- usage /altb # display all alts bags
SlashCmdList["ALTBAGS"] = function(msg)
	printSavedBags(AltEquipSettings);	
end 


SLASH_ALTMAILS1 = "/altm";
SLASH_ALTMAILS2 = "/altmails";
-- usage /altm # display unprocessed mails to alts
SlashCmdList["ALTMAILS"] = function(msg)
	
	-- /altm clear -- clear message log manually (need to do this automatically)
	if msg == "clear" then
		AltEquipMailLog = {};
		print(cYellow.."Mail log was cleared.");
	else
		printLogedMails(AltEquipMailLog);
	end

	--TODO clear old log items after mail were opened and read
	--TODO inform player that some of his alts already received his emails, so its time to log them and get mails
end 

SLASH_ALTENCHANT1 = "/alten";
SLASH_ALTENCHANT2 = "/altenchant";
-- usage /altshow # display all known alts
SlashCmdList["ALTENCHANT"] = function(msg)

	print(cYellow.."Items enchantable by armor kits:");
	print("(0=no enchantment, 15,16,17,18=armor kits)");

	if msg == "me" then
		printMyEnchantmentsByArmorKits();
	else
		printEnchantableByArmorKitAlts();
	end
end 


function printSavedCharacters()
	for name in pairs(AltEquipSettings) do
		print(cYellow..name..cWhite.." l".. AltEquipSettings[name]["level"], " ", AltEquipSettings[name]["class"]..cGreen1..GetCharacterProfessionLevels(AltEquipSettings, name));
	end
end

function GetCharacterProfessionLevels(setts, charname)
	local foundProf = "";

	if setts ~= nil and setts[charname] ~= nil and setts[charname].profs ~= nil then
		for p in pairs(setts[charname].profs) do
				if contains(primaryProfessions, p) and setts[charname].profs[p].level ~= nil then
					foundProf = foundProf.." "..p.." "..setts[charname].profs[p].level;
				end
		end
	end

	return foundProf;
end


function printMySavedProfessions()
	local player = GetUnitName("player");

		if AltEquipSettings[player] ~= nil and AltEquipSettings[player]["profs"] ~= nil then
			print(cYellow.."Found these professions:");
			for prof in pairs(AltEquipSettings[player]["profs"]) do
				if contains(primaryProfessions, prof) and AltEquipSettings[player]["profs"][prof].level ~= nil then
					print(cGreen1, prof, AltEquipSettings[player]["profs"][prof].level);
				end
			end

		end

end

function printSavedProfessions()
	for name in pairs(AltEquipSettings) do
		if AltEquipSettings[name]["profs"] ~= nil then
			for prof in pairs(AltEquipSettings[name]["profs"]) do
				if contains(primaryProfessions, prof) and AltEquipSettings[name]["profs"][prof].level ~= nil then
					print(cYellow..name, "-", cGreen1, prof, AltEquipSettings[name]["profs"][prof].level);
				end
			end

		end
	end
end


function printMySavedSkills()
	local player = GetUnitName("player");

		if AltEquipSettings[player] ~= nil and AltEquipSettings[player]["profs"] ~= nil then
			print(cYellow.."Found these skills:");
			for prof in pairs(AltEquipSettings[player]["profs"]) do
				if AltEquipSettings[player]["profs"][prof].level ~= nil then
					print(cGreen1, prof, AltEquipSettings[player]["profs"][prof].level);
				end
			end

		end

end

function printSavedSkills(filter)

	for name in pairs(AltEquipSettings) do
	
		if AltEquipSettings[name]["profs"] ~= nil then
	
			for prof in pairs(AltEquipSettings[name]["profs"]) do

				if (filter == nil or string.lower(prof) == string.lower(filter)) and AltEquipSettings[name]["profs"][prof].level ~= nil then
					print(cYellow, name, "-", cGreen1, prof, AltEquipSettings[name]["profs"][prof].level);
				end

			end

		end
	end
end

-- print stored infor about alts bags (size and type)
function printSavedBags(setts)
	print(cYellow.."Bags of your characters:");

	for name in pairs(setts) do

		local line = cYellow.. name .. cWhite.. " - ";

		if setts[name].bags ~= nil then

			for n = 1, #setts[name].bags do

				if setts[name].bags[n].type == 0 or setts[name].bags[n].type == nil then -- nil can happen it player has no bag
					line = line..setts[name].bags[n].slots.." ";
				else
					line = line..cLightBlue..setts[name].bags[n].slots.."(special) "..cWhite;
				end
			end

			print(line);
		end

	end
end


local frame = CreateFrame("FRAME");

function frame:OnEvent(event, arg1, ...)

	if event == "ADDON_LOADED" then
		if arg1 == "AltEquip" then
			if AltEquipSettings == nil then
				AltEquipSettings = {};
			end

			if AltEquipMailLog == nil then
				AltEquipMailLog = {};
			end

			-- tracking send emails to alts
			-- we hook SEND MAIL button in oficial mail WOW dialog
			-- but we miss all mails send by other ways (API, addons)
			-- https://www.townlong-yak.com/framexml/live/MailFrame.lua#833
			SendMailMailButton:HookScript("OnClick", AltSendMailHookFunction);

			if HasDeliveredMails(AltEquipMailLog) then
				print(cYellow.."One of your alts has mail delivered. Try "..SLASH_ALTMAILS1.." for details.");
			end
		end

	elseif event == "PLAYER_ENTERING_WORLD" then
		UpdatePlayerData(AltEquipSettings);

		if AltEquipSettings[GetUnitName("player")]["items"] == nil then
		-- sometimes equipment data are not loaded yet,
		-- we do not want to rewrite last equipment data
		-- so update now only if we do not have any data saved yet 
			UpdatePlayerEquipment(AltEquipSettings);
		end

	elseif event == "PLAYER_EQUIPMENT_CHANGED" then
		-- save new equipment data
		UpdatePlayerEquipment(AltEquipSettings);

	elseif event == "CHAT_MSG_SKILL" then
		UpdatePlayerProfs(AltEquipSettings, arg1);

	elseif event == "PLAYER_LOGOUT" then
		UpdatePlayerData(AltEquipSettings);

	elseif event == "BAG_UPDATE" then
		--print("BAG_UPDATE", arg1, ...);
		UpdatePlayerBags(AltEquipSettings);

	elseif event == "TRADE_SKILL_UPDATE" or event == "CRAFT_UPDATE" then
		--print(cLightBlue..event);
		-- Opened window with player profession skills
		-- TODO better listen only _UPDATE events, because during _SHOW are not lines data ready yet (show data from previous profesion window)

		-- for trade professions eg. cooking
		local skillName, curSkill, maxSkill = GetTradeSkillLine();

		if skillName ~= nil and skillName ~= "UNKNOWN" then
		--	print(skillName, curSkill, maxSkill);
		end

		-- For craft  professions, eg. enchanting
		local skillName, curSkill, maxSkill = GetCraftDisplaySkillLine();

		if skillName ~= nill and skillName ~= "UNKNOWN" then
		--	print(skillName, curSkill, maxSkill);
		end

		-- only one is correct, second return cache value from previous window
		-- need to really distinguis is we have opened trade or crafts here
		--print("GetNumTradeSkills", GetNumTradeSkills());
		--print("GetNumCrafts", GetNumCrafts());

		--[[ 
		-- list of learned skills = lines in profession window
		if event == "TRADE_SKILL_UPDATE" then
			print(cYellow.."GetTradeSkillInfo");
			for i = 1,GetNumTradeSkills() do
				print(i, GetTradeSkillInfo(i));
			end
		end

		if event == "CRAFT_UPDATE" then
			print(cYellow.."GetCraftInfo");
			for i = 1, GetNumCrafts() do
				print(i, GetCraftInfo(i));
			end
		end
		--]]

		-- https://github.com/satan666/WOW-UI-SOURCE/blob/master/AddOns/Blizzard_TrainerUI/Blizzard_TrainerUI.lua
		-- https://github.com/satan666/WOW-UI-SOURCE/blob/master/AddOns/Blizzard_TradeSkillUI/Blizzard_TradeSkillUI.lua
		-- https://github.com/satan666/WOW-UI-SOURCE/blob/master/AddOns/Blizzard_CraftUI/Blizzard_CraftUI.lua
		--GetCraftDescription(index) text line
		--GetCraftNumReagents(index)
		--GetCraftReagentInfo(index, reagentIndex); = name, id, howmuchneed, howmuchhave

	elseif event == "TRAINER_UPDATE" then
		--print(event, arg1, ...);
		--event is raised several times during opening window, only the last has lines info loaded (GetNumTrainerServices > 0)

		--print(cYellow.."GetTrainerServiceInfo");
		for i = 1, GetNumTrainerServices() do
			--print(i, GetTrainerServiceInfo(i));
			--GetTrainerServiceLevelReq(i) -- level limit
			--GetTrainerServiceSkillReq(i) -- skill level limit { "skillname", number, boolean}
			-- takhle si mohu snadno stahnout kdy se mohu zacit ucit dalsi dovednosti u trenera
			-- a v remnotes na to mohu upozornovat
			-- nemusi to byt v tabulce notes, udelam si tabulku receptu/skillu v treningu - pro kazdeho hrace,
			-- pri kazdem otevteni okna trenera to updatnu (protoze treneri jsou ruzni)
			-- a zapamatuji si typ profese, nazev budouciho skillitemu, pozadavky na level a skill u learningu, a jmeno a lokaci trenera (abych ho snadno nasel)

			-- vypis ikon, id ziskam z GetTrainerServiceIcon(index)
			-- https://wow.gamepedia.com/UI_escape_sequences#Textures
			-- "|T135913:0|t"
			-- /run print("\124T135913:0\124t")
			-- /run print("\124TInterface\\Icons\\INV_Misc_Coin_01:16\124t Coins");
			-- /run print("\124cFFFF0000This is red text \124rthis is normal color");

		end

	elseif event == "CHAT_MSG_SYSTEM" then
		--print(event, arg1, ...);
		-- there is huge amount of different messages for this event, see https://www.townlong-yak.com/framexml/live/GlobalStrings.lua
		-- we look for ERR_LEARN_RECIPE_S = "You have learned how to create a new item: %s.";	
		local itemname = string.match(arg1, "^You have learned how to create a new item: (.+).");

		if itemname ~= nil then
			print(event, arg1);
			print("Matched:", itemname);
		end

	else
		print(cRed.."ERROR. Received unhandled event.");
		print(event, arg1, ...);
	end
end

function UpdatePlayerEquipment(setts)
	local player = GetUnitName("player");
	setts[player]["items"] = {}; -- rewrite everything old here

	for x = 0,19 do
		setts[player]["items"][x] = GetInventoryItemLink("player",x);
	end

	setts[player]["equipmentDataTime"] = date();
end

function UpdatePlayerData(setts)
	local player = GetUnitName("player");

	if setts[player] == nil then
		setts[player] = {};
	end

	setts[player]["class"] = GetPlayerInfoByGUID(UnitGUID("player"));
	setts[player]["level"] = UnitLevel("player");
	setts[player]["lastTime"] = date();

end

function UpdatePlayerProfs(setts, msg)
	local player = GetUnitName("player");

	-- Msg like:
	-- Your skill in Fishing has increased to 131.
	local profession, proflevel = string.match(msg, "Your skill in (.+) has increased to (%d+).");

	if profession == nil or proflevel == nil then
		return;
	end

	if setts[player]["profs"] == nil then
		setts[player]["profs"] = {};
	end

	if setts[player]["profs"][profession] == nil then
		setts[player]["profs"][profession] = {};
	end

	setts[player]["profs"][profession].level = proflevel;

end

function UpdatePlayerBags(setts)
	local player = GetUnitName("player");

	if setts[player] == nil then
		setts[player] = {};
	end

	setts[player].bags = {};

	for n=1,NUM_BAG_SLOTS do
		local nSlots = GetContainerNumSlots(n);
		local nFreeSlots, bagType = GetContainerNumFreeSlots(n);

		table.insert(setts[player].bags, { ["slots"] = nSlots, ["type"] = bagType});
	end
end

function IsMyAlt(setts, charname)
	assert(setts, "IsMyAlt - setts is nil");
	assert(charname, "IsMyAlt - charname is nil");

	if setts[charname] ~= nil then
		return true;
	else
		return false;
	end
end

-- true if timestamp in unixtime is older than 1 hour
function IsOlderOneHour(timestamp)
	return ((time() - timestamp) > 60*60)  -- 1 hour = 60 * 60 secondes
end

-- check log and if any mail is older than 1 hours (considered deliver), return true
function HasDeliveredMails(maillog)
	assert(maillog, "HasDeliveredMails - maillog is nil");

	for k,v in pairs(maillog) do
		if IsOlderOneHour(v.timestamp) then
			return true;
		end
	end

	return false;
end

-- log when player send mail to alts, hooked to SendMailMailButton - OnClick
function AltSendMailHookFunction(...)
	--print("AltSendMailHookFunction", ...);

	local recipient = SendMailNameEditBox:GetText();
	local subject = SendMailSubjectEditBox:GetText();
	local mailBody = SendMailBodyEditBox:GetText();
	local mailMoney = 0;

	if SendMailSendMoneyButton:GetChecked() then -- otherwise it is C.O.D = cash on delivery not send money
		mailMoney = MoneyInputFrame_GetCopper(SendMailMoney);
	end

	local attachments = {};

	for i = 1, ATTACHMENTS_MAX_SEND do
		--print(SendMailFrame.SendMailAttachments[i].count);
		--print(GetSendMailItem(i));

		local itemName, itemID, itemTexture, stackCount, quality = GetSendMailItem(i);
		if itemName ~= nil then
			table.insert(attachments, {name = itemName, id = itemID, count = stackCount});
		end
	end

	local timestamp = time();
	local dateSend = date(nil, timestamp); -- human readable string for this unixtime

	-- we care only about emails sent to alt characters
	if IsMyAlt(AltEquipSettings, recipient) then
		LogSendMail(AltEquipMailLog, dateSend, timestamp, GetUnitName("player"), recipient, subject, mailBody, mailMoney, attachments);
	end
end

function LogSendMail(maillog, dateSend, timestamp, sender, recipient, subject, mailBody, mailMoney, attachments)
	assert(maillog, "LogSendMail - maillog is nil");
	assert(dateSend, "LogSendMail - dateSend is nil");
	assert(timestamp, "LogSendMail - timestamp is nil");
	assert(sender, "LogSendMail - sender is nil");
	assert(recipient, "LogSendMail - recipient is nil");
	assert(subject, "LogSendMail - subject is nil");
	assert(mailBody, "LogSendMail - mailBody is nil");
	assert(mailMoney, "LogSendMail - mailMoney is nil");	
	assert(attachments, "LogSendMail - attachments is nil");

	local logItem = {
		date = dateSend, timestamp = timestamp, -- 1st humamn readable, 2nd for easy computing
		sender = sender, recipient = recipient,
		subject = subject, body = mailBody,
		money = mailMoney, attachments = attachments
	};

	table.insert(maillog, logItem);
end

function printLogedMails(maillog)
	assert(maillog, "printLogedMails - maillog is nil");

	if #maillog == 0 then
		print(cYellow.."Mail log is empty.");
		return;
	end

	print(cYellow.."Last mails between alts:");

	for k,v in pairs(maillog) do

		local recievedText = "";

		if IsOlderOneHour(v.timestamp) then
			recievedText = cGreen1.."=="..cWhite;
		end

		local textMoney = "";
		if v.money > 0 then
			textMoney = " money: "..tostring(v.money);
		end

		local textAttachment = "";
		if #v.attachments > 0 then
			textAttachment = cLightBlue.." A:"..cWhite;

			for k1,v1 in pairs(v.attachments) do
				local _, itemLink = GetItemInfo(v1.id);
				local count = v1.count;

				if itemLink == nil then
					-- sometimes GetItemInfo returns nothing, because has no cache data yet
					-- just show that we do not have a data, on next call is everything ok
					itemLink = "???";
				end

				if count > 1 then
					textAttachment = textAttachment.. " "..tostring(count).."x"..itemLink;
				else
					textAttachment = textAttachment.." "..itemLink;
				end
			end
		end


		print(recievedText, k, cYellow..v.sender..cWhite.." => "..cYellow..v.recipient..cWhite.." s:"..v.subject.." "..cYellow..textMoney..cWhite..textAttachment);
	end
end

function GetItemEnchantements(itemLink)
	assert(itemLink, "GetItemEnchantements - itemLink is nil");

	local itemId, enchantId, gem1, gem2, gem3, gem4 = string.match(itemLink, "Hitem:(%d+):(%d*):(%d*):(%d*):(%d*):(%d*)");
	return itemId, enchantId, gem1, gem2, gem3, gem4;
end

-- return number enchantId (0 for on enchanting)
function GetItemEnchantId(itemLink)
	assert(itemLink, "GetItemEnchantements - itemLink is nil");

	local itemId, enchantId = GetItemEnchantements(itemLink);

	if tonumber(enchantId) then
		enchantId = tonumber(enchantId);
	else
		enchantId = 0;
	end		

	return enchantId;
end


function printEnchantableByArmorKitAlts()
	local slots = { "chest", "hands", "legs", "feet"};

	for charName,v in pairs(AltEquipSettings) do

		if v.items then

			for i = 1, #slots do
				local slotId = GetInventorySlotInfo(slots[i].."slot");
				local itemLink = v.items[slotId];
				
				if itemLink then
					local enchantId = GetItemEnchantId(itemLink);

					local msgEnchant = tostring(enchantId);

					if enchantId == 0 then
						msgEnchant = cRed..msgEnchant;
					elseif enchantId >= 15 and enchantId <= 18 then
						msgEnchant = cYellow..msgEnchant;
					else
						msgEnchant = cLightBlue..msgEnchant;
					end

					print(cYellow..charName..cWhite.." "..slots[i].." : "..msgEnchant);
				end
			end
		end
	end
end


-- Check if player items are enchanted by armor kits
function printMyEnchantmentsByArmorKits()
	local slots = { "chest", "hands", "legs", "feet"};

	for i = 1, #slots do
		local slotId = GetInventorySlotInfo(slots[i].."slot");
		local player = GetUnitName("player");
		local itemLink = AltEquipSettings[player].items[slotId];

		if itemLink then
			local enchantId = GetItemEnchantId(itemLink);

			-- armor kits have ids: 15,16,17,18, see https://wowwiki.fandom.com/wiki/EnchantId
			print(player, slots[i], enchantId);
		end
	end

end

frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("PLAYER_LOGOUT");
frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("CHAT_MSG_SKILL");
frame:RegisterEvent("BAG_UPDATE");

frame:RegisterEvent("CHAT_MSG_SYSTEM");
frame:RegisterEvent("TRADE_SKILL_UPDATE");
frame:RegisterEvent("CRAFT_UPDATE");
frame:RegisterEvent("TRAINER_UPDATE");


frame:SetScript("OnEvent", frame.OnEvent);
