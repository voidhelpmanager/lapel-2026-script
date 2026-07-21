--[[
    ╔════════════════════════════════════════════════════╗
    ║              🎄 LAPEL 2026 GUI 🎄                  ║
    ║         Murder Mystery 2 — Mobile Edition          ║
    ║   ESP · Auto-Shoot · Skin Changer · Key System     ║
    ╚════════════════════════════════════════════════════╝
    
    Executor : Delta (mobile/desktop)
    Game    : Murder Mystery 2 (PlaceId: 142823291)
    Lang    : TR (default) / RU / EN
    API     : https://lapel-2026-keys.vercel.app
    Button  : Roblox Asset 107466198768601 (Noel themed)
]]

----------------------------------------------------------------
-- CONFIG
----------------------------------------------------------------
local Config = {
    API_BASE       = "https://lapel-2026-keys.vercel.app",
    PLACE_ID_MM2   = 142823291,
    DEFAULT_KEY    = "LAPEL-JVL9-9CMZ-SWVA", -- demo key (kullanılmamış)
    LANG_DEFAULT   = "tr",
    VERSION        = "1.0.0",
    BUTTON_ASSET   = "rbxassetid://107466198768601", -- Noel tuş görseli
    BUTTON_SIZE    = 76,   -- tuş boyutu (px)
}

----------------------------------------------------------------
-- SERVICES
----------------------------------------------------------------
local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInputService= game:GetService("UserInputService")
local TweenService   = game:GetService("TweenService")
local HttpService    = game:GetService("HttpService")
local CoreGui        = (game:GetService("CoreGui") or game:FindService("CoreGui"))
local Lighting       = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer    = Players.LocalPlayer
local Camera         = workspace.CurrentCamera

----------------------------------------------------------------
-- HTTP HELPER (Delta supports request, fallback http_request)
----------------------------------------------------------------
local function httpRequest(opts)
    local ok, res = pcall(function()
        if syn and syn.request then return syn.request(opts) end
        if request then return request(opts) end
        if http and http.request then return http.request(opts) end
        if http_request then return http_request(opts) end
        if fluxus and fluxus.request then return fluxus.request(opts) end
    end)
    if not ok then return nil, tostring(res) end
    return res
end

----------------------------------------------------------------
-- LANGUAGE STRINGS
----------------------------------------------------------------
local Lang = {
    tr = {
        app_name          = "LAPEL 2026",
        loading           = "Yükleniyor...",
        select_game       = "Hile yapmak istediğin oyunu seç",
        available_games   = "Mevcut Oyunlar",
        soon              = "Yakında",
        no_games          = "Şu an desteklenen oyun yok",
        mm2               = "Murder Mystery 2",
        categories        = "Kategoriler",
        cat_esp           = "ESP",
        cat_aimbot        = "Otomatik Nişan",
        cat_premium       = "Premium",
        cat_settings      = "Ayarlar",
        back              = "← Geri",
        enabled           = "Açık",
        disabled          = "Kapalı",
        on                = "AÇ",
        off               = "KAP",
        killer_color      = "Katil Rengi",
        innocent_color    = "Sivil Rengi",
        sheriff_color     = "Şerif Rengi",
        esp_role_label    = "Rol Etiketi",
        esp_distance      = "Mesafe",
        esp_box           = "Kutu",
        auto_shoot        = "Otomatik Şerif Atışı",
        auto_shoot_hint   = "Şerifken aktif · 1 dokunuş = 1 atış",
        aim_key           = "Ateş Tuşu",
        aim_key_current   = "Mevcut: ",
        premium_locked    = "🔒 Premium Kilidi",
        premium_msg       = "Premium özellikler key sistemi ile korunuyor.\nKey girerek 24 saatlik erişim açabilirsin.",
        enter_key         = "Keyini Gir",
        key_placeholder   = "LAPEL-XXXX-XXXX-XXXX",
        activate          = "Aktif Et",
        key_valid         = "✅ Key geçerli!",
        key_invalid       = "❌ Key geçersiz",
        key_expired       = "⏰ Key süresi dolmuş",
        premium_active    = "⭐ Premium Aktif",
        time_left         = "Kalan Süre",
        skin_changer      = "Skin Hilesi",
        skin_changer_hint = "Premium ile açılır",
        not_premium       = "Bu özellik için premium gerekli",
        language          = "Dil",
        not_in_game       = "Sadece Murder Mystery 2'de çalışır!",
        connecting        = "Sunucuya bağlanılıyor...",
        conn_failed       = "Bağlantı başarısız",
        conn_ok           = "Bağlantı kuruldu",
        role_murderer     = "KATİL",
        role_sheriff      = "ŞERİF",
        role_innocent     = "SİVİL",
        role_hero         = "KAHRAMAN",
        gun_ready         = "Silah Hazır",
        gun_cooldown      = "Cooldown",
        drop_weapon       = "Silahı Düşür",
        tip_tap_to_lock   = "Kilitlemek için çift dokun",
        tip_drag          = "Sürükle",
        tip_locked        = "🔒 Kilitli",
        tip_unlocked      = "🔓 Taşınabilir",
    },
    ru = {
        app_name          = "LAPEL 2026",
        loading           = "Загрузка...",
        select_game       = "Выберите игру",
        available_games   = "Доступные игры",
        soon              = "Скоро",
        no_games          = "Нет доступных игр",
        mm2               = "Murder Mystery 2",
        categories        = "Категории",
        cat_esp           = "ESP",
        cat_aimbot        = "Авто-стрельба",
        cat_premium       = "Премиум",
        cat_settings      = "Настройки",
        back              = "← Назад",
        enabled           = "Вкл",
        disabled          = "Выкл",
        on                = "ВКЛ",
        off               = "ВЫКЛ",
        killer_color      = "Цвет Убийцы",
        innocent_color    = "Цвет Невиновного",
        sheriff_color     = "Цвет Шерифа",
        esp_role_label    = "Метка роли",
        esp_distance      = "Дистанция",
        esp_box           = "Рамка",
        auto_shoot        = "Авто-выстрел Шерифа",
        auto_shoot_hint   = "Активно в роли Шерифа · 1 нажатие = 1 выстрел",
        aim_key           = "Клавиша стрельбы",
        aim_key_current   = "Текущая: ",
        premium_locked    = "🔒 Премиум заблокирован",
        premium_msg       = "Премиум-функции защищены ключом.\nВведите ключ для активации на 24 часа.",
        enter_key         = "Введите ключ",
        key_placeholder   = "LAPEL-XXXX-XXXX-XXXX",
        activate          = "Активировать",
        key_valid         = "✅ Ключ действителен!",
        key_invalid       = "❌ Неверный ключ",
        key_expired       = "⏰ Ключ истёк",
        premium_active    = "⭐ Премиум активен",
        time_left         = "Осталось",
        skin_changer      = "Скин-чейнджер",
        skin_changer_hint = "Доступно с премиумом",
        not_premium       = "Требуется премиум",
        language          = "Язык",
        not_in_game       = "Работает только в Murder Mystery 2!",
        connecting        = "Подключение к серверу...",
        conn_failed       = "Ошибка подключения",
        conn_ok           = "Подключено",
        role_murderer     = "УБИЙЦА",
        role_sheriff      = "ШЕРИФ",
        role_innocent     = "НЕВИНОВНЫЙ",
        role_hero         = "ГЕРОЙ",
        gun_ready         = "Оружие готово",
        gun_cooldown      = "Перезарядка",
        drop_weapon       = "Бросить оружие",
        tip_tap_to_lock   = "Двойной тап для фиксации",
        tip_drag          = "Перетащить",
        tip_locked        = "🔒 Зафиксировано",
        tip_unlocked      = "🔓 Можно двигать",
    },
    en = {
        app_name          = "LAPEL 2026",
        loading           = "Loading...",
        select_game       = "Select a game to cheat in",
        available_games   = "Available Games",
        soon              = "Coming soon",
        no_games          = "No supported games",
        mm2               = "Murder Mystery 2",
        categories        = "Categories",
        cat_esp           = "ESP",
        cat_aimbot        = "Auto Shoot",
        cat_premium       = "Premium",
        cat_settings      = "Settings",
        back              = "← Back",
        enabled           = "On",
        disabled          = "Off",
        on                = "ON",
        off               = "OFF",
        killer_color      = "Murderer Color",
        innocent_color    = "Innocent Color",
        sheriff_color     = "Sheriff Color",
        esp_role_label    = "Role Label",
        esp_distance      = "Distance",
        esp_box           = "Box",
        auto_shoot        = "Sheriff Auto-Shoot",
        auto_shoot_hint   = "Active as Sheriff · 1 tap = 1 shot",
        aim_key           = "Fire Key",
        aim_key_current   = "Current: ",
        premium_locked    = "🔒 Premium Locked",
        premium_msg       = "Premium features are key-protected.\nEnter a key to unlock for 24 hours.",
        enter_key         = "Enter your key",
        key_placeholder   = "LAPEL-XXXX-XXXX-XXXX",
        activate          = "Activate",
        key_valid         = "✅ Key valid!",
        key_invalid       = "❌ Invalid key",
        key_expired       = "⏰ Key expired",
        premium_active    = "⭐ Premium Active",
        time_left         = "Time left",
        skin_changer      = "Skin Changer",
        skin_changer_hint = "Unlocked with premium",
        not_premium       = "Premium required",
        language          = "Language",
        not_in_game       = "Only works in Murder Mystery 2!",
        connecting        = "Connecting to server...",
        conn_failed       = "Connection failed",
        conn_ok           = "Connected",
        role_murderer     = "MURDERER",
        role_sheriff      = "SHERIFF",
        role_innocent     = "INNOCENT",
        role_hero         = "HERO",
        gun_ready         = "Gun Ready",
        gun_cooldown      = "Cooldown",
        drop_weapon       = "Drop Weapon",
        tip_tap_to_lock   = "Double-tap to lock",
        tip_drag          = "Drag",
        tip_locked        = "🔒 Locked",
        tip_unlocked      = "🔓 Draggable",
    },
}

local currentLang = Config.LANG_DEFAULT
local function L(key) return (Lang[currentLang] and Lang[currentLang][key]) or Lang.tr[key] or key end

----------------------------------------------------------------
-- STATE
----------------------------------------------------------------
local State = {
    mainGui       = nil,
    toggleButton  = nil,
    mainFrame     = nil,
    gameSelect    = nil,
    mm2Panel      = nil,
    premiumPanel  = nil,
    espPanel      = nil,
    aimbotPanel   = nil,
    settingsPanel = nil,
    -- ESP
    espEnabled   = false,
    espBox       = true,
    espLabel     = true,
    espDistance  = true,
    colorMurderer = Color3.fromRGB(255, 50, 50),
    colorInnocent = Color3.fromRGB(50, 220, 80),
    colorSheriff  = Color3.fromRGB(60, 130, 255),
    espCache      = {}, -- player -> { highlight, billboard, root }
    -- Aimbot
    aimEnabled   = false,
    -- Premium
    premiumActive = false,
    premiumExpires = 0,
    -- Skin
    skinChangerEnabled = false,
    -- Misc
    currentView  = "loading", -- loading | gameSelect | categories | esp | aimbot | premium | settings
    buttonLocked = false,
    buttonPos    = nil,
    updateConn   = nil,
    verifyTick   = nil,
}

----------------------------------------------------------------
-- UTIL: create instance with props
----------------------------------------------------------------
local function create(class, props, parent)
    local inst = Instance.new(class)
    if props then
        for k, v in pairs(props) do
            if k == "Children" then
                for _, c in ipairs(v) do c.Parent = inst end
            elseif k == "Size" or k == "Position" then
                inst[k] = v
            else
                pcall(function() inst[k] = v end)
            end
        end
    end
    if parent then inst.Parent = parent end
    return inst
end

local function corner(radius) return create("UICorner", { CornerRadius = UDim.new(0, radius or 8) }) end
local function stroke(color, thickness) return create("UIStroke", { Color = color or Color3.fromRGB(60, 60, 60), Thickness = thickness or 1 }) end
local function pad(all) return create("UIPadding", { PaddingTop = UDim.new(0,all), PaddingBottom = UDim.new(0,all), PaddingLeft = UDim.new(0,all), PaddingRight = UDim.new(0,all) }) end
local function listLayout(dir, gap, hAlign, vAlign) return create("UIListLayout", { FillDirection = dir or Enum.FillDirection.Vertical, Padding = UDim.new(0, gap or 6), HorizontalAlignment = hAlign or Enum.HorizontalAlignment.Center, VerticalAlignment = vAlign or Enum.VerticalAlignment.Top, SortOrder = Enum.SortOrder.LayoutOrder }) end
local function aspectRatio(r) return create("UIAspectRatioConstraint", { AspectRatio = r }) end

----------------------------------------------------------------
-- API: verify key
----------------------------------------------------------------
local function verifyKey(key, callback)
    spawn(function()
        local res, err = httpRequest({
            Url = Config.API_BASE .. "/api/key/verify",
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode({ key = key, userId = tostring(LocalPlayer.UserId) }),
        })
        if not res then
            if callback then callback(false, "HTTP error: " .. tostring(err)) return end
        end
        local data
        pcall(function() data = HttpService:JSONDecode(res.Body) end)
        if data and data.ok and data.valid then
            if callback then callback(true, data) end
        else
            if callback then callback(false, data and data.error or "Key geçersiz", data) end
        end
    end)
end

local function updatePremiumUI()
    -- Sol üstte kalan süre etiketi (sürekli güncellenir)
    local lbl = State.mainGui and State.mainGui:FindFirstChild("PremiumTimer")
    if not lbl then return end
    if State.premiumActive and State.premiumExpires > 0 then
        local remaining = math.max(0, State.premiumExpires - os.time())
        if remaining <= 0 then
            State.premiumActive = false
            lbl.Visible = false
            -- premium bitti, UI kilitlensin
            if State.premiumPanel and State.premiumPanel:FindFirstChild("Locked") then
                State.premiumPanel.Locked.Visible = true
            end
            if State.premiumPanel and State.premiumPanel:FindFirstChild("Unlocked") then
                State.premiumPanel.Unlocked.Visible = false
            end
        else
            local h = math.floor(remaining / 3600)
            local m = math.floor((remaining % 3600) / 60)
            local s = remaining % 60
            lbl.Text = string.format("⭐ %s: %02d:%02d:%02d", L("time_left"), h, m, s)
            lbl.Visible = true
        end
    else
        lbl.Visible = false
    end
end

----------------------------------------------------------------
-- GUI: BUILD
----------------------------------------------------------------
local function clearChildren(parent)
    for _, c in ipairs(parent:GetChildren()) do
        if c:IsA("GuiObject") then c:Destroy() end
    end
end

-- Mevcut görünümü aç/kapa
local function showOnly(name)
    State.currentView = name
    for _, v in ipairs({"gameSelect", "categories", "esp", "aimbot", "premium", "settings"}) do
        local f = State.mainGui and State.mainGui:FindFirstChild("View_" .. v)
        if f then f.Visible = (v == name) end
    end
end

----------------------------------------------------------------
-- TOGGLE BUTTON (PNG tabanlı, sürüklenebilir, animasyonlu)
----------------------------------------------------------------
local function buildToggleButton()
    if State.toggleButton then State.toggleButton:Destroy() end
    local sg = create("ScreenGui", {
        Name = "LapelToggle",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        DisplayOrder = 999,
    }, CoreGui)

    local size = Config.BUTTON_SIZE

    -- Gölge (tuşun arkasında)
    local shadow = create("ImageLabel", {
        Name = "Shadow",
        Size = UDim2.new(0, size + 8, 0, size + 8),
        Position = UDim2.new(0, 20, 0.4, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 24, 0.42, 4),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        ZIndex = 99,
    }, sg)

    -- Tuş (ImageButton — PNG ile)
    local btn = create("ImageButton", {
        Name = "Btn",
        Size = UDim2.new(0, size, 0, size),
        Position = UDim2.new(0, 20, 0.4, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = Config.BUTTON_ASSET,
        ScaleType = Enum.ScaleType.Stretch,
        AutoButtonColor = false,
        ZIndex = 100,
    }, sg)

    -- Kilitleme göstergesi (kilit simgesi, sadece kilitliyse görünür)
    local lockIcon = create("TextLabel", {
        Name = "LockIcon",
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(1, -28, 1, -28),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(180, 30, 30),
        BackgroundTransparency = 0.15,
        Text = "🔒",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextScaled = true,
        Visible = false,
        ZIndex = 105,
    }, btn)
    corner(12); corner(12):Clone().Parent = lockIcon
    create("UITextSizeConstraint", { MaxTextSize = 16 }, lockIcon)
    stroke(Color3.fromRGB(80, 0, 0), 1).Parent = lockIcon

    -- "L" badge (küçük, tuşun sağ altında, premium/preview)
    local badge = create("TextLabel", {
        Name = "Badge",
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(0, -4, 0, -4),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 200, 60),
        Text = "L",
        TextColor3 = Color3.fromRGB(120, 30, 0),
        Font = Enum.Font.GothamBlack,
        TextSize = 14,
        TextScaled = true,
        ZIndex = 105,
    }, btn)
    corner(11); corner(11):Clone().Parent = badge
    stroke(Color3.fromRGB(180, 100, 0), 1).Parent = badge
    create("UITextSizeConstraint", { MaxTextSize = 16 }, badge)

    -- Tıklama alanı büyütücü (görünmez, tıklama kolaylığı için)
    local hitArea = create("TextButton", {
        Name = "HitArea",
        Size = UDim2.new(1.4, 0, 1.4, 0),
        Position = UDim2.new(-0.2, 0, -0.2, 0),
        AnchorPoint = Vector2.new(0, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 98,
    }, btn)

    -- Sürükleme & tıklama
    local dragging = false
    local moved = false
    local dragStart, startPos
    local lastTap = 0
    local pressTime = 0

    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            dragStart = input.Position
            startPos = btn.Position
            pressTime = tick()
            -- Tıklama animasyonu (küçülme)
            TweenService:Create(btn, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, size - 6, 0, size - 6)
            }):Play()
            -- Çift tık algılama
            local now = tick()
            if now - lastTap < 0.35 then
                State.buttonLocked = not State.buttonLocked
                lockIcon.Visible = State.buttonLocked
                if State.buttonLocked then
                    lockIcon.Text = "🔒"
                else
                    lockIcon.Text = ""
                end
            end
            lastTap = now
        end
    end

    local function onInputEnded(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local wasDragging = dragging
            dragging = false
            -- Bounce animasyonu (büyüme)
            TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, size, 0, size)
            }):Play()
            -- Eğer sürükleme olmadıysa, tıklama
            if wasDragging and not moved and (tick() - pressTime < 0.4) then
                if State.mainGui and State.mainGui.Enabled then
                    State.mainGui.Enabled = false
                else
                    if not State.mainGui then
                        buildMainGui()
                    end
                    State.mainGui.Enabled = true
                    -- Eğer oyun MM2 değilse uyar
                    if game.PlaceId ~= Config.PLACE_ID_MM2 then
                        showOnly("gameSelect")
                    else
                        showOnly("categories")
                    end
                end
            end
        end
    end

    btn.InputBegan:Connect(onInputBegan)
    btn.InputEnded:Connect(onInputEnded)
    hitArea.InputBegan:Connect(onInputBegan)
    hitArea.InputEnded:Connect(onInputEnded)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and not State.buttonLocked then
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local delta = input.Position - dragStart
                if delta.Magnitude > 5 then moved = true end
                if moved then
                    btn.Position = UDim2.new(
                        startPos.X.Scale, startPos.X.Offset + delta.X,
                        startPos.Y.Scale, startPos.Y.Offset + delta.Y
                    )
                    -- Gölge de tuşla beraber hareket eder
                    shadow.Position = UDim2.new(
                        startPos.X.Scale, startPos.X.Offset + delta.X + 4,
                        startPos.Y.Scale, startPos.Y.Offset + delta.Y + 4
                    )
                end
            end
        end
    end)

    State.toggleButton = sg
    return sg
end

----------------------------------------------------------------
-- MAIN GUI
----------------------------------------------------------------
local function buildMainGui()
    if State.mainGui then State.mainGui:Destroy() end
    local sg = create("ScreenGui", {
        Name = "LapelMain",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    }, CoreGui)

    -- Sol üstte key kalan süre
    local timer = create("TextLabel", {
        Name = "PremiumTimer",
        Size = UDim2.new(0, 220, 0, 32),
        Position = UDim2.new(0, 12, 0, 12),
        BackgroundColor3 = Color3.fromRGB(20, 5, 5),
        BackgroundTransparency = 0.2,
        TextColor3 = Color3.fromRGB(255, 200, 60),
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        Text = "",
        Visible = false,
        ZIndex = 50,
    }, sg)
    corner(6); corner(6):Clone().Parent = timer
    stroke(Color3.fromRGB(180, 30, 30), 1).Parent = timer
    create("UIPadding", {
        PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4)
    }, timer)

    -- ANA ÇERÇEVE
    local main = create("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 360, 0, 480),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(18, 8, 8),
        BorderSizePixel = 0,
    }, sg)
    corner(14); corner(14):Clone().Parent = main
    local mainStroke = stroke(Color3.fromRGB(180, 30, 30), 2)
    mainStroke.Parent = main

    -- BAŞLIK ÇUBUĞU
    local titleBar = create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Color3.fromRGB(40, 5, 5),
        BorderSizePixel = 0,
    }, main)
    corner(14); corner(14):Clone().Parent = titleBar
    local titleCover = create("Frame", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 1, -14),
        BackgroundColor3 = Color3.fromRGB(40, 5, 5),
        BorderSizePixel = 0,
    }, titleBar)
    local title = create("TextLabel", {
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 50, 0, 0),
        BackgroundTransparency = 1,
        Text = "🎄 " .. L("app_name") .. " 🎄",
        TextColor3 = Color3.fromRGB(255, 200, 60),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, titleBar)
    local closeBtn = create("TextButton", {
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -40, 0, 9),
        BackgroundColor3 = Color3.fromRGB(120, 20, 20),
        Text = "✕",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 16,
    }, titleBar)
    corner(8); corner(8):Clone().Parent = closeBtn
    closeBtn.MouseButton1Click:Connect(function() sg.Enabled = false end)

    -- İçerik frame
    local content = create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -16, 1, -60),
        Position = UDim2.new(0, 8, 0, 54),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
    }, main)

    local function newView(name)
        local v = create("Frame", {
            Name = "View_" .. name,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
        }, content)
        listLayout(Enum.FillDirection.Vertical, 6, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top).Parent = v
        create("UIPadding", {
            PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4),
            PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4)
        }, v)
        return v
    end

    ----------------------------------------------------------------
    -- VIEW: OYUN SEÇİMİ
    ----------------------------------------------------------------
    local gameSelect = newView("gameSelect")
    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Text = L("select_game"),
        TextColor3 = Color3.fromRGB(220, 220, 220),
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        LayoutOrder = 1,
    }, gameSelect)

    local function gameCard(name, desc, callback, order)
        local card = create("TextButton", {
            Size = UDim2.new(1, -10, 0, 60),
            BackgroundColor3 = Color3.fromRGB(35, 12, 12),
            AutoButtonColor = true,
            Text = "",
            LayoutOrder = order or 2,
        }, gameSelect)
        corner(10); corner(10):Clone().Parent = card
        stroke(Color3.fromRGB(180, 30, 30), 1).Parent = card
        create("TextLabel", {
            Size = UDim2.new(0.7, 0, 0.5, 0),
            Position = UDim2.new(0, 14, 0, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Color3.fromRGB(255, 200, 60),
            Font = Enum.Font.GothamBold,
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, card)
        create("TextLabel", {
            Size = UDim2.new(0.7, 0, 0.4, 0),
            Position = UDim2.new(0, 14, 0.55, 0),
            BackgroundTransparency = 1,
            Text = desc,
            TextColor3 = Color3.fromRGB(180, 180, 180),
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, card)
        create("TextLabel", {
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(1, -40, 0.5, -15),
            BackgroundTransparency = 1,
            Text = "▶",
            TextColor3 = Color3.fromRGB(255, 200, 60),
            Font = Enum.Font.GothamBold,
            TextSize = 16,
        }, card)
        card.MouseButton1Click:Connect(callback)
    end

    -- Şu an sadece MM2
    if game.PlaceId == Config.PLACE_ID_MM2 then
        gameCard("🔪 " .. L("mm2"), "Şu an buradasın ✓", function() showOnly("categories") end, 2)
    else
        gameCard("🔪 " .. L("mm2"), L("soon"), function()
            -- mesaj göster
        end, 2)
    end

    ----------------------------------------------------------------
    -- VIEW: KATEGORİLER
    ----------------------------------------------------------------
    local categories = newView("categories")
    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        Text = L("categories"),
        TextColor3 = Color3.fromRGB(220, 220, 220),
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        LayoutOrder = 1,
    }, categories)

    local function categoryCard(icon, name, color, callback, order)
        local card = create("TextButton", {
            Size = UDim2.new(1, -10, 0, 56),
            BackgroundColor3 = Color3.fromRGB(28, 10, 10),
            AutoButtonColor = true,
            Text = "",
            LayoutOrder = order or 2,
        }, categories)
        corner(10); corner(10):Clone().Parent = card
        stroke(color, 1).Parent = card
        create("TextLabel", {
            Size = UDim2.new(0, 50, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            Text = icon,
            Font = Enum.Font.GothamBold,
            TextSize = 26,
        }, card)
        create("TextLabel", {
            Size = UDim2.new(1, -60, 1, 0),
            Position = UDim2.new(0, 56, 0, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, card)
        card.MouseButton1Click:Connect(callback)
    end

    categoryCard("👁", L("cat_esp"), Color3.fromRGB(60, 130, 255), function() showOnly("esp") end, 2)
    categoryCard("🔫", L("cat_aimbot"), Color3.fromRGB(255, 100, 60), function() showOnly("aimbot") end, 3)
    categoryCard("⭐", L("cat_premium"), Color3.fromRGB(255, 200, 60), function() showOnly("premium") end, 4)
    categoryCard("⚙", L("cat_settings"), Color3.fromRGB(150, 150, 150), function() showOnly("settings") end, 5)

    -- Eğer MM2 dışındaysa uyarı
    if game.PlaceId ~= Config.PLACE_ID_MM2 then
        create("TextLabel", {
            Size = UDim2.new(1, -10, 0, 40),
            BackgroundColor3 = Color3.fromRGB(80, 20, 20),
            BackgroundTransparency = 0.3,
            Text = "⚠ " .. L("not_in_game"),
            TextColor3 = Color3.fromRGB(255, 200, 100),
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            TextWrapped = true,
            LayoutOrder = 99,
        }, categories)
    end

    ----------------------------------------------------------------
    -- VIEW: ESP
    ----------------------------------------------------------------
    local esp = newView("esp")
    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        Text = "👁 " .. L("cat_esp"),
        TextColor3 = Color3.fromRGB(220, 220, 220),
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        LayoutOrder = 1,
    }, esp)

    local function toggleRow(label, default, callback, order)
        local row = create("Frame", {
            Size = UDim2.new(1, -10, 0, 40),
            BackgroundColor3 = Color3.fromRGB(30, 12, 12),
            LayoutOrder = order or 2,
        }, esp)
        corner(8); corner(8):Clone().Parent = row
        stroke(Color3.fromRGB(80, 20, 20), 1).Parent = row
        create("TextLabel", {
            Size = UDim2.new(1, -70, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            Text = label,
            TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)
        local btn = create("TextButton", {
            Size = UDim2.new(0, 50, 0, 26),
            Position = UDim2.new(1, -60, 0.5, -13),
            BackgroundColor3 = default and Color3.fromRGB(0, 130, 60) or Color3.fromRGB(80, 30, 30),
            Text = default and L("on") or L("off"),
            TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.GothamBold,
            TextSize = 11,
        }, row)
        corner(6); corner(6):Clone().Parent = btn
        local state = default
        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.BackgroundColor3 = state and Color3.fromRGB(0, 130, 60) or Color3.fromRGB(80, 30, 30)
            btn.Text = state and L("on") or L("off")
            callback(state)
        end)
        return function() return state end
    end

    toggleRow("ESP " .. L("on") .. "/" .. L("off"), false, function(v)
        State.espEnabled = v
    end, 2)
    toggleRow(L("esp_box"), true, function(v) State.espBox = v end, 3)
    toggleRow(L("esp_role_label"), true, function(v) State.espLabel = v end, 4)
    toggleRow(L("esp_distance"), true, function(v) State.espDistance = v end, 5)

    local function colorRow(label, defaultColor, callback, order)
        local row = create("Frame", {
            Size = UDim2.new(1, -10, 0, 40),
            BackgroundColor3 = Color3.fromRGB(30, 12, 12),
            LayoutOrder = order or 6,
        }, esp)
        corner(8); corner(8):Clone().Parent = row
        stroke(Color3.fromRGB(80, 20, 20), 1).Parent = row
        create("TextLabel", {
            Size = UDim2.new(1, -60, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            Text = label,
            TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, row)
        local swatch = create("TextButton", {
            Size = UDim2.new(0, 44, 0, 26),
            Position = UDim2.new(1, -54, 0.5, -13),
            BackgroundColor3 = defaultColor,
            Text = "",
        }, row)
        corner(6); corner(6):Clone().Parent = swatch
        swatch.MouseButton1Click:Connect(function()
            -- sırayla renkleri döndür
            local palette = {
                Color3.fromRGB(255, 50, 50),
                Color3.fromRGB(50, 220, 80),
                Color3.fromRGB(60, 130, 255),
                Color3.fromRGB(255, 200, 60),
                Color3.fromRGB(200, 50, 200),
                Color3.fromRGB(255, 255, 255),
            }
            local cur = swatch.BackgroundColor3
            local idx = 1
            for i, c in ipairs(palette) do
                if c == cur then idx = i break end
            end
            idx = idx % #palette + 1
            swatch.BackgroundColor3 = palette[idx]
            callback(palette[idx])
        end)
    end

    colorRow(L("killer_color"), State.colorMurderer, function(c) State.colorMurderer = c end, 6)
    colorRow(L("innocent_color"), State.colorInnocent, function(c) State.colorInnocent = c end, 7)
    colorRow(L("sheriff_color"), State.colorSheriff, function(c) State.colorSheriff = c end, 8)

    ----------------------------------------------------------------
    -- VIEW: AIMBOT (Otomatik Şerif Atışı)
    ----------------------------------------------------------------
    local aimbot = newView("aimbot")
    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        Text = "🔫 " .. L("cat_aimbot"),
        TextColor3 = Color3.fromRGB(220, 220, 220),
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        LayoutOrder = 1,
    }, aimbot)

    local function makeInfo(text, order)
        create("TextLabel", {
            Size = UDim2.new(1, -10, 0, 32),
            BackgroundColor3 = Color3.fromRGB(40, 20, 10),
            BackgroundTransparency = 0.3,
            Text = text,
            TextColor3 = Color3.fromRGB(255, 200, 100),
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextWrapped = true,
            LayoutOrder = order or 99,
        }, aimbot)
    end

    toggleRow(L("auto_shoot"), false, function(v) State.aimEnabled = v end, 2)
    makeInfo("ℹ " .. L("auto_shoot_hint"), 3)
    makeInfo("📌 " .. L("gun_ready") .. " / " .. L("gun_cooldown") .. " durumları otomatik takip edilir", 4)

    ----------------------------------------------------------------
    -- VIEW: PREMIUM
    ----------------------------------------------------------------
    local premium = newView("premium")
    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        Text = "⭐ " .. L("cat_premium"),
        TextColor3 = Color3.fromRGB(220, 220, 220),
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        LayoutOrder = 1,
    }, premium)

    -- Kilitli alan
    local locked = create("Frame", {
        Name = "Locked",
        Size = UDim2.new(1, -10, 1, -30),
        BackgroundColor3 = Color3.fromRGB(25, 10, 10),
        LayoutOrder = 2,
    }, premium)
    corner(10); corner(10):Clone().Parent = locked
    stroke(Color3.fromRGB(180, 30, 30), 1).Parent = locked
    listLayout(Enum.FillDirection.Vertical, 8, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center).Parent = locked

    create("TextLabel", {
        Size = UDim2.new(0.9, 0, 0, 32),
        BackgroundTransparency = 1,
        Text = L("premium_locked"),
        TextColor3 = Color3.fromRGB(255, 200, 60),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
    }, locked)
    create("TextLabel", {
        Size = UDim2.new(0.9, 0, 0, 50),
        BackgroundTransparency = 1,
        Text = L("premium_msg"),
        TextColor3 = Color3.fromRGB(180, 180, 180),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextWrapped = true,
    }, locked)

    local keyInput = create("TextBox", {
        Size = UDim2.new(0.85, 0, 0, 36),
        BackgroundColor3 = Color3.fromRGB(15, 5, 5),
        Text = "",
        PlaceholderText = L("key_placeholder"),
        PlaceholderColor3 = Color3.fromRGB(100, 100, 100),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.Code,
        TextSize = 14,
        ClearTextOnFocus = false,
    }, locked)
    corner(8); corner(8):Clone().Parent = keyInput
    stroke(Color3.fromRGB(180, 30, 30), 1).Parent = keyInput

    local keyStatus = create("TextLabel", {
        Size = UDim2.new(0.9, 0, 0, 22),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Color3.fromRGB(255, 100, 100),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextWrapped = true,
    }, locked)

    local activateBtn = create("TextButton", {
        Size = UDim2.new(0.6, 0, 0, 36),
        BackgroundColor3 = Color3.fromRGB(180, 30, 30),
        Text = L("activate"),
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
    }, locked)
    corner(8); corner(8):Clone().Parent = activateBtn

    activateBtn.MouseButton1Click:Connect(function()
        local k = keyInput.Text:gsub("%s+", ""):upper()
        if #k < 10 then
            keyStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
            keyStatus.Text = L("key_invalid")
            return
        end
        keyStatus.TextColor3 = Color3.fromRGB(255, 200, 100)
        keyStatus.Text = L("connecting")
        activateBtn.Text = "..."
        verifyKey(k, function(ok, dataOrErr, raw)
            activateBtn.Text = L("activate")
            if ok then
                local d = dataOrErr
                State.premiumActive = true
                State.premiumExpires = math.floor(d.expiresAt / 1000)
                keyStatus.TextColor3 = Color3.fromRGB(100, 230, 130)
                keyStatus.Text = L("key_valid") .. " (" .. d.remainingFormatted .. ")"
                locked.Visible = false
                unlocked.Visible = true
                updatePremiumUI()
            else
                if raw and raw.expired then
                    keyStatus.TextColor3 = Color3.fromRGB(255, 150, 50)
                    keyStatus.Text = L("key_expired")
                else
                    keyStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
                    keyStatus.Text = L("key_invalid") .. " — " .. tostring(dataOrErr)
                end
            end
        end)
    end)

    -- Premium aktif alan
    local unlocked = create("Frame", {
        Name = "Unlocked",
        Size = UDim2.new(1, -10, 1, -30),
        BackgroundColor3 = Color3.fromRGB(20, 15, 5),
        Visible = false,
        LayoutOrder = 3,
    }, premium)
    corner(10); corner(10):Clone().Parent = unlocked
    stroke(Color3.fromRGB(255, 200, 60), 1).Parent = unlocked
    listLayout(Enum.FillDirection.Vertical, 8, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top).Parent = unlocked

    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        Text = L("premium_active"),
        TextColor3 = Color3.fromRGB(255, 200, 60),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        LayoutOrder = 1,
    }, unlocked)

    -- Skin Changer
    local skinRow = create("Frame", {
        Size = UDim2.new(1, -16, 0, 50),
        BackgroundColor3 = Color3.fromRGB(30, 20, 8),
        LayoutOrder = 2,
    }, unlocked)
    corner(8); corner(8):Clone().Parent = skinRow
    stroke(Color3.fromRGB(255, 200, 60), 1).Parent = skinRow
    create("TextLabel", {
        Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = "🎭 " .. L("skin_changer"),
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, skinRow)
    local skinBtn = create("TextButton", {
        Size = UDim2.new(0, 50, 0, 26),
        Position = UDim2.new(1, -60, 0.5, -13),
        BackgroundColor3 = Color3.fromRGB(80, 30, 30),
        Text = L("off"),
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 11,
    }, skinRow)
    corner(6); corner(6):Clone().Parent = skinBtn
    local skinOn = false
    skinBtn.MouseButton1Click:Connect(function()
        if not State.premiumActive then return end
        skinOn = not skinOn
        State.skinChangerEnabled = skinOn
        skinBtn.BackgroundColor3 = skinOn and Color3.fromRGB(0, 130, 60) or Color3.fromRGB(80, 30, 30)
        skinBtn.Text = skinOn and L("on") or L("off")
        applySkinChanger(skinOn)
    end)

    ----------------------------------------------------------------
    -- VIEW: SETTINGS (Dil)
    ----------------------------------------------------------------
    local settings = newView("settings")
    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundTransparency = 1,
        Text = "⚙ " .. L("cat_settings"),
        TextColor3 = Color3.fromRGB(220, 220, 220),
        Font = Enum.Font.GothamSemibold,
        TextSize = 14,
        LayoutOrder = 1,
    }, settings)

    local langRow = create("Frame", {
        Size = UDim2.new(1, -10, 0, 50),
        BackgroundColor3 = Color3.fromRGB(30, 12, 12),
        LayoutOrder = 2,
    }, settings)
    corner(8); corner(8):Clone().Parent = langRow
    stroke(Color3.fromRGB(80, 20, 20), 1).Parent = langRow
    create("TextLabel", {
        Size = UDim2.new(0, 100, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = "🌐 " .. L("language"),
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, langRow)

    local langSegs = {{"tr", "TR"}, {"ru", "RU"}, {"en", "EN"}}
    local segFrame = create("Frame", {
        Size = UDim2.new(0, 150, 0, 30),
        Position = UDim2.new(1, -160, 0.5, -15),
        BackgroundTransparency = 1,
    }, langRow)
    listLayout(Enum.FillDirection.Horizontal, 4, Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center).Parent = segFrame
    for _, seg in ipairs(langSegs) do
        local s = create("TextButton", {
            Size = UDim2.new(1/3, -2, 1, 0),
            BackgroundColor3 = currentLang == seg[1] and Color3.fromRGB(180, 30, 30) or Color3.fromRGB(50, 20, 20),
            Text = seg[2],
            TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.GothamBold,
            TextSize = 12,
        }, segFrame)
        corner(6); corner(6):Clone().Parent = s
        s.MouseButton1Click:Connect(function()
            currentLang = seg[1]
            buildMainGui() -- dil değişti, GUI yeniden kur
        end)
    end

    create("TextLabel", {
        Size = UDim2.new(1, -10, 0, 28),
        BackgroundTransparency = 1,
        Text = "Lapel 2026 v" .. Config.VERSION .. " · Delta Mobile",
        TextColor3 = Color3.fromRGB(100, 100, 100),
        Font = Enum.Font.Gotham,
        TextSize = 11,
        LayoutOrder = 99,
    }, settings)

    -- Geri butonu (her alt view'da üstte küçük)
    local function backBtn(view)
        local btn = create("TextButton", {
            Size = UDim2.new(1, -10, 0, 32),
            BackgroundColor3 = Color3.fromRGB(40, 20, 20),
            Text = L("back"),
            TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            LayoutOrder = 99,
        }, view)
        corner(6); corner(6):Clone().Parent = btn
        btn.MouseButton1Click:Connect(function() showOnly("categories") end)
    end
    backBtn(esp)
    backBtn(aimbot)
    backBtn(premium)
    backBtn(settings)
    -- gameSelect için geri yok

    -- Sürükleme (ana pencereyi de sürüklenebilir yap, başlık çubuğundan)
    do
        local dragging = false
        local dragStart, startPos
        titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = main.Position
            end
        end)
        titleBar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging then
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    local delta = input.Position - dragStart
                    main.Position = UDim2.new(
                        startPos.X.Scale, startPos.X.Offset + delta.X,
                        startPos.Y.Scale, startPos.Y.Offset + delta.Y
                    )
                end
            end
        end)
    end

    State.mainGui = sg
    State.mainFrame = main
    return sg
end

----------------------------------------------------------------
-- ESP RENDER (MM2)
----------------------------------------------------------------
local function getRole(player)
    -- MM2'de oyuncu rolünü tespit etmek için Remote/LocalScript'lere erişim zor.
    -- En güvenilir yöntem: Backpack/Character içindeki silahı kontrol et.
    local char = player.Character
    if not char then return nil end
    local hasGun = false
    local hasKnife = false
    -- Backpack kontrolü
    local bp = player:FindFirstChildOfClass("Backpack")
    if bp then
        for _, item in ipairs(bp:GetChildren()) do
            if item:IsA("Tool") then
                local n = item.Name:lower()
                if n:find("gun") or n:find("revolver") or n:find("pistol") then hasGun = true end
                if n:find("knife") or n:find("blade") or n:find("sword") then hasKnife = true end
            end
        end
    end
    -- Karakter içindeki tool
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") then
            local n = item.Name:lower()
            if n:find("gun") or n:find("revolver") or n:find("pistol") then hasGun = true end
            if n:find("knife") or n:find("blade") or n:find("sword") then hasKnife = true end
        end
    end
    if hasKnife then return "Murderer" end
    if hasGun then return "Sheriff" end
    return "Innocent"
end

local function ensureESP(player)
    if not State.espCache[player] then
        local hl = Instance.new("Highlight")
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0.2
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = CoreGui

        local bb = create("BillboardGui", {
            Size = UDim2.new(0, 200, 0, 50),
            StudsOffset = Vector3.new(0, 3, 0),
            AlwaysOnTop = true,
        })
        bb.Parent = CoreGui
        local nameLabel = create("TextLabel", {
            Size = UDim2.new(1, 0, 0.5, 0),
            BackgroundTransparency = 1,
            TextColor3 = Color3.new(1, 1, 1),
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextStrokeTransparency = 0.4,
        }, bb)
        local distLabel = create("TextLabel", {
            Size = UDim2.new(1, 0, 0.5, 0),
            Position = UDim2.new(0, 0, 0.5, 0),
            BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(220, 220, 220),
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextStrokeTransparency = 0.4,
        }, bb)

        State.espCache[player] = { highlight = hl, billboard = bb, nameLabel = nameLabel, distLabel = distLabel }
    end
    return State.espCache[player]
end

local function clearESP(player)
    if State.espCache[player] then
        local e = State.espCache[player]
        if e.highlight then e.highlight:Destroy() end
        if e.billboard then e.billboard:Destroy() end
        State.espCache[player] = nil
    end
end

local function updateESP()
    if not State.espEnabled then
        for p, _ in pairs(State.espCache) do clearESP(p) end
        return
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Parent then continue end
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then
            clearESP(player)
            continue
        end
        if char.Humanoid.Health <= 0 then
            clearESP(player)
            continue
        end
        local e = ensureESP(player)
        local role = getRole(player)
        local color
        local roleText
        if role == "Murderer" then
            color = State.colorMurderer
            roleText = L("role_murderer")
        elseif role == "Sheriff" then
            color = State.colorSheriff
            roleText = L("role_sheriff")
        else
            color = State.colorInnocent
            roleText = L("role_innocent")
        end
        e.highlight.Adornee = char
        e.highlight.FillColor = color
        e.highlight.OutlineColor = color
        e.highlight.Enabled = true
        e.billboard.Adornee = char:FindFirstChild("Head") or char.HumanoidRootPart
        e.billboard.Enabled = true
        if State.espLabel then
            e.nameLabel.Visible = true
            e.nameLabel.Text = string.format("[%s] %s", roleText, player.DisplayName or player.Name)
            e.nameLabel.TextColor3 = color
        else
            e.nameLabel.Visible = false
        end
        if State.espDistance then
            e.distLabel.Visible = true
            local dist = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
                and math.floor((LocalPlayer.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude) or 0
            e.distLabel.Text = dist .. "m"
        else
            e.distLabel.Visible = false
        end
    end
end

----------------------------------------------------------------
-- AIMBOT (Otomatik Şerif atışı: tuşa 1 kere basınca 1 atış)
----------------------------------------------------------------
local function getMyRole()
    if game.PlaceId ~= Config.PLACE_ID_MM2 then return nil end
    return getRole(LocalPlayer)
end

local function getEquippedTool()
    local char = LocalPlayer.Character
    if not char then return nil end
    for _, c in ipairs(char:GetChildren()) do
        if c:IsA("Tool") then return c end
    end
    return nil
end

local function findNearestMurderer()
    local best, bestDist = nil, math.huge
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 and getRole(p) == "Murderer" then
                local d = (myRoot.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if d < bestDist then best, bestDist = p, d end
            end
        end
    end
    return best
end

local function performSheriffShot()
    -- Mouse.Hit'e en yakın katilin pozisyonunu hedefle
    local murderer = findNearestMurderer()
    if not murderer or not murderer.Character or not murderer.Character:FindFirstChild("Head") then return end
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    local target = murderer.Character.Head
    local myPos = myChar.HumanoidRootPart.Position
    local targetPos = target.Position
    local dir = (targetPos - myPos).Unit
    -- Mouse.Hit'i sanal olarak güncelle
    pcall(function()
        -- Yöntem 1: RemoteEvent (MM2'deki shoot remote'u)
        -- Çoğu executor için en güvenli: Camera.CFrame'i çevirmek + mouse1click
        local camCF = CFrame.new(Camera.CFrame.Position, targetPos)
        Camera.CFrame = camCF
        wait(0.05)
        mouse1click()
    end)
end

----------------------------------------------------------------
-- SKIN CHANGER (Premium)
----------------------------------------------------------------
local function applySkinChanger(on)
    if not on then
        -- restore: karakter spawnlanınca orijinal görünür
        return
    end
    local char = LocalPlayer.Character
    if not char then return end
    -- MM2'de skin ID'leri farklı; burada örnek olarak tüm Accessory'leri altın rengi yap
    for _, desc in ipairs(char:GetChildren()) do
        if desc:IsA("Accessory") or desc:IsA("Shirt") or desc:IsA("Pants") then
            pcall(function()
                if desc:IsA("Shirt") then desc.ShirtTemplate = nil end
                if desc:IsA("Pants") then desc.PantsTemplate = nil end
            end)
        end
    end
    -- Basit altın karakter
    pcall(function()
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Color = Color3.fromRGB(255, 200, 60)
                if part:IsA("MeshPart") then part.TextureID = "" end
            end
        end
    end)
end

----------------------------------------------------------------
-- INIT
----------------------------------------------------------------
local function init()
    -- Toggle butonu
    buildToggleButton()

    -- Sol üst timer güncellemesi
    if State.verifyTick then State.verifyTick:Disconnect() end
    State.verifyTick = RunService.Heartbeat:Connect(function()
        if State.premiumActive then updatePremiumUI() end
    end)

    -- ESP update
    if State.updateConn then State.updateConn:Disconnect() end
    State.updateConn = RunService.RenderStepped:Connect(function()
        if game.PlaceId == Config.PLACE_ID_MM2 and State.espEnabled then
            pcall(updateESP)
        end
    end)

    -- Aimbot: Şerifken çalışır, tuş = sol mouse veya atanmış tuş
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if not State.aimEnabled then return end
        if game.PlaceId ~= Config.PLACE_ID_MM2 then return end
        if getMyRole() ~= "Sheriff" then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            performSheriffShot()
        end
    end)

    -- Otomatik default key'i arka planda doğrulamaya çalış (sessiz)
    spawn(function()
        verifyKey(Config.DEFAULT_KEY, function(ok, data)
            if ok then
                State.premiumActive = true
                State.premiumExpires = math.floor(data.expiresAt / 1000)
            end
        end)
    end)

    -- Oyuncu çıkınca ESP temizle
    Players.PlayerRemoving:Connect(function(p) clearESP(p) end)
end

init()

print("[Lapel 2026] Loaded. Version " .. Config.VERSION)
