
  --get the addon namespace
  local addon, ns = ...

  --get oUF namespace (just in case needed)
  local oUF = ns.oUF or oUF

  --get the config
  local cfg = ns.cfg
  --get the database
  local db = ns.db

  --get the functions
  local func = ns.func

  --get the unit container
  local unit = ns.unit

  --get the bars container
  local bars = ns.bars

  local floor, abs, sin, pi = floor, math.abs, math.sin, math.pi

  ---------------------------------------------
  -- UNIT SPECIFIC FUNCTIONS
  ---------------------------------------------

  --init parameters
  local initUnitParameters = function(self)
    self:SetFrameStrata("BACKGROUND")
    self:SetFrameLevel(1)
    self:SetSize(self.cfg.size, self.cfg.size)
    self:SetScale(self.cfg.scale)
    self:SetPoint(self.cfg.pos.a1,self.cfg.pos.af,self.cfg.pos.a2,self.cfg.pos.x,self.cfg.pos.y)
    self:RegisterForClicks("AnyDown")
    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)
    func.applyDragFunctionality(self,"orb")
  end

  --actionbar background
  local createActionBarBackground = function(self)
    local cfg = self.cfg.art.actionbarbackground
    if not cfg.show then return end
    local f = CreateFrame("Frame","oUF_DiabloActionBarBackground",self)
    f:SetFrameStrata("BACKGROUND")
    f:SetFrameLevel(0)
    f:SetSize(512,256)
    f:SetPoint(cfg.pos.a1, cfg.pos.af, cfg.pos.a2, cfg.pos.x, cfg.pos.y)
    f:SetScale(cfg.scale)
    func.applyDragFunctionality(f)
    local t = f:CreateTexture(nil,"BACKGROUND",nil,-8)
    t:SetAllPoints(f)
    if cfg.style >= 1 and cfg.style <= 3 then
      t:SetTexture("Interface\\AddOns\\oUF_Diablo\\media\\bar"..cfg.style)
    else
      local setupBarTexture = function()
        if ((HasVehicleActionBar() and UnitVehicleSkin("player") and UnitVehicleSkin("player") ~= "")
        or (HasOverrideActionBar() and GetOverrideBarSkin() and GetOverrideBarSkin() ~= ""))
        or UnitHasVehicleUI("player") then
          t:SetTexture("Interface\\AddOns\\oUF_Diablo\\media\\bar1")
        elseif MultiBarBottomRight:IsShown() then
          t:SetTexture("Interface\\AddOns\\oUF_Diablo\\media\\bar3")
        elseif MultiBarBottomLeft:IsShown() then
          t:SetTexture("Interface\\AddOns\\oUF_Diablo\\media\\bar2")
        else
          t:SetTexture("Interface\\AddOns\\oUF_Diablo\\media\\bar1")
        end
      end
      setupBarTexture()
      MultiBarBottomRight:HookScript("OnShow", setupBarTexture)
      MultiBarBottomRight:HookScript("OnHide", setupBarTexture)
      MultiBarBottomLeft:HookScript("OnShow", setupBarTexture)
      MultiBarBottomLeft:HookScript("OnHide", setupBarTexture)
      f:RegisterEvent("UNIT_ENTERED_VEHICLE")
      f:RegisterEvent("UNIT_EXITED_VEHICLE")
      f:SetScript("OnEvent", function(...)
        local self, event, unit = ...
        if unit and unit ~= "player" then return end
        setupBarTexture()
      end)
    end
  end

  --create the angel
  local createAngelFrame = function(self)
    if not self.cfg.art.angel.show then return end
    local f = CreateFrame("Frame","oUF_DiabloAngelFrame",self)
    f:SetSize(320,160)
    f:SetFrameStrata("LOW")
    f:SetFrameLevel(0)
    f:SetPoint(self.cfg.art.angel.pos.a1, self.cfg.art.angel.pos.af, self.cfg.art.angel.pos.a2, self.cfg.art.angel.pos.x, self.cfg.art.angel.pos.y)
    f:SetScale(self.cfg.art.angel.scale)
    func.applyDragFunctionality(f)
    local t = f:CreateTexture(nil,"BACKGROUND",nil,2)
    t:SetAllPoints(f)
    t:SetTexture("Interface\\AddOns\\oUF_Diablo\\media\\d3_angel2")
  end

  --create the demon
  local createDemonFrame = function(self)
    if not self.cfg.art.demon.show then return end
    local f = CreateFrame("Frame","oUF_DiabloDemonFrame",self)
    f:SetSize(320,160)
    f:SetFrameStrata("LOW")
    f:SetFrameLevel(0)
    f:SetPoint(self.cfg.art.demon.pos.a1, self.cfg.art.demon.pos.af, self.cfg.art.demon.pos.a2, self.cfg.art.demon.pos.x, self.cfg.art.demon.pos.y)
    f:SetScale(self.cfg.art.demon.scale)
    func.applyDragFunctionality(f)
    local t = f:CreateTexture(nil,"BACKGROUND",nil,2)
    t:SetAllPoints(f)
    t:SetTexture("Interface\\AddOns\\oUF_Diablo\\media\\d3_demon2")
  end

  --create the bottomline
  local createBottomLine = function(self)
    local cfg = self.cfg.art.bottomline
    if not cfg.show then return end
    local f = CreateFrame("Frame","oUF_DiabloBottomLine",self)
    f:SetFrameStrata("MEDIUM")
    f:SetFrameLevel(0)
    f:SetSize(500,112)
    f:SetPoint(cfg.pos.a1, cfg.pos.af, cfg.pos.a2, cfg.pos.x, cfg.pos.y)
    f:SetScale(cfg.scale)
    func.applyDragFunctionality(f,"bottomline")
    local t = f:CreateTexture(nil,"BACKGROUND",nil,3)
    t:SetAllPoints(f)
    t:SetTexture("Interface\\AddOns\\oUF_Diablo\\media\\d3_bottom")
  end

  --post update orb func (used to display lowHp on percentage)
  local updateValue = function(bar, unit, cur, max)
    local per = 0
    if max > 0 then per = floor(cur/max*100) end
    local orb = bar:GetParent()
    local self = orb:GetParent()
    --if orb.type == "HEALTH" and  (per <= 25 and not UnitIsDeadOrGhost(unit)) then
    if orb.type == "HEALTH" and  (per <= 25 or UnitIsDeadOrGhost(unit)) then
      orb.lowHP:Show()
    elseif orb.type == "HEALTH" then
      orb.lowHP:Hide()
    end
    if orb.type == "HEALTH" and UnitIsDeadOrGhost(unit) then
      orb.skull:Show()
    elseif orb.type == "HEALTH" then
      orb.skull:Hide()
    end
    if db.char[orb.type].value.hideOnEmpty and (UnitIsDeadOrGhost(unit) or cur < 1) then
      orb.values:Hide()
    elseif db.char[orb.type].value.hideOnFull and (cur == max) then
      orb.values:Hide()
    elseif not orb.values:IsShown() then
      orb.values:Show()
    end
    if orb.type == "HEALTH" then
      orb.values.top:SetText(oUF.Tags.Methods["diablo:HealthOrbTop"](self.unit or "player"))
      orb.values.bottom:SetText(oUF.Tags.Methods["diablo:HealthOrbBottom"](self.unit or "player"))
    elseif orb.type == "POWER" then
      orb.values.top:SetText(oUF.Tags.Methods["diablo:PowerOrbTop"](self.unit or "player"))
      orb.values.bottom:SetText(oUF.Tags.Methods["diablo:PowerOrbBottom"](self.unit or "player"))
    end
    if UnitIsDeadOrGhost(unit) then
      bar:SetValue(0)
    end
    if ns.panel:IsShown() then
      ns.panel.eventHelper:SetOrbsToMax()
    end
  end

  --update spark func
  local updateStatusBarColor = function(bar, r, g, b)
    local orb = bar:GetParent()
    orb.spark:SetVertexColor(r,g,b)
  end

  --update orb func
  local updateOrb = function(bar,value)
    local orb = bar:GetParent()
    local min, max = bar:GetMinMaxValues()
    local per = 0
    if max > 0 then per = value/max*100 end
    local offset = orb.size-per*orb.size/100
    orb.scrollFrame:SetPoint("TOP",0,-offset)
    orb.scrollFrame:SetVerticalScroll(offset)
    --adjust the orb spark in width/height matching the current scrollframe state
    if not orb.spark then return end
    local multiplier = floor(sin(per/100*pi)*1000)/1000
    if multiplier <= 0.25 then
      orb.spark:Hide()
    else
      orb.spark:SetWidth(256*orb.size/256*multiplier)
      orb.spark:SetHeight(32*orb.size/256*multiplier)
      orb.spark:SetPoint("TOP", orb.scrollFrame, 0, 16*orb.size/256*multiplier)
      orb.spark:Show()
    end
  end

  --create orb func
  local createOrb = function(self,type)
    --get the orb config
    local orbcfg = db.char[type]
    local name
    if type == "HEALTH" then
      name = "oUF_DiabloHealthOrb"
    else
      name = "oUF_DiabloPowerOrb"
    end
    --create the orb baseframe
    local orb = CreateFrame("Frame", name, self)
    --orb data
    orb.self = self
    orb.type = type
    orb.size = self.cfg.size
    orb:SetSize(orb.size,orb.size)
    --position the orb
    if orb.type == "POWER" then
      --reset the power to be on the opposite side of the health orb
      orb:SetPoint(self.cfg.pos.a1,self.cfg.pos.af,self.cfg.pos.a2,self.cfg.pos.x*(-1),self.cfg.pos.y)
      --make the power orb dragable
      func.applyDragFunctionality(orb,"orb")
    else
      --position the health orb ontop of the self object
      orb:SetPoint("CENTER")
    end

    if orb.type == "HEALTH" then
      --debuff glow
      local glow = orb:CreateTexture("$parentGlow", "BACKGROUND", nil, -7)
      glow:SetPoint("CENTER",0,0)
      glow:SetSize(self.cfg.size+5,self.cfg.size+5)
      glow:SetBlendMode("BLEND")
      glow:SetVertexColor(0, 1, 1, 0) -- set alpha to 0 to hide the texture
      glow:SetTexture("Interface\\AddOns\\oUF_Diablo\\media\\orb_debuff_glow")
      orb.glow = glow
      self.DebuffHighlight = orb.glow
      self.DebuffHighlightAlpha = 1
      self.DebuffHighlightFilter = false
    end

    --background
    local bg = orb:CreateTexture("$parentBG","BACKGROUND",nil,-6)
    bg:SetAllPoints()
    bg:SetTexture("Interface\\AddOns\\oUF_Diablo\\media\\orb_back2")
    orb.bg = bg

    --filling statusbar
    local fill = CreateFrame("StatusBar","$parentFill",orb)
    fill:SetAllPoints()
    fill:SetMinMaxValues(0, 100)
    fill:SetStatusBarTexture(orbcfg.filling.texture)
    fill:SetStatusBarColor(orbcfg.filling.color.r,orbcfg.filling.color.g,orbcfg.filling.color.b)
    fill:SetOrientation("VERTICAL")
    fill:SetScript("OnValueChanged", updateOrb)
    orb.fill = fill

    --scrollframe
    local scrollFrame = CreateFrame("ScrollFrame","$parentScrollFrame",orb)
    scrollFrame:SetSize(orb:GetSize())
    scrollFrame:SetPoint("TOP")
    --scrollchild
    local scrollChild = CreateFrame("Frame","$parentScrollChild",scrollFrame)
    scrollChild:SetSize(orb:GetSize())
    scrollFrame:SetScrollChild(scrollChild)
    orb.scrollFrame = scrollFrame

    --orb model
    local model = CreateFrame("PlayerModel","$parentModel",scrollChild)
    model:SetSize(orb:GetSize())
    model:SetPoint("TOP")
    --model:SetBackdrop(cfg.backdrop)
    model:SetAlpha(orbcfg.model.alpha or 1)

    --update model func
    function model:Update()
      local cfg = db.char[self.type].model
      self:SetCamDistanceScale(cfg.camDistanceScale)
      self:SetPosition(0,cfg.pos_x,cfg.pos_y)
      self:SetRotation(cfg.rotation)
      self:SetPortraitZoom(cfg.portraitZoom)
      self:ClearModel()
      --self:SetModel("interface\\buttons\\talktomequestionmark.m2") --in case setdisplayinfo fails
      self:SetDisplayInfo(cfg.displayInfo)
    end
    model.type = orb.type
    model:SetScript("OnEvent", function(self) self:Update() end)
    model:RegisterEvent("PLAYER_ENTERING_WORLD")
    model:SetScript("OnShow", function(self) self:Update() end)
    model:Update()
    orb.model = model

    --overlay frame
    local overlay = CreateFrame("Frame","$parentOverlay",scrollFrame)
    --overlay:SetFrameLevel(model:GetFrameLevel()+1)
    overlay:SetAllPoints(orb)
    orb.overlay = orb

    --spark frame
    local spark = overlay:CreateTexture(nil,"BACKGROUND",nil,-3)
    spark:SetTexture("Interface\\AddOns\\oUF_Diablo\\media\\orb_spark")
    --the spark should fit the filling color otherwise it will stand out too much
    spark:SetVertexColor(orbcfg.filling.color.r,orbcfg.filling.color.g,orbcfg.filling.color.b)
    spark:SetWidth(256*orb.size/256)
    spark:SetHeight(32*orb.size/256)
    spark:SetPoint("TOP", scrollFrame, 0, -16*orb.size/256)
    --texture will be blended by blendmode, http://wowprogramming.com/docs/widgets/Texture/SetBlendMode
    spark:SetAlpha(orbcfg.spark.alpha or 1)
    spark:SetBlendMode("ADD")
    spark:Hide()
    orb.spark = spark

    --skull+lowhp
    if orb.type == "HEALTH" then

      local skull = overlay:CreateTexture(nil, "BACKGROUND", nil, 1)
      skull:SetPoint("CENTER",0,0)
      skull:SetSize(self.cfg.size-40,self.cfg.size-40)
      skull:SetTexture("Interface\\AddOns\\oUF_Diablo\\media\\d2_skull")
      --skull:SetBlendMode("ADD")
      skull:SetAlpha(0.6)
      skull:Hide()
      orb.skull = skull

      local lowHP = overlay:CreateTexture(nil, "BACKGROUND", nil, 2)
      lowHP:SetPoint("CENTER",0,0)
      lowHP:SetSize(self.cfg.size-15,self.cfg.size-15)
      lowHP:SetTexture("Interface\\AddOns\\oUF_Diablo\\media\\orb_lowhp_glow")
      lowHP:SetBlendMode("ADD")
      lowHP:SetVertexColor(1, 0, 0, 1)
      lowHP:Hide()
      orb.lowHP = lowHP
    end

    --highlight
    local highlight = overlay:CreateTexture("$parentHighlight","BACKGROUND",nil,3)
    highlight:SetAllPoints()
    highlight:SetTexture("Interface\\AddOns\\oUF_Diablo\\media\\orb_gloss")
    highlight:SetAlpha(orbcfg.highlight.alpha or 1)
    orb.highlight = highlight

    --orb values
    local values = CreateFrame("Frame","$parentValues",overlay)
    values:SetAllPoints(orb)
    --top value
    values.top = func.createFontString(values, cfg.font, 28, "THINOUTLINE")
    values.top:SetPoint("CENTER", 0, 10)
    values.top:SetTextColor(orbcfg.value.top.color.r,orbcfg.value.top.color.g,orbcfg.value.top.color.b)
    --bottom value
    values.bottom = func.createFontString(values, cfg.font, 16, "THINOUTLINE")
    values.bottom:SetPoint("CENTER", 0, -10)
    values.bottom:SetTextColor(orbcfg.value.top.color.r,orbcfg.value.top.color.g,orbcfg.value.top.color.b)
    orb.values = values

    --register the tags
    if orb.type == "HEALTH" then
      self:Tag(orb.values.top, "[diablo:HealthOrbTop]")
      self:Tag(orb.values.bottom, "[diablo:HealthOrbBottom]")
    else
      self:Tag(orb.values.top, "[diablo:PowerOrbTop]")
      self:Tag(orb.values.bottom, "[diablo:PowerOrbBottom]")
    end

    if orb.type == "POWER" then
      self.Power = orb.fill
      ns.PowerOrb = orb --save the orb in the namespace
      hooksecurefunc(self.Power, "SetStatusBarColor", updateStatusBarColor)
      self.Power.frequentUpdates = self.cfg.power.frequentUpdates or false
      self.Power.Smooth = self.cfg.power.smooth or false
      self.Power.colorPower = orbcfg.filling.colorAuto or false
      self.Power.PostUpdate = updateValue
    else
      self.Health = orb.fill
      ns.HealthOrb = orb --save the orb in the namespace
      hooksecurefunc(self.Health, "SetStatusBarColor", updateStatusBarColor)
      self.Health.frequentUpdates = self.cfg.health.frequentUpdates or false
      self.Health.Smooth = self.cfg.health.smooth or false
      self.Health.colorClass = orbcfg.filling.colorAuto or false
      self.Health.colorHealth = orbcfg.filling.colorAuto or false --when player switches into a vehicle it will recolor the orb
      --we need to display the lowhp on a certain threshold without smoothing, so we use the postUpdate for that
      self.Health.PostUpdate = updateValue
    end
    --print(addon..": orb created "..orb.type)
  end

  ---------------------------------------------
  -- PLAYER STYLE FUNC
  ---------------------------------------------

  local createStyle = function(self)

    --apply config to self
    self.cfg = cfg.units.player
    self.cfg.style = "player"

    --init
    initUnitParameters(self)

    --create the actionbarbackground
    createActionBarBackground(self)

    --create the health orb
    createOrb(self,"HEALTH")
    --create the power orb
    createOrb(self,"POWER")

    --create art textures do this now for correct frame stacking
    createAngelFrame(self)
    createDemonFrame(self)

    --experience bar
    bars.createExpBar(self)

    --reputation bar
    bars.createRepBar(self)

    --bottomline
    createBottomLine(self)

    --icons
    if self.cfg.icons.resting.show then
      local pos = self.cfg.icons.resting.pos
      self.Resting = func.createIcon(self,"BACKGROUND",32,self,pos.a1,pos.a2,pos.x,pos.y,-1)
    end
    if self.cfg.icons.pvp.show then
      local pos = self.cfg.icons.pvp.pos
      self.PvP = func.createIcon(self,"BACKGROUND",44,self,pos.a1,pos.a2,pos.x,pos.y,-1)
    end
    if self.cfg.icons.combat.show then
      local pos = self.cfg.icons.combat.pos
      self.Combat = func.createIcon(self,"BACKGROUND",32,self,pos.a1,pos.a2,pos.x,pos.y,-1)
    end

    --castbar
    if self.cfg.castbar.show then
      --load castingbar
      func.createCastbar(self)
    elseif self.cfg.castbar.hideDefault then
      CastingBarFrame:UnregisterAllEvents()
      CastingBarFrame.Show = CastingBarFrame.Hide
      CastingBarFrame:Hide()
    end

    --warlock bars
    if cfg.playerclass == "WARLOCK" and self.cfg.demonicfury.show then
      bars.createDemonicFuryPowerBar(self)
    end
    if cfg.playerclass == "WARLOCK" and self.cfg.soulshards.show then
      bars.createSoulShardPowerBar(self)
    end
    if cfg.playerclass == "WARLOCK" and self.cfg.burningembers.show then
      bars.createBurningEmberPowerBar(self)
    end

    --holypower
    if cfg.playerclass == "PALADIN" and self.cfg.holypower.show then
      bars.createHolyPowerBar(self)
    end

    --harmony
    if cfg.playerclass == "MONK" and self.cfg.harmony.show then
      bars.createHarmonyPowerBar(self)
    end

    --shadoworbs
    if cfg.playerclass == "PRIEST" and self.cfg.shadoworbs.show then
      bars.createShadowOrbPowerBar(self)
    end

    --eclipsebar
    if cfg.playerclass == "DRUID" and self.cfg.eclipse.show then
      bars.createEclipseBar(self)
    end

    --runes
    if cfg.playerclass == "DEATHKNIGHT" and self.cfg.runes.show then
      --position deathknight runes
      bars.createRuneBar(self)
    end

    --create portrait
    if self.cfg.portrait.show then
      func.createStandAlonePortrait(self)
    end

    --make alternative power bar movable
    if self.cfg.altpower.show then
      func.createAltPowerBar(self,"oUF_AltPowerPlayer")
    end

    --add self to unit container (maybe access to that unit is needed in another style)
    unit.player = self

  end

  ---------------------------------------------
  -- SPAWN PLAYER UNIT
  ---------------------------------------------
  if cfg.units.player.show then
    oUF:RegisterStyle("diablo:player", createStyle)
    oUF:SetActiveStyle("diablo:player")
    oUF:Spawn("player", "oUF_DiabloPlayerFrame")
  end