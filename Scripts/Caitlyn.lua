IncludeFile("Lib\\TOIR_SDK.lua")
--IncludeFile("Lib\\OrbNew.lua")
--IncludeFile("Lib\\Baseult.lua")

Caitlyn = class()

function OnLoad()
	if GetChampName(GetMyChamp()) == "Caitlyn" then
		Caitlyn:__init()
	end
end

function Caitlyn:__init()
	-- VPrediction
	vpred = VPrediction(true)

	--TS
    self.menu_ts = TargetSelector(1750, 0, myHero, true, true, true)


    self.Q = Spell(_Q, 1250) -- catlyn
    self.W = Spell(_W, 900) -- catlyn
    self.E = Spell(_E, 900)  -- catlyn
    self.R = Spell(_R, 2300) -- catlyn

    self.Q:SetSkillShot(0.65, 2200, 60, true) -- catlyn
    self.W:SetSkillShot(1.5, math.huge, 20, true) -- catlyn
    self.E:SetSkillShot(0.30, 2000, 70, true) -- catlyn
    self.R:SetSkillShot(0.7, 1500, 200, true) -- catlyn


    self.WCastTime = 0
    self.grabTime = 0
    self.IsMovingInSameDirection = false
    self.GetTrapPos = nil

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

	self.QCastTime = 0
	self.RRange = 2300

	Callback.Add("Tick", function(...) self:OnTick(...) end)
    Callback.Add("Draw", function(...) self:OnDraw(...) end)
    Callback.Add("ProcessSpell", function(...) self:OnProcessSpell(...) end)
    --Callback.Add("BeforeAttack", function(...) self:OnBeforeAttack(...) end)
    Callback.Add("NewPath", function(...) self:OnNewPath(...) end)
    Callback.Add("CreateObject", function(...) self:OnCreateObject(...) end)
    Callback.Add("DrawMenu", function(...) self:OnDrawMenu(...) end)
    self:MenuValueDefault()
end

function Caitlyn:MenuValueDefault()
	self.menu = "Caitlyn_Magic"
	self.Draw_When_Already = self:MenuBool("Draw When Already", true)
	self.menu_Draw_Q = self:MenuBool("Draw Q Range", true)
	self.menu_Draw_W = self:MenuBool("Draw W Range", true)
	self.menu_Draw_E = self:MenuBool("Draw E Range", true)
	self.menu_Draw_R = self:MenuBool("Draw R Range", true)

	self.autoQ2 = self:MenuBool("Auto Q", true)
	self.autoQcc = self:MenuBool("Auto Q on CC", true)
	self.autoQ = self:MenuBool("Reduce Q use", true)
	self.Qaoe = self:MenuBool("Q Aoe", true)
	self.Qslow = self:MenuBool("Q slow", true)
	self.qendDas = self:MenuBool("Q End Dash", true)
	self.qks = self:MenuBool("Q Kill Steal", true)

	self.autoW = self:MenuBool("Auto W on hard CC", true)
	self.telE = self:MenuBool("Auto W teleport", true)
	self.forceW = self:MenuBool("Force W before E", true)
	self.bushW = self:MenuBool("Auto W bush after enemy enter", true)
	self.bushW2 = self:MenuBool("Auto W bush and turret if full ammo", true)
	self.Wspell = self:MenuBool("W on special spell detection", true)
	self.WmodeGC = self:MenuComboBox("Gap Closer position mode", 0)
	self.wendDas = self:MenuBool("W End Dash", true)

	self.autoE = self:MenuBool("Auto E", true)
	self.Ehitchance = self:MenuBool("Auto E dash and immobile target", true)
	self.harrasEQ = self:MenuBool("TRY E + Q", true)
	self.EQks = self:MenuBool("Ks E + Q + AA", true)
	self.useE = self:MenuKeyBinding("Dash E HotKey Smartcast", 71)
	self.EmodeGC = self:MenuComboBox("Gap Closer position mode", 0)
	--self.eendDas = self:MenuBool("E End Dash", true)

	self.autoR = self:MenuBool("Auto R KS", true)
	self.Rturrent = self:MenuBool("Don't R under turret", true)
	self.useR = self:MenuKeyBinding("Semi-manual cast R key", 84)

	self.Enalble_Mod_Skin = self:MenuBool("Enalble Mod Skin", false)
	self.Set_Skin = self:MenuSliderInt("Set Skin", 11)

	self.Combo = self:MenuKeyBinding("Combo", 32)
	self.Harass = self:MenuKeyBinding("Harass", 67)
	self.Lane_Clear = self:MenuKeyBinding("Lane Clear", 86)
	self.Last_Hit = self:MenuKeyBinding("Last Hit", 88)
end

function Caitlyn:OnDrawMenu()
	if Menu_Begin(self.menu) then
		if Menu_Begin("Setting Q") then
			self.autoQ2 = Menu_Bool("Auto Q", self.autoQ2, self.menu)
			self.autoQcc = Menu_Bool("Auto Q on CC", self.autoQcc, self.menu)
			self.autoQ = Menu_Bool("Reduce Q use", self.autoQ, self.menu)
			self.Qaoe = Menu_Bool("Q Aoe", self.Qaoe, self.menu)
			self.Qslow = Menu_Bool("Q slow", self.Qslow, self.menu)
			self.qendDas = Menu_Bool("Q End Dash", self.qendDas, self.menu)
			self.qks = Menu_Bool("Q Kill Steal", self.qks, self.menu)
			Menu_End()
		end

		if Menu_Begin("Setting W") then
			self.autoW = Menu_Bool("Auto W on hard CC", self.autoW, self.menu)
			self.telE = Menu_Bool("Auto W teleport", self.telE, self.menu)
			self.forceW = Menu_Bool("Force W before E", self.forceW, self.menu)
			self.bushW = Menu_Bool("Auto W bush after enemy enter", self.bushW, self.menu)
			self.bushW2 = Menu_Bool("Auto W bush and turret if full ammo", self.bushW2, self.menu)
			self.Wspell = Menu_Bool("W on special spell detection", self.Wspell, self.menu)
			self.WmodeGC = Menu_ComboBox("Gap Closer position mode", self.WmodeGC, "Dash end position\0My hero position\0\0", self.menu)
			self.wendDas = Menu_Bool("W End Dash", self.wendDas, self.menu)
			Menu_End()
		end

		if Menu_Begin("Setting E") then
			self.autoE = Menu_Bool("Auto E", self.autoE, self.menu)
			self.Ehitchance = Menu_Bool("Auto E dash and immobile target", self.Ehitchance, self.menu)
			self.harrasEQ = Menu_Bool("TRY E + Q", self.harrasEQ, self.menu)
			self.EQks = Menu_Bool("Ks E + Q + AA", self.EQks, self.menu)
			self.useE = Menu_KeyBinding("Dash E HotKey Smartcast", self.useE, self.menu)
			self.EmodeGC = Menu_ComboBox("Gap Closer position mode", self.WmodeGC, "Dash end position\0Cursor position\0Enemy position\0\0", self.menu)
			--self.eendDas = Menu_Bool("E End Dash", self.eendDas, self.menu)
			Menu_End()
		end

		if Menu_Begin("Setting R") then
			self.autoR = Menu_Bool("Auto R KS", self.autoR, self.menu)
			self.Rturrent = Menu_Bool("Don't R under turret", self.Rturrent, self.menu)
			self.useR = Menu_KeyBinding("Semi-manual cast R key", self.useR, self.menu)
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

function Caitlyn:MenuBool(stringKey, bool)
	return ReadIniBoolean(self.menu, stringKey, bool)
end

function Caitlyn:MenuSliderInt(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Caitlyn:MenuSliderFloat(stringKey, valueDefault)
	return ReadIniFloat(self.menu, stringKey, valueDefault)
end

function Caitlyn:MenuComboBox(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Caitlyn:MenuKeyBinding(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Caitlyn:OnCreateObject(obj)
	--__PrintDebug(obj.Name)
	
	local objPos = Vector(GetPosX(obj.Addr), GetPosY(obj.Addr), GetPosZ(obj.Addr))
	for i, heros in ipairs(GetEnemyHeroes()) do
		if heros ~= nil then
			local hero = GetAIHero(heros)
			heroPos = Vector(hero.x, hero.y, hero.z)
			
			if string.find(obj.Name, "GateMarker_red.troy") or string.find(obj.Name, "global_ss_teleport_target_red.troy") or
				string.find(obj.Name, "r_indicator_red.troy") or (string.find(obj.Name, "LifeAura.troy") and hero.IsValid and GetDistance(objPos, heroPos) < 200) then
				if GetDistance(objPos) < self.W.range - 150 and obj.IsValid then
					self.GetTrapPos = objPos
				else
					self.GetTrapPos = nil
				end
			end

			if (hero.Name == "Rengar" or hero.Name == "Khazix") and hero.IsValid then
				if obj.Name == "Rengar_LeapSound.troy" and GetDistance(heroPos) < self.W.range - 150 then
					CastSpellToPos(hero.x, hero.z, _E)
				end

				if obj.Name == "Khazix_Base_E_Tar.troy" and GetDistance(heroPos) < 300 then
					CastSpellToPos(hero.x, hero.z, _E)
				end
			end
		end
	end

	if obj.IsValid and GetDistance(objPos, heroPos) < 300 and string.find(obj.Name:lower(), "yordleTrap_idle_green.troy") then
		Process = false;
	end
end

function Caitlyn:OnNewPath(unit, startPos, endPos, isDash, dashSpeed ,dashGravity, dashDistance)
	if unit.IsMe then
		local myLastPath = endPos
	end
	local TargetE = self.menu_ts:GetTarget(self.W.range - 150)
	if CanCast(_E) and TargetE ~= 0 then
		target = GetAIHero(TargetE)
		if unit.NetworkId == unit.NetworkId then
			local targetLastPath = endPos
		end
	end

	if myLastPath ~= nil and targetLastPath ~= nil then
		local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
		local getAngle = myHeroPos:AngleBetween(myLastPath, targetLastPath)
		if(getAngle < 20) then
            self.IsMovingInSameDirection = true;
        else
            self.IsMovingInSameDirection = false;
        end
	end
end

function Caitlyn:OnTick()
	if myHero.IsDead then return end
	SetLuaCombo(true)

	for i,hero in pairs(GetEnemyHeroes()) do
		if IsValidTarget(hero, 1000) then
			target = GetAIHero(hero)
			if IsValidTarget(target.Addr, 1000) then
				if GetBuffByName(target.Addr, "slow") ~= 0 then
					if self.Qaoe then
						--local CastPosition, HitChance, Position = vpred:GetLineAOECastPosition(target, self.Q.delay, self.Q.width, self.Q.range, self.Q.speed, myHero)
						--__PrintTextGame("string szText")						
						CastSpellToPos(target.x, target.z, _W)
						CastSpellToPos(target.x, target.z, _Q)
					end			
				end
				--GetAllBuffNameActive(882209824)
				--for i,v in pairs(pBuffName) do
					--__PrintDebug(tostring(v))				      
				--end
			end
		end
	end

	for i, heros in ipairs(GetEnemyHeroes()) do
		if heros ~= nil then
			local hero = GetAIHero(heros)
			if not hero.IsDead and GetDistance(hero.Addr) < self.W.range - 150 and (hero.HasBuff("bardrstasis") or CountBuffByType(hero.Addr, 17) > 0) then
				self.GetTrapPos = Vector(hero.x, hero.y, hero.z)
			else
				self.GetTrapPos = nil
			end
		end
	end

    local TargetR = self.menu_ts:GetTarget(self.RRange)
    if GetKeyPress(self.useR) > 0 and IsValidTarget(TargetR, self.RRange) then
    	CastSpellTarget(TargetR, _R)
    end

	self:KillSteal()

	self:AntiGapCloser()

	self.RRange = 500 * myHero.LevelSpell(_R) + 1800

	self:AutoQEW()

	if CanCast(_E) then --and self:CanMoveOrb(40) then
		self:LogicE()
	end

	local orbT = GetTargetOrb()
	if orbT ~= nil and GetType(GetTargetOrb()) == 0 then 
		if GetAADamageHitEnemy(orbT) * 2 > GetHealthPoint(orbT) then
			return
		end
	end 

	if CanCast(_W) then
		self:LogicW()
	end

	if CanCast(_Q) and self.autoQ2 then --and self:CanMoveOrb(40) 
		self:LogicQ()
	end

	local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
    if CanCast(_R) and self.autoR and GetTimeGame() - self.QCastTime > 1 and not self:IsUnderTurretEnemy(myHeroPos) then
    	self:LogicR();
	end

	if GetKeyPress(self.useE) > 0 and CanCast(_E) then
		local Position = Vector(myHero) - (GetMousePos() - Vector(myHero))
		CastSpellToPos(Position.x, Position.z, _E)
	end

	if self.Enalble_Mod_Skin then
		ModSkin(self.Set_Skin)
	end
end

function Caitlyn:CanMoveOrb(extraWindup)
    return GetTimeGame() + self:GamePing() > GetLastBATick() + GetWindupBA(myHero.Addr) + extraWindup --self.menu_advanced_delayWindup.getValue() /1000
end

function Caitlyn:GamePing()
    return GetLatency() / 2000
end

function Caitlyn:bonusRange()
	return (670 + GetBoundingRadius(myHero.Addr) + 25 * myHero.LevelSpell(_Q))
end

function Caitlyn:GetRealPowPowRange(target)
	return (620 + GetBoundingRadius(myHero.Addr) + GetBoundingRadius(target.Addr))
end

function Caitlyn:GetRealDistance(target)
	local targetPos = Vector(target.x, target.y, target.z)
	return (GetDistance(targetPos) + GetBoundingRadius(myHero.Addr) + GetBoundingRadius(target.Addr))
end

function Caitlyn:LogicQ()
	local TargetQ = self.menu_ts:GetTarget(self.Q.range - 150)
	if IsValidTarget(TargetQ, self.Q.range - 150) then
		target = GetAIHero(TargetQ)
		local CastPosition, HitChance, Position = vpred:GetLineCastPosition(target, self.Q.delay, self.Q.width, self.Q.range, self.Q.speed, myHero, false)
		if self:GetRealDistance(target) > self:bonusRange() + 250 and GetDistance(target.Addr) > GetTrueAttackRange() and CountEnemyChampAroundObject(myHero.Addr, 400) == 0 and HitChance > 2 then
			CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
		elseif GetKeyPress(self.Combo) > 0 and myHero.MP > 250 and CountEnemyChampAroundObject(myHero.Addr, self:bonusRange() + 100 + GetBoundingRadius(target.Addr)) == 0 and not self.autoQ then
			CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
		end

		for i,hero in pairs(GetEnemyHeroes()) do
			if IsValidTarget(hero, self.Q.range - 150) then
				target = GetAIHero(hero)
				if (not self:CanMove(target) or target.HasBuff("caitlynyordletrapinternal")) and GetDistance(target.Addr) < self.Q.range - 150 and self.autoQcc then
					CastSpellToPos(target.x, target.z, _Q)
				end
			end
		end

		if GetKeyPress(self.Combo) > 0 and myHero.MP > 150 and CountEnemyChampAroundObject(myHero.Addr, 400) == 0 then
			for i,hero in pairs(GetEnemyHeroes()) do
				if IsValidTarget(hero, self.Q.range - 150) then
					target = GetAIHero(hero)
					if (not self:CanMove(target) or target.HasBuff("caitlynyordletrapinternal")) and GetDistance(target.Addr) < self.Q.range - 150 then
						CastSpellToPos(target.x, target.z, _Q)
					end
				end
			end

			if CountEnemyChampAroundObject(myHero.Addr, self:bonusRange()) == 0 and self:CanHarras() then
				if GetBuffByName(target.Addr, "slow") ~= 0 and self.Qslow then
					CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
				end				
			end
		end
	end
end

function Caitlyn:CanHarras()
	local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
	if not self:IsUnderTurretEnemy(myHeroPos) and self:CanMoveOrb(50) then
		return true
	end
	return false
end

function Caitlyn:LogicW()
	for i,hero in pairs(GetEnemyHeroes()) do
		if IsValidTarget(hero, self.W.range + 50) then
			target = GetAIHero(hero)
			local CastPosition, HitChance, Position = vpred:GetLineCastPosition(target, self.W.delay, self.W.width, self.W.range, self.W.speed, myHero, false)
			--__PrintTextGame(tostring(target.HasBuff("caitlynyordletrapinternal")))
			if not self:CanMove(target) and self.autoW and not target.HasBuff("caitlynyordletrapinternal") then
				CastSpellToPos(CastPosition.x, CastPosition.z, _W)
				return
			end

			if self.IsMovingInSameDirection then
				CastSpellToPos(CastPosition.x, CastPosition.z, _W)
			end
		end
	end
	if self.telE then
		if self.GetTrapPos ~= nil then
			CastSpellToPos(self.GetTrapPos.x, self.GetTrapPos.z, _W)
		end
	end

	

	if (GetTimeGame() * 10) % 2 < 0.03 and self.bushW2 then
		local AmmoW = {3, 3, 4, 4, 5}
		local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
		--__PrintTextGame(tostring(AmmoW[myHero.LevelSpell(_W)]))
		if GetAmmoSpell(myHero.Addr, _W) == AmmoW[myHero.LevelSpell(_W)] and CountEnemyChampAroundObject(myHero.Addr, 1000) == 0 then
			points = self:CirclePoints(8, self.W.range, myHeroPos)
			for i, point in pairs(points) do
				if self:IsUnderTurretEnemy(point) and not IsWall(point.x, point.y, point.z) then
					CastSpellToPos(point.x, point.z, _W)
				end
			end
		end
	end
end

function Caitlyn:LogicE()
	if self.autoE then
		local TargetE = self.menu_ts:GetTarget(self.E.range - 200)
		if IsValidTarget(TargetE, self.E.range) then
			target = GetAIHero(TargetE)
			local positionT = Vector(myHero) - (Vector(target) - Vector(myHero))
			--local targetPos = Vector(target.x, target.y, target.z)
			--pos = myHero::Extended(targetPos, 400)
			if self:CountEnemiesInRange(positionT, 700) < 2 then
				local eDmg = GetDamage("E", target)
				local qDmg = GetDamage("Q", target)
				local CastPosition, HitChance, Position = vpred:GetLineCastPosition(target, self.E.delay, self.E.width, self.E.range, self.E.speed, myHero, false)
				local Collision = CountObjectCollision(0, target.Addr, myHero.x, myHero.z, CastPosition.x, CastPosition.z, self.E.width, self.E.range, 65)
				if self.EQks and qDmg + eDmg + GetAADamageHitEnemy(target.Addr) > target.HP and myHero.MP > 130 and Collision == 0 then
					CastSpellToPos(CastPosition.x, CastPosition.z, _E)
				elseif GetKeyPress(self.Combo) > 0 and self.harrasEQ and myHero.MP > 230 and Collision == 0 then
					CastSpellToPos(CastPosition.x, CastPosition.z, _E)
				end
			end
			if myHero.MP > 170 then
				if self.Ehitchance then
					local TargetDashing, CanHitDashing, DashPosition = vpred:IsDashing(target, self.E.delay, self.E.width, self.E.speed, myHero, false)
					if DashPosition ~= nil then 
						local CollisionDash = CountObjectCollision(0, target.Addr, myHero.x, myHero.z, DashPosition.x, DashPosition.z, self.E.width, self.E.range, 65)
						if CollisionDash == 0 then
							CastSpellToPos(DashPosition.x, DashPosition.z, _E)
						end
					end					
				end
				if myHero.HP < myHero.MaxHP * 0.3 then
					if GetDistance(target.Addr) < 500 and Collision == 0 then
						CastSpellToPos(CastPosition.x, CastPosition.z, _E)
					end
					if CountEnemyChampAroundObject(myHero.Addr, 250) > 0 and Collision == 0 then
						CastSpellToPos(CastPosition.x, CastPosition.z, _E)
					end
				end
			end
		end
	end
end

function Caitlyn:LogicR()

	local cast = false;
	local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
	if self:IsUnderTurretEnemy(myHeroPos) and self.Rturrent then
		return
	end

	for i,hero in pairs(GetEnemyHeroes()) do
		if hero ~= nil then
			target = GetAIHero(hero)
			if IsValidTarget(target.Addr, self.RRange) and self:ValidUlt(target) then
				if GetDamage("R", target) > target.HP and GetDistance(target.Addr) > GetTrueAttackRange() + 300 and CountEnemyChampAroundObject(myHero.Addr, GetTrueAttackRange()) == 0 and CountEnemyChampAroundObject(target.Addr, 400) == 0 then
					cast = true
					--local CastPosition, HitChance, Position = vpred:GetLineCastPosition(Target, self.R.delay, self.R.width, self.RRange, self.R.speed, myHero, false)
					CastSpellTarget(target.Addr, _R)
				end
			end
		end
	end

	--[[bool cast = false;

            if (Player.UnderTurret(true) && Config.Item("Rturrent", true).GetValue<bool>())
                return;


            foreach (var target in HeroManager.Enemies.Where(target => target.IsValidTarget(R.Range) && Player.Distance(target.Position) > Config.Item("Rrange", true).GetValue<Slider>().Value && target.CountEnemiesInRange(Config.Item("Rcol", true).GetValue<Slider>().Value) == 1 && target.CountAlliesInRange(500) == 0 && OktwCommon.ValidUlt(target)))
            {
                if (OktwCommon.GetKsDamage(target, R) > target.Health)
                {
                    cast = true;
                    PredictionOutput output = R.GetPrediction(target);
                    Vector2 direction = output.CastPosition.To2D() - Player.Position.To2D();
                    direction.Normalize();
                    List<AIHeroClient> enemies = HeroManager.Enemies.Where(x => x.IsValidTarget()).ToList();
                    foreach (var enemy in enemies)
                    {
                        if (enemy.BaseSkinName == target.BaseSkinName || !cast)
                            continue;
                        PredictionOutput prediction = R.GetPrediction(enemy);
                        Vector3 predictedPosition = prediction.CastPosition;
                        Vector3 v = output.CastPosition - Player.ServerPosition;
                        Vector3 w = predictedPosition - Player.ServerPosition;
                        double c1 = Vector3.Dot(w, v);
                        double c2 = Vector3.Dot(v, v);
                        double b = c1 / c2;
                        Vector3 pb = Player.ServerPosition + ((float)b * v);
                        float length = Vector3.Distance(predictedPosition, pb);
                        if (length < (Config.Item("Rcol", true).GetValue<Slider>().Value + enemy.BoundingRadius) && Player.Distance(predictedPosition) < Player.Distance(target.ServerPosition))
                            cast = false;
                    }
                    if (cast)
                        R.CastOnUnit(target);
                }
            }]]
end

function Caitlyn:ValidUlt(unit)
	if CountBuffByType(unit, 16) == 1 or CountBuffByType(unit, 15) == 1 or CountBuffByType(unit, 17) == 1 or unit.HasBuff("kindredrnodeathbuff") or CountBuffByType(unit, 4) == 1 then
		return false
	end
	return true
end

function Caitlyn:AutoQEW()
	local TargetW = self.menu_ts:GetTarget(self.W.range  - 150)
	if CanCast(_W) and TargetW ~= 0 then
		target = GetAIHero(TargetW)
		local TargetDashing, CanHitDashing, DashPosition = vpred:IsDashing(target, self.W.delay, self.W.width, self.W.speed, myHero, true)
		local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)

	    if DashPosition ~= nil then
	    	if GetDistance(DashPosition) <= self.W.range and self.wendDas then
	    		CastSpellToPos(DashPosition.x, DashPosition.z, _W)
	    		CastSpellToPos(DashPosition.x, DashPosition.z, _Q)
	    	end
		end
	end

	--[[local TargetQ = self.menu_ts:GetTarget(self.Q.range)
	if CanCast(_Q) and TargetQ ~= 0 then
		target = GetAIHero(TargetQ)
		local TargetDashing, CanHitDashing, DashPosition = vpred:IsDashing(target, self.Q.delay, self.Q.width, self.Q.speed, myHero, false)
		local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)

	    if DashPosition ~= nil then
	    	if GetDistance(DashPosition) <= self.Q.range and self.qendDas then
	    		CastSpellToPos(DashPosition.x, DashPosition.z, _Q)
	    	end
		end
	end]]

	--[[local TargetE = self.menu_ts:GetTarget(self.E.range)
	if CanCast(_E) and TargetE ~= 0 then
		target = GetAIHero(TargetE)
		local TargetDashing, CanHitDashing, DashPosition = vpred:IsDashing(target, self.E.delay, self.E.width, self.E.speed, myHero, false)
		local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
		

	    if DashPosition ~= nil then
	    	local CollisionDash = CountObjectCollision(0, target.Addr, myHero.x, myHero.z, DashPosition.x, DashPosition.z, self.E.width, self.E.range, 65)
	    	if GetDistance(DashPosition) <= self.E.range and self.eendDas and CollisionDash == 0 then
	    		CastSpellToPos(DashPosition.x, DashPosition.z, _E)
	    	end
		end
	end]]
end

function Caitlyn:KillSteal()
	local TargetQ = self.menu_ts:GetTarget(self.Q.range - 150)
	if TargetQ ~= nil and IsValidTarget(TargetW, self.Q.range) and CanCast(_Q) and self.qks then
		targetQ = GetAIHero(TargetQ)
		local CastPosition, HitChance, Position = vpred:GetLineCastPosition(targetQ, self.Q.delay, self.Q.width, self.Q.range, self.Q.speed, myHero, false)
		if GetDistance(TargetQ) < self.Q.range and GetDamage("Q", targetQ) > targetQ.HP then
			CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
		end
	end
end

function Caitlyn:OnDraw()
	for i,hero in pairs(GetEnemyHeroes()) do
		if IsValidTarget(hero, 2000) then
			target = GetAIHero(hero)
			if IsValidTarget(target.Addr, self.RRange) and GetDamage("R", target) > target.HP then
				local a,b = WorldToScreen(target.x, target.y, target.z)
				DrawTextD3DX(a, b, "CAN KILL by R", Lua_ARGB(255, 0, 255, 10))
				--__PrintDebug(tostring(GetAllBuffNameActive(target.Addr)))
			end
		end
	end

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
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.RRange, Lua_ARGB(255,255,0,0))
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
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.RRange, Lua_ARGB(255,255,0,0))
		end
	end
end

function Caitlyn:OnProcessSpell(unit, spell)
	local spellName = spell.Name:lower()
	if unit.IsMe then
		--__PrintDebug(spell.Name)
	end
	if unit.IsMe and (spell.Name == "CaitlynPiltoverPeacemaker" or spell.Name == "CaitlynEntrapment") then
		self.QCastTime = GetTimeGame()
	end

	if spell and unit.IsEnemy and IsValidTarget(unit.Addr, self.W.range) and self.Wspell and self.W:IsReady() then
        if self.Spells[spellName] ~= nil then
        	CastSpellToPos(unit.x, unit.z, _W)
        end
    end

    if unit.IsMe then
    	if spell.Name == "CaitlynEntrapment" and self.forceW and myHero.MP > 110 then
    		myHeroDestPos = Vector(GetMousePos().x, GetMousePos().y, GetMousePos().z)
    		if GetDistance(myHeroDestPos) < self.W.range then
	    		myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
	    		cast = myHeroPos:Extended(myHeroDestPos, GetDistance(myHeroPos, myHeroDestPos) - 50)
	    		CastSpellToPos(cast.x, cast.z, _W)
	    	end	    	
    	end
    end
end


function Caitlyn:AntiGapCloser()
	for i, heros in pairs(GetEnemyHeroes()) do
    	if heros ~= nil then
      		local hero = GetAIHero(heros)
      		if hero.IsDash then
        		local TargetDashing, CanHitDashing, DashPosition = vpred:IsDashing(hero, 0.09, 65, 2000, myHero, false)
        		local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
        		if DashPosition ~= nil then
          			if GetDistance(DashPosition) < 400 then
          				if CanCast(_E) and IsValidTarget(hero.Addr, self.E.range - 150) then
          					if self.EmodeGC == 0 then
          						CastSpellToPos(DashPosition.x, DashPosition.z, _E)
          					end
          					if self.EmodeGC == 1 then
          						CastSpellToPos(GetMousePos().x, GetMousePos().z, _E)
          					end
          					if self.EmodeGC == 2 then
          						CastSpellToPos(hero.x, hero.z, _E)
          					end
          				end

          				if CanCast(_W) and IsValidTarget(hero.Addr, self.W.range - 150) then
          					if self.WmodeGC == 0 then
          						CastSpellToPos(DashPosition.x, DashPosition.z, _W)
          					end
          					if self.WmodeGC == 1 then
          						CastSpellToPos(myHero.x, myHero.z, _W)
          					end
          				end
          			end
        		end
      		end
    	end
	end
end

function Caitlyn:GetRealRange(target)
	return (680 + GetBoundingRadius(myHero.Addr) + GetBoundingRadius(target.Addr))
end

function Caitlyn:GetRealDistance(target)
	return (GetDistance(target) + GetBoundingRadius(myHero.Addr) + GetBoundingRadius(target.Addr))
end

function Caitlyn:bonusRange()
	return 720 + GetBoundingRadius(myHero.Addr)
end

function Caitlyn:IsImmobileTarget(unit)
	if (CountBuffByType(unit, 5) == 1 or CountBuffByType(unit, 11) == 1 or CountBuffByType(unit, 29) == 1 or CountBuffByType(unit, 24) == 1 or CountBuffByType(unit, 10) == 1 or CountBuffByType(unit, 29) == 1) then
		return true
	end
	return false
end

function Caitlyn:CanMove(unit)
	if (unit.MoveSpeed < 50 or CountBuffByType(unit.Addr, 5) == 1 or CountBuffByType(unit.Addr, 21) == 1 or CountBuffByType(unit.Addr, 11) == 1 or CountBuffByType(unit.Addr, 29) == 1 or
		unit.HasBuff("recall") or CountBuffByType(unit.Addr, 30) == 1 or CountBuffByType(unit.Addr, 22) == 1 or CountBuffByType(unit.Addr, 8) == 1 or CountBuffByType(unit.Addr, 24) == 1
		or CountBuffByType(unit.Addr, 20) == 1 or CountBuffByType(unit.Addr, 18) == 1) then
		return false
	end
	return true
end

function Caitlyn:CheckWalls(enemyPos)
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

function Caitlyn:IsUnderTurretEnemy(pos)			--Will Only work near myHero
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

function Caitlyn:IsUnderAllyTurret(pos)
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

function Caitlyn:CountEnemiesInRange(pos, range)
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

function Caitlyn:CirclePoints(CircleLineSegmentN, radius, position)
  local points = {}
  for i = 1, CircleLineSegmentN, 1 do
    local angle = i * 2 * math.pi / CircleLineSegmentN
    local point = Vector(position.x + radius * math.cos(angle), position.y + radius * math.sin(angle), position.z);
    table.insert(points, point)
  end
  return points
end
