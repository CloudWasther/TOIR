IncludeFile("Lib\\TOIR_SDK.lua")

Corki = class()

function OnLoad()
	--if GetChampName(GetMyChamp()) == "Corki" then
		Corki:__init()
	--end
end

function Corki:__init()
	if myHero.CharName ~= "Corki" then
        return;
    end
	-- VPrediction
	vpred = VPrediction(true)
	--HPred = HPrediction()
	AntiGap = AntiGapcloser(nil)

    self.Q = Spell(_Q, 925)
    self.W = Spell(_W, 700)
    self.E = Spell(_E, 800)
    self.R = Spell(_R, 1300)

    self.Q:SetSkillShot(0.1, 1000, 200, true)
    --self.W:SetSkillShot(0.25, 1600, 80, true)
    self.E:SetTargetted()
    self.R:SetSkillShot(0.2, 2000, 40, true)

    self.OverKill = 0
    self.tickIndex = 0
    self.ts_prio = {}

	Callback.Add("Tick", function(...) self:OnTick(...) end)
	Callback.Add("AntiGapClose", function(target, EndPos) self:OnAntiGapClose(target, EndPos) end)
	--Callback.Add("Update", function(...) self:OnUpdate(...) end)	
    Callback.Add("Draw", function(...) self:OnDraw(...) end)
    --Callback.Add("ProcessSpell", function(...) self:OnProcessSpell(...) end)
    Callback.Add("BeforeAttack", function(...) self:OnBeforeAttack(...) end)
    --Callback.Add("NewPath", function(...) self:OnNewPath(...) end)
    --Callback.Add("CreateObject", function(...) self:OnCreateObject(...) end)
    Callback.Add("DrawMenu", function(...) self:OnDrawMenu(...) end)
    --Callback.Add("UpdateBuff", function(unit, buff, stacks) self:OnUpdateBuff(source, unit, buff, stacks) end)
    --Callback.Add("AfterAttack", function(...) self:OnAfterAttack(...) end)
    self:MenuValueDefault()
end

function Corki:MenuValueDefault()
	self.menu = "Corki_Magic"
	self.Draw_When_Already = self:MenuBool("Draw When Already", false)
	self.menu_Draw_Q = self:MenuBool("Draw Q Range", false)
	self.menu_Draw_W = self:MenuBool("Draw W Range", false)
	self.menu_Draw_E = self:MenuBool("Draw E Range", false)
	self.menu_Draw_R = self:MenuBool("Draw R Range", false)

	self.autoQ = self:MenuBool("Auto Q", true)
	self.harassQ = self:MenuBool("Q harass", true)
	self.farmQ = self:MenuBool("Farm Q", true)
	self.farmQmana = self:MenuSliderInt("Mana Farm Q", 60)
	for i, enemy in pairs(GetEnemyHeroes()) do
        table.insert(self.ts_prio, { Enemy = GetAIHero(enemy), Menu = self:MenuBool(GetAIHero(enemy).CharName, true)})
    end

	self.nktdE = self:MenuBool("NoKeyToDash", false)
	self.AGC = self:MenuBool("Anti GapClose)", true)

	self.autoE = self:MenuBool("Auto E", true)
	self.harassE = self:MenuBool("E harass", true)

	self.autoR = self:MenuBool("Auto R", true)
	self.Rcc = self:MenuBool("R cc", true)
	self.Rammo = self:MenuSliderInt("Minimum R ammo harass", 3)
	self.minionR = self:MenuBool("Try R on minion", true)
	self.useR = self:MenuKeyBinding("Semi-manual cast R key", 84)
	self.rHC = self:MenuComboBox("R HitChance", 3)

	self.Enalble_Mod_Skin = self:MenuBool("Enalble Mod Skin", false)
	self.Set_Skin = self:MenuSliderInt("Set Skin", 15)

	self.Combo = self:MenuKeyBinding("Combo", 32)
	self.Harass = self:MenuKeyBinding("Harass", 67)
	self.Lane_Clear = self:MenuKeyBinding("Lane Clear", 86)
	self.Last_Hit = self:MenuKeyBinding("Last Hit", 88)
end

function Corki:OnDrawMenu()
	if Menu_Begin(self.menu) then
		if Menu_Begin("Setting Q") then
			self.autoQ = Menu_Bool("Auto Q", self.autoQ, self.menu)			
			self.farmQ = Menu_Bool("Farm Q", self.farmQ, self.menu)
			self.farmQmana = Menu_SliderInt("Mana Farm Q", self.farmQmana, 0, 100, self.menu)
			self.harassQ = Menu_Bool("Q harass", self.harassQ, self.menu)
			Menu_Text("Harass Enemy")
			for i, enemy in pairs(GetEnemyHeroes()) do
            	self.ts_prio[i].Menu = Menu_Bool(GetAIHero(enemy).CharName, self.ts_prio[i].Menu, self.menu)
        	end				
			Menu_End()
		end

		if Menu_Begin("Setting W") then
			self.nktdE = Menu_Bool("NoKeyToDash", self.nktdE, self.menu)
			self.AGC = Menu_Bool("Anti GapClose", self.AGC, self.menu)
			Menu_End()
		end

		if Menu_Begin("Setting E") then
			self.autoE = Menu_Bool("Auto E", self.autoE, self.menu)
			self.harassE = Menu_Bool("E harass", self.harassE, self.menu)		
			Menu_End()
		end

		if Menu_Begin("Setting R") then
			self.autoR = Menu_Bool("Auto R", self.autoR, self.menu)
			self.Rcc = Menu_Bool("R cc", self.Rcc, self.menu)
			self.Rammo = Menu_SliderInt("Minimum R ammo harass", self.Rammo, 0, 6, self.menu)
			self.minionR = Menu_Bool("Try R on minion", self.minionR, self.menu)
			self.useR = Menu_KeyBinding("Semi-manual cast R key", self.useR, self.menu)
			self.rHC = Menu_ComboBox("R HitChance", self.rHC, "Low\0Medium\0High\0Very High\0\0", self.menu)
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

function Corki:MenuBool(stringKey, bool)
	return ReadIniBoolean(self.menu, stringKey, bool)
end

function Corki:MenuSliderInt(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Corki:MenuSliderFloat(stringKey, valueDefault)
	return ReadIniFloat(self.menu, stringKey, valueDefault)
end

function Corki:MenuComboBox(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Corki:MenuKeyBinding(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Corki:HitChanceManager(hc)
	return (hc + 3)
end
--MP : Q 60 W 100 E 50 R 20
function Corki:OnBeforeAttack(target)
	if target ~= nil and target.Type == 0 then
		if CanCast(_E) and self:Sheen() then
			if GetKeyPress(self.Combo) > 0 and self.autoE and myHero.MP > 120 then
				CastSpellTarget(target.Addr, _E)
			end 
			if GetKeyPress(self.Harass) > 0 and self.harassE and myHero.MP > 230 and self:CanHarras() then
				CastSpellTarget(target.Addr, _E)
			end 
			if not CanCast(_Q) and not CanCast(_R) and GetHealthPoint(target.Addr) < GetAADamageHitEnemy(target.Addr) * 2 then
				CastSpellTarget(target.Addr, _E)
			end
		end
	end
end

function Corki:GetQCirclePreCore(target)
	local castPosX, castPosZ, unitPosX, unitPosZ, hitChance, _aoeTargetsHitCount = GetPredictionCore(target.Addr, 1, self.W.delay, self.W.width, self.W.range, self.W.speed, myHero.x, myHero.z, false, false, 1, 5, 5, 5, 5, 5)
	if target ~= nil then
		 CastPosition = Vector(castPosX, target.y, castPosZ)
		 HitChance = hitChance
		 Position = Vector(unitPosX, target.y, unitPosZ)
		 return CastPosition, HitChance, Position
	end
	return nil , 0 , nil
end

function Corki:GetRLinePreCore(target)
	local castPosX, castPosZ, unitPosX, unitPosZ, hitChance, _aoeTargetsHitCount = GetPredictionCore(target.Addr, 0, self.R.delay, self.R.width, self.R.range, self.R.speed, myHero.x, myHero.z, false, true, 1, 0, 5, 5, 5, 5)
	if target ~= nil then
		 CastPosition = Vector(castPosX, target.y, castPosZ)
		 HitChance = hitChance
		 Position = Vector(unitPosX, target.y, unitPosZ)
		 AOE = _aoeTargetsHitCount
		 return CastPosition, HitChance, Position, AOE
	end
	return nil , 0 , nil, 0
end

function Corki:OnTick()
	
	if (IsDead(myHero.Addr) or myHero.IsRecall or IsTyping() or IsDodging()) then return end
	SetLuaCombo(true)

	--[[GetAllBuffNameActive(myHero.Addr)
		for i,v in pairs(pBuffName) do
		__PrintDebug(tostring(v))				      
	end]]

	--self.HPred_Q_M = HPSkillshot({type = "PromptCircle", delay = self.Q.delay, range = self.Q.range, speed = self.Q.speed, radius = self.Q.width})
	--self.HPred_R_M = HPSkillshot({type = "DelayLine", delay = self.R.delay, range = self.R.range, speed = self.R.speed, collisionH = false, collisionM = true, width = self.R.width})
	--__PrintTextGame(tostring(self:Sheen()))
	--if self.AGC then
		--self:AntiGapCloser()
	--end

	if CanCast(_Q) and self:Sheen() then
		self:LogicQ();
	end

	if CanCast(_W) then
		self:LogicW();
	end

	if CanCast(_R) and self:Sheen() then
		self:LogicR();
	end

	self:AutoQR()

	if GetKeyPress(self.Lane_Clear) > 0 then
		self:LaneClear()
	end

	if self.Enalble_Mod_Skin then
		ModSkin(self.Set_Skin)
	end		
end

function Corki:OnUpdate()
	--self.tickIndex = self.tickIndex + 1
    --if (self.tickIndex > 4) then
        --self.tickIndex = 0;
    --end
end


function Corki:CanMoveOrb(extraWindup)
    return GetTimeGame() + self:GamePing() > GetLastBATick() + GetWindupBA(myHero.Addr) + extraWindup --self.menu_advanced_delayWindup.getValue() /1000
end

function Corki:LagFree(offset)
    if self.tickIndex == offset then
    	return true
    else
    	return false
    end
    return false
end

function Corki:GamePing()
    return GetLatency() / 2000
end

function Corki:LogicQ()
    local t = GetTargetSelector(self.Q.range - 150, 0)
    if CanCast(_Q) and t ~= 0 then	
		--__PrintTextGame(tostring(self:RDamage(target)))
		if IsValidTarget(t, self.Q.range - 150) then
			target = GetAIHero(t)
			--local CastPosition, HitChance, Position = vpred:GetCircularCastPosition(target, self.Q.delay, self.Q.width, self.Q.range, self.Q.speed, myHero, false)
			--local QPos, QHitChance = HPred:GetPredict(self.HPred_Q_M, target, myHero)
			local CastPosition, HitChance, Position = self:GetQCirclePreCore(target)
			if GetKeyPress(self.Combo) > 0 and self.autoQ and myHero.MP > 120 and HitChance >= 5 then
				CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
			else
				local qDmg = GetDamage("Q", target)				
				local rDmg = self:RDamage(target)
				if qDmg > target.HP and HitChance >= 6 then
					CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
				elseif (rDmg + qDmg) > target.HP and myHero.MP > 80 and HitChance >= 5 then
					CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
				elseif rDmg + 2 * qDmg > target.HP and myHero.MP > 100 and HitChance >= 5 then
					CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
				end
			end
		end
	end

	if myHero.MP > 170 then
		for i,hero in pairs(GetEnemyHeroes()) do
			if hero ~= nil then
				target = GetAIHero(hero)
				local CastPosition, HitChance, Position = self:GetQCirclePreCore(target)
				
				if IsValidTarget(target, self.Q.range - 150) and not self:CanMove(target) then
					CastSpellToPos(target.x, target.z, _Q)
				end
				if self.harassQ and myHero.MP > 200 and self:CanHarras() then
					for i = #self.ts_prio, 1, -1 do
				    	if self.ts_prio[i].Menu then
				    		if IsValidTarget(target.Addr, self.Q.range) and target.NetworkId == self.ts_prio[i].Enemy.NetworkId and HitChance >= 5 then
				    			CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
				    		end
				    	end 
				    end
				end
			end
		end
	end
end

function Corki:bonusR()
	if myHero.HasBuff("mbcheck2") then
		return true
	end
	return false
end

function Corki:RDamage(target)
	if self:bonusR() then
		return GetDamage("R", target) * 2
	end
	return GetDamage("R", target)
end

function Corki:Sheen()
	if GetType(GetTargetOrb()) == 0 then
		target = GetAIHero(GetTargetOrb())	
		if IsValidTarget(target, GetTrueAttackRange()) and target.HasBuff("sheen") then
			return false
		else
			return true
		end
	end
	return true
end

function Corki:CanHarras()
	local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
	if not self:IsUnderTurretEnemy(myHeroPos) then
		return true
	end
	return false
end

function Corki:LogicW()
	local dashPosition = Vector(myHero):Extended(GetMousePos(), self.W.range)
	if GetDistance(GetMousePos()) > GetTrueAttackRange() + 2 * GetBoundingRadius(myHero.Addr) and GetKeyPress(self.Combo) > 0 and self.nktdE and myHero.MP > 120 then
		CastSpellToPos(dashPosition.x,dashPosition.z, _W)
	end
end

function Corki:LogicR()
	local rSplash = 150;
    if self:bonusR() then
        rSplash = 300;
    end
    local t = GetTargetSelector(self.R.range - 150, 1) 
    if t ~= 0 then	
		if IsValidTarget(t, self.R.range - 150) then
			target = GetAIHero(t)	
			--local RPos, RHitChance = HPred:GetPredict(self.HPred_R_M, target, myHero)
			local CastPosition, HitChance, Position = self:GetRLinePreCore(target)

			local qDmg = GetDamage("Q", target)
			local rDmg = self:RDamage(target)
			if rDmg * 2 > target.HP and HitChance >= self:HitChanceManager(self.rHC) then
				CastSpellToPos(CastPosition.x, CastPosition.z, _R)
			elseif IsValidTarget(target.Addr, self.Q.range - 150) and qDmg + rDmg > target.HP and HitChance >= self:HitChanceManager(self.rHC) then
				CastSpellToPos(CastPosition.x, CastPosition.z, _R)
			end

			if rDmg * 2 > target.HP then
				self:CastRminion(target)
			elseif IsValidTarget(target.Addr, self.Q.range - 150) and qDmg + rDmg > target.HP then
				self:CastRminion(target)
			end
		end
	end

	if GetAmmoSpell(myHero.Addr, _R) > 1 then
		for i,hero in pairs(GetEnemyHeroes()) do
			if hero ~= nil then
				target = GetAIHero(hero)
				if IsValidTarget(target, self.R.range - 150) then --and CountEnemyChampAroundObject(target.Addr, rSplash) > 1 then
					--local RPos, RHitChance = HPred:GetPredict(self.HPred_R_M, target, myHero)
					local CastPosition, HitChance, Position = self:GetRLinePreCore(target)
					--__PrintTextGame(tostring(HitChance >= self:HitChanceManager(self.rHC)))
					if GetKeyPress(self.Combo) > 0 and myHero.MP > 60 and HitChance >= self:HitChanceManager(self.rHC) then
						--__PrintTextGame("string szText")
						CastSpellToPos(CastPosition.x, CastPosition.z, _R)
					elseif myHero.MP > 230 and GetAmmoSpell(myHero.Addr, _R) > self.Rammo and self:CanHarras() then
					    if self.ts_prio[i].Menu then
					    	if IsValidTarget(target.Addr, self.R.range - 150) and target.NetworkId == self.ts_prio[i].Enemy.NetworkId and HitChance >= self:HitChanceManager(self.rHC) then
					    		CastSpellToPos(CastPosition.x, CastPosition.z, _R)
					    	end 
					    end
					end

					if GetKeyPress(self.Combo) > 0 and myHero.MP > 60 and CountEnemyChampAroundObject(target.Addr, rSplash) > 1 then
						self:CastRminion(target)
					elseif myHero.MP > 230 and GetAmmoSpell(myHero.Addr, _R) > self.Rammo and self:CanHarras() and CountEnemyChampAroundObject(target.Addr, rSplash) > 1 then
					    if self.ts_prio[i].Menu then
					    	if IsValidTarget(target.Addr, self.R.range - 150) and target.NetworkId == self.ts_prio[i].Enemy.NetworkId then
					    		self:CastRminion(target)
					    	end 
					    end
					end
				end
				if myHero.MP > 130 and IsValidTarget(target, self.R.range - 150) then
					local Collision = CountCollision(myHero.x, myHero.z, target.x, target.z, self.R.delay, self.R.width, self.R.range, self.R.speed, 0, 5, 5, 5, 5)
					--__PrintTextGame(tostring(Collision))
					if not self:CanMove(target) then
						self:CastRminion(target)
						local Collision = CountCollision(myHero.x, myHero.z, target.x, target.z, self.R.delay, self.R.width, self.R.range, self.R.speed, 0, 5, 5, 5, 5)
						if Collision == 0 then
							CastSpellToPos(target.x, target.z, _R)
						end
					end
				end
			end
		end
	end
end

function Corki:CastRminion(target)
	if self.minionR then
		--local RPos, RHitChance = HPred:GetPredict(self.HPred_R_M, target, myHero) 
		local CastPosition, HitChance, Position = self:GetRLinePreCore(target)
		local rSplash = 150;
	    if self:bonusR() then
	        rSplash = 300;
	    end

	    GetAllUnitAroundAnObject(myHero.Addr, 2000)
	    for i, obj in pairs(pUnit) do
	        if obj ~= 0  then
	            local minions = GetUnit(obj)
            	if IsEnemy(minions.Addr) and not IsDead(minions.Addr) and not IsInFog(minions.Addr) and GetType(minions.Addr) == 1 then
            		if HitChance <= 1 and GetDistance(CastPosition, Vector(minions)) < rSplash then
            			CastSpellToPos(CastPosition.x, CastPosition.z, _R)
            		end
            	end
            end
        end
	end
end

function Corki:ValidUlt(unit)
	if CountBuffByType(unit.Addr, 16) == 1 or CountBuffByType(unit.Addr, 15) == 1 or CountBuffByType(unit.Addr, 17) == 1 or unit.HasBuff("kindredrnodeathbuff") or CountBuffByType(unit.Addr, 4) == 1 then
		return false
	end
	return true
end

function Corki:AutoQR()
	for i,hero in pairs(GetEnemyHeroes()) do
		if hero ~= nil then
			target = GetAIHero(hero)
			if IsValidTarget(target, 2000) then
				local TargetDashing, CanHitDashing, DashPosition = vpred:IsDashing(target, 0.25, 65, 2000, myHero)

				if DashPosition ~= nil then
					local Collision = CountCollision(myHero.x, myHero.z, DashPosition.x, DashPosition.z, self.R.delay, self.R.width, self.R.range, self.R.speed, 0, 5, 5, 5, 5)
			    	if GetDistance(DashPosition) <= self.R.range - 100 and Collision == 0 and CanCast(_R) then
			    		CastSpellToPos(DashPosition.x, DashPosition.z, _R)
			    	end

			    	if GetDistance(DashPosition) <= self.Q.range  - 100 and CanCast(_Q) then
			    		CastSpellToPos(DashPosition.x, DashPosition.z, _Q)
			    	end
				end			
			end
		end
	end
end

function Corki:LaneClear()
	if self.farmQ then
		GetAllUnitAroundAnObject(myHero.Addr, 2000)
	    for i, obj in pairs(pUnit) do
	        if obj ~= 0  then
	            local minion = GetUnit(obj)
            	if IsEnemy(minion.Addr) and not IsDead(minion.Addr) and not IsInFog(minion.Addr) and
                (GetObjName(minion.Addr) ~= "PlantSatchel" and GetObjName(minion.Addr) ~= "PlantHealth" and GetObjName(minion.Addr) ~= "PlantVision")then
            		local delay = GetDistance(Vector(minion)) / self.Q.speed + self.Q.delay
					local hpPred = GetHealthPred(minion.Addr, delay, 0.07)
					if hpPred > 0 and hpPred < GetDamage("Q", minion) and ((GetDistance(minion.Addr) > GetTrueAttackRange() and GetType(minion.Addr) == 1) or GetType(minion.Addr) == 3) then
						if  myHero.MP / myHero.MaxMP * 100 > self.farmQmana or CountEnemyChampAroundObject(minion.Addr, 300) > 0 then
							CastSpellToPos(minion.x, minion.z, _Q)
						end
					end
					--if hpPred > 0 and hpPred < self:RDamage(minion) and ((GetDistance(minion.Addr) > GetTrueAttackRange() and GetType(minion.Addr) == 1) or GetType(minion.Addr) == 3) then
						--CastSpellToPos(minion.x, minion.z, _R)
					--end
            	end
            end
        end	
	end
end

function Corki:OnDraw()
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

function Corki:OnProcessSpell(unit, spell)
	local spellName = spell.Name:lower()
	if unit.IsMe then
		--__PrintDebug(spell.Name)
	end	
end

function Corki:IsImmobileTarget(unit)
	if (CountBuffByType(unit, 5) == 1 or CountBuffByType(unit, 11) == 1 or CountBuffByType(unit, 29) == 1 or CountBuffByType(unit, 24) == 1 or CountBuffByType(unit, 10) == 1 or CountBuffByType(unit, 29) == 1) then
		return true
	end
	return false
end

function Corki:CanMove(unit)
	if (unit.MoveSpeed < 50 or CountBuffByType(unit.Addr, 5) == 1 or CountBuffByType(unit.Addr, 21) == 1 or CountBuffByType(unit.Addr, 11) == 1 or CountBuffByType(unit.Addr, 29) == 1 or
		unit.HasBuff("recall") or CountBuffByType(unit.Addr, 30) == 1 or CountBuffByType(unit.Addr, 22) == 1 or CountBuffByType(unit.Addr, 8) == 1 or CountBuffByType(unit.Addr, 24) == 1
		or CountBuffByType(unit.Addr, 20) == 1 or CountBuffByType(unit.Addr, 18) == 1) then
		return false
	end
	return true
end

function Corki:CheckWalls(enemyPos)
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

function Corki:IsUnderTurretEnemy(pos)			--Will Only work near myHero
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

function Corki:IsUnderAllyTurret(pos)
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

function Corki:CountEnemiesInRange(pos, range)
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

function Corki:CirclePoints(CircleLineSegmentN, radius, position)
  local points = {}
  for i = 1, CircleLineSegmentN, 1 do
    local angle = i * 2 * math.pi / CircleLineSegmentN
    local point = Vector(position.x + radius * math.cos(angle), position.y + radius * math.sin(angle), position.z);
    table.insert(points, point)
  end
  return points
end

function Corki:CastDash(asap)
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
	    points = self:CirclePoints(15, self.W.range, myHeroPos)
	    bestpoint = myHeroPos:Extended(GetMousePos(), self.W.range);
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

function Corki:InAARange(point)
  --if not "AAcheck" then
    --return true
  --end
  if GetType(GetTargetOrb()) == 0 then
    --local targetpos = GetPos(orbwalk:GetTargetOrb())
    local target = GetAIHero(GetTargetOrb())
    local targetpos = Vector(target.x, target.y, target.z)
    return GetDistance(point, targetpos) < GetTrueAttackRange()
  else
    return self:CountEnemiesInRange(point, GetTrueAttackRange()) > 0
  end
end

function Corki:IsGoodPosition(dashPos)
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

function Corki:OnAntiGapClose(target, EndPos)
	--for _,heros in pairs(GetEnemyHeroes()) do
        --if IsValidTarget(heros, 2000) then
            hero = GetAIHero(target.Addr)
            --if hero.NetworkId == target.NetworkId then
            --__PrintTextGame(tostring(GetDistance(hero)).."<-->"..tostring(GetDistance(EndPos))) 
            if GetDistance(EndPos) < 500 or GetDistance(hero) < 500 then
                points = self:CirclePoints(10, self.W.range, Vector(myHero))
		    	bestpoint = Vector(myHero):Extended(Vector(hero), - self.W.range);
		    	local enemies = self:CountEnemiesInRange(bestpoint, self.W.range)
		    	for i, point in pairs(points) do
		    		local count = self:CountEnemiesInRange(point, self.W.range)
		    		if count < enemies then
		    			enemies = count;
	                    bestpoint = point;
	                elseif count == enemies and GetDistance(GetMousePos(), point) < GetDistance(GetMousePos(), bestpoint) then
	                    enemies = count;
	                    bestpoint = point;
		    		end
		    	end
		    	if self:IsGoodPosition(bestpoint) and self.AGC and CanCast(_W) then   
	                CastSpellToPos(bestpoint.x,bestpoint.z, _W) 
	                --return    				
	          	end
            end
        --end
    --end
end
