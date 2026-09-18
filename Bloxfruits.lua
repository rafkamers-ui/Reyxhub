--[[
    ⚔️ ReyX Hub Blox Fruits v1.0.0
    Repo: rafkamers-ui/reyxhub
    Auto Boss Sea 3 | V4 | ESP | Keyless
    UI: Fluent | Auto-detect HP/PC
]]

-- ========== KONFIGURASI ==========
local SCRIPT_VERSION = "1.0.0"
local SCRIPT_URL = "https://raw.githubusercontent.com/rafkamers-ui/reyxhub/main/bloxfruits.lua"
local VERSION_URL = "https://raw.githubusercontent.com/rafkamers-ui/reyxhub/main/bloxfruits.version"

-- ========== SERVICES ==========
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- ========== AUTO-DETECT DEVICE ==========
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local IS_PC = UserInputService.KeyboardEnabled and not UserInputService.TouchEnabled
local VIEWPORT = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
local IS_SMALL = VIEWPORT.X < 800

local UI_SIZE = IS_SMALL and UDim2.fromOffset(480, 360) or UDim2.fromOffset(620, 500)
local UI_ACRYLIC = IS_PC
local UI_TABWIDTH = IS_MOBILE and 130 or 160

-- ========== LOAD UI LIBRARY ==========
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- ========== DEBUG ==========
local DEBUG = true
local function log(...)
    if DEBUG then print("[REYX HUB] ", ...) end
end

local function safeCall(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then
        log("ERROR: " .. tostring(err))
        Fluent:Notify({ Title = "❌ Error", Content = tostring(err), Duration = 5 })
    end
    return ok, err
end

-- ========== REMOTE FINDER ==========
local function getRemote(name)
    local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:FindFirstChild("CommF_")
    if not remotes then return nil end
    return remotes:FindFirstChild(name)
end

local function invokeRemote(name, ...)
    local remote = getRemote(name)
    if remote then
        local ok, result = safeCall(function() return remote:InvokeServer(...) end)
        if ok then return result end
    end
    return nil
end

-- ========== CEK UPDATE ==========
task.spawn(function()
    safeCall(function()
        local latest = game:HttpGet(VERSION_URL)
        if latest and latest:gsub("%s", "") ~= SCRIPT_VERSION then
            Fluent:Notify({ Title = "⚠️ Update", Content = "Versi baru tersedia!", Duration = 5 })
            task.wait(2)
            loadstring(game:HttpGet(SCRIPT_URL))()
        end
    end)
end)

-- ========== WINDOW ==========
local Window = Fluent:CreateWindow({
    Title = "⚔️ ReyX Hub Blox Fruits",
    SubTitle = "v" .. SCRIPT_VERSION .. " | " .. (IS_MOBILE and "📱 Mobile" or "💻 PC"),
    TabWidth = UI_TABWIDTH,
    Size = UI_SIZE,
    Acrylic = UI_ACRYLIC,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- ========== TABS ==========
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    AutoFarm = Window:AddTab({ Title = "Farm", Icon = "sword" }),
    Boss = Window:AddTab({ Title = "Boss", Icon = "skull" }),
    V4 = Window:AddTab({ Title = "V4", Icon = "zap" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
    LocalPlayer = Window:AddTab({ Title = "Local", Icon = "user" }),
    Teleport = Window:AddTab({ Title = "TP", Icon = "map-pin" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "settings" }),
    Settings = Window:AddTab({ Title = "Config", Icon = "cog" })
}

-- ============================================================
-- MAIN
-- ============================================================
Tabs.Main:AddParagraph({
    Title = "⚔️ ReyX Hub Blox Fruits v" .. SCRIPT_VERSION,
    Content = "Device: " .. (IS_MOBILE and "📱 Mobile" or "💻 PC") ..
              "\nRemote: " .. (getRemote("CommF_") and "✅ OK" or "❌ Not Found") ..
              "\nExecutor: " .. (identifyexecutor and identifyexecutor() or "Unknown")
})

Tabs.Main:AddButton({
    Title = "🔄 Refresh Remote",
    Description = "Cek ulang koneksi remote",
    Callback = function()
        local r = getRemote("CommF_")
        Fluent:Notify({
            Title = r and "✅ Remote OK" or "❌ Not Found",
            Content = r and "CommF_ terdeteksi." or "Coba rejoin server.",
            Duration = 3
        })
    end
})

-- ============================================================
-- AUTO FARM
-- ============================================================
local FarmGroup = Tabs.AutoFarm:AddLeftGroupbox("Auto Farm")

FarmGroup:AddToggle("AutoFarmLevel", {
    Title = "Auto Farm Level",
    Description = "Farming level otomatis",
    Default = false
})

FarmGroup:AddToggle("AutoQuest", {
    Title = "Auto Quest",
    Description = "Otomatis ambil quest",
    Default = false
})

FarmGroup:AddToggle("AutoMastery", {
    Title = "Auto Mastery",
    Description = "Farming mastery",
    Default = false
})

FarmGroup:AddSlider("FarmSpeed", {
    Title = "Farm Speed (detik)",
    Default = 3,
    Min = 1,
    Max = 15,
    Rounding = 0
})

Toggles.AutoFarmLevel:OnChanged(function()
    if Toggles.AutoFarmLevel.Value then
        task.spawn(function()
            while Toggles.AutoFarmLevel.Value do
                safeCall(function() invokeRemote("CommF_", "Level") end)
                task.wait(Toggles.FarmSpeed.Value)
            end
        end)
    end
end)

Toggles.AutoQuest:OnChanged(function()
    if Toggles.AutoQuest.Value then
        task.spawn(function()
            while Toggles.AutoQuest.Value do
                safeCall(function() invokeRemote("CommF_", "StartQuest") end)
                task.wait(3)
            end
        end)
    end
end)

Toggles.AutoMastery:OnChanged(function()
    if Toggles.AutoMastery.Value then
        task.spawn(function()
            while Toggles.AutoMastery.Value do
                safeCall(function() invokeRemote("CommF_", "Mastery") end)
                task.wait(2)
            end
        end)
    end
end)

-- ============================================================
-- AUTO BOSS
-- ============================================================
local BossGroup = Tabs.Boss:AddLeftGroupbox("Auto Boss")

BossGroup:AddDropdown("BossSelect", {
    Title = "Pilih Boss",
    Description = "Boss yang ingin di-auto",
    Values = {
        "Sea 1 - All Bosses",
        "Sea 2 - All Bosses",
        "Sea 3 - Fish Island Boss",
        "Sea 3 - All Bosses",
        "Auto Kill All Boss",
        "Greybeard",
        "Katakuri V1",
        "Katakuri V2"
    },
    Default = "Sea 3 - Fish Island Boss",
    Multi = false
})

BossGroup:AddToggle("AutoBoss", {
    Title = "Auto Boss Farm",
    Description = "Farming boss otomatis",
    Default = false
})

BossGroup:AddSlider("BossFarmSpeed", {
    Title = "Boss Farm Speed (detik)",
    Default = 3,
    Min = 1,
    Max = 10,
    Rounding = 0
})

Toggles.AutoBoss:OnChanged(function()
    if Toggles.AutoBoss.Value then
        task.spawn(function()
            while Toggles.AutoBoss.Value do
                safeCall(function()
                    local sel = Toggles.BossSelect.Value
                    log("Auto Boss: " .. sel)
                    if sel == "Sea 3 - Fish Island Boss" then
                        invokeRemote("CommF_", "Boss", "Fish Island")
                    elseif sel == "Auto Kill All Boss" then
                        invokeRemote("CommF_", "Boss", "All")
                    elseif sel == "Greybeard" then
                        invokeRemote("CommF_", "Boss", "Greybeard")
                    elseif sel == "Katakuri V1" then
                        invokeRemote("CommF_", "Boss", "Katakuri")
                    elseif sel == "Katakuri V2" then
                        invokeRemote("CommF_", "Boss", "KatakuriV2")
                    else
                        invokeRemote("CommF_", "Boss", sel)
                    end
                end)
                task.wait(Toggles.BossFarmSpeed.Value)
            end
        end)
    end
end)

-- ============================================================
-- V4
-- ============================================================
local V4Group = Tabs.V4:AddLeftGroupbox("V4 / Race")

V4Group:AddToggle("AutoV4", {
    Title = "Auto V4 Trial",
    Description = "Otomatis V4 trial",
    Default = false
})

V4Group:AddToggle("AutoRaceV4", {
    Title = "Auto Race V4",
    Description = "Otomatis Race V4",
    Default = false
})

V4Group:AddButton({
    Title = "Teleport ke V4 Trial",
    Description = "Teleport ke V4 trial",
    Callback = function()
        safeCall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(0, 500, 0)
                Fluent:Notify({ Title = "V4 Trial", Content = "Teleporting...", Duration = 2 })
            end
        end)
    end
})

Toggles.AutoV4:OnChanged(function()
    if Toggles.AutoV4.Value then
        task.spawn(function()
            while Toggles.AutoV4.Value do
                safeCall(function() invokeRemote("CommF_", "V4Trial") end)
                task.wait(2)
            end
        end)
    end
end)

Toggles.AutoRaceV4:OnChanged(function()
    if Toggles.AutoRaceV4.Value then
        task.spawn(function()
            while Toggles.AutoRaceV4.Value do
                safeCall(function() invokeRemote("CommF_", "RaceV4") end)
                task.wait(2)
            end
        end)
    end
end)

-- ============================================================
-- ESP
-- ============================================================
local ESPGroup = Tabs.ESP:AddLeftGroupbox("ESP")

ESPGroup:AddToggle("PlayerESP", {
    Title = "Player ESP",
    Description = "Nama pemain",
    Default = false
})

ESPGroup:AddToggle("FruitESP", {
    Title = "Fruit ESP",
    Description = "Lokasi Devil Fruit",
    Default = false
})

ESPGroup:AddToggle("ChestESP", {
    Title = "Chest ESP",
    Description = "Lokasi chest",
    Default = false
})

ESPGroup:AddToggle("BossESP", {
    Title = "Boss ESP",
    Description = "Lokasi boss",
    Default = false
})

Toggles.PlayerESP:OnChanged(function()
    task.spawn(function()
        while Toggles.PlayerESP.Value do
            safeCall(function()
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character then
                        local head = plr.Character:FindFirstChild("Head")
                        if head and not head:FindFirstChild("ESPName") then
                            local bb = Instance.new("BillboardGui")
                            bb.Name = "ESPName"
                            bb.Size = UDim2.new(0, 120, 0, 50)
                            bb.Adornee = head
                            bb.Parent = head
                            local txt = Instance.new("TextLabel")
                            txt.Size = UDim2.new(1, 0, 1, 0)
                            txt.BackgroundTransparency = 1
                            txt.Text = plr.Name
                            txt.TextColor3 = Color3.new(1, 0, 0)
                            txt.TextStrokeTransparency = 0
                            txt.Parent = bb
                        end
                    end
                end
            end)
            task.wait(1)
        end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character then
                local head = plr.Character:FindFirstChild("Head")
                if head then
                    local esp = head:FindFirstChild("ESPName")
                    if esp then esp:Destroy() end
                end
            end
        end
    end)
end)

-- ============================================================
-- LOCAL PLAYER
-- ============================================================
local LocalGroup = Tabs.LocalPlayer:AddLeftGroupbox("Local Player")

LocalGroup:AddToggle("InfiniteJump", {
    Title = "Infinite Jump",
    Description = "Lompat tanpa batas",
    Default = false
})

LocalGroup:AddToggle("SpeedHack", {
    Title = "Speed Hack",
    Description = "Kecepatan karakter",
    Default = false
})

LocalGroup:AddSlider("SpeedValue", {
    Title = "Speed Multiplier",
    Default = 2,
    Min = 1,
    Max = 10,
    Rounding = 0
})

LocalGroup:AddToggle("NoClip", {
    Title = "No Clip",
    Description = "Tembus dinding",
    Default = false
})

Toggles.InfiniteJump:OnChanged(function()
    if Toggles.InfiniteJump.Value then
        UserInputService.JumpRequest:Connect(function()
            safeCall(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChildOfClass("Humanoid") then
                    char.Humanoid:ChangeState("Jumping")
                end
            end)
        end)
    end
end)

Toggles.SpeedHack:OnChanged(function()
    safeCall(function()
        local speed = Toggles.SpeedHack.Value and Toggles.SpeedValue.Value or 1
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char.Humanoid.WalkSpeed = 16 * speed
        end
    end)
end)

Toggles.NoClip:OnChanged(function()
    safeCall(function()
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = not Toggles.NoClip.Value
                end
            end
        end
    end)
end)

-- ============================================================
-- TELEPORT
-- ============================================================
local TpGroup = Tabs.Teleport:AddLeftGroupbox("Teleport")

TpGroup:AddButton({
    Title = "Teleport ke Spawn",
    Description = "Kembali ke spawn",
    Callback = function()
        safeCall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(0, 5, 0)
            end
        end)
    end
})

TpGroup:AddDropdown("PlayerList", {
    Title = "Pilih Pemain",
    Values = {},
    Default = 1,
    Multi = false
})

TpGroup:AddButton({
    Title = "Teleport ke Pemain",
    Callback = function()
        safeCall(function()
            local sel = Toggles.PlayerList.Value
            if sel then
                local target = Players:FindFirstChild(sel)
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
                end
            end
        end)
    end
})

task.spawn(function()
    while true do
        safeCall(function()
            local names = {}
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer then table.insert(names, plr.Name) end
            end
            Toggles.PlayerList:SetValues(names)
        end)
        task.wait(3)
    end
end)

-- ============================================================
-- MISC
-- ============================================================
local MiscGroup = Tabs.Misc:AddLeftGroupbox("Misc")

MiscGroup:AddToggle("AntiAFK", {
    Title = "Anti AFK",
    Description = "Cegah kick AFK",
    Default = true
})

MiscGroup:AddToggle("FullBright", {
    Title = "Full Bright",
    Description = "Terangi map",
    Default = false
})

MiscGroup:AddButton({
    Title = "Rejoin Server",
    Description = "Masuk server baru",
    Callback = function()
        TeleportService:Teleport(game.PlaceId)
    end
})

Toggles.AntiAFK:OnChanged(function()
    if Toggles.AntiAFK.Value then
        LocalPlayer.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    end
end)

Toggles.FullBright:OnChanged(function()
    safeCall(function()
        if Toggles.FullBright.Value then
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 2
            Lighting.ClockTime = 12
        else
            Lighting.Ambient = Color3.fromRGB(0, 0, 0)
            Lighting.Brightness = 1
        end
    end)
end)

-- ============================================================
-- SETTINGS
-- ============================================================
local SettingsGroup = Tabs.Settings:AddLeftGroupbox("UI Settings")

SettingsGroup:AddButton({
    Title = "Unload Script",
    Description = "Matikan script",
    Callback = function()
        Fluent:Unload()
    end
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("ReyxHub")
SaveManager:SetFolder("ReyxHub/Configs")
SaveManager:BuildConfigSection(Tabs.Settings)
InterfaceManager:ApplyToTab(Tabs.Settings)

-- ========== NOTIFIKASI ==========
Fluent:Notify({
    Title = "⚔️ ReyX Hub v" .. SCRIPT_VERSION,
    Content = "Loaded! Device: " .. (IS_MOBILE and "📱" or "💻"),
    Duration = 5
})

log("Script loaded. Device: " .. (IS_MOBILE and "Mobile" or "PC"))
