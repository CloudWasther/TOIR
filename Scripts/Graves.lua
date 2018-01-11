IncludeFile("Lib\\TOIR_SDK.lua")
IncludeFile("Lib\\OrbCustom.lua")
--IncludeFile("Lib\\AntiGapCloser.lua")

Graves = class()

function OnLoad()
	if GetChampName(GetMyChamp()) == "Graves" then
		Graves:__init()
	end
end

function Graves:__init()
	orbwalk = Orbwalking()

	-- VPrediction
	self.vpred = VPrediction(true)

	--TS
    self.menu_ts = TargetSelector(1750, 0, myHero, true, true, true)

    

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

	Callback.Add("Tick", function(...) self:OnTick(...) end)
    Callback.Add("Draw", function(...) self:OnDraw(...) end)
    --Callback.Add("ProcessSpell", function(...) self:OnProcessSpell(...) end)
    --Callback.Add("DoCast", function(...) self:OnDoCast(...) end)
    Callback.Add("AfterAttack", function(...) self:OnAfterAttack(...) end)
    Callback.Add("DrawMenu", function(...) self:OnDrawMenu(...) end)

    self:MenuValueDefault()
end

function Graves:MenuValueDefault()
	self.menu = "Graves_Magic"
	self.Use_Combo_Q = self:MenuBool("Use Combo Q", true)
	self.Auto_Q_End_Dash = self:MenuBool("Auto Q End Dash", true)
	self.Auto_Q_If_Wall = self:MenuBool("Auto Q If Wall", true)
	self.Auto_Q_Kill_Steal = self:MenuBool("Auto Q Kill Steal", true)

	self.Use_Combo_W = self:MenuBool("Use Combo W", false)
	self.Use_W_Anti_GapClose = self:MenuBool("Use W Anti GapClose", true)
	self.Use_W_End_Dash = self:MenuBool("Use W End Dash", true)
	self.Auto_W_Kill_Steal = self:MenuBool("Auto W Kill Steal", true)

	self.Enable_E = self:MenuBool("Enable E", true)
	self.Enable_E_Reload_JungFarm = self:MenuBool("Enable E Reload JungFarm", true)
	self.E_Mode = self:MenuComboBox("E Mode", 2)

	self.Enable_R = self:MenuBool("Enable R", true)
	self.Auto_R_if_Hit = self:MenuSliderInt("Auto R if Hit", 2)
	self.Use_R_Kill_Steal = self:MenuBool("Use R Kill Steal", true)

	self.Use_Smite_Kill_Steal = self:MenuBool("Use Smite Kill Steal", true)
	self.Use_Smite_in_Combo = self:MenuBool("Use Smite in Combo", true)
	self.Use_Smite_Small_Jungle = self:MenuBool("Use Smite Small Jungle", true)
	self.Use_Smite_Blue = self:MenuBool("Use Smite Blue", true)
	self.Use_Smite_Red = self:MenuBool("Use Smite Red", true)
	self.Use_Smite_Dragon = self:MenuBool("Use Smite Dragon", true)
	self.Use_Smite_Baron = self:MenuBool("Use Smite Baron", true)

	self.Draw_When_Already = self:MenuBool("Draw When Already", true)
	self.Draw_Q_Range = self:MenuBool("Draw Q Range", true)
	self.Draw_W_Range = self:MenuBool("Draw W Range", true)
	self.Draw_E_Range = self:MenuBool("Draw E Range", true)
	self.Draw_R_Range = self:MenuBool("Draw R Range", true)
	self.Draw_R2_Range = self:MenuBool("Draw R2 Range", true)

	self.Enalble_Mod_Skin = self:MenuBool("Enalble Mod Skin", true)
	self.Set_Skin = self:MenuSliderInt("Set Skin", 16)

	self.Combo = self:MenuKeyBinding("Combo", 32)
	self.Harass = self:MenuKeyBinding("Harass", 67)
	self.Lane_Clear = self:MenuKeyBinding("Lane Clear", 86)
	self.Last_Hit = self:MenuKeyBinding("Last Hit", 88)
end

function Graves:OnDrawMenu()
	if Menu_Begin(self.menu) then
		if Menu_Begin("Setting Q") then
			self.Use_Combo_Q = Menu_Bool("Use Combo Q", self.Use_Combo_Q, self.menu)
			self.Auto_Q_End_Dash = Menu_Bool("Auto Q End Dash", self.Auto_Q_End_Dash, self.menu)
			self.Auto_Q_If_Wall = Menu_Bool("Auto Q If Wall", self.Auto_Q_If_Wall, self.menu)
			self.Auto_Q_Kill_Steal = Menu_Bool("Auto Q Kill Steal", self.Auto_Q_Kill_Steal, self.menu)
			Menu_End()
		end
		if Menu_Begin("Setting W") then
			self.Use_Combo_W = Menu_Bool("Use Combo W", self.Use_Combo_W, self.menu)
			self.Use_W_Anti_GapClose = Menu_Bool("Use W Anti GapClose", self.Use_W_Anti_GapClose, self.menu)
			self.Use_W_End_Dash = Menu_Bool("Use W End Dash", self.Use_W_End_Dash, self.menu)
			self.Auto_W_Kill_Steal = Menu_Bool("Auto W Kill Steal", self.Auto_W_Kill_Steal, self.menu)
			Menu_End()
		end
		if Menu_Begin("Setting E") then
			self.Enable_E = Menu_Bool("Enable E", self.Enable_E, self.menu)
			self.Enable_E_Reload_JungFarm = Menu_Bool("Enable E Reload JungFarm", self.Enable_E_Reload_JungFarm, self.menu)
			self.E_Mode = Menu_ComboBox("E Mode", self.E_Mode, "Mouse\0Side\0Safe position\0\0\0", self.menu)		
			Menu_End()
		end
		if Menu_Begin("Setting R") then
			self.Enable_R = Menu_Bool("Enable R", self.Enable_R, self.menu)
			self.Auto_R_if_Hit = Menu_SliderInt("Auto R if Hit", self.Auto_R_if_Hit, 1, 5, self.menu)
			self.Use_R_Kill_Steal = Menu_Bool("Use R Kill Steal", self.Use_R_Kill_Steal, self.menu)
			Menu_End()
		end
		if Menu_Begin("Setting Smite") then
			Menu_Text("Smite In Combo")
			self.Use_Smite_Kill_Steal = Menu_Bool("Use Smite Kill Steal", self.Use_Smite_Kill_Steal, self.menu)
			self.Use_Smite_in_Combo = Menu_Bool("Use Smite in Combo", self.Use_Smite_in_Combo, self.menu)
			Menu_Text("Smite In Jungle")
			self.Use_Smite_Small_Jungle = Menu_Bool("Use Smite Small Jungle", self.Use_Smite_Small_Jungle, self.menu)
			self.Use_Smite_Blue = Menu_Bool("Use Smite Blue", self.Use_Smite_Blue, self.menu)
			self.Use_Smite_Red = Menu_Bool("Use Smite Red", self.Use_Smite_Red, self.menu)
			self.Use_Smite_Dragon = Menu_Bool("Use Smite Dragon", self.Use_Smite_Dragon, self.menu)
			self.Use_Smite_Baron = Menu_Bool("Use Smite Baron", self.Use_Smite_Baron, self.menu)
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

function Graves:OnAfterAttack(unit, target)
	if unit.IsMe then
		if CanCast(_E) and GetKeyPress(self.Combo) > 0 and self.Enable_E then
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


function Graves:OnTick()
	if IsDead(myHero.Addr) then return end
	SetLuaCombo(true)

	self:AutoQW()

	self:KillSteal()

	self:LogicSmiteJungle()

	self:AntiGapCloser()

	if GetKeyPress(self.Combo) > 0 then	
		self:LogicQ()
		self:LogicW()
		self:LogicR()
	end

	if self.Enalble_Mod_Skin then
		ModSkin(self.Set_Skin)
	end
end



function Graves:JungleTbl()
    GetAllUnitAroundAnObject(myHero.Addr, 2000)
    local result = {}
    for i, minions in pairs(pUnit) do
        if minions ~= 0 and not IsDead(minions) and not IsInFog(minions) and GetType(minions) == 3 then
            table.insert(result, minions)
        end
    end

    return result
end

function Graves:GetIndexSmite()
	if GetSpellIndexByName("SummonerSmite") > -1 then
		return GetSpellIndexByName("SummonerSmite")
	elseif GetSpellIndexByName("S5_SummonerSmiteDuel") > -1 then
		return GetSpellIndexByName("S5_SummonerSmiteDuel")
	elseif GetSpellIndexByName("S5_SummonerSmitePlayerGanker") > -1 then
		return GetSpellIndexByName("S5_SummonerSmitePlayerGanker")
	end
	return -1
end

function Graves:GetSmiteDamage(target)
	if self:GetIndexSmite() > -1 then
		if GetType(target) == 0 then
			if GetSpellNameByIndex(myHero.Addr, self:GetIndexSmite()) == "S5_SummonerSmitePlayerGanker" then
				return 20 + 8*myHero.Level;
			end
			if GetSpellNameByIndex(myHero.Addr, self:GetIndexSmite()) == "S5_SummonerSmiteDuel" then
				return 54 + 6*myHero.Level;
			end

		end
		local DamageSpellSmiteTable = {390, 410, 430, 450, 480, 510, 540, 570, 600, 640, 680, 720, 760, 800, 850, 900, 950, 1000}
		return DamageSpellSmiteTable[myHero.Level]
	end
	return 0
end

function Graves:LogicSmiteJungle()
	for i, minions in ipairs(self:JungleTbl()) do
        if minions ~= 0 then
            local jungle = GetUnit(minions)
            if jungle.Type == 3 and jungle.TeamId == 300 and GetDistance(jungle.Addr) < GetTrueAttackRange() and
                (GetObjName(jungle.Addr) ~= "PlantSatchel" and GetObjName(jungle.Addr) ~= "PlantHealth" and GetObjName(jungle.Addr) ~= "PlantVision") then

                if IsValidTarget(jungle.Addr, 650) and self:GetSmiteDamage(jungle.Addr) > jungle.HP and jungle.CharName == "SRU_Red" and self.Use_Smite_Red then
                    CastSpellTarget(jungle.Addr, self:GetIndexSmite())
                end
                if IsValidTarget(jungle.Addr, 650) and self:GetSmiteDamage(jungle.Addr) > jungle.HP and jungle.CharName == "SRU_Blue" and self.Use_Smite_Blue then
                    CastSpellTarget(jungle.Addr, self:GetIndexSmite())
                end

                if IsValidTarget(jungle.Addr, 650) and self:GetSmiteDamage(jungle.Addr) > jungle.HP and jungle.CharName == "SRU_RiftHerald" and self.Use_Smite_Baron then
                    CastSpellTarget(jungle.Addr, self:GetIndexSmite())
                end

                if IsValidTarget(jungle.Addr, 650) and self:GetSmiteDamage(jungle.Addr) > jungle.HP and jungle.CharName == "SRU_Baron" and self.Use_Smite_Baron then
                    CastSpellTarget(jungle.Addr, self:GetIndexSmite())
                end

                if IsValidTarget(jungle.Addr, 650) and self:GetSmiteDamage(jungle.Addr) > jungle.HP and self.Use_Smite_Small_Jungle then
                	if jungle.CharName == "SRU_Razorbeak" or jungle.CharName == "SRU_Murkwolf" or jungle.CharName == "SRU_Gromp" or jungle.CharName == "SRU_Krug" then
                    	CastSpellTarget(jungle.Addr, self:GetIndexSmite())
                	end
                end

                if IsValidTarget(jungle.Addr, 650) and self:GetSmiteDamage(jungle.Addr) > jungle.HP and jungle.CharName:find("SRU_Dragon") and self.Use_Smite_Dragon then
                    CastSpellTarget(jungle.Addr, self:GetIndexSmite())
                end
            end
        end
    end
end

function Graves:LogicE()
	local TargetE = self.menu_ts:GetTarget(GetTrueAttackRange())
	if CanCast(_E) and TargetE ~= 0 then
		target = GetAIHero(TargetE)
		if target.IsMelee then
			local dashPos = self:CastDash(true);
			if dashPos ~= Vector(0, 0, 0) then
				CastSpellToPos(dashPos.x,dashPos.z, _E)
			end
		end
	end

	if GetKeyPress(self.Combo) > 0 and myHero.MP > 140 and not myHero.HasBuff("gravesbasicattackammo2") then
		local dashPos = self:CastDash();
		if CanCast(_E) and dashPos ~= Vector(0, 0, 0) then
			CastSpellToPos(dashPos.x,dashPos.z, _E)
		end
	end
end

function Graves:LogicQ()
	local TargetQ = self.menu_ts:GetTarget(self.Q.range)
	if CanCast(_Q) and TargetQ ~= 0 then
		target = GetAIHero(TargetQ)
		local CastPosition, HitChance, Position = self.vpred:GetLineCastPosition(target, self.Q.delay, self.Q.width, self.Q.range, self.Q.speed, myHero, false)
		local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
    	--local QPred = myHeroPos:Extended(CastPosition, self.Q.range - 100) --endPosition

		if TargetQ ~= nil then
			if (GetDistance(TargetQ) < self.Q.range - 100 and GetDistance(TargetQ) > 300  or (self:IsImmobileTarget(TargetQ))) then
				if self:GetIndexSmite() > -1 and self.Use_Smite_in_Combo then
					CastSpellTarget(TargetQ, self:GetIndexSmite())
				end
				if CastPosition and HitChance >= 2 and self.Use_Combo_Q then
		        	CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
		    	end
		    end
		end
	end
end

function Graves:LogicW()
	local TargetW = self.menu_ts:GetTarget(self.W.range)
	if CanCast(_W) and TargetW ~= 0 then
		target = GetAIHero(TargetW)
		local CastPosition, HitChance, Position = self.vpred:GetCircularCastPosition(target, self.W.delay, self.W.width, self.W.range, self.W.speed, myHero, false)
		local TargetDashing, CanHitDashing, DashPosition = self.vpred:IsDashing(target, self.W.delay, self.W.width, self.W.speed, myHero, false)
		local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)

		if TargetW ~= nil then
			if (GetDistance(TargetW) < self.W.range - 100 and GetDistance(TargetW) > 300  or self:IsImmobileTarget(TargetW)) then
				if self:GetIndexSmite() > -1 and self.Use_Smite_in_Combo then
					CastSpellTarget(TargetW, self:GetIndexSmite())
				end

				if CastPosition and HitChance >= 2 and self.Use_Combo_W then
		        	CastSpellToPos(CastPosition.x, CastPosition.z, _W)
		    	end
		    end
		end

		if DashPosition ~= nil then
			if GetDistance(DashPosition) <= 300 and self.Use_W_Anti_GapClose then
	    		CastSpellToPos(DashPosition.x, DashPosition.z, _W)
	    	end
		end
	end
end

function Graves:LogicR()
	local TargetR = self.menu_ts:GetTarget(self.R.range)
	if CanCast(_R) and TargetR ~= 0 then
		target = GetAIHero(TargetR)
		local CastPosition, HitChance, Position = self.vpred:GetLineCastPosition(target, self.R.delay, self.R.width, self.R.range, self.R.speed, myHero, false)
		--__PrintTextGame(tostring(self:CountEnemyInLine(target)).."--"..tostring(self:MenuSliderInt("Auto R if Hit")))
		if HitChance >= 2 and self:CountEnemyInLine(target) > self.Auto_R_if_Hit then
			CastSpellToPos(CastPosition.x, CastPosition.z, _R)
		end
	end
end

function Graves:AutoQW()
	local TargetQ = self.menu_ts:GetTarget(self.Q.range)
	if CanCast(_Q) and TargetQ ~= 0 then
		target = GetAIHero(TargetQ)
		local CastPosition, HitChance, Position = self.vpred:GetLineCastPosition(target, self.Q.delay, self.Q.width, self.Q.range, self.Q.speed, myHero, false)
		local TargetDashing, CanHitDashing, DashPosition = self.vpred:IsDashing(target, self.Q.delay, self.Q.width, self.Q.speed, myHero, false)
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

	local TargetW = self.menu_ts:GetTarget(self.W.range)
	if CanCast(_W) and TargetW ~= 0 then
		target = GetAIHero(TargetW)
		local CastPosition, HitChance, Position = self.vpred:GetCircularCastPosition(target, self.W.delay, self.W.width, self.W.range, self.W.speed, myHero, false)
		local TargetDashing, CanHitDashing, DashPosition = self.vpred:IsDashing(target, self.W.delay, self.W.width, self.W.speed, myHero, false)
		local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)

	    if DashPosition ~= nil then
	    	if GetDistance(DashPosition) <= self.W.range and self.Use_W_End_Dash then
	    		CastSpellToPos(DashPosition.x, DashPosition.z, _W)
	    	end
		end
	end
end

function Graves:KillSteal()
	local TargetR = self.menu_ts:GetTarget(self.R.range)
	if TargetR ~= nil and IsValidTarget(TargetR, self.R.range) and CanCast(_R) and self.Use_R_Kill_Steal then
		targetR = GetAIHero(TargetR)

		local CastPosition, HitChance, Position = self.vpred:GetLineCastPosition(targetR, self.R.delay, self.R.width, self.R.range, self.R.speed, myHero, false)
		if GetDistance(TargetR) < self.R.range and GetDamage("R", targetR) > GetHealthPoint(TargetR) then
			CastSpellToPos(CastPosition.x, CastPosition.z, _R)
		end
	end

	local TargetQ = self.menu_ts:GetTarget(self.Q.range)
	if TargetQ ~= nil and IsValidTarget(TargetQ, self.Q.range) and CanCast(_Q) and self.Auto_Q_Kill_Steal then
		targetQ = GetAIHero(TargetQ)

		local CastPosition, HitChance, Position = self.vpred:GetLineCastPosition(targetQ, self.Q.delay, self.Q.width, self.Q.range, self.Q.speed, myHero, false)
		if GetDistance(TargetQ) < self.Q.range and GetDamage("Q", targetQ) > GetHealthPoint(TargetQ) then
			CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
		end
	end

	local TargetW = self.menu_ts:GetTarget(self.W.range)
	if TargetW ~= nil and IsValidTarget(TargetW, self.W.range) and CanCast(_W) and self.Auto_W_Kill_Steal then
		targetW = GetAIHero(TargetW)
		local CastPosition, HitChance, Position = self.vpred:GetLineCastPosition(targetW, self.W.delay, self.W.width, self.W.range, self.W.speed, myHero, false)
		if GetDistance(TargetW) < self.W.range and GetDamage("W", targetW) > GetHealthPoint(TargetW) then
			CastSpellToPos(CastPosition.x, CastPosition.z, _W)
		end
	end

	local TargetSmite = self.menu_ts:GetTarget(650)
	if TargetSmite ~= nil and IsValidTarget(TargetSmite, 650) and CanCast(self:GetIndexSmite()) and self.Use_Smite_Kill_Steal then
		if self:GetSmiteDamage(TargetSmite) > GetHealthPoint(TargetSmite) then
			CastSpellTarget(TargetSmite, self:GetIndexSmite())
		end
	end
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
    	local orbT = orbwalk:GetTargetOrb()
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
  --if not "AAcheck" then
    --return true
  --end
  if GetType(orbwalk:GetTargetOrb()) == 0 then
    --local targetpos = GetPos(orbwalk:GetTargetOrb())
    local target = GetAIHero(orbwalk:GetTargetOrb())
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
      		if hero.IsDash then
        		local TargetDashing, CanHitDashing, DashPosition = self.vpred:IsDashing(hero, 0.09, 65, 2000, myHero, false)
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
