--[[
    ╔════════════════════════════════════════════════════╗
    ║              🎄 LAPEL 2026 GUI 🎄                  ║
    ║         Murder Mystery 2 — Mobile Edition          ║
    ║   ESP · Auto-Shoot · Skin Changer · Key System     ║
    ╚════════════════════════════════════════════════════╝
    
    Base : RVIALS V24 (toggle kalıbı)
    API  : https://lapel-2026-keys.vercel.app
]]

----------------------------------------------------------------
-- SERVICES
----------------------------------------------------------------
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInputService= game:GetService("UserInputService")
local TweenService   = game:GetService("TweenService")
local HttpService    = game:GetService("HttpService")
local LocalPlayer    = Players.LocalPlayer
local Camera         = workspace.CurrentCamera
local PlaceId_MM2    = 142823291
local API_BASE       = "https://lapel-2026-keys.vercel.app"
local DEMO_KEY       = "LAPEL-JVL9-9CMZ-SWVA"

-- HTTP (delta + fallback)
local function httpRequest(opts)
    local ok, res = pcall(function()
        if syn and syn.request then return syn.request(opts) end
        if request then return request(opts) end
        if http and http.request then return http.request(opts) end
        if http_request then return http_request(opts) end
    end)
    return ok and res or nil
end

-- Güvenli GUI parent
local function GetUI()
    local ok, res = pcall(function() return game:GetService("CoreGui") end)
    return (ok and res) or LocalPlayer:WaitForChild("PlayerGui")
end

----------------------------------------------------------------
-- YARDIMCILAR
----------------------------------------------------------------
local function Round(obj, r)
    local c = Instance.new("UICorner", obj)
    c.CornerRadius = UDim.new(0, r or 8)
end
local function Stroke(obj, col, th)
    local s = Instance.new("UIStroke", obj)
    s.Color = col or Color3.new(1,1,1)
    s.Thickness = th or 1.2
end
local function Make(class, props, parent)
    local inst = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            pcall(function() inst[k] = v end)
        end
    end
    if parent then inst.Parent = parent end
    return inst
end

----------------------------------------------------------------
-- DİL SİSTEMİ
----------------------------------------------------------------
local Lang = {
    tr = {app="🎄 LAPEL 2026 🎄", cat="Kategoriler", esp="ESP", aim="Otomatik Nişan",
          prem="Premium (Key)", skin="Skin Hilesi", lang="Dil: TR / RU / EN",
          back="← Geri", enter_key="Keyini Gir", activate="Aktif Et",
          on="AÇ", off="KAP", locked="🔒 Premium Kilitli",
          msg="Premium özellikler key sistemi ile korunuyor.\nKey girerek 24 saatlik erişim açabilirsin.",
          valid="✅ Key geçerli!", invalid="❌ Key geçersiz", expired="⏰ Süresi dolmuş",
          connecting="Bağlanılıyor...", killer="Katil Rengi", civ="Sivil Rengi", sheriff="Şerif Rengi"},
    ru = {app="🎄 LAPEL 2026 🎄", cat="Категории", esp="ESP", aim="Авто-стрельба",
          prem="Премиум (Ключ)", skin="Скин-чейнджер", lang="Язык: TR / RU / EN",
          back="← Назад", enter_key="Введите ключ", activate="Активировать",
          on="ВКЛ", off="ВЫКЛ", locked="🔒 Премиум заблокирован",
          msg="Премиум функции защищены ключом.\nВведите ключ для 24-часового доступа.",
          valid="✅ Ключ действителен!", invalid="❌ Неверный ключ", expired="⏰ Истёк",
          connecting="Подключение...", killer="Цвет Убийцы", civ="Цвет Невиновного", sheriff="Цвет Шерифа"},
    en = {app="🎄 LAPEL 2026 🎄", cat="Categories", esp="ESP", aim="Auto Shoot",
          prem="Premium (Key)", skin="Skin Changer", lang="Language: TR / RU / EN",
          back="← Back", enter_key="Enter your key", activate="Activate",
          on="ON", off="OFF", locked="🔒 Premium Locked",
          msg="Premium features are key-protected.\nEnter a key to unlock for 24 hours.",
          valid="✅ Key valid!", invalid="❌ Invalid key", expired="⏰ Expired",
          connecting="Connecting...", killer="Murderer Color", civ="Innocent Color", sheriff="Sheriff Color"},
}
local currentLang = "tr"
local function L(k) return Lang[currentLang][k] or Lang.tr[k] or k end

----------------------------------------------------------------
-- STATE
----------------------------------------------------------------
local State = {
    toggleGui    = nil,
    toggleBtn    = nil,
    mainFrame    = nil,
    mainContent  = nil,
    espOn        = false,
    aimOn        = false,
    premiumOn    = false,
    skinOn       = false,
    premiumExpiry= 0,
    espCache     = {},
    colorKiller  = Color3.fromRGB(255, 50, 50),
    colorCiv     = Color3.fromRGB(50, 220, 80),
    colorSheriff = Color3.fromRGB(60, 130, 255),
}

----------------------------------------------------------------
-- ESKİ GUI TEMİZLE
----------------------------------------------------------------
local UIP = GetUI()
if UIP:FindFirstChild("Lapel2026") then UIP.Lapel2026:Destroy() end

----------------------------------------------------------------
-- ANA SCREENGUI (toggle + main aynı SG içinde — RVIALS kalıbı)
----------------------------------------------------------------
local SG = Make("ScreenGui", {
    Name = "Lapel2026",
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 999,
    ResetOnSpawn = false,
}, UIP)

----------------------------------------------------------------
-- TOGGLE BUTONU (sol alt)
----------------------------------------------------------------
State.toggleBtn = Make("TextButton", {
    Name = "Toggle",
    Size = UDim2.new(0, 80, 0, 36),
    Position = UDim2.new(0, 10, 1, -46),
    AnchorPoint = Vector2.new(0, 0),
    Text = "🎄 LAPEL",
    BackgroundColor3 = Color3.fromRGB(18, 8, 8),
    TextColor3 = Color3.fromRGB(255, 200, 60),
    Font = Enum.Font.GothamBold,
    TextSize = 14,
    AutoButtonColor = true,
    ZIndex = 100,
}, SG)
Round(State.toggleBtn, 10)
Stroke(State.toggleBtn, Color3.fromRGB(180, 30, 30), 2)

----------------------------------------------------------------
-- ANA GUI (başta gizli)
----------------------------------------------------------------
State.mainFrame = Make("Frame", {
    Name = "Main",
    Size = UDim2.new(0, 320, 0, 420),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = Color3.fromRGB(18, 8, 8),
    BorderSizePixel = 0,
    Visible = false,
    Active = true,
    Draggable = true,
    ZIndex = 50,
}, SG)
Round(State.mainFrame, 14)
Stroke(State.mainFrame, Color3.fromRGB(180, 30, 30), 2)

----------------------------------------------------------------
-- TOGGLE BAĞLANTISI
----------------------------------------------------------------
State.toggleBtn.MouseButton1Click:Connect(function()
    State.mainFrame.Visible = not State.mainFrame.Visible
end)

----------------------------------------------------------------
-- BAŞLIK ÇUBUĞU
----------------------------------------------------------------
local titleBar = Make("Frame", {
    Name = "TitleBar",
    Size = UDim2.new(1, 0, 0, 46),
    BackgroundColor3 = Color3.fromRGB(40, 5, 5),
    BorderSizePixel = 0,
    ZIndex = 55,
}, State.mainFrame)
Round(titleBar, 14)
-- alt köşeleri kapatmak için cover
Make("Frame", {
    Size = UDim2.new(1, 0, 0, 14),
    Position = UDim2.new(0, 0, 1, -14),
    BackgroundColor3 = Color3.fromRGB(40, 5, 5),
    BorderSizePixel = 0,
    ZIndex = 55,
}, titleBar)

Make("TextLabel", {
    Size = UDim2.new(1, -60, 1, 0),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundTransparency = 1,
    Text = L("app"),
    TextColor3 = Color3.fromRGB(255, 200, 60),
    Font = Enum.Font.GothamBlack,
    TextSize = 17,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 60,
}, titleBar)

local closeBtn = Make("TextButton", {
    Size = UDim2.new(0, 30, 0, 30),
    Position = UDim2.new(1, -38, 0, 8),
    BackgroundColor3 = Color3.fromRGB(120, 20, 20),
    Text = "✕",
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    ZIndex = 60,
}, titleBar)
Round(closeBtn, 8)
closeBtn.MouseButton1Click:Connect(function()
    State.mainFrame.Visible = false
end)

----------------------------------------------------------------
-- İÇERİK ALANI (görünümler buraya)
----------------------------------------------------------------
State.mainContent = Make("Frame", {
    Name = "Content",
    Size = UDim2.new(1, -16, 1, -56),
    Position = UDim2.new(0, 8, 0, 52),
    BackgroundTransparency = 1,
    ClipsDescendants = true,
    ZIndex = 55,
}, State.mainFrame)

local function newView(name)
    local v = Make("Frame", {
        Name = "View_" .. name,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 56,
    }, State.mainContent)
    local layout = Make("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0, 5),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, v)
    Make("UIPadding", {
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
    }, v)
    return v
end

local function showOnly(name)
    for _, v in ipairs({"home", "esp", "aim", "premium", "lang"}) do
        local f = State.mainContent:FindFirstChild("View_" .. v)
        if f then f.Visible = (v == name) end
    end
end

----------------------------------------------------------------
-- ANA SAYFA
----------------------------------------------------------------
local home = newView("home")
Make("TextLabel", {
    Size = UDim2.new(1, 0, 0, 24),
    BackgroundTransparency = 1,
    Text = L("cat"),
    TextColor3 = Color3.fromRGB(220, 220, 220),
    Font = Enum.Font.GothamSemibold,
    TextSize = 13,
    LayoutOrder = 1,
    ZIndex = 60,
}, home)

local function makeCard(parent, icon, name, color, callback, order)
    local card = Make("TextButton", {
        Size = UDim2.new(1, -8, 0, 50),
        BackgroundColor3 = Color3.fromRGB(28, 10, 10),
        AutoButtonColor = true,
        Text = "",
        LayoutOrder = order or 2,
        ZIndex = 60,
    }, parent)
    Round(card, 8)
    Stroke(card, color, 1)
    Make("TextLabel", {
        Size = UDim2.new(0, 44, 1, 0),
        BackgroundTransparency = 1,
        Text = icon,
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        ZIndex = 61,
    }, card)
    Make("TextLabel", {
        Size = UDim2.new(1, -54, 1, 0),
        Position = UDim2.new(0, 50, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 61,
    }, card)
    card.MouseButton1Click:Connect(callback)
end

makeCard(home, "👁",  L("esp"),   Color3.fromRGB(60, 130, 255),  function() showOnly("esp") end, 2)
makeCard(home, "🔫",  L("aim"),   Color3.fromRGB(255, 100, 60),  function() showOnly("aim") end, 3)
makeCard(home, "⭐",  L("prem"),  Color3.fromRGB(255, 200, 60),  function() showOnly("premium") end, 4)
makeCard(home, "🎭",  L("skin"),  Color3.fromRGB(200, 80, 200),  function()
    if not State.premiumOn then
        showOnly("premium")
        return
    end
    State.skinOn = not State.skinOn
    applySkin(State.skinOn)
end, 5)
makeCard(home, "🌐",  L("lang"),  Color3.fromRGB(150, 150, 150),function() showOnly("lang") end, 6)

----------------------------------------------------------------
-- ESP SAYFASI
----------------------------------------------------------------
local espView = newView("esp")
Make("TextLabel", {
    Size = UDim2.new(1, 0, 0, 24),
    BackgroundTransparency = 1,
    Text = "👁 " .. L("esp"),
    TextColor3 = Color3.fromRGB(60, 130, 255),
    Font = Enum.Font.GothamBlack,
    TextSize = 15,
    LayoutOrder = 1, ZIndex = 60,
}, espView)

local function toggleRow(parent, label, default, callback, order)
    local row = Make("Frame", {
        Size = UDim2.new(1, -8, 0, 38),
        BackgroundColor3 = Color3.fromRGB(30, 12, 12),
        LayoutOrder = order or 2, ZIndex = 60,
    }, parent)
    Round(row, 8)
    Stroke(row, Color3.fromRGB(80, 20, 20), 1)
    Make("TextLabel", {
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = label, TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.Gotham, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 61,
    }, row)
    local btn = Make("TextButton", {
        Size = UDim2.new(0, 48, 0, 24),
        Position = UDim2.new(1, -58, 0.5, -12),
        BackgroundColor3 = default and Color3.fromRGB(0, 130, 60) or Color3.fromRGB(80, 30, 30),
        Text = default and L("on") or L("off"),
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold, TextSize = 11,
        ZIndex = 61,
    }, row)
    Round(btn, 6)
    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 130, 60) or Color3.fromRGB(80, 30, 30)
        btn.Text = state and L("on") or L("off")
        callback(state)
    end)
end

toggleRow(espView, L("esp") .. " " .. L("on") .. "/" .. L("off"), false, function(v) State.espOn = v end, 2)
toggleRow(espView, "Kutu/Highlight", true, function() end, 3)
toggleRow(espView, "Rol Etiketi", true, function() end, 4)
toggleRow(espView, "Mesafe", true, function() end, 5)

-- Renk seçici
local function colorRow(parent, label, color, callback, order)
    local row = Make("Frame", {
        Size = UDim2.new(1, -8, 0, 36),
        BackgroundColor3 = Color3.fromRGB(30, 12, 12),
        LayoutOrder = order or 6, ZIndex = 60,
    }, parent)
    Round(row, 8)
    Make("TextLabel", {
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = label, TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.Gotham, TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 61,
    }, row)
    local palette = {
        Color3.fromRGB(255, 50, 50), Color3.fromRGB(50, 220, 80),
        Color3.fromRGB(60, 130, 255), Color3.fromRGB(255, 200, 60),
        Color3.fromRGB(200, 80, 200), Color3.fromRGB(255, 255, 255),
    }
    local swatch = Make("TextButton", {
        Size = UDim2.new(0, 40, 0, 22),
        Position = UDim2.new(1, -50, 0.5, -11),
        BackgroundColor3 = color,
        Text = "", ZIndex = 61,
    }, row)
    Round(swatch, 6)
    swatch.MouseButton1Click:Connect(function()
        local cur, idx = swatch.BackgroundColor3, 1
        for i, c in ipairs(palette) do if c == cur then idx = i break end end
        idx = idx % #palette + 1
        swatch.BackgroundColor3 = palette[idx]
        callback(palette[idx])
    end)
end

colorRow(espView, L("killer"), State.colorKiller, function(c) State.colorKiller = c end, 6)
colorRow(espView, L("civ"),    State.colorCiv,    function(c) State.colorCiv = c end, 7)
colorRow(espView, L("sheriff"), State.colorSheriff, function(c) State.colorSheriff = c end, 8)

local backEsp = Make("TextButton", {
    Size = UDim2.new(1, -8, 0, 30),
    BackgroundColor3 = Color3.fromRGB(40, 20, 20),
    Text = L("back"), TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold, TextSize = 12,
    LayoutOrder = 99, ZIndex = 60,
}, espView)
Round(backEsp, 6)
backEsp.MouseButton1Click:Connect(function() showOnly("home") end)

----------------------------------------------------------------
-- AIMBOT SAYFASI
----------------------------------------------------------------
local aimView = newView("aim")
Make("TextLabel", {
    Size = UDim2.new(1, 0, 0, 24),
    BackgroundTransparency = 1,
    Text = "🔫 " .. L("aim"),
    TextColor3 = Color3.fromRGB(255, 100, 60),
    Font = Enum.Font.GothamBlack, TextSize = 15,
    LayoutOrder = 1, ZIndex = 60,
}, aimView)

toggleRow(aimView, L("aim"), false, function(v) State.aimOn = v end, 2)
Make("TextLabel", {
    Size = UDim2.new(1, -8, 0, 50),
    BackgroundColor3 = Color3.fromRGB(40, 20, 10),
    BackgroundTransparency = 0.3,
    Text = "ℹ " .. L("aim") .. " sadece Şerifken çalışır.\n1 dokunma = 1 atış.",
    TextColor3 = Color3.fromRGB(255, 200, 100),
    Font = Enum.Font.Gotham, TextSize = 11,
    TextWrapped = true,
    LayoutOrder = 3, ZIndex = 60,
}, aimView)

local backAim = Make("TextButton", {
    Size = UDim2.new(1, -8, 0, 30),
    BackgroundColor3 = Color3.fromRGB(40, 20, 20),
    Text = L("back"), TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold, TextSize = 12,
    LayoutOrder = 99, ZIndex = 60,
}, aimView)
Round(backAim, 6)
backAim.MouseButton1Click:Connect(function() showOnly("home") end)

----------------------------------------------------------------
-- PREMIUM (KEY) SAYFASI
----------------------------------------------------------------
local premView = newView("premium")
Make("TextLabel", {
    Size = UDim2.new(1, 0, 0, 24),
    BackgroundTransparency = 1,
    Text = "⭐ " .. L("prem"),
    TextColor3 = Color3.fromRGB(255, 200, 60),
    Font = Enum.Font.GothamBlack, TextSize = 15,
    LayoutOrder = 1, ZIndex = 60,
}, premView)

local lockedBox = Make("Frame", {
    Name = "Locked",
    Size = UDim2.new(1, -8, 0, 240),
    BackgroundColor3 = Color3.fromRGB(25, 10, 10),
    LayoutOrder = 2, ZIndex = 60,
}, premView)
Round(lockedBox, 10)
Stroke(lockedBox, Color3.fromRGB(180, 30, 30), 1)
local lbLayout = Make("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    Padding = UDim.new(0, 6),
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    VerticalAlignment = Enum.VerticalAlignment.Center,
}, lockedBox)

Make("TextLabel", {
    Size = UDim2.new(0.9, 0, 0, 24),
    BackgroundTransparency = 1,
    Text = L("locked"),
    TextColor3 = Color3.fromRGB(255, 200, 60),
    Font = Enum.Font.GothamBold, TextSize = 16,
    ZIndex = 61,
}, lockedBox)

Make("TextLabel", {
    Size = UDim2.new(0.9, 0, 0, 40),
    BackgroundTransparency = 1,
    Text = L("msg"),
    TextColor3 = Color3.fromRGB(180, 180, 180),
    Font = Enum.Font.Gotham, TextSize = 11,
    TextWrapped = true,
    ZIndex = 61,
}, lockedBox)

local keyInput = Make("TextBox", {
    Size = UDim2.new(0.85, 0, 0, 34),
    BackgroundColor3 = Color3.fromRGB(15, 5, 5),
    Text = "",
    PlaceholderText = "LAPEL-XXXX-XXXX-XXXX",
    PlaceholderColor3 = Color3.fromRGB(100, 100, 100),
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.Code, TextSize = 13,
    ClearTextOnFocus = false,
    ZIndex = 61,
}, lockedBox)
Round(keyInput, 8)
Stroke(keyInput, Color3.fromRGB(180, 30, 30), 1)

local keyStatus = Make("TextLabel", {
    Size = UDim2.new(0.9, 0, 0, 20),
    BackgroundTransparency = 1,
    Text = "", TextColor3 = Color3.fromRGB(255, 100, 100),
    Font = Enum.Font.Gotham, TextSize = 11,
    TextWrapped = true, ZIndex = 61,
}, lockedBox)

local activateBtn = Make("TextButton", {
    Size = UDim2.new(0.6, 0, 0, 34),
    BackgroundColor3 = Color3.fromRGB(180, 30, 30),
    Text = L("activate"),
    TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold, TextSize = 13,
    ZIndex = 61,
}, lockedBox)
Round(activateBtn, 8)

local function verifyKey(key, cb)
    spawn(function()
        local res = httpRequest({
            Url = API_BASE .. "/api/key/verify",
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode({ key = key, userId = tostring(LocalPlayer.UserId) }),
        })
        if not res then cb(false, "HTTP hatası") return end
        local data
        pcall(function() data = HttpService:JSONDecode(res.Body) end)
        if data and data.ok and data.valid then
            cb(true, data)
        else
            cb(false, data and data.error or "Geçersiz key", data)
        end
    end)
end

activateBtn.MouseButton1Click:Connect(function()
    local k = keyInput.Text:gsub("%s+", ""):upper()
    if #k < 10 then
        keyStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
        keyStatus.Text = L("invalid") return
    end
    keyStatus.TextColor3 = Color3.fromRGB(255, 200, 100)
    keyStatus.Text = L("connecting")
    activateBtn.Text = "..."
    verifyKey(k, function(ok, d, raw)
        activateBtn.Text = L("activate")
        if ok then
            State.premiumOn = true
            State.premiumExpiry = math.floor(d.expiresAt / 1000)
            keyStatus.TextColor3 = Color3.fromRGB(100, 230, 130)
            keyStatus.Text = L("valid") .. " (" .. d.remainingFormatted .. ")"
        else
            if raw and raw.expired then
                keyStatus.TextColor3 = Color3.fromRGB(255, 150, 50)
                keyStatus.Text = L("expired")
            else
                keyStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
                keyStatus.Text = L("invalid")
            end
        end
    end)
end)

-- Premium aktif
local unlockedBox = Make("Frame", {
    Name = "Unlocked",
    Size = UDim2.new(1, -8, 0, 100),
    BackgroundColor3 = Color3.fromRGB(20, 15, 5),
    Visible = false,
    LayoutOrder = 3, ZIndex = 60,
}, premView)
Round(unlockedBox, 10)
Stroke(unlockedBox, Color3.fromRGB(255, 200, 60), 1)
Make("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    Padding = UDim.new(0, 6),
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    VerticalAlignment = Enum.VerticalAlignment.Center,
}, unlockedBox)
Make("TextLabel", {
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundTransparency = 1,
    Text = "⭐ " .. L("prem") .. " AKTİF!",
    TextColor3 = Color3.fromRGB(255, 200, 60),
    Font = Enum.Font.GothamBold, TextSize = 16,
    ZIndex = 61,
}, unlockedBox)
Make("TextLabel", {
    Name = "Timer",
    Size = UDim2.new(1, 0, 0, 20),
    BackgroundTransparency = 1,
    Text = "—",
    TextColor3 = Color3.fromRGB(200, 200, 200),
    Font = Enum.Font.Code, TextSize = 14,
    ZIndex = 61,
}, unlockedBox)

local backPrem = Make("TextButton", {
    Size = UDim2.new(1, -8, 0, 30),
    BackgroundColor3 = Color3.fromRGB(40, 20, 20),
    Text = L("back"), TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold, TextSize = 12,
    LayoutOrder = 99, ZIndex = 60,
}, premView)
Round(backPrem, 6)
backPrem.MouseButton1Click:Connect(function() showOnly("home") end)

----------------------------------------------------------------
-- DİL SAYFASI
----------------------------------------------------------------
local langView = newView("lang")
Make("TextLabel", {
    Size = UDim2.new(1, 0, 0, 24),
    BackgroundTransparency = 1,
    Text = "🌐 " .. L("lang"),
    TextColor3 = Color3.fromRGB(220, 220, 220),
    Font = Enum.Font.GothamBlack, TextSize = 14,
    LayoutOrder = 1, ZIndex = 60,
}, langView)

local function langBtn(code, label, order)
    local b = Make("TextButton", {
        Size = UDim2.new(1, -8, 0, 40),
        BackgroundColor3 = currentLang == code and Color3.fromRGB(180, 30, 30) or Color3.fromRGB(40, 20, 20),
        Text = label,
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold, TextSize = 14,
        LayoutOrder = order, ZIndex = 60,
    }, langView)
    Round(b, 8)
    b.MouseButton1Click:Connect(function()
        currentLang = code
        if SG and SG.Parent then SG:Destroy() end
        -- yeniden yükleme: tüm script'i tekrar çalıştır
        loadstring(game:HttpGet(API_BASE and "https://raw.githubusercontent.com/voidhelpmanager/lapel-2026-script/main/loader.lua" or "https://raw.githubusercontent.com/voidhelpmanager/lapel-2026-script/main/loader.lua"))()
    end)
end
langBtn("tr", "🇹🇷 Türkçe", 2)
langBtn("ru", "🇷🇺 Русский", 3)
langBtn("en", "🇬🇧 English", 4)

local backLang = Make("TextButton", {
    Size = UDim2.new(1, -8, 0, 30),
    BackgroundColor3 = Color3.fromRGB(40, 20, 20),
    Text = L("back"), TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold, TextSize = 12,
    LayoutOrder = 99, ZIndex = 60,
}, langView)
Round(backLang, 6)
backLang.MouseButton1Click:Connect(function() showOnly("home") end)

-- İlk görünüm
showOnly("home")

----------------------------------------------------------------
-- ESP RENDER
----------------------------------------------------------------
local function getRole(p)
    if not p.Character then return "Civ" end
    for _, item in ipairs(p.Character:GetChildren()) do
        if item:IsA("Tool") then
            local n = item.Name:lower()
            if n:find("knife") or n:find("blade") then return "Killer" end
        end
    end
    if p:FindFirstChild("Backpack") then
        for _, item in ipairs(p.Backpack:GetChildren()) do
            if item:IsA("Tool") then
                local n = item.Name:lower()
                if n:find("knife") or n:find("blade") then return "Killer" end
            end
        end
    end
    return "Civ"
end

local function ensureESP(p)
    if State.espCache[p] then return State.espCache[p] end
    local hl = Instance.new("Highlight")
    hl.Name = "LapelESP"
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = p.Character or nil
    if not hl.Parent then hl:Destroy() return nil end
    State.espCache[p] = hl
    return hl
end

RunService.RenderStepped:Connect(function()
    if not State.espOn then
        for p, hl in pairs(State.espCache) do
            if hl and hl.Parent then hl.Enabled = false end
        end
        return
    end
    if game.PlaceId ~= PlaceId_MM2 then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") then
            if p.Character.Humanoid.Health <= 0 then
                if State.espCache[p] then State.espCache[p].Enabled = false end
                continue
            end
            local hl = ensureESP(p)
            if hl then
                hl.Adornee = p.Character
                hl.Enabled = true
                local r = getRole(p)
                if r == "Killer" then
                    hl.FillColor = State.colorKiller
                    hl.OutlineColor = State.colorKiller
                else
                    hl.FillColor = State.colorCiv
                    hl.OutlineColor = State.colorCiv
                end
            end
        end
    end
end)

----------------------------------------------------------------
-- AIMBOT (Şerifken 1 tık = 1 atış)
----------------------------------------------------------------
local function findKiller()
    local best, bestD = nil, math.huge
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            if getRole(p) == "Killer" then
                local hum = p.Character:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    local d = (myRoot.Position - p.Character.Head.Position).Magnitude
                    if d < bestD then best, bestD = p, d end
                end
            end
        end
    end
    return best
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if not State.aimOn then return end
    if game.PlaceId ~= PlaceId_MM2 then return end
    if getRole(LocalPlayer) ~= "Sheriff" then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local k = findKiller()
    if not k or not k.Character or not k.Character:FindFirstChild("Head") then return end
    pcall(function()
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, k.Character.Head.Position)
        task.wait(0.05)
        mouse1click()
    end)
end)

----------------------------------------------------------------
-- SKIN HİLESİ
----------------------------------------------------------------
function applySkin(on)
    local char = LocalPlayer.Character
    if not char then return end
    pcall(function()
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.Color = on and Color3.fromRGB(255, 200, 60) or Color3.fromRGB(163, 162, 165)
            end
        end
    end)
end

----------------------------------------------------------------
-- PREMIUM TIMER (sürekli güncelle)
----------------------------------------------------------------
spawn(function()
    while task.wait(1) do
        if State.premiumOn and State.premiumExpiry > 0 then
            local rem = State.premiumExpiry - os.time()
            if rem <= 0 then
                State.premiumOn = false
                State.skinOn = false
                applySkin(false)
                if unlockedBox and lockedBox then
                    unlockedBox.Visible = false
                    lockedBox.Visible = true
                end
            else
                local h = math.floor(rem / 3600)
                local m = math.floor((rem % 3600) / 60)
                local s = rem % 60
                local t = unlockedBox and unlockedBox:FindFirstChild("Timer")
                if t then
                    t.Text = string.format("Kalan: %02d:%02d:%02d", h, m, s)
                end
                if lockedBox.Visible == false and unlockedBox.Visible == false then
                    unlockedBox.Visible = true
                end
            end
        end
    end
end)

-- Demo key'i arka planda doğrula
spawn(function()
    verifyKey(DEMO_KEY, function(ok, d)
        if ok then
            State.premiumOn = true
            State.premiumExpiry = math.floor(d.expiresAt / 1000)
        end
    end)
end)

print("[Lapel 2026 v1.8] Loaded. Toggle sol altta 🎄")
