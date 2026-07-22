--[[
    LAPEL 2026 - MM2 Script
    RVIALS kalıbı birebir uygulanmıştır
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- GÜVENLİ GUI HEDEFİ
local function GetUI()
    local ok, res = pcall(function() return game:GetService("CoreGui") end)
    return (ok and res) or LocalPlayer:WaitForChild("PlayerGui")
end

-- Eski GUI varsa sil
if GetUI():FindFirstChild("Lapel2026") then GetUI().Lapel2026:Destroy() end

-- TEK ScreenGui
local SG = Instance.new("ScreenGui", GetUI())
SG.Name = "Lapel2026"
SG.IgnoreGuiInset = true
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.DisplayOrder = 999

-- Yardımcılar
local function Round(obj, r)
    local c = Instance.new("UICorner", obj)
    c.CornerRadius = UDim.new(0, r or 8)
end
local function Stroke(obj, col, th)
    local s = Instance.new("UIStroke", obj)
    s.Color = col or Color3.new(1,1,1)
    s.Thickness = th or 1.2
end

-- ============================================
-- TOGGLE BUTONU (RVIALS kalıbı)
-- ============================================
local Tgl = Instance.new("TextButton", SG)
Tgl.Name = "Toggle"
Tgl.Size = UDim2.new(0, 75, 0, 35)
Tgl.Position = UDim2.new(0, 10, 1, -45)
Tgl.Text = "LAPEL"
Tgl.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Tgl.TextColor3 = Color3.fromRGB(255, 200, 60)
Tgl.Font = Enum.Font.GothamBold
Tgl.TextSize = 13
Round(Tgl, 8)
Stroke(Tgl, Color3.fromRGB(180, 30, 30), 1.5)

-- ============================================
-- ANA GUI (RVIALS kalıbı: Main frame başta oluşur, Visible=false)
-- ============================================
local Main = Instance.new("Frame", SG)
Main.Name = "Main"
Main.Size = UDim2.new(0, 360, 0, 460)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Color3.fromRGB(18, 8, 8)
Main.Visible = false
Main.Active = true
Main.Draggable = true
Round(Main, 12)
Stroke(Main, Color3.fromRGB(180, 30, 30), 2)

-- ============================================
-- TOGGLE BAĞLANTISI (RVIALS'in birebir kalıbı)
-- ============================================
Tgl.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

-- Test mesajı
print("[Lapel 2026] Toggle hazır. Tıkla!")

-- ============================================
-- ANA GUI İÇERİĞİ (basit, RVIALS stili)
-- ============================================

-- Başlık çubuğu
local TitleBar = Instance.new("Frame", Main)
TitleBar.Size = UDim2.new(1, 0, 0, 44)
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 5, 5)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 5
Round(TitleBar, 12)

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🎄 LAPEL 2026 🎄"
Title.TextColor3 = Color3.fromRGB(255, 200, 60)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 6

-- Kapat butonu
local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -38, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(120, 20, 20)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.ZIndex = 6
Round(CloseBtn, 8)
CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
end)

-- İçerik alanı
local Container = Instance.new("Frame", Main)
Container.Name = "Container"
Container.Size = UDim2.new(1, -16, 1, -54)
Container.Position = UDim2.new(0, 8, 0, 50)
Container.BackgroundTransparency = 1
Container.ZIndex = 4

-- Kategori listesi
local categories = {
    {id = "esp",     icon = "👁",  name = "ESP",                color = Color3.fromRGB(60, 130, 255)},
    {id = "aimbot",  icon = "🔫",  name = "Otomatik Nişan",      color = Color3.fromRGB(255, 100, 60)},
    {id = "premium", icon = "⭐",  name = "Premium (Key)",       color = Color3.fromRGB(255, 200, 60)},
    {id = "skin",    icon = "🎭",  name = "Skin Hilesi",         color = Color3.fromRGB(200, 80, 200)},
    {id = "lang",    icon = "🌐",  name = "Dil: TR / RU / EN",  color = Color3.fromRGB(150, 150, 150)},
}

local UIListLayout = Instance.new("UIListLayout", Container)
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function makeCategoryCard(cat)
    local card = Instance.new("TextButton", Container)
    card.Size = UDim2.new(1, -8, 0, 50)
    card.BackgroundColor3 = Color3.fromRGB(30, 12, 12)
    card.Text = ""
    card.AutoButtonColor = true
    card.ZIndex = 5
    Round(card, 8)
    Stroke(card, cat.color, 1)
    
    local icon = Instance.new("TextLabel", card)
    icon.Size = UDim2.new(0, 50, 1, 0)
    icon.BackgroundTransparency = 1
    icon.Text = cat.icon
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 24
    icon.TextColor3 = Color3.new(1,1,1)
    icon.ZIndex = 6
    
    local name = Instance.new("TextLabel", card)
    name.Size = UDim2.new(1, -60, 1, 0)
    name.Position = UDim2.new(0, 55, 0, 0)
    name.BackgroundTransparency = 1
    name.Text = cat.name
    name.TextColor3 = Color3.new(1, 1, 1)
    name.Font = Enum.Font.GothamBold
    name.TextSize = 13
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.ZIndex = 6
    
    card.MouseButton1Click:Connect(function()
        print("[Lapel] " .. cat.name .. " tıklandı (henüz bağlı değil)")
    end)
end

for _, cat in ipairs(categories) do
    makeCategoryCard(cat)
end

-- ============================================
-- ESP SİSTEMİ (basit)
-- ============================================
local EspEnabled = false

local function getRole(player)
    if not player.Character then return nil end
    for _, tool in ipairs(player.Character:GetChildren()) do
        if tool:IsA("Tool") then
            local n = tool.Name:lower()
            if n:find("knife") or n:find("blade") or n:find("sword") then
                return "Murderer"
            end
        end
    end
    for _, tool in ipairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local n = tool.Name:lower()
            if n:find("knife") or n:find("blade") or n:find("sword") then
                return "Murderer"
            end
        end
    end
    return "Innocent"
end

local function setupESP(player)
    if player == LocalPlayer then return end
    if player.Character and not player.Character:FindFirstChild("LapelESP") then
        local hl = Instance.new("Highlight")
        hl.Name = "LapelESP"
        hl.FillColor = Color3.fromRGB(50, 220, 80)
        hl.OutlineColor = Color3.fromRGB(50, 220, 80)
        hl.FillTransparency = 0.5
        hl.Enabled = false
        hl.Parent = player.Character
    end
end

RunService.RenderStepped:Connect(function()
    if not EspEnabled then return end
    if game.PlaceId ~= 142823291 then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            setupESP(p)
            local hl = p.Character:FindFirstChild("LapelESP")
            if hl then
                hl.Enabled = true
                local role = getRole(p)
                if role == "Murderer" then
                    hl.FillColor = Color3.fromRGB(255, 50, 50)
                    hl.OutlineColor = Color3.fromRGB(255, 50, 50)
                else
                    hl.FillColor = Color3.fromRGB(50, 220, 80)
                    hl.OutlineColor = Color3.fromRGB(50, 220, 80)
                end
            end
        end
    end
end)

-- ESP toggle butonu
local espBtn = Container:FindFirstChild("ESP") or Container:GetChildren()[1]
if espBtn then
    espBtn.MouseButton1Click:Connect(function()
        EspEnabled = not EspEnabled
        print("[Lapel] ESP " .. (EspEnabled and "açıldı" or "kapatıldı"))
        if not EspEnabled then
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("LapelESP") then
                    p.Character.LapelESP.Enabled = false
                end
            end
        end
    end)
end

print("[Lapel 2026 v1.7] Yüklendi! Toggle sol altta.")
