IncludeFile("Lib\\TOIR_SDK.lua")
--IncludeFile("Lib\\OrbNew.lua")
--IncludeFile("Lib\\AllClass.lua")

Thresh = class()

function OnLoad()
	if GetChampName(GetMyChamp()) == "Thresh" then
		Thresh:__init()
	end
end

function Thresh:__init()
	-- VPrediction
	vpred = VPrediction(true)

	--TS
    self.menu_ts = TargetSelector(1750, 0, myHero, true, true, true)

	--menuInstSep.setValue("Thresh Magic")

	self.Q = Spell(_Q, 1175)
    self.W = Spell(_W, 1075)
    self.E = Spell(_E, 500)
    self.R = Spell(_R, 450)
    self.Q:SetSkillShot(0.5, 1900, 70, true)
    self.W:SetSkillShot(0.25, 1900, 70, false)
    self.E:SetSkillShot(0.25, 1900, 70, false)
    self.R:SetActive()

	Callback.Add("Tick", function(...) self:OnTick(...) end)
    Callback.Add("Draw", function(...) self:OnDraw(...) end)
    Callback.Add("ProcessSpell", function(...) self:OnProcessSpell(...) end)
    --Callback.Add("PlayAnimation", function(...) self:OnPlayAnimation(...) end)

    Callback.Add("DrawMenu", function(...) self:OnDrawMenu(...) end)

    self:MenuValueDefault()

    self.grab = 0
	self.grabS = 0
	self.grabW = 0
	self.lastQ = 0
	self.posEndDash = Vector(0, 0, 0)
	self.DurationEx = 0
	self.lastCast = 0

	Thresh:aa()
end

function Thresh:MenuValueDefault()
	self.menu = "Thresh_Magic"

	self.menu_Combo_Q = self:MenuBool("Use Q", true)
	self.menu_Combo_Q2 = self:MenuBool("Use Q2", true)
	self.menu_Combo_QendDash = self:MenuBool("Auto Q End Dash", true)
	self.menu_Combo_Qinterrup = self:MenuBool("Use Q Interrup", true)
	self.menu_Combo_Qks = self:MenuBool("Use Q Kill Steal", true)

	self.menu_Combo_W = self:MenuBool("Auto Use W Combo", true)
	self.menu_Combo_Wsavehp = self:MenuSliderInt("Save When HP", 30)
	self.menu_Combo_Wshieldhp = self:MenuSliderInt("Shield Allies on CC", 20)

	self.menu_Combo_Epull = self:MenuKeyBinding("Use E Pull", 32)
	self.menu_Combo_Epush = self:MenuKeyBinding("Use E Push", 88)
	self.menu_Combo_Egap = self:MenuBool("Use E Anti Gapclose", true)
	self.menu_Combo_Einterrup = self:MenuBool("Use E Interrup", true)
	self.menu_Combo_Eks = self:MenuBool("Use E Kill Steal", true)

	self.menu_Combo_Reneme = self:MenuSliderInt("Save When HP", 2)
	self.menu_Combo_Rks = self:MenuBool("Use R Kill Steal", true)


	self.Draw_When_Already = self:MenuBool("Draw When Already", true)
	self.Draw_Q_Range = self:MenuBool("Draw Q Range", true)
	self.Draw_W_Range = self:MenuBool("Draw W Range", true)
	self.Draw_E_Range = self:MenuBool("Draw E Range", true)
	self.Draw_R_Range = self:MenuBool("Draw R Range", true)
	self.menu_Draw_CountQ = self:MenuBool("Draw Q Counter", true)

	self.Enalble_Mod_Skin = self:MenuBool("Enalble Mod Skin", false)
	self.Set_Skin = self:MenuSliderInt("Set Skin", 5)

	self.Combo = self:MenuKeyBinding("Combo", 32)
end

function Thresh:OnDrawMenu()
	if Menu_Begin(self.menu) then
		if Menu_Begin("Setting Q") then
			self.menu_Combo_Q = Menu_Bool("Use Q", self.menu_Combo_Q, self.menu)
			self.menu_Combo_Q2 = Menu_Bool("Use Q2", self.menu_Combo_Q2, self.menu)
			self.menu_Combo_QendDash = Menu_Bool("Auto Q End Dash", self.menu_Combo_QendDash, self.menu)
			self.menu_Combo_Qinterrup = Menu_Bool("Use Q Interrup", self.menu_Combo_Qinterrup, self.menu)
			self.menu_Combo_Qks = Menu_Bool("Use Q Kill Steal", self.menu_Combo_Qks, self.menu)
			Menu_End()
		end
		if Menu_Begin("Setting W") then
			self.menu_Combo_W = Menu_Bool("Auto Use W Combo", self.menu_Combo_W, self.menu)
			self.menu_Combo_Wsavehp = Menu_SliderInt("Save When HP", self.menu_Combo_Wsavehp, 0, 100, self.menu)
			self.menu_Combo_Wshieldhp = Menu_SliderInt("Shield Allies on CC", self.menu_Combo_Wshieldhp, 0, 100, self.menu)
			Menu_End()
		end
		if Menu_Begin("Setting E") then
			self.menu_Combo_Epull = Menu_KeyBinding("Use E Pull", self.menu_Combo_Epull, self.menu)
			self.menu_Combo_Epush = Menu_KeyBinding("Use E Push", self.menu_Combo_Epush, self.menu)
			self.menu_Combo_Egap = Menu_Bool("Use E Anti Gapclose", self.menu_Combo_Egap, self.menu)
			self.menu_Combo_Einterrup = Menu_Bool("Use E Interrup", self.menu_Combo_Einterrup, self.menu)
			self.menu_Combo_Eks = Menu_Bool("Use E Kill Steal", self.menu_Combo_Eks, self.menu)
			Menu_End()
		end
		if Menu_Begin("Setting R") then
			self.menu_Combo_Reneme = Menu_SliderInt("Enable R for x Enemy", self.menu_Combo_Reneme, 1, 5, self.menu)
			self.menu_Combo_Rks = Menu_Bool("Use R Kill Steal", self.menu_Combo_Rks, self.menu)
			Menu_End()
		end
		if Menu_Begin("Draw Spell") then
			self.Draw_When_Already = Menu_Bool("Draw When Already", self.Draw_When_Already, self.menu)
			self.Draw_Q_Range = Menu_Bool("Draw Q Range", self.Draw_Q_Range, self.menu)
			self.Draw_W_Range = Menu_Bool("Draw W Range", self.Draw_W_Range, self.menu)
			self.Draw_E_Range = Menu_Bool("Draw E Range", self.Draw_E_Range, self.menu)
			self.Draw_R_Range = Menu_Bool("Draw R Range", self.Draw_R_Range, self.menu)
			self.menu_Draw_CountQ = Menu_Bool("Draw Q Counter", self.menu_Draw_CountQ, self.menu)
			Menu_End()
		end
		if Menu_Begin("Mod Skin") then
			self.Enalble_Mod_Skin = Menu_Bool("Enalble Mod Skin", self.Enalble_Mod_Skin, self.menu)
			self.Set_Skin = Menu_SliderInt("Set Skin", self.Set_Skin, 0, 20, self.menu)
			Menu_End()
		end
		if Menu_Begin("Key Mode") then
			self.Combo = Menu_KeyBinding("Combo", self.Combo, self.menu)
			Menu_End()
		end
		Menu_End()
	end
end

function Thresh:MenuBool(stringKey, bool)
	return ReadIniBoolean(self.menu, stringKey, bool)
end

function Thresh:MenuSliderInt(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Thresh:MenuSliderFloat(stringKey, valueDefault)
	return ReadIniFloat(self.menu, stringKey, valueDefault)
end

function Thresh:MenuComboBox(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Thresh:MenuKeyBinding(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Thresh:OnTick()

	if IsDead(myHero.Addr) then return end
	SetLuaCombo(true)
	
	if GetKeyPress(self.Combo) > 0 then			
		self:ComboMode()	
	end

	if self.menu_Combo_QendDash then
		self:autoQtoEndDash()
	end

	self:KillSteal()

	if not self.Q:IsReady() and GetTimeGame() - self.grabW > 2 then
		local targetQ = self.menu_ts:GetTarget(self.Q.range) --orbwalk:getTarget(self.Q.range)
		if GetBuffByName(targetQ, "ThreshQ") ~= 0 and IsValidTarget(targetQ, self.Q.range) then
			self.grabS = self.grabS + 1
			self.grabW = GetTimeGame()
			self.lastQ = GetTimeGame()
		end
	end

	if self.Enalble_Mod_Skin then
		ModSkin(self.Set_Skin)
	end
end

function Thresh:OnDraw()

	if self.Draw_When_Already then
		if self.Draw_Q_Range and self.Q:IsReady() then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.Q.range, Lua_ARGB(255,255,0,0))
		end
		if self.Draw_W_Range and self.W:IsReady() then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.W.range, Lua_ARGB(255,255,0,255))
		end
		if self.Draw_E_Range and self.E:IsReady() then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.E.range, Lua_ARGB(255,0,255,0))
		end
		if self.Draw_R_Range and self.R:IsReady() then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.R.range, Lua_ARGB(255,0,0,255))
		end
	else
		if self.Draw_Q_Range then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.Q.range, Lua_ARGB(255,255,0,0))
		end
		if self.Draw_W_Range and self.W:IsReady() then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.W.range, Lua_ARGB(255,255,0,255))
		end
		if self.Draw_E_Range then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.E.range, Lua_ARGB(255,0,255,0))
		end
		if self.Draw_R_Range then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.R.range, Lua_ARGB(255,0,0,255))
		end
	end

	if self.posEndDash ~= 0 and self.lastCast + 2 * self.DurationEx + 0.1 > GetTimeGame() and self.lastCast + self.DurationEx < GetTimeGame() then
		DrawCircleGame(self.posEndDash.x , self.posEndDash.y, self.posEndDash.z, 200, Lua_ARGB(255,255,0,0))
	end

	local percent = 0
    if (self.grab > 0) and self.menu_Draw_CountQ then
		percent = (self.grabS / self.grab) * 100
		DrawTextD3DX(100, 100, " grab: "..tostring(self.grab).." grab successful: " ..tostring(self.grabS).. " grab successful % : " ..tostring(percent).. "%", Lua_ARGB(255, 0, 255, 10))
	end
end

function Thresh:Qstat(t)
	target = t or self.menu_ts:GetTarget(self.Q.range)
	if not self.Q:IsReady() then
		return false
	end
	if GetBuffByName(target, "ThreshQ") ~= 0 then
		return true
	end
	return false
end

function Thresh:OnProcessSpell(unit, spell)
	if spell and unit.IsMe and spell.Name == "ThreshQ" then
		self.grab = self.grab + 1
	end

	if spell and unit.IsEnemy then
        if self.listSpellInterrup[spell.Name] ~= nil then
			local vp_distance = VPGetLineCastPosition(unit.Addr, self.Q.delay, self.Q.speed)
			local targetPos = Vector(unit.x, unit.y, unit.z)
			local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
			if self.menu_Combo_Qinterrup and IsValidTarget(unit.Addr, self.Q.range) then
				if not GetCollision(unit.Addr, self.Q.width, self.Q.range, vp_distance) then
					CastSpellToPredictionPos(unit.Addr, _Q, vp_distance)
				end
			end
			if self.menu_Combo_Einterrup and IsValidTarget(unit.Addr, self.E.range) then
				CastSpellTarget(unit.Addr, _E)
			end
		end
	end
end

function Thresh:CountAlliesInRange(unit, range)
	return CountAllyChampAroundObject(unit, range)
end

function Thresh:CountEnemiesInRange(unit, range)
	return CountEnemyChampAroundObject(unit, range)
end

function Thresh:IsUnderAllyTurret(pos)
    GetAllUnitAroundAnObject(myHero.Addr, 2000)
	for k,v in pairs(pUnit) do
		if not IsDead(v) and IsTurret(v) and IsAlly(v) then
			local turretPos = Vector(GetPosX(v), GetPosY(v), GetPosZ(v))
			if GetDistance(turretPos,pos) < 915 then
				return true
			end
		end
	end
    return false
end

function Thresh:autoQtoEndDash()
	local TargetQ = self.menu_ts:GetTarget(self.Q.range)
	local TargetDashing, CanHitDashing, DashPosition
	if CanCast(_Q) and IsValidTarget(TargetQ) then
    	Target = GetAIHero(TargetQ)
	    TargetDashing, CanHitDashing, DashPosition = vpred:IsDashing(Target, self.Q.delay, self.Q.width, self.Q.speed, myHero)
	    --local Collision = vpred:CheckMinionCollision(Target, DashPosition, self.Q.delay, self.Q.width, self.Q.range, self.Q.speed, myHero, true, true)
  	end

  	if DashPosition ~= nil and GetDistance(DashPosition) <= self.Q.range and not self:Qstat(TargetQ) then
	    local Collision = CountObjectCollision(0, Target.Addr, myHero.x, myHero.z, DashPosition.x, DashPosition.z, self.Q.width, self.Q.range, 65)
  		if Collision == 0 then
	    	CastSpellToPos(DashPosition.x, DashPosition.z, _Q)
	    end
	end

	local TargetE = self.menu_ts:GetTarget(self.E.range)
	if CanCast(_E) and IsValidTarget(TargetE) then
    	Target = GetAIHero(TargetE)
	    local TargetDashing, CanHitDashing, DashPosition = vpred:IsDashing(Target, self.E.delay, self.E.width, self.E.speed, myHero)

	    if DashPosition ~= nil and GetDistance(DashPosition) <= self.E.range then
	        local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
			local targetPos = Vector(Target.x, Target.y, Target.z)
	        if GetDistance(DashPosition) < self.E.range then
				CastSpellToPos(DashPosition.x, DashPosition.z, _E)
			end

			if GetDistance(myHeroPos, targetPos) < self.E.range and GetDistance(DashPosition) < self.E.range and (self:IsUnderAllyTurret(myHeroPos) or self:CountAlliesInRange(myHero.Addr, 1000) > 0) then
				pos = myHeroPos:Extended(DashPosition, - self.E.range)
				CastSpellToPos(pos.x, pos.z, _E)
			end
	    end
  	end
end

function Thresh:KillSteal()
	for i, heros in ipairs(GetEnemyHeroes()) do
		if heros ~= nil then
			local hero = GetAIHero(heros)
			if IsValidTarget(hero.Addr, self.R.range) and CanCast(_R) and self.menu_Combo_Rks and GetDamage("R", hero) > GetHealthPoint(hero.Addr) then
				CastSpellTarget(myHero.Addr, _R)
			end

			if IsValidTarget(hero.Addr, self.Q.range) and CanCast(_Q) and self.menu_Combo_Qks and GetDamage("Q", hero) > GetHealthPoint(hero.Addr) then
				local CastPosition, HitChance, Position = vpred:GetLineCastPosition(Target, self.Q.delay, self.Q.width, self.Q.range, self.Q.speed, myHero, false)
				local distance = VPGetLineCastPosition(target.Addr, self.Q.delay, self.Q.speed)
				if not GetCollision(target.Addr, self.Q.width, self.Q.range, distance, 1) then
					CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
				end
			end

			if IsValidTarget(hero.Addr, self.R.range) and CanCast(_E) and self.menu_Combo_Eks and GetDamage("E", hero) > GetHealthPoint(hero.Addr) then
				--CastSpellTarget(myHero.Addr, _E)
				Pull(hero.Addr)
			end
		end
	end
end

function Thresh:Push(t)
	target = t or self.menu_ts:GetTarget(self.E.range)
	hero = GetAIHero(target)
	if(hero ~= nil) then
		CastSpellToPos(hero.x,hero.z, _E)
	end
end

function Thresh:Pull(t)
	target = t or self.menu_ts:GetTarget(self.E.range)
	if(target ~= nil) then
		local targetPos = Vector(GetPosX(target), GetPosY(target), GetPosZ(target))
		local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
		--pos = Vector(myHeroPos) + (Vector(myHeroPos) - Vector(targetPos)):Normalized()*400
		pos = myHeroPos:Extended(targetPos, - self.E.range)
		CastSpellToPos(pos.x, pos.z, _E)
	end
end

function Thresh:ComboMode()
	local TargetQ = self.menu_ts:GetTarget(self.Q.range)
	if self.menu_Combo_Q then
		--if TargetQ ~= nil and (GetDistance(TargetQ) < self.Q.range - 150  or self:IsImmobileTarget(TargetQ)) and self.menu_Combo_Q then
		--__PrintTextGame(tostring(self:Qstat(TargetQ)))
		if TargetQ ~= nil and (GetDistance(TargetQ) < self.Q.range - 150 and GetDistance(TargetQ) > 300
			or self:IsImmobileTarget(TargetQ)) and self.menu_Combo_Q and not self:Qstat(TargetQ) then
			self:CastQ(TargetQ)
		end
	end

	if self.menu_Combo_Q2 and GetTimeGame() - self.lastQ > 1 and self:Qstat(TargetQ) then
		CastSpellTarget(myHero.Addr, _Q)
	end

	local TargetE = self.menu_ts:GetTarget(self.E.range)
	if CanCast(_E) and GetKeyPress(self.menu_Combo_Epull) > 0 and IsValidTarget(TargetE, self.E.range) then
		self:Pull(TargetE)
	end
	if CanCast(_E) and GetKeyPress(self.menu_Combo_Epush) > 0 and IsValidTarget(TargetE, self.E.range) then
		self:Push(TargetE)
	end

	local TargetR = self.menu_ts:GetTarget(self.R.range)
	if CanCast(_R) and self:CountEnemiesInRange(myHero.Addr, self.R.range) >= self.menu_Combo_Reneme and IsValidTarget(TargetR, self.R.range) then
		CastSpellTarget(myHero.Addr, _R)
	end

	if CanCast(_W) and self.menu_Combo_W then
		self:autoW()
	end

	local Ally = self:GetUglyAlly(self.W.range)

	if CanCast(_W) and (self.menu_Combo_Wshieldhp >= (GetHealthPoint(Ally) / GetHealthPointMax(Ally) * 100) and self:IsImmobileTarget(Ally)) and self:CountEnemiesInRange(Ally, self.W.range) > 1 then

		local allyPos = Vector(GetPosX(Ally), GetPosY(Ally), GetPosZ(Ally))
		local myHeroPos = Vector(GetPosX(myHero.Addr), GetPosY(myHero.Addr), GetPosZ(myHero.Addr))

		local posW1 = allyPos:Extended(myHeroPos, 300)
		local posW2 = myHeroPos:Extended(allyPos, self.W.range - 200)

		if Ally == myHero.Addr then
			CastSpellTarget(myHero.Addr, _W)
		end

		if GetDistance(allyPos) < self.W.range then
			CastSpellToPos(posW1.x, posW1.z, _W)
		else
			CastSpellToPos(posW2.x, posW2.z, _W)
		end
	end

	if CanCast(_W) and (self.menu_Combo_Wsavehp >= GetHealthPoint(Ally) / GetHealthPointMax(Ally) * 100) and self:CountEnemiesInRange(Ally, self.W.range) > 1 then

		local allyPos = Vector(GetPosX(Ally), GetPosY(Ally), GetPosZ(Ally))
		local myHeroPos = Vector(GetPosX(myHero.Addr), GetPosY(myHero.Addr), GetPosZ(myHero.Addr))

		local posW1 = allyPos:Extended(myHeroPos, 300)
		local posW2 = myHeroPos:Extended(allyPos, self.W.range - 200)

		if Ally == myHero.Addr then
			CastSpellTarget(myHero.Addr, _W)
		end

		if GetDistance(allyPos) < self.W.range then
			CastSpellToPos(posW1.x, posW1.z, _W)
		else
			CastSpellToPos(posW2.x, posW2.z, _W)
		end
	end
end

function Thresh:CastQ(target)
    if CanCast(_Q) and IsValidTarget(target) then
    	Target = GetAIHero(target)
	    local CastPosition, HitChance, Position = vpred:GetLineCastPosition(Target, self.Q.delay, self.Q.width, self.Q.range, self.Q.speed, myHero, false)
	    if CastPosition and HitChance >= 2 and GetDistance(CastPosition) <= self.Q.range then
	    	local Collision = CountObjectCollision(0, Target.Addr, myHero.x, myHero.z, CastPosition.x, CastPosition.z, self.Q.width, self.Q.range, 65)
	    	if Collision == 0 then
	        	CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
	        end
	    end
  	end
end

function Thresh:GetUglyAlly(range)
    local result = nil
    local N = math.huge
    for i,hero in pairs(GetAllyHeroes()) do
	table.sort(GetAllyHeroes(), function(a, b) return GetDistance(a) < GetDistance(b) end)
        if hero~= 0 and not IsDead(hero) and IsAlly(hero) and GetDistance(hero) < range then
            local tokill = GetHealthPoint(hero)
            if tokill > N or result == nil then
                N = tokill
                result = hero
            end
        end
    end
    return result
end

function Thresh:autoW()

	local ally = self:GetUglyAlly(self.W.range + 500)
	local allyPos = Vector(GetPosX(ally), GetPosY(ally), GetPosZ(ally))
	local myHeroPos = Vector(GetPosX(myHero.Addr), GetPosY(myHero.Addr), GetPosZ(myHero.Addr))
	local posW1 = allyPos:Extended(myHeroPos, 300)
	local posW2 = myHeroPos:Extended(allyPos, self.W.range - 100)

	local TargetQ = self.menu_ts:GetTarget(self.Q.range)
	if self:Qstat(TargetQ) and CanCast(_W) then
		if GetDistance(allyPos) < self.W.range + 100 then
			CastSpellToPos(posW1.x, posW1.z, _W)
		else
			CastSpellToPos(posW2.x, posW2.z, _W)
		end
	end
end

function Thresh:IsImmobileTarget(unit)
	if (CountBuffByType(unit, 5) == 1 or CountBuffByType(unit, 11) == 1 or CountBuffByType(unit, 29) == 1 or CountBuffByType(unit, 24) == 1 or CountBuffByType(unit, 10) == 1 or CountBuffByType(unit, 29) == 1) then
		return true
	end
	return false
end

function Thresh:aa()

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

	self.listEndDash =
	{
		{Name = "ZoeR", RangeMin = 570, Range = 570, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "MaokaiW", RangeMin = 0, Range = math.huge, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "CamilleE", RangeMin = 0, Range = math.huge, Type = 1, Duration = 1.25}, --MaokaiW
		--{Name = "BlindMonkQTwo", RangeMin = 0, Range = math.huge, Type = 1, Duration = 0.25}, --MaokaiW
		{Name = "BlindMonkWOne", RangeMin = 0, Range = math.huge, Type = 1, Duration = 0.25}, --MaokaiW
		{Name = "NocturneParanoia2", RangeMin = 0, Range = math.huge, Type = 1, Duration = 0.25}, --MaokaiW
		{Name = "XinZhaoE", RangeMin = 0, Range = 100, Type = 2, Duration = 0.25}, --CHUAN
		{Name = "PantheonW", RangeMin = 0, Range = 200, Type = 2, Duration = 0.25}, --CHUAN
		{Name = "AkaliShadowDance", RangeMin = 0, Range = - 100, Type = 2, Duration = 0.25}, --CHUAN
		{Name = "AkaliSmokeBomb", RangeMin = 0, Range = 250, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "Headbutt", RangeMin = 0, Range = math.huge, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "BraumW", RangeMin = 0, Range = - 140, Type = 2, Duration = 0.25}, --CHUAN
		{Name = "DianaTeleport", RangeMin = 0, Range = 80, Type = 2, Duration = 0.25}, --50% CHUAN
		{Name = "JaxLeapStrike", RangeMin = 0, Range = math.huge, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "MonkeyKingNimbus", RangeMin = 0, Range = math.huge, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "PoppyE", RangeMin = 0, Range = math.huge, Type = 1, Duration = 0.25}, --MaokaiW
		{Name = "IreliaGatotsu", RangeMin = 0, Range = math.huge, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "UFSlash", RangeMin = 0, Range = math.huge, Type = 1, Duration = 0.25}, --CHUAN MalphiteR
		{Name = "LucianE", RangeMin = 200, Range = 430, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "EzrealArcaneShift", RangeMin = 0, Range = 470, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "TristanaW", RangeMin = 0, Range = 900, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "SummonerFlash", RangeMin = 0, Range = 400, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "AhriTumble", RangeMin = 0, Range = 500, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "CarpetBomb", RangeMin = 300, Range = 600, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "FioraQ", RangeMin = 0, Range = 400, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "KindredQ", RangeMin = 0, Range = 300, Type = 1, Duration = 0.25}, --CHUAn
		{Name = "RiftWalk", RangeMin = 0, Range = 500, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "FizzETwo", RangeMin = 0, Range = 300, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "FizzE", RangeMin = 0, Range = 400, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "CamilleEDash2", RangeMin = 0, Range = 400, Type = 1, Duration = 0.25}, --50% CHUAN
		{Name = "AatroxQ", RangeMin = 0, Range = 650, Type = 1, Duration = 0.5}, --CHUAN
		{Name = "RakanW", RangeMin = 0, Range = 650, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "QuinnE", RangeMin = 0, Range = 600, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "JarvanIVDemacianStandard", RangeMin = 0, Range = 850, Type = 1, Duration = 0.25}, --Ezreal E
		{Name = "ShyvanaTransformLeap", RangeMin = 0, Range = 1000, Type = 1, Duration = 0.25}, --Ezreal E
		{Name = "ShenE", RangeMin = 300, Range = 600, Type = 1, Duration = 0.5}, --CHUAN
		{Name = "Deceive", RangeMin = 0, Range = 400, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "SejuaniQ", RangeMin = 0, Range = 650, Type = 1, Duration = 0.25}, --Ezreal E
		{Name = "KhazixE", RangeMin = 0, Range = 700, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "KhazixELong", RangeMin = 0, Range = 900, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "TryndamereE", RangeMin = 0, Range = 650, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "LeblancW", RangeMin = 0, Range = 600, Type = 1, Duration = 0.25}, --Ezreal E
		{Name = "GalioE", RangeMin = 0, Range = 625, Type = 1, Duration = 0.5}, --Ezreal E
		{Name = "ZacE", RangeMin = 0, Range = 1200, Type = 1, Duration = 1}, --Ezreal E
		--{Name = "ViQ", RangeMin = 0, Range = 720, Type = 1, Duration = 0.25}, --Ezreal E
		{Name = "EkkoEAttack", RangeMin = 0, Range = 150, Type = 2, Duration = 0.25}, --CHUAN
		{Name = "TalonQ", RangeMin = 0, Range = 120, Type = 2, Duration = 0.25}, --CHUAN
		{Name = "EkkoE", RangeMin = 350, Range = 350, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "FizzQ", RangeMin = 550, Range = 600, Type = 1, Duration = 0.25}, --50% CHUAN
		{Name = "GragasE", RangeMin = 700, Range = 600, Type = 1, Duration = 0.25}, --Ezreal E
		{Name = "GravesMove", RangeMin = 280, Range = 370, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "OrnnE", RangeMin = 650, Range = 650, Type = 1, Duration = 0.75}, --CHUAN
		{Name = "Pounce", RangeMin = 370, Range = 370, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "RivenFeint", RangeMin = 250, Range = 250, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "KaynQ", RangeMin = 350, Range = 350, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "RenektonSliceAndDice", RangeMin = 450, Range = 450, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "RenektonDice", RangeMin = 450, Range = 450, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "VayneTumble", RangeMin = 300, Range = 300, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "UrgotE", RangeMin = 470, Range = 470, Type = 3, Duration = 0.25}, --Ezreal E
		{Name = "JarvanIVDragonStrike", RangeMin = 850, Range = 850, Type = 1, Duration = 0.25}, --Ezreal E
		{Name = "WarwickR", RangeMin = 1000, Range = 1000, Type = 1, Duration = 1}, --CHUAN
		{Name = "YasuoDashWrapper", RangeMin = 480, Range = 480, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "CaitlynEntrapment", RangeMin = -380, Range = -380, Type = 1, Duration = 0.25}, --CHUAN
	}
end


