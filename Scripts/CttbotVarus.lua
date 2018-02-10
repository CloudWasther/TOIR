IncludeFile("Lib\\TOIR_SDK.lua")

Varus = class()

function OnLoad()
	--if GetChampName(GetMyChamp()) == "Varus" then
		Varus:__init()
	--end
end

function Varus:__init()
	if myHero.CharName ~= "Varus" then
        return;
    end
	-- VPrediction
	vpred = VPrediction(true)
	AntiGap = AntiGapcloser(nil)

    --self.Q = Spell(_Q, 1150)
    --self.Q2 = Spell(_Q, 1600)
    self.E = Spell(_E, 1050)
    self.R = Spell(_R, 1400)

    self.Q = ({Slot = 0, delay = 0.25, minrange = 1150, maxrange = 1800, speed = 1750, width = 70})
    --self.Q:SetSkillShot(0.25, 1650, 70, true)
    self.E:SetSkillShot(0.25, 1400, 120, true)
    self.R:SetSkillShot(1.2, 2000, 120, true)

    self.OverKill = 0
    self.tickIndex = 0
    self.ts_prio = {}
    self.attackNow = false
    self.CastTime = 0 --GetTimeGame()
    self.CanCast = true
    self._chargedCastedT = 0
    self.Charging = false

	--Callback.Add("Tick", function(...) self:OnTick(...) end)
	--Callback.Add("AfterAttack", function(...) self:OnAfterAttack(...) end)
    --Callback.Add("BeforeAttack", function(...) self:OnBeforeAttack(...) end)
    Callback.Add("Update", function(...) self:OnUpdate(...) end)
    Callback.Add("PlayAnimation", function(unit, anim) self:OnPlayAnimation(unit, anim) end)
    Callback.Add("ProcessSpell", function(...) self:OnProcessSpell(...) end)
    Callback.Add("DoCast", function(...) self:OnDoCast(...) end)
    Callback.Add("Draw", function(...) self:OnDraw(...) end)
    Callback.Add("AntiGapClose", function(target, EndPos) self:OnAntiGapClose(target, EndPos) end)
    Callback.Add("DrawMenu", function(...) self:OnDrawMenu(...) end)
    self:MenuValueDefault()
end

function Varus:MenuValueDefault()
	self.menu = "Varus_Magic"
	self.Draw_When_Already = self:MenuBool("Draw When Already", false)
	self.menu_Draw_Q = self:MenuBool("Draw Q Range", false)
	self.menu_Draw_E = self:MenuBool("Draw E Range", false)
	self.menu_Draw_R = self:MenuBool("Draw R Range", false)

	self.autoQ = self:MenuBool("Auto Q", true)
	self.maxQ = self:MenuBool("Cast Q only max range", true)
	self.fastQ = self:MenuBool("Fast cast Q", true)
	self.qonly = self:MenuBool("Only Q if have W", false)
	--for i, enemy in pairs(GetEnemyHeroes()) do
        --table.insert(self.ts_prio, { Enemy = GetAIHero(enemy), Menu = self:MenuBool(GetAIHero(enemy).CharName, true)})
    --end

	self.wCount = self:MenuSliderInt("Auto Cast Spell if Count W", 3)

	self.autoE = self:MenuBool("Auto E", true)
	self.AGC = self:MenuBool("AntiGapcloser E", true)
	self.Eend = self:MenuBool("Auto E EndDash", true)

	self.autoR = self:MenuBool("Auto R KS", true)
	self.rGap = self:MenuBool("GapCloser R", true)
	self.useR = self:MenuKeyBinding("Semi-manual cast R key", 84)
	self.rCount = self:MenuSliderInt("Auto R if enemies in range (combo mode)", 3)

	self.Enalble_Mod_Skin = self:MenuBool("Enalble Mod Skin", false)
	self.Set_Skin = self:MenuSliderInt("Set Skin", 9)

	self.Combo = self:MenuKeyBinding("Combo", 32)
	self.Harass = self:MenuKeyBinding("Harass", 67)
	self.Lane_Clear = self:MenuKeyBinding("Lane Clear", 86)
	self.Last_Hit = self:MenuKeyBinding("Last Hit", 88)
end

function Varus:OnDrawMenu()
	if Menu_Begin(self.menu) then
		if Menu_Begin("Setting Q") then
			self.autoQ = Menu_Bool("Auto Q", self.autoQ, self.menu)
			self.maxQ = Menu_Bool("Cast Q only max range", self.maxQ, self.menu)
			self.fastQ = Menu_Bool("Fast cast Q", self.fastQ, self.menu)
			self.qonly = Menu_Bool("Only Q if have W", self.qonly, self.menu)
			--Menu_Text("Harass Enemy")
			--for i, enemy in pairs(GetEnemyHeroes()) do
            	--self.ts_prio[i].Menu = Menu_Bool(GetAIHero(enemy).CharName, self.ts_prio[i].Menu, self.menu)
        	--end
			Menu_End()
		end

		if Menu_Begin("Setting W") then
			self.wCount = Menu_SliderInt("Auto Cast Spell if Count W", self.wCount, 0, 3, self.menu)
			Menu_End()
		end

		if Menu_Begin("Setting E") then
			self.autoE = Menu_Bool("Auto E", self.autoE, self.menu)
			self.AGC = Menu_Bool("AntiGapcloser E", self.AGC, self.menu)
			self.Eend = Menu_Bool("Auto E EndDash", self.Eend, self.menu)
			Menu_End()
		end

		if Menu_Begin("Setting R") then
			self.autoR = Menu_Bool("Auto R KS", self.autoR, self.menu)
			self.rGap = Menu_Bool("GapCloser R", self.rGap, self.menu)
			self.useR = Menu_KeyBinding("Semi-manual cast R key", self.useR, self.menu)
			self.rCount = Menu_SliderInt("Auto R if enemies in range (combo mode)", self.rCount, 0, 5, self.menu)
			Menu_End()
		end

		if Menu_Begin("Draw Spell") then
			self.Draw_When_Already = Menu_Bool("Draw When Already", self.Draw_When_Already, self.menu)
			self.menu_Draw_Q = Menu_Bool("Draw Q Range", self.menu_Draw_Q, self.menu)
			self.menu_Draw_E = Menu_Bool("Draw E Range", self.menu_Draw_E, self.menu)
			self.menu_Draw_R = Menu_Bool("Draw R Range", self.menu_Draw_R, self.menu)
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

function Varus:MenuBool(stringKey, bool)
	return ReadIniBoolean(self.menu, stringKey, bool)
end

function Varus:MenuSliderInt(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Varus:MenuSliderFloat(stringKey, valueDefault)
	return ReadIniFloat(self.menu, stringKey, valueDefault)
end

function Varus:MenuComboBox(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Varus:MenuKeyBinding(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Varus:HitChanceManager(hc)
	return (hc + 3)
end

function Varus:GetQLinePreCore(target)
	local castPosX, castPosZ, unitPosX, unitPosZ, hitChance, _aoeTargetsHitCount = GetPredictionCore(target.Addr, 0, self.Q.delay, self.Q.width, self.Q.maxrange, self.Q.speed, myHero.x, myHero.z, false, false, 1, 5, 5, 2, 5, 5)
	if target ~= nil then
		 CastPosition = Vector(castPosX, target.y, castPosZ)
		 HitChance = hitChance
		 Position = Vector(unitPosX, target.y, unitPosZ)
		 return CastPosition, HitChance, Position
	end
	return nil , 0 , nil
end

function Varus:GetECirclePreCore(target)
	local castPosX, castPosZ, unitPosX, unitPosZ, hitChance, _aoeTargetsHitCount = GetPredictionCore(target.Addr, 1, self.E.delay, self.E.width, self.E.range, self.E.speed, myHero.x, myHero.z, false, false, 1, 5, 5, 5, 5, 5)
	if target ~= nil then
		 CastPosition = Vector(castPosX, target.y, castPosZ)
		 HitChance = hitChance
		 Position = Vector(unitPosX, target.y, unitPosZ)
		 return CastPosition, HitChance, Position
	end
	return nil , 0 , nil
end

function Varus:GetRLinePreCore(target)
	local castPosX, castPosZ, unitPosX, unitPosZ, hitChance, _aoeTargetsHitCount = GetPredictionCore(target.Addr, 0, self.R.delay, self.R.width, self.R.range, self.R.speed, myHero.x, myHero.z, false, false, 1, 5, 5, 2, 5, 5)
	if target ~= nil then
		 CastPosition = Vector(castPosX, target.y, castPosZ)
		 HitChance = hitChance
		 Position = Vector(unitPosX, target.y, unitPosZ)
		 return CastPosition, HitChance, Position
	end
	return nil , 0 , nil
end

function Varus:OnAntiGapClose(target, EndPos)
	hero = GetAIHero(target.Addr)
    if GetDistance(EndPos) < 500 or GetDistance(hero) < 500 and myHero.MP > 120 then
    	if self.rGap and CanCast(_R) then
    		CastSpellToPos(hero.x, hero.z, _R)
    	end
    	CastSpellToPos(myHero.x, myHero.z, _E)
    end
end

function Varus:OnUpdate()
	--self.R.range = 1050 + 300 * myHero.LevelSpell(_R)
    --self.W.range = 680 + 130 * myHero.LevelSpell(_W)

    --[[GetAllBuffNameActive(myHero.Addr)
		for i,v in pairs(pBuffName) do
		__PrintDebug(tostring(v))
	end]]
	if (IsDead(myHero.Addr) or myHero.IsRecall or IsTyping() or IsDodging()) then return end
	SetLuaCombo(true)

	if self._chargedCastedT + 4.5 < GetTimeGame() then
		self.Charging = false
	end

	local timecasting = GetTimeGame() - self.CastTime
	local range = self:CalcQRange(timecasting)

	if CanCast(_Q) and self.autoQ and not IsAttacked() then
		self:LogicQ();
	end

	if CanCast(_E) and self.autoE and not IsAttacked() then
		self:LogicE();
	end

	if CanCast(_R) and not IsAttacked() then
		local TargetR = GetTargetSelector(self.R.range, 1)
	    if GetKeyPress(self.useR) > 0 and IsValidTarget(TargetR, self.R.range) then
	    	target = GetAIHero(TargetR)
	    	local CastPosition, HitChance, Position = self:GetRLinePreCore(target)
	    	if HitChance >= 6 then
	    		CastSpellToPos(CastPosition.x, CastPosition.z, _R)
	    	end
	    end
	    if self.autoR then
			self:LogicR();
		end
	end

	self:AutoER()

	
	--[[if self.Charging and GetKeyPress(self.Combo) == 0 then
		local timecasting = GetTimeGame() - self.CastTime
		local range = self:CalcQRange2(timecasting)
		local TargetQ = GetTargetSelector(2000, 1)
		if TargetQ ~= 0 then
			target = GetAIHero(TargetQ)
			local CastPosition, HitChance, Position = self:GetQLinePreCore(target)
			if HitChance >= 6 and range > GetDistance(target) + 200 then
				ReleaseSpellToPos(CastPosition.x, CastPosition.z, _Q)
			end
			if HitChance >= 6 and GetDistance(target) < GetTrueAttackRange() then
				ReleaseSpellToPos(CastPosition.x, CastPosition.z, _Q)
			end
		end
	end]]
end

--[[function Varus:OnTick()
	if (IsDead(myHero.Addr) or myHero.IsRecall or IsTyping() or IsDodging()) then return end
	SetLuaCombo(true)

	if CanCast(_Q) and self.autoQ then
		self:LogicQ();
	end

	if CanCast(_W) and self.autoW then
		self:LogicW();
	end

	if CanCast(_E) and self.autoE then
		self:LogicE();
	end

	if CanCast(_R) then
		local TargetR = GetTargetSelector(self.R.range, 1)
	    if GetKeyPress(self.useR) > 0 and IsValidTarget(TargetR, self.R.range) then
	    	target = GetAIHero(TargetR)
	    	local CastPosition, HitChance, Position = self:GetRCirclePreCore(target)
	    	if HitChance >= self:HitChanceManager(self.rHC) then
	    		CastSpellToPos(CastPosition.x, CastPosition.z, _R)
	    	end
	    end
	    if self.autoR then
			self:LogicR();
		end
	end

	self:AutoQER()

	if self.Enalble_Mod_Skin then
		ModSkin(self.Set_Skin)
	end
end]]

function Varus:CanMoveOrb(extraWindup)
    return GetTimeGame() + self:GamePing() > GetLastBATick() + GetWindupBA(myHero.Addr) + extraWindup --self.menu_advanced_delayWindup.getValue() /1000
end

function Varus:CanHarras()
	local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
	if not self:IsUnderTurretEnemy(myHeroPos) then
		return true
	end
	return false
end

function Varus:LogicQ()
	local timecasting = GetTimeGame() - self.CastTime
	local range = self:CalcQRange(timecasting)

	--[[for i,hero in pairs(GetEnemyHeroes()) do
		if hero ~= nil then
			target = GetAIHero(hero)
			if IsValidTarget(target.Addr, 1600) and self:GetQDmg(target) > target.HP then
				local CastPosition, HitChance, Position = self:GetQLinePreCore(target)
				self:CastQ(target, CastPosition, HitChance)
			end
		end
	end]]

	if self.maxQ and range < 1600 then --and CountEnemyChampAroundObject(myHero.Addr, GetTrueAttackRange()) == 0 then --and not self.Charging then
		return
	end

	local TargetQ = GetTargetSelector(self.Q.maxrange, 1)
	if TargetQ ~= 0 then
		target = GetAIHero(TargetQ)
		--local CastPosition, HitChance, Position = self:GetQLinePreCore(target)
		if (CountEnemyChampAroundObject(myHero.Addr, 800) == 0 and self.qonly and self:GetPassiveCount(target) > 0) or myHero.LevelSpell(_E) == 0 then
			if GetKeyPress(self.Combo) > 0 then
				self:CastQ(target)
			end
		else
			if GetKeyPress(self.Combo) > 0 and ((CountEnemyChampAroundObject(myHero.Addr, 800) == 0 and GetDistance(target) > GetTrueAttackRange()) or myHero.LevelSpell(_E) == 0) and not self.qonly then
				self:CastQ(target)
			end
		end
		if not self.Charging and GetDistance(target) < GetTrueAttackRange() then
			local CastPosition, HitChance, Position = self:GetQLinePreCore(target)
	    	if HitChance >= 4 then
	    		ReleaseSpellToPos(CastPosition.x, CastPosition.z, _Q)
	    	end
		end
	end

	local target = 0
	if GetType(GetTargetOrb()) == 0 then
		target = GetAIHero(GetTargetOrb())
		if GetKeyPress(self.Combo) > 0 then
			if self:GetPassiveCount(target) >= 3 then
				self:CastQ(target)
			end
		end
	end

	for i,hero in pairs(GetEnemyHeroes()) do
		if IsValidTarget(hero, self.Q.maxrange - 200) then
			enemy = GetAIHero(hero)
			--local CastPosition, HitChance, Position = self:GetQLinePreCore(enemy)
			if self:GetPassiveCount(enemy) >= self.wCount then				
				self:CastQ(enemy)
			end
			--[[if self.ts_prio[i].Menu then	    			    	
			    if IsValidTarget(enemy, self.Q.maxrange) then
			    	__PrintTextGame(tostring(enemy.NetworkId == self.ts_prio[i].Enemy.NetworkId))
			    	if enemy.NetworkId == self.ts_prio[i].Enemy.NetworkId and GetDistance(enemy) > GetTrueAttackRange() and self:CanHarras() then				    						
			    		self:CastQ(enemy, CastPosition, HitChance)
			    	end
			    end
			end]]
			if self:GetQDmg(enemy) > enemy.HP then
				self:CastQ(enemy)
			end

			if not self:CanMove(enemy) then --and self.Charging then
				self:CastQ(enemy)
				--ReleaseSpellToPos(enemy.x, enemy.z, _Q)
			end
		end
	end
end

function Varus:LogicE()
	local TargetE = GetTargetSelector(self.E.range, 1)
	if TargetE ~= 0 then
		target = GetAIHero(TargetE)
		local CastPosition, HitChance, Position = self:GetECirclePreCore(target)
		if CountEnemyChampAroundObject(myHero.Addr, 800) == 0 and GetDistance(target) < GetTrueAttackRange() then
			if GetKeyPress(self.Combo) > 0 and HitChance >= 6 then
				CastSpellToPos(CastPosition.x, CastPosition.z, _E)
			end
		end
	end

	for i,hero in pairs(GetEnemyHeroes()) do
		if IsValidTarget(hero, self.E.range - 100) then
			enemy = GetAIHero(hero)
			local CastPosition, HitChance, Position = self:GetECirclePreCore(enemy)
			if not self:CanMove(enemy) then
				CastSpellToPos(enemy.x, enemy.z, _Q)
			end

			if self:GetPassiveCount(enemy) >= self.wCount and HitChance >= 6 then				
				CastSpellToPos(CastPosition.x, CastPosition.z, _E)
			end

			if self:GetEDmg(enemy) > enemy.HP and HitChance >= 6 then
				CastSpellToPos(CastPosition.x, CastPosition.z, _E)
			end

			if IsValidTarget(enemy.Addr, 270) and enemy.IsMelee and HitChance >= 6 then
				CastSpellToPos(CastPosition.x, CastPosition.z, _E)
			end
		end
	end
end

function Varus:LogicR()
	local TargetR = GetTargetSelector(self.R.range, 1)
	if TargetR ~= 0 then
		target = GetAIHero(TargetR)
		local CastPosition, HitChance, Position = self:GetRLinePreCore(target)
		if CountEnemyChampAroundObject(myHero.Addr, 800) == 0 and CountEnemyChampAroundObject(target.Addr, 400) >= self.rCount then
			if GetKeyPress(self.Combo) > 0 and HitChance >= 6 then
				CastSpellToPos(CastPosition.x, CastPosition.z, _R)
			end
		end
	end

	for i,hero in pairs(GetEnemyHeroes()) do
		if IsValidTarget(hero, self.R.range - 100) then
			enemy = GetAIHero(hero)
			local CastPosition, HitChance, Position = self:GetRLinePreCore(enemy)
			if not self:CanMove(enemy) and CountAllyChampAroundObject(myHero.Addr , 600) > 0 and GetDistance(enemy) < self.R.range - 300 then
				CastSpellToPos(enemy.x, enemy.z, _R)
			end

			if self:GetPassiveCount(enemy) >= self.wCount and HitChance >= 6 and CanCast(_Q) and (self:GetRDmg(enemy) + self:GetQDmg(enemy) > enemy.HP) then				
				CastSpellToPos(CastPosition.x, CastPosition.z, _R)
			end

			if self:GetRDmg(enemy) > enemy.HP and HitChance >= 6 then
				CastSpellToPos(CastPosition.x, CastPosition.z, _R)
			end

			if IsValidTarget(enemy.Addr, 270) and enemy.IsMelee and HitChance >= 6 then
				CastSpellToPos(CastPosition.x, CastPosition.z, _R)
			end
		end
	end
	--- dont under turrent

end


function Varus:ValidUlt(unit)
	if CountBuffByType(unit.Addr, 16) == 1 or CountBuffByType(unit.Addr, 15) == 1 or CountBuffByType(unit.Addr, 17) == 1 or unit.HasBuff("kindredrnodeathbuff") or CountBuffByType(unit.Addr, 4) == 1 then
		return false
	end
	return true
end

function Varus:AutoER()
	for i,hero in pairs(GetEnemyHeroes()) do
		if hero ~= nil then
			target = GetAIHero(hero)
			if IsValidTarget(target, 2000) then
				local TargetDashing, CanHitDashing, DashPosition = vpred:IsDashing(target, 0.25, 65, 2000, myHero)
				if DashPosition ~= nil then
			    	if GetDistance(DashPosition) <= self.E.range  - 100 and CanCast(_E) then
			    		CastSpellToPos(DashPosition.x, DashPosition.z, _E)
			    	end
				end
			end
		end
	end
end

function Varus:farmQ()

end

function Varus:DrawQRange()
	if self.Charging then
		local timecasting = GetTimeGame() - self.CastTime
		local range = self:CalcQRange(timecasting)

		DrawCircleGame(myHero.x , myHero.y, myHero.z, range, Lua_ARGB(255,255,0,0))
	else
		DrawCircleGame(myHero.x , myHero.y, myHero.z, self.Q.minrange, Lua_ARGB(255,255,0,0))
	end
end

function Varus:OnDraw()
	if self.menu_Draw_Already then
		if self.menu_Draw_Q and self.Q:IsReady() then
			--DrawCircleGame(myHero.x , myHero.y, myHero.z, self.Q.maxrange, Lua_ARGB(255,255,0,0))
		end
		if self.menu_Draw_E and self.E:IsReady() then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.E.range, Lua_ARGB(255,0,255,0))
		end
		if self.menu_Draw_R and self.R:IsReady() then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.R.range, Lua_ARGB(255,255,0,0))
		end
	else
		if self.menu_Draw_Q then
			self:DrawQRange()
			--aa = (1 / (self.CastTime - GetTimeGame())) * self.Q.speed + self.Q.maxrange
			--if --aa >= self.Q2.range then
				--aa = self.Q2.range
			--end
			--DrawCircleGame(myHero.x , myHero.y, myHero.z, aa, Lua_ARGB(255,255,0,0))
		end
		if self.menu_Draw_E then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.E.range, Lua_ARGB(255,0,255,0))
		end
		if self.menu_Draw_R then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.R.range, Lua_ARGB(255,255,0,0))
		end
	end
end

function Varus:OnProcessSpell(unit, spell)
	local spellName = spell.Name:lower()

	if unit.IsMe then
		if spell.Name == "VarusQ" or spell.Name == "VarusE" or spell.Name == "VarusR" then
			--self.CastTime = GetTimeGame();
            --self.CanCast = false;
		end
	end
end

function Varus:OnDoCast(unit, spell)
	local spellName = spell.Name:lower()
	if unit.IsMe then
		--__PrintTextGame(spell.Name)
		if spell.Name == "VarusQ" or spell.Name == "VarusE" or spell.Name == "VarusR" then
			self.CastTime = GetTimeGame();
            self.CanCast = false;
            --self.Charging = true
		end
	end
end

function Varus:OnPlayAnimation(unit, anim)
	if unit.IsMe then
			--__PrintDebug(anim)
			if anim == "Spell1" then
				self._chargedCastedT = GetTimeGame()
				self.Charging = true
			end

			if anim == "Spell1_Fire" then
				self.Charging = false
			end
	end
end

function Varus:IsCharging()
	if not CanCast(_Q) then
		return false
	end
	if myHero.HasBuff("VarusQ") then --or GetTimeGame() - self.CastTime < 0.3 + GetLatency() then
		return true
	end
	return false
end

function Varus:GetQEndTime()
	if GetBuffByName(myHero.Addr, "VarusQ") > 0 then
		local stack = GetBuff(GetBuffByName(myHero.Addr, "VarusQ"))
		return stack.EndT - GetTimeGame()
	else
		return 0
	end
end

function Varus:GetPassiveCount(target)
	if target.HasBuff("VarusWDebuff") then
		local stack = GetBuff(GetBuffByName(target.Addr, "VarusWDebuff"))
		return stack.Stacks
	end
	return 0
end

function Varus:CalcQRange(timer)
	local rangediff = self.Q.maxrange - self.Q.minrange
	local min = self.Q.minrange

	local total = rangediff / 1.4 * timer + min

	if total > self.Q.maxrange then total = self.Q.maxrange end

	return total
end

function Varus:CalcQRange2(timer)
	local rangediff = self.Q.maxrange - self.Q.minrange
	local min = self.Q.minrange

	local total = rangediff / 1.4 * timer + min

	--if total > self.Q.maxrange then total = self.Q.maxrange end

	return total
end

function Varus:CastQ(target)
	--__PrintTextGame(tostring(target))
	local CastPosition, HitChance, Position = self:GetQLinePreCore(target)
	local timecasting = GetTimeGame() - self.CastTime
	local range = self:CalcQRange(timecasting)
	if not self.Charging then
		if IsValidTarget(target.Addr, self.Q.maxrange) then
			CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
		end
	else
		if GetDistance(CastPosition) < range - 350 and self.fastQ and HitChance >= 6 then
			ReleaseSpellToPos(CastPosition.x, CastPosition.z, _Q)
		elseif range == self.Q.maxrange and GetDistance(CastPosition) < range - 350 and HitChance >= 6 then
			ReleaseSpellToPos(CastPosition.x, CastPosition.z, _Q)
		elseif GetDistance(target) < GetTrueAttackRange() and HitChance >= 6 then
			ReleaseSpellToPos(CastPosition.x, CastPosition.z, _Q)
		else
			for i, heros in ipairs(GetEnemyHeroes()) do
				if heros ~= nil then
					local targetQ = GetAIHero(heros)
					if IsValidTarget(targetQ.Addr, GetTrueAttackRange()) then
						local CastPosition, HitChance, Position = self:GetQLinePreCore(targetQ)
						if HitChance >= 5 then
							--__PrintTextGame("1111111111111111")
							ReleaseSpellToPos(CastPosition.x, CastPosition.z, _Q)
						end
					end
				end
			end
			--__PrintTextGame("string szText")
			--[[local TargetQ = GetTargetSelector(GetTrueAttackRange(), 1)
			if TargetQ ~= 0 then
				targetQ = GetAIHero(TargetQ)
				local CastPosition, HitChance
				local CastPosition, HitChance, Position = self:GetQLinePreCore(targetQ)
				if HitChance >= 5 and GetDistance(targetQ) < 1800 then
					--__PrintTextGame("1111111111111111")
					ReleaseSpellToPos(CastPosition.x, CastPosition.z, _Q)
				end
			end]]
			return;
		end		
	end
end

function Varus:GetWDmg(target, state)
	if target.HasBuff("VarusWDebuff") then
		return self:GetPassiveCount(target) * GetDamage("W", target, state)
	end
	return 0
end

function Varus:GetQDmg(target)
	if target.HasBuff("VarusWDebuff") then
		return self:GetWDmg(target, 2) + GetDamage("Q", target, 1)
	end
	if self.Charging then
		local timecasting = GetTimeGame() - self.CastTime
		local range = self:CalcQRange(timecasting)

		return GetDamage("Q", target, 2)
	else
		return GetDamage("Q", target, 1)
	end
	return GetDamage("Q", target, 1)
end

function Varus:GetEDmg(target)
	if target.HasBuff("VarusWDebuff") then
		return self:GetWDmg(target, 2) + GetDamage("E", target)
	end
	return GetDamage("E", target)
end

function Varus:GetRDmg(target)
	if target.HasBuff("VarusWDebuff") then
		return self:GetWDmg(target, 2) + GetDamage("R", target)
	end
	return GetDamage("R", target)
end

function Varus:IsImmobileTarget(unit)
	if (CountBuffByType(unit, 5) == 1 or CountBuffByType(unit, 11) == 1 or CountBuffByType(unit, 29) == 1 or CountBuffByType(unit, 24) == 1 or CountBuffByType(unit, 10) == 1 or CountBuffByType(unit, 29) == 1) then
		return true
	end
	return false
end

function Varus:CanMove(unit)
	if (unit.MoveSpeed < 50 or CountBuffByType(unit.Addr, 5) == 1 or CountBuffByType(unit.Addr, 21) == 1 or CountBuffByType(unit.Addr, 11) == 1 or CountBuffByType(unit.Addr, 29) == 1 or
		unit.HasBuff("recall") or CountBuffByType(unit.Addr, 30) == 1 or CountBuffByType(unit.Addr, 22) == 1 or CountBuffByType(unit.Addr, 8) == 1 or CountBuffByType(unit.Addr, 24) == 1
		or CountBuffByType(unit.Addr, 20) == 1 or CountBuffByType(unit.Addr, 18) == 1) then
		return false
	end
	return true
end

function Varus:CheckWalls(enemyPos)
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

function Varus:IsUnderTurretEnemy(pos)			--Will Only work near myHero
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

function Varus:IsUnderAllyTurret(pos)
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

function Varus:CountEnemiesInRange(pos, range)
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

function Varus:CirclePoints(CircleLineSegmentN, radius, position)
  local points = {}
  for i = 1, CircleLineSegmentN, 1 do
    local angle = i * 2 * math.pi / CircleLineSegmentN
    local point = Vector(position.x + radius * math.cos(angle), position.y + radius * math.sin(angle), position.z);
    table.insert(points, point)
  end
  return points
end

function Varus:CastDash(asap)
    asap = asap and asap or false
    local DashMode = self.E_Mode
    local bestpoint = Vector(0, 0, 0)
    local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)

    if DashMode == 0 then
    	bestpoint = myHeroPos:Extended(GetMousePos(), self.E.range)
    end

    if DashMode == 1 then
    	local orbT = GetTargetOrb()
    	if orbT ~= nil and GetType(orbT) == 0 then
	    	target = GetAIHero(orbT)
		    local startpos = Vector(myHero.x, myHero.y, myHero.z)
		    local endpos = Vector(target.x, target.y, target.z)
		    local dir = (endpos - startpos):Normalized()
		    local pDir = dir:Perpendicular()
		    local rightEndPos = endpos + pDir * GetDistance(orbT)
		    local leftEndPos = endpos - pDir * GetDistance(orbT)
		    local rEndPos = Vector(rightEndPos.x, rightEndPos.y, myHero.z)
		    local lEndPos = Vector(leftEndPos.x, leftEndPos.y, myHero.z);
		    if GetDistance(GetMousePos(), rEndPos) < GetDistance(GetMousePos(), lEndPos) then
		        bestpoint = myHeroPos:Extended(rEndPos, self.E.range);
		    else
		        bestpoint = myHeroPos:Extended(lEndPos, self.E.range);
		    end
   		end
  	end

    if DashMode == 2 then
	    points = self:CirclePoints(15, self.E.range, myHeroPos)
	    bestpoint = myHeroPos:Extended(GetMousePos(), self.E.range);
	    local enemies = self:CountEnemiesInRange(bestpoint, 350)

	    for i, point in pairs(points) do
		    local count = self:CountEnemiesInRange(point, 350)
		    if not self:InAARange(point) then
			  	if self:IsUnderAllyTurret(point) then
			        bestpoint = point;
			        enemies = count - 1;
			    elseif count < enemies then
			        enemies = count;
			        bestpoint = point;
			    elseif count == enemies and GetDistance(GetMousePos(), point) < GetDistance(GetMousePos(), bestpoint) then
			        enemies = count;
			        bestpoint = point;
			  	end
		    end
		end
  	end

  	if bestpoint == Vector(0, 0, 0) then
    	return Vector(0, 0, 0)
  	end

  	local isGoodPos = self:IsGoodPosition(bestpoint)

  	if asap and isGoodPos then
    	return bestpoint
  	elseif isGoodPos and self:InAARange(bestpoint) then
    	return bestpoint
  	end
  	return Vector(0, 0, 0)
end

function Varus:InAARange(point)
  --if not "AAcheck" then
    --return true
  --end
  if self.targetslector ~= nil and GetType(GetTargetOrb()) == 0 then
    --local targetpos = GetPos(orbwalk:GetTargetOrb())
    local target = GetAIHero(GetTargetOrb())
    local targetpos = Vector(target.x, target.y, target.z)
    return GetDistance(point, targetpos) < GetTrueAttackRange()
  else
    return self:CountEnemiesInRange(point, GetTrueAttackRange()) > 0
  end
end

function Varus:IsGoodPosition(dashPos)
	local segment = self.E.range / 5;
	local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
	for i = 1, 5, 1 do
		pos = myHeroPos:Extended(dashPos, i * segment)
		if IsWall(pos.x, pos.y, pos.z) then
			return false
		end
	end

	if self:IsUnderTurretEnemy(dashPos) then
		return false
	end

	local enemyCheck = 2 --Config.Item("EnemyCheck", true).GetValue<Slider>().Value;
    local enemyCountDashPos = self:CountEnemiesInRange(dashPos, 600);
    if enemyCheck > enemyCountDashPos then
    	return true
    end
    local enemyCountPlayer = CountEnemyChampAroundObject(myHero.Addr, 400)
    if enemyCountDashPos <= enemyCountPlayer then
    	return true
    end

    return false
end
