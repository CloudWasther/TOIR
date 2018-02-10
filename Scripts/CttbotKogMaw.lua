IncludeFile("Lib\\TOIR_SDK.lua")

KogMaw = class()

function OnLoad()
	--if GetChampName(GetMyChamp()) == "KogMaw" then
		KogMaw:__init()
	--end
end

function KogMaw:__init()
	if myHero.CharName ~= "KogMaw" then
        return;
    end
	-- VPrediction
	vpred = VPrediction(true)
	AntiGap = AntiGapcloser(nil)
	--TS
    --self.menu_ts = TargetSelector(1750, 0, myHero, true, true, true)


    self.Q = Spell(_Q, 1300)
    self.W = Spell(_W, 1150)
    self.E = Spell(_E, 1350)
    self.R = Spell(_R, 1350)

    self.Q:SetSkillShot(0.25, 2000, 50, true)
    self.E:SetSkillShot(0.25, 1400, 120, true)
    self.W:SetSkillShot()
    self.R:SetSkillShot(1.2, 2000, 120, true)

    self.OverKill = 0
    self.tickIndex = 0
    self.ts_prio = {}
    self.attackNow = false

	Callback.Add("Tick", function(...) self:OnTick(...) end)
	--Callback.Add("AfterAttack", function(...) self:OnAfterAttack(...) end)
    --Callback.Add("BeforeAttack", function(...) self:OnBeforeAttack(...) end)
    Callback.Add("Update", function(...) self:OnUpdate(...) end)	
    Callback.Add("Draw", function(...) self:OnDraw(...) end)
    Callback.Add("AntiGapClose", function(target, EndPos) self:OnAntiGapClose(target, EndPos) end)
    Callback.Add("DrawMenu", function(...) self:OnDrawMenu(...) end)
    self:MenuValueDefault()
end

function KogMaw:MenuValueDefault()
	self.menu = "KogMaw_Magic"
	self.Draw_When_Already = self:MenuBool("Draw When Already", false)
	self.menu_Draw_Q = self:MenuBool("Draw Q Range", false)
	self.menu_Draw_W = self:MenuBool("Draw W Range", false)
	self.menu_Draw_E = self:MenuBool("Draw E Range", false)
	self.menu_Draw_R = self:MenuBool("Draw R Range", false)

	self.autoQ = self:MenuBool("Auto Q", true)
	self.Qend = self:MenuBool("Auto Q EndDash", true)
	
	self.autoW = self:MenuBool("Auto W", true)
	--self.Eend = self:MenuBool("Harass W on max range", true)

	self.autoE = self:MenuBool("Auto E", true)
	self.harassE = self:MenuBool("Harass E", true)
	self.AGC = self:MenuBool("AntiGapcloser E", true)
	self.Eend = self:MenuBool("Auto E EndDash", true)

	self.autoR = self:MenuBool("Auto R KS", true)	
	self.useR = self:MenuKeyBinding("Semi-manual cast R key", 84)
	self.RmaxHp = self:MenuSliderInt("Target max % HP", 50)
	self.comboStack = self:MenuSliderInt("Max combo stack R", 2)
	self.harasStack = self:MenuSliderInt("Max haras stack R", 1)
	self.Rcc = self:MenuBool("R cc", true)
	self.Rslow = self:MenuBool("R slow", true)
	self.Raoe = self:MenuBool("R aoe", true)
	self.Raa = self:MenuBool("R only out off AA range", true)
	self.Rend = self:MenuBool("Auto R EndDash", true)
	self.rHC = self:MenuComboBox("R HitChance", 3)
	for i, enemy in pairs(GetEnemyHeroes()) do
        table.insert(self.ts_prio, { Enemy = GetAIHero(enemy), Menu = self:MenuBool(GetAIHero(enemy).CharName, true)})
    end

	self.sheen = self:MenuBool("Sheen logic", true)
	self.AApriority = self:MenuBool("AA priority over spell", true)

	self.Enalble_Mod_Skin = self:MenuBool("Enalble Mod Skin", false)
	self.Set_Skin = self:MenuSliderInt("Set Skin", 9)

	self.Combo = self:MenuKeyBinding("Combo", 32)
	self.Harass = self:MenuKeyBinding("Harass", 67)
	self.Lane_Clear = self:MenuKeyBinding("Lane Clear", 86)
	self.Last_Hit = self:MenuKeyBinding("Last Hit", 88)
end

function KogMaw:OnDrawMenu()
	if Menu_Begin(self.menu) then
		if Menu_Begin("Setting Q") then
			self.autoQ = Menu_Bool("Auto Q", self.autoQ, self.menu)		
			self.Qend = Menu_Bool("Auto Q EndDash", self.Qend, self.menu)	
			Menu_End()
		end

		if Menu_Begin("Setting W") then
			self.autoW = Menu_Bool("Auto W", self.autoW, self.menu)
			--self.harassW = Menu_Bool("Harass W", self.harassW, self.menu)
			Menu_End()
		end

		if Menu_Begin("Setting E") then
			self.autoE = Menu_Bool("Auto E", self.autoE, self.menu)
			self.harassE = Menu_Bool("Harass E", self.harassE, self.menu)	
			self.AGC = Menu_Bool("AntiGapcloser E", self.AGC, self.menu)	
			self.Eend = Menu_Bool("Auto E EndDash", self.Eend, self.menu)
			Menu_End()
		end

		if Menu_Begin("Setting R") then
			self.autoR = Menu_Bool("Auto R KS", self.autoR, self.menu)
			self.useR = Menu_KeyBinding("Semi-manual cast R key", self.useR, self.menu)
			self.RmaxHp = Menu_SliderInt("Target max % HP", self.RmaxHp, 0, 100, self.menu)
			self.comboStack = Menu_SliderInt("Max combo stack R", self.comboStack, 0, 10, self.menu)
			self.harasStack = Menu_SliderInt("Max haras stack R", self.harasStack, 0, 10, self.menu)
			self.Rcc = Menu_Bool("R cc", self.Rcc, self.menu)
			self.Rslow = Menu_Bool("R slow", self.Rslow, self.menu)
			self.Raoe = Menu_Bool("R aoe", self.Raoe, self.menu)
			self.Raa = Menu_Bool("R only out off AA range", self.Raa, self.menu)
			self.Rend = Menu_Bool("Auto R EndDash", self.Rend, self.menu)
			Menu_Text("Auto R Harass :")
			for i, enemy in pairs(GetEnemyHeroes()) do
            	self.ts_prio[i].Menu = Menu_Bool(GetAIHero(enemy).CharName, self.ts_prio[i].Menu, self.menu)
        	end
			self.rHC = Menu_ComboBox("R HitChance", self.rHC, "Low\0Medium\0High\0Very High\0\0", self.menu)
			Menu_End()
		end

		if Menu_Begin("Extra") then
			self.sheen = Menu_Bool("Sheen logic", self.sheen, self.menu)
			self.AApriority = Menu_Bool("AA priority over spell", self.AApriority, self.menu)
			Menu_End()
		end

		if Menu_Begin("Draw Spell") then
			self.Draw_When_Already = Menu_Bool("Draw When Already", self.Draw_When_Already, self.menu)
			self.menu_Draw_Q = Menu_Bool("Draw Q Range", self.menu_Draw_Q, self.menu)
			self.menu_Draw_W = Menu_Bool("Draw W Range", self.menu_Draw_W, self.menu)
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

function KogMaw:MenuBool(stringKey, bool)
	return ReadIniBoolean(self.menu, stringKey, bool)
end

function KogMaw:MenuSliderInt(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function KogMaw:MenuSliderFloat(stringKey, valueDefault)
	return ReadIniFloat(self.menu, stringKey, valueDefault)
end

function KogMaw:MenuComboBox(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function KogMaw:MenuKeyBinding(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function KogMaw:HitChanceManager(hc)
	return (hc + 3)
end

function KogMaw:GetQLinePreCore(target)
	local castPosX, castPosZ, unitPosX, unitPosZ, hitChance, _aoeTargetsHitCount = GetPredictionCore(target.Addr, 0, self.Q.delay, self.Q.width, self.Q.range, self.Q.speed, myHero.x, myHero.z, false, true, 1, 0, 5, 5, 5, 5)
	if target ~= nil then
		 CastPosition = Vector(castPosX, target.y, castPosZ)
		 HitChance = hitChance
		 Position = Vector(unitPosX, target.y, unitPosZ)
		 return CastPosition, HitChance, Position
	end
	return nil , 0 , nil
end

function KogMaw:GetELinePreCore(target)
	local castPosX, castPosZ, unitPosX, unitPosZ, hitChance, _aoeTargetsHitCount = GetPredictionCore(target.Addr, 0, self.E.delay, self.E.width, self.E.range, self.E.speed, myHero.x, myHero.z, false, false, 1, 5, 5, 5, 5, 5)
	if target ~= nil then
		 CastPosition = Vector(castPosX, target.y, castPosZ)
		 HitChance = hitChance
		 Position = Vector(unitPosX, target.y, unitPosZ)
		 return CastPosition, HitChance, Position
	end
	return nil , 0 , nil
end

function KogMaw:GetRCirclePreCore(target)
	local castPosX, castPosZ, unitPosX, unitPosZ, hitChance, _aoeTargetsHitCount = GetPredictionCore(target.Addr, 1, self.R.delay, self.R.width, self.R.range, self.R.speed, myHero.x, myHero.z, false, false, 1, 5, 5, 5, 5, 5)
	if target ~= nil then
		 CastPosition = Vector(castPosX, target.y, castPosZ)
		 HitChance = hitChance
		 Position = Vector(unitPosX, target.y, unitPosZ)
		 return CastPosition, HitChance, Position
	end
	return nil , 0 , nil
end

function KogMaw:OnBeforeAttack(target)
	self.attackNow = false;
end

function KogMaw:OnAfterAttack(unit, target)
	self.attackNow = true;
	if CanCast(_W) and GetType(GetTargetById(target.Id)) == 1 and myHero.MP > 400 then
		
	end
end

function KogMaw:OnAntiGapClose(target, EndPos)
	hero = GetAIHero(target.Addr)
    if GetDistance(EndPos) < 500 or GetDistance(hero) < 500 and myHero.MP > 120 then
    	if self.AGC and CanCast(_E) then
    		CastSpellToPos(hero.x, hero.z, _E)
    	end 
    end
end

function KogMaw:OnUpdate()
	self.R.range = 1050 + 300 * myHero.LevelSpell(_R)
    self.W.range = 680 + 130 * myHero.LevelSpell(_W)

    --[[GetAllBuffNameActive(myHero.Addr)
		for i,v in pairs(pBuffName) do
		__PrintDebug(tostring(v))				      
	end]]
end

function KogMaw:OnTick()
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
		self:LogicR();
	end

	self:AutoQER()

	if self.Enalble_Mod_Skin then
		ModSkin(self.Set_Skin)
	end		
end

function KogMaw:LaneClear()
	if CanCast(_Q) and (GetType(GetTargetOrb()) == 3) and self.jungQ then
		if (GetObjName(GetTargetOrb()) ~= "PlantSatchel" and GetObjName(GetTargetOrb()) ~= "PlantHealth" and GetObjName(GetTargetOrb()) ~= "PlantVision") then
			target = GetUnit(GetTargetOrb())
	    	local CastPosition, HitChance, Position = self:GetQLinePreCore(target)
	    	if HitChance > 2 then
				CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
			end
		end
	end
end


function KogMaw:CanMoveOrb(extraWindup)
    return GetTimeGame() + self:GamePing() > GetLastBATick() + GetWindupBA(myHero.Addr) + extraWindup --self.menu_advanced_delayWindup.getValue() /1000
end

function KogMaw:CanHarras()
	local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
	if not self:IsUnderTurretEnemy(myHeroPos) then
		return true
	end
	return false
end

function KogMaw:LogicQ()
	if self:Sheen() then
		local TargetQ = GetTargetSelector(self.Q.range - 100, 0)
		if TargetQ ~= 0 then
			target = GetAIHero(TargetQ)	
			local qDmg = GetDamage("Q", target)
			local eDmg = GetDamage("E", target)
			local CastPosition, HitChance, Position = self:GetQLinePreCore(target)
			if IsValidTarget(target.Addr, self.W.range) and qDmg + eDmg > target.HP and HitChance >= 6 then
				CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
			elseif GetKeyPress(self.Combo) > 0 and myHero.MP > 200 and HitChance >= 6 then
				CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
			end
		end
	end
	for i,hero in pairs(GetEnemyHeroes()) do
		if hero ~= nil then
			target = GetAIHero(hero)
			if IsValidTarget(target, self.Q.range - 100) and not self:CanMove(target) then
				local Collision = CountCollision(myHero.x, myHero.z, target.x, target.z, self.Q.delay, self.Q.width, self.Q.range, self.Q.speed, 0, 5, 5, 5, 5)
				if Collision == 0 then
					CastSpellToPos(target.x, target.z, _Q)
				end
			end
		end
	end
end

function KogMaw:LogicW()
	if CountEnemyChampAroundObject(myHero.Addr, self.W.range) > 0 and self:Sheen() then
		if GetKeyPress(self.Combo) > 0 then
			CastSpellTarget(myHero.Addr, _W)
		end
	end
end

function KogMaw:LogicE()
	if self:Sheen() then
		local TargetE = GetTargetSelector(self.E.range - 100, 0)
		if TargetE ~= 0 then
			target = GetAIHero(TargetE)	
			local qDmg = GetDamage("Q", target)
			local eDmg = GetDamage("E", target)
			local CastPosition, HitChance, Position = self:GetELinePreCore(target)
			if eDmg > target.HP and HitChance >= 6 then
				CastSpellToPos(CastPosition.x, CastPosition.z, _E)
			elseif qDmg + eDmg > target.HP and CanCast(_Q) and HitChance >= 6 then
				CastSpellToPos(CastPosition.x, CastPosition.z, _E)
			elseif GetKeyPress(self.Combo) > 0 and myHero.MP > 160 and HitChance >= 6 then
				CastSpellToPos(CastPosition.x, CastPosition.z, _E)
			end
		end
	end
	for i,hero in pairs(GetEnemyHeroes()) do
		if hero ~= nil then
			target = GetAIHero(hero)
			if IsValidTarget(target, self.E.range - 100) and not self:CanMove(target) then
				CastSpellToPos(target.x, target.z, _E)
			end
		end
	end
end

function KogMaw:LogicR()
	if self.autoR and self:Sheen() then
		local TargetR = GetTargetSelector(3000, 0)
		if TargetR ~= 0 then
			target = GetAIHero(TargetR)
			if IsValidTarget(target.Addr, self.R.range - 100) and target.HP / target.MaxHP < self.RmaxHp / 100 and self:ValidUlt(target) then
				local CastPosition, HitChance, Position = self:GetRCirclePreCore(target) 
				if self.Raa and GetDistance(Vector(target)) < GetTrueAttackRange() then
					return
				end
				--__PrintTextGame(tostring(self:GetRStacks() < self.comboStack))
				local Rdmg = self:Rdmg(target)
				Rdmg = Rdmg + CountEnemyChampAroundObject(target.Addr, 500) * Rdmg
				--__PrintTextGame(tostring(self:Rdmg(target)))
				if self:Rdmg(target) > target.HP and HitChance >= self:HitChanceManager(self.rHC) then
					CastSpellToPos(CastPosition.x, CastPosition.z, _R)
				elseif GetKeyPress(self.Combo) > 0 and Rdmg * 2 > target.HP and myHero.MP > 150 and HitChance >= self:HitChanceManager(self.rHC) then
					CastSpellToPos(CastPosition.x, CastPosition.z, _R)
				end

				if (GetBuffByName(target.Addr, "slow") > 0 or CountBuffByType(target.Addr, 10) == 1) and self.Rslow and self:GetRStacks() < self.comboStack + 1 and myHero.MP > 200 and HitChance >= self:HitChanceManager(self.rHC) then
					CastSpellToPos(CastPosition.x, CastPosition.z, _R)
				elseif GetKeyPress(self.Combo) > 0 and self:GetRStacks() < self.comboStack and myHero.MP > 200 and HitChance >= self:HitChanceManager(self.rHC) then
					CastSpellToPos(CastPosition.x, CastPosition.z, _R)
				end
			end
		end
	end

	for i,hero in pairs(GetEnemyHeroes()) do
		if hero ~= nil then
			target = GetAIHero(hero)
			local CastPosition, HitChance, Position = self:GetRCirclePreCore(target)
			if IsValidTarget(target, self.R.range - 100) and not self:CanMove(target) then
				if self:GetRStacks() < self.comboStack + 2 and myHero.MP > 200 then
					--CastSpellToPos(target.x, target.z, _R)
				end
			end
			if IsValidTarget(target, self.R.range - 100) then
				--__PrintTextGame(tostring(self:Rdmg(target)))
				if self:Rdmg(target) > target.HP and HitChance >= self:HitChanceManager(self.rHC) then
					CastSpellToPos(CastPosition.x, CastPosition.z, _R)
				end
			end
			if self.ts_prio[i].Menu then	    			    	
		    	if IsValidTarget(target.Addr, self.R.range) then
		    		if target.NetworkId == self.ts_prio[i].Enemy.NetworkId and self:CanHarras() then				    
						if HitChance >= self:HitChanceManager(self.rHC) and self:GetRStacks() < self.harasStack and myHero.MP > 200 and HitChance >= self:HitChanceManager(self.rHC) then
					        CastSpellToPos(CastPosition.x, CastPosition.z, _R)
					    end
					end
		    	end
		    end
		end
	end
end

function KogMaw:GetRStacks()
	if GetBuffByName(myHero.Addr, "kogmawlivingartillerycost") ~= 0 then
		local stack = GetBuff(GetBuffByName(myHero.Addr, "kogmawlivingartillerycost"))
		return stack.Stacks
	end
	return 0
end

function KogMaw:Sheen()
	local hero = GetTargetOrb()
	if hero ~= 0 then		
		target = GetAIHero(hero)
		if GetType(target.Addr) ~= 0 then
			self.attackNow = true;
		end
		if IsValidTarget(target.Addr, self.W.range) and myHero.HasBuff("sheen") and self.sheen and target.Type == 0 then
			return false
		elseif IsValidTarget(target.Addr, self.W.range) and self.AApriority and target.Type == 0 and not self.attackNow then
			return false	
		end
	end
	return true
end

--(({100, 140, 180})[level] + 0.65 * source.BonusDmg + 0.25 * source.MagicDmg) * (GetPercentHP(target.Addr) < 25 and 3 or (GetPercentHP(target.Addr) < 50 and 2 or 1)) end},
function KogMaw:Rdmg(target)
	if target ~= 0 and CanCast(_R) then
		local DamageAD = {100, 140, 180}
		Damage = DamageAD[myHero.LevelSpell(_R)] + 0.65 * myHero.BonusDmg + 0.25 * myHero.MagicDmg
		targetHPpercent = target.HP / target.MaxHP * 100

		if targetHPpercent < 40 then
			return myHero.CalcDamage(target.Addr, Damage * 2)
		else
			return myHero.CalcDamage(target.Addr, Damage)
		end
	end
	return 0
end


function KogMaw:ValidUlt(unit)
	if CountBuffByType(unit.Addr, 16) == 1 or CountBuffByType(unit.Addr, 15) == 1 or CountBuffByType(unit.Addr, 17) == 1 or unit.HasBuff("kindredrnodeathbuff") or CountBuffByType(unit.Addr, 4) == 1 then
		return false
	end
	return true
end

function KogMaw:AutoQER()
	for i,hero in pairs(GetEnemyHeroes()) do
		if hero ~= nil then
			target = GetAIHero(hero)
			if IsValidTarget(target, 2000) then
				local TargetDashing, CanHitDashing, DashPosition = vpred:IsDashing(target, 0.25, 65, 2000, myHero)
				if DashPosition ~= nil then
					local Collision = CountCollision(myHero.x, myHero.z, DashPosition.x, DashPosition.z, self.Q.delay, self.Q.width, self.Q.range, self.Q.speed, 0, 5, 5, 5, 5)
			    	if GetDistance(DashPosition) <= self.Q.range - 100 and Collision == 0 and CanCast(_Q) and self.Qend then
			    		CastSpellToPos(DashPosition.x, DashPosition.z, _Q)
			    	end

			    	if GetDistance(DashPosition) <= self.E.range  - 100 and CanCast(_E) and self.Eend then
			    		CastSpellToPos(DashPosition.x, DashPosition.z, _E)
			    	end

			    	if GetDistance(DashPosition) <= self.R.range  - 100 and CanCast(_R) and self.Rend then
			    		CastSpellToPos(DashPosition.x, DashPosition.z, _R)
			    	end
				end			
			end
		end
	end
end

function KogMaw:farmQ()
	--local orbTarget = GetTargetOrb()
	--if orbTarget ~= nil and GetType(orbTarget) == 1 then	
		GetAllUnitAroundAnObject(myHero.Addr, self.Q.range)	
		for i, obj in ipairs(pUnit) do
			if obj ~= 0  then
				--__PrintTextGame(tostring(obj))
	            local minion = GetUnit(obj)
	            if IsEnemy(minion.Addr) and not IsDead(minion.Addr) and not IsInFog(minion.Addr) and GetType(minion.Addr) == 1 then
	            	if IsValidTarget(minion, self.Q.range) and GetDistance(Vector(minion)) > GetTrueAttackRange() and self.FQ then

						local delay = GetDistance(minion) / self.Q.speed + self.Q.delay
						local hpPred = GetHealthPred(minion.Addr, delay, 0.07)
						local QPos, QHitChance = HPred:GetPredict(self.HPred_Q_M, minion, myHero)						
						--__PrintTextGame(tostring(GetSpellDamage(_Q, minion)))
						if hpPred > 0 and hpPred < GetDamage("Q", minion) then --GetSpellDamage(_Q, minion) then
							--local CastPosition, HitChance, Position, AOE = self:GetQLinePreCore(minion)
							if QHitChance >= 0 then
								CastSpellToPos(QPos.x, QPos.z, _Q)
							end
						end
					end
	            end
	        end
        end
    --end
end

function KogMaw:OnDraw()
	if self.menu_Draw_Already then
		if self.menu_Draw_Q then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.Q.range, Lua_ARGB(255,255,0,0))
		end
		if self.menu_Draw_W and self.W:IsReady() then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.W.range, Lua_ARGB(255,255,0,0))
		end
		if self.menu_Draw_E and self.E:IsReady() then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.E.range, Lua_ARGB(255,0,255,0))
		end
		if self.menu_Draw_R and self.R:IsReady() then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.R.range, Lua_ARGB(255,255,0,0))
		end
	else
		if self.menu_Draw_Q then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.Q.range, Lua_ARGB(255,255,0,0))
		end
		if self.menu_Draw_W then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.W.range, Lua_ARGB(255,255,0,0))
		end
		if self.menu_Draw_E then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.E.range, Lua_ARGB(255,0,255,0))
		end
		if self.menu_Draw_R then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.R.range, Lua_ARGB(255,255,0,0))
		end
	end
end

function KogMaw:OnProcessSpell(unit, spell)
	local spellName = spell.Name:lower()
	if unit.IsMe then
		--__PrintDebug(spell.Name)
	end	
end

function KogMaw:IsImmobileTarget(unit)
	if (CountBuffByType(unit, 5) == 1 or CountBuffByType(unit, 11) == 1 or CountBuffByType(unit, 29) == 1 or CountBuffByType(unit, 24) == 1 or CountBuffByType(unit, 10) == 1 or CountBuffByType(unit, 29) == 1) then
		return true
	end
	return false
end

function KogMaw:CanMove(unit)
	if (unit.MoveSpeed < 50 or CountBuffByType(unit.Addr, 5) == 1 or CountBuffByType(unit.Addr, 21) == 1 or CountBuffByType(unit.Addr, 11) == 1 or CountBuffByType(unit.Addr, 29) == 1 or
		unit.HasBuff("recall") or CountBuffByType(unit.Addr, 30) == 1 or CountBuffByType(unit.Addr, 22) == 1 or CountBuffByType(unit.Addr, 8) == 1 or CountBuffByType(unit.Addr, 24) == 1
		or CountBuffByType(unit.Addr, 20) == 1 or CountBuffByType(unit.Addr, 18) == 1) then
		return false
	end
	return true
end

function KogMaw:CheckWalls(enemyPos)
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

function KogMaw:IsUnderTurretEnemy(pos)			--Will Only work near myHero
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

function KogMaw:IsUnderAllyTurret(pos)
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

function KogMaw:CountEnemiesInRange(pos, range)
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

function KogMaw:CirclePoints(CircleLineSegmentN, radius, position)
  local points = {}
  for i = 1, CircleLineSegmentN, 1 do
    local angle = i * 2 * math.pi / CircleLineSegmentN
    local point = Vector(position.x + radius * math.cos(angle), position.y + radius * math.sin(angle), position.z);
    table.insert(points, point)
  end
  return points
end

function KogMaw:CastDash(asap)
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

function KogMaw:InAARange(point)
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

function KogMaw:IsGoodPosition(dashPos)
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
