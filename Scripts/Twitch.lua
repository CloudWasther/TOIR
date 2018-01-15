IncludeFile("Lib\\TOIR_SDK.lua")
IncludeFile("Lib\\OrbCustom.lua")
--IncludeFile("Lib\\AntiGapCloser.lua")

Twitch = class()

function OnLoad()
	if GetChampName(GetMyChamp()) == "Twitch" then
		Twitch:__init()
	end
end

function Twitch:__init()
	--orbwalk = Orbwalking()

	-- VPrediction
	vpred = VPrediction(true)

	--TS
    self.menu_ts = TargetSelector(1750, 0, myHero, true, true, true)

	self.Q = Spell(_Q, GetTrueAttackRange())
    self.W = Spell(_W, 1050)
    self.E = Spell(_E, 1350)
    self.R = Spell(_R, GetTrueAttackRange() + 300)
    self.Q:SetActive()
    self.W:SetSkillShot(0.25, 1750, 300, true)
    self.E:SetActive()
    self.R:SetActive()

	Callback.Add("Tick", function(...) self:OnTick(...) end)
    Callback.Add("Draw", function(...) self:OnDraw(...) end)
    Callback.Add("ProcessSpell", function(...) self:OnProcessSpell(...) end)

    Callback.Add("DrawMenu", function(...) self:OnDrawMenu(...) end)

    self:MenuValueDefault()

    --self.JungleMobs = minionManager(MINION_JUNGLE, 2000, myHero, MINION_SORT_MAXHEALTH_DEC)
end

function Twitch:MenuValueDefault()
	self.menu = "Twitch_Magic"
	self.menu_Combo_Q = self:MenuBool("Use Q In Combo", true)
	self.menu_Combo_QCount = self:MenuSliderInt("Auto Q if Have", 3)
	self.menu_Combo_QRecall = self:MenuKeyBinding("Safe Recall", 66)

	self.menu_Combo_W = self:MenuBool("Auto Use W Combo", false)
	self.menu_Combo_Wmode = self:MenuComboBox("W Mode", 2)
	self.menu_Combo_Wgap = self:MenuBool("Use W Anti GapClose", true)
	self.menu_Combo_WendDash = self:MenuBool("Use W End Dash", true)
	self.menu_Combo_WCount = self:MenuSliderInt("Auto W if Hit", 2)

	self.menu_Combo_E = self:MenuComboBox("Mode Target", 1)
	self.menu_Combo_EAuto = self:MenuSliderInt("Auto E Out Range & Stack", 3)
	self.menu_Combo_EKs = self:MenuBool("Auto E Kill Steal", true)
	self.menu_Combo_EKsBlue = self:MenuBool("Auto E KS Blue", true)
	self.menu_Combo_EKsRed = self:MenuBool("Auto E KS Red", true)
	self.menu_Combo_EKsDragon = self:MenuBool("Auto E KS Dragon", true)
	self.menu_Combo_EKsBaron = self:MenuBool("Auto E KS Baron", true)

	self.menu_Combo_R = self:MenuBool("Use R In Combo", true)
	self.menu_Combo_RCount = self:MenuSliderInt("Auto R If Have Enemy", 2)

	self.menu_Combo_Smiteks = self:MenuBool("Use Smite Kill Steal", true)
	self.menu_Combo_Smite = self:MenuBool("Use Smite in Combo", true)
	self.menu_Combo_SmiteSmall = self:MenuBool("Use Smite Small Jungle", true)
	self.menu_Combo_SmiteBlue = self:MenuBool("Use Smite Blue", true)
	self.menu_Combo_SmiteRed = self:MenuBool("Use Smite Red", true)
	self.menu_Combo_SmiteDragon = self:MenuBool("Use Smite Dragon", true)
	self.menu_Combo_SmiteBaron = self:MenuBool("Use Smite Baron", true)

	self.menu_Draw_Already = self:MenuBool("Draw When Already", true)
	self.menu_Draw_Q = self:MenuBool("Draw Q Time Stealth", true)
	self.menu_Draw_Qrange = self:MenuBool("Draw Q Range", true)
	self.menu_Draw_W = self:MenuBool("Draw W Range", true)
	self.menu_Draw_Erange = self:MenuBool("Draw E Range", true)
	self.menu_Draw_E = self:MenuBool("Draw E Damage", true)
	self.menu_Draw_R = self:MenuBool("Draw R Range", true)

	self.Enalble_Mod_Skin = self:MenuBool("Enalble Mod Skin", true)
	self.Set_Skin = self:MenuSliderInt("Set Skin", 10)

	self.Combo = self:MenuKeyBinding("Combo", 32)
	self.Harass = self:MenuKeyBinding("Harass", 67)
	self.Lane_Clear = self:MenuKeyBinding("Lane Clear", 86)
	self.Last_Hit = self:MenuKeyBinding("Last Hit", 88)
end

function Twitch:OnDrawMenu()
	if Menu_Begin(self.menu) then
		if Menu_Begin("Setting Q") then
			self.menu_Combo_Q = Menu_Bool("Use Q In Combo", self.menu_Combo_Q, self.menu)
			self.menu_Combo_QCount = Menu_SliderInt("Auto Q if Have", self.menu_Combo_QCount, 0, 5, self.menu)
			self.menu_Combo_QRecall = Menu_KeyBinding("Safe Recall", self.menu_Combo_QRecall, self.menu)
			Menu_End()
		end
		if Menu_Begin("Setting W") then
			self.menu_Combo_W = Menu_Bool("Auto Use W Combo", self.menu_Combo_W, self.menu)
			self.menu_Combo_Wmode = Menu_ComboBox("W Mode", self.menu_Combo_Wmode, "Normal\0Behind Target\0Front Target\0\0", self.menu)	
			self.menu_Combo_Wgap = Menu_Bool("Use W Anti GapClose", self.menu_Combo_Wgap, self.menu)
			self.menu_Combo_WendDash = Menu_Bool("Use W End Dash", self.menu_Combo_WendDash, self.menu)
			self.menu_Combo_WCount = Menu_SliderInt("Auto W if Hit", self.menu_Combo_WCount, 1, 5, self.menu)
			Menu_End()
		end
		if Menu_Begin("Setting E") then
			--self.menu_Combo_E = Menu_ComboBox("Mode Target", self.menu_Combo_E, "Normal\0Have E\0\0\0\0", self.menu)
			self.menu_Combo_EAuto = Menu_SliderInt("Auto E Out Range & Stack", self.menu_Combo_EAuto, 1, 6, self.menu)
			self.menu_Combo_EKs = Menu_Bool("Auto E Kill Steal", self.menu_Combo_EKs, self.menu)
			Menu_Text("E In Jungle")
			self.menu_Combo_EKsBlue = Menu_Bool("Auto E KS Blue", self.menu_Combo_EKsBlue, self.menu)
			self.menu_Combo_EKsRed = Menu_Bool("Auto E KS Red", self.menu_Combo_EKsRed, self.menu)
			self.menu_Combo_EKsDragon = Menu_Bool("Auto E KS Dragon", self.menu_Combo_EKsDragon, self.menu)
			self.menu_Combo_EKsBaron = Menu_Bool("Auto E KS Baron", self.menu_Combo_EKsBaron, self.menu)					
			Menu_End()
		end
		if Menu_Begin("Setting R") then
			self.menu_Combo_R = Menu_Bool("Use R In Combo", self.menu_Combo_R, self.menu)
			self.menu_Combo_RCount = Menu_SliderInt("Auto R If Have Enemy", self.menu_Combo_RCount, 1, 5, self.menu)
			Menu_End()
		end
		if Menu_Begin("Setting Smite") then
			Menu_Text("Smite In Combo")
			self.menu_Combo_Smiteks = Menu_Bool("Use Smite Kill Steal", self.menu_Combo_Smiteks, self.menu)
			self.menu_Combo_Smite = Menu_Bool("Use Smite in Combo", self.menu_Combo_Smite, self.menu)
			Menu_Text("Smite In Jungle")
			self.menu_Combo_SmiteSmall = Menu_Bool("Use Smite Small Jungle", self.menu_Combo_SmiteSmall, self.menu)
			self.menu_Combo_SmiteBlue = Menu_Bool("Use Smite Blue", self.menu_Combo_SmiteBlue, self.menu)
			self.menu_Combo_SmiteRed = Menu_Bool("Use Smite Red", self.menu_Combo_SmiteRed, self.menu)
			self.menu_Combo_SmiteDragon = Menu_Bool("Use Smite Dragon", self.menu_Combo_SmiteDragon, self.menu)
			self.menu_Combo_SmiteBaron = Menu_Bool("Use Smite Baron", self.menu_Combo_SmiteBaron, self.menu)
			Menu_End()
		end
		if Menu_Begin("Draw Spell") then
			self.menu_Draw_Already = Menu_Bool("Draw When Already", self.menu_Draw_Already, self.menu)
			self.menu_Draw_Q = Menu_Bool("Draw Q Time Stealth", self.menu_Draw_Q, self.menu)
			self.menu_Draw_Qrange = Menu_Bool("Draw Q Range", self.menu_Draw_Qrange, self.menu)
			self.menu_Draw_W = Menu_Bool("Draw W Range", self.menu_Draw_W, self.menu)
			self.menu_Draw_Erange = Menu_Bool("Draw E Range", self.menu_Draw_Erange, self.menu)
			self.menu_Draw_E = Menu_Bool("Draw E Damage", self.menu_Draw_E, self.menu)
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

function Twitch:MenuBool(stringKey, bool)
	return ReadIniBoolean(self.menu, stringKey, bool)
end

function Twitch:MenuSliderInt(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Twitch:MenuSliderFloat(stringKey, valueDefault)
	return ReadIniFloat(self.menu, stringKey, valueDefault)
end

function Twitch:MenuComboBox(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Twitch:MenuKeyBinding(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Twitch:OnTick()
	if myHero.IsDead then return end
	SetLuaCombo(true)

	self:AutoQ()
	self:AutoW()
	self:AutoE()
	self:AutoR()
	self:ReCall()

	self:KillSteal()

	self:LogicSmiteJungle()

	if GetKeyPress(self.Combo) > 0 then
		
		self:LogicQ()
		self:LogicW()
		self:LogicE()
		self:LogicR()
	end

	if self.Enalble_Mod_Skin then
		ModSkin(self.Set_Skin)
	end
end

function Twitch:GetIndexSmite()
	if GetSpellIndexByName("SummonerSmite") > -1 then
		return GetSpellIndexByName("SummonerSmite")
	elseif GetSpellIndexByName("S5_SummonerSmiteDuel") > -1 then
		return GetSpellIndexByName("S5_SummonerSmiteDuel")
	elseif GetSpellIndexByName("S5_SummonerSmitePlayerGanker") > -1 then
		return GetSpellIndexByName("S5_SummonerSmitePlayerGanker")
	end
	return -1
end

function Twitch:GetIndexRecall()
	if GetSpellIndexByName("recall") > -1 then
		return GetSpellIndexByName("recall")
	end
	return -1
end

function Twitch:GetSmiteDamage(target)
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

function Twitch:JungleTbl()
    GetAllUnitAroundAnObject(myHero.Addr, 2000)
    local result = {}
    for i, minions in pairs(pUnit) do
        if minions ~= 0 and not IsDead(minions) and not IsInFog(minions) and GetType(minions) == 3 then
            table.insert(result, minions)
        end
    end

    return result
end

function Twitch:LogicSmiteJungle()
	for i, minions in ipairs(self:JungleTbl()) do
        if minions ~= 0 then
            local jungle = GetUnit(minions)
            if jungle.Type == 3 and jungle.TeamId == 300 and GetDistance(jungle.Addr) < GetTrueAttackRange() and
                (GetObjName(jungle.Addr) ~= "PlantSatchel" and GetObjName(jungle.Addr) ~= "PlantHealth" and GetObjName(jungle.Addr) ~= "PlantVision") then

                if IsValidTarget(jungle.Addr, 650) and self:GetSmiteDamage(jungle.Addr) > jungle.HP and jungle.CharName == "SRU_Red" and self.menu_Combo_SmiteRed then
                    CastSpellTarget(jungle.Addr, self:GetIndexSmite())
                end
                if IsValidTarget(jungle.Addr, 650) and self:GetSmiteDamage(jungle.Addr) > jungle.HP and jungle.CharName == "SRU_Blue" and self.menu_Combo_SmiteBlue then
                    CastSpellTarget(jungle.Addr, self:GetIndexSmite())
                end

                if IsValidTarget(jungle.Addr, 650) and self:GetSmiteDamage(jungle.Addr) > jungle.HP and jungle.CharName == "SRU_RiftHerald" and self.menu_Combo_SmiteDragon then
                    CastSpellTarget(jungle.Addr, self:GetIndexSmite())
                end

                if IsValidTarget(jungle.Addr, 650) and self:GetSmiteDamage(jungle.Addr) > jungle.HP and jungle.CharName == "SRU_Baron" and self.menu_Combo_SmiteBaron then
                    CastSpellTarget(jungle.Addr, self:GetIndexSmite())
                end

                if IsValidTarget(jungle.Addr, 650) and self:GetSmiteDamage(jungle.Addr) > jungle.HP and self.menu_Combo_SmiteSmall then
                	if jungle.CharName == "SRU_Razorbeak" or jungle.CharName == "SRU_Murkwolf" or jungle.CharName == "SRU_Gromp" or jungle.CharName == "SRU_Krug" then
                    	CastSpellTarget(jungle.Addr, self:GetIndexSmite())
                	end
                end

                if IsValidTarget(jungle.Addr, 650) and self:GetSmiteDamage(jungle.Addr) > jungle.HP and jungle.CharName:find("SRU_Dragon") and self.menu_Combo_SmiteDragon then
                    CastSpellTarget(jungle.Addr, self:GetIndexSmite())
                end
            end
        end
    end
end

function Twitch:LogicQ()
    local orbT = GetTargetOrb()
	if orbT ~= nil and GetType(orbT) == 0 then
		if myHero.MP > 180 and GetDistance(orbT) < GetTrueAttackRange() and self.menu_Combo_Q and CanCast(_Q) then
			CastSpellTarget(myHero.Addr, _Q)
		end
	end
end

function Twitch:LogicW()
	local TargetW = self.menu_ts:GetTarget(self.W.range - 150)
	if CanCast(_W) and TargetW ~= 0 then
		target = GetAIHero(TargetW)
		local CastPosition, HitChance, Position = vpred:GetCircularCastPosition(target, self.W.delay, self.W.width, self.W.range, self.W.speed, myHero, false)
		local TargetDashing, CanHitDashing, DashPosition = vpred:IsDashing(target, self.W.delay, self.W.width, self.W.speed, myHero, false)
		local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)

		if (GetDistance(target.Addr) < self.W.range - 300 and GetDistance(target.Addr) > 300  or self:IsImmobileTarget(TargetW)) then
			if self:GetIndexSmite() > -1 and self.menu_Combo_Smite then
				CastSpellTarget(TargetW, self:GetIndexSmite())
			end
			if self.menu_Combo_W then
				if CastPosition and HitChance >= 2 and self.menu_Combo_Wmode == 0 then
		        	CastSpellToPos(CastPosition.x, CastPosition.z, _W)
		    	end
		    	if CastPosition and HitChance >= 2 and self.menu_Combo_Wmode == 1 then
		    		posBehind = CastPosition:Extended(myHero, -150)
		        	CastSpellToPos(posBehind.x, posBehind.z, _W)
		    	end
		    	if CastPosition and HitChance >= 2 and self.menu_Combo_Wmode == 2 then
		    		posFront = CastPosition:Extended(myHero, 150)
		        	CastSpellToPos(posFront.x, posFront.z, _W)
		    	end
		    end
		end

		if DashPosition ~= nil then
			if GetDistance(DashPosition) <= 300 and self.menu_Combo_Wgap then
	    		CastSpellToPos(DashPosition.x, DashPosition.z, _W)
	    	end
		end
	end
end

function Twitch:LogicE()
	if self.menu_Combo_E == 2 then
		local target = self:GetTargetBuffE(GetTrueAttackRange() + 50)
		--ForceTarget(target)
	end
end

function Twitch:LogicR()
    local orbT = GetTargetOrb()
	if orbT ~= nil and GetType(orbT) == 0 and myHero.MP > 140 and self.menu_Combo_R and CanCast(_R) then
		CastSpellTarget(myHero.Addr, _Q)
	end
end

function Twitch:AutoQ()
    if CountEnemyChampAroundObject(myHero.Addr, 650) >= self.menu_Combo_QCount and CountAllyChampAroundObject(myHero.Addr, 650) < CountEnemyChampAroundObject(myHero.Addr, 650) and CanCast(_Q) then
    	CastSpellTarget(myHero.Addr, _Q)
    end
end

function Twitch:AutoW()
	local TargetW = self.menu_ts:GetTarget(self.W.range - 150)
	if CanCast(_W) and TargetW ~= 0 then
		target = GetAIHero(TargetW)
		local CastPosition, HitChance, Position = vpred:GetCircularCastPosition(target, self.W.delay, self.W.width, self.W.range, self.W.speed, myHero, false)
		local TargetDashing, CanHitDashing, DashPosition = vpred:IsDashing(target, self.W.delay, self.W.width, self.W.speed, myHero, false)
		local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)

	    if DashPosition ~= nil then
	    	if GetDistance(DashPosition) <= self.W.range and self.menu_Combo_WendDash then
	    		CastSpellToPos(DashPosition.x, DashPosition.z, _W)
	    	end
		end
	end
end

function Twitch:AutoE()
	local target = self:GetTargetBuffE(self.E.range)
	if target ~= nil then		
		targetE = GetAIHero(target)	
		--__PrintTextGame(tostring(self:GetStackBuffE(target)))
		--if self:GetStackBuffE(target) >= self.menu_Combo_ECount and CanCast(_E) then
			--CastSpellTarget(myHero.Addr, _E)
		--end
		
		if IsValidTarget(targetE.Addr, self.E.range) and self:GetStackBuffE(target) >= self.menu_Combo_EAuto and GetDistance(targetE.Addr) >= self.E.range * 0.80 and CanCast(_E) then
			--__PrintTextGame(tostring(GetDistance(target)))
			CastSpellTarget(myHero.Addr, _E)
		end
	end
	--self.JungleMobs:update()
    for i, minions in ipairs(self:JungleTbl()) do
        if minions ~= 0 then
            local jungle = GetUnit(minions)
            if jungle.Type == 3 and jungle.TeamId == 300 and GetDistance(jungle.Addr) < self.E.range and
                (GetObjName(jungle.Addr) ~= "PlantSatchel" and GetObjName(jungle.Addr) ~= "PlantHealth" and GetObjName(jungle.Addr) ~= "PlantVision") then
                --local stack = GetBuff(GetBuffByName(jungle.Addr, "TwitchDeadlyVenom"))
                --__PrintTextGame(tostring(self:getEDmg(jungle)))
                if IsValidTarget(jungle.Addr, self.E.range) and self:getEDmg(jungle) > jungle.HP and jungle.CharName == "SRU_Red" and self.menu_Combo_EKsRed then
                    CastSpellTarget(jungle.Addr, _E)
                end

                if IsValidTarget(jungle.Addr, self.E.range) and self:getEDmg(jungle) > jungle.HP and jungle.CharName == "SRU_Blue" and self.menu_Combo_EKsBlue then
                    CastSpellTarget(jungle.Addr, _E)
                end

                if IsValidTarget(jungle.Addr, self.E.range) and self:getEDmg(jungle) > jungle.HP and jungle.CharName == "SRU_RiftHerald" and self.menu_Combo_SmiteRed then
                    CastSpellTarget(jungle.Addr, _E)
                end

                if IsValidTarget(jungle.Addr, self.E.range) and self:getEDmg(jungle) > jungle.HP and jungle.CharName == "SRU_Baron" and self.menu_Combo_EKsBaron then
                    CastSpellTarget(jungle.Addr, _E)
                end

                if IsValidTarget(jungle.Addr, self.E.range) and self:getEDmg(jungle) > jungle.HP and jungle.CharName:find("SRU_Dragon") and self.menu_Combo_EKsDragon then
                    CastSpellTarget(jungle.Addr, _E)
                end
            end
        end
    end
end

function Twitch:AutoR()
	if CountEnemyChampAroundObject(myHero.Addr, 650) >= self.menu_Combo_RCount and CountAllyChampAroundObject(myHero.Addr, 650) < CountEnemyChampAroundObject(myHero.Addr, 650) and CanCast(_R) then
    	CastSpellTarget(myHero.Addr, _R)
    end
end

function Twitch:GetStackBuffE(target)
	if target ~= nil then
		if GetBuffByName(target, "TwitchDeadlyVenom") ~= 0 then
			local stack = GetBuff(GetBuffByName(target, "TwitchDeadlyVenom"))
			return stack.Count
		else
			return 0
		end
	end
	return 0
end

function Twitch:GetTargetBuffE(range)
    local result = nil
    local N = math.huge
    for i,hero in pairs(GetEnemyHeroes()) do
        if hero~= 0 and IsValidTarget(hero, range) and GetBuffByName(hero, "TwitchDeadlyVenom") ~= 0 then
        	table.sort(GetEnemyHeroes(), function(a, b) return self:GetStackBuffE(a) > self:GetStackBuffE(b) end)
            local dmgtohero = GetAADamageHitEnemy(hero) or 1
            local tokill = GetHealthPoint(hero)/dmgtohero
            if tokill < N or result == nil then
                N = tokill
                result = hero
            end
        end
    end
    return result
end

function Twitch:KillSteal()
	for i,hero in pairs(GetEnemyHeroes()) do
        if hero~= 0 and IsValidTarget(hero, self.E.range) and GetBuffByName(hero, "TwitchDeadlyVenom") ~= 0 then
        	target = GetAIHero(hero)
        	if self:RealEDamage(target) > target.HP and CanCast(_E) and self.menu_Combo_EKs then        		
        		CastSpellTarget(myHero.Addr, _E)
        	end
        end
    end

	local TargetSmite = self.menu_ts:GetTarget(650)
	if TargetSmite ~= nil and IsValidTarget(TargetSmite, 650) and CanCast(self:GetIndexSmite()) and self.menu_Combo_Smiteks then

		if self:GetSmiteDamage(TargetSmite) > GetHealthPoint(TargetSmite) then
			CastSpellTarget(TargetSmite, self:GetIndexSmite())
		end
	end
end


function Twitch:OnProcessSpell(unit, spell)

end

function Twitch:ReCall()
	if GetKeyPress(self.menu_Combo_QRecall) > 0 then		
		if self.Q:IsReady() then
			CastSpellTarget(myHero.Addr, _Q)			
			DelayAction(function() CastSpellTarget(myHero.Addr, self:GetIndexRecall()) end, 0.5)
		end 
	end
end

function Twitch:OnDraw()
	if self.menu_Draw_Already then
		if self.menu_Draw_W and self.W:IsReady() then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.W.range, Lua_ARGB(255,255,0,0))
		end
		if self.menu_Draw_Erange and self.E:IsReady() then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.E.range, Lua_ARGB(255,0,0,255))
		end
		if self.menu_Draw_R and self.R:IsReady() then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.R.range, Lua_ARGB(255,0,0,255))
		end
	else		
		if self.menu_Draw_W then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.W.range, Lua_ARGB(255,255,0,0))
		end
		if self.menu_Draw_Erange then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.E.range, Lua_ARGB(255,0,0,255))
		end
		if self.menu_Draw_R then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.R.range, Lua_ARGB(255,0,0,255))
		end
	end
	if self.menu_Draw_Qrange then
		DrawCircleGame(myHero.x , myHero.y, myHero.z, self:RemainQ() * myHero.MoveSpeed, Lua_ARGB(255, 0, 255, 10))
	end
	
	if GetKeyPress(self.menu_Combo_QRecall) > 0 then
		if self.Q:IsReady() then
			CastSpellTarget(myHero.Addr, _Q)			
			DelayAction(function() CastSpellTarget(myHero.Addr, self:GetIndexRecall()) end, 0.5)
		end 
	end

	local a,b = WorldToScreen(myHero.x, myHero.y, myHero.z)
	if self.menu_Draw_Q and myHero.HasBuff("TwitchHideInShadows") then
    	DrawTextD3DX(a, b, tostring(self:RemainQ()), Lua_ARGB(255, 0, 255, 10))
    end
    if self.menu_Draw_E then
	    for i,hero in pairs(GetEnemyHeroes()) do
	        if hero~= 0 and IsValidTarget(hero, self.E.range) and GetBuffByName(hero, "TwitchDeadlyVenom") ~= 0 then
	        	target = GetAIHero(hero)
	            self:DrawHP(target, self:RealEDamage(target))
	        end
	    end
	end

	--self:DrawHP(100)
    --local a,b =  GetHealthBarPos(myHero.Addr)
    --DrawTextD3DX(a, b, tostring(self:RemainQ()), Lua_ARGB(255, 0, 255, 10))
    --DrawBorderBoxD3DX(a, b, 50, 50, 3, Lua_ARGB(255,0,0,255))
	--FilledRectD3DX(a, b, myHero.HP * (108 / myHero.MaxHP), 12, Lua_ARGB(100,255,0,0))
	--local pbuff = GetBuff(GetBuffByName(myHero.Addr, "recall"))
	--__PrintTextGame(pbuff.Name)
	--__PrintTextGame(tostring(CastSpellTarget(myHero.Addr, self:GetIndexRecall())))


	--[[local TargetW = self.menu_ts:GetTarget(self.W.range)
	target = GetAIHero(TargetW)
	--local aa = (GetBuffCount(target.Addr, "TwitchDeadlyVenom") * ({15, 20, 25, 30, 35})[myHero.Level] + 0.2 * myHero.MagicDmg + 0.25 * myHero.TotalDmg) + ({20, 35, 50, 65, 80})[myHero.Level]
    --{Slot = "E", Stage = 2, DamageType = 1, Damage = function(source, target, level) return ({15, 20, 25, 30, 35})[level] + 0.2 * source.MagicDmg + 0.25 * source.TotalDmg + ({20, 35, 50, 65, 80})[level] end},
	--local stack = GetBuff(GetBuffByName(target.Addr, "TwitchDeadlyVenom"))
	if target ~= 0 then
		--__PrintTextGame(tostring(self:getEDmg(target)))
	end]]
	--local stack = GetBuff(GetBuffByName(myHero.Addr, "TwitchHideInShadows"))
	--__PrintTextGame(tostring(GetBuffByName(myHero.Addr, "TwitchHideInShadows")).."--"..tostring(stack.EndT).."--"..tostring(stack.EndT - GetTimeGame()))
end

function Twitch:DrawHP(unit, damage)
	local a,b =  GetHealthBarPos(unit.Addr)
	FilledRectD3DX(a, b, (unit.HP - damage) * (108 / unit.MaxHP), 12, Lua_ARGB(100,0,0,0))
end

function Twitch:IsImmobileTarget(unit)
	if (CountBuffByType(unit, 5) == 1 or CountBuffByType(unit, 11) == 1 or CountBuffByType(unit, 29) == 1 or CountBuffByType(unit, 24) == 1 or CountBuffByType(unit, 10) == 1 or CountBuffByType(unit, 29) == 1) then
		return true
	end
	return false
end


function Twitch:getEDmg(target)
	if target ~= 0 and CanCast(_E) then
		local Damage = 0
		local DamageAP = {15, 20, 25, 30, 35}
		local DamageAD = {20, 35, 50, 65, 80}

		local stack = GetBuff(GetBuffByName(target.Addr, "TwitchDeadlyVenom"))
		--__PrintTextGame(tostring(stack.Count).."--"..tostring(myHero.BonusDmg).."--"..tostring(myHero.MagicDmg).."--"..tostring(DamageAP[myHero.LevelSpell(_E)]).."--"..tostring(DamageAD[myHero.LevelSpell(_E)]))
		if stack.Count > 0 then
			Damage = stack.Count * (0.25 * myHero.BonusDmg + DamageAP[myHero.LevelSpell(_E)] + 0.2 * myHero.MagicDmg) + DamageAD[myHero.LevelSpell(_E)]
		end
		return myHero.CalcDamage(target.Addr, Damage)
	end
	return 0
end

function Twitch:RealEDamage(target)
	if target ~= 0 and target.HasBuff("TwitchDeadlyVenom") then
		local damage = 0
		if target.HasBuff("KindredRNoDeathBuff") then
			return 0
		end
		local pbuff = GetBuff(GetBuffByName(target, "UndyingRage"))
		if target.HasBuff("UndyingRage") and pbuff.EndT > GetTimeGame() + 0.3  then
			return 0
		end
		if target.HasBuff("JudicatorIntervention") then
			return 0
		end
		local pbuff2 = GetBuff(GetBuffByName(target, "ChronoShift"))
		if target.HasBuff("ChronoShift") and pbuff2.EndT > GetTimeGame() + 0.3 then
			return 0
		end
		if target.HasBuff("FioraW") then
			return 0
		end
		if target.HasBuff("ShroudofDarkness") then
			return 0
		end
		if target.HasBuff("SivirShield") then
			return 0
		end
		if self.E:IsReady() then
			damage = damage + self:getEDmg(target)
		else
			damage = 0
		end
		if target.HasBuff("Moredkaiser") then
			damage = damage - target.MP
		end
		if target.HasBuff("SummonerExhaust") then
			damage = damage * 0.6;
		end
		if target.HasBuff("BlitzcrankManaBarrierCD") and target.HasBuff("ManaBarrier") then
			damage = damage - target.MP / 2
		end
		if target.HasBuff("GarenW") then
			damage = damage * 0.7;
		end
		if target.HasBuff("ferocioushowl") then
			damage = damage * 0.7;
		end
		return damage
	end
	return 0
end

function Twitch:passiveDmg(target)
	--if not target.HasBuff("TwitchDeadlyVenom") then
		--return 0
	--end
	local stack = GetBuff(GetBuffByName(target, "TwitchDeadlyVenom"))
	local dmg = 6;
	if myHero.Level < 17 then
		dmg = 5
	end
	if myHero.Level < 13 then
		dmg = 4
	end
	if myHero.Level < 9 then
		dmg = 3
	end
	if myHero.Level < 5 then
		dmg = 2
	end
	__PrintTextGame(tostring(stack.EndT))
	local buffTime = stack.EndT - GetTimeGame() -- GetPassiveTime(target, "TwitchDeadlyVenom");
    return (dmg * stack.Count * buffTime) - 20 * buffTime;
end

function Twitch:RemainQ()
	if myHero.HasBuff("TwitchHideInShadows") then
		local stack = GetBuff(GetBuffByName(myHero.Addr, "TwitchHideInShadows"))
		return stack.EndT - GetTimeGame()
	end
	return 0
end
