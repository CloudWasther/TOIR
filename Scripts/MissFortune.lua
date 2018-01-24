IncludeFile("Lib\\TOIR_SDK.lua")

MissFortune = class()

function OnLoad()
	--if GetChampName(GetMyChamp()) == "MissFortune" then
		MissFortune:__init()
	--end
end

function MissFortune:__init()
	-- VPrediction
	vpred = VPrediction(true)
	HPred = HPrediction()

	--TS
    --self.menu_ts = TargetSelector(1750, 0, myHero, true, true, true)


    self.Q = Spell(_Q, GetTrueAttackRange())
    self.Q1 = Spell(_Q, 1300)
    self.W = Spell(_W, GetTrueAttackRange())
    self.E = Spell(_E, 1100)
    self.R = Spell(_R, 1500)

    self.Q:SetTargetted()
    self.Q1:SetSkillShot(0.25, 1500, 70, true)
    self.W:SetTargetted()
    self.E:SetSkillShot(0.5, math.huge, 200, true)
    self.R:SetSkillShot(0.25, 3000, 50, true)

    self.SpellAttack =
{
    ["caitlynheadshotmissile"] = {},
    ["garenslash2"] = {},
    ["masteryidoublestrike"] = {},
    ["renektonexecute"] = {},
    ["rengarnewpassivebuffdash"] = {},
    ["xenzhaothrust"] = {},
    ["xenzhaothrust3"] = {},
    ["lucianpassiveshot"] = {},
    ["frostarrow"] = {},
    ["kennenmegaproc"] = {},
    ["quinnwenhanced"] = {},
    ["renektonsuperexecute"] = {},
    ["trundleq"] = {},
    ["xenzhaothrust2"] = {},
    ["viktorqbuff"] = {},
    ["lucianpassiveattack"] = {},
}

self.NotAttackSpell =
{
    ["volleyattack"] = {},
    ["jarvanivcataclysmattack"] = {},
    ["shyvanadoubleattack"] = {},
    ["zyragraspingplantattack"] = {},
    ["zyragraspingplantattackfire"] = {},
    ["asheqattacknoonhit"] = {},
    ["heimertyellowbasicattack"] = {},
    ["heimertbluebasicattack"] = {},
    ["annietibbersbasicattack"] = {},
    ["yorickdecayedghoulbasicattack"] = {},
    ["yorickspectralghoulbasicattack"] = {},
    ["malzaharvoidlingbasicattack2"] = {},
    ["kindredwolfbasicattack"] = {},
    ["volleyattackwithsound"] = {},
    ["monkeykingdoubleattack"] = {},
    ["shyvanadoubleattackdragon"] = {},
    ["zyragraspingplantattack2"] = {},
    ["zyragraspingplantattack2fire"] = {},
    ["elisespiderlingbasicattack"] = {},
    ["heimertyellowbasicattack2"] = {},
    ["gravesautoattackrecoil"] = {},
    ["annietibbersbasicattack2"] = {},
    ["yorickravenousghoulbasicattack"] = {},
    ["malzaharvoidlingbasicattack"] = {},
    ["malzaharvoidlingbasicattack3"] = {},
}

	self.ts_prio = {}
	self.LastAttackId = 0;
	self.RCastTime = 0;

	Callback.Add("Tick", function(...) self:OnTick(...) end)
	--Callback.Add("Update", function(...) self:OnUpdate(...) end)	
    Callback.Add("Draw", function(...) self:OnDraw(...) end)
    --Callback.Add("ProcessSpell", function(...) self:OnProcessSpell(...) end)
    --Callback.Add("BeforeAttack", function(...) self:OnBeforeAttack(...) end)
    --Callback.Add("NewPath", function(...) self:OnNewPath(...) end)
    --Callback.Add("CreateObject", function(...) self:OnCreateObject(...) end)
    --Callback.Add("DeleteObject", function(...) self:OnDeleteObject(...) end)
    --Callback.Add("UpdateBuff", function(unit, buff, stacks) self:OnUpdateBuff(source, unit, buff, stacks) end)
    Callback.Add("AfterAttack", function(...) self:OnAfterAttack(...) end)
    Callback.Add("DrawMenu", function(...) self:OnDrawMenu(...) end)
    self:MenuValueDefault()
end

function MissFortune:MenuValueDefault()
	self.menu = "MissFortune_Magic"
	self.Draw_When_Already = self:MenuBool("Draw When Already", true)
	self.menu_Draw_Q = self:MenuBool("Draw Q Range", true)
	self.menu_Draw_E = self:MenuBool("Draw E Range", true)
	self.menu_Draw_R = self:MenuBool("Draw R Range", true)

	self.autoQ = self:MenuBool("Auto Q", true)
	self.harassQ = self:MenuBool("Use Q on minion", true)
	self.killQ = self:MenuBool("Use Q only if can kill minion", true)
	self.qMinionMove = self:MenuBool("Don't use if minions moving", true)
	for i, enemy in pairs(GetEnemyHeroes()) do
        table.insert(self.ts_prio, { Enemy = GetAIHero(enemy), Menu = self:MenuBool(GetAIHero(enemy).CharName, true)})
    end

	self.autoW = self:MenuBool("Auto W", true)
	self.autoWslow = self:MenuBool("Auto W if Slow", true)

	self.autoE = self:MenuBool("Auto E", true)
	self.AGC = self:MenuBool("AntiGapcloserE", true)

	self.autoR = self:MenuBool("Auto R", true)

	self.Enalble_Mod_Skin = self:MenuBool("Enalble Mod Skin", false)
	self.Set_Skin = self:MenuSliderInt("Set Skin", 5)

	self.Combo = self:MenuKeyBinding("Combo", 32)
	self.Harass = self:MenuKeyBinding("Harass", 67)
	self.Lane_Clear = self:MenuKeyBinding("Lane Clear", 86)
	self.Last_Hit = self:MenuKeyBinding("Last Hit", 88)
end

function MissFortune:OnDrawMenu()
	if Menu_Begin(self.menu) then
		if Menu_Begin("Q Setting") then
			self.autoQ = Menu_Bool("Auto Q", self.autoQ, self.menu)
			self.harassQ = Menu_Bool("Use Q on minion", self.harassQ, self.menu)	
			self.killQ = Menu_Bool("Use Q only if can kill minion", self.killQ, self.menu)	
			self.qMinionMove = Menu_Bool("Don't use if minions moving", self.qMinionMove, self.menu)	
			Menu_Text("Auto Q to target :")
			for i, enemy in pairs(GetEnemyHeroes()) do
            	self.ts_prio[i].Menu = Menu_Bool(GetAIHero(enemy).CharName, self.ts_prio[i].Menu, self.menu)
        	end
			Menu_End()
		end

		if Menu_Begin("W Setting") then
			self.autoW = Menu_Bool("Auto W", self.autoW, self.menu)	
			self.autoWslow = Menu_Bool("Auto W if Slow", self.autoWslow, self.menu)		
			Menu_End()
		end

		if Menu_Begin("E Setting") then
			self.autoE = Menu_Bool("Auto E", self.autoE, self.menu)	
			self.AGC = Menu_Bool("AntiGapcloserE", self.AGC, self.menu)	
			Menu_End()
		end

		if Menu_Begin("R Setting") then
			self.autoR = Menu_Bool("Auto R", self.autoR, self.menu)	
			Menu_End()
		end

		if Menu_Begin("Draw Spell") then
			self.menu_Draw_Q = Menu_Bool("Draw Q Range", self.menu_Draw_Q, self.menu)
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

function MissFortune:MenuBool(stringKey, bool)
	return ReadIniBoolean(self.menu, stringKey, bool)
end

function MissFortune:MenuSliderInt(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function MissFortune:MenuSliderFloat(stringKey, valueDefault)
	return ReadIniFloat(self.menu, stringKey, valueDefault)
end

function MissFortune:MenuComboBox(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function MissFortune:MenuKeyBinding(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

local function GetDistanceSqr(p1, p2)
    p2 = GetOrigin(p2) or GetOrigin(myHero)
    return (p1.x - p2.x) ^ 2 + ((p1.z or p1.y) - (p2.z or p2.y)) ^ 2
end

function MissFortune:OnProcessSpell(unit, spell)
	
	if spell ~= nil and spell.TargetId ~= nil and unit ~= nil then
		--__PrintTextGame("------------------"..tostring(self.FAKER[spell.Name]))
		if self.FAKER[spell.Name] and GetTargetById(spell.TargetId) == myHero.Addr and self.autoE then
			__PrintTextGame(tostring(self.FAKER[spell.Name]).."--"..tostring(myHero.Addr).."--"..tostring(spell.Name).."--"..tostring(self.FAKER[spell.Name].delay))
			DelayAction(function() CastSpellTarget(myHero.Addr, _E) end, self.FAKER[spell.Name].delay) 
		end
	end
end

function MissFortune:IsAutoAttack(spell)
    --return spell:find("attack") or spell:find("attack") or self.AttacksTbl[spell]
    return (string.find(string.lower(spell), "attack") ~= nil and not self.NotAttackSpell[string.lower(spell)]) or self.SpellAttack[string.lower(spell)]
end

function MissFortune:OnAfterAttack(unit, target)
	if unit.IsMe then		
		if target.Type == 0 then
			if CanCast(_W) then
				if GetKeyPress(self.Combo) > 0 and myHero.MP > 180 and self.autoW then
					CastSpellTarget(myHero.Addr, _W)
				end	
			end
			self.LastAttackId = target.NetworkId
			if CanCast(_Q) then
				if GetDamage("Q", target) + GetAADamageHitEnemy(target.Addr) * 3 > GetHealthPoint(target.Addr) then
					CastSpellTarget(target.Addr, _Q)
				elseif GetKeyPress(self.Combo) > 0 and myHero.MP > 180 then
					CastSpellTarget(target.Addr, _Q)				
				elseif GetKeyPress(self.Harass) > 0 and myHero.MP > 260 and self.Harass then
					for i, enemy in pairs(GetEnemyHeroes()) do
						if enemy ~= nil then
						    if self.ts_prio[i].Menu then	    			    	
						    	if IsValidTarget(target.Addr, self.Q.range) then
						    		if target.NetworkId == self.ts_prio[i].Enemy.NetworkId and self:CanHarras() then				    
										CastSpellTarget(self.ts_prio[i].Enemy.Addr, _Q)
									end
						    	end
						    end
						end	   
					end
				end
			end		
    	end
	end
end

function MissFortune:InCone(Position, finishPos, firstPos, angleSet)
	local range = 420;
	local angle = angleSet * math.pi / 180
	local end2 = finishPos - firstPos
	local edge1 = self:Rotated(end2, -angle / 2)
	local edge2 = self:Rotated(edge1, angle)

	local point = Position - firstPos
	--DrawCircleGame(point.x , point.y, point.z, 2000, Lua_ARGB(255,255,0,0))
	if GetDistanceSqr(point, Vector(0,0,0)) < range * range and self:CrossProduct(edge1, point) > 0 and self:CrossProduct(point, edge2) > 0 then
		return true
	end
	return false
end

function MissFortune:Rotated(v, angle)
	local c = math.cos(angle)
	local s = math.sin(angle)
	return Vector(v.x * c - v.z * s, 0, v.z * c + v.x * s)
end

function MissFortune:CrossProduct(p1, p2)
	return (p2.z * p1.x - p2.x * p1.z)
end

function MissFortune:IsINSIDE_TAMGIAC(target, start, pos1, pos2)
	local v1 = Vector(position):Rotated(0, -angle / 2, 0)
    local v2 = Vector(position):Rotated(0, angle / 2, 0)
end

--[[bool IsINSIDE_TAMGIAC(KPos *pos_diem, KPos *pos_1, KPos *pos_2, KPos *pos_3) 
{ 
    float fAB = (pos_diem->z - pos_1->z)*(pos_2->x - pos_1->x) - (pos_diem->x - pos_1->x)*(pos_2->z - pos_1->z);
    float fBC = (pos_diem->z - pos_2->z)*(pos_3->x - pos_2->x) - (pos_diem->x - pos_2->x)*(pos_3->z - pos_2->z);
    float fCA = (pos_diem->z - pos_3->z)*(pos_1->x - pos_3->x) - (pos_diem->x - pos_3->x)*(pos_1->z - pos_3->z); 

    if ((fAB*fBC > 0.) && (fBC*fCA > 0.)) return true;
    return false;
}]]


function MissFortune:OnDraw()
	--DrawCircleGame(myHero.x , myHero.y, myHero.z, self.Q.range, Lua_ARGB(255,0,0,255))
	--DrawCircleGame(myHero.x , myHero.y, myHero.z, self.Q1.range, Lua_ARGB(255,0,0,255))

		local TargetQ = GetTargetSelector(self.Q1.range, 1)
		if TargetQ ~= 0 then
			target = GetAIHero(TargetQ)
			--local x,y,z = GetPredPos(target.Addr, GetDistance(target.Addr))
			--DrawCircleGame(x , y, z, 225, Lua_ARGB(255,255,0,0))
						--[[local posExt = Vector(target.x, 0, target.z):Extended(Vector(myHero.x, 0, myHero.z), -400)

						DrawCircleGame(target.x , 0, target.z, 450, Lua_ARGB(255,255,0,0))
						DrawCircleGame(posExt.x , 0, posExt.z, 225, Lua_ARGB(255,255,0,0))
						--DrawCircleGame(target.x , target.y, target.z, 450, Lua_ARGB(255,255,0,0))
						--DrawCircleGame(posExt.x , posExt.y, posExt.z, 225, Lua_ARGB(255,255,0,0))
						local p1, p2 = CircleCircleIntersectionS(Vector(target), Vector(posExt), 450, 225)		
						if p1 and p2 then
							--__PrintTextGame(tostring(p1).."--"..tostring(p2))
							DrawCircleGame(p1.x , 0, p1.z, 20, Lua_ARGB(255,255,255,0))
							DrawCircleGame(p2.x , 0, p2.z, 20, Lua_ARGB(255,255,255,0))
						end	]]	


			--[[GetAllUnitAroundAnObject(myHero.Addr, 2000)
		    for i, obj in pairs(pUnit) do
		        if obj ~= 0  then	            
		            if IsEnemy(obj) and not IsDead(obj) and not IsInFog(obj) and (GetType(obj) == 1) then
		            	local minion = GetUnit(obj)
		            	local posExt = Vector(minion):Extended(Vector(myHero), -420)
		            	--DrawCircleGame(posExt.x , posExt.y, posExt.z, 200, Lua_ARGB(255,255,255,0))

		            	--local point = Vector(target) - Vector(minion)
						--__PrintTextGame(tostring(point))
						--DrawCircleGame(point.x , point.y, point.z, 200, Lua_ARGB(255,255,0,0))

						if GetDamage("Q", minion) > minion.HP then
		            	--self:InCone(Vector(target), posExt, Vector(minion), 45)
		            	--if self:InCone(Vector(target), posExt, Vector(minion), 45) then
		            		--DrawCircleGame(minion.x , minion.y, minion.z, 200, Lua_ARGB(255,255,0,0))
		            		--CastSpellTarget(minion.Addr, _Q)
		            	end
		            end
		        end
		    end]]
		end

		

	if self.menu_Draw_Already then
		if self.menu_Draw_Q and self.Q:IsReady() then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.Q.range, Lua_ARGB(255,255,0,0))
		end
		if self.menu_Draw_E and self.E:IsReady() then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.E.range, Lua_ARGB(255,0,255,0))
		end
		if self.menu_Draw_R and self.R:IsReady() then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.R.range, Lua_ARGB(255,0,0,255))
		end
	else
		if self.menu_Draw_Q then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.Q.range, Lua_ARGB(255,255,0,0))
		end
		if self.menu_Draw_E then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.E.range, Lua_ARGB(255,0,255,0))
		end
		if self.menu_Draw_R then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.R.range, Lua_ARGB(255,0,0,255))
		end
	end
end

function MissFortune:OnTick()
	if myHero.IsDead then return end
	SetLuaCombo(true)
	self.HPred_E_M = HPSkillshot({type = "PromptCircle", delay = self.E.delay, range = self.E.range, speed = self.E.speed, radius = self.E.width})
	--__PrintTextGame(tostring(self.Q.range).."--"..tostring(self.Q1.range))
		for i,hero in pairs(GetEnemyHeroes()) do
			if IsValidTarget(hero, 22000) then
				target = GetAIHero(hero)	
						--CastSpellTarget(target.Addr, _W)
				--local posExt = Vector(myHero):Extended(to, distance)
				--__PrintTextGame(tostring(t1).."--"..tostring(t2))
				--local mainCastPosition, mainHitChance = vpred:GetConeAOECastPosition(t2, self.Q.delay, 45, self.Q1.range, self.Q1.speed, t1)
				--__PrintDebug(tostring(mainHitChance))
			end
		end
	if CanCast(_Q) and self.autoQ then
        self:LogicQ();
    end

    if CanCast(_E) and self.autoE then
        self:LogicE();
    end

    self:AntiGapCloser()
		

	if self.Enalble_Mod_Skin then
		ModSkin(self.Set_Skin)
	end		
end

function MissFortune:OnUpdate()

end

function MissFortune:LogicQ()
		local TargetQ = GetTargetSelector(self.Q.range, 0)
		local TargetQ1 = GetTargetSelector(self.Q1.range, 0)
		if IsValidTarget(TargetQ, self.Q.range) and GetDistance(TargetQ) > 500 then
			target = GetAIHero(TargetQ)
			local qDmg = GetDamage("Q", target)
			if qDmg + GetAADamageHitEnemy(target.Addr) > target.HP then
				--CastSpellTarget(target.Addr, _Q)
			elseif qDmg + GetAADamageHitEnemy(target.Addr) * 3 > target.HP then
				--CastSpellTarget(target.Addr, _Q)
			elseif GetKeyPress(self.Combo) > 0 and myHero.MP > 170 then
				--CastSpellTarget(target.Addr, _Q)
			elseif GetKeyPress(self.Harass) > 0 and myHero.MP > 250 then
				for i, enemy in pairs(GetEnemyHeroes()) do
					if enemy ~= nil then
						target = GetAIHero(enemy)
					    if self.ts_prio[i].Menu then	    			    	
					    	if IsValidTarget(self.ts_prio[i].Enemy.Addr, self.Q.range) then
					    		--if target.NetworkId == self.ts_prio[i].Enemy.NetworkId then				    
									--CastSpellTarget(self.ts_prio[i].Enemy.Addr, _Q)
								--end
					    	end
					    end					   
					end	   
				end
			end
		elseif IsValidTarget(TargetQ1, self.Q1.range) and self.harassQ and GetDistance(TargetQ1) > self.Q.range + 50 then
			target1 = GetAIHero(TargetQ1)
			--__PrintTextGame(tostring(GetDamage("Q", target1)))
			local x,y,z = GetPredPos(target1.Addr, GetDistance(target1.Addr))
		    local enemyPredictionPos = Vector(target1) --Vector(x, y ,z)
			GetAllUnitAroundAnObject(target1.Addr, 500)
		    for i, obj in pairs(pUnit) do
		        if obj ~= 0  then
		            local minion = GetUnit(obj)
		            if IsEnemy(minion.Addr) and not IsDead(minion.Addr) and not IsInFog(minion.Addr) and (GetType(minion.Addr) == 1) then
		            	if IsValidTarget(minion.Addr, self.Q1.range) then
		            		if self.qMinionMove then
		            			if minion.IsMove then
		            				return
		            			end
		            		end
		            		local posExt = Vector(minion):Extended(Vector(myHero), -400)
		            		if self.killQ then
		            			if GetDamage("Q", minion) > minion.HP then
									if self:InCone(enemyPredictionPos, posExt, Vector(minion), 60) then
										CastSpellTarget(minion.Addr, _Q)
										--return
									end									
								end
								return
							else
								if self:InCone(enemyPredictionPos, posExt, Vector(minion), 60) then
									CastSpellTarget(minion.Addr, _Q)
								end
							end	
						end
					end
				end
			end
		end

end

function MissFortune:LogicE()
	local TargetE = GetTargetSelector(self.E.range, 0)
	if IsValidTarget(TargetE, self.E.range) then
		target = GetAIHero(TargetE)
		local EPos, EHitChance = HPred:GetPredict(self.HPred_E_M, target, myHero)
		local eDmg = GetDamage("E", target)
		if eDmg > target.HP then			
			CastSpellToPos(EPos.x, EPos.z, _E)
		elseif eDmg + GetDamage("Q", target) > target.HP and myHero.MP > 220 then
			CastSpellToPos(EPos.x, EPos.z, _E)
		elseif GetKeyPress(self.Combo) > 0 and myHero.MP > 250 then
			if GetDistance(EPos) > GetTrueAttackRange() or CountEnemyChampAroundObject(myHero.Addr, 300) > 0 or CountEnemyChampAroundObject(target.Addr, 250) > 1 then
				CastSpellToPos(EPos.x, EPos.z, _E)
			else
				for i, enemy in pairs(GetEnemyHeroes()) do
					if enemy ~= nil then
						target = GetAIHero(enemy)
						if IsValidTarget(target.Addr, self.E.range) then
					    	if not self:CanMove(target) then
								CastSpellToPos(target.x, target.z, _E)
							end
					    end
					end
				end
			end
		end
	end

	for i, enemy in pairs(GetEnemyHeroes()) do
		if enemy ~= nil then
		    target = GetAIHero(enemy)
		    if IsValidTarget(target.Addr, 2000) then
			    local TargetDashing, CanHitDashing, DashPosition = vpred:IsDashing(target, self.E.delay, self.E.width, self.E.speed, myHero, true)	    	
			    if DashPosition ~= nil and GetDistance(DashPosition) <= self.E.range then
				    CastSpellToPos(DashPosition.x, DashPosition.z, _E)
				end
			end
		end
	end
end

function MissFortune:LogicR()
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


function MissFortune:CanMoveOrb(extraWindup)
    return GetTimeGame() + self:GamePing() > GetLastBATick() + GetWindupBA(myHero.Addr) + extraWindup --self.menu_advanced_delayWindup.getValue() /1000
end

function MissFortune:CanHarras()
	local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
	if not self:IsUnderTurretEnemy(myHeroPos) then
		return true
	end
	return false
end

function MissFortune:ValidUlt(unit)
	if CountBuffByType(unit.Addr, 16) == 1 or CountBuffByType(unit.Addr, 15) == 1 or CountBuffByType(unit.Addr, 17) == 1 or unit.HasBuff("kindredrnodeathbuff") or CountBuffByType(unit.Addr, 4) == 1 then
		return false
	end
	return true
end

function MissFortune:RemainE(target)
	if target.HasBuff("MissFortuneechargesound") then
		local stack = GetBuff(GetBuffByName(target.Addr, "MissFortuneechargesound"))
		return stack.EndT - GetTimeGame()
	end
	return 0
end

function MissFortune:AntiGapCloser()
	for i, heros in pairs(GetEnemyHeroes()) do
    	if heros ~= nil then
      		local hero = GetAIHero(heros)
      		--if hero.IsDash then
        		local TargetDashing, CanHitDashing, DashPosition = vpred:IsDashing(hero, 0.09, 65, 2000, myHero, false)
        		local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
        		if DashPosition ~= nil then
        			if GetDistance(DashPosition) < 400 and CanCast(_E) then
          				if self.AGC then
          					CastSpellToPos(DashPosition.x, DashPosition.z, _E)
          				end
          			end
        		end
      		--end
    	end
	end
end

function MissFortune:IsImmobileTarget(unit)
	if (CountBuffByType(unit, 5) == 1 or CountBuffByType(unit, 11) == 1 or CountBuffByType(unit, 29) == 1 or CountBuffByType(unit, 24) == 1 or CountBuffByType(unit, 10) == 1 or CountBuffByType(unit, 29) == 1) then
		return true
	end
	return false
end

function MissFortune:CanMove(unit)
	if (unit.MoveSpeed < 50 or CountBuffByType(unit.Addr, 5) == 1 or CountBuffByType(unit.Addr, 21) == 1 or CountBuffByType(unit.Addr, 11) == 1 or CountBuffByType(unit.Addr, 29) == 1 or
		unit.HasBuff("recall") or CountBuffByType(unit.Addr, 30) == 1 or CountBuffByType(unit.Addr, 22) == 1 or CountBuffByType(unit.Addr, 8) == 1 or CountBuffByType(unit.Addr, 24) == 1
		or CountBuffByType(unit.Addr, 20) == 1 or CountBuffByType(unit.Addr, 18) == 1) then
		return false
	end
	return true
end

function MissFortune:CheckWalls(enemyPos)
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

function MissFortune:IsUnderTurretEnemy(pos)			--Will Only work near myHero
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

function MissFortune:IsUnderAllyTurret(pos)
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

function MissFortune:CountEnemiesInRange(pos, range)
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

function MissFortune:CountAlliesInRange(pos, range)
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




