IncludeFile("Lib\\TOIR_SDK.lua")

Ashe = class()

function OnLoad()
	if GetChampName(GetMyChamp()) == "Ashe" then
		Ashe:__init()
	end
end

function Ashe:__init()
	--orbwalk = Orbwalking()
	-- VPrediction
	vpred = VPrediction(true)
	HPred = HPrediction()
	--TS
    --self.menu_ts = TargetSelector(1750, 0, myHero, true, true, true)

	self.Q = Spell(_Q, GetTrueAttackRange())
    self.W = Spell(_W, 1400)
    self.E = Spell(_E, math.huge)
    self.R = Spell(_R, 3000)

    self.Q:SetTargetted()
    self.W:SetSkillShot(0.25, 1500, 20, true)
    self.E:SetSkillShot(0.25, 1400, 300, true)
    self.R:SetSkillShot(0.25, 1600, 130, true)

    self.WCastTime = 0
    self.grabTime = 0
    self.IsMovingInSameDirection = false
    self.GetTrapPos = nil

    self.listSpellInterrup =
	{
		["KatarinaR"] = true,
		["AlZaharNetherGrasp"] = true,
		["TwistedFateR"] = true,
		["VelkozR"] = true,
		["InfiniteDuress"] = true,
		["JhinR"] = true,
		["CaitlynAceintheHole"] = true,
		["UrgotSwap2"] = true,
		["LucianR"] = true,
		["GalioIdolOfDurand"] = true,
		["MissFortuneBulletTime"] = true,
		["XerathLocusPulse"] = true,
	}

	self.ts_prio = {}
	self.ChampionInfoList = {}

	Callback.Add("Tick", function(...) self:OnTick(...) end)
    Callback.Add("Draw", function(...) self:OnDraw(...) end)
    Callback.Add("ProcessSpell", function(...) self:OnProcessSpell(...) end)
    --Callback.Add("BeforeAttack", function(...) self:OnBeforeAttack(...) end)
    --Callback.Add("NewPath", function(...) self:OnNewPath(...) end)
    --Callback.Add("CreateObject", function(...) self:OnCreateObject(...) end)
    Callback.Add("AfterAttack", function(...) self:OnAfterAttack(...) end)
    Callback.Add("DrawMenu", function(...) self:OnDrawMenu(...) end)

    self:MenuValueDefault()
end

function Ashe:MenuValueDefault()
	self.menu = "Ashe_Magic"
	self.autoQ = self:MenuBool("Auto Q", true)
	self.harassQ = self:MenuBool("Harass Q", true)
	self.farmQ = self:MenuBool("Farm Q", true)

	self.autoW = self:MenuBool("Auto W", false)
	self.harassW = self:MenuBool("Harass W", false)
	self.ksW = self:MenuBool("Auto KS W", true)
	self.ccW = self:MenuBool("W immobile target", true)
	for i, enemy in pairs(GetEnemyHeroes()) do
        table.insert(self.ts_prio, { Enemy = GetAIHero(enemy), Menu = self:MenuBool(GetAIHero(enemy).CharName, true)})
    end

	self.autoE = self:MenuBool("Auto E", true)

	self.autoR = self:MenuBool("Auto R", true)
	self.Rkscombo = self:MenuBool("R KS combo R + W + AA", true)
	self.Rturrent = self:MenuBool("Don't R under turret", true)
	self.autoRaoe = self:MenuBool("Auto R aoe", true)
	--self.MaxRangeR = self:MenuSliderInt("Max R range", 3000)
	--self.MinRangeR = self:MenuSliderInt("Min R range", 900)

	self.Draw_When_Already = self:MenuBool("Draw When Already", true)
	self.menu_Draw_W = self:MenuBool("Draw W Range", true)

	self.Enalble_Mod_Skin = self:MenuBool("Enalble Mod Skin", false)
	self.Set_Skin = self:MenuSliderInt("Set Skin", 10)

	self.Combo = self:MenuKeyBinding("Combo", 32)
	self.Harass = self:MenuKeyBinding("Harass", 67)
	self.Lane_Clear = self:MenuKeyBinding("Lane Clear", 86)
	self.Last_Hit = self:MenuKeyBinding("Last Hit", 88)
end

function Ashe:OnDrawMenu()
	if Menu_Begin(self.menu) then
		if Menu_Begin("Setting Q") then
			self.autoQ = Menu_Bool("Auto Q", self.autoQ, self.menu)
			self.harassQ = Menu_Bool("Harass Q", self.harassQ, self.menu)
			self.farmQ = Menu_Bool("Farm Q", self.farmQ, self.menu)
			Menu_End()
		end
		if Menu_Begin("Setting W") then
			self.autoW = Menu_Bool("Auto W", self.autoW, self.menu)
			self.harassW = Menu_Bool("Harass W", self.harassW, self.menu)
			self.ksW = Menu_Bool("Auto KS W", self.ksW, self.menu)
			self.ccW = Menu_Bool("W immobile target", self.ccW, self.menu)
			Menu_Text("Auto W to target :")
			for i, enemy in pairs(GetEnemyHeroes()) do
            	self.ts_prio[i].Menu = Menu_Bool(GetAIHero(enemy).CharName, self.ts_prio[i].Menu, self.menu)
        	end
			Menu_End()
		end
		if Menu_Begin("Setting E") then
			self.autoE = Menu_Bool("Auto E", self.autoE, self.menu)
			Menu_End()
		end
		if Menu_Begin("Setting R") then
			self.autoR = Menu_Bool("Auto R", self.autoR, self.menu)
			self.Rkscombo = Menu_Bool("R KS combo R + W + AA", self.Rkscombo, self.menu)
			self.Rturrent = Menu_Bool("Don't R under turret", self.Rturrent, self.menu)
			self.autoRaoe = Menu_Bool("Auto R aoe", self.autoRaoe, self.menu)
			--self.MaxRangeR = Menu_SliderInt("Max R range", self.MaxRangeR, 0, 3000, self.menu)
			--self.MinRangeR = Menu_SliderInt("Min R range", self.MinRangeR, 0, 3000, self.menu)
			Menu_End()
		end
		if Menu_Begin("Draw Spell") then
			self.Draw_When_Already = Menu_Bool("Draw When Already", self.Draw_When_Already, self.menu)
			self.menu_Draw_W = Menu_Bool("Draw W Range", self.menu_Draw_W, self.menu)
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

function Ashe:MenuBool(stringKey, bool)
	return ReadIniBoolean(self.menu, stringKey, bool)
end

function Ashe:MenuSliderInt(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Ashe:MenuSliderFloat(stringKey, valueDefault)
	return ReadIniFloat(self.menu, stringKey, valueDefault)
end

function Ashe:MenuComboBox(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Ashe:MenuKeyBinding(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Ashe:OnAfterAttack(unit, target)
	if unit.IsMe then
		if target ~= nil and target.Type == 0 and self.autoQ then
			if GetKeyPress(self.Combo) > 0 and (myHero.MP > 150 or GetHealthPoint(target.Addr) < GetAADamageHitEnemy(target.Addr) * 5) then
    			CastSpellTarget(myHero.Addr, _Q)
    		elseif GetKeyPress(self.Harass) > 0 and myHero.MP > 200 and self.harassQ then
    			for i = #self.ts_prio, 1, -1 do
			    	if self.ts_prio[i].Menu then
			    		if IsValidTarget(target.Addr, GetTrueAttackRange()) and target.NetworkId == self.ts_prio[i].Enemy.NetworkId then
			    			CastSpellTarget(myHero.Addr, _Q)
			    		end
			    	end
			    end
    		end
    	end
    	if target ~= nil and (target.Type == 1 or target.Type == 3) and GetKeyPress(self.Lane_Clear) > 0 then
    		if self.farmQ and GetEnemyMinionAroundObject(myHero.Addr, 700) >= 2 then
    			CastSpellTarget(myHero.Addr, _Q)
    		end
    	end
	end
end

function Ashe:AntiGapCloser()
	for i, heros in pairs(GetEnemyHeroes()) do
    	if heros ~= nil then
      		local hero = GetAIHero(heros)
      		--if hero.IsDash then
        		local TargetDashing, CanHitDashing, DashPosition = vpred:IsDashing(hero, 0.09, 65, self.E.speed, myHero, false)
        		local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
        		if DashPosition ~= nil then
          			if GetDistance(DashPosition) < 400 and CanCast(_R)  then
          				if self:ValidUlt(hero) then
          					CastSpellToPos(DashPosition.x, DashPosition.z, _R)
          				end
          			end
        		end
      		--end
    	end
	end
end

function Ashe:OnTick()
	if myHero.IsDead then return end
	SetLuaCombo(true)

	self.HPred_W_M = HPSkillshot({type = "DelayLine", delay = self.W.delay, range = self.W.range, speed = self.W.speed, collisionH = false, collisionM = true, width = self.W.width})
	self.HPred_R_M = HPSkillshot({type = "DelayLine", delay = self.R.delay, range = self.R.range, speed = self.R.speed, collisionH = true, collisionM = false, width = self.R.width})

	self:AutoEW()

	self:AntiGapCloser()

	if CanCast(_R) then
		self:LogicR()
	end

	if CanCast(_E) and self.autoE then
		self:LogicE()
	end

	if CanCast(_W) and self.autoW then
		self:LogicW()
	end

	if self.Enalble_Mod_Skin then
		ModSkin(self.Set_Skin)
	end
end

function Ashe:LogicW()
	local t = nil
	if GetType(GetTargetOrb()) == 0 then
		t = GetAIHero(GetTargetOrb())	
		if t == 0 then
			t = GetTargetSelector(self.W.range - 150, 1)
		end
	end
	if t ~= nil then
		if IsValidTarget(t, self.W.range - 100) then
			--function VPrediction:GetConeAOECastPosition(unit, delay, angle, range, speed, from)
			local mainCastPosition, mainHitChance = vpred:GetConeAOECastPosition(target, self.W.delay, 45, self.W.range, self.W.speed, myHero)
			--local WPos, WHitChance = HPred:GetPredict(self.HPred_W_M, t, myHero)
			if GetKeyPress(self.Combo) > 0 and myHero.MP > 150 then
				if mainHitChance >=2 then --WHitChance > 1 then
					CastSpellToPos(mainCastPosition.x, mainCastPosition.z, _W)
				end			
			elseif self.ksW and GetDamage("W", t) > t.HP then
				CastSpellToPos(mainCastPosition.x, mainCastPosition.z, _W)
			end
		end
	end
	if self.ccW then
		for i,hero in pairs(GetEnemyHeroes()) do
			if IsValidTarget(hero, self.W.range- 100) then
				target = GetAIHero(hero)
				if not self:CanMove(target) then
					local Collision = CountObjectCollision(0, target.Addr, myHero.x, myHero.z, target.x, target.z, self.W.width, self.W.range, 65)
					CastSpellToPos(target.x, target.z, _W)
				end
				local WPos, WHitChance = HPred:GetPredict(self.HPred_W_M, target, myHero)
				local mainCastPosition, mainHitChance = vpred:GetConeAOECastPosition(target, self.W.delay, 45, self.W.range, self.W.speed, myHero)
				if WHitChance >= 3 then
	                CastSpellToPos(WPos.x, WPos.z, _W)
	            end
				--local CastPosition, HitChance, Position = vpred:GetLineCastPosition(target, self.W.delay, self.W.width, self.W.range, self.W.speed, myHero, false)
				--local Collision = CountObjectCollision(0, target.Addr, myHero.x, myHero.z, CastPosition.x, CastPosition.z, self.W.width, self.W.range, 65)
				if self.harassW and myHero.MP > 250 and self:CanHarras() and IsValidTarget(target, self.W.range - 200) then
					for i = #self.ts_prio, 1, -1 do
					    if self.ts_prio[i].Menu then
					    	if IsValidTarget(target.Addr, self.W.range) and target.NetworkId == self.ts_prio[i].Enemy.NetworkId and mainHitChance >= 2 then
					    		CastSpellToPos(mainCastPosition.x, mainCastPosition.z, _W)
					    	end
					   	end
					end
				end
			end
		end
	end
end

function Ashe:LogicE()
	for i,champ in pairs(GetEnemyHeroes()) do
		if champ ~= 0  then
			if not IsDead(champ) and not IsInFog(champ) then
				hero = GetAIHero(champ)
	            local data = {target = hero, LastVisablePos = Vector(hero), LastVisableTime = GetTimeGame()}
	    		table.insert(self.ChampionInfoList, data)
	    	end
        end
    end

    for i = #self.ChampionInfoList, 1, -1 do
    	--__PrintTextGame(tostring(self.ChampionInfoList[i].LastVisableTime))
	    if --[[IsInFog(self.ChampionInfoList[i].target.Addr) or]] self.ChampionInfoList[i].target.IsDead or GetTimeGame() - self.ChampionInfoList[i].LastVisableTime > 3 then
	    	table.remove(self.ChampionInfoList, i)
	    end

	    if IsInFog(self.ChampionInfoList[i].target.Addr) and GetDistance(self.ChampionInfoList[i].LastVisablePos) < 1000 and GetTimeGame() - self.ChampionInfoList[i].LastVisableTime > 1 and GetTimeGame() - self.ChampionInfoList[i].LastVisableTime < 2 then
	    	--__PrintTextGame(tostring(GetTimeGame() - self.ChampionInfoList[i].LastVisableTime))
	    	pos = Vector(myHero):Extended(self.ChampionInfoList[i].LastVisablePos, 2000)
	    	CastSpellToPos(pos.x, pos.z, _E)
	    end
    end
end

function Ashe:LogicR()
	if self.autoR then
		for i,hero in pairs(GetEnemyHeroes()) do
			if IsValidTarget(hero, 2000) then
				target = GetAIHero(hero)
				if self:ValidUlt(target) then
					local rDmg = GetDamage("R", target)
					--local CastPosition, HitChance, Position = vpred:GetCircularCastPosition(target, self.R.delay, self.R.width, self.R.range, self.R.speed, myHero, false)
					--local Collision = CountObjectCollision(2, target.Addr, myHero.x, myHero.z, CastPosition.x, CastPosition.z, self.R.width, self.R.range, 65)
					local RPos, RHitChance = HPred:GetPredict(self.HPred_R_M, target, myHero)
					if GetKeyPress(self.Combo) > 0 and CountEnemyChampAroundObject(target.Addr, 250) > 2 and self.autoRaoe and IsValidTarget(target.Addr, 1500) and RHitChance >= 2 then
						CastSpellToPos(RPos.x, RPos.z, _R)
					end
					if GetKeyPress(self.Combo) > 0 and IsValidTarget(target.Addr, self.W.range - 100) and self.Rkscombo and GetAADamageHitEnemy(target.Addr) * 5 + rDmg + GetDamage("W", target) > target.HP and
						RHitChance >= 2 and GetBuffByName(target.Addr, "slow") > 0 then
						CastSpellToPos(RPos.x, RPos.z, _R)
					end
					if rDmg > target.HP and CountAllyChampAroundObject(target.Addr, 600) >= 0 and GetDistance(Vector(target)) > 1000 and RHitChance >= 2 then
						CastSpellToPos(RPos.x, RPos.z, _R)
					end
				end
			end
		end
	end
end

function Ashe:ValidUlt(unit)
	if CountBuffByType(unit.Addr, 16) == 1 or CountBuffByType(unit.Addr, 15) == 1 or CountBuffByType(unit.Addr, 17) == 1 or unit.HasBuff("kindredrnodeathbuff") or CountBuffByType(unit.Addr, 4) == 1 then
		return false
	end
	return true
end

function Ashe:CanHarras()
	local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
	if not self:IsUnderTurretEnemy(myHeroPos) then
		return true
	end
	return false
end

function Ashe:AutoEW()
	for i,hero in pairs(GetEnemyHeroes()) do
		if hero ~= nil then
			target = GetAIHero(hero)
			if IsValidTarget(target, self.W.range) then
				local TargetDashing, CanHitDashing, DashPosition = vpred:IsDashing(target, self.W.delay, self.W.width, self.W.speed, myHero, false)
			    if DashPosition ~= nil then
			    	local collision = CountObjectCollision(0, target.Addr, myHero.x, myHero.z, DashPosition.x, DashPosition.z, self.W.width, self.W.range, 65)
			    	if GetDistance(DashPosition) <= self.W.range and collision == 0 then
			    		CastSpellToPos(DashPosition.x, DashPosition.z, _W)
			    	end
				end
			end
		end
	end
end

function Ashe:OnDraw()
	if self.menu_Draw_Already then
		if self.menu_Draw_W and self.W:IsReady() then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.W.range, Lua_ARGB(255,255,0,0))
		end
	else
		if self.menu_Draw_W then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.W.range, Lua_ARGB(255,255,0,0))
		end
	end
end

function Ashe:OnProcessSpell(unit, spell)
	local spellName = spell.Name:lower()
	if spell and unit.IsEnemy then
        if self.listSpellInterrup[spell.Name] ~= nil then
			--local CastPosition, HitChance, Position = vpred:GetCircularCastPosition(unit, self.R.delay, self.R.width, self.R.range, self.R.speed, myHero, false)
			--local Collision = CountObjectCollision(2, unit.Addr, myHero.x, myHero.z, unit.x, unit.z, self.R.width, self.R.range, 65)
			--if Collision == 0 then
				CastSpellToPos(unit.x, unit.z, _R)
			--end
		end
	end
end

function Ashe:IsImmobileTarget(unit)
	if (CountBuffByType(unit, 5) == 1 or CountBuffByType(unit, 11) == 1 or CountBuffByType(unit, 29) == 1 or CountBuffByType(unit, 24) == 1 or CountBuffByType(unit, 10) == 1 or CountBuffByType(unit, 29) == 1) then
		return true
	end
	return false
end

function Ashe:CanMove(unit)
	if (unit.MoveSpeed < 50 or CountBuffByType(unit.Addr, 5) == 1 or CountBuffByType(unit.Addr, 21) == 1 or CountBuffByType(unit.Addr, 11) == 1 or CountBuffByType(unit.Addr, 29) == 1 or
		unit.HasBuff("recall") or CountBuffByType(unit.Addr, 30) == 1 or CountBuffByType(unit.Addr, 22) == 1 or CountBuffByType(unit.Addr, 8) == 1 or CountBuffByType(unit.Addr, 24) == 1
		or CountBuffByType(unit.Addr, 20) == 1 or CountBuffByType(unit.Addr, 18) == 1) then
		return false
	end
	return true
end

function Ashe:CheckWalls(enemyPos)
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

function Ashe:IsUnderTurretEnemy(pos)			--Will Only work near myHero
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

function Ashe:IsUnderAllyTurret(pos)
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

function Ashe:CountEnemiesInRange(pos, range)
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
