
-- Do NOT alter this manually. Use ingame "/gw set [congratz, welcome] [1-10]" to change these values!
-- DEFAULTS:
GUILD_WELCOME_TEXT = {
	"Welcome", -- 1
	"Welcome", -- 2
	"Welcome", -- 3
	"Welcome", -- 4
	"Welcome", -- 5
	"Welcome", -- 6
	"Welcome", -- 7
	"Welcome", -- 8
	"Welcome", -- 9
	"Welcome", -- 10
}
GUILD_CONGRATZ_TEXT = {
	"gz", -- 1
	"gz", -- 2
	"gz", -- 3
	"gz", -- 4
	"gz", -- 5
	"gz", -- 6
	"gz", -- 7
	"gz", -- 8
	"gz", -- 9
	"gz", -- 10
}

local events = CreateFrame("Frame")
events:RegisterEvent("GUILD_ROSTER_UPDATE")
events:RegisterEvent("PLAYER_ENTERING_WORLD")  
events:RegisterEvent("PLAYER_LOGIN")

local currentAmount
local newAmount
local player = select(1, UnitName("player"))
local isInitialLogin = true

local initialGuildRosterUpdate = true 

local initialGuildRosterUpdate = true -- Flag to track the initial guild roster update

local function handleEvents(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        if isInitialLogin then
            isInitialLogin = false
            return
        end
    end

    if event == "GUILD_ROSTER_UPDATE" then
        GuildRoster()
        
        if initialGuildRosterUpdate then
            initialGuildRosterUpdate = false
            currentAmount = GetNumGuildMembers() -- Store the initial member count
            return
        end

        -- Handle the case of new members
        newAmount = GetNumGuildMembers()
        if newAmount and currentAmount and newAmount > currentAmount then
            events:UnregisterEvent("GUILD_ROSTER_UPDATE")
            local e = 0
            local updateListener = CreateFrame("Frame")
            updateListener:SetScript("OnUpdate", function(self, elapsed)
                e = e + elapsed
                if e >= 3 then
                    e = 0
                    local num = tostring(GetTime())
                    num = (string.sub(num, #num, #num)) + 1

                    if event == "GUILD_ROSTER_UPDATE" then
                        SendChatMessage(GUILD_WELCOME_TEXT[num], "GUILD")
                    end

                    currentAmount = newAmount
                    events:RegisterEvent("GUILD_ROSTER_UPDATE")
                    self:SetScript("OnUpdate", nil)
                end
            end)
        elseif newAmount and currentAmount and newAmount < currentAmount then
            currentAmount = newAmount
        end
    end
end


events:SetScript("OnEvent", handleEvents)

local function printMessages()
    print("|cff40ff40Usage:")
    print("|cff40ff40/agm|r show [congratz, welcome]")
    print("|cff40ff40/agm|r set [congratz, welcome] [1-10] [new message]")
end

SLASH_AutoGuildMessage1 = "/agm"
SLASH_AutoGuildMessage2 = "/autoguild"
SLASH_AutoGuildMessage3 = "/automessage"
SLASH_AutoGuildMessage4 = "/autoguildmessage"
SlashCmdList["AutoGuildMessage"] = function(msg)
    local cmd, arg1, arg2 = string.split(" ", msg)
    if cmd then cmd = cmd:lower() end    
    if cmd == "show" and arg1 then -- show list
        arg1:lower()
        print("|cff40ff40Guild "..(arg1:gsub("^%l", string.upper)).." Messages:")
        if arg1 == "congratz" then arg1 = "GUILD_CONGRATZ_TEXT" elseif arg1 == "welcome" then arg1 = "GUILD_WELCOME_TEXT" else printMessages() return end    
        for k, v in pairs(_G[arg1]) do            
            print("|cff40ff40"..k..":|r "..v)
        end
    elseif cmd == "set" and arg1 and arg2 then -- adds element to next available space
        arg1:lower()
        if arg1 == "congratz" then arg1 = "GUILD_CONGRATZ_TEXT" elseif arg1 == "welcome" then arg1 = "GUILD_WELCOME_TEXT" else printMessages() return end
        arg2 = tonumber(arg2)
        if arg2 > 10 or arg2 < 1 then printMessages() return end
        local _, last = string.find(msg, arg2)
        if last then 
            msg = string.sub(msg, last + 1, #msg)
            msg = string.trim(msg)
            if _G[arg1][arg2] then _G[arg1][arg2] = msg end
            print("|cff40ff40"..arg2..":|r ".._G[arg1][arg2])
        end
    else -- show list of commands
        printMessages()
    end
end
