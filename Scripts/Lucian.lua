IncludeFile("Lib\\TOIR_SDK.lua")
IncludeFile("Lib\\OrbCustom.lua")
--IncludeFile("Lib\\AntiGapCloser.lua")

Lucian = class()

function OnLoad()
	if GetChampName(GetMyChamp()) == "Lucian" then
		Lucian:__init()
	end
end

function Lucian:__init()
	orbwalk = Orbwalking()

	-- VPrediction
	vpred = VPrediction(true)

	--TS
    self.menu_ts = TargetSelector(1750, 0, myHero, true, true, true)

	self.Q = Spell(_Q, 650)
    self.Q2 = Spell(_Q, 1000)
    self.W = Spell(_W, 1000)
    self.E = Spell(_E, 450)
    self.R = Spell(_R, 1200)

    self.Q:SetTargetted()
    self.Q2:SetTargetted()
    self.Q2.width = 50
    self.Q2.delay = 0.35
    self.W:SetSkillShot(0.30, 1600, 80, true)
    self.E:SetSkillShot()
    self.R:SetSkillShot(0.25, 2800, 110, true)

    self.newMovePos = nil
    self.NewPath = {}
    self.WaypointTick = GetTickCount()
    self.passRdy = false
    self.lucianR = false


	Callback.Add("Tick", function(...) self:OnTick(...) end)
    Callback.Add("Draw", function(...) self:OnDraw(...) end)
    Callback.Add("ProcessSpell", function(...) self:OnProcessSpell(...) end)
    --Callback.Add("DoCast", function(...) self:OnDoCast(...) end)
    Callback.Add("DrawMenu", function(...) self:OnDrawMenu(...) end)

    self:MenuValueDefault()

    self.EnemyMinions = minionManager(MINION_ENEMY, 2000, myHero, MINION_SORT_HEALTH_ASC)
end

function Lucian:MenuValueDefault()
	self.menu = "Lucian_Magic"
	self.menu_Combo_Q = self:MenuBool("Use Q", true)
	self.menu_Combo_Qhit = self:MenuSliderInt("Auto Q If Hit Minion", 2)
	self.menu_Combo_Qmana = self:MenuSliderInt("Auto Q If Mana", 60)
	self.menu_Combo_Qks = self:MenuBool("Use Q Kill Steal", true)


	self.menu_Combo_W = self:MenuBool("Use Combo W", true)
	self.menu_Combo_WendDash = self:MenuBool("Use W End Dash", true)
	self.menu_Combo_Wks = self:MenuBool("Auto W Kill Steal", true)

	self.menu_Combo_E = self:MenuBool("Enable E", true)
	self.menu_Combo_EMode = self:MenuComboBox("E Mode", 2)

	self.menu_Combo_R = self:MenuBool("Enable R", true)
	self.menu_Combo_Rks = self:MenuBool("Use R Kill Steal", true)
	self.menu_Combo_Rlock = self:MenuKeyBinding("Lock R On Target", 32)

	self.Draw_When_Already = self:MenuBool("Draw When Already", true)
	self.Draw_Q_Range = self:MenuBool("Draw Q Range", true)
	self.Draw_Q2_Range = self:MenuBool("Draw Q2 Range", true)
	self.Draw_W_Range = self:MenuBool("Draw W Range", true)
	self.Draw_E_Range = self:MenuBool("Draw E Range", true)
	self.Draw_R_Range = self:MenuBool("Draw R Range", true)

	self.Enalble_Mod_Skin = self:MenuBool("Enalble Mod Skin", true)
	self.Set_Skin = self:MenuSliderInt("Set Skin", 7)

	self.Combo = self:MenuKeyBinding("Combo", 32)
	self.Harass = self:MenuKeyBinding("Harass", 67)
	self.Lane_Clear = self:MenuKeyBinding("Lane Clear", 86)
	self.Last_Hit = self:MenuKeyBinding("Last Hit", 88)
end

function Lucian:OnDrawMenu()
	if Menu_Begin(self.menu) then
		if Menu_Begin("Setting Q") then
			self.menu_Combo_Q = Menu_Bool("Use Q", self.menu_Combo_Q, self.menu)
			self.menu_Combo_Qhit = Menu_SliderInt("Auto Q If Hit Minion", self.menu_Combo_Qhit, 0, 5, self.menu)
			self.menu_Combo_Qmana = Menu_SliderInt("Auto Q If Mana", self.menu_Combo_Qmana, 0, 100, self.menu)
			self.menu_Combo_Qks = Menu_Bool("Use Q Kill Steal", self.menu_Combo_Qks, self.menu)
			Menu_End()
		end
		if Menu_Begin("Setting W") then
			self.menu_Combo_W = Menu_Bool("Auto Use W Combo", self.menu_Combo_W, self.menu)
			self.menu_Combo_WendDash = Menu_Bool("Use W End Dash", self.menu_Combo_WendDash, self.menu)
			self.menu_Combo_Wks = Menu_Bool("Auto W Kill Steal", self.menu_Combo_Wks, self.menu)
			Menu_End()
		end
		if Menu_Begin("Setting E") then
			self.menu_Combo_E = Menu_Bool("Enable E", self.menu_Combo_E, self.menu)
			self.menu_Combo_EMode = Menu_ComboBox("E Mode", self.menu_Combo_EMode, "Mouse\0Side\0Safe position\0\0\0", self.menu)		
			Menu_End()
		end
		if Menu_Begin("Setting R") then
			self.menu_Combo_R = Menu_Bool("Enable R", self.menu_Combo_R, self.menu)
			self.menu_Combo_Rks = Menu_Bool("Use R Kill Steal", self.menu_Combo_Rks, self.menu)
			self.menu_Combo_Rlock = Menu_KeyBinding("Lock R On Target", self.menu_Combo_Rlock, self.menu)
			Menu_End()
		end		
		if Menu_Begin("Draw Spell") then
			self.Draw_When_Already = Menu_Bool("Draw When Already", self.Draw_When_Already, self.menu)
			self.Draw_Q_Range = Menu_Bool("Draw Q Range", self.Draw_Q_Range, self.menu)
			self.Draw_Q2_Range = Menu_Bool("Draw Q2 Range", self.Draw_R2_Range, self.menu)
			self.Draw_W_Range = Menu_Bool("Draw W Range", self.Draw_W_Range, self.menu)
			self.Draw_E_Range = Menu_Bool("Draw E Range", self.Draw_E_Range, self.menu)
			self.Draw_R_Range = Menu_Bool("Draw R Range", self.Draw_R_Range, self.menu)			
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

function Lucian:MenuBool(stringKey, bool)
	return ReadIniBoolean(self.menu, stringKey, bool)
end

function Lucian:MenuSliderInt(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Lucian:MenuSliderFloat(stringKey, valueDefault)
	return ReadIniFloat(self.menu, stringKey, valueDefault)
end

function Lucian:MenuComboBox(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Lucian:MenuKeyBinding(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Lucian:OnWaypoint(pUnit)            
    local unit = GetAIHero(pUnit)
    local unitPosTo = Vector(GetDestPos(pUnit))

    if self.NewPath[unit.NetworkId] == nil then 
        self.NewPath[unit.NetworkId] = {pos = unitPosTo} 
    end 

    if self.NewPath[unit.NetworkId].pos ~= unitPosTo then    

        local unitPos = Vector(GetPos(pUnit))
        self.NewPath[unit.NetworkId] = {startPos = unitPos, pos = unitPosTo}

        local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
		local TargetR = self.menu_ts:GetTarget(self.R.range)
		if TargetR ~= nil and IsValidTarget(TargetR, self.R.range) and CanCast(_R) then --and GetKeyPress(self.menu_Combo_Rlock) > 0 then
			local target = GetAIHero(TargetR)
			local targetPos = Vector(target.x, target.y, target.z)
			local trungdiem = unitPosTo:Extended(myHeroPos, GetDistance(unitPosTo, myHeroPos) / 2)

			self.newMovePos = unitPos:Extended(trungdiem, 2 * GetDistance(unitPos, trungdiem))			

			--self.Move = false
			--[[local CastPosition, HitChance, Position = vpred:GetLineCastPosition(target, self.R.delay, self.R.width, self.R.range, self.R.speed, myHero, false)
			if HitChance >= 2 and GetTimeGame() - self.castR > 5 and self.menu_Combo_R.getValue() then
				DelayAction(function() CastSpellToPos(Position.x, Position.z, _R) end, 0.1, {})	
				if GetDistance(self.newMovePos) > 100 and GetDistance(self.newMovePos) < self.E.range and CanCast(_E) then
					CastSpellToPos(self.newMovePos.x, self.newMovePos.z, _E)	
				end	
			end]]
		else
			self.newMovePos = nil
			--self.Move = true
		end   
    end                             
end

function Lucian:OnWaypointLoop()            
    --if GetTickCount() - WaypointTick > 50 then
        SearchAllChamp()                
        local h = pObjChamp
        for k, v in pairs(h) do                          
            if IsChampion(v) then
                self:OnWaypoint(v)  
            end                         
        end
        self.WaypointTick = GetTickCount()
    --end
end



function Lucian:OnTick()
	if myHero.IsDead then return end

	SetLuaCombo(true)

	self:AutoQW()
	self:AntiGapCloser()
	self:KillSteal()
	self:OnWaypointLoop()
	self:LogicR()

	if GetKeyPress(self.Combo) > 0 then
		if not self.passRdy and not self:SpellLock() then
			self:LogicQ()
			self:LogicW()	
			self:LogicE()
		end			
	end

	if self.Enalble_Mod_Skin then
		ModSkin(self.Set_Skin)
	end
end

function Lucian:SpellLock()
	if GetBuffByName(myHero.Addr, "LucianPassiveBuff") ~= 0 then
		return true;
    else
        return false;
    end
    return false
end

function Lucian:LogicE()
	if myHero.MP > 150 and not self.menu_Combo_E then
		return
	end

	local TargetE = self.menu_ts:GetTarget(self.E.range)
	if CanCast(_E) and TargetE ~= 0 then
		target = GetAIHero(TargetE)
		if target.IsMelee then
			local dashPos = self:CastDash(true);
			--__PrintTextGame(tostring(dashPos))
			if dashPos ~= Vector(0, 0, 0) then
				--__PrintTextGame("111111111")
				CastSpellToPos(dashPos.x,dashPos.z, _E)
			end
		else
			if GetKeyPress(self.Combo) == 0 or self.passRdy or self:SpellLock() then
                return
            end

            local dashPos = self:CastDash();
			if dashPos ~= Vector(0, 0, 0) then
				--__PrintTextGame("222222222222")
				CastSpellToPos(dashPos.x,dashPos.z, _E)
			end
		end
	end
end

function Lucian:LogicQ()
	local TargetQ = self.menu_ts:GetTarget(self.Q.range)	
	if CanCast(_Q) and TargetQ ~= 0 then
		target = GetAIHero(TargetQ)
		local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
		local targetPos = Vector(target.x, target.y, target.z)
		if GetDistance(targetPos) <= self.Q.range then
			CastSpellTarget(target.Addr, _Q)
		end
	end

	local TargetQ2 = self.menu_ts:GetTarget(self.Q2.range)
	if CanCast(_Q) and TargetQ2 ~= 0 then
		target = GetAIHero(TargetQ2)
		local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
		local targetPos = Vector(target.x, target.y, target.z)
		local CastPosition, HitChance, Position = vpred:GetLineCastPosition(target, self.Q2.delay, self.Q2.width, self.Q2.range, math.huge, myHero, false)
		if HitChance >= 2 and GetDistance(targetPos) > self.Q.range and GetDistance(targetPos) <= self.Q2.range then
			local countMinion, minion = self:CountMinionInLine(target)
			if minion ~= nil and countMinion >= self.menu_Combo_Qhit then
				CastSpellTarget(minion.Addr, _Q)
			end
			
			--[[local j = 0
			local distance = GetDistance(CastPosition)
			GetAllUnitAroundAnObject(myHero.Addr, self.Q.range)
            for i, minions in ipairs(pUnit) do
				if minions ~= nil then
					if GetType(minions) == 1 and IsValidTarget(minions, self.Q.range) and IsEnemy(minions) then
						local minion = GetUnit(minions)
						local minionPos = Vector(minion.x, minion.y, minion.z) 
						local posEx = myHeroPos:Extended(minionPos, distance)
						local angle = myHeroPos:AngleBetween(CastPosition, posEx)
						if GetDistance(CastPosition, posEx) < 25 or angle < 10 then
							__PrintTextGame(tostring(angle))
							j = j + 1
							--CastSpellTarget(minion.Addr, _Q)
							DrawCircleGame(minion.x , minion.y, minion.z, 200, Lua_ARGB(255,255,0,255))
						end						
					end
				end
			end]]       
		end
	end
end

function Lucian:CountMinionInLine(target)
	local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
    local targetPos = Vector(target.x, target.y, target.z)
	local NH = 0
	local minioncollision
	self.EnemyMinions:update()
	for i, minions in ipairs(self.EnemyMinions.objects) do
		if minions ~= nil then
		local minion = GetUnit(minions)
			local proj2, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(myHeroPos, targetPos, Vector(minion))
		    if isOnSegment and (GetDistance(GetOrigin(minion), GetOrigin(proj2)) <= (50)) then
		        NH = NH + 1
		        minioncollision = minion
		    end
		end
	end
    return NH , minioncollision
    --[[local NH = 0
	local minioncollision = nil
    local targetPos = Vector(target.x, target.y, target.z)
    local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
	local CastPosition, HitChance, Position = vpred:GetLineCastPosition(target, self.Q2.delay, self.Q2.width, self.Q2.range, math.huge, myHero, false)
	if HitChance >= 2 and GetDistance(targetPos) > self.Q.range and GetDistance(targetPos) <= self.Q2.range then
		local distance = GetDistance(CastPosition)
		GetAllUnitAroundAnObject(myHero.Addr, self.Q.range)
        for i, minions in ipairs(pUnit) do
			if minions ~= nil then
				if GetType(minions) == 1 and IsValidTarget(minions, self.Q.range) and IsEnemy(minions) then
					local minion = GetUnit(minions)
					local minionPos = Vector(minion.x, minion.y, minion.z) 
					local posEx = myHeroPos:Extended(minionPos, distance)
					--local angle = myHeroPos:AngleBetween(CastPosition, posEx)
					if GetDistance(CastPosition, posEx) < 25 then --or angle < 10 then
						NH = NH + 1
						minioncollision = minion
							--CastSpellTarget(minion.Addr, _Q)
						DrawCircleGame(minion.x , minion.y, minion.z, 200, Lua_ARGB(255,255,0,255))
					end						
				end
			end
		end 			        
	end
	return NH , minioncollision]]
end

function Lucian:LogicW()
	local TargetW = self.menu_ts:GetTarget(self.W.range)
	if CanCast(_W) and TargetW ~= 0 then
		target = GetAIHero(TargetW)
		local CastPosition, HitChance, Position = vpred:GetCircularCastPosition(target, self.W.delay, self.W.width, self.W.range, self.W.speed, myHero, false)
		local distance = VPGetLineCastPosition(target.Addr, self.W.delay, self.W.speed)
	    if not GetCollision(target.Addr, self.W.width, self.W.range, distance, 1) then
	    	if (GetDistance(GetOrigin(TargetW)) < self.W.range - 100 and GetDistance(GetOrigin(TargetW)) > 300 and not CanCast(_E) and not CanCast(_Q))  or self:IsImmobileTarget(TargetW) then
				if CastPosition and HitChance >= 2 and self.menu_Combo_W then
		        	CastSpellToPos(CastPosition.x, CastPosition.z, _W)
		    	end
		    end
	    end
	end
end

function Lucian:LogicR()
	if GetKeyPress(self.menu_Combo_Rlock) > 0 and myHero.MP > 250 then
		local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
		local TargetR = self.menu_ts:GetTarget(self.R.range)
		if TargetR ~= nil and IsValidTarget(TargetR, self.R.range) and CanCast(_R) then
			local target = GetAIHero(TargetR)
			local targetPos = Vector(target.x, target.y, target.z)
			local CastPosition, HitChance, Position = vpred:GetLineCastPosition(target, self.R.delay, self.R.width, self.R.range, self.R.speed, myHero, false)
			local distance = VPGetLineCastPosition(target.Addr, self.R.delay, self.R.speed)
			if HitChance >= 2 and GetDistance(GetOrigin(TargetR)) < self.R.range - 100 and 10 * GetDamage("R", target) + GetDamage("Q", target) + GetDamage("W", target) > GetHealthPoint(TargetR) and self.menu_Combo_R then				
				if self.newMovePos ~= nil then
					orbwalk:DisableMove()
					MoveToPos(self.newMovePos.x, self.newMovePos.z)
					if not self.lucianR and not GetCollision(target.Addr, self.R.width, self.R.range, distance, 2) then					
						DelayAction(function() CastSpellToPos(CastPosition.x, CastPosition.z, _R) end, 0.1, {})	
					end	
					if GetDistance(self.newMovePos) > 100 and GetDistance(self.newMovePos) < self.E.range and CanCast(_E) then
						CastSpellToPos(self.newMovePos.x, self.newMovePos.z, _E)	
					end
				end						
			end
		end	
		orbwalk:EnableMove()	
	end
end

function Lucian:AutoQW()
	local TargetQ2 = self.menu_ts:GetTarget(self.Q2.range)
	if CanCast(_Q) and TargetQ2 ~= 0 then
		target = GetAIHero(TargetQ2)
		local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
		local targetPos = Vector(target.x, target.y, target.z)
		local CastPosition, HitChance, Position = vpred:GetLineCastPosition(target, self.Q2.delay, self.Q2.width, self.Q2.range, math.huge, myHero, false)
		if HitChance >= 2 and GetDistance(targetPos) > self.Q.range and GetDistance(targetPos) <= self.Q2.range then
			local countMinion, minion = self:CountMinionInLine(target)
			if minion ~= nil and myHero.MP / myHero.MaxMP * 100 >= self.menu_Combo_Qmana then
				CastSpellTarget(minion.Addr, _Q)
			end		       
		end
	end

	--[[local TargetW = self.menu_ts:GetTarget(self.W.range)
	if CanCast(_W) and TargetW ~= 0 then
		target = GetAIHero(TargetW)
		--local CastPosition, HitChance, Position = vpred:GetCircularCastPosition(target, self.W.delay, self.W.width, self.W.range, self.W.speed, myHero, false)
		local TargetDashing, CanHitDashing, DashPosition = vpred:IsDashing(target, self.W.delay, self.W.width, self.W.speed, myHero, false)
		local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)

	    if DashPosition ~= nil then
	    	if GetDistance(DashPosition) <= self.W.range and self.menu_Combo_WendDash then
	    		CastSpellToPos(DashPosition.x, DashPosition.z, _W)
	    	end
		end
	end]]
end

function Lucian:KillSteal()
	for i, heros in ipairs(GetEnemyHeroes()) do
		if heros ~= nil then
			local hero = GetUnit(heros)
			if IsValidTarget(hero.Addr, self.R.range) and CanCast(_R) and self.menu_Combo_Rks then
				local CastPosition, HitChance, Position = vpred:GetLineCastPosition(hero, self.R.delay, self.R.width, self.R.range, self.R.speed, myHero, false)	
				local distance = VPGetLineCastPosition(target.Addr, self.R.delay, self.R.speed)
				if HitChance >= 2 and GetDistance(GetOrigin(hero.Addr)) < self.R.range and GetDamage("R", hero) > GetHealthPoint(hero.Addr) then
					if self.newMovePos ~= nil then
						orbwalk:DisableMove()
						MoveToPos(self.newMovePos.x, self.newMovePos.z)
						if not self.lucianR and not GetCollision(target.Addr, self.R.width, self.R.range, distance, 2) then
							DelayAction(function() CastSpellToPos(Position.x, Position.z, _R) end, 0.1, {})	
						end	
						if GetDistance(self.newMovePos) > 100 and GetDistance(self.newMovePos) < self.E.range and CanCast(_E) then
							CastSpellToPos(self.newMovePos.x, self.newMovePos.z, _E)	
						end	
					end
								
				end	
				orbwalk:EnableMove()
			end

			if IsValidTarget(hero.Addr, self.Q.range) and CanCast(_Q) and self.menu_Combo_Qks then
				if GetDistance(GetOrigin(hero.Addr)) < self.Q.range and GetDamage("Q", hero) > GetHealthPoint(hero.Addr) then
					--CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
					CastSpellTarget(hero.Addr, _Q)
				end
			end

			if IsValidTarget(hero.Addr, self.W.range) and CanCast(_W) and self.menu_Combo_Wks then
				local CastPosition, HitChance, Position = vpred:GetLineCastPosition(hero, self.W.delay, self.W.width, self.W.range, self.W.speed, myHero, false)
				if GetDistance(GetOrigin(hero.Addr)) < self.W.range and GetDamage("W", hero) > GetHealthPoint(hero.Addr) then
					CastSpellToPos(CastPosition.x, CastPosition.z, _W)
				end
			end
		end
	end
	--[[local TargetR = self.menu_ts:GetTarget(self.R.range)
	if TargetR ~= nil and IsValidTarget(TargetR, self.R.range) and CanCast(_R) and self.menu_Combo_Rks then
		targetR = GetAIHero(TargetR)
		--__PrintTextGame(tostring(myHero.CalcDamage(target.Addr, GetDamage("R", targetR))))
		local CastPosition, HitChance, Position = vpred:GetLineCastPosition(targetR, self.R.delay, self.R.width, self.R.range, self.R.speed, myHero, false)		

		if HitChance >= 2 and GetDistance(GetOrigin(TargetR)) < self.R.range and 10 * GetDamage("R", targetR) > GetHealthPoint(TargetR) then
			if self.newMovePos ~= nil then
				MoveToPos(self.newMovePos.x, self.newMovePos.z)
			end
			if not self.lucianR then
				DelayAction(function() CastSpellToPos(Position.x, Position.z, _R) end, 0.1, {})	
			end
			if GetDistance(self.newMovePos) > 100 and GetDistance(self.newMovePos) < self.E.range and CanCast(_E) then
				CastSpellToPos(self.newMovePos.x, self.newMovePos.z, _E)	
			end	
		end	
	end

	local TargetQ = self.menu_ts:GetTarget(self.Q.range)
	if TargetQ ~= nil and IsValidTarget(TargetQ, self.Q.range) and CanCast(_Q) and self.menu_Combo_Qks then
		targetQ = GetAIHero(TargetQ)
		--__PrintTextGame(GetDamage("Q", targetQ))
		--__PrintTextGame(tostring(myHero.CalcDamage(targetQ.Addr, GetDamage("Q", targetQ))))
		--local CastPosition, HitChance, Position = vpred:GetLineCastPosition(targetQ, self.Q.delay, self.Q.width, self.Q.range, self.Q.speed, myHero, false)
		if GetDistance(GetOrigin(TargetQ)) < self.Q.range and GetDamage("Q", targetQ) > GetHealthPoint(TargetQ) then
			--CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
			CastSpellTarget(targetQ.Addr, _Q)
		end
	end

	local TargetW = self.menu_ts:GetTarget(self.W.range)
	if TargetW ~= nil and IsValidTarget(TargetW, self.W.range) and CanCast(_W) and self.menu_Combo_Wks then
		targetW = GetAIHero(TargetW)
		--__PrintTextGame(tostring(GetDamage("W", targetW)))
		local CastPosition, HitChance, Position = vpred:GetLineCastPosition(targetW, self.W.delay, self.W.width, self.W.range, self.W.speed, myHero, false)
		if GetDistance(GetOrigin(TargetW)) < self.W.range and GetDamage("W", targetW) > GetHealthPoint(TargetW) then
			CastSpellToPos(CastPosition.x, CastPosition.z, _W)
		end
	end]]
end

function Lucian:OnDraw()

	if self.Draw_When_Already then
		if self.Draw_Q_Range and self.Q:IsReady() then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.Q.range, Lua_ARGB(255,255,0,0))
		end
		if self.Draw_W_Range and self.W:IsReady() then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.W.range, Lua_ARGB(255,255,0,0))
		end
		if self.Draw_E_Range and self.E:IsReady() then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.E.range, Lua_ARGB(255,0,255,0))
		end
		if self.Draw_R_Range and self.R:IsReady() then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.R.range, Lua_ARGB(255,0,0,255))
		end
		if self.Draw_Q2_Range and self.Q:IsReady() then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.Q2.range, Lua_ARGB(255,0,0,255))
		end
	else
		if self.Draw_Q_Range then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.Q.range, Lua_ARGB(255,255,0,0))
		end
		if self.Draw_W_Range then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.W.range, Lua_ARGB(255,255,0,0))
		end
		if self.Draw_E_Range then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.E.range, Lua_ARGB(255,0,255,0))
		end
		if self.Draw_R_Range then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.R.range, Lua_ARGB(255,0,0,255))
		end
		if self.Draw_Q2_Range then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.Q2.range, Lua_ARGB(255,0,0,255))
		end
	end
	if self.newMovePos ~= nil then
		DrawCircleGame(self.newMovePos.x , self.newMovePos.y, self.newMovePos.z, 200, Lua_ARGB(255,255,0,255))
	end
end

function Lucian:OnProcessSpell(unit, spell)
	local spellName = spell.Name:lower()
    if unit.IsMe then
    	if spellName == "lucianr" then
    		self.lucianR = true
		else
			self.lucianR = false
    	end

    	if (spellName == "lucianw" or spellName == "luciane" or spellName == "lucianq") then    		
            self.passRdy = true
        else
        	self.passRdy = false
        end
    end

    if unit.IsMe and myHero.NetworkId ~= GetIndex(GetTargetById(spell.TargetId))  and string.find(string.lower(spell.Name), "attack") ~= nil then
    	self.modeTarget = GetType(GetTargetById(spell.TargetId))
    	self.targetslector = GetTargetById(spell.TargetId)   
    else
    	self.modeTarget = 4
    	self.targetslector = nil	
    end
end

function Lucian:OnDoCast(unit, spell)
	local spellName = spell.Name:lower()	
end

function Lucian:IsImmobileTarget(unit)
	if (CountBuffByType(unit, 5) == 1 or CountBuffByType(unit, 11) == 1 or CountBuffByType(unit, 29) == 1 or CountBuffByType(unit, 24) == 1 or CountBuffByType(unit, 10) == 1 or CountBuffByType(unit, 29) == 1) then
		return true
	end
	return false
end

function Lucian:CheckWalls(enemyPos)
	if enemyPos ~= nil then
		local distance = GetDistance(enemyPos)
		local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)

		for i = 100 , 900, 100 do
			local qPos = Vector(enemyPos.x + i, enemyPos.y + i, enemyPos.z)
			--pos = myHeroPos:Extended(enemyPos, distance + 60 * i)
			if IsWall(qPos.x, qPos.y, qPos.z) then
				return qPos
			end
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

function Lucian:IsUnderTurretEnemy(pos)			--Will Only work near myHero
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

function Lucian:IsUnderAllyTurret(pos)
    GetAllUnitAroundAnObject(myHero.Addr, 2000)
  for k,v in pairs(pUnit) do
    if not IsDead(v) and IsTurret(v) and IsAlly(v) and GetTargetableToTeam(v) == 4 then
      local turretPos = Vector(GetPosX(v), GetPosY(v), GetPosZ(v))
      if GetDistance(turretPos,pos) < 915 then
        return true
      end
    end
  end
    return false
end

function Lucian:CountEnemiesInRange(pos, range)
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


function Lucian:CirclePoints(CircleLineSegmentN, radius, position)
  local points = {}
  for i = 1, CircleLineSegmentN, 1 do
    local angle = i * 2 * math.pi / CircleLineSegmentN
    local point = Vector(position.x + radius * math.cos(angle), position.y + radius * math.sin(angle), position.z);
    table.insert(points, point)
  end
  return points
end

function Lucian:CastDash(asap)
    asap = asap and asap or false
    local DashMode = self.menu_Combo_EMode
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

function Lucian:InAARange(point)
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

function Lucian:IsGoodPosition(dashPos)
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

function Lucian:AntiGapCloser()
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

