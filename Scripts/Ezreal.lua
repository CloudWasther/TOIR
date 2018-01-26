IncludeFile("Lib\\TOIR_SDK.lua")

Ezreal = class()

function OnLoad()
	if GetChampName(GetMyChamp()) == "Ezreal" then
		Ezreal:__init()
	end
end

function Ezreal:__init()
	-- VPrediction
	vpred = VPrediction(true)
	HPred = HPrediction()
	--TS
    --self.menu_ts = TargetSelector(1750, 0, myHero, true, true, true)


    self.Q = Spell(_Q, 1300)
    self.W = Spell(_W, 1150)
    self.E = Spell(_E, 550)
    self.R = Spell(_R, 3000)

    self.Q:SetSkillShot(0.25, 2000, 60, true)
    self.W:SetSkillShot(0.25, 1600, 80, true)
    self.E:SetSkillShot()
    self.R:SetSkillShot(1.1, 2000, 160, true)

    self.OverKill = 0
    self.tickIndex = 0
    self.ts_prio = {}

	Callback.Add("Tick", function(...) self:OnTick(...) end)
	Callback.Add("Update", function(...) self:OnUpdate(...) end)	
    Callback.Add("Draw", function(...) self:OnDraw(...) end)
    --Callback.Add("ProcessSpell", function(...) self:OnProcessSpell(...) end)
    --Callback.Add("BeforeAttack", function(...) self:OnBeforeAttack(...) end)
    --Callback.Add("NewPath", function(...) self:OnNewPath(...) end)
    --Callback.Add("CreateObject", function(...) self:OnCreateObject(...) end)
    Callback.Add("DrawMenu", function(...) self:OnDrawMenu(...) end)
    Callback.Add("UpdateBuff", function(unit, buff, stacks) self:OnUpdateBuff(source, unit, buff, stacks) end)
    Callback.Add("AfterAttack", function(...) self:OnAfterAttack(...) end)
    self:MenuValueDefault()
end

function Ezreal:MenuValueDefault()
	self.menu = "Ezreal_Magic"
	self.Draw_When_Already = self:MenuBool("Draw When Already", true)
	self.menu_Draw_Q = self:MenuBool("Draw Q Range", false)
	self.menu_Draw_W = self:MenuBool("Draw W Range", false)
	self.menu_Draw_E = self:MenuBool("Draw E Range", false)
	self.menu_Draw_R = self:MenuBool("Draw R Range", false)

	self.stack = self:MenuBool("Stack Tear if full mana", true)
	self.jungQ = self:MenuBool("Jungle Q", true)
	self.FQ = self:MenuBool("Farm Q out range last hit", true)
	self.qHC = self:MenuComboBox("Q HitChance", 1)
	self.PredicMode = self:MenuComboBox("Prediction Mode", 0)
	for i, enemy in pairs(GetEnemyHeroes()) do
        table.insert(self.ts_prio, { Enemy = GetAIHero(enemy), Menu = self:MenuBool(GetAIHero(enemy).CharName, true)})
    end
	self.HarassManaQ = self:MenuSliderInt("Harass Q Mana", 30)

	self.autoW = self:MenuBool("Auto W", true)
	self.wPush = self:MenuBool("W ally (push tower)", true)
	self.harassW = self:MenuBool("Harass W", true)
	self.HarassManaW = self:MenuSliderInt("Harass W Mana", 30)
	self.wHC = self:MenuSliderFloat("W HitChane", 1.5)

	self.smartEW = self:MenuKeyBinding("SmartCast E + W key", 84)
	self.EKsCombo = self:MenuBool("E ks combo", true)
	self.EAntiMelee = self:MenuBool("E anti-melee", true)
	self.autoEgrab = self:MenuBool("Auto E anti grab", true)
	self.E_Mode = self:MenuComboBox("E Mode", 2)

	self.autoR = self:MenuBool("Auto R KS", true)
	self.Rcc = self:MenuBool("R cc", true)
	--self.Raoe = self:MenuBool("R AOE", true)
	self.useR = self:MenuKeyBinding("Semi-manual cast R key", 84)
	self.Rturrent = self:MenuBool("Don't R under turret", true)
	self.MaxRangeR = self:MenuSliderInt("Max R range", 3000)
	self.MinRangeR = self:MenuSliderInt("Min R range", 900)


	self.Enalble_Mod_Skin = self:MenuBool("Enalble Mod Skin", false)
	self.Set_Skin = self:MenuSliderInt("Set Skin", 18)

	self.Combo = self:MenuKeyBinding("Combo", 32)
	self.Harass = self:MenuKeyBinding("Harass", 67)
	self.Lane_Clear = self:MenuKeyBinding("Lane Clear", 86)
	self.Last_Hit = self:MenuKeyBinding("Last Hit", 88)
end

function Ezreal:OnDrawMenu()
	if Menu_Begin(self.menu) then
		if Menu_Begin("Setting Q") then
			self.stack = Menu_Bool("Stack Tear if full mana", self.stack, self.menu)
			self.jungQ = Menu_Bool("Jungle Q", self.jungQ, self.menu)
			self.FQ = Menu_Bool("Farm Q out range last hit", self.FQ, self.menu)
			self.qHC = Menu_ComboBox("Q HitChance", self.qHC, "Low\0Medium\0High\0Very High\0\0", self.menu)
			self.PredicMode = Menu_ComboBox("Prediction Mode", self.PredicMode, "VPrediction\0HPrediction\0CorePrediction (not yet)\0\0", self.menu)	
			Menu_Text("Harass Enemy")
			for i, enemy in pairs(GetEnemyHeroes()) do
            	self.ts_prio[i].Menu = Menu_Bool(GetAIHero(enemy).CharName, self.ts_prio[i].Menu, self.menu)
        	end
			self.HarassManaQ = Menu_SliderInt("Harass Q Mana", self.HarassManaQ, 0, 100, self.menu)				
			Menu_End()
		end

		if Menu_Begin("Setting W") then
			self.autoW = Menu_Bool("Auto W", self.autoW, self.menu)
			self.wPush = Menu_Bool("W ally (push tower)", self.wPush, self.menu)
			self.harassW = Menu_Bool("Harass W", self.harassW, self.menu)
			self.HarassManaW = Menu_SliderInt("Harass W Mana", self.HarassManaW, 0, 100, self.menu)
			self.wHC = Menu_SliderFloat("W HitChane", self.wHC, 1, 3, self.menu)
			Menu_End()
		end

		if Menu_Begin("Setting E") then
			self.smartEW = Menu_KeyBinding("SmartCast E + W key", self.smartEW, self.menu)
			self.EKsCombo = Menu_Bool("E ks combo", self.EKsCombo, self.menu)
			self.EAntiMelee = Menu_Bool("E anti-melee", self.EAntiMelee, self.menu)
			self.autoEgrab = Menu_Bool("Auto E anti grab", self.autoEgrab, self.menu)
			self.E_Mode = Menu_ComboBox("E Mode", self.E_Mode, "Mouse\0Side\0Safe position\0\0\0", self.menu)		
			Menu_End()
		end

		if Menu_Begin("Setting R") then
			self.autoR = Menu_Bool("Auto R KS", self.autoR, self.menu)
			self.Rcc = Menu_Bool("R cc", self.Rcc, self.menu)
			--self.Raoe = Menu_Bool("R AOE", self.Raoe, self.menu)
			self.useR = Menu_KeyBinding("Semi-manual cast R key", self.useR, self.menu)
			self.Rturrent = Menu_Bool("Don't R under turret", self.Rturrent, self.menu)
			self.MaxRangeR = Menu_SliderInt("Max R range", self.MaxRangeR, 0, 3000, self.menu)
			self.MinRangeR = Menu_SliderInt("Min R range", self.MinRangeR, 0, 3000, self.menu)
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

function Ezreal:MenuBool(stringKey, bool)
	return ReadIniBoolean(self.menu, stringKey, bool)
end

function Ezreal:MenuSliderInt(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Ezreal:MenuSliderFloat(stringKey, valueDefault)
	return ReadIniFloat(self.menu, stringKey, valueDefault)
end

function Ezreal:MenuComboBox(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Ezreal:MenuKeyBinding(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Ezreal:HitChanceManager(hc)
	if self.PredicMode == 0 then
		return hc 
	end
	if self.PredicMode == 1 then
		return hc
	end
	return 0
end

function Ezreal:OnUpdateBuff(source, unit, buff, stacks)
	
	if unit.IsMe and self.autoEgrab and CanCast(_E) then
		--__PrintTextGame(tostring(buff.Name))
		if buff.Name == "rocketgrab2" then
			
			local dashPos = self:CastDash(true);
			if dashPos ~= Vector(0, 0, 0) then
				--__PrintTextGame("111111111111111")
				DelayAction(function() CastSpellToPos(dashPos.x,dashPos.z, _E) end, 0.3)
				
			else
				--__PrintTextGame("2222222222222")
				DelayAction(function() CastSpellToPos(dashPos.x,dashPos.z, _E) end, 0.3)
			end
		end
	end
end

function Ezreal:OnAfterAttack(unit, target)
	if CanCast(_W) and self.wPush and GetType(GetTargetById(target.Id)) == 2 and myHero.MP > 400 then
		for i,hero in pairs(GetAllyHeroes()) do
			if hero ~= nil then
				ally = GetAIHero(hero)
				if not ally.IsMe and not ally.IsDead and GetDistance(ally.Addr) < 600 then
					CastSpellToPos(ally.x, ally.z, _W)
				end
			end
		end
	end
end

function Ezreal:OnTick()
	self.tickIndex = self.tickIndex + 1
    if (self.tickIndex > 4) then
        self.tickIndex = 0;
    end

	if myHero.IsDead then return end
	SetLuaCombo(true)

	self.HPred_Q_M = HPSkillshot({type = "DelayLine", delay = self.Q.delay, range = self.Q.range, speed = self.Q.speed, collisionH = false, collisionM = true, width = self.Q.width})
	self.HPred_W_M = HPSkillshot({type = "DelayLine", delay = self.W.delay, range = self.W.range, speed = self.W.speed, width = self.W.width})
	self.HPred_R_M = HPSkillshot({type = "DelayLine", delay = self.R.delay, range = self.R.range, speed = self.R.speed, width = self.R.width})

	--self:LogicSmiteJungle()

	if CanCast(_E) then
		--if self:LagFree(0) then
			self:LogicE();
		--end
		if GetKeyPress(self.smartEW) > 0 and CanCast(_W) then
			CastSpellToPos(GetMousePos().x, GetMousePos().z, _W)
			castE = Vector(myHero.x, myHero.y, myHero.z):Extended(GetMousePos(), self.E.range)
			CastSpellToPos(castE.x, castE.z, _E)
		end
	end

	if GetKeyPress(self.Lane_Clear) > 0 then
		self:LaneClear()
	end

	self:AntiGapCloser()
	self:AutoQW()

	if CanCast(_Q) then
		self:LogicQ()
	end

	if --[[self:LagFree(3) and]] CanCast(_W) and self.autoW then
		self:LogicW();
	end

	if --[[self:LagFree(4) and]] CanCast(_R) then
		local TargetR = GetTargetSelector(self.R.range, 1)
	    if GetKeyPress(self.useR) > 0 and IsValidTarget(TargetR, self.R.range) then
	    	CastSpellTarget(TargetR, _R)
	    end
		self:LogicR();
	end

	if self.Enalble_Mod_Skin then
		ModSkin(self.Set_Skin)
	end		
end


function Ezreal:LaneClear()
	if CanCast(_Q) and (GetType(GetTargetOrb()) == 3) and self.jungQ then
		if (GetObjName(GetTargetOrb()) ~= "PlantSatchel" and GetObjName(GetTargetOrb()) ~= "PlantHealth" and GetObjName(GetTargetOrb()) ~= "PlantVision") then
			target = GetUnit(GetTargetOrb())
	    	local CastPosition, HitChance, Position = vpred:GetLineCastPosition(target, self.Q.delay, self.Q.width, self.Q.range, self.Q.speed, myHero, false)
			CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
		end
	end
end

function Ezreal:OnUpdate()
	--self.tickIndex = self.tickIndex + 1
    --if (self.tickIndex > 4) then
        --self.tickIndex = 0;
    --end
end


function Ezreal:CanMoveOrb(extraWindup)
    return GetTimeGame() + self:GamePing() > GetLastBATick() + GetWindupBA(myHero.Addr) + extraWindup --self.menu_advanced_delayWindup.getValue() /1000
end

function Ezreal:LagFree(offset)
    if self.tickIndex == offset then
    	return true
    else
    	return false
    end
    return false
end

function Ezreal:GamePing()
    return GetLatency() / 2000
end

function Ezreal:bonusRange()
	return (670 + GetBoundingRadius(myHero.Addr) + 25 * myHero.LevelSpell(_Q))
end

function Ezreal:GetRealPowPowRange(target)
	return (620 + GetBoundingRadius(myHero.Addr) + GetBoundingRadius(target.Addr))
end

function Ezreal:GetRealDistance(target)
	local targetPos = Vector(target.x, target.y, target.z)
	return (GetDistance(targetPos) + GetBoundingRadius(myHero.Addr) + GetBoundingRadius(target.Addr))
end

function Ezreal:LogicQ()
    	if GetKeyPress(self.Combo) > 0 and myHero.MP > 130 then
    		local TargetQ = GetTargetSelector(self.Q.range - 150, 1)
			if CanCast(_Q) and TargetQ ~= 0 then
				target = GetAIHero(TargetQ)
				local QPos, QHitChance = HPred:GetPredict(self.HPred_Q_M, target, myHero)
				local CastPosition, HitChance, Position = vpred:GetLineCastPosition(target, self.Q.delay, self.Q.width, self.Q.range, self.Q.speed, myHero, true)
		    	if HitChance >= self:HitChanceManager(self.qHC) then
		    		if self.PredicMode == 0 then
		        		CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
		        	end
		        end
		        if QHitChance >= self:HitChanceManager(self.qHC) then
		        	if self.PredicMode == 1 then
		        		CastSpellToPos(QPos.x, QPos.z, _Q)
		        	end
		        end
    		end
    	end

    	for i, heros in ipairs(GetEnemyHeroes()) do
			if heros ~= nil then
				local target = GetAIHero(heros)	
				local QPos, QHitChance = HPred:GetPredict(self.HPred_Q_M, target, myHero)
				local CastPosition, HitChance, Position = vpred:GetLineCastPosition(target, self.Q.delay, self.Q.width, self.Q.range, self.Q.speed, myHero, true)
			    if self.ts_prio[i].Menu then	    			    	
			    	if IsValidTarget(target.Addr, self.Q.range - 150) then
			    		if target.NetworkId == self.ts_prio[i].Enemy.NetworkId and myHero.MP / myHero.MaxMP * 100 > self.HarassManaQ and self:CanHarras() then				    						
							if HitChance >= self.qHC then
								if self.PredicMode == 0 then
								    CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
								end
							end
							if QHitChance >= self.qHC then
								if self.PredicMode == 1 then
								    CastSpellToPos(QPos.x, QPos.z, _Q)
								end
							end 
						end
			    	end
			    end

				local wDmg = GetDamage("W", target)
				local qDmg = GetDamage("Q", target)
				local QPos, QHitChance = HPred:GetPredict(self.HPred_Q_M, target, myHero)
				local CastPosition, HitChance, Position = vpred:GetLineCastPosition(target, self.Q.delay, self.Q.width, self.Q.range, self.Q.speed, myHero, true)
				if IsValidTarget(target.Addr, self.Q.range - 150) then
					if (qDmg + wDmg > target.HP) then 
				    	if HitChance >= self:HitChanceManager(self.qHC) then
				    		if self.PredicMode == 0 then
				        		CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
				        	end
				        end
				        if QHitChance >= self:HitChanceManager(self.qHC) then
				        	if self.PredicMode == 1 then
				        		CastSpellToPos(QPos.x, QPos.z, _Q)
				        	end
				        end	
				    elseif (qDmg > target.HP) then
				    	if HitChance >= 2 then
				    		if self.PredicMode == 0 then
				        		CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
				        	end
				        end
				        if QHitChance >= 2 then
				        	if self.PredicMode == 1 then
				        		CastSpellToPos(QPos.x, QPos.z, _Q)
				        	end
				        end	
					end
					if not self:CanMove(target) and IsValidTarget(target.Addr, self.Q.range - 150) then
						local Collision = CountObjectCollision(0, target.Addr, myHero.x, myHero.z, target.x, target.z, self.Q.width, self.Q.range, 65)
				    	if Collision == 0 then
				        	CastSpellToPos(target.x, target.z, _Q)
				        end
					end

					if QHitChance >= 3 then
			        	CastSpellToPos(QPos.x, QPos.z, _Q)
			        end 
			        if HitChance >= 5 then
			        	CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
			        end 
				end				
			end
		end

		if myHero.MP > 30 and GetKeyPress(self.Lane_Clear) > 0 then
			self:farmQ();
		elseif self.stack and CanCast(_Q) and not myHero.HasBuff("recall") and myHero.MP > myHero.MaxMP * 0.95 and (GetItemByID(3070) > 0 or GetItemByID(3004) > 0 or GetItemByID(3003) > 0) and CountEnemyChampAroundObject(myHero.Addr, 1000) == 0 then
			pos = Vector(myHero):Extended(GetMousePos(), 500)
			CastSpellToPos(pos.x, pos.z, _Q)
		end
    --end
end

function Ezreal:CanHarras()
	local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
	if not self:IsUnderTurretEnemy(myHeroPos) then
		return true
	end
	return false
end

function Ezreal:LogicW()
	local TargetW = GetTargetSelector(self.W.range - 150, 0)
	if CanCast(_W) and TargetW ~= 0 then
		target = GetAIHero(TargetW)
		local WPos, WHitChance = HPred:GetPredict(self.HPred_W_M, target, myHero)
		--local CastPosition, HitChance, Position = vpred:GetLineCastPosition(target, self.W.delay, self.W.width, self.W.range, self.W.speed, myHero, false)
		if GetKeyPress(self.Combo) > 0 and myHero.MP > 240 and WHitChance >= self.wHC then
			CastSpellToPos(WPos.x, WPos.z, _W)
		elseif GetKeyPress(self.Harass) > 0 and self.harassW and myHero.MP > myHero.MaxMP * 0.8 and self:CanHarras() then
			CastSpellToPos(WPos.x, WPos.z, _W)
		else
			local wDmg = GetDamage("W", target)
			local qDmg = GetDamage("Q", target)
			if wDmg > target.HP and WHitChance >= self.wHC then
				CastSpellToPos(WPos.x, WPos.z, _W)
				self.OverKill = GetTimeGame()
			elseif (wDmg + qDmg > target.HP and CanCast(_Q)) and WHitChance >= self.wHC then
				CastSpellToPos(WPos.x, WPos.z, _W)
			end
		end
	end

	if myHero.MP > 240 then
		for i,hero in pairs(GetEnemyHeroes()) do
			if hero ~= nil then
				target = GetAIHero(hero)
				if IsValidTarget(target, self.W.range - 150) and not self:CanMove(target) then
					CastSpellToPos(target.x, target.z, _W)
				end

				if IsValidTarget(target.Addr, self.W.range - 150) then
					local WPos, WHitChance = HPred:GetPredict(self.HPred_W_M, target, myHero)
					if WHitChance >= 3 then
			        	CastSpellToPos(WPos.x, WPos.z, _W)
			        end 
				end	
			end
		end
	end
end

function Ezreal:LogicE()
	local TargetE = GetTargetSelector(1300, 0)
	if CanCast(_E) and TargetE ~= 0 then
		target = GetAIHero(TargetE)
		if self.EAntiMelee then
			for i,hero in pairs(GetEnemyHeroes()) do
				if hero ~= nil then
					target = GetAIHero(hero)
					--local CastPosition, HitChance, Position = vpred:GetLineCastPosition(target, 0.2, self.W.width, self.W.range, self.W.speed, myHero, false)
					if IsValidTarget(target.Addr, 1000) and target.IsMelee and GetDistance(target.Addr) < 250 then
						local dashPos = self:CastDash(true);
						if dashPos ~= Vector(0, 0, 0) then
							CastSpellToPos(dashPos.x,dashPos.z, _E)
						end
					end
				end
			end
		end
		local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
		if IsValidTarget(target.Addr, self.E.range + GetTrueAttackRange()) and GetKeyPress(self.Combo) > 0 and self.EKsCombo and myHero.HP / myHero.MaxHP > 0.4 and GetDistance(target.Addr, GetMousePos()) + 300 < GetDistance(target.Addr) and
		 GetDistance(target.Addr) > GetTrueAttackRange() and (GetTimeGame() - self.OverKill) > 0.3 and not self:IsUnderTurretEnemy(myHeroPos) then
		 	local dashPosition = myHeroPos:Extended(GetMousePos(), self.E.range)
		 	if self:CountEnemiesInRange(dashPosition, 900) < 3 then
		 		local dmgCombo = 0
		 		if IsValidTarget(target.Addr, 950) then
		 			dmgCombo = GetAADamageHitEnemy(target.Addr) + GetDamage("E", target)
		 		end
		 		if CanCast(_Q) and myHero.MP > 120 then
		 			dmgCombo = GetDamage("Q", target)
		 		end
		 		if CanCast(_W) and myHero.MP > 170 then
		 			dmgCombo = dmgCombo + GetDamage("W", target)
		 		end
		 		if dmgCombo > target.HP and self:ValidUlt(target) then
		 			CastSpellToPos(dashPosition.x, dashPosition.z, _E)
			        self.OverKill = GetTimeGame()
		 		end
		 	end
		end
	end
end

function Ezreal:LogicR()
	local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
	if self:IsUnderTurretEnemy(myHeroPos) and self.Rturrent then
		return
	end
	if self.autoR and self:CountEnemiesInRange(myHeroPos, 800) == 0 and GetTimeGame() - self.OverKill > 0.6 then
		for i,hero in pairs(GetEnemyHeroes()) do
			if hero ~= nil then
				target = GetAIHero(hero)
				--local CastPosition, HitChance, Position = vpred:GetLineCastPosition(target, self.R.delay, self.R.width, self.MaxRangeR, self.R.speed, myHero, false)			
				if IsValidTarget(target.Addr, self.MaxRangeR) and self:ValidUlt(target) then
					local RPos, RHitChance = HPred:GetPredict(self.HPred_R_M, target, myHero)
					if self.Rcc and IsValidTarget(target.Addr, self.Q.range + self.E.range) and target.HP < myHero.MaxHP and not self:CanMove(target) then
						CastSpellToPos(target.x,target.z, _R)
					end
					if GetDamage("R", target) > target.HP and CountEnemyChampAroundObject(target.Addr, 500) == 0 and GetDistance(RPos) > self.MinRangeR then
						if RHitChance > 2 then
							CastSpellToPos(RPos.x,RPos.z, _R)
						end
					end 
					--if GetKeyPress(self.Combo) > 0 and CountEnemyChampAroundObject(target.Addr, 1200) == 0 and self.Raoe then
						--CastSpellToPos(CastPosition.x,CastPosition.z, _R)
					--end
				end
			end
		end
	end
end

function Ezreal:ValidUlt(unit)
	if CountBuffByType(unit.Addr, 16) == 1 or CountBuffByType(unit.Addr, 15) == 1 or CountBuffByType(unit.Addr, 17) == 1 or unit.HasBuff("kindredrnodeathbuff") or CountBuffByType(unit.Addr, 4) == 1 then
		return false
	end
	return true
end

function Ezreal:AutoQW()
	for i,hero in pairs(GetEnemyHeroes()) do
		if hero ~= nil then
			target = GetAIHero(hero)
			if IsValidTarget(target, self.Q.range) then
				local TargetDashing, CanHitDashing, DashPosition = vpred:IsDashing(target, self.Q.delay, self.Q.width, self.Q.speed, myHero, false)

				if DashPosition ~= nil then
					local Collision = CountObjectCollision(0, target.Addr, myHero.x, myHero.z, DashPosition.x, DashPosition.z, self.Q.width, self.Q.range, 65)
			    	if GetDistance(DashPosition) <= self.Q.range and Collision == 0 then
			    		CastSpellToPos(DashPosition.x, DashPosition.z, _Q)
			    	end
				end			
			end

			if IsValidTarget(target, self.W.range) then
				local TargetDashing, CanHitDashing, DashPosition = vpred:IsDashing(target, self.W.delay, self.W.width, self.W.speed, myHero, false)
			    if DashPosition ~= nil then
			    	if GetDistance(DashPosition) <= self.W.range then
			    		CastSpellToPos(DashPosition.x, DashPosition.z, _W)
			    	end
				end			
			end
		end
	end
end

function Ezreal:farmQ()

	local orbTarget = GetTargetOrb()
	if orbTarget ~= nil and GetType(orbTarget) == 1 then		
		for i, minions in ipairs(self:EnemyMinionsTbl()) do
			if minions ~= nil then
				local minion = GetUnit(minions)
				--__PrintTextGame(tostring(GetIndex(orbTarget)))
				if IsValidTarget(minion.Addr, self.Q.range) and GetDistance(minion.Addr) > GetTrueAttackRange() and minion.NetworkId ~= GetIndex(orbTarget) and self.FQ then

					local delay = GetDistance(orbTarget) / self.Q.speed + self.Q.delay
					local hpPred = GetHealthPred(minion.Addr, delay, 0.07)
					local QPos, QHitChance = HPred:GetPredict(self.HPred_Q_M, minion, myHero)
					--__PrintTextGame(tostring(delay))
					if hpPred > 0 and hpPred < GetDamage("Q", minion) and QHitChance > 0 then
						CastSpellToPos(QPos.x, QPos.z, _Q)
					end
				end
			end
		end
	end
end
function Ezreal:EnemyMinionsTbl()
    GetAllUnitAroundAnObject(myHero.Addr, 2000)
    local result = {}
    for i, obj in pairs(pUnit) do
        if obj ~= 0  then
            local minions = GetUnit(obj)
            if IsEnemy(minions.Addr) and not IsDead(minions.Addr) and not IsInFog(minions.Addr) and (GetType(minions.Addr) == 1 or GetType(minions.Addr) == 2) then
                table.insert(result, minions.Addr)
            end
        end
    end
    return result
end

function Ezreal:OnDraw()
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

	local TargetQ = GetTargetSelector(self.Q.range - 150, 0)
	if CanCast(_Q) and TargetQ ~= 0 then
		target = GetAIHero(TargetQ)
		local QPos, QHitChance = HPred:GetPredict(self.HPred_Q_M, target, myHero)
		if QPos ~= nil then
			DrawCircleGame(QPos.x , QPos.y, QPos.z, 200, Lua_ARGB(255,255,0,0))
		end
	end
end

function Ezreal:OnProcessSpell(unit, spell)
	local spellName = spell.Name:lower()
	if unit.IsMe then
		--__PrintDebug(spell.Name)
	end	
end


function Ezreal:AntiGapCloser()
	for i, heros in pairs(GetEnemyHeroes()) do
    	if heros ~= nil then
      		local hero = GetAIHero(heros)
      		--if hero.IsDash then
        		local TargetDashing, CanHitDashing, DashPosition = vpred:IsDashing(hero, 0.09, 65, 2000, myHero, false)
        		local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
        		if DashPosition ~= nil then
          			if GetDistance(DashPosition) < 400 and CanCast(_E) then
          				points = self:CirclePoints(10, self.E.range, myHeroPos)
	    				bestpoint = myHeroPos:Extended(DashPosition, - self.E.range);
	    				local enemies = self:CountEnemiesInRange(bestpoint, self.E.range)
	    				for i, point in pairs(points) do
	    					local count = self:CountEnemiesInRange(point, self.E.range)
	    					if count < enemies then
	    						enemies = count;
                            	bestpoint = point;
                            elseif count == enemies and GetDistance(GetMousePos(), point) < GetDistance(GetMousePos(), bestpoint) then
                            	enemies = count;
                            	bestpoint = point;
	    					end
	    				end
	    				if self:IsGoodPosition(bestpoint) then   
                        	CastSpellToPos(bestpoint.x,bestpoint.z, _E)     				
          				end
          			end
        		end
      		--end
    	end
	end
end

function Ezreal:IsImmobileTarget(unit)
	if (CountBuffByType(unit, 5) == 1 or CountBuffByType(unit, 11) == 1 or CountBuffByType(unit, 29) == 1 or CountBuffByType(unit, 24) == 1 or CountBuffByType(unit, 10) == 1 or CountBuffByType(unit, 29) == 1) then
		return true
	end
	return false
end

function Ezreal:CanMove(unit)
	if (unit.MoveSpeed < 50 or CountBuffByType(unit.Addr, 5) == 1 or CountBuffByType(unit.Addr, 21) == 1 or CountBuffByType(unit.Addr, 11) == 1 or CountBuffByType(unit.Addr, 29) == 1 or
		unit.HasBuff("recall") or CountBuffByType(unit.Addr, 30) == 1 or CountBuffByType(unit.Addr, 22) == 1 or CountBuffByType(unit.Addr, 8) == 1 or CountBuffByType(unit.Addr, 24) == 1
		or CountBuffByType(unit.Addr, 20) == 1 or CountBuffByType(unit.Addr, 18) == 1) then
		return false
	end
	return true
end

function Ezreal:CheckWalls(enemyPos)
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

function Ezreal:IsUnderTurretEnemy(pos)			--Will Only work near myHero
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

function Ezreal:IsUnderAllyTurret(pos)
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

function Ezreal:CountEnemiesInRange(pos, range)
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

function Ezreal:CirclePoints(CircleLineSegmentN, radius, position)
  local points = {}
  for i = 1, CircleLineSegmentN, 1 do
    local angle = i * 2 * math.pi / CircleLineSegmentN
    local point = Vector(position.x + radius * math.cos(angle), position.y + radius * math.sin(angle), position.z);
    table.insert(points, point)
  end
  return points
end

function Ezreal:CastDash(asap)
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

function Ezreal:InAARange(point)
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

function Ezreal:IsGoodPosition(dashPos)
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

function Ezreal:AntiGapCloser()
	for i, heros in pairs(GetEnemyHeroes()) do
    	if heros ~= nil then
      		local hero = GetAIHero(heros)
      		if hero.IsDash then
        		local TargetDashing, CanHitDashing, DashPosition = vpred:IsDashing(hero, 0.09, 65, 2000, myHero, false)
        		local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
        		if DashPosition ~= nil then
          			if GetDistance(DashPosition) < 400 and CanCast(_E) then
          				points = self:CirclePoints(10, self.E.range, myHeroPos)
	    				bestpoint = myHeroPos:Extended(DashPosition, - self.E.range);
	    				local enemies = self:CountEnemiesInRange(bestpoint, self.E.range)
	    				for i, point in pairs(points) do
	    					local count = self:CountEnemiesInRange(point, self.E.range)
	    					if count < enemies then
	    						enemies = count;
                            	bestpoint = point;
                            elseif count == enemies and GetDistance(GetMousePos(), point) < GetDistance(GetMousePos(), bestpoint) then
                            	enemies = count;
                            	bestpoint = point;
	    					end
	    				end
	    				if self:IsGoodPosition(bestpoint) then   
                        	CastSpellToPos(bestpoint.x,bestpoint.z, _E)     				
          				end
          			end
        		end
      		end
    	end
	end
end
