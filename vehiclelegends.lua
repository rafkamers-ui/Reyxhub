--[[
    🚗 Vehicle Legends Pro Hub v2.1.0
    Repo: rafkamers-ui/reyxhub
    Auto Update | Auto-detect HP/PC
    UI: LinoriaLib
]]

-- ========== KONFIGURASI ==========
local SCRIPT_VERSION = "2.1.0"
local SCRIPT_URL = "https://raw.githubusercontent.com/rafkamers-ui/reyxhub/main/vehiclelegends.lua"
local VERSION_URL = "https://raw.githubusercontent.com/rafkamers-ui/reyxhub/main/vehiclelegends.version"

-- ========== SERVICES ==========
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- ========== AUTO-DETECT DEVICE ==========
local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local IS_PC = UserInputService.KeyboardEnabled and not UserInputService.TouchEnabled
local VIEWPORT = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
local IS_SMALL = VIEWPORT.X < 800

local TAB_PADDING = IS_MOBILE and 6 or 8
local MENU_FADE = IS_MOBILE and 0.15 or 0.2

-- ========== LOAD LIBRARY ==========
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Progoonerfrfr/LinoriaLib/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Progoonerfrfr/LinoriaLib/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/Progoonerfrfr/LinoriaLib/main/addons/SaveManager.lua"))()

-- ========== DEBUG ==========
local DEBUG = true
local function log(...)
    if DEBUG then print("[VEHICLE LEGENDS] ", ...) end
end

local function safeCall(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then log("ERROR: " .. tostring(err)) end
    return ok, err
end

-- ========== CEK UPDATE ==========
task.spawn(function()
    safeCall(function()
        local latest = game:HttpGet(VERSION_URL)
        if latest and latest:gsub("%s", "") ~= SCRIPT_VERSION then
            Library:Notify("⚠️ Versi baru! Update otomatis...", 5)
            task.wait(2)
            loadstring(game:HttpGet(SCRIPT_URL))()
        end
    end)
end)

-- ========== WINDOW ==========
local Window = Library:CreateWindow({
    Title = "🚗 Vehicle Legends | v" .. SCRIPT_VERSION .. " | " .. (IS_MOBILE and "📱" or "💻"),
    Center = true,
    AutoShow = true,
    TabPadding = TAB_PADDING,
    MenuFadeTime = MENU_FADE
})

-- ========== TABS ==========
local Tabs = {
    Main = Window:AddTab("Main"),
    Race = Window:AddTab("Race"),
    Vehicle = Window:AddTab("Vehicle"),
    Visual = Window:AddTab("Visual"),
    Teleport = Window:AddTab("TP"),
    Misc = Window:AddTab("Misc"),
    Settings = Window:AddTab("Config")
}

-- ============================================================
-- MAIN
-- ============================================================
local MainGroup = Tabs.Main:AddLeftGroupbox("Auto Farm")

MainGroup:AddToggle("AutoFarmMoney", {
    Text = "Auto Farm Money",
    Default = false,
    Tooltip = "Mengemudi otomatis"
})

MainGroup:AddSlider("FarmSpeed", {
    Text = "Farm Speed (detik)",
    Default = 3,
    Min = 1,
    Max = 15,
    Rounding = 0,
    Compact = false
})

MainGroup:AddToggle("AutoCollect", {
    Text = "Auto Collect Items",
    Default = false
})

-- ============================================================
-- RACE
-- ============================================================
local RaceGroup = Tabs.Race:AddLeftGroupbox("Race Settings")

RaceGroup:AddDropdown("RaceSelect", {
    Values = {"Race 1", "Race 2", "Race 3", "Race 4", "Race 5", "Race 6", "Offroad 1", "Offroad 2", "Water Race", "Air Race"},
    Default = 1,
    Multi = false,
    Text = "Pilih Race"
})

RaceGroup:AddToggle("AutoRace", {
    Text = "Auto Join Race",
    Default = false
})

RaceGroup:AddToggle("AutoWin", {
    Text = "Auto Win Race",
    Default = false
})

RaceGroup:AddButton("Join Race Sekarang", function()
    Library:Notify("Mencoba join race...", 2)
end)

-- ============================================================
-- VEHICLE
-- ============================================================
local VehicleGroup = Tabs.Vehicle:AddLeftGroupbox("Vehicle Mods")

VehicleGroup:AddToggle("SpeedHack", {
    Text = "Speed Hack",
    Default = false
})

VehicleGroup:AddSlider("SpeedValue", {
    Text = "Speed Multiplier",
    Default = 2,
    Min = 1,
    Max = 10,
    Rounding = 0
})

VehicleGroup:AddToggle("GodMode", {
    Text = "God Mode (Kendaraan)",
    Default = false
})

VehicleGroup:AddToggle("InfiniteBoost", {
    Text = "Infinite Boost",
    Default = false
})

VehicleGroup:AddToggle("UnlockCars", {
    Text = "Unlock All Cars",
    Default = false
})

-- ============================================================
-- VISUAL
-- ============================================================
local VisualGroup = Tabs.Visual:AddLeftGroupbox("ESP & Visual")

VisualGroup:AddToggle("ESP", {
    Text = "Player ESP",
    Default = false
})

VisualGroup:AddToggle("FullBright", {
    Text = "Full Bright",
    Default = false
})

-- ============================================================
-- TELEPORT
-- ============================================================
local TpGroup = Tabs.Teleport:AddLeftGroupbox("Teleport")

TpGroup:AddButton("Teleport ke Spawn", function()
    safeCall(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(0, 5, 0)
        end
    end)
end)

TpGroup:AddDropdown("PlayerList", {
    Values = {},
    Default = 1,
    Multi = false,
    Text = "Pilih Pemain"
})

TpGroup:AddButton("Teleport ke Pemain", function()
    safeCall(function()
        local sel = Toggles.PlayerList.Value
        if sel then
            local target = Players:FindFirstChild(sel)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
            end
        end
    end)
end)

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
    Text = "Anti AFK",
    Default = true
})

MiscGroup:AddButton("Rejoin Server", function()
    TeleportService:Teleport(game.PlaceId)
end)

-- ============================================================
-- SETTINGS
-- ============================================================
local SettingsGroup = Tabs.Settings:AddLeftGroupbox("UI Settings")

SettingsGroup:AddButton("Unload Script", function()
    Library:Unload()
end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- ============================================================
-- LOGIC
-- ============================================================

Toggles.AutoFarmMoney:OnChanged(function()
    if Toggles.AutoFarmMoney.Value then
        task.spawn(function()
            while Toggles.AutoFarmMoney.Value do
                safeCall(function()
                    local char = LocalPlayer.Character
                    if char then
                        local vehicle = char:FindFirstChildOfClass("VehicleSeat")
                        if vehicle then
                            vehicle.Throttle = 1
                            vehicle.Steer = math.sin(tick())
                        end
                    end
                end)
                task.wait(Toggles.FarmSpeed.Value)
            end
        end)
    end
end)

Toggles.AutoCollect:OnChanged(function()
    if Toggles.AutoCollect.Value then
        task.spawn(function()
            while Toggles.AutoCollect.Value do
                safeCall(function()
                    for _, item in ipairs(workspace:GetChildren()) do
                        if item:IsA("BasePart") and item.Name ~= "Baseplate" then
                            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                                LocalPlayer.Character.HumanoidRootPart.CFrame = item.CFrame
                                task.wait(0.2)
                            end
                        end
                    end
                end)
                task.wait(1)
            end
        end)
    end
end)

Toggles.SpeedHack:OnChanged(function()
    safeCall(function()
        local speed = Toggles.SpeedHack.Value and Sliders.SpeedValue.Value or 1
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = 16 * speed end
            local veh = char:FindFirstChildOfClass("VehicleSeat")
            if veh then veh.MaxSpeed = veh.MaxSpeed * speed end
        end
    end)
end)

Toggles.GodMode:OnChanged(function()
    safeCall(function()
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.MaxHealth = Toggles.GodMode.Value and math.huge or 100
                hum.Health = hum.MaxHealth
            end
        end
    end)
end)

Toggles.InfiniteBoost:OnChanged(function()
    safeCall(function()
        local char = LocalPlayer.Character
        if char then
            local veh = char:FindFirstChildOfClass("VehicleSeat")
            if veh then
                veh:SetAttribute("Boost", Toggles.InfiniteBoost.Value and 9999 or 0)
            end
        end
    end)
end)

Toggles.UnlockCars:OnChanged(function()
    safeCall(function()
        if Toggles.UnlockCars.Value then
            Library:Notify("Unlock All Cars (client-side).", 3)
        end
    end)
end)

Toggles.ESP:OnChanged(function()
    task.spawn(function()
        while Toggles.ESP.Value do
            safeCall(function()
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character then
                        local head = plr.Character:FindFirstChild("Head")
                        if head and not head:FindFirstChild("ESPName") then
                            local bb = Instance.new("BillboardGui")
                            bb.Name = "ESPName"
                            bb.Size = UDim2.new(0, 100, 0, 50)
                            bb.Adornee = head
                            bb.Parent = head
                            local txt = Instance.new("TextLabel")
                            txt.Size = UDim2.new(1, 0, 1, 0)
                            txt.BackgroundTransparency = 1
                            txt.Text = plr.Name
                            txt.TextColor3 = Color3.new(1, 0, 0)
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

Toggles.AntiAFK:OnChanged(function()
    if Toggles.AntiAFK.Value then
        LocalPlayer.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    end
end)

Library:Notify("🚗 Vehicle Legends v" .. SCRIPT_VERSION .. " Loaded! " .. (IS_MOBILE and "📱" or "💻"), 3)
log("Loaded. Device: " .. (IS_MOBILE and "Mobile" or "PC"))
