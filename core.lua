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

SLASH_ALTEQUIP1 = "/alte";
SLASH_ALTEQUIP2 = "/altequip";

-- usage /alte charname
SlashCmdList["ALTEQUIP"] = function(msg)

	if msg == "" then
		print("Which character do you want to list?");
		printSavedCharacters();
	else
		if AltEquipSettings[msg] == nill then
			print("Do not know character ", msg, ".");
		else
			if AltEquipSettings[msg].items == nill then
				print("Character ", msg, " has no saved equipment.");
			else
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

			print("Equipment in ", msg, ":");
			for name in pairs(AltEquipSettings) do
				if AltEquipSettings[name]["items"] ~= nill then
					print(name, " l", AltEquipSettings[name]["level"], " ", AltEquipSettings[name]["class"], " ", AltEquipSettings[name]["items"][slotid]);
				end
			end

	end
end

SLASH_ALTSHOW1 = "/alts";
SLASH_ALTSHOW2 = "/altshow";
-- usage /altshow # display all known alts
SlashCmdList["ALTSHOW"] = function(msg)

	print("Found these alts:");
	printSavedCharacters();

end 

SLASH_ALTSKILLS1 = "/altsk";
SLASH_ALTSKILLS2 = "/altskills";
-- usage /altshow # display all known alts
SlashCmdList["ALTSKILLS"] = function(msg)

	if msg == "me" then
		printMySavedSkills();
	else
		print("Found these alts skills:");
		printSavedSkills();
	end
end 

SLASH_ALTPROFS1 = "/altp";
SLASH_ALTPROFS2 = "/altprofs";
-- usage /altshow # display all known alts
SlashCmdList["ALTPROFS"] = function(msg)

	if msg == "me" then
		printMySavedProfessions();
	else
		print("Found these alts professions:");
		printSavedProfessions();
	end
end 



function printSavedCharacters()
	for name in pairs(AltEquipSettings) do
		print(name, " l", AltEquipSettings[name]["level"], " ", AltEquipSettings[name]["class"]);
	end
end


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

function printMySavedProfessions()
	local player = GetUnitName("player");

		if AltEquipSettings[player] ~= nill and AltEquipSettings[player]["profs"] ~= nill then
			print("Found these professions:");
			for prof in pairs(AltEquipSettings[player]["profs"]) do
				if contains(primaryProfessions, prof) and AltEquipSettings[player]["profs"][prof].level ~= nill then
					print(prof, AltEquipSettings[player]["profs"][prof].level);
				end
			end

		end

end

function printSavedProfessions()
	for name in pairs(AltEquipSettings) do
		if AltEquipSettings[name]["profs"] ~= nill then
			for prof in pairs(AltEquipSettings[name]["profs"]) do
				if contains(primaryProfessions, prof) and AltEquipSettings[name]["profs"][prof].level ~= nill then
					print(name, "-", prof, AltEquipSettings[name]["profs"][prof].level);
				end
			end

		end
	end
end


function printMySavedSkills()
	local player = GetUnitName("player");

		if AltEquipSettings[player] ~= nill and AltEquipSettings[player]["profs"] ~= nill then
			print("Found these skills:");
			for prof in pairs(AltEquipSettings[player]["profs"]) do
				if AltEquipSettings[player]["profs"][prof].level ~= nill then
					print(prof, AltEquipSettings[player]["profs"][prof].level);
				end
			end

		end

end

function printSavedSkills()
	for name in pairs(AltEquipSettings) do
		if AltEquipSettings[name]["profs"] ~= nill then
			for prof in pairs(AltEquipSettings[name]["profs"]) do
				if AltEquipSettings[name]["profs"][prof].level ~= nill then
					print(name, "-", prof, AltEquipSettings[name]["profs"][prof].level);
				end
			end

		end
	end
end



local frame = CreateFrame("FRAME");

function frame:OnEvent(event, arg1)

	if event == "ADDON_LOADED" and arg1 == "AltEquip" then
		if AltEquipSettings == nill then
			AltEquipSettings = {};
		end

	elseif event == "PLAYER_ENTERING_WORLD" then
		UpdatePlayerData(AltEquipSettings);

		if AltEquipSettings[GetUnitName("player")]["items"] == nill then
		-- sometimes equipment data are not loaded yet,
		-- we do not want to rewrite last equipment data
		-- so update now only if we do not have any data saved yet 
			UpdatePlayerEquipment(AltEquipSettings);

		-- because we do not have complete data yet,
		-- register for some event that happen very soon, eg. update of BAGS = dirty solution
			frame:RegisterEvent("BAG_UPDATE");
		end

	elseif event == "PLAYER_EQUIPMENT_CHANGED" then
		-- save new equipment data
		UpdatePlayerEquipment(AltEquipSettings);

	elseif event == "BAG_UPDATE" then
		-- we use this event only once for the first time and deregister
		UpdatePlayerEquipment(AltEquipSettings);
		frame:UnregisterEvent("BAG_UPDATE");
	
	elseif event == "CHAT_MSG_SKILL" then
			UpdatePlayerProfs(AltEquipSettings, arg1);


	elseif event == "PLAYER_LOGOUT" then
		UpdatePlayerData(AltEquipSettings);
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

	if setts[player] == nill then
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

	if profession == nill or proflevel == nill then
		return;
	end

	if setts[player]["profs"] == nill then
		setts[player]["profs"] = {};
	end

	if setts[player]["profs"][profession] == nill then
		setts[player]["profs"][profession] = {};
	end

	setts[player]["profs"][profession].level = proflevel;

end

frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("PLAYER_LOGOUT");
frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("CHAT_MSG_SKILL");

frame:SetScript("OnEvent", frame.OnEvent);
