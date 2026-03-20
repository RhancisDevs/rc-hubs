local RunService = game:GetService("RunService")

local count = 0
local conn

conn = RunService.Heartbeat:Connect(function()
    count += 1
    if count >= 10 then
        conn:Disconnect()
    end
end)

while count < 10 do
    RunService.Heartbeat:Wait()
end

if count < 10 then
    error("nope")
    return
end

local UI = loadstring(game:HttpGet("https://pastebin.com/raw/Rwva1iVH"))()
local HttpService = game:GetService("HttpService")
local KEY_FILE = "RcHub.json"

local GameLoaders = {
    [9186719164] = "https://vss.pandadevelopment.net/virtual/file/1d76e3704a58405f",
    [119987266683883] = "https://vss.pandadevelopment.net/virtual/file/af185d5c2e424cbc",
}

local function LoadData()
    local loader = GameLoaders[game.GameId]
    if loader then
        loadstring(game:HttpGet(loader))()
    else
        game:GetService("Players").LocalPlayer:Kick("Game not supported")
    end
end

local function SaveKey(key)
    if writefile then
        writefile(KEY_FILE, HttpService:JSONEncode({ key = key }))
    end
end

local function DeleteKey()
    if delfile and isfile and isfile(KEY_FILE) then
        delfile(KEY_FILE)
    end
end

local function LoadKey()
    if readfile and isfile and isfile(KEY_FILE) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(KEY_FILE))
        end)
        if success and type(result) == "table" and result.key then
            return result.key
        else
            DeleteKey()
        end
    end
    return nil
end

local function n(txt)
    UI:Notify({
        Title = "RcHub - Key System",
        Message = txt,
        Duration = 3
    })
end

local function DebugValidate(key)
    local success, result = pcall(function()
        return PandaV4Lite.validate(key)
    end)

    print("==== PANDA DEBUG START ====")
    print("pcall success:", success)
    print("result type:", typeof(result))

    if type(result) == "table" then
        for k, v in pairs(result) do
            print(k, v)
        end
    else
        print("raw result:", result)
    end

    print("==== PANDA DEBUG END ====")

    return success, result
end

print("Panda version:", PandaV4Lite and PandaV4Lite.getVersion and PandaV4Lite.getVersion())

local savedKey = LoadKey()

if savedKey then
    local success, result = DebugValidate(savedKey)

    if success and result and result.success then
        if result.isPremium then
            n("Script Load!")
            n("Status: Premium")
        else
            n("Script Load!")
            n("Status: Normal")
        end
        LoadData()
        return
    else
        DeleteKey()
    end
end

local Window = UI:CreateWindow({
    Title = "RC HUB | KEY SYSTEM",
    Subtitle = "1 Checkpoint · 24 Hours Key",
    Width = 400,
    Height = 250
})

Window:CreateInput({
    Placeholder = "Enter your key...",
    Callback = function(text)
        local success, result = DebugValidate(text)

        if success and result and result.success then
            SaveKey(text)
            Window:Destroy()

            n("Script Load!")

            if result.isPremium then
                n("Status: Premium")
            else
                n("Status: Normal")
            end

            LoadData()
        else
            n("Invalid Key: " .. (result and result.error or "Unknown error"))
        end
    end
})

Window:CreateButton({
    Text = "Get Key",
    Callback = function()
        local success, result = pcall(function()
            return PandaV4Lite.copyGetKeyUrl()
        end)

        if success and result and result.success then
            setclipboard(result.url)
            Window:Notify({
                Title = "Get Key",
                Message = "Link copied to clipboard.",
                Duration = 3
            })
        else
            Window:Notify({
                Title = "Error",
                Message = "Failed to get key URL.",
                Duration = 3
            })
        end
    end
})

Window:CreateButton({
    Text = "Discord",
    Callback = function()
        setclipboard("https://discord.gg/CpcnQ9DHng")
        Window:Notify({
            Title = "Discord",
            Message = "Discord link Copied.",
            Duration = 3
        })
    end
})
