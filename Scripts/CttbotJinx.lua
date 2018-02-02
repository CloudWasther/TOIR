IncludeFile("Lib\\TOIR_SDK.lua")

Jinx = class()

function OnLoad()
	if GetChampName(GetMyChamp()) == "Jinx" then
		Jinx:__init()
	end
end

function Jinx:__init()
	--orbwalk = Orbwalking()
	-- VPrediction
	vpred = VPrediction(true)
	HPred = HPrediction()
	AntiGap = AntiGapcloser(nil)
	--TS
    --self.menu_ts = TargetSelector(1750, 0, myHero, true, true, true)

	self.Q = Spell(_Q, GetTrueAttackRange())
    self.W = Spell(_W, 1600)
    self.E = Spell(_E, 1000)
    self.R = Spell(_R, 3000)

    self.Q:SetTargetted()
    self.W:SetSkillShot(0.6, 3300, 60)
    self.E:SetSkillShot(1.2, 1750, 100)
    self.R:SetSkillShot(0.7, 1500, 140)

    self.WCastTime = 0
    self.grabTime = 0
    self.IsMovingInSameDirection = false
    self.GetTrapPos = nil

    self.myLastPath = Vector(0,0,0)
	self.targetLastPath = Vector(0,0,0)

    self.SpellNameChaneling =
	{
	    ["ThreshQ"] = {},
	    ["KatarinaR"] = {},
	    ["AlZaharNetherGrasp"] = {},
	    ["GalioIdolOfDurand"] = {},
	    ["LuxMaliceCannon"] = {},
	    ["MissFortuneBulletTime"] = {},
	    ["RocketGrabMissile"] = {},
	    ["CaitlynPiltoverPeacemaker"] = {},
	    ["EzrealTrueshotBarrage"] = {},
	    ["InfiniteDuress"] = {},
	    ["VelkozR"] = {},
	}

	self.Spells =
	{
    ["katarinar"] 					= {},
    ["drain"] 						= {},
    ["consume"] 					= {},
    ["absolutezero"] 				= {},
    ["staticfield"] 				= {},
    ["reapthewhirlwind"] 			= {},
    ["jinxw"] 						= {},
    ["jinxr"] 						= {},
    ["shenstandunited"] 			= {},
    ["threshe"] 					= {},
    ["threshrpenta"] 				= {},
    ["threshq"] 					= {},
    ["meditate"] 					= {},
    ["caitlynpiltoverpeacemaker"] 	= {},
    ["volibearqattack"] 			= {},
    ["cassiopeiapetrifyinggaze"] 	= {},
    ["ezrealtrueshotbarrage"] 		= {},
    ["galioidolofdurand"] 			= {},
    ["luxmalicecannon"] 			= {},
    ["missfortunebullettime"] 		= {},
    ["infiniteduress"]				= {},
    ["alzaharnethergrasp"] 			= {},
    ["lucianq"] 					= {},
    ["velkozr"] 					= {},
    ["rocketgrabmissile"] 			= {},
	}

	Callback.Add("Tick", function(...) self:OnTick(...) end)
	Callback.Add("AntiGapClose", function(target, EndPos) self:OnAntiGapClose(target, EndPos) end)
    Callback.Add("Draw", function(...) self:OnDraw(...) end)
    Callback.Add("ProcessSpell", function(...) self:OnProcessSpell(...) end)
    Callback.Add("BeforeAttack", function(...) self:OnBeforeAttack(...) end)
    Callback.Add("NewPath", function(...) self:OnNewPath(...) end)
    Callback.Add("CreateObject", function(...) self:OnCreateObject(...) end)
    Callback.Add("DrawMenu", function(...) self:OnDrawMenu(...) end)

    self:MenuValueDefault()
end

function Jinx:MenuValueDefault()
	self.menu = "Jinx_Magic"
	self.autoQ = self:MenuBool("Auto Q", true)
	self.menu_Combo_Qharass = self:MenuBool("Harass Q", true)
	self.menu_Combo_farmQout = self:MenuBool("Farm out range AA", true)
	self.menu_Combo_farmQ = self:MenuBool("LaneClear Q", true)
	self.Qmana = self:MenuSliderInt("Mana Q farm", 60)

	self.autoW = self:MenuBool("Auto W", false)
	self.Use_Combo_Wharras = self:MenuBool("Harass W", false)
	self.Use_W_Anti_GapClose = self:MenuBool("Use W Anti GapClose", true)
	self.Use_W_End_Dash = self:MenuBool("Auto W End Dash", true)
	self.Auto_W_Kill_Steal = self:MenuBool("Auto W Kill Steal", true)
	self.wHC = self:MenuSliderFloat("W HitChane", 1.3)

	self.autoE = self:MenuBool("Auto E on CC", true)
	self.comboE = self:MenuBool("Auto E in Combo BETA", true)
	--self.AGC = self:MenuBool("Anti Gapcloser E", true)
	self.opsE = self:MenuBool("OnProcessSpellCastE", true)
	self.telE = self:MenuBool("Auto E teleport", true)
	self.EmodeGC = self:MenuComboBox("Gap Closer position mode", 1)

	self.autoR = self:MenuBool("Auto R", true)
	self.menu_Combo_Rks = self:MenuBool("Use R Kill Steal", true)
	self.Rturrent = self:MenuBool("Don't R under turret", true)
	self.MaxRangeR = self:MenuSliderInt("Max R range", 3000)
	self.MinRangeR = self:MenuSliderInt("Min R range", 900)


	self.Draw_When_Already = self:MenuBool("Draw When Already", false)
	self.menu_Draw_Q = self:MenuBool("Draw Q Range", false)
	self.menu_Draw_W = self:MenuBool("Draw W Range", false)
	self.menu_Draw_E = self:MenuBool("Draw E Range", false)
	self.menu_Draw_R = self:MenuBool("Draw R Range", false)

	self.Enalble_Mod_Skin = self:MenuBool("Enalble Mod Skin", false)
	self.Set_Skin = self:MenuSliderInt("Set Skin", 12)

	self.Combo = self:MenuKeyBinding("Combo", 32)
	self.Harass = self:MenuKeyBinding("Harass", 67)
	self.Lane_Clear = self:MenuKeyBinding("Lane Clear", 86)
	self.Last_Hit = self:MenuKeyBinding("Last Hit", 88)
end

function Jinx:OnDrawMenu()
	if Menu_Begin(self.menu) then
		if Menu_Begin("Setting Q") then
			self.autoQ = Menu_Bool("Auto Q", self.autoQ, self.menu)
			self.menu_Combo_Qharass = Menu_Bool("Harass Q", self.menu_Combo_Qharass, self.menu)
			self.menu_Combo_farmQout = Menu_Bool("Farm out range AA", self.menu_Combo_farmQout, self.menu)
			self.menu_Combo_farmQ = Menu_Bool("LaneClear Q", self.menu_Combo_farmQ, self.menu)
			self.Qmana = Menu_SliderInt("Mana Q farm", self.Qmana, 0, 100, self.menu)
			Menu_End()
		end
		if Menu_Begin("Setting W") then
			self.autoW = Menu_Bool("Auto W", self.autoW, self.menu)
			self.Use_Combo_Wharras = Menu_Bool("Harass W", self.Use_Combo_Wharras, self.menu)
			self.Use_W_Anti_GapClose = Menu_Bool("Use W Anti GapClose", self.Use_W_Anti_GapClose, self.menu)
			self.Use_W_End_Dash = Menu_Bool("Auto W End Dash", self.Use_W_End_Dash, self.menu)
			self.Auto_W_Kill_Steal = Menu_Bool("Auto W Kill Steal", self.Auto_W_Kill_Steal, self.menu)
			self.wHC = Menu_SliderFloat("W HitChane", self.wHC, 1, 3, self.menu)
			Menu_End()
		end
		if Menu_Begin("Setting E") then
			self.autoE = Menu_Bool("Auto E on CC", self.autoE, self.menu)
			self.comboE = Menu_Bool("Auto E in Combo BETA", self.comboE, self.menu)
			--self.AGC = Menu_Bool("Anti Gapcloser E", self.AGC, self.menu)
			self.opsE = Menu_Bool("OnProcessSpellCastE", self.opsE, self.menu)
			self.telE = Menu_Bool("Auto E teleport", self.telE, self.menu)
			self.EmodeGC = Menu_ComboBox("Gap Closer position mode", self.EmodeGC, "Dash end position\0My hero position\0\0\0", self.menu)
			Menu_End()
		end
		if Menu_Begin("Setting R") then
			self.autoR = Menu_Bool("Auto R", self.autoR, self.menu)
			self.menu_Combo_Rks = Menu_Bool("Use R Kill Steal", self.menu_Combo_Rks, self.menu)
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

function Jinx:MenuBool(stringKey, bool)
	return ReadIniBoolean(self.menu, stringKey, bool)
end

function Jinx:MenuSliderInt(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Jinx:MenuSliderFloat(stringKey, valueDefault)
	return ReadIniFloat(self.menu, stringKey, valueDefault)
end

function Jinx:MenuComboBox(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Jinx:MenuKeyBinding(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Jinx:OnCreateObject(obj)
	local objPos = Vector(GetPosX(obj.Addr), GetPosY(obj.Addr), GetPosZ(obj.Addr))
	for i, heros in ipairs(GetEnemyHeroes()) do
		if heros ~= nil then
			local hero = GetAIHero(heros)
			heroPos = Vector(hero.x, hero.y, hero.z)
			if GetDistance(objPos) < self.E.range and obj.IsValid then
				if string.find(obj.Name, "GateMarker_red.troy") or string.find(obj.Name, "global_ss_teleport_target_red.troy") or
					string.find(obj.Name, "r_indicator_red.troy") or (string.find(obj.Name, "LifeAura.troy") and hero.IsValid and GetDistance(objPos, heroPos) < 200) then
					self.GetTrapPos = objPos
				else
					self.GetTrapPos = nil
				end
			end
		end
	end
end

function Jinx:OnNewPath(unit, startPos, endPos, isDash, dashSpeed ,dashGravity, dashDistance)
	if unit.IsMe then
		self.myLastPath = endPos
	end
	local TargetE = GetTargetSelector(2000, 0)
	if CanCast(_E) and TargetE ~= 0 then
		target = GetAIHero(TargetE)
		if unit.NetworkId == target.NetworkId then
			self.targetLastPath = endPos
		end
	end

	if self.myLastPath ~= Vector(0,0,0) and self.targetLastPath ~= Vector(0,0,0) then
		local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
		local getAngle = myHeroPos:AngleBetween(self.myLastPath, self.targetLastPath)
		if(getAngle < 20) then
            self.IsMovingInSameDirection = true;
        else
            self.IsMovingInSameDirection = false;
        end
	end
end

function Jinx:OnBeforeAttack(target)
	if not CanCast(_Q) or not self.autoQ or not self:FishBoneActive() then
		return;
	end
    if target ~= nil and target.Type == 0 then
    	local realDistance = self:GetRealDistance(target) - 50
    	--__PrintTextGame(tostring(realDistance).."--"..tostring(self:GetRealPowPowRange(target)).."--"..tostring(GetHealthPoint(target.Addr)))
    	if GetKeyPress(self.Combo) > 0 and (realDistance < self:GetRealPowPowRange(target) or (myHero.MP < 120 and GetAADamageHitEnemy(target.Addr) * 3 < GetHealthPoint(target.Addr))) then
    		CastSpellTarget(myHero.Addr, _Q)
    	elseif GetKeyPress(self.Harass) > 0 and (realDistance > self:bonusRange() or realDistance < self:GetRealPowPowRange(target) or myHero.MP > 220) then
    		CastSpellTarget(myHero.Addr, _Q)
    	end
    end
    if target ~= nil and target.Type == 1 and GetKeyPress(self.Lane_Clear) > 0 then
    	local realDistance = self:GetRealDistance(target)
    	if realDistance < self:GetRealPowPowRange(target) or myHero.MP / myHero.MaxMP * 100 < self.Qmana then
    		CastSpellTarget(myHero.Addr, _Q)
    		return;
    	else
    		for i, heros in ipairs(GetEnemyHeroes()) do
				if heros ~= nil then
					local hero = GetAIHero(heros)
					if IsValidTarget(hero.Addr, 1000) and GetDistance(target.Addr, hero.Addr) < 200 then
						CastSpellTarget(myHero.Addr, _Q)
	    				--return;
					end
				end
			end
    	end
    end
end

function Jinx:AntiGapCloser()
	for i, heros in pairs(GetEnemyHeroes()) do
    	if heros ~= nil then
      		local hero = GetAIHero(heros)
      		--if hero.IsDash then
        		local TargetDashing, CanHitDashing, DashPosition = vpred:IsDashing(hero, 0.09, 65, self.E.speed, myHero, false)
        		local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
        		if DashPosition ~= nil then
          			if GetDistance(DashPosition) < 400 and CanCast(_E) and self.AGC then
          				CastSpellToPos(DashPosition.x,DashPosition.z, _E)
          			end
        		end
      		--end
    	end
	end
end

function Jinx:OnAntiGapClose(target, EndPos)
	hero = GetAIHero(target.Addr)
    if GetDistance(EndPos) < 500 or GetDistance(hero) < 500 then
        if CanCast(_E) then --and IsValidTarget(hero.Addr, self.E.range - 150) then
          	if self.WmodeGC == 0 then
          		CastSpellToPos(EndPos.x, EndPos.z, _E)
          	end
          	if self.WmodeGC == 1 then
          		CastSpellToPos(myHero.x, myHero.z, _E)
          	end
        end
    end
end

function Jinx:OnTick()
	if (IsDead(myHero.Addr) or myHero.IsRecall or IsTyping() or IsDodging()) then return end
	SetLuaCombo(true)

	--self.IsMovingInSameDirection

	self.HPred_W_M = HPSkillshot({type = "DelayLine", delay = self.W.delay, range = self.W.range, speed = self.W.speed, collisionH = false, collisionM = true, width = self.W.width})
	self.HPred_E_M = HPSkillshot({type = "PromptCircle", delay = self.E.delay, range = self.E.range, speed = self.E.speed, radius = self.E.width})
	self.HPred_R_M = HPSkillshot({type = "DelayLine", delay = self.R.delay, range = self.R.range, speed = self.R.speed, collisionH = true, collisionM = false, width = self.R.width})

	for i, heros in ipairs(GetEnemyHeroes()) do
		if heros ~= nil then
			local hero = GetAIHero(heros)
			if not hero.IsDead and GetDistance(hero.Addr) < self.E.range and (hero.HasBuff("bardrstasis") or CountBuffByType(hero.Addr, 17) > 0) then
				self.GetTrapPos = Vector(hero.x, hero.y, hero.z)
			else
				self.GetTrapPos = nil
			end
		end
	end

	self:AutoEW()
	self:KillSteal()
	--self:AntiGapCloser()
	--self:LogicR()

	if CanCast(_Q) and self.autoQ then
		self:LogicQ()
	end

	if CanCast(_E) then
		self:LogicE()
	end

	if CanCast(_R) then
		self:LogicR()
	end

	if CanCast(_W) and self.autoW then
		self:LogicW()
	end

	if self.Enalble_Mod_Skin then
		ModSkin(self.Set_Skin)
	end
end

function Jinx:FishBoneActive()
	if myHero.HasBuff("JinxQ") then
		return true
	else
		return false
	end
	return false
end

function Jinx:bonusRange()
	return (670 + GetBoundingRadius(myHero.Addr) + 25 * myHero.LevelSpell(_Q))
end

function Jinx:GetRealPowPowRange(target)
	return (620 + GetBoundingRadius(myHero.Addr) + GetBoundingRadius(target.Addr))
end

function Jinx:GetRealDistance(target)
	local targetPos = Vector(target.x, target.y, target.z)
	return (GetDistance(targetPos) + GetBoundingRadius(myHero.Addr) + GetBoundingRadius(target.Addr))
end

function Jinx:LogicQ()
	--__PrintTextGame(tostring((self:FishBoneActive())))
	if GetKeyPress(self.Lane_Clear) > 0 and not self:FishBoneActive() and self.menu_Combo_farmQout and myHero.MP > 200 then --and GetTargetOrb == nil then
		GetAllUnitAroundAnObject(myHero.Addr, 2000)
	    for i, obj in pairs(pUnit) do
	        if obj ~= 0  then
	            local minion = GetUnit(obj)
	            if IsEnemy(minion.Addr) and not IsDead(minion.Addr) and not IsInFog(minion.Addr) and (GetType(minion.Addr) == 1) then
	            	if IsValidTarget(minion.Addr, self.bonusRange() + 30) and GetDistance(minion.Addr) > GetTrueAttackRange() and self:GetRealPowPowRange(minion) < self:GetRealDistance(minion) and self.bonusRange() < self:GetRealDistance(minion) then
						local hpPred = GetHealthPred(minion.Addr, 0.4, 0.07)
						if hpPred < GetAADamageHitEnemy(minion.Addr) * 1.1 and hpPred > 5 then
							--__PrintTextGame(tostring(hpPred))
							--Orbwalker.ForceTarget(minion);
	                        CastSpellTarget(myHero.Addr, _Q)
	                        return;
						end
					end
				end
			end
		end
	elseif	self:FishBoneActive() and GetKeyPress(self.Lane_Clear) > 0 then
		CastSpellTarget(myHero.Addr, _Q)
	end

	local TargetQ = GetTargetSelector(self.bonusRange() + 60, 1)
	if CanCast(_Q) and TargetQ ~= 0 then
		target = GetAIHero(TargetQ)
		--__PrintTextGame(tostring(GetDistance(target.Addr)).."--"..tostring(GetTrueAttackRange()))
		if not self:FishBoneActive() and (GetDistance(target.Addr) > GetTrueAttackRange() or CountEnemyChampAroundObject(target.Addr, 250) > 2) then
			local distance = self:GetRealDistance(target)
			if GetKeyPress(self.Combo) > 0 and (myHero.MP > 150 or GetAADamageHitEnemy(target.Addr) * 3 > target.HP) then
				CastSpellTarget(myHero.Addr, _Q)
			end
		end
	elseif CanCast(_Q) and not self:FishBoneActive() and GetKeyPress(self.Combo) > 0 and myHero.MP > 150 and CountEnemyChampAroundObject(myHero.Addr, 2000) > 2 then
		CastSpellTarget(myHero.Addr, _Q)
	elseif CanCast(_Q) and self:FishBoneActive() and GetKeyPress(self.Combo) > 0 and myHero.MP < 150 then
		CastSpellTarget(myHero.Addr, _Q)
	elseif CanCast(_Q) and self:FishBoneActive() and GetKeyPress(self.Combo) > 0 and CountEnemyChampAroundObject(myHero.Addr, 2000) == 0 then
		CastSpellTarget(myHero.Addr, _Q)
	--elseif	self:FishBoneActive() and GetKeyPress(self.Lane_Clear) > 0 then
		--CastSpellTarget(myHero.Addr, _Q)
	end
end

function Jinx:LogicW()
	if CountEnemyChampAroundObject(myHero.Addr, self:bonusRange()) == 0 then
		if GetKeyPress(self.Combo) > 0 and myHero.MP > 150 then
			local TargetW = GetTargetSelector(self.W.range - 150, 1)
			if TargetW ~= 0 then
				target = GetAIHero(TargetW)
				if self:GetRealDistance(target) > GetTrueAttackRange() then-- self:bonusRange() then
					local WPos, WHitChance = HPred:GetPredict(self.HPred_W_M, target, myHero)
	                if WHitChance >= self.wHC then
	                    CastSpellToPos(WPos.x, WPos.z, _W)
	                end
				end
			end
		end
	end

	for i,hero in pairs(GetEnemyHeroes()) do
		if hero ~= nil then
			target = GetAIHero(hero)
			if IsValidTarget(target, self.W.range - 150) and GetDistance(target.Addr) > self:bonusRange() then
				local WPos, WHitChance = HPred:GetPredict(self.HPred_W_M, target, myHero)
				local comboDmg = GetDamage("W", target)
				if CanCast(_R) and myHero.MP > 200 then
					comboDmg = comboDmg + GetDamage("R", target)
				end
				if comboDmg > target.HP and self:ValidUlt(target) and WHitChance >= self.wHC then
					CastSpellToPos(WPos.x, WPos.z, _W)
				end
			end

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

function Jinx:LogicE()
	if (myHero.MP > 150 and self.autoE and GetTimeGame() - self.grabTime > 1) then
		for i,hero in pairs(GetEnemyHeroes()) do
			if IsValidTarget(hero, self.E.range + 50) then
				target = GetAIHero(hero)
				local EPos, EHitChance = HPred:GetPredict(self.HPred_E_M, target, myHero)
				if IsValidTarget(target.Addr, self.E.range - 150) then
					if not self:CanMove(target) then
						CastSpellToPos(EPos.x, EPos.z, _E)
						return
					end
				end
				if IsValidTarget(target.Addr, self.E.range - 150) then
					local EPos, EHitChance = HPred:GetPredict(self.HPred_E_M, target, myHero)
					if EHitChance >= 3 then
				        CastSpellToPos(EPos.x, EPos.z, _E)
				    end
				end
			end
		end
		if self.telE then
			if self.GetTrapPos ~= nil then
				CastSpellToPos(self.GetTrapPos.x, self.GetTrapPos.z, _E)
			end
		end
	end
	--__PrintTextGame(tostring(self.IsMovingInSameDirection))
		if GetKeyPress(self.Combo) > 0 and self.comboE and myHero.MP > 190 then
			local TargetE = GetTargetSelector(self.E.range, 0)
			if CanCast(_E) and TargetE ~= 0 then
				target = GetAIHero(TargetE)
				local EPos, EHitChance = HPred:GetPredict(self.HPred_E_M, target, myHero)
				if CountBuffByType(target.Addr, 10) == 1 then
					CastSpellToPos(EPos.x, EPos.z, _E)
				end
				if GetDistance(EPos, Vector(target)) > 200 then
					if self.IsMovingInSameDirection then
						CastSpellToPos(EPos.x, EPos.z, _E)
					end
				end
			end
		end
end

function Jinx:ValidUlt(unit)
	if CountBuffByType(unit.Addr, 16) == 1 or CountBuffByType(unit.Addr, 15) == 1 or CountBuffByType(unit.Addr, 17) == 1 or unit.HasBuff("kindredrnodeathbuff") or CountBuffByType(unit.Addr, 4) == 1 then
		return false
	end
	return true
end

function Jinx:LogicR()
	local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
	if self:IsUnderTurretEnemy(myHeroPos) and self.Rturrent then
		return
	end
	if GetTimeGame() - self.WCastTime > 0.9 and self.autoR then
		for i,hero in pairs(GetEnemyHeroes()) do
			if hero ~= nil then
				target = GetAIHero(hero)
				if IsValidTarget(target, self.MaxRangeR) and self:ValidUlt(target) then
					if GetDamage("R", target) > target.HP and self:GetRealDistance(target) > self:bonusRange() + 200 then
						local RPos, RHitChance = HPred:GetPredict(self.HPred_R_M, target, myHero)
						if RHitChance > 2 and self:GetRealDistance(target) > self:bonusRange() + 300 + GetBoundingRadius(target.Addr) and CountEnemyChampAroundObject(target.Addr, 500) == 0 and CountEnemyChampAroundObject(myHero.Addr, 400) == 0 then
							CastSpellToPos(RPos.x, RPos.z, _R)
						elseif CountEnemyChampAroundObject(target.Addr, 200) > 2 and RHitChance > 2 then
							CastSpellToPos(RPos.x, RPos.z, _R)
						end
					end
				end
			end
		end
	end
end

function Jinx:AutoEW()
	for i,hero in pairs(GetEnemyHeroes()) do
		if hero ~= nil then
			target = GetAIHero(hero)
			if IsValidTarget(target, self.E.range) then
				local TargetDashing, CanHitDashing, DashPosition = vpred:IsDashing(target, self.E.delay, self.E.width, self.E.speed, myHero, false)

				if DashPosition ~= nil then
					local Collision = CountObjectCollision(0, target.Addr, myHero.x, myHero.z, DashPosition.x, DashPosition.z, self.W.width, self.W.range, 65)
			    	if GetDistance(DashPosition) <= self.E.range and self.menu_Combo_EendDash and Collision == 0 then
			    		CastSpellToPos(DashPosition.x, DashPosition.z, _W)
			    	end
				end

				if not self:CanMove(target) and self.autoE then
					local CastPosition, HitChance, Position = vpred:GetCircularCastPosition(target, self.E.delay, self.E.width, self.E.range, self.E.speed, myHero, false)
					CastSpellToPos(CastPosition.x, CastPosition.z, _E)
				end
			end

			if IsValidTarget(target, self.W.range - 150) then

				local TargetDashing, CanHitDashing, DashPosition = vpred:IsDashing(target, self.W.delay, self.W.width, self.W.speed, myHero, false)
			    if DashPosition ~= nil then
			    	local collision = CountObjectCollision(0, target.Addr, myHero.x, myHero.z, DashPosition.x, DashPosition.z, self.W.width, self.W.range, 65)
			    	if GetDistance(DashPosition) <= self.W.range and self.menu_Combo_WendDash and collision == 0 then
			    		CastSpellToPos(DashPosition.x, DashPosition.z, _W)
			    	end
				end

				if not self:CanMove(target) and (self.Use_Combo_Wharras or self.autoW) then
					local CastPosition, HitChance, Position = vpred:GetCircularCastPosition(target, self.W.delay, self.W.width, self.W.range, self.W.speed, myHero, false)
	                CastSpellToPos(CastPosition.x, CastPosition.z, _W)
				end
			end
		end
	end
end

function Jinx:KillSteal()
	for i,hero in pairs(GetEnemyHeroes()) do
		if hero ~= nil then
			--__PrintTextGame(tostring(__PrintTextGame))
			target = GetAIHero(hero)
			if IsValidTarget(target, self.W.range) then
				if CanCast(_W) and self.Auto_W_Kill_Steal and GetDamage("W", target) > target.HP then
					local CastPosition, HitChance, Position = vpred:GetLineCastPosition(target, self.W.delay, self.W.width, self.W.range, self.W.speed, myHero) --vpred:GetLineCastPosition(target, self.W.delay, self.W.width, self.W.range, self.W.speed, myHero, false)
	                local distance = VPGetLineCastPosition(target.Addr, self.W.delay, self.W.speed)
	                --local Collision = vpred:CheckMinionCollision(target, CastPosition, self.W.delay, self.W.width, self.W.range, self.W.speed, myHero, false, true)
	                --if distance > 0 and distance < self.W.range then
	                    if not GetCollision(target.Addr, self.W.width, self.W.range, distance, 1) then
	                        --CastSpellToPredictionPos(target.Addr, _W, distance)
	                        CastSpellToPos(CastPosition.x, CastPosition.z, _W)
	                    end
	                --end
	            end
			end

			if IsValidTarget(target, self.MaxRangeR) then
				if CanCast(_R) and self.menu_Combo_Rks and GetDamage("R", target) > target.HP and GetDistance(target.Addr) > self.MinRangeR then
					local CastPosition, HitChance, Position = vpred:GetLineCastPosition(target, self.R.delay, self.R.width, self.MaxRangeR, self.R.speed, myHero, false)
	                local distance = VPGetLineCastPosition(target.Addr, self.R.delay, self.R.speed)
	                --if distance > 0 and distance < self.R.range then
	                    if not GetCollision(target.Addr, self.R.width, self.MaxRangeR, distance, 2) then
	                        --CastSpellToPredictionPos(target.Addr, _R, distance)
	                        CastSpellToPos(CastPosition.x, CastPosition.z, _R)
	                    end
	                --end
	            end
			end
		end
	end
end

function Jinx:OnDraw()
	if self.menu_Draw_Already then
		if self.menu_Draw_Q then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, GetTrueAttackRange(), Lua_ARGB(255,255,0,0))
		end
		if self.menu_Draw_W and self.W:IsReady() then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.W.range, Lua_ARGB(255,255,0,0))
		end
		if self.menu_Draw_E and self.E:IsReady() then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.E.range, Lua_ARGB(255,0,255,0))
		end
		if self.menu_Draw_R and self.R:IsReady() then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.R.range, Lua_ARGB(255,0,0,255))
		end
	else
		if self.menu_Draw_Q then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, GetTrueAttackRange(), Lua_ARGB(255,255,0,0))
		end
		if self.menu_Draw_W and self.W:IsReady() then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.W.range, Lua_ARGB(255,255,0,0))
		end
		if self.menu_Draw_E then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.E.range, Lua_ARGB(255,0,255,0))
		end
		if self.menu_Draw_R then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.R.range, Lua_ARGB(255,0,0,255))
		end
	end

end

function Jinx:OnProcessSpell(unit, spell)
	local spellName = spell.Name:lower()

	if unit.Type == 1 then
		return
	end

    if unit.IsMe then
    	if spellName == "jinxwmissile" then
    		self.WCastTime = GetTimeGame()
    	end
    end

    if spell and unit.IsEnemy and IsValidTarget(unit.Addr, self.E.range) and self.E:IsReady() then
        if self.Spells[spellName] ~= nil then
        	CastSpellToPos(unit.x, unit.z, _E)
        end
    end

    if self.E:IsReady() then
    	if unit.IsEnemy and self.SpellNameChaneling[spell.Name] and IsValidTarget(unit.Addr, self.E.range) and self.opsE then
    		--local CastPosition, HitChance, Position = vpred:GetLineCastPosition(unit, self.E.delay, self.E.width, self.E.range, self.E.speed, myHero, false)
    		CastSpellToPos(unit.x, unit.z, _E)
    		--local distance = VPGetLineCastPosition(unit.Addr, self.E.delay, self.E.speed)
	        --if distance > 0 and distance < self.E.range then
	            --CastSpellToPredictionPos(target.Addr, _E, distance)
	        --end
    	end
    	if not unit.IsEnemy and spellName == "RocketGrab" and GetDistance(unit.Addr) < self.E.range then
    		self.grabTime = GetTimeGame()
    	end
    end
end

function Jinx:IsImmobileTarget(unit)
	if (CountBuffByType(unit, 5) == 1 or CountBuffByType(unit, 11) == 1 or CountBuffByType(unit, 29) == 1 or CountBuffByType(unit, 24) == 1 or CountBuffByType(unit, 10) == 1 or CountBuffByType(unit, 29) == 1) then
		return true
	end
	return false
end

function Jinx:CanMove(unit)
	if (unit.MoveSpeed < 50 or CountBuffByType(unit.Addr, 5) == 1 or CountBuffByType(unit.Addr, 21) == 1 or CountBuffByType(unit.Addr, 11) == 1 or CountBuffByType(unit.Addr, 29) == 1 or
		unit.HasBuff("recall") or CountBuffByType(unit.Addr, 30) == 1 or CountBuffByType(unit.Addr, 22) == 1 or CountBuffByType(unit.Addr, 8) == 1 or CountBuffByType(unit.Addr, 24) == 1
		or CountBuffByType(unit.Addr, 20) == 1 or CountBuffByType(unit.Addr, 18) == 1) then
		return false
	end
	return true
end

function Jinx:CheckWalls(enemyPos)
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

function Jinx:IsUnderTurretEnemy(pos)			--Will Only work near myHero
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

function Jinx:IsUnderAllyTurret(pos)
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

function Jinx:CountEnemiesInRange(pos, range)
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
