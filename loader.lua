--[[
    LAPEL v10
    + Arka plan: rbxassetid://140148264996634
    + Auto Shoot: toggle açınca HEMEN buton cikar (rol/oyun kontrolü yok)
    + Color picker: overlay kaldirildi, UserInputService ile dis klik algila
    + Tüm v9 düzeltmeleri korundu
]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local HttpService      = game:GetService("HttpService")
local LocalPlayer      = Players.LocalPlayer
local Camera           = workspace.CurrentCamera

local API    = "https://lapel-2026-keys.vercel.app"
local MM2_ID = 142823291
local BG_IMG = "rbxassetid://88795516882844"

local function httpReq(o)
    local ok,r = pcall(function()
        if syn and syn.request then return syn.request(o) end
        if request then return request(o) end
        if http_request then return http_request(o) end
    end)
    return ok and r or nil
end
local function GetUI()
    local ok,r = pcall(function() return game:GetService("CoreGui") end)
    return (ok and r) or LocalPlayer:WaitForChild("PlayerGui")
end

-- Renkler (siyah-beyaz)
local T = {
    item    = Color3.fromRGB(22, 22, 30),
    itemHov = Color3.fromRGB(38, 38, 50),
    border  = Color3.fromRGB(52, 52, 70),
    txtMain = Color3.fromRGB(255,255,255),
    txtSub  = Color3.fromRGB(148,148,165),
    txtDim  = Color3.fromRGB(82, 82, 102),
    sep     = Color3.fromRGB(30, 30, 42),
    inpBg   = Color3.fromRGB(16, 16, 24),
    togOn   = Color3.fromRGB(255,255,255),
    togOff  = Color3.fromRGB(40, 40, 55),
    togDot  = Color3.fromRGB(14, 14, 20),
    glow    = Color3.fromRGB(180,180,210),
}

-- Dil tabloları
local Lang = {
    tr = {
        mm2="Murder Mystery 2", skin="Skin Hack", themes="Temalar", lang="Dil",
        espTitle="ESP", espSub="Gorsel Yardim",
        cKiller="Katil Rengi",   cKillerS="Katil oyuncularin rengi",
        cSheriff="Serif Rengi",  cSheriffS="Serif oyuncularin rengi",
        cInno="Masum Rengi",     cInnoS="Masum oyuncularin rengi",
        espBox="ESP Kutusu",     espBoxS="Oyuncular etrafinda kutu",
        espName="Isim",          espNameS="Oyuncu isimlerini goster",
        espDist="Mesafe",        espDistS="Oyuncuya uzaklik",
        espHP="Saglik",          espHPS="Saglik barini goster",
        gunPickup="Silahi Al",   gunPickupS="Dusen silahi al, geri isinlan",
        autoShoot="Auto Shoot",  autoShootInfo="Serif iken katili nisanlar",
        prem="Bu ozellik premiumdur!",
        premD="Gecerli bir key giriniz.",
        keyPlac="KEYINIZI BURAYA GIRIN...",
        keyBtn="KEYИ DOGRULA",
        keyOk="Key dogrulandi!",keyErr="Gecersiz key",keyExp="Suresi dolmus",
        keyChk="Dogrulanıyor...",keyInv="Gecersiz format",
        selectLang="Dil Secin",
        footBar="LAPEL  —  STAY AHEAD. STAY UNDETECTED.",
        on="ACIK", off="KAPALI",
    },
    es = {
        mm2="Murder Mystery 2",skin="Skin Hack",themes="Temas",lang="Idioma",
        espTitle="ESP",espSub="Asistencia Visual",
        cKiller="Color Asesino",  cKillerS="Color de asesinos",
        cSheriff="Color Sheriff", cSheriffS="Color del sheriff",
        cInno="Color Inocente",   cInnoS="Color de inocentes",
        espBox="Caja ESP",        espBoxS="Mostrar caja alrededor",
        espName="Nombre",         espNameS="Mostrar nombres",
        espDist="Distancia",      espDistS="Mostrar distancia",
        espHP="Salud",            espHPS="Mostrar salud",
        gunPickup="Recoger Arma", gunPickupS="Recoger arma y volver",
        autoShoot="Disparo Auto", autoShootInfo="Dispara al asesino como sheriff",
        prem="Esta funcion es premium!",premD="Necesitas una clave valida.",
        keyPlac="INGRESE CLAVE AQUI...",keyBtn="VERIFICAR CLAVE",
        keyOk="Verificado!",keyErr="Invalida",keyExp="Expirada",
        keyChk="Verificando...",keyInv="Formato invalido",
        selectLang="Seleccionar Idioma",
        footBar="LAPEL  —  STAY AHEAD. STAY UNDETECTED.",
        on="ON",off="OFF",
    },
    ru = {
        mm2="Murder Mystery 2",skin="Скин Хак",themes="Темы",lang="Язык",
        espTitle="ESP",espSub="Визуальная Помощь",
        cKiller="Цвет Убийцы",    cKillerS="Цвет ESP убийц",
        cSheriff="Цвет Шерифа",   cSheriffS="Цвет ESP шерифа",
        cInno="Цвет Невиновных",  cInnoS="Цвет ESP невиновных",
        espBox="Коробка ESP",     espBoxS="Показать коробку",
        espName="Имя",            espNameS="Показывать имена",
        espDist="Дистанция",      espDistS="Показывать расстояние",
        espHP="Здоровье",         espHPS="Показывать здоровье",
        gunPickup="Поднять Оружие",gunPickupS="Поднять оружие и вернуться",
        autoShoot="Авто-выстрел", autoShootInfo="Стреляет по убийце шерифом",
        prem="Эта функция премиум!",premD="Нужен действительный ключ.",
        keyPlac="ВВЕДИТЕ КЛЮЧ...",keyBtn="ПРОВЕРИТЬ КЛЮЧ",
        keyOk="Подтверждено!",keyErr="Недействителен",keyExp="Истёк",
        keyChk="Проверка...",keyInv="Неверный формат",
        selectLang="Выбрать Язык",
        footBar="LAPEL  —  STAY AHEAD. STAY UNDETECTED.",
        on="ВКЛ",off="ВЫКЛ",
    },
}
local currentLang = "tr"
local function L(k)
    return (Lang[currentLang] and Lang[currentLang][k]) or Lang.tr[k] or k
end

-- State
local State = {
    espOn=false, espBox=true, espName=true, espDistance=false, espHealth=true,
    colorKiller  = Color3.fromRGB(215,38,38),
    colorSheriff = Color3.fromRGB(60,120,255),
    colorInno    = Color3.fromRGB(40,195,75),
    aimOn=false, premiumOn=false, premiumExpiry=0,
}
local skinStatusRef,skinTimerRef,shootBtnRef,SG_global = nil,nil,nil,nil

-- 12 renk paleti
local COLORS = {
    Color3.fromRGB(215,38,38),  Color3.fromRGB(255,140,0),   Color3.fromRGB(255,220,0),
    Color3.fromRGB(40,195,75),  Color3.fromRGB(0,210,255),   Color3.fromRGB(60,120,255),
    Color3.fromRGB(160,60,255), Color3.fromRGB(255,60,200),  Color3.fromRGB(255,255,255),
    Color3.fromRGB(140,140,155),Color3.fromRGB(100,70,20),   Color3.fromRGB(20,20,28),
}

-- ── ESP (CharacterAdded düzeltmesi) ──────────────────────────
local espConns = {}
local function makeHL(char)
    local old = char:FindFirstChild("LapelESP"); if old then old:Destroy() end
    local hl  = Instance.new("Highlight")
    hl.Name="LapelESP"; hl.FillTransparency=0.5; hl.OutlineTransparency=0
    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent=char
end
local function setupPlayerESP(p)
    if p==LocalPlayer then return end
    if p.Character then makeHL(p.Character) end
    if espConns[p] then espConns[p]:Disconnect() end
    espConns[p]=p.CharacterAdded:Connect(function(char) task.wait(0.05); makeHL(char) end)
end
for _,p in ipairs(Players:GetPlayers()) do setupPlayerESP(p) end
Players.PlayerAdded:Connect(setupPlayerESP)
Players.PlayerRemoving:Connect(function(p)
    if espConns[p] then espConns[p]:Disconnect(); espConns[p]=nil end
end)

-- ── Rol tespiti ────────────────────────────────────────────────
local function getRole(p)
    if p==LocalPlayer then return "Self" end
    local char=p.Character; if not char then return "Innocent" end
    local function scan(c)
        for _,t in ipairs(c:GetChildren()) do if t:IsA("Tool") then
            local n=t.Name:lower()
            if n:find("knife") then return "Murderer" end
            if n:find("sheriff") or n:find("revolver") or n:find("gun") or n:find("pistol") then return "Sheriff" end
        end end
    end
    return scan(char) or (p:FindFirstChild("Backpack") and scan(p.Backpack)) or "Innocent"
end

-- ── Skin ────────────────────────────────────────────────────────
local function applySkin(on)
    pcall(function()
        local c=LocalPlayer.Character; if not c then return end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
                p.Color=on and Color3.fromRGB(220,220,230) or Color3.fromRGB(163,162,165)
            end
        end
    end)
end

-- ── Key ──────────────────────────────────────────────────────────
local function verifyKey(key,cb)
    task.spawn(function()
        local res=httpReq({Url=API.."/api/key/verify",Method="POST",
            Headers={["Content-Type"]="application/json"},
            Body=HttpService:JSONEncode({key=key,userId=tostring(LocalPlayer.UserId)})})
        if not res then cb(false,"HTTP") return end
        local ok,data=pcall(function() return HttpService:JSONDecode(res.Body) end)
        if ok and data and data.valid then cb(true,data) else cb(false,data and data.error or "?",data) end
    end)
end

-- ── Silahi Al ──────────────────────────────────────────────────
local function doGunPickup()
    local char=LocalPlayer.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    for _,obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Tool") then
            local n=obj.Name:lower()
            if n:find("sheriff") or n:find("revolver") or n:find("gun") or n:find("pistol") then
                local h=obj:FindFirstChild("Handle"); if not h then break end
                local saved=hrp.CFrame
                hrp.CFrame=h.CFrame+Vector3.new(0,3,0); task.wait(0.28)
                pcall(function() local pe=obj:FindFirstChildOfClass("RemoteEvent"); if pe then pe:FireServer() end end)
                task.wait(0.10); hrp.CFrame=saved; break
            end
        end
    end
end

-- ── Auto Shoot (1 atis per click) ─────────────────────────────
local function doShoot()
    -- Buton her zaman cikiyor, ama atisas sadece Serif + MM2'de calisir
    if game.PlaceId~=MM2_ID then return end
    if getRole(LocalPlayer)~="Sheriff" then return end
    if not State.aimOn then return end
    local best,bd=nil,math.huge
    local myHRP=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            if getRole(p)=="Murderer" then
                local hum=p.Character:FindFirstChild("Humanoid")
                if hum and hum.Health>0 then
                    local d=(myHRP.Position-p.Character.Head.Position).Magnitude
                    if d<bd then best=p; bd=d end
                end
            end
        end
    end
    if not(best and best.Character and best.Character:FindFirstChild("Head")) then return end
    pcall(function()
        Camera.CFrame=CFrame.new(Camera.CFrame.Position,best.Character.Head.Position)
        task.wait(0.05)
        local ch=LocalPlayer.Character
        if ch then for _,t in ipairs(ch:GetChildren()) do
            if t:IsA("Tool") then pcall(function() t:Activate() end) end
        end end
        if mouse1click then pcall(mouse1click) end
    end)
end

-- ── Render loop ────────────────────────────────────────────────
RunService.RenderStepped:Connect(function()
    -- Auto Shoot butonu: sadece State.aimOn kontrol et (oyun/rol bagimsiz)
    if shootBtnRef and shootBtnRef.Parent then
        shootBtnRef.Visible = State.aimOn
    end
    -- ESP render
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LocalPlayer and p.Character then
            local char=p.Character
            local hum=char:FindFirstChild("Humanoid")
            local hl=char:FindFirstChild("LapelESP")
            if not hl then makeHL(char); hl=char:FindFirstChild("LapelESP") end
            if hl then
                if not State.espOn or (hum and hum.Health<=0) then
                    hl.Enabled=false
                else
                    local role=getRole(p)
                    local col=(role=="Murderer") and State.colorKiller
                           or (role=="Sheriff")  and State.colorSheriff
                           or State.colorInno
                    hl.FillColor=col; hl.OutlineColor=col
                    hl.Enabled=true
                    hl.FillTransparency=State.espBox and 1 or 0.45
                    hl.OutlineTransparency=0
                end
            end
        end
    end
end)

-- ── Timer ─────────────────────────────────────────────────────
task.spawn(function()
    while task.wait(1) do
        if State.premiumOn and State.premiumExpiry>0 then
            local rem=State.premiumExpiry-os.time()
            if rem<=0 then
                State.premiumOn=false; applySkin(false)
                if skinStatusRef and skinStatusRef.Parent then
                    skinStatusRef.TextColor3=Color3.fromRGB(200,80,80); skinStatusRef.Text=L("keyExp")
                end
                if skinTimerRef and skinTimerRef.Parent then skinTimerRef.Text="" end
            else
                if skinTimerRef and skinTimerRef.Parent then
                    skinTimerRef.Text=string.format("%02d:%02d:%02d kaldi",
                        math.floor(rem/3600),math.floor((rem%3600)/60),rem%60)
                end
            end
        end
    end
end)

-- Active color picker popup referansi
local activePopup = nil
local activePopupConn = nil

-- ═══════════════════════════════════════════════
-- GUI BUILDER
-- ═══════════════════════════════════════════════
local function buildGUI()
    local UIP=GetUI()
    local old=UIP:FindFirstChild("LapelGUI"); if old then old:Destroy() end
    -- Aktif popup kapat
    if activePopup and activePopup.Parent then activePopup:Destroy(); activePopup=nil end
    if activePopupConn then activePopupConn:Disconnect(); activePopupConn=nil end

    -- Responsive boyut — gorsel ile ayni oran (1.62:1)
    local vp=Camera.ViewportSize
    local W=math.clamp(math.floor(vp.X*0.76),300,420)
    local H=math.clamp(math.floor(W/1.62),185,260)
    local SW=math.clamp(math.floor(W*0.27),80,115)  -- gorsel ile ayni sidebar orani
    local FH=20

    -- ── Yardimcilar ──────────────────────────────────────────
    local function R(o,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 8); c.Parent=o end
    local function S(o,col,th) local s=Instance.new("UIStroke"); s.Color=col; s.Thickness=th or 1.2; s.Parent=o; return s end
    local function Tw(o,p,t) TweenService:Create(o,TweenInfo.new(t or 0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),p):Play() end
    local function CA(b)
        local orig=b.BackgroundColor3
        Tw(b,{BackgroundColor3=Color3.new(math.min(orig.R+0.14,1),math.min(orig.G+0.12,1),math.min(orig.B+0.12,1))},0.07)
        task.delay(0.1,function() Tw(b,{BackgroundColor3=orig},0.14) end)
    end
    local function Drag(frame,handle)
        handle=handle or frame
        local drag,ds,sp=false,nil,nil
        handle.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                drag=true; ds=i.Position; sp=frame.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if not drag then return end
            if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
                local d=i.Position-ds; frame.Position=UDim2.new(0,sp.X.Offset+d.X,0,sp.Y.Offset+d.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
        end)
    end

    -- ── iOS Toggle ───────────────────────────────────────────
    local function IosToggle(parent,xOff,yOff,initState,cb)
        local pill=Instance.new("TextButton",parent)
        pill.Size=UDim2.new(0,40,0,22); pill.Position=UDim2.new(1,xOff,0,yOff)
        pill.BackgroundColor3=initState and T.togOn or T.togOff
        pill.BorderSizePixel=0; pill.Text=""; pill.ZIndex=parent.ZIndex+2
        R(pill,11)
        local dot=Instance.new("Frame",pill)
        dot.Size=UDim2.new(0,16,0,16)
        dot.Position=initState and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)
        dot.BackgroundColor3=initState and T.togDot or T.txtMain
        dot.BorderSizePixel=0; dot.ZIndex=pill.ZIndex+1; R(dot,8)
        local state=initState
        pill.MouseButton1Click:Connect(function()
            state=not state
            Tw(pill,{BackgroundColor3=state and T.togOn or T.togOff},0.2)
            Tw(dot,{Position=state and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)},0.2)
            Tw(dot,{BackgroundColor3=state and T.togDot or T.txtMain},0.2)
            if cb then cb(state) end
        end)
        return pill
    end

    -- ── Color Picker (OVERLAY YOK — UserInputService ile disarik klik algilama) ──
    local function ColorBtn(parent,xOff,yOff,getter,setter)
        local circle=Instance.new("TextButton",parent)
        circle.Size=UDim2.new(0,22,0,22); circle.Position=UDim2.new(1,xOff,0,yOff)
        circle.BackgroundColor3=getter(); circle.BorderSizePixel=0; circle.Text=""
        circle.ZIndex=parent.ZIndex+2; R(circle,11); S(circle,T.txtSub,1.2)

        local chev=Instance.new("TextLabel",parent)
        chev.Size=UDim2.new(0,14,0,22); chev.Position=UDim2.new(1,xOff+24,0,yOff)
        chev.BackgroundTransparency=1; chev.Text="v"; chev.TextColor3=T.txtDim
        chev.Font=Enum.Font.GothamBold; chev.TextSize=10; chev.ZIndex=parent.ZIndex+2

        circle.MouseButton1Click:Connect(function()
            local SG=SG_global; if not SG then return end
            -- Onceki popup'u kapat
            if activePopup and activePopup.Parent then activePopup:Destroy(); activePopup=nil end
            if activePopupConn then activePopupConn:Disconnect(); activePopupConn=nil end

            -- Popup olustur
            local popup=Instance.new("Frame",SG)
            popup.Size=UDim2.new(0,158,0,96); popup.ZIndex=200
            popup.BackgroundColor3=Color3.fromRGB(18,18,26); popup.BorderSizePixel=0
            R(popup,10); S(popup,T.border,1.2)
            activePopup=popup

            local px=math.clamp(circle.AbsolutePosition.X-60,4,vp.X-162)
            local py=circle.AbsolutePosition.Y+26
            if py+96>vp.Y then py=circle.AbsolutePosition.Y-100 end
            popup.Position=UDim2.new(0,px,0,py)

            local grid=Instance.new("UIGridLayout",popup)
            grid.CellSize=UDim2.new(0,24,0,24); grid.CellPadding=UDim2.new(0,5,0,5)
            local pp=Instance.new("UIPadding",popup); pp.PaddingTop=UDim.new(0,9); pp.PaddingLeft=UDim.new(0,9)

            for _,col in ipairs(COLORS) do
                local sw=Instance.new("TextButton",popup)
                sw.Size=UDim2.new(0,24,0,24); sw.BackgroundColor3=col
                sw.Text=""; sw.BorderSizePixel=0; sw.ZIndex=202
                R(sw,12)
                if (col-getter()).Magnitude<0.1 then S(sw,Color3.new(1,1,1),2) end
                sw.MouseButton1Click:Connect(function()
                    setter(col); circle.BackgroundColor3=col
                    if activePopup then activePopup:Destroy(); activePopup=nil end
                    if activePopupConn then activePopupConn:Disconnect(); activePopupConn=nil end
                end)
            end

            -- Disarik klik algilama (overlay OLMADAN) — 50ms bekle sonra pozisyon kontrol
            activePopupConn=UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType==Enum.UserInputType.MouseButton1 or
                   input.UserInputType==Enum.UserInputType.Touch then
                    task.delay(0.06,function()
                        if not(activePopup and activePopup.Parent) then return end
                        local mx,my=input.Position.X,input.Position.Y
                        local ap=activePopup.AbsolutePosition; local as=activePopup.AbsoluteSize
                        if mx<ap.X or mx>ap.X+as.X or my<ap.Y or my>ap.Y+as.Y then
                            activePopup:Destroy(); activePopup=nil
                            activePopupConn:Disconnect(); activePopupConn=nil
                        end
                    end)
                end
            end)
        end)
        return circle
    end

    -- ── ScreenGui ────────────────────────────────────────────
    local SG=Instance.new("ScreenGui",UIP)
    SG.Name="LapelGUI"; SG.IgnoreGuiInset=true; SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    SG.DisplayOrder=9999; SG.ResetOnSpawn=false; SG_global=SG

    -- Glow cerceveleri (baslangicta gizli)
    local glowFrames={}
    for _,g in ipairs({{t=0.80,e=4},{t=0.88,e=9},{t=0.94,e=16}}) do
        local gf=Instance.new("Frame",SG)
        gf.Size=UDim2.new(0,W+g.e*2,0,H+g.e*2)
        gf.Position=UDim2.new(0.5,-(W/2+g.e),0.5,-(H/2+g.e))
        gf.BackgroundColor3=T.glow; gf.BackgroundTransparency=g.t
        gf.BorderSizePixel=0; gf.ZIndex=46; gf.Visible=false
        R(gf,14+g.e); table.insert(glowFrames,gf)
    end

    -- Auto Shoot butonu (yatay dikdortgen, sürüklenebilir)
    local shootBtn=Instance.new("TextButton",SG)
    shootBtn.Size=UDim2.new(0,120,0,34); shootBtn.Position=UDim2.new(0.5,-60,1,-56)
    shootBtn.Text="AUTO SHOOT"; shootBtn.TextColor3=T.txtMain
    shootBtn.Font=Enum.Font.GothamBlack; shootBtn.TextSize=12
    shootBtn.BackgroundColor3=T.item; shootBtn.BorderSizePixel=0
    shootBtn.Visible=false; shootBtn.ZIndex=90
    R(shootBtn,8); S(shootBtn,T.border,1.5); Drag(shootBtn)
    shootBtn.MouseButton1Click:Connect(function() CA(shootBtn); doShoot() end)
    shootBtn.MouseEnter:Connect(function() Tw(shootBtn,{BackgroundColor3=T.itemHov},0.12) end)
    shootBtn.MouseLeave:Connect(function() Tw(shootBtn,{BackgroundColor3=T.item},0.12) end)
    shootBtnRef=shootBtn

    -- Toggle butonu (RVIALS V24 - sabit piksel)
    local Tgl=Instance.new("TextButton",SG)
    Tgl.Size=UDim2.new(0,24,0,24); Tgl.Position=UDim2.new(0,10,0,140)
    Tgl.Text="L"; Tgl.BackgroundColor3=Color3.fromRGB(10,10,14)
    Tgl.TextColor3=T.txtMain; Tgl.Font=Enum.Font.GothamBlack; Tgl.TextSize=14
    Tgl.BorderSizePixel=0; Tgl.ZIndex=100
    R(Tgl,24); S(Tgl,T.border,1.5); Drag(Tgl)

    -- Ana Frame
    local Main=Instance.new("Frame",SG)
    Main.Size=UDim2.new(0,W,0,H); Main.Position=UDim2.new(0.5,-W/2,0.5,-H/2)
    Main.BackgroundTransparency=1  -- Resim arka plani sagliyor
    Main.Visible=false; Main.Active=true; Main.BorderSizePixel=0; Main.ZIndex=50
    R(Main,16); Drag(Main)

    -- ARKA PLAN GORSEL
    local bgImg=Instance.new("ImageLabel",Main)
    bgImg.Size=UDim2.new(1,0,1,0); bgImg.BackgroundTransparency=1
    bgImg.Image=BG_IMG; bgImg.ScaleType=Enum.ScaleType.Stretch
    bgImg.ZIndex=1; R(bgImg,16)

    -- Hafif ince border (gorsel ustunde)
    S(Main,T.border,1.5)

    -- Toggle / Close baglantisi
    local function toggleMain()
        Main.Visible=not Main.Visible
        for _,gf in ipairs(glowFrames) do gf.Visible=Main.Visible end
    end
    Tgl.MouseButton1Click:Connect(function() CA(Tgl); toggleMain() end)

    -- Pencere butonlari
    local function wb(txt,xOff,col)
        local b=Instance.new("TextButton",Main)
        b.Size=UDim2.new(0,22,0,22); b.Position=UDim2.new(1,xOff,0,6)
        b.BackgroundColor3=T.item; b.BackgroundTransparency=0.3
        b.Text=txt; b.TextColor3=col or T.txtSub
        b.Font=Enum.Font.GothamBold; b.TextSize=11; b.BorderSizePixel=0; b.ZIndex=65
        R(b,11); S(b,T.sep,1)
        b.MouseEnter:Connect(function() Tw(b,{BackgroundColor3=T.itemHov},0.12) end)
        b.MouseLeave:Connect(function() Tw(b,{BackgroundColor3=T.item},0.12) end)
        return b
    end
    local MinBtn=wb("-",-78)
    local CloseBtn=wb("x",-26,Color3.fromRGB(200,80,80))
    CloseBtn.MouseButton1Click:Connect(function()
        CA(CloseBtn); Main.Visible=false
        for _,gf in ipairs(glowFrames) do gf.Visible=false end
    end)
    MinBtn.MouseButton1Click:Connect(function()
        CA(MinBtn); Main.Visible=false
        for _,gf in ipairs(glowFrames) do gf.Visible=false end
    end)

    -- Sidebar (saydam - resim gorulsun)
    local Sidebar=Instance.new("Frame",Main)
    Sidebar.Size=UDim2.new(0,SW,0,H-FH); Sidebar.BackgroundTransparency=1
    Sidebar.BorderSizePixel=0; Sidebar.ZIndex=52

    -- Sag panel (saydam)
    local RP=Instance.new("Frame",Main)
    RP.Size=UDim2.new(1,-(SW+1),0,H-FH); RP.Position=UDim2.new(0,SW+1,0,0)
    RP.BackgroundTransparency=1; RP.BorderSizePixel=0; RP.ZIndex=52; RP.ClipsDescendants=true

    -- Footer (saydam)
    local Foot=Instance.new("Frame",Main)
    Foot.Size=UDim2.new(1,0,0,FH); Foot.Position=UDim2.new(0,0,1,-FH)
    Foot.BackgroundTransparency=1; Foot.BorderSizePixel=0; Foot.ZIndex=56
    local fl=Instance.new("TextLabel",Foot); fl.Size=UDim2.new(1,0,1,0)
    fl.BackgroundTransparency=1; fl.Text=L("footBar"); fl.TextColor3=T.txtDim
    fl.Font=Enum.Font.GothamBold; fl.TextSize=7; fl.ZIndex=58

    -- Sidebar logo metinleri (resmin ustunde, saydam bg)
    local lapelY=math.floor(H*0.22)
    local bigL=Instance.new("TextLabel",Sidebar)
    bigL.Size=UDim2.new(1,0,0,math.floor(H*0.21)); bigL.Position=UDim2.new(0,0,0,3)
    bigL.BackgroundTransparency=1; bigL.Text=""  -- resim zaten L logosu gosteriyor
    bigL.ZIndex=60

    local lapelTxt=Instance.new("TextLabel",Sidebar)
    lapelTxt.Size=UDim2.new(1,-4,0,15); lapelTxt.Position=UDim2.new(0,2,0,lapelY+2)
    lapelTxt.BackgroundTransparency=1; lapelTxt.Text=""  -- resim gosteriyor
    lapelTxt.TextColor3=T.txtMain; lapelTxt.Font=Enum.Font.GothamBlack; lapelTxt.TextSize=13; lapelTxt.ZIndex=60

    -- Alt bilgi
    local sideFoot=Instance.new("TextLabel",Sidebar)
    sideFoot.Size=UDim2.new(1,-6,0,18); sideFoot.Position=UDim2.new(0,3,1,-24)
    sideFoot.BackgroundTransparency=1; sideFoot.Text=""  -- resim gosteriyor
    sideFoot.ZIndex=60

    -- Separator (gorsel ayirici — hafif)
    local sideSep=Instance.new("Frame",Sidebar)
    sideSep.Size=UDim2.new(1,-10,0,1); sideSep.Position=UDim2.new(0,5,0,lapelY+28)
    sideSep.BackgroundColor3=T.sep; sideSep.BackgroundTransparency=0.5
    sideSep.BorderSizePixel=0; sideSep.ZIndex=60

    -- ── Ekranlar ─────────────────────────────────────────────
    local rScreens={}
    local function newRS(name)
        local s=Instance.new("Frame",RP); s.Size=UDim2.new(1,0,1,0)
        s.BackgroundTransparency=1; s.Visible=false; s.ZIndex=56; s.ClipsDescendants=true
        rScreens[name]=s; return s
    end
    local function showR(name)
        for n,s in pairs(rScreens) do s.Visible=(n==name) end
    end

    -- ── HOME ─────────────────────────────────────────────────
    local homeS=newRS("home")
    -- Resim zaten ana icerik gosteriyor, sadece interaktif elementler ekle
    local verB=Instance.new("TextButton",homeS)
    verB.Size=UDim2.new(0,100,0,20); verB.Position=UDim2.new(0.5,-50,1,-32)
    verB.BackgroundColor3=T.item; verB.BackgroundTransparency=0.4
    verB.Text="v10.0"; verB.TextColor3=T.txtDim
    verB.Font=Enum.Font.GothamBold; verB.TextSize=8; verB.BorderSizePixel=0; verB.ZIndex=60
    R(verB,10); S(verB,T.sep,1)

    -- ── MM2 ──────────────────────────────────────────────────
    local mm2S=newRS("mm2")
    -- Baslik (resmin icerigi ile ortusuyor)
    local m2t=Instance.new("TextLabel",mm2S)
    m2t.Size=UDim2.new(1,-14,0,16); m2t.Position=UDim2.new(0,7,0,8)
    m2t.BackgroundTransparency=1; m2t.Text="MURDER MYSTERY 2"
    m2t.TextColor3=T.txtMain; m2t.Font=Enum.Font.GothamBlack; m2t.TextSize=12
    m2t.TextXAlignment=Enum.TextXAlignment.Left; m2t.ZIndex=60
    local m2sub=Instance.new("TextLabel",mm2S)
    m2sub.Size=UDim2.new(1,-14,0,12); m2sub.Position=UDim2.new(0,7,0,24)
    m2sub.BackgroundTransparency=1; m2sub.Text="ESP & VISUAL ASSIST"
    m2sub.TextColor3=Color3.fromRGB(100,130,220); m2sub.Font=Enum.Font.GothamBold; m2sub.TextSize=9
    m2sub.TextXAlignment=Enum.TextXAlignment.Left; m2sub.ZIndex=60
    local m2sep=Instance.new("Frame",mm2S); m2sep.Size=UDim2.new(1,-14,0,1); m2sep.Position=UDim2.new(0,7,0,38)
    m2sep.BackgroundColor3=T.sep; m2sep.BackgroundTransparency=0.3; m2sep.BorderSizePixel=0; m2sep.ZIndex=60

    local RPW=W-(SW+1)
    local LCW=math.floor(RPW*0.36)

    -- Sol sutun
    local LC=Instance.new("Frame",mm2S)
    LC.Size=UDim2.new(0,LCW,1,-44); LC.Position=UDim2.new(0,6,0,44)
    LC.BackgroundTransparency=1; LC.ZIndex=60; LC.ClipsDescendants=true

    local colSepV=Instance.new("Frame",mm2S)
    colSepV.Size=UDim2.new(0,1,1,-44); colSepV.Position=UDim2.new(0,LCW+8,0,44)
    colSepV.BackgroundColor3=T.sep; colSepV.BackgroundTransparency=0.3; colSepV.BorderSizePixel=0; colSepV.ZIndex=60

    -- Sag sutun (scrollable)
    local RC=Instance.new("ScrollingFrame",mm2S)
    RC.Size=UDim2.new(1,-(LCW+12),1,-44); RC.Position=UDim2.new(0,LCW+12,0,44)
    RC.BackgroundTransparency=1; RC.BorderSizePixel=0; RC.ZIndex=60
    RC.ScrollBarThickness=2; RC.ScrollBarImageColor3=T.sep; RC.CanvasSize=UDim2.new(0,0,0,0)
    local rcL=Instance.new("UIListLayout",RC)
    rcL.Padding=UDim.new(0,3); rcL.HorizontalAlignment=Enum.HorizontalAlignment.Center
    rcL.SortOrder=Enum.SortOrder.LayoutOrder
    Instance.new("UIPadding",RC).PaddingTop=UDim.new(0,4)
    rcL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        RC.CanvasSize=UDim2.new(0,0,0,rcL.AbsoluteContentSize.Y+6)
    end)

    -- Sol sutun toggle
    local lcY=4
    local function lcTog(lbl,sub,initS,cb,h)
        h=h or 48
        local row=Instance.new("Frame",LC)
        row.Size=UDim2.new(1,-2,0,h); row.Position=UDim2.new(0,1,0,lcY)
        row.BackgroundColor3=T.item; row.BackgroundTransparency=0.25
        row.BorderSizePixel=0; row.ZIndex=61; R(row,8); S(row,T.sep,1)
        local tl=Instance.new("TextLabel",row); tl.Size=UDim2.new(1,-4,0,16); tl.Position=UDim2.new(0,8,0,6)
        tl.BackgroundTransparency=1; tl.Text=lbl; tl.TextColor3=T.txtMain
        tl.Font=Enum.Font.GothamBold; tl.TextSize=11; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.ZIndex=62
        if sub then
            local sl=Instance.new("TextLabel",row); sl.Size=UDim2.new(1,-4,0,11); sl.Position=UDim2.new(0,8,0,24)
            sl.BackgroundTransparency=1; sl.Text=sub; sl.TextColor3=T.txtDim
            sl.Font=Enum.Font.Gotham; sl.TextSize=8; sl.TextXAlignment=Enum.TextXAlignment.Left; sl.ZIndex=62
        end
        IosToggle(row,-46,h/2-11,initS,cb)
        lcY=lcY+h+4; return row
    end

    lcTog(L("espTitle"),L("espSub"),State.espOn,function(v) State.espOn=v end,48)

    -- Auto Shoot toggle (ekrana buton gelicek)
    local lcY_before=lcY
    lcTog(L("autoShoot"),L("autoShootInfo"),State.aimOn,function(v) State.aimOn=v end,48)

    -- Silahi Al
    lcY=lcY+2
    local gunBtn=Instance.new("TextButton",LC)
    gunBtn.Size=UDim2.new(1,-2,0,28); gunBtn.Position=UDim2.new(0,1,0,lcY)
    gunBtn.BackgroundColor3=T.item; gunBtn.BackgroundTransparency=0.25
    gunBtn.Text="Silahi Al"; gunBtn.TextColor3=T.txtSub
    gunBtn.Font=Enum.Font.GothamBold; gunBtn.TextSize=10; gunBtn.BorderSizePixel=0; gunBtn.ZIndex=61
    R(gunBtn,8); S(gunBtn,T.sep,1)
    gunBtn.MouseEnter:Connect(function() Tw(gunBtn,{BackgroundTransparency=0.1},0.12) end)
    gunBtn.MouseLeave:Connect(function() Tw(gunBtn,{BackgroundTransparency=0.25},0.12) end)
    gunBtn.MouseButton1Click:Connect(function() CA(gunBtn); doGunPickup() end)

    -- Sag sutun: ESP ayarlari
    local espHdrLbl=Instance.new("TextLabel",RC); espHdrLbl.Size=UDim2.new(1,-8,0,14)
    espHdrLbl.BackgroundTransparency=1; espHdrLbl.LayoutOrder=1
    espHdrLbl.Text="ESP AYARLARI"; espHdrLbl.TextColor3=T.txtDim
    espHdrLbl.Font=Enum.Font.GothamBold; espHdrLbl.TextSize=8
    espHdrLbl.TextXAlignment=Enum.TextXAlignment.Left; espHdrLbl.ZIndex=61

    local function colorRow(lbl,sub,getter,setter,order)
        local row=Instance.new("Frame",RC); row.Size=UDim2.new(1,-8,0,40)
        row.BackgroundColor3=T.item; row.BackgroundTransparency=0.25
        row.BorderSizePixel=0; row.LayoutOrder=order; row.ZIndex=61; R(row,8); S(row,T.sep,1)
        local tl=Instance.new("TextLabel",row); tl.Size=UDim2.new(1,-52,0,16); tl.Position=UDim2.new(0,10,0,4)
        tl.BackgroundTransparency=1; tl.Text=lbl; tl.TextColor3=T.txtMain
        tl.Font=Enum.Font.GothamBold; tl.TextSize=10; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.ZIndex=62
        local sl=Instance.new("TextLabel",row); sl.Size=UDim2.new(1,-52,0,12); sl.Position=UDim2.new(0,10,0,22)
        sl.BackgroundTransparency=1; sl.Text=sub; sl.TextColor3=T.txtDim
        sl.Font=Enum.Font.Gotham; sl.TextSize=8; sl.TextXAlignment=Enum.TextXAlignment.Left; sl.ZIndex=62
        ColorBtn(row,-50,9,getter,setter)
        return row
    end

    local function togRow(lbl,sub,initS,cb,order)
        local row=Instance.new("Frame",RC); row.Size=UDim2.new(1,-8,0,36)
        row.BackgroundColor3=T.item; row.BackgroundTransparency=0.25
        row.BorderSizePixel=0; row.LayoutOrder=order; row.ZIndex=61; R(row,8); S(row,T.sep,1)
        local tl=Instance.new("TextLabel",row); tl.Size=UDim2.new(1,-52,0,15); tl.Position=UDim2.new(0,10,0,5)
        tl.BackgroundTransparency=1; tl.Text=lbl; tl.TextColor3=T.txtMain
        tl.Font=Enum.Font.GothamBold; tl.TextSize=10; tl.TextXAlignment=Enum.TextXAlignment.Left; tl.ZIndex=62
        local sl=Instance.new("TextLabel",row); sl.Size=UDim2.new(1,-52,0,12); sl.Position=UDim2.new(0,10,0,22)
        sl.BackgroundTransparency=1; sl.Text=sub; sl.TextColor3=T.txtDim
        sl.Font=Enum.Font.Gotham; sl.TextSize=8; sl.TextXAlignment=Enum.TextXAlignment.Left; sl.ZIndex=62
        IosToggle(row,-50,7,initS,cb)
        return row
    end

    colorRow(L("cKiller"),L("cKillerS"),function() return State.colorKiller end,function(c) State.colorKiller=c end,2)
    colorRow(L("cSheriff"),L("cSheriffS"),function() return State.colorSheriff end,function(c) State.colorSheriff=c end,3)
    colorRow(L("cInno"),L("cInnoS"),function() return State.colorInno end,function(c) State.colorInno=c end,4)
    togRow(L("espBox"),L("espBoxS"),State.espBox,function(v) State.espBox=v end,5)
    togRow(L("espName"),L("espNameS"),State.espName,function(v) State.espName=v end,6)
    togRow(L("espDist"),L("espDistS"),State.espDistance,function(v) State.espDistance=v end,7)
    togRow(L("espHP"),L("espHPS"),State.espHealth,function(v) State.espHealth=v end,8)

    -- ── SKIN HACK ────────────────────────────────────────────
    local skinS=newRS("skin")
    local sT=Instance.new("TextLabel",skinS); sT.Size=UDim2.new(1,-14,0,20); sT.Position=UDim2.new(0,7,0,8)
    sT.BackgroundTransparency=1; sT.Text="SKIN HACK"; sT.TextColor3=T.txtMain
    sT.Font=Enum.Font.GothamBlack; sT.TextSize=16; sT.ZIndex=60
    local sSep=Instance.new("Frame",skinS); sSep.Size=UDim2.new(1,-14,0,1); sSep.Position=UDim2.new(0,7,0,32)
    sSep.BackgroundColor3=T.sep; sSep.BackgroundTransparency=0.4; sSep.BorderSizePixel=0; sSep.ZIndex=60
    local sP=Instance.new("TextLabel",skinS); sP.Size=UDim2.new(1,-14,0,16); sP.Position=UDim2.new(0,7,0,38)
    sP.BackgroundTransparency=1; sP.Text=L("prem"); sP.TextColor3=T.txtMain
    sP.Font=Enum.Font.GothamBlack; sP.TextSize=12; sP.ZIndex=60
    local sD=Instance.new("TextLabel",skinS); sD.Size=UDim2.new(1,-18,0,24); sD.Position=UDim2.new(0,9,0,56)
    sD.BackgroundTransparency=1; sD.Text=L("premD"); sD.TextColor3=T.txtDim
    sD.Font=Enum.Font.Gotham; sD.TextSize=9; sD.TextWrapped=true; sD.ZIndex=60
    local kF=Instance.new("Frame",skinS); kF.Size=UDim2.new(1,-16,0,32); kF.Position=UDim2.new(0,8,0,84)
    kF.BackgroundColor3=T.inpBg; kF.BackgroundTransparency=0.2; kF.BorderSizePixel=0; kF.ZIndex=60; R(kF,8); S(kF,T.border,1)
    local keyInput=Instance.new("TextBox",kF); keyInput.Size=UDim2.new(1,-16,1,-4); keyInput.Position=UDim2.new(0,8,0,2)
    keyInput.BackgroundTransparency=1; keyInput.Text=""; keyInput.PlaceholderText=L("keyPlac")
    keyInput.PlaceholderColor3=T.txtDim; keyInput.TextColor3=T.txtMain
    keyInput.Font=Enum.Font.GothamBold; keyInput.TextSize=9; keyInput.ClearTextOnFocus=false; keyInput.BorderSizePixel=0; keyInput.ZIndex=61
    local vBtn=Instance.new("TextButton",skinS); vBtn.Size=UDim2.new(1,-16,0,30); vBtn.Position=UDim2.new(0,8,0,122)
    vBtn.BackgroundColor3=T.item; vBtn.BackgroundTransparency=0.2; vBtn.Text=L("keyBtn"); vBtn.TextColor3=T.txtMain
    vBtn.Font=Enum.Font.GothamBlack; vBtn.TextSize=10; vBtn.BorderSizePixel=0; vBtn.ZIndex=60; R(vBtn,8); S(vBtn,T.border,1.2)
    vBtn.MouseEnter:Connect(function() Tw(vBtn,{BackgroundTransparency=0},0.12) end)
    vBtn.MouseLeave:Connect(function() Tw(vBtn,{BackgroundTransparency=0.2},0.12) end)
    local sStatus=Instance.new("TextLabel",skinS); sStatus.Size=UDim2.new(1,-14,0,14); sStatus.Position=UDim2.new(0,7,0,158)
    sStatus.BackgroundTransparency=1; sStatus.Text=""; sStatus.TextColor3=Color3.fromRGB(200,80,80)
    sStatus.Font=Enum.Font.Gotham; sStatus.TextSize=9; sStatus.ZIndex=60; skinStatusRef=sStatus
    local sTimer=Instance.new("TextLabel",skinS); sTimer.Size=UDim2.new(1,-14,0,14); sTimer.Position=UDim2.new(0,7,0,173)
    sTimer.BackgroundTransparency=1; sTimer.Text=""; sTimer.TextColor3=T.txtSub
    sTimer.Font=Enum.Font.Code; sTimer.TextSize=9; sTimer.ZIndex=60; skinTimerRef=sTimer
    if State.premiumOn then sStatus.TextColor3=Color3.fromRGB(100,200,120); sStatus.Text=L("keyOk") end
    vBtn.MouseButton1Click:Connect(function()
        local k=keyInput.Text:gsub("%s+",""):upper()
        if #k<10 then sStatus.TextColor3=Color3.fromRGB(200,80,80); sStatus.Text=L("keyInv"); return end
        CA(vBtn); sStatus.TextColor3=T.txtSub; sStatus.Text=L("keyChk"); vBtn.Text="..."
        verifyKey(k,function(ok,d,raw)
            vBtn.Text=L("keyBtn")
            if ok then
                State.premiumOn=true; State.premiumExpiry=math.floor(d.expiresAt/1000)
                sStatus.TextColor3=Color3.fromRGB(100,200,120); sStatus.Text=L("keyOk"); applySkin(true)
            else
                sStatus.TextColor3=Color3.fromRGB(200,80,80)
                sStatus.Text=(raw and raw.expired) and L("keyExp") or L("keyErr")
            end
        end)
    end)

    -- ── TEMALAR ──────────────────────────────────────────────
    local themesS=newRS("themes")
    local thT=Instance.new("TextLabel",themesS); thT.Size=UDim2.new(1,-14,0,16); thT.Position=UDim2.new(0,7,0,8)
    thT.BackgroundTransparency=1; thT.Text="TEMALAR"; thT.TextColor3=T.txtMain
    thT.Font=Enum.Font.GothamBlack; thT.TextSize=12; thT.TextXAlignment=Enum.TextXAlignment.Left; thT.ZIndex=60
    local thI=Instance.new("TextLabel",themesS); thI.Size=UDim2.new(1,-18,0,50); thI.Position=UDim2.new(0,9,0,30)
    thI.BackgroundTransparency=1; thI.Text="Aktif: Siyah & Beyaz (Dark)\n\nRenk ozellestirme icin ESP ekranindaki renk secicileri kullanin."
    thI.TextColor3=T.txtSub; thI.Font=Enum.Font.Gotham; thI.TextSize=9
    thI.TextWrapped=true; thI.TextXAlignment=Enum.TextXAlignment.Left; thI.ZIndex=60

    -- ── DIL ──────────────────────────────────────────────────
    local langS=newRS("language")
    local lH=Instance.new("TextLabel",langS); lH.Size=UDim2.new(1,-14,0,16); lH.Position=UDim2.new(0,7,0,8)
    lH.BackgroundTransparency=1; lH.Text="DIL / LANGUAGE"; lH.TextColor3=T.txtMain
    lH.Font=Enum.Font.GothamBlack; lH.TextSize=12; lH.TextXAlignment=Enum.TextXAlignment.Left; lH.ZIndex=60
    local lSep=Instance.new("Frame",langS); lSep.Size=UDim2.new(1,-14,0,1); lSep.Position=UDim2.new(0,7,0,28)
    lSep.BackgroundColor3=T.sep; lSep.BackgroundTransparency=0.4; lSep.BorderSizePixel=0; lSep.ZIndex=60
    local function langBtn(code,flag,name,yPos)
        local isA=(currentLang==code)
        local row=Instance.new("TextButton",langS); row.Size=UDim2.new(1,-14,0,36); row.Position=UDim2.new(0,7,0,yPos)
        row.BackgroundColor3=T.item; row.BackgroundTransparency=isA and 0.1 or 0.3
        row.Text=""; row.BorderSizePixel=0; row.ZIndex=60; R(row,9); S(row,isA and T.border or T.sep,1)
        local fl=Instance.new("TextLabel",row); fl.Size=UDim2.new(0,30,1,0); fl.Position=UDim2.new(0,7,0,0)
        fl.BackgroundTransparency=1; fl.Text=flag; fl.TextColor3=T.txtMain; fl.Font=Enum.Font.GothamBold; fl.TextSize=11; fl.ZIndex=61
        local nl=Instance.new("TextLabel",row); nl.Size=UDim2.new(1,-62,1,0); nl.Position=UDim2.new(0,40,0,0)
        nl.BackgroundTransparency=1; nl.Text=name; nl.TextColor3=T.txtMain
        nl.Font=Enum.Font.GothamBold; nl.TextSize=11; nl.TextXAlignment=Enum.TextXAlignment.Left; nl.ZIndex=61
        if isA then
            local ck=Instance.new("TextLabel",row); ck.Size=UDim2.new(0,18,1,0); ck.Position=UDim2.new(1,-22,0,0)
            ck.BackgroundTransparency=1; ck.Text="v"; ck.TextColor3=T.txtMain; ck.Font=Enum.Font.GothamBold; ck.TextSize=12; ck.ZIndex=61
        end
        local us=Instance.new("UIScale",row); us.Scale=1
        row.MouseEnter:Connect(function()
            Tw(row,{BackgroundTransparency=0.1},0.12)
            TweenService:Create(us,TweenInfo.new(0.12,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1.02}):Play()
        end)
        row.MouseLeave:Connect(function()
            if not isA then Tw(row,{BackgroundTransparency=0.3},0.12) end
            TweenService:Create(us,TweenInfo.new(0.1),{Scale=1}):Play()
        end)
        row.MouseButton1Click:Connect(function() CA(row); currentLang=code; task.delay(0.15,buildGUI) end)
    end
    langBtn("tr","TR","Turkce",34); langBtn("es","ES","Espanol",76); langBtn("ru","RU","Russki",118)

    -- ── Sidebar Menu Butonlari (emoji yok) ─────────────────
    local activeMenu=nil
    local menuStartY=lapelY+34
    local menuGap=40

    local function menuBtn(label,yPos,cb)
        local btn=Instance.new("TextButton",Sidebar)
        btn.Size=UDim2.new(1,-12,0,34); btn.Position=UDim2.new(0,6,0,yPos)
        btn.BackgroundColor3=T.item; btn.BackgroundTransparency=0.35
        btn.Text=""; btn.BorderSizePixel=0; btn.ZIndex=62; R(btn,9); S(btn,T.sep,1)
        local lbl=Instance.new("TextLabel",btn); lbl.Size=UDim2.new(1,-20,1,0); lbl.Position=UDim2.new(0,10,0,0)
        lbl.BackgroundTransparency=1; lbl.Text=label; lbl.TextColor3=T.txtSub
        lbl.Font=Enum.Font.GothamBold; lbl.TextSize=9
        lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.TextWrapped=true; lbl.ZIndex=63
        local arr=Instance.new("TextLabel",btn); arr.Size=UDim2.new(0,10,1,0); arr.Position=UDim2.new(1,-12,0,0)
        arr.BackgroundTransparency=1; arr.Text=">"; arr.TextColor3=T.txtDim
        arr.Font=Enum.Font.GothamBold; arr.TextSize=10; arr.ZIndex=63
        local us=Instance.new("UIScale",btn); us.Scale=1
        btn.MouseEnter:Connect(function()
            if activeMenu~=btn then Tw(btn,{BackgroundTransparency=0.1},0.12) end
            TweenService:Create(us,TweenInfo.new(0.12,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1.02}):Play()
            lbl.TextColor3=T.txtMain
        end)
        btn.MouseLeave:Connect(function()
            if activeMenu~=btn then Tw(btn,{BackgroundTransparency=0.35},0.12); lbl.TextColor3=T.txtSub end
            TweenService:Create(us,TweenInfo.new(0.1),{Scale=1}):Play()
        end)
        btn.MouseButton1Click:Connect(function()
            CA(btn)
            if activeMenu and activeMenu~=btn then
                Tw(activeMenu,{BackgroundTransparency=0.35},0.15)
                local ol=activeMenu:FindFirstChildOfClass("TextLabel"); if ol then ol.TextColor3=T.txtSub end
            end
            activeMenu=btn; Tw(btn,{BackgroundTransparency=0.1},0.15); lbl.TextColor3=T.txtMain
            if cb then task.delay(0.08,cb) end
        end)
        return btn
    end

    menuBtn(L("mm2"),    menuStartY,           function() showR("mm2") end)
    menuBtn(L("skin"),   menuStartY+menuGap,   function() showR("skin") end)
    menuBtn(L("themes"), menuStartY+menuGap*2, function() showR("themes") end)
    menuBtn(L("lang"),   menuStartY+menuGap*3, function() showR("language") end)

    showR("home")
    print("[LAPEL v10] Yuklendi. BG: "..BG_IMG)
end

local ok,err=pcall(buildGUI)
if not ok then
    warn("[LAPEL ERR] "..tostring(err))
    local sg=Instance.new("ScreenGui",GetUI()); sg.IgnoreGuiInset=true
    local lb=Instance.new("TextLabel",sg); lb.Size=UDim2.new(1,0,0,80); lb.Position=UDim2.new(0,0,0,100)
    lb.BackgroundTransparency=1; lb.Text="LAPEL ERR:\n"..tostring(err)
    lb.TextColor3=Color3.fromRGB(200,80,80); lb.Font=Enum.Font.GothamBold; lb.TextSize=11; lb.TextWrapped=true
end
