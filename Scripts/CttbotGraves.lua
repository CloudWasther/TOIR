IncludeFile("Lib\\TOIR_SDK.lua")

Graves = class()

function OnLoad()
	--if GetChampName(GetMyChamp()) == "Graves" then
		Graves:__init()
	--end
end

function Graves:__init()
	if myHero.CharName ~= "Graves" then
        return;
    end
	-- VPrediction
	vpred = VPrediction(true)
	--HPred = HPrediction()
	AntiGap = AntiGapcloser(nil)

	--TS
    --self.menu_ts = TargetSelector(1750, 0, myHero, true, true, true)

	self.Q = Spell(_Q, 1000)
    self.W = Spell(_W, 1100)
    self.E = Spell(_E, 450)
    self.R = Spell(_R, 1100)
    self.R2 = Spell(_R, 1800)
    self.Q:SetSkillShot(0.25, 2100, 100, true)
    self.W:SetSkillShot(0.25, 1500, 300, true)
    self.E:SetSkillShot()
    self.R:SetSkillShot(0.25, 2100, 100, true)
    self.R2:SetSkillShot(0.25, 2100, 100, true)

    self.OverKill = 0

	Callback.Add("Tick", function(...) self:OnTick(...) end)
    Callback.Add("Draw", function(...) self:OnDraw(...) end)
    Callback.Add("AntiGapClose", function(target, EndPos) self:OnAntiGapClose(target, EndPos) end)
    Callback.Add("AfterAttack", function(...) self:OnAfterAttack(...) end)
    Callback.Add("DrawMenu", function(...) self:OnDrawMenu(...) end)

    self:MenuValueDefault()
end

function Graves:MenuValueDefault()
	self.menu = "Graves_Magic"
	self.autoQ = self:MenuBool("Auto Q", true)
	self.Auto_Q_If_Wall = self:MenuBool("Auto Q If Wall", true)
	self.QWlogic = self:MenuBool("Use Q and W only if don't have ammo", true)
	--self.Qharras = self:MenuBool("Harass Q", true)
	self.jungQ = self:MenuBool("Jungle Q", true)
	--self.qHC = self:MenuSliderFloat("Q HitChane", 1)

	self.autoW = self:MenuBool("Auto W", false)
	self.AGCW = self:MenuBool("AntiGapcloser W", true)


	self.Enable_E = self:MenuBool("Enable E", true)
	self.Enable_E_Reload_JungFarm = self:MenuBool("Enable E Reload JungFarm", true)
	self.EmodeGC = self:MenuComboBox("Gap Closer position mode", 1)
	self.E_Mode = self:MenuComboBox("E Mode", 2)

	self.autoR = self:MenuBool("Auto R", true)
	--self.Auto_R_if_Hit = self:MenuSliderInt("Auto R if Hit", 2)
	self.fastR = self:MenuBool("Fast R ks Combo", true)
	self.overkillR = self:MenuBool("Overkill protection", true)

	self.Draw_When_Already = self:MenuBool("Draw When Already", false)
	self.Draw_Q_Range = self:MenuBool("Draw Q Range", false)
	self.Draw_W_Range = self:MenuBool("Draw W Range", false)
	self.Draw_E_Range = self:MenuBool("Draw E Range", false)
	self.Draw_R_Range = self:MenuBool("Draw R Range", false)
	self.Draw_R2_Range = self:MenuBool("Draw R2 Range", false)

	self.Enalble_Mod_Skin = self:MenuBool("Enalble Mod Skin", false)
	self.Set_Skin = self:MenuSliderInt("Set Skin", 16)

	self.Combo = self:MenuKeyBinding("Combo", 32)
	self.Harass = self:MenuKeyBinding("Harass", 67)
	self.Lane_Clear = self:MenuKeyBinding("Lane Clear", 86)
	self.Last_Hit = self:MenuKeyBinding("Last Hit", 88)
end

function Graves:OnDrawMenu()
	if Menu_Begin(self.menu) then
		if Menu_Begin("Setting Q") then
			self.autoQ = Menu_Bool("Auto Q", self.autoQ, self.menu)
			self.Auto_Q_If_Wall = Menu_Bool("Auto Q If Wall", self.Auto_Q_If_Wall, self.menu)
			self.QWlogic = Menu_Bool("Use Q and W only if don't have ammo", self.QWlogic, self.menu)
			--self.Qharras = Menu_Bool("Harass Q", self.Qharras, self.menu)
			self.jungQ = Menu_Bool("Jungle Q", self.jungQ, self.menu)
			--self.qHC = Menu_SliderFloat("Q HitChane", self.qHC, 0, 3, self.menu)
			Menu_End()
		end
		if Menu_Begin("Setting W") then
			self.autoW = Menu_Bool("Auto W", self.autoW, self.menu)
			self.AGCW = Menu_Bool("AntiGapcloser W", self.AGCW, self.menu)
			Menu_End()
		end
		if Menu_Begin("Setting E") then
			self.Enable_E = Menu_Bool("Enable E", self.Enable_E, self.menu)
			self.Enable_E_Reload_JungFarm = Menu_Bool("Enable E Reload JungFarm", self.Enable_E_Reload_JungFarm, self.menu)
			self.E_Mode = Menu_ComboBox("E Mode", self.E_Mode, "Mouse\0Side\0Safe position\0\0\0", self.menu)	
			self.EmodeGC = Menu_ComboBox("Gap Closer position mode", self.EmodeGC, "Game Cursor\0Away - safe position\0Disable\0\0\0", self.menu)	
			Menu_End()
		end
		if Menu_Begin("Setting R") then
			self.autoR = Menu_Bool("Auto R", self.autoR, self.menu)
			--self.Auto_R_if_Hit = Menu_SliderInt("Auto R if Hit", self.Auto_R_if_Hit, 1, 5, self.menu)
			self.fastR = Menu_Bool("Fast R ks Combo", self.fastR, self.menu)
			self.overkillR = Menu_Bool("Overkill protection", self.overkillR, self.menu)
			Menu_End()
		end
		if Menu_Begin("Draw Spell") then
			self.Draw_When_Already = Menu_Bool("Draw When Already", self.Draw_When_Already, self.menu)
			self.Draw_Q_Range = Menu_Bool("Draw Q Range", self.Draw_Q_Range, self.menu)
			self.Draw_W_Range = Menu_Bool("Draw W Range", self.Draw_W_Range, self.menu)
			self.Draw_E_Range = Menu_Bool("Draw E Range", self.Draw_E_Range, self.menu)
			self.Draw_R_Range = Menu_Bool("Draw R Range", self.Draw_R_Range, self.menu)
			self.Draw_R2_Range = Menu_Bool("Draw R2 Range", self.Draw_R2_Range, self.menu)
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

function Graves:MenuBool(stringKey, bool)
	return ReadIniBoolean(self.menu, stringKey, bool)
end

function Graves:MenuSliderInt(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Graves:MenuSliderFloat(stringKey, valueDefault)
	return ReadIniFloat(self.menu, stringKey, valueDefault)
end

function Graves:MenuComboBox(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Graves:MenuKeyBinding(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Graves:GetQLinePreCore(target)
	local castPosX, castPosZ, unitPosX, unitPosZ, hitChance, _aoeTargetsHitCount = GetPredictionCore(target.Addr, 0, self.Q.delay, self.Q.width, self.Q.range, self.Q.speed, myHero.x, myHero.z, false, true, 1, 3, 5, 5, 5, 5)
	if target ~= nil then
		 CastPosition = Vector(castPosX, target.y, castPosZ)
		 HitChance = hitChance
		 Position = Vector(unitPosX, target.y, unitPosZ)
		 return CastPosition, HitChance, Position
	end
	return nil , 0 , nil
end

function Graves:GetWCirclePreCore(target)
	local castPosX, castPosZ, unitPosX, unitPosZ, hitChance, _aoeTargetsHitCount = GetPredictionCore(target.Addr, 1, self.W.delay, self.W.width, self.W.range, self.W.speed, myHero.x, myHero.z, false, false, 1, 5, 5, 5, 5, 5)
	if target ~= nil then
		 CastPosition = Vector(castPosX, target.y, castPosZ)
		 HitChance = hitChance
		 Position = Vector(unitPosX, target.y, unitPosZ)
		 return CastPosition, HitChance, Position
	end
	return nil , 0 , nil
end

function Graves:GetRLinePreCore(target)
	local castPosX, castPosZ, unitPosX, unitPosZ, hitChance, _aoeTargetsHitCount = GetPredictionCore(target.Addr, 0, self.R.delay, self.R.width, self.R.range, self.R.speed, myHero.x, myHero.z, false, false, 1, 5, 5, 5, 5, 5)
	if target ~= nil then
		 CastPosition = Vector(castPosX, target.y, castPosZ)
		 HitChance = hitChance
		 Position = Vector(unitPosX, target.y, unitPosZ)
		 AOE = _aoeTargetsHitCount
		 return CastPosition, HitChance, Position, AOE
	end
	return nil , 0 , nil, 0
end

function Graves:OnAfterAttack(unit, target)
	if unit.IsMe then
		if CanCast(_E) and self.Enable_E then
			self:LogicE()
		end

		if CanCast(_E) and self.Enable_E_Reload_JungFarm then			
	    	local orbT = GetTargetOrb()
    		if orbT ~= nil and GetType(orbT) == 3 then
    			CastSpellToPos(GetMousePos().x,GetMousePos().z, _E)
    		end
		end
	end
end

function Graves:OnAntiGapClose(target, EndPos)
    hero = GetAIHero(target.Addr)
    if GetDistance(EndPos) < 500 or GetDistance(hero) < 500 then
    	if self.EmodeGC == 1 then
	        points = self:CirclePoints(10, self.E.range, Vector(myHero))
			bestpoint = Vector(myHero):Extended(hero, - self.E.range);
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
			if self:IsGoodPosition(bestpoint) and CanCast(_E) and GetKeyPress(self.Combo) > 0 then   
				DelayAction(function() CastSpellToPos(bestpoint.x, bestpoint.z, _E) end, 0)          				
	    	end  
	    end
	    if self.EmodeGC == 0 then
	    	bestpoint = Vector(myHero):Extended(GetMousePos(), self.E.range);
	    	if self:IsGoodPosition(bestpoint) and CanCast(_E) then
	    		CastSpellToPos(bestpoint.x, bestpoint.z, _E)
	    	end
	    end

		if CanCast(_W) and self.AGCW then
          	CastSpellToPos(myHero.x, myHero.z, _W) 
        end		 
    end
end


function Graves:OnTick()
	if (IsDead(myHero.Addr) or myHero.IsRecall or IsTyping() or IsDodging()) then return end
	SetLuaCombo(true)

	--self.HPred_Q_M = HPSkillshot({type = "DelayLine", delay = self.Q.delay, range = self.Q.range, speed = self.Q.speed, width = self.Q.width})
	--self.HPred_W_M = HPSkillshot({type = "PromptCircle", delay = self.W.delay, range = self.W.range, speed = self.W.speed, radius = self.W.width})
	--self.HPred_R_M = HPSkillshot({type = "DelayLine", delay = self.R.delay, range = self.R.range, speed = self.R.speed, collisionH = true, collisionM = false, width = self.R.width})

	--self:AutoQW()

	if GetKeyPress(self.Lane_Clear) > 0 then
		self:LaneClear()
	end

	if self.QWlogic or not myHero.HasBuff("gravesbasicattackammo1") then
		if CanCast(_Q) and self.autoQ then
			self:LogicQ();
		end
		if CanCast(_W) and self.autoW then
			self:LogicW();
		end
	end
	if CanCast(_R) and self.autoR then
		self:LogicR();
	end

	if self.Enalble_Mod_Skin then
		ModSkin(self.Set_Skin)
	end
end

function Graves:LaneClear()
	if CanCast(_Q) and (GetType(GetTargetOrb()) == 3) and self.jungQ then
		if (GetObjName(GetTargetOrb()) ~= "PlantSatchel" and GetObjName(GetTargetOrb()) ~= "PlantHealth" and GetObjName(GetTargetOrb()) ~= "PlantVision") then
			target = GetUnit(GetTargetOrb())
	    	local CastPosition, HitChance, Position = vpred:GetLineCastPosition(target, self.Q.delay, self.Q.width, self.Q.range, self.Q.speed, myHero, false)
			CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
		end
	end
end

function Graves:LogicE()
	for i,hero in pairs(GetEnemyHeroes()) do
		if hero ~= nil then
			target = GetAIHero(hero)
			if IsValidTarget(target.Addr, GetTrueAttackRange()) then --and target.IsMelee then
				local dashPos = self:CastDash(true);
				if dashPos ~= Vector(0, 0, 0) then
					CastSpellToPos(dashPos.x,dashPos.z, _E)
				end
			end
		end
	end

	if GetKeyPress(self.Combo) > 0 and myHero.MP > 140 and not myHero.HasBuff("gravesbasicattackammo2") and myHero.HasBuff("gravesbasicattackammo1") then
		local dashPos = self:CastDash();
		if dashPos ~= Vector(0, 0, 0) then
			CastSpellToPos(dashPos.x,dashPos.z, _E)
		end
	end
end

function Graves:LogicQ()
	local TargetQ = GetTargetSelector(self.Q.range - 150, 1)
	if TargetQ ~= 0 then
		target = GetAIHero(TargetQ)
		
		if IsValidTarget(target.Addr, self.Q.range - 150) then
			--local QPos, QHitChance = HPred:GetPredict(self.HPred_Q_M, target, myHero)
			local CastPosition, HitChance, Position = self:GetQLinePreCore(target)
			local step = GetDistance(CastPosition) / 20
			for i = 1, 20, 1 do 
				local p = Vector(myHero):Extended(CastPosition, step * i)
				if IsWall(p.x, p.y, p.z) then
					return
				end
			end

			if GetKeyPress(self.Combo) > 0 and myHero.MP > 160 and HitChance >= 6 then
				CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
			--elseif GetKeyPress(self.Harass) > 0 and self.Qharras and myHero.MP > 330 and QHitChance >= self.qHC then
				--CastSpellToPos(QPos.x, QPos.z, _Q)
			else
				local qDmg = GetDamage("Q", target)
				local rDmg = GetDamage("R", target)
				if qDmg > target.HP and HitChance >= 6 then
					CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
					self.OverKill = GetTimeGame()
				elseif qDmg + rDmg > target.HP and CanCast(_R) and myHero.MP > 160 and HitChance >= 6 then
					CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
					if self.fastR and rDmg > target.HP then
						CastSpellToPos(CastPosition.x, CastPosition.z, _R)
					end
				end
			end
		end
	end
	if myHero.MP > 230 then
		for i,hero in pairs(GetEnemyHeroes()) do
			if hero ~= nil then
				target = GetAIHero(hero)				
				if IsValidTarget(target, self.Q.range - 200) and not self:CanMove(target)then
					CastSpellToPos(target.x, target.z, _Q)
				end
				if IsValidTarget(target, self.Q.range - 200) then
					--local QPos, QHitChance = HPred:GetPredict(self.HPred_Q_M, target, myHero)
					local CastPosition, HitChance, Position = self:GetQLinePreCore(target)
					local QPred = Vector(myHero):Extended(CastPosition, self.Q.range - 150)
					if GetDistance(CastPosition) < self.Q.range - 150 and HitChance >= 6 then
						CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
					end
					if IsWall(QPred.x, QPred.y, QPred.z) and self.Auto_Q_If_Wall then
						CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
					end
				end
			end
		end
	end
end

function Graves:LogicW()
	local TargetW = GetTargetSelector(self.W.range - 150, 0)
	if TargetW ~= 0 then
		target = GetAIHero(TargetW)		
		if IsValidTarget(target.Addr, self.W.range - 150) then
			--local WPos, WHitChance = HPred:GetPredict(self.HPred_W_M, target, myHero)
			local CastPosition, HitChance, Position = self:GetWCirclePreCore(target)
			local wDmg = GetDamage("W", target)
			if wDmg > target.HP and HitChance >= 6 then
				CastSpellToPos(CastPosition.x, CastPosition.z, _W)
			elseif wDmg + GetDamage("Q", target) > target.HP and myHero.MP >  230 and HitChance >= 6 then
				CastSpellToPos(CastPosition.x, CastPosition.z, _W)
			elseif GetKeyPress(self.Combo) > 0 and myHero.MP > 230 and HitChance >= 6 then
				if GetDistance(CastPosition) > GetTrueAttackRange() or CountEnemyChampAroundObject(target.Addr, 300) > 0 or self:CountEnemiesInRange(Vector(target), 250) > 1 or target.HP / target.MaxHP < 0.5 then
					CastSpellToPos(CastPosition.x, CastPosition.z, _W)
				end
			end
		end
	end
	if myHero.MP > 270 then
		for i,hero in pairs(GetEnemyHeroes()) do
			if hero ~= nil then
				target = GetAIHero(hero)				
				if IsValidTarget(target, self.W.range - 150) and not self:CanMove(target)then
					CastSpellToPos(target.x, target.z, _W)
				end
			end
		end
	end
end

function Graves:LogicR()
	for i,hero in pairs(GetEnemyHeroes()) do
		if hero ~= nil then
			target = GetAIHero(hero)
			if IsValidTarget(target, self.R.range - 150) and self:ValidUlt(target) then
				local rDmg = GetDamage("R", target)
				--__PrintTextGame(tostring(rDmg))
				if rDmg > target.HP then
					if self.overkillR and target.HP < myHero.HP then
						if GetDistance(Vector(target)) < GetTrueAttackRange() or CountAllyChampAroundObject(target.Addr, 400) > 0 then
							--local RPos, RHitChance = HPred:GetPredict(self.HPred_R_M, target, myHero)
							local CastPosition, HitChance, Position = self:GetRLinePreCore(target)
										__PrintTextGame(tostring(HitChance))
							local rDmg2 = rDmg * 0.8
							if HitChance >= 6 then 
								CastSpellToPos(CastPosition.x, CastPosition.z, _R)
							end
							if rDmg2 > target.HP then
								if HitChance <= 1 then
									CastSpellToPos(CastPosition.x, CastPosition.z, _R)
								end
							end
						end
					end
				end
			end
		end
	end
end

function Graves:AutoQW()
	local TargetQ = GetTargetSelector(self.Q.range - 150, 1)
	if CanCast(_Q) and TargetQ ~= 0 then
		target = GetAIHero(TargetQ)
		local CastPosition, HitChance, Position = vpred:GetLineCastPosition(target, self.Q.delay, self.Q.width, self.Q.range, self.Q.speed, myHero, false)
		local TargetDashing, CanHitDashing, DashPosition = vpred:IsDashing(target, self.Q.delay, self.Q.width, self.Q.speed, myHero, false)
		local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
    	local QPred = myHeroPos:Extended(CastPosition, self.Q.range - 150)

	    if CastPosition ~= nil and HitChance >= 2 then
	    	if GetDistance(CastPosition) <= self.Q.range and IsWall(QPred.x, QPred.y, QPred.z) and self.Auto_Q_If_Wall then
	        	CastSpellToPos(QPred.x, QPred.z, _Q)
	        end
	    end

	    if DashPosition ~= nil then
	    	if GetDistance(DashPosition) <= self.Q.range and self.Auto_Q_End_Dash then
	    		CastSpellToPos(DashPosition.x, DashPosition.z, _Q)
	    	end
		end
	end

	local TargetW = GetTargetSelector(self.W.range - 150, 0)
	if CanCast(_W) and TargetW ~= 0 then
		target = GetAIHero(TargetW)
		local CastPosition, HitChance, Position = vpred:GetCircularCastPosition(target, self.W.delay, self.W.width, self.W.range, self.W.speed, myHero, false)
		local TargetDashing, CanHitDashing, DashPosition = vpred:IsDashing(target, self.W.delay, self.W.width, self.W.speed, myHero, false)
		local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)

	    if DashPosition ~= nil then
	    	if GetDistance(DashPosition) <= self.W.range and self.Use_W_End_Dash then
	    		CastSpellToPos(DashPosition.x, DashPosition.z, _W)
	    	end
		end
	end
end


function Graves:CanMove(unit)
	if (unit.MoveSpeed < 50 or CountBuffByType(unit.Addr, 5) == 1 or CountBuffByType(unit.Addr, 21) == 1 or CountBuffByType(unit.Addr, 11) == 1 or CountBuffByType(unit.Addr, 29) == 1 or
		unit.HasBuff("recall") or CountBuffByType(unit.Addr, 30) == 1 or CountBuffByType(unit.Addr, 22) == 1 or CountBuffByType(unit.Addr, 8) == 1 or CountBuffByType(unit.Addr, 24) == 1
		or CountBuffByType(unit.Addr, 20) == 1 or CountBuffByType(unit.Addr, 18) == 1) then
		return false
	end
	return true
end

function Graves:ValidUlt(unit)
	if CountBuffByType(unit.Addr, 16) == 1 or CountBuffByType(unit.Addr, 15) == 1 or CountBuffByType(unit.Addr, 17) == 1 or unit.HasBuff("kindredrnodeathbuff") or CountBuffByType(unit.Addr, 4) == 1 then
		return false
	end
	return true
end

local function GetDistanceSqr(p1, p2)
    p2 = p2 or GetOrigin(myHero)
    return (p1.x - p2.x) ^ 2 + ((p1.z or p1.y) - (p2.z or p2.y)) ^ 2
end

function Graves:CountEnemyInLine(target)
	local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
    local targetPos = Vector(target.x, target.y, target.z)
    --local targetPosEx = myHeroPos:Extended(targetPos, 500)
	local NH = 0
	for i, heros in ipairs(GetEnemyHeroes()) do
		if heros ~= nil then
		local hero = GetUnit(heros)
			local proj2, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(myHeroPos, targetPos, Vector(hero))
			--__PrintTextGame(tostring(proj2.z).."--"..tostring(pointLine.z).."--"..tostring(isOnSegment))
			--__PrintTextGame(tostring(GetDistanceSqr(proj2, pointLine)))
		    if isOnSegment and (GetDistanceSqr(hero, proj2) <= (65) ^ 2) then
		        NH = NH + 1
		    end
		end
	end
    return NH



	--[[local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
    local targetPos = Vector(target.x, target.y, target.z)
    local targetPosEx = myHeroPos:Extended(targetPos, 500)
    local NH = 1
	for i=1, 4 do
		local h = GetAIHero(GetEnemyHeroes()[i])
		local proj2, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(myHeroPos, targetPosEx, h)
		if isOnSegment and GetDistanceSqr(proj2, h) < 65 ^ 2 then
			NH = NH + 1
		end
	end
	return NH]]
end

function Graves:OnDraw()

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
		if self.Draw_R2_Range and self.R:IsReady() then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.R2.range, Lua_ARGB(255,0,0,255))
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
		if self.Draw_R2_Range then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.R2.range, Lua_ARGB(255,0,0,255))
		end
	end
end

function Graves:IsImmobileTarget(unit)
	if (CountBuffByType(unit, 5) == 1 or CountBuffByType(unit, 11) == 1 or CountBuffByType(unit, 29) == 1 or CountBuffByType(unit, 24) == 1 or CountBuffByType(unit, 10) == 1 or CountBuffByType(unit, 29) == 1) then
		return true
	end
	return false
end

function Graves:CheckWalls(enemyPos)
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

function Graves:IsUnderTurretEnemy(pos)			--Will Only work near myHero
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

function Graves:IsUnderAllyTurret(pos)
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

function Graves:CountEnemiesInRange(pos, range)
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


function Graves:CirclePoints(CircleLineSegmentN, radius, position)
  local points = {}
  for i = 1, CircleLineSegmentN, 1 do
    local angle = i * 2 * math.pi / CircleLineSegmentN
    local point = Vector(position.x + radius * math.cos(angle), position.y + radius * math.sin(angle), position.z);
    table.insert(points, point)
  end
  return points
end

function Graves:CastDash(asap)
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

function Graves:InAARange(point)
  if GetType(GetTargetOrb()) == 0 then
    local target = GetAIHero(GetTargetOrb())
    local targetpos = Vector(target.x, target.y, target.z)
    return GetDistance(point, targetpos) < GetTrueAttackRange()
  else
    return self:CountEnemiesInRange(point, GetTrueAttackRange()) > 0
  end
end

function Graves:IsGoodPosition(dashPos)
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

function Graves:AntiGapCloser()
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
          			if GetDistance(DashPosition) < 400 and CanCast(_W) and self.AGCW then
          				CastSpellToPos(DashPosition.x, DashPosition.z, _W) 
          			end
        		end
      		--end
    	end
	end
end
