IncludeFile("Lib\\TOIR_SDK.lua")
--IncludeFile("Lib\\OrbNew.lua")
--IncludeFile("Lib\\AntiGapCloser.lua")

Blitzcrank = class()

function OnLoad()
	if GetChampName(GetMyChamp()) == "Blitzcrank" then
		Blitzcrank:__init()
	end
end

function Blitzcrank:__init()
	-- VPrediction
	vpred = VPrediction(true)

	--TS
    --self.menu_ts = TargetSelector(1750, 0, myHero, true, true, true)


	self.Q = Spell(_Q, 1075)
    self.W = Spell(_W, math.huge)
    self.E = Spell(_E, GetTrueAttackRange())
    self.R = Spell(_R, 680)
    self.Q:SetSkillShot(0.25, 2000, 75, true)
    self.W:SetActive()
    self.E:SetActive()
    self.R:SetActive()

	Callback.Add("Tick", function(...) self:OnTick(...) end)
    Callback.Add("Draw", function(...) self:OnDraw(...) end)
    Callback.Add("ProcessSpell", function(...) self:OnProcessSpell(...) end)

     Callback.Add("DrawMenu", function(...) self:OnDrawMenu(...) end)

    self:MenuValueDefault()

    self.grab = 0
	self.grabS = 0
	self.grabW = 0
	self.posEndDash = Vector(0, 0, 0)
	self.DurationEx = 0
	self.lastCast = 0

	Blitzcrank:aa()
end

function Blitzcrank:MenuValueDefault()
	self.menu = "Blitzcrank_Magic"

	self.menu_Combo_Q = self:MenuBool("Use Q", true)
	self.menu_Combo_QendDash = self:MenuBool("Auto Q End Dash", true)
	self.menu_Combo_Qinterrup = self:MenuBool("Use Q Interrup", true)
	self.menu_Combo_Qks = self:MenuBool("Use Q Kill Steal", true)

	self.menu_Combo_W = self:MenuBool("Auto Use W Combo", true)
	self.menu_Combo_Wslow = self:MenuBool("Use W If Slow", true)

	self.menu_Combo_E = self:MenuBool("Enable E", true)
	self.menu_Combo_Einterrup = self:MenuBool("Use E Interrup", true)

	self.menu_Combo_R = self:MenuBool("Enable R", true)
	self.menu_Combo_Rks = self:MenuBool("Use R Kill Steal", true)


	self.Draw_When_Already = self:MenuBool("Draw When Already", true)
	self.Draw_Q_Range = self:MenuBool("Draw Q Range", true)
	self.Draw_E_Range = self:MenuBool("Draw E Range", true)
	self.Draw_R_Range = self:MenuBool("Draw R Range", true)
	self.menu_Draw_CountQ = self:MenuBool("Draw Q Counter", true)

	self.Enalble_Mod_Skin = self:MenuBool("Enalble Mod Skin", true)
	self.Set_Skin = self:MenuSliderInt("Set Skin", 20)

	self.Combo = self:MenuKeyBinding("Combo", 32)
end

function Blitzcrank:OnDrawMenu()
	if Menu_Begin(self.menu) then
		if Menu_Begin("Setting Q") then
			self.menu_Combo_Q = Menu_Bool("Use Q", self.menu_Combo_Q, self.menu)
			self.menu_Combo_QendDash = Menu_Bool("Auto Q End Dash", self.menu_Combo_QendDash, self.menu)
			self.menu_Combo_Qinterrup = Menu_Bool("Use Q Interrup", self.menu_Combo_Qinterrup, self.menu)
			self.menu_Combo_Qks = Menu_Bool("Use Q Kill Steal", self.menu_Combo_Qks, self.menu)
			Menu_End()
		end
		if Menu_Begin("Setting W") then
			self.menu_Combo_W = Menu_Bool("Auto Use W Combo", self.menu_Combo_W, self.menu)
			self.menu_Combo_Wslow = Menu_Bool("Use W If Slow", self.menu_Combo_Wslow, self.menu)
			Menu_End()
		end
		if Menu_Begin("Setting E") then
			self.menu_Combo_E = Menu_Bool("Enable E", self.menu_Combo_E, self.menu)
			self.menu_Combo_Einterrup = Menu_Bool("Use E Interrup", self.menu_Combo_Einterrup, self.menu)
			Menu_End()
		end
		if Menu_Begin("Setting R") then
			self.menu_Combo_R = Menu_Bool("Enable R", self.menu_Combo_R, self.menu)
			self.menu_Combo_Rks = Menu_Bool("Use R Kill Steal", self.menu_Combo_Rks, self.menu)
			Menu_End()
		end
		if Menu_Begin("Draw Spell") then
			self.Draw_When_Already = Menu_Bool("Draw When Already", self.Draw_When_Already, self.menu)
			self.Draw_Q_Range = Menu_Bool("Draw Q Range", self.Draw_Q_Range, self.menu)
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

function Blitzcrank:MenuBool(stringKey, bool)
	return ReadIniBoolean(self.menu, stringKey, bool)
end

function Blitzcrank:MenuSliderInt(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Blitzcrank:MenuSliderFloat(stringKey, valueDefault)
	return ReadIniFloat(self.menu, stringKey, valueDefault)
end

function Blitzcrank:MenuComboBox(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Blitzcrank:MenuKeyBinding(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Blitzcrank:OnTick()

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
		local targetQ = GetTargetSelector(self.Q.range, 0) --orbwalk:getTarget(self.Q.range)
		if GetBuffByName(targetQ, "rocketgrab2") ~= 0 and IsValidTarget(targetQ, self.Q.range) then
			self.grabS = self.grabS + 1
			self.grabW = GetTimeGame()
		end
	end

	if self.Enalble_Mod_Skin then
		ModSkin(self.Set_Skin)
	end
end


function Blitzcrank:OnDraw()

	if self.Draw_When_Already then
		if self.Draw_Q_Range and self.Q:IsReady() then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.Q.range, Lua_ARGB(255,255,0,0))
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
		if self.Draw_E_Range then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.E.range, Lua_ARGB(255,0,255,0))
		end
		if self.Draw_R_Range then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.R.range, Lua_ARGB(255,0,0,255))
		end
	end

	--[[if self.posEndDash ~= 0 and self.lastCast + 2 * self.DurationEx + 0.1 > GetTimeGame() and self.lastCast + self.DurationEx < GetTimeGame() then
		DrawCircleGame(self.posEndDash.x , self.posEndDash.y, self.posEndDash.z, 200, Lua_ARGB(255,255,0,0))
	end]]
	--[[if self.menu_Draw_CountQ then
		local percent = 0
	    if self.grab > 0 then
			percent = (self.grabS / self.grab) * 100
			DrawTextD3DX(100, 100, " grab: "..tostring(self.grab).." grab successful: " ..tostring(self.grabS).. " grab successful % : " ..tostring(percent).. "%", Lua_ARGB(255, 0, 255, 10))
		end
	end]]

	local TargetQ = GetTargetSelector(self.Q.range - 150, 0)
	if IsValidTarget(TargetQ) and CanCast(_Q) and (GetDistance(TargetQ) <= self.Q.range) then
		Target = GetAIHero(TargetQ)
		local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
		local targetPos = Vector(Target.x, Target.y, Target.z)
	   	local IsCollision = vpred:CheckMinionCollision(Target, targetPos, self.Q.delay, self.Q.width, self.Q.range, self.Q.speed, myHeroPos, nil, true)
	   	if not IsCollision then
			DrawLineGame(myHero.x, myHero.y, myHero.z, targetPos.x, targetPos.y, targetPos.z, 3)
		end
	end

	local TargetDashing, CanHitDashing, DashPosition
	if CanCast(_Q) and IsValidTarget(TargetQ) then
    	Target = GetAIHero(TargetQ)
	    TargetDashing, CanHitDashing, DashPosition = vpred:IsDashing(Target, self.Q.delay, self.Q.width, self.Q.speed, myHero, true)
  	end

  	if DashPosition ~= nil and GetDistance(DashPosition) <= self.Q.range - 150 then
	    CastSpellToPos(DashPosition.x, DashPosition.z, _Q)
	    DrawCircleGame(DashPosition.x, DashPosition.y, DashPosition.z, 200, Lua_ARGB(255, 255, 0, 0))
	end
end

function Blitzcrank:OnProcessSpell(unit, spell)
	if spell and unit.IsMe and spell.Name == "RocketGrab" then
		self.grab = self.grab + 1
	end
	--__PrintDebug(spell.Name)
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

function Blitzcrank:autoQtoEndDash()
	local TargetQ = GetTargetSelector(self.Q.range - 150, 0)
	local TargetDashing, CanHitDashing, DashPosition
	if CanCast(_Q) and IsValidTarget(TargetQ) then
    	Target = GetAIHero(TargetQ)
	    TargetDashing, CanHitDashing, DashPosition = vpred:IsDashing(Target, self.Q.delay, self.Q.width, self.Q.speed, myHero, true)
	    --local Collision = vpred:CheckMinionCollision(Target, DashPosition, self.Q.delay, self.Q.width, self.Q.range, self.Q.speed, myHero, true, true)
  	end

  	if DashPosition ~= nil and GetDistance(DashPosition) <= self.Q.range then
  		local Collision = CountObjectCollision(0, Target.Addr, myHero.x, myHero.z, DashPosition.x, DashPosition.z, self.Q.width, self.Q.range, 65)
  		if Collision == 0 then
	    	CastSpellToPos(DashPosition.x, DashPosition.z, _Q)
	    end
	end
end

function Blitzcrank:KillSteal()
	for i, heros in ipairs(GetEnemyHeroes()) do
		if heros ~= nil then
			local hero = GetAIHero(heros)
			if IsValidTarget(hero.Addr, self.R.range - 150) and CanCast(_R) and self.menu_Combo_Rks and GetDamage("R", hero) > GetHealthPoint(hero.Addr) then
				CastSpellTarget(myHero.Addr, _R)
			end

			if IsValidTarget(hero.Addr, self.Q.range - 150) and CanCast(_Q) and self.menu_Combo_Qks and GetDamage("Q", hero) > GetHealthPoint(hero.Addr) then
				local CastPosition, HitChance, Position = vpred:GetLineCastPosition(Target, self.Q.delay, self.Q.width, self.Q.range, self.Q.speed, myHero, false)
				local distance = VPGetLineCastPosition(target.Addr, self.Q.delay, self.Q.speed)
				if not GetCollision(target.Addr, self.Q.width, self.Q.range, distance, 1) then
					CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
				end
			end
		end
	end
end

function Blitzcrank:ComboMode()
	local TargetQ = GetTargetSelector(self.Q.range - 150, 0)
	if CanCast(_Q) and TargetQ ~= 0 then
		target = GetAIHero(TargetQ)
		local CastPosition, HitChance, Position = vpred:GetLineCastPosition(target, self.Q.delay, self.Q.width, self.Q.range, self.Q.speed, myHero, false)
		local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
		local distance = VPGetLineCastPosition(target.Addr, self.Q.delay, self.Q.speed)

		if TargetQ ~= nil then
			if (GetDistance(TargetQ) < self.Q.range - 100 and GetDistance(TargetQ) > 300  or self:IsImmobileTarget(TargetQ)) then
				if CastPosition and HitChance >= 2 and self.menu_Combo_Q and not GetCollision(target.Addr, self.Q.width, self.Q.range, distance, 1) then
		        	CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
		    	end
		    end
		end
	end

	if self.menu_Combo_W then
		if CanCast(_W) and GetManaPoint(myHero.Addr) > 275 then
			if GetDistance(TargetQ) <= 1200 and GetDistance(TargetQ) > 500 then
				CastSpellTarget(myHero.Addr, _W)
			end
		end
	end

	if self.menu_Combo_Wslow then
		if CanCast(_W) and CountBuffByType(unit, 10) == 1 then
			if GetDistance(TargetQ) <= self.Q.range then
				CastSpellTarget(myHero.Addr, _W)
			end
		end
	end
	local TargetE = GetTargetSelector(self.E.range, 1)
	if self.menu_Combo_E then
		if CanCast(_E) and IsValidTarget(TargetE, self.E.range) then
			if GetDistance(TargetE) <= self.E.range then
				CastSpellTarget(TargetE, _E)
			end
		end
	end

	local TargetR = GetTargetSelector(self.R.range - 150, 0)
	if self.menu_Combo_R then
		if CanCast(_R) and IsValidTarget(TargetR, self.R.range - 100) then
			if GetDistance(TargetR) <= self.R.range then
				CastSpellTarget(TargetR, _R)
			end
		end
	end
end

function Blitzcrank:IsImmobileTarget(unit)
	if (CountBuffByType(unit, 5) == 1 or CountBuffByType(unit, 11) == 1 or CountBuffByType(unit, 29) == 1 or CountBuffByType(unit, 24) == 1 or CountBuffByType(unit, 10) == 1 or CountBuffByType(unit, 29) == 1) then
		return true
	end
	return false
end

function Blitzcrank:aa()

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


