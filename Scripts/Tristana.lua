IncludeFile("Lib\\TOIR_SDK.lua")

Tristana = class()

function OnLoad()
	if GetChampName(GetMyChamp()) == "Tristana" then
		Tristana:__init()
	end
end

function Tristana:__init()
	-- VPrediction
	vpred = VPrediction(true)

	--TS
    --self.menu_ts = TargetSelector(1750, 0, myHero, true, true, true)


    self.Q = Spell(_Q, GetTrueAttackRange())
    self.W = Spell(_W, 1000)
    self.E = Spell(_E, GetTrueAttackRange())
    self.R = Spell(_R, GetTrueAttackRange())

    self.Q:SetTargetted()
    self.W:SetSkillShot(0.35, 1400, 250, true)
    self.E:SetTargetted()
    self.R:SetTargetted()

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

	Callback.Add("Tick", function(...) self:OnTick(...) end)
	--Callback.Add("Update", function(...) self:OnUpdate(...) end)	
    Callback.Add("Draw", function(...) self:OnDraw(...) end)
    Callback.Add("ProcessSpell", function(...) self:OnProcessSpell(...) end)
    Callback.Add("BeforeAttack", function(...) self:OnBeforeAttack(...) end)
    --Callback.Add("NewPath", function(...) self:OnNewPath(...) end)
    --Callback.Add("CreateObject", function(...) self:OnCreateObject(...) end)
    --Callback.Add("DeleteObject", function(...) self:OnDeleteObject(...) end)
    --Callback.Add("UpdateBuff", function(unit, buff, stacks) self:OnUpdateBuff(source, unit, buff, stacks) end)
    Callback.Add("AfterAttack", function(...) self:OnAfterAttack(...) end)
    Callback.Add("DrawMenu", function(...) self:OnDrawMenu(...) end)
    self:MenuValueDefault()
end

function Tristana:MenuValueDefault()
	self.menu = "Tristana_Magic"
	self.Draw_When_Already = self:MenuBool("Draw When Already", true)
	self.menu_Draw_W = self:MenuBool("Draw W Range", true)
	self.menu_Draw_E = self:MenuBool("Draw E Range", true)
	self.menu_Draw_R = self:MenuBool("Draw R Range", true)
	self.eInfo = self:MenuBool("Draw E Info", true)

	self.qcb = self:MenuBool("Auto Q Combo)", true)
	self.qlc = self:MenuBool("Use Q Lane Clear", true)

	self.Wks = self:MenuBool("W KS logic (W+E+R calculation)", true)
	self.W_Mode = self:MenuComboBox("W GapClose Mode :", 2)
	self.smartW = self:MenuKeyBinding("SmartCast W key", 84)

	--self.harassE = self:MenuBool("Harass E", true)
	self.Eturet = self:MenuBool("E on turrent laneclear", true)
	self.focusE = self:MenuBool("Focus target with E", true)
	for i, enemy in pairs(GetEnemyHeroes()) do
        table.insert(self.ts_prio, { Enemy = GetAIHero(enemy), Menu = self:MenuBool(GetAIHero(enemy).CharName, true)})
    end

	self.autoR = self:MenuBool("Auto R KS (E+R calculation)", true)
	self.turrentR = self:MenuBool("Try R under turrent", true)
	self.allyR = self:MenuBool("Try R under ally", true)
	self.Rgap = self:MenuBool("R GapCloser", true)
	self.OnInterruptableSpell = self:MenuBool("OnInterruptableSpell", true)
	self.RgapHP = self:MenuSliderInt("use gapcloser only under % hp", 40)

	self.Enalble_Mod_Skin = self:MenuBool("Enalble Mod Skin", false)
	self.Set_Skin = self:MenuSliderInt("Set Skin", 15)

	self.Combo = self:MenuKeyBinding("Combo", 32)
	self.Harass = self:MenuKeyBinding("Harass", 67)
	self.Lane_Clear = self:MenuKeyBinding("Lane Clear", 86)
	self.Last_Hit = self:MenuKeyBinding("Last Hit", 88)
end

function Tristana:OnDrawMenu()
	if Menu_Begin(self.menu) then
		if Menu_Begin("Q Setting") then
			self.qcb = Menu_Bool("Auto Q Combo", self.qcb, self.menu)	
			self.qlc = Menu_Bool("Use Q Lane Clear", self.qlc, self.menu)	
			--self.qjg = Menu_KeyBinding("Use Q Jungle", self.qlc, self.menu)	
			Menu_End()
		end

		if Menu_Begin("W Setting") then
			self.Wks = Menu_Bool("W KS logic (W+E+R calculation)", self.Wks, self.menu)	
			self.W_Mode = Menu_ComboBox("W GapClose Mode :", self.W_Mode, "Mouse\0Side\0Safe position\0\0\0", self.menu)
			self.smartW = Menu_KeyBinding("SmartCast W key", self.smartW, self.menu)	
			Menu_End()
		end

		if Menu_Begin("E Setting") then
			--self.harassE = Menu_Bool("Harass E", self.harassE, self.menu)	
			self.Eturet = Menu_Bool("E on turrent laneclear", self.Eturet, self.menu)
			self.focusE = Menu_Bool("Focus target with E", self.focusE, self.menu)
			Menu_Text("Auto E to target :")
			for i, enemy in pairs(GetEnemyHeroes()) do
            	self.ts_prio[i].Menu = Menu_Bool(GetAIHero(enemy).CharName, self.ts_prio[i].Menu, self.menu)
        	end
			Menu_End()
		end

		if Menu_Begin("R Setting") then
			self.autoR = Menu_Bool("Auto R KS (E+R calculation)", self.autoR, self.menu)	
			self.turrentR = Menu_Bool("Try R under turrent", self.turrentR, self.menu)
			self.allyR = Menu_Bool("Try R under ally", self.allyR, self.menu)
			self.OnInterruptableSpell = Menu_Bool("OnInterruptableSpell", self.OnInterruptableSpell, self.menu)
			self.RgapHP = Menu_SliderInt("use gapcloser only under % hp", self.RgapHP, 0, 100, self.menu)
			self.Rgap = Menu_Bool("R GapCloser", self.Rgap, self.menu)
			Menu_End()
		end

		if Menu_Begin("Draw Spell") then
			self.menu_Draw_W = Menu_Bool("Draw W Range", self.menu_Draw_W, self.menu)
			self.menu_Draw_E = Menu_Bool("Draw E Range", self.menu_Draw_E, self.menu)
			self.menu_Draw_R = Menu_Bool("Draw R Range", self.menu_Draw_R, self.menu)
			self.eInfo = Menu_Bool("Draw E Info", self.eInfo, self.menu)
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

function Tristana:MenuBool(stringKey, bool)
	return ReadIniBoolean(self.menu, stringKey, bool)
end

function Tristana:MenuSliderInt(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Tristana:MenuSliderFloat(stringKey, valueDefault)
	return ReadIniFloat(self.menu, stringKey, valueDefault)
end

function Tristana:MenuComboBox(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Tristana:MenuKeyBinding(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Tristana:OnAfterAttack(unit, target)
	if unit.IsMe then
		if target ~= nil and target.Type == 0 and self.qcb then
    		CastSpellTarget(myHero.Addr, _Q)
    	end
    	if target ~= nil and target.Type == 1 and self.qlc then
    		if GetEnemyMinionAroundObject(target.Addr, 700) > 2 then
    			CastSpellTarget(myHero.Addr, _Q)
    		end
    	end
	end
end

function Tristana:OnBeforeAttack(target)
	--if unit.IsMe then
		if target ~= nil and target.Type == 0 then
    		local predHel = GetHealthPoint(target.Addr) - GetAADamageHitEnemy(target.Addr)
    		if GetDamage("E", target) + GetAADamageHitEnemy(target.Addr) * 4 > predHel then
    			CastSpellTarget(target.Addr, _E)
    		elseif CanCast(_R) and GetDamage("E", target) + GetDamage("R", target) > predHel and myHero.MP > 170 then
    			CastSpellTarget(target.Addr, _E)
    		elseif GetKeyPress(self.Combo) > 0 and myHero.MP > 170 then 
    			for i = #self.ts_prio, 1, -1 do
			    	if self.ts_prio[i].Menu then
			    		if IsValidTarget(target.Addr, self.E.range) and target.NetworkId == self.ts_prio[i].Enemy.NetworkId then
			    			CastSpellTarget(target.Addr, _E)
			    		end
			    	end 
			    end
    		end
    	end

    	if target ~= nil and target.Type == 2 then
    		if myHero.MP > 230 then
    			CastSpellTarget(target.Addr, _E)
    		end
    	end
	--end
end


function Tristana:OnTick()
	if myHero.IsDead then return end
	SetLuaCombo(true)
	--self:CatchAxe()
	--local stack = GetBuff(GetBuffByName(myHero.Addr, "TristanaSpinningAttack"))
	--__PrintTextGame(tostring(self:QCount()))

	--[[GetAllBuffNameActive(myHero.Addr)
		for i,v in pairs(pBuffName) do
		__PrintDebug(tostring(v))				      
	end]]
	self:AntiGapCloser()

	if CanCast(_W) and GetKeyPress(self.smartW) > 0 then
		CastSpellToPos(GetMousePos().x, GetMousePos().z, _W)
	end

	if CanCast(_W) then
		self:LogicW()
	end

	if CanCast(_R) then
		self:LogicR()
	end

	if self.Enalble_Mod_Skin then
		ModSkin(self.Set_Skin)
	end		
end

function Tristana:OnUpdate()

end
function Tristana:LogicW()
	if self.Wks and myHero.MP > 160 then
		for i,hero in pairs(GetEnemyHeroes()) do
			if IsValidTarget(hero, self.W.range - 150) then
				target = GetAIHero(hero)				
				if self:ValidUlt(target) and CountEnemyChampAroundObject(target.Addr, 800) < 2 and CountAllyChampAroundObject(target.Addr, 400) == 0 then
					local CastPosition, HitChance, Position = vpred:GetLineCastPosition(target, self.W.delay, self.W.width, self.W.range, self.W.speed, myHero, false)
					local playerAaDmg = GetAADamageHitEnemy(target.Addr)
					local dmgCombo = playerAaDmg + GetDamage("W", target) + self:GetEDmg(target)
					if dmgCombo > target.HP then
						if GetDistance(Vector(target)) < GetTrueAttackRange() then
							if playerAaDmg * 2 + self:GetEDmg(target) < target.HP then
								CastSpellToPos(CastPosition.x, CastPosition.z, _W)
							end
						else
							if playerAaDmg + self:GetEDmg(target) < target.HP then
								CastSpellToPos(CastPosition.x, CastPosition.z, _W)
							end
						end
					elseif CanCast(_R) and GetDamage("R", target) + dmgCombo > target.HP and myHero.MP > 160 then
						CastSpellToPos(CastPosition.x, CastPosition.z, _W)
					end
				end
			end
		end
	end
end

function Tristana:GetEDmg(target)
	if not target.HasBuff("tristanaechargesound") then
		return 0
	end

	return GetDamage("E", target) + (GetDamage("E", target) * 0.3 * (GetBuffStack(target.Addr, "tristanaecharge")))
end

function Tristana:LogicR()
	local bestEnemy = nil
	local pushDistance = 400 + (myHero.LevelSpell(_R) * 200)
	for i,hero in pairs(GetEnemyHeroes()) do
		if IsValidTarget(hero, self.R.range) then
			enemy = GetAIHero(hero)
			if self:ValidUlt(enemy) then
				if bestEnemy == nil then
					bestEnemy = enemy
				elseif GetDistance(Vector(enemy)) < GetDistance(Vector(bestEnemy)) then
					bestEnemy = enemy;
				end

				if GetDamage("R", enemy) + self:GetEDmg(enemy) > enemy.HP and GetDamage("E", enemy) < enemy.HP and self.autoR then
					CastSpellTarget(enemy.Addr, _R)
				end
				local prepos = Vector(enemy)
				local finalPosition = prepos:Extended(Vector(myHero),  -pushDistance)

				if self.turrentR then
					if not self:IsUnderTurretEnemy(finalPosition) and self:IsUnderAllyTurret(finalPosition) and not self:IsUnderTurretEnemy(Vector(myHero)) then
						CastSpellTarget(enemy.Addr, _R)
					end
				end
				if self.allyR and self:CountAlliesInRange(finalPosition, 500) > 1 and self:CountAlliesInRange(prepos, 350) == 0 then
					CastSpellTarget(enemy.Addr, _R)
				end
				if (myHero.HP / myHero.MaxHP) * 100 < self.RgapHP and IsValidTarget(enemy.Addr, 300) and enemy.IsMelee then
					CastSpellTarget(enemy.Addr, _R)
				end
			end
		end
	end		
end


function Tristana:CanMoveOrb(extraWindup)
    return GetTimeGame() + self:GamePing() > GetLastBATick() + GetWindupBA(myHero.Addr) + extraWindup --self.menu_advanced_delayWindup.getValue() /1000
end

function Tristana:CanHarras()
	local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
	if not self:IsUnderTurretEnemy(myHeroPos) and self:CanMoveOrb(50) then
		return true
	end
	return false
end

function Tristana:ValidUlt(unit)
	if CountBuffByType(unit, 16) == 1 or CountBuffByType(unit, 15) == 1 or CountBuffByType(unit, 17) == 1 or unit.HasBuff("kindredrnodeathbuff") or CountBuffByType(unit, 4) == 1 then
		return false
	end
	return true
end

function Tristana:RemainE(target)
	if target.HasBuff("tristanaechargesound") then
		local stack = GetBuff(GetBuffByName(target.Addr, "tristanaechargesound"))
		return stack.EndT - GetTimeGame()
	end
	return 0
end

function Tristana:OnDraw()
	if self.eInfo then
		for i,hero in pairs(GetEnemyHeroes()) do
			if IsValidTarget(hero, 2000) then
				target = GetAIHero(hero)
				local a,b = WorldToScreen(target.x, target.y, target.z)
				local c,d =  GetHealthBarPos(target.Addr)
				if self:GetEDmg(target) > target.HP then
					DrawTextD3DX(a, b, "IS DEAD", Lua_ARGB(255, 0, 255, 10))
				end
				if target.HasBuff("tristanaechargesound") then
					DrawTextD3DX(c, d - 50, "Stack E : "..GetBuffStack(target.Addr, "tristanaecharge").." -- "..self:RemainE(target), Lua_ARGB(255, 0, 255, 10))
				end
			end
		end
	end

	if self.menu_Draw_Already then
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
		if self.menu_Draw_W then
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

function Tristana:OnProcessSpell(unit, spell)
	if spell and unit.IsEnemy then
        if self.listSpellInterrup[spell.Name] ~= nil then
			if self.OnInterruptableSpell and IsValidTarget(unit.Addr, self.R.range) then
				CastSpellTarget(unit.Addr, _R)
			end
		end
	end
end


function Tristana:AntiGapCloser()
	for i, heros in pairs(GetEnemyHeroes()) do
    	if heros ~= nil then
      		local hero = GetAIHero(heros)
      		--if hero.IsDash then
        		local TargetDashing, CanHitDashing, DashPosition = vpred:IsDashing(hero, 0.09, 65, 2000, myHero, false)
        		local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
        		if DashPosition ~= nil then
        			if GetDistance(DashPosition) < 400 and CanCast(_R) then
          				if self.Rgap then
          					CastSpellTarget(hero.Addr, _R)
          				end
          			end

          			if GetDistance(DashPosition) < 400 and CanCast(_W) then
          				points = self:CirclePoints(10, self.W.range, myHeroPos)
	    				bestpoint = myHeroPos:Extended(DashPosition, - self.W.range);
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
	    				if self:IsGoodPosition(bestpoint) then   
                        	CastSpellToPos(bestpoint.x,bestpoint.z, _W)     				
          				end
          			end
        		end
      		--end
    	end
	end
end

function Tristana:IsImmobileTarget(unit)
	if (CountBuffByType(unit, 5) == 1 or CountBuffByType(unit, 11) == 1 or CountBuffByType(unit, 29) == 1 or CountBuffByType(unit, 24) == 1 or CountBuffByType(unit, 10) == 1 or CountBuffByType(unit, 29) == 1) then
		return true
	end
	return false
end

function Tristana:CanMove(unit)
	if (unit.MoveSpeed < 50 or CountBuffByType(unit.Addr, 5) == 1 or CountBuffByType(unit.Addr, 21) == 1 or CountBuffByType(unit.Addr, 11) == 1 or CountBuffByType(unit.Addr, 29) == 1 or
		unit.HasBuff("recall") or CountBuffByType(unit.Addr, 30) == 1 or CountBuffByType(unit.Addr, 22) == 1 or CountBuffByType(unit.Addr, 8) == 1 or CountBuffByType(unit.Addr, 24) == 1
		or CountBuffByType(unit.Addr, 20) == 1 or CountBuffByType(unit.Addr, 18) == 1) then
		return false
	end
	return true
end

function Tristana:CheckWalls(enemyPos)
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

function Tristana:IsUnderTurretEnemy(pos)			--Will Only work near myHero
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

function Tristana:IsUnderAllyTurret(pos)
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

function Tristana:CountEnemiesInRange(pos, range)
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

function Tristana:CountAlliesInRange(pos, range)
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

function Tristana:CirclePoints(CircleLineSegmentN, radius, position)
  local points = {}
  for i = 1, CircleLineSegmentN, 1 do
    local angle = i * 2 * math.pi / CircleLineSegmentN
    local point = Vector(position.x + radius * math.cos(angle), position.y + radius * math.sin(angle), position.z);
    table.insert(points, point)
  end
  return points
end

function Tristana:CastDash(asap)
    asap = asap and asap or false
    local DashMode = self.W_Mode
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

function Tristana:InAARange(point)
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

function Tristana:IsGoodPosition(dashPos)
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


