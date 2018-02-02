IncludeFile("Lib\\TOIR_SDK.lua")

Draven = class()

function OnLoad()
	if GetChampName(GetMyChamp()) == "Draven" then
		Draven:__init()
	end
end

function Draven:__init()
	-- VPrediction
	vpred = VPrediction(true)
	AntiGap = AntiGapcloser(nil)
	--TS
    --self.menu_ts = TargetSelector(1750, 0, myHero, true, true, true)


    self.Q = Spell(_Q, GetTrueAttackRange())
    self.W = Spell(_W, GetTrueAttackRange())
    self.E = Spell(_E, 1200)
    self.R = Spell(_R, 3000)

    self.Q:SetSkillShot()
    self.W:SetSkillShot()
    self.E:SetSkillShot(0.25, 1400, 100, true)
    self.R:SetSkillShot(0.4, 2000, 160, true)

    self.QReticles = {}

    self.listSpellInterrup =
	{
		["KatarinaR"] = true,
		["AlZaharNetherGrasp"] = true,
		["TwistedFateR"] = true,
		["VelkozR"] = true,
		["InfiniteDuress"] = true,
		["JhinR"] = true,
		["CaitlynAceintheHole"] = true,
		["UrgotSwap2"] = true,
		["LucianR"] = true,
		["GalioIdolOfDurand"] = true,
		["MissFortuneBulletTime"] = true,
		["XerathLocusPulse"] = true,
	}

	Callback.Add("Tick", function(...) self:OnTick(...) end)
	Callback.Add("AntiGapClose", function(target, EndPos) self:OnAntiGapClose(target, EndPos) end)
	Callback.Add("Update", function(...) self:OnUpdate(...) end)	
    Callback.Add("Draw", function(...) self:OnDraw(...) end)
    Callback.Add("ProcessSpell", function(...) self:OnProcessSpell(...) end)
    Callback.Add("BeforeAttack", function(...) self:OnBeforeAttack(...) end)
    Callback.Add("NewPath", function(...) self:OnNewPath(...) end)
    Callback.Add("CreateObject", function(...) self:OnCreateObject(...) end)
    Callback.Add("DeleteObject", function(...) self:OnDeleteObject(...) end)
    Callback.Add("DrawMenu", function(...) self:OnDrawMenu(...) end)
    --Callback.Add("UpdateBuff", function(unit, buff, stacks) self:OnUpdateBuff(source, unit, buff, stacks) end)
    --Callback.Add("AfterAttack", function(...) self:OnAfterAttack(...) end)
    self:MenuValueDefault()
end

function Draven:MenuValueDefault()
	self.menu = "Draven_Magic"
	self.Draw_When_Already = self:MenuBool("Draw When Already", true)
	self.DrawAxeLocation = self:MenuBool("Draw Axe Location", true)
	self.DrawAxeRange = self:MenuBool("Draw Axe Catch Range", true)
	self.menu_Draw_E = self:MenuBool("Draw E Range", true)


	self.UseQCombo = self:MenuBool("Use Q", true)
	self.UseWCombo = self:MenuBool("Use W", true)
	self.UseECombo = self:MenuBool("Use E", false)
	self.UseRCombo = self:MenuBool("Use R", true)

	--self.UseEHarass = self:MenuBool("Use E", true)

	self.UseQWaveClear = self:MenuBool("Use Q", true)
	--self.UseWWaveClear = self:MenuBool("Use W", true)
	--self.UseEWaveClear = self:MenuBool("Use E", true)
	self.WaveClearManaPercent = self:MenuSliderInt("Mana Percent", 50)

	self.AxeMode = self:MenuComboBox("Catch Axe on Mode:", 2)
	self.CatchAxeRange = self:MenuSliderInt("Catch Axe Range", 800)
	self.MaxAxes = self:MenuSliderInt("Maximum Axes", 2)
	self.UseWForQ = self:MenuBool("Use W if Axe too far", true)
	self.DontCatchUnderTurret = self:MenuBool("Don't Catch Axe Under Turret", true)

	self.UseWSetting = self:MenuBool("Use W Instantly(When Available)", false)
	self.UseEGapcloser = self:MenuBool("Use E on Gapcloser", true)
	self.UseEInterrupt = self:MenuBool("Use E to Interrupt", true)
	self.UseWManaPercent = self:MenuSliderInt("Use W Mana Percent", 50)
	self.UseWSlow = self:MenuBool("Use W if Slowed", true)

	self.Enalble_Mod_Skin = self:MenuBool("Enalble Mod Skin", false)
	self.Set_Skin = self:MenuSliderInt("Set Skin", 1)

	self.Combo = self:MenuKeyBinding("Combo", 32)
	self.Harass = self:MenuKeyBinding("Harass", 67)
	self.Lane_Clear = self:MenuKeyBinding("Lane Clear", 86)
	self.Last_Hit = self:MenuKeyBinding("Last Hit", 88)
end

function Draven:OnDrawMenu()
	if Menu_Begin(self.menu) then
		if Menu_Begin("Combo Setting") then
			self.UseQCombo = Menu_Bool("Use Q", self.UseQCombo, self.menu)	
			self.UseWCombo = Menu_Bool("Use W", self.UseWCombo, self.menu)
			self.UseECombo = Menu_Bool("Use E", self.UseECombo, self.menu)
			self.UseRCombo = Menu_Bool("Use R", self.UseRCombo, self.menu)		
			Menu_End()
		end

		--if Menu_Begin("Harass Setting") then
			--self.UseEHarass = Menu_Bool("Use E", self.UseEHarass, self.menu)
			--Menu_End()
		--end

		if Menu_Begin("LaneClear Setting") then
			self.UseQWaveClear = Menu_Bool("Use Q", self.UseQWaveClear, self.menu)	
			--self.UseWWaveClear = Menu_Bool("Use W", self.UseWWaveClear, self.menu)
			--self.UseEWaveClear = Menu_Bool("Use E", self.UseEWaveClear, self.menu)
			self.WaveClearManaPercent = Menu_SliderInt("Mana Percent", self.WaveClearManaPercent, 0, 100, self.menu)
			Menu_End()
		end

		if Menu_Begin("Axe Setting") then
			self.AxeMode = Menu_ComboBox("Catch Axe on Mode:", self.AxeMode, "Combo\0Any\0Always\0\0", self.menu)	
			self.CatchAxeRange = Menu_SliderInt("Catch Axe Range", self.CatchAxeRange, 120, 1500, self.menu)
			self.MaxAxes = Menu_SliderInt("Maximum Axes", self.MaxAxes, 1, 3, self.menu)
			self.UseWForQ = Menu_Bool("Use W if Axe too far", self.UseWForQ, self.menu)
			self.DontCatchUnderTurret = Menu_Bool("Don't Catch Axe Under Turret", self.DontCatchUnderTurret, self.menu)
			Menu_End()
		end

		if Menu_Begin("Misc Setting") then
			self.UseWSetting = Menu_Bool("Use W Instantly(When Available)", self.UseWSetting, self.menu)	
			self.UseEGapcloser = Menu_Bool("Use E on Gapcloser", self.UseEGapcloser, self.menu)
			self.UseEInterrupt = Menu_Bool("Use E to Interrupt", self.UseEInterrupt, self.menu)
			self.UseWManaPercent = Menu_SliderInt("Use W Mana Percent", self.UseWManaPercent, 0, 100, self.menu)
			self.UseWSlow = Menu_Bool("Use W if Slowed", self.UseWSlow, self.menu)
			Menu_End()
		end

		if Menu_Begin("Draw Spell") then
			self.DrawAxeLocation = Menu_Bool("Draw Axe Location", self.DrawAxeLocation, self.menu)
			self.DrawAxeRange = Menu_Bool("Draw Axe Catch Range", self.DrawAxeRange, self.menu)
			self.menu_Draw_E = Menu_Bool("Draw E Range", self.menu_Draw_E, self.menu)
			Menu_End()
		end
		if Menu_Begin("Mod Skin") then
			self.Enalble_Mod_Skin = Menu_Bool("Enalble Mod Skin", self.Enalble_Mod_Skin, self.menu)
			self.Set_Skin = Menu_SliderInt("Set Skin", self.Set_Skin, 0, 20, self.menu)
			Menu_End()
		end
		if Menu_Begin("Key Mode") then
			self.Combo = Menu_KeyBinding("Combo", self.Combo, self.menu)
			self.Harass = Menu_KeyBinding("Harass", self.Harass, self.menu)
			self.Lane_Clear = Menu_KeyBinding("Lane Clear", self.Lane_Clear, self.menu)
			self.Last_Hit = Menu_KeyBinding("Last Hit", self.Last_Hit, self.menu)
			Menu_End()
		end
		
		Menu_End()
	end
end

function Draven:MenuBool(stringKey, bool)
	return ReadIniBoolean(self.menu, stringKey, bool)
end

function Draven:MenuSliderInt(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Draven:MenuSliderFloat(stringKey, valueDefault)
	return ReadIniFloat(self.menu, stringKey, valueDefault)
end

function Draven:MenuComboBox(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Draven:MenuKeyBinding(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Draven:OnBeforeAttack(target)
	if CanCast(_Q) then
		if target.Type == 0 then
			if self.UseQCombo and self:QCount() < self.MaxAxes and GetDistance(target.Addr) < GetTrueAttackRange() then
				CastSpellTarget(myHero.Addr, _Q)
			end
		end
		if target.Type == 1 or target.Type == 3 then
			if self.UseQWaveClear and self:QCount() < self.MaxAxes and GetDistance(target.Addr) < GetTrueAttackRange() and self.WaveClearManaPercent < (myHero.MP / myHero.MaxMP) * 100 then
				CastSpellTarget(myHero.Addr, _Q)
			end
		end		
	end
end

function Draven:OnCreateObject(obj)
	if string.find(obj.Name, "Q_") then
		--__PrintTextGame(tostring(obj.Name))
	end

	if string.find(obj.Name, "Q_reticle") then --Draven_Base_Q_reticle [11240] Draven_Skin03_Q_reticle_self [11240] Draven_Skin03_Q_reticle
		table.insert(self.QReticles, {object = obj, pos = Vector(obj), expireTime = GetTimeGame() + 1.5, networkid = obj.NetworkId})	
	    --table.sort(self.QReticles, function(a, b)
            --return (GetDistance(a.pos, myHero) < GetDistance(b.pos, myHero) and GetDistance(a.pos, GetMousePos()) < GetDistance(b.pos, GetMousePos()) and a.expireTime < b.expireTime)
        --end)
	end
end

function Draven:OnDeleteObject(obj)	
	if string.find(obj.Name, "Q_reticle_self") then --Draven_Base_Q_reticle [11240] Draven_Skin03_Q_reticle_self [11240] Draven_Skin03_Q_reticle
		for i = #self.QReticles, 1, -1 do
			--if obj.networkid == self.QReticles[i].NetworkId then-- or self.QReticles[i].expireTime < GetTimeGame() then
	      		table.remove(self.QReticles, i)
	      	--end
    	end
	end
end

function Draven:QCount()
	local counting = 0
	local countleft = 0
	if myHero.HasBuff("DravenSpinning") then
		counting = 1
	else
		counting = 0
	end
	if myHero.HasBuff("dravenspinningleft") then
		countleft = 1
	else
		countleft = 0
	end
	--return counting + countleft

	local stack = GetBuff(GetBuffByName(myHero.Addr, "DravenSpinningAttack"))
	return stack.Stacks
end

function Draven:CatchAxe()
	if (self.AxeMode == 0 and GetKeyPress(self.Combo) > 0) or ((self.AxeMode == 1 or self.AxeMode == 2) and (GetKeyPress(self.Combo) > 0 or GetKeyPress(self.Harass) > 0 or GetKeyPress(self.Lane_Clear) > 0 or GetKeyPress(self.Last_Hit) > 0)) then
		for i = #self.QReticles, 1, -1 do
			local bestReticle = nil
			local ReticlePos = Vector(0, 0, 0)
			--__PrintTextGame(tostring(GetDistance(self.QReticles[i].pos, GetMousePos())))
			if GetDistance(self.QReticles[i].pos, GetMousePos()) < self.CatchAxeRange then 
				bestReticle = self.QReticles[i].object
			else
				bestReticle = nil
	      	end

	      	if bestReticle ~= nil and GetDistance(Vector(bestReticle)) > 100 then
	      		ReticlePos = Vector(bestReticle)
	      		local eta = GetDistance(Vector(bestReticle)) / myHero.MoveSpeed
	      		local expireTime = self.QReticles[i].expireTime - GetTimeGame()
	      		if eta >= expireTime and self.UseWForQ then
	      			CastSpellTarget(myHero.Addr, _W)
	      		end
	      		 
	      		if self.DontCatchUnderTurret then
	      			if self:IsUnderTurretEnemy(Vector(myHero)) and self:IsUnderTurretEnemy(Vector(bestReticle)) then
	      				SetOrbwalkingPoint(bestReticle.x, bestReticle.z)
	      			elseif not self:IsUnderTurretEnemy(Vector(bestReticle)) then
	      				SetOrbwalkingPoint(bestReticle.x, bestReticle.z)
	      			end
	      		else
	      			SetOrbwalkingPoint(bestReticle.x, bestReticle.z)
	      		end
	      	else
	      		SetOrbwalkingPoint(0, 0, 0)
	      	end
	    end
	    SetOrbwalkingPoint(0, 0, 0)
	end

	if (GetKeyPress(self.Combo) == 0 or GetKeyPress(self.Harass) == 0 or GetKeyPress(self.Lane_Clear) == 0 or GetKeyPress(self.Last_Hit) == 0) and self.AxeMode == 2 then
		for i = #self.QReticles, 1, -1 do
			local bestReticle = nil
			local ReticlePos = Vector(0, 0, 0)
			--__PrintTextGame(tostring(GetDistance(self.QReticles[i].pos, GetMousePos())))
			if GetDistance(self.QReticles[i].pos, GetMousePos()) < self.CatchAxeRange then 
				bestReticle = self.QReticles[i].object
			else
				bestReticle = nil
	      	end

	      	if bestReticle ~= nil and GetDistance(Vector(bestReticle)) > 100 then
	      		ReticlePos = Vector(bestReticle)
	      		local eta = GetDistance(Vector(bestReticle)) / myHero.MoveSpeed
	      		local expireTime = self.QReticles[i].expireTime - GetTimeGame()
	      		if eta >= expireTime and self.UseWForQ then
	      			CastSpellTarget(myHero.Addr, _W)
	      		end
	      		 
	      		if self.DontCatchUnderTurret then
	      			if self:IsUnderTurretEnemy(Vector(myHero)) and self:IsUnderTurretEnemy(Vector(bestReticle)) then
	      				MoveToPos(bestReticle.x, bestReticle.z)
	      			elseif not self:IsUnderTurretEnemy(Vector(bestReticle)) then
	      				MoveToPos(bestReticle.x, bestReticle.z)
	      			end
	      		else
	      			MoveToPos(bestReticle.x, bestReticle.z)
	      		end
	      	else
	      		--ReticlePos = Vector(0, 0, 0)
	      		SetOrbwalkingPoint(0, 0, 0)
	      	end
	    end
	    SetOrbwalkingPoint(0, 0, 0)
	end
end

function Draven:OnNewPath(unit, startPos, endPos, isDash, dashSpeed ,dashGravity, dashDistance)
	if unit.IsMe then
		self:CatchAxe()
	end
end

function Draven:OnAntiGapClose(target, EndPos)
	hero = GetAIHero(target.Addr)
    if GetDistance(EndPos) < 500 or GetDistance(hero) < 500 then
    	if self.UseEGapcloser and CanCast(_E) then
    		CastSpellToPos(EndPos.x, EndPos.z, _E)
    	end
    end
end

function Draven:OnTick()
	if (IsDead(myHero.Addr) or myHero.IsRecall or IsTyping() or IsDodging()) then return end
	SetLuaCombo(true)
	
	--[[local target, enpos = AntiGap:AntiGapInfo()
    if target ~= nil and enpos ~= nil then
    	if self.UseEGapcloser and CanCast(_E) then
    		CastSpellToPos(enpos.x, enpos.z, _E)
    		self:AntiGapCloser()
    	end
    end]]

    self:CatchAxe()

	if CanCast(_W) then
		self:LogicW()
	end	

	if CanCast(_E) and self.UseECombo then
		self:LogicE()
	end

	if CanCast(_R) and self.UseECombo then
		self:LogicR()
	end

	if self.Enalble_Mod_Skin then
		ModSkin(self.Set_Skin)
	end		
end

function Draven:LogicW()
	if self.UseWCombo and GetKeyPress(self.Combo) > 0 and myHero.MP > 250 and CountEnemyChampAroundObject(myHero.Addr, 1000) > 0 and not myHero.HasBuff("dravenfurybuff") then
		CastSpellTarget(myHero.Addr, _W)
	else
		if GetBuffByName(myHero.Addr, "slow") ~= 0 and self.UseWSlow then
			CastSpellTarget(myHero.Addr, _W)
		end
	end
end

function Draven:LogicE()
	for i,hero in pairs(GetEnemyHeroes()) do
		if hero ~= nil then
			target = GetAIHero(hero)
			local CastPosition, HitChance, Position = vpred:GetLineCastPosition(target, self.E.delay, self.E.width, self.E.range, self.E.speed, myHero, false)
			if IsValidTarget(target.Addr, self.E.range) and GetDistance(Vector(target)) > GetTrueAttackRange() and GetDamage("E", target) > target.HP then				
				if HitChance >= 2 then
					CastSpellToPos(CastPosition.x, CastPosition.z, _E)
				end
			end
			if IsValidTarget(target.Addr, 300) and target.IsMelee then
				if HitChance >= 2 then
					CastSpellToPos(CastPosition.x, CastPosition.z, _E)
				end
			end
		end
	end
	local TargetE = GetTargetSelector(self.E.range - 150, 1)
	if TargetE ~= 0 then
		target = GetAIHero(TargetE)
		local CastPosition, HitChance, Position = vpred:GetLineCastPosition(target, self.E.delay, self.E.width, self.E.range, self.E.speed, myHero, false)
		if IsValidTarget(target.Addr, self.E.range) then
			if GetKeyPress(self.Combo) > 0 then
				if myHero.MP > 170 then
					if GetDistance(Vector(target)) > GetTrueAttackRange() then
						if HitChance >= 2 then
							CastSpellToPos(CastPosition.x, CastPosition.z, _E)
						end
					end
					if myHero.HP < myHero.MaxHP * 0.5 then
						if HitChance >= 2 then
							CastSpellToPos(CastPosition.x, CastPosition.z, _E)
						end
					end
				end
			end
		end
	end
end

function Draven:OnUpdate()
	--if string.find(obj.Name, "Q_reticle_self") then --Draven_Base_Q_reticle [11240] Draven_Skin03_Q_reticle_self [11240] Draven_Skin03_Q_reticle
		for i = #self.QReticles, 1, -1 do
			if self.QReticles[i].object.IsDead then
	      		table.remove(self.QReticles, i)
	      	end
    	end
	--end
    --self:CatchAxe()
end

function Draven:LogicR()
	for i,hero in pairs(GetEnemyHeroes()) do
		if IsValidTarget(hero, 2000 - 150) then
			target = GetAIHero(hero)
			local CastPosition, HitChance, Position = vpred:GetLineCastPosition(target, self.R.delay, self.R.width, self.R.range, self.R.speed, myHero, false)
			if self.UseRCombo and CanCast(_R) then
				local rDmg = GetDamage("R", target)
				if rDmg * 2 > target.HP and (GetDistance(target.Addr) > GetTrueAttackRange() or CountEnemyChampAroundObject(target.Addr, self.E.range) > 2) and HitChance >= 2 then
					CastSpellToPos(CastPosition.x, CastPosition.z, _R)
				end
			end
		end
	end		
end


function Draven:CanMoveOrb(extraWindup)
    return GetTimeGame() + self:GamePing() > GetLastBATick() + GetWindupBA(myHero.Addr) + extraWindup --self.menu_advanced_delayWindup.getValue() /1000
end

function Draven:CanHarras()
	local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
	if not self:IsUnderTurretEnemy(myHeroPos) and self:CanMoveOrb(50) then
		return true
	end
	return false
end

function Draven:ValidUlt(unit)
	if CountBuffByType(unit, 16) == 1 or CountBuffByType(unit, 15) == 1 or CountBuffByType(unit, 17) == 1 or unit.HasBuff("kindredrnodeathbuff") or CountBuffByType(unit, 4) == 1 then
		return false
	end
	return true
end


function Draven:OnDraw()
	if self.menu_Draw_E then
		DrawCircleGame(myHero.x , myHero.y, myHero.z, self.E.range, Lua_ARGB(255,0,255,0))
	end

	for i = #self.QReticles, 1, -1 do
		if self.DrawAxeLocation then
			--table.sort(self.QReticles, function(a, b)
            	--return (GetDistance(a.pos, myHero) < GetDistance(b.pos, myHero) and GetDistance(a.pos, GetMousePos()) < GetDistance(b.pos, GetMousePos()))
        	--end)
			if GetDistance(self.QReticles[i].pos, GetMousePos()) < self.CatchAxeRange then 
      			DrawCircleGame(self.QReticles[i].pos.x , self.QReticles[i].pos.y, self.QReticles[i].pos.z, 150, Lua_ARGB(255,0,255,0))
      		else
      			DrawCircleGame(self.QReticles[i].pos.x , self.QReticles[i].pos.y, self.QReticles[i].pos.z, 150, Lua_ARGB(255,0,255,255))
      		end
      	end
    end

    if self.DrawAxeRange then
    	DrawCircleGame(GetMousePos().x , GetMousePos().y, GetMousePos().z, self.CatchAxeRange, Lua_ARGB(255,0,255,255))
    end
    
end

function Draven:OnProcessSpell(unit, spell)
	if spell and unit.IsEnemy then
        if self.listSpellInterrup[spell.Name] ~= nil then
			if self.UseEInterrupt and IsValidTarget(unit.Addr, self.E.range) then
				CastSpellTarget(unit.Addr, _E)
			end
		end
	end
end


function Draven:AntiGapCloser()
	for i, heros in pairs(GetEnemyHeroes()) do
    	if heros ~= nil then
      		local hero = GetAIHero(heros)
      		if hero.IsDash then
        		local TargetDashing, CanHitDashing, DashPosition = vpred:IsDashing(hero, 0.09, 65, 2000, myHero, false)
        		local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
        		if DashPosition ~= nil then
          			if GetDistance(DashPosition) < 400 and CanCast(_E) then
          				CastSpellToPos(DashPosition.x,DashPosition.z, _E)
          			else
          				if GetDistance(DashPosition) <= self.E.range then
			    			CastSpellToPos(DashPosition.x, DashPosition.z, _E)
			    		end
          			end
        		end
      		end
    	end
	end
end

function Draven:IsImmobileTarget(unit)
	if (CountBuffByType(unit, 5) == 1 or CountBuffByType(unit, 11) == 1 or CountBuffByType(unit, 29) == 1 or CountBuffByType(unit, 24) == 1 or CountBuffByType(unit, 10) == 1 or CountBuffByType(unit, 29) == 1) then
		return true
	end
	return false
end

function Draven:CanMove(unit)
	if (unit.MoveSpeed < 50 or CountBuffByType(unit.Addr, 5) == 1 or CountBuffByType(unit.Addr, 21) == 1 or CountBuffByType(unit.Addr, 11) == 1 or CountBuffByType(unit.Addr, 29) == 1 or
		unit.HasBuff("recall") or CountBuffByType(unit.Addr, 30) == 1 or CountBuffByType(unit.Addr, 22) == 1 or CountBuffByType(unit.Addr, 8) == 1 or CountBuffByType(unit.Addr, 24) == 1
		or CountBuffByType(unit.Addr, 20) == 1 or CountBuffByType(unit.Addr, 18) == 1) then
		return false
	end
	return true
end

function Draven:CheckWalls(enemyPos)
	local distance = GetDistance(enemyPos)
	local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)

	for i = 100 , 900, 100 do
		local qPos = Vector(enemyPos.x + i, enemyPos.y + i, enemyPos.z)
		--pos = myHeroPos:Extended(enemyPos, distance + 60 * i)
		if IsWall(qPos.x, qPos.y, qPos.z) then
			return qPos
		end
	end
	--return false
end

--[[local function GetDistanceSqr(Pos1, Pos2)
  --local Pos2 = Pos2 or Vector(myHero)
  local P2 = GetOrigin(Pos2) or GetOrigin(myHero)
  local P1 = GetOrigin(Pos1)
  local dx = Pos1.x - Pos2.x
  local dz = (Pos1.z or Pos1.y) - (Pos2.z or Pos2.y)
  return dx * dx + dz * dz
end]]

local function GetDistanceSqr(p1, p2)
    p2 = GetOrigin(p2) or GetOrigin(myHero)
    return (p1.x - p2.x) ^ 2 + ((p1.z or p1.y) - (p2.z or p2.y)) ^ 2
end

function Draven:IsUnderTurretEnemy(pos)			--Will Only work near myHero
	GetAllUnitAroundAnObject(myHero.Addr, 2000)
	local objects = pUnit
	for k,v in pairs(objects) do
		if IsTurret(v) and not IsDead(v) and IsEnemy(v) and GetTargetableToTeam(v) == 4 then
			local turretPos = Vector(GetPosX(v), GetPosY(v), GetPosZ(v))
			if GetDistanceSqr(turretPos,pos) < 915*915 then
				return true
			end
		end
	end
	return false
end

function Draven:IsUnderAllyTurret(pos)
    GetAllUnitAroundAnObject(myHero.Addr, 2000)
  for k,v in pairs(pUnit) do
    if not IsDead(v) and IsTurret(v) and IsAlly(v) and GetTargetableToTeam(v) == 4 then
      local turretPos = Vector(GetPosX(v), GetPosY(v), GetPosZ(v))
      if GetDistanceSqr(turretPos,pos) < 915 ^ 2 then
        return true
      end
    end
  end
    return false
end

function Draven:CountEnemiesInRange(pos, range)
    local n = 0
    GetAllUnitAroundAnObject(myHero.Addr, 2000)
    for i, object in ipairs(pUnit) do
        if GetType(object) == 0 and not IsDead(object) and not IsInFog(object) and GetTargetableToTeam(object) == 4 and IsEnemy(object) then
        	local objectPos = Vector(GetPos(object))
          	if GetDistanceSqr(pos, objectPos) <= math.pow(range, 2) then
            	n = n + 1
          	end
        end
    end
    return n
end

local function CountAlliesInRange(pos, range)
    local n = 0
    GetAllUnitAroundAnObject(myHero.Addr, 2000)
    for i, object in ipairs(pUnit) do
        if GetType(object) == 0 and not IsDead(object) and not IsInFog(object) and GetTargetableToTeam(object) == 4 and IsAlly(object) then
          if GetDistanceSqr(pos, object) <= math.pow(range, 2) then
              n = n + 1
          end
        end
    end
    return n
end


