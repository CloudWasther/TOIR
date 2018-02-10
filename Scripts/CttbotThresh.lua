IncludeFile("Lib\\TOIR_SDK.lua")
--IncludeFile("Lib\\OrbNew.lua")
--IncludeFile("Lib\\AllClass.lua")

Thresh = class()

function OnLoad()
	--if GetChampName(GetMyChamp()) == "Thresh" then
		Thresh:__init()
	--end
end

function Thresh:__init()
	if myHero.CharName ~= "Thresh" then
        return;
    end
	-- VPrediction
	vpred = VPrediction(true)
	--HPred = HPrediction()
	AntiGap = AntiGapcloser(nil)
	--TS
    --self.menu_ts = TargetSelector(1750, 0, myHero, true, true, true)

	--menuInstSep.setValue("Thresh Magic")

	self.Q = Spell(_Q, 1175)
    self.W = Spell(_W, 1075)
    self.E = Spell(_E, 500)
    self.R = Spell(_R, 450)
    self.Q:SetSkillShot(0.5, 1900, 70, true)
    self.W:SetSkillShot(0.25, 1900, 70, false)
    self.E:SetSkillShot(0.25, 1900, 70, false)
    self.R:SetActive()

    self.Marked = nil
    self.ts_prio = {}
    self.grab = 0
	self.grabS = 0
	self.grabW = 0
	self.lastQ = 0
	self.posEndDash = Vector(0, 0, 0)
	self.DurationEx = 0
	self.lastCast = 0

	Thresh:aa()

	Callback.Add("Update", function(...) self:OnUpdate(...) end)
	Callback.Add("AntiGapClose", function(target, EndPos) self:OnAntiGapClose(target, EndPos) end)
    Callback.Add("Draw", function(...) self:OnDraw(...) end)
    Callback.Add("ProcessSpell", function(...) self:OnProcessSpell(...) end)
    Callback.Add("UpdateBuff", function(unit, buff, stacks) self:OnUpdateBuff(source, unit, buff, stacks) end)
    Callback.Add("RemoveBuff", function(unit, buff) self:OnRemoveBuff(unit, buff) end)

    Callback.Add("DrawMenu", function(...) self:OnDrawMenu(...) end)

    self:MenuValueDefault()
end

function Thresh:MenuValueDefault()
	self.menu = "Thresh_Magic"

	self.menu_Combo_Q = self:MenuBool("Use Q", true)
	self.maxGrab = self:MenuSliderInt("Max range grab", self.Q.range - 150)
	self.minGrab = self:MenuSliderInt("Min range grab", 250)
	self.menu_Combo_Q2 = self:MenuBool("Use Q2", true)	
	self.qCC = self:MenuBool("Auto Q cc", true)
	self.qTur = self:MenuBool("Auto Q under turret", true)
	self.GapQ = self:MenuBool("OnEnemyGapcloser Q", true)
	self.Qspell = self:MenuBool("Q on special spell detection", true)
	self.menu_Combo_QendDash = self:MenuBool("Auto Q End Dash", true)
	self.menu_Combo_Qinterrup = self:MenuBool("Use Q Interrup", true)
	self.menu_Combo_Qks = self:MenuBool("Use Q Kill Steal", true)
	self.qHC = self:MenuComboBox("Q HitChance", 3)
	--self.PredicMode = self:MenuComboBox("Prediction Mode", 1)
	for i, enemy in pairs(GetEnemyHeroes()) do
        table.insert(self.ts_prio, { Enemy = GetAIHero(enemy), Menu = self:MenuBool(GetAIHero(enemy).CharName, true)})
    end

	self.menu_Combo_W = self:MenuBool("Auto Use W Combo", true)
	self.menu_Combo_Wsavehp = self:MenuSliderInt("Save When HP", 30)
	self.menu_Combo_Wshieldhp = self:MenuSliderInt("Shield Allies on CC", 20)

	self.autoW = self:MenuBool("Auto W", true)
	self.Wdmg = self:MenuSliderInt("W dmg % hp", 10)
	self.autoW3 = self:MenuBool("Auto W shield big dmg", true)
	self.autoW2 = self:MenuBool("Auto W if Q succesfull", true)
	self.autoW4 = self:MenuBool("Auto W vs Blitz Hook", true)
	self.autoW5 = self:MenuBool("Auto W if jungler pings", true)
	self.autoW6 = self:MenuBool("Auto W on gapCloser", true)
	self.autoW7 = self:MenuBool("Auto W on Slows/Stuns", true)
	self.wCount = self:MenuSliderInt("Auto W if x enemies near ally", 3)

	self.menu_Combo_Epull = self:MenuKeyBinding("Use E Pull", 32)
	self.menu_Combo_Epush = self:MenuKeyBinding("Use E Push", 88)
	self.menu_Combo_Egap = self:MenuBool("Use E Anti Gapclose", true)
	self.menu_Combo_Einterrup = self:MenuBool("Use E Interrup", true)
	self.menu_Combo_Eks = self:MenuBool("Use E Kill Steal", true)

	self.menu_Combo_Reneme = self:MenuSliderInt("Save When HP", 2)
	self.menu_Combo_Rks = self:MenuBool("Use R Kill Steal", true)


	self.Draw_When_Already = self:MenuBool("Draw When Already", false)
	self.Draw_Q_Range = self:MenuBool("Draw Q Range", false)
	self.Draw_W_Range = self:MenuBool("Draw W Range", false)
	self.Draw_E_Range = self:MenuBool("Draw E Range", false)
	self.Draw_R_Range = self:MenuBool("Draw R Range", false)
	self.menu_Draw_CountQ = self:MenuBool("Draw Q Counter", false)

	self.Enalble_Mod_Skin = self:MenuBool("Enalble Mod Skin", false)
	self.Set_Skin = self:MenuSliderInt("Set Skin", 5)

	self.Combo = self:MenuKeyBinding("Combo", 32)
end

function Thresh:OnDrawMenu()
	if Menu_Begin(self.menu) then
		if Menu_Begin("Setting Q") then
			self.menu_Combo_Q = Menu_Bool("Use Q", self.menu_Combo_Q, self.menu)
			self.minGrab = Menu_SliderInt("Min range grab", self.minGrab, 125, self.Q.range - 150, self.menu)
			self.maxGrab = Menu_SliderInt("Max range grab", self.maxGrab, 125, self.Q.range - 150, self.menu)
			self.menu_Combo_Q2 = Menu_Bool("Use Q2", self.menu_Combo_Q2, self.menu)
			self.Qspell = Menu_Bool("Q on special spell detection", self.Qspell, self.menu)
			self.qCC = Menu_Bool("Auto Q cc", self.qCC, self.menu)
			self.qTur = Menu_Bool("Auto Q under turret", self.qTur, self.menu)
			self.GapQ = Menu_Bool("OnEnemyGapcloser Q", self.GapQ, self.menu)
			self.menu_Combo_QendDash = Menu_Bool("Auto Q End Dash", self.menu_Combo_QendDash, self.menu)
			self.menu_Combo_Qinterrup = Menu_Bool("Use Q Interrup", self.menu_Combo_Qinterrup, self.menu)
			self.menu_Combo_Qks = Menu_Bool("Use Q Kill Steal", self.menu_Combo_Qks, self.menu)
			--self.PredicMode = Menu_ComboBox("Prediction Mode", self.PredicMode, "VPrediction\0HPrediction\0CorePrediction (not yet)\0\0", self.menu)
			self.qHC = Menu_ComboBox("Q HitChance", self.qHC, "Low\0Medium\0High\0Very High\0\0", self.menu)
			Menu_Text("Auto Q to target :")
			for i, enemy in pairs(GetEnemyHeroes()) do
            	self.ts_prio[i].Menu = Menu_Bool(GetAIHero(enemy).CharName, self.ts_prio[i].Menu, self.menu)
        	end
			Menu_End()
		end
		if Menu_Begin("Setting W") then
			self.menu_Combo_W = Menu_Bool("Auto Use W Combo", self.menu_Combo_W, self.menu)
			self.menu_Combo_Wsavehp = Menu_SliderInt("Save When HP", self.menu_Combo_Wsavehp, 0, 100, self.menu)
			self.menu_Combo_Wshieldhp = Menu_SliderInt("Shield Allies on CC", self.menu_Combo_Wshieldhp, 0, 100, self.menu)

			self.autoW = Menu_Bool("Auto W", self.autoW, self.menu)
			self.Wdmg = Menu_SliderInt("W dmg % hp", self.Wdmg, 0, 100, self.menu)
			self.autoW3 = Menu_Bool("Auto W shield big dmg", self.autoW3, self.menu)
			self.autoW2 = Menu_Bool("Auto W if Q succesfull", self.autoW2, self.menu)
			self.autoW4 = Menu_Bool("Auto W vs Blitz Hook", self.autoW4, self.menu)
			self.autoW5 = Menu_Bool("Auto W if jungler pings", self.autoW5, self.menu)
			self.autoW6 = Menu_Bool("Auto W on gapCloser", self.autoW6, self.menu)
			self.autoW7 = Menu_Bool("Auto W on Slows/Stuns", self.autoW7, self.menu)
			self.wCount = Menu_SliderInt("Auto W if x enemies near ally", self.wCount, 0, 5, self.menu)

			Menu_End()
		end
		if Menu_Begin("Setting E") then
			self.menu_Combo_Epull = Menu_KeyBinding("Use E Pull", self.menu_Combo_Epull, self.menu)
			self.menu_Combo_Epush = Menu_KeyBinding("Use E Push", self.menu_Combo_Epush, self.menu)
			self.menu_Combo_Egap = Menu_Bool("Use E Anti Gapclose", self.menu_Combo_Egap, self.menu)
			self.menu_Combo_Einterrup = Menu_Bool("Use E Interrup", self.menu_Combo_Einterrup, self.menu)
			self.menu_Combo_Eks = Menu_Bool("Use E Kill Steal", self.menu_Combo_Eks, self.menu)
			Menu_End()
		end
		if Menu_Begin("Setting R") then
			self.menu_Combo_Reneme = Menu_SliderInt("Enable R for x Enemy", self.menu_Combo_Reneme, 1, 5, self.menu)
			self.menu_Combo_Rks = Menu_Bool("Use R Kill Steal", self.menu_Combo_Rks, self.menu)
			Menu_End()
		end
		if Menu_Begin("Draw Spell") then
			self.Draw_When_Already = Menu_Bool("Draw When Already", self.Draw_When_Already, self.menu)
			self.Draw_Q_Range = Menu_Bool("Draw Q Range", self.Draw_Q_Range, self.menu)
			self.Draw_W_Range = Menu_Bool("Draw W Range", self.Draw_W_Range, self.menu)
			self.Draw_E_Range = Menu_Bool("Draw E Range", self.Draw_E_Range, self.menu)
			self.Draw_R_Range = Menu_Bool("Draw R Range", self.Draw_R_Range, self.menu)
			self.menu_Draw_CountQ = Menu_Bool("Draw Q Counter", self.menu_Draw_CountQ, self.menu)
			Menu_End()
		end
		if Menu_Begin("Mod Skin") then
			self.Enalble_Mod_Skin = Menu_Bool("Enalble Mod Skin", self.Enalble_Mod_Skin, self.menu)
			self.Set_Skin = Menu_SliderInt("Set Skin", self.Set_Skin, 0, 20, self.menu)
			Menu_End()
		end
		if Menu_Begin("Key Mode") then
			self.Combo = Menu_KeyBinding("Combo", self.Combo, self.menu)
			Menu_End()
		end
		Menu_End()
	end
end

function Thresh:MenuBool(stringKey, bool)
	return ReadIniBoolean(self.menu, stringKey, bool)
end

function Thresh:MenuSliderInt(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Thresh:MenuSliderFloat(stringKey, valueDefault)
	return ReadIniFloat(self.menu, stringKey, valueDefault)
end

function Thresh:MenuComboBox(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Thresh:MenuKeyBinding(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Thresh:HitChanceManager(hc)
	return (hc + 3)
end

function Thresh:GetQLinePreCore(target)
	local castPosX, castPosZ, unitPosX, unitPosZ, hitChance, _aoeTargetsHitCount = GetPredictionCore(target.Addr, 0, self.Q.delay, self.Q.width, self.Q.range, self.Q.speed, myHero.x, myHero.z, false, true, 1, 0, 5, 5, 5, 5)
	if target ~= nil then
		 CastPosition = Vector(castPosX, target.y, castPosZ)
		 HitChance = hitChance
		 Position = Vector(unitPosX, target.y, unitPosZ)
		 return CastPosition, HitChance, Position
	end
	return nil , 0 , nil
end

function Thresh:OnUpdate()
	if (IsDead(myHero.Addr) or myHero.IsRecall or IsTyping() or IsDodging()) then return end
	SetLuaCombo(true)

	--self.HPred_Q_M = HPSkillshot({type = "DelayLine", delay = self.Q.delay, range = self.Q.range, speed = self.Q.speed, collisionH = false, collisionM = true, width = self.Q.width})

	if self.Marked ~= nil then
		if IsValidTarget(self.Marked.Addr, self.W.range) and GetKeyPress(self.Combo) > 0 then
			if self.W:IsReady() and self.autoW2 then
				for i,hero in pairs(GetAllyHeroes()) do
					if hero ~= nil then
						ally = GetAIHero(hero)
						if not ally.IsMe and not ally.IsDead and GetDistance(ally.Addr) < self.W.range + 300 then
							if GetDistance(Vector(self.Marked), Vector(ally)) > 800 and GetDistance(Vector(ally)) > 600 then
								--CastSpellToPos(ally.x, ally.z, _W)
								self:CastW(Vector(ally))
							end
						end
					end
				end
			end
		end
	end

	if CanCast(_Q) then
		self:LogicQ();
	end
	if CanCast(_E) then
		self:LogicE();
	end
	if CanCast(_W) then
		self:LogicW();
	end
	if CanCast(_R) then
		self:LogicR();
	end

	if self.menu_Combo_QendDash then
		self:autoQtoEndDash()
	end

	self:KillSteal()

	if not self.Q:IsReady() and GetTimeGame() - self.grabW > 2 then
		local targetQ = GetTargetSelector(self.Q.range, 0) --orbwalk:getTarget(self.Q.range)
		if GetBuffByName(targetQ, "ThreshQ") ~= 0 and IsValidTarget(targetQ, self.Q.range) then
			self.grabS = self.grabS + 1
			self.grabW = GetTimeGame()
			self.lastQ = GetTimeGame()
		end
	end

	if self.Enalble_Mod_Skin then
		ModSkin(self.Set_Skin)
	end
end

function Thresh:OnDraw()

	if self.Draw_When_Already then
		if self.Draw_Q_Range and self.Q:IsReady() then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.Q.range, Lua_ARGB(255,255,0,0))
		end
		if self.Draw_W_Range and self.W:IsReady() then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.W.range, Lua_ARGB(255,255,0,255))
		end
		if self.Draw_E_Range and self.E:IsReady() then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.E.range, Lua_ARGB(255,0,255,0))
		end
		if self.Draw_R_Range and self.R:IsReady() then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.R.range, Lua_ARGB(255,0,0,255))
		end
	else
		if self.Draw_Q_Range then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.Q.range, Lua_ARGB(255,255,0,0))
		end
		if self.Draw_W_Range and self.W:IsReady() then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.W.range, Lua_ARGB(255,255,0,255))
		end
		if self.Draw_E_Range then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.E.range, Lua_ARGB(255,0,255,0))
		end
		if self.Draw_R_Range then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.R.range, Lua_ARGB(255,0,0,255))
		end
	end

	if self.posEndDash ~= 0 and self.lastCast + 2 * self.DurationEx + 0.1 > GetTimeGame() and self.lastCast + self.DurationEx < GetTimeGame() then
		DrawCircleGame(self.posEndDash.x , self.posEndDash.y, self.posEndDash.z, 200, Lua_ARGB(255,255,0,0))
	end

	local percent = 0
    if (self.grab > 0) and self.menu_Draw_CountQ then
		percent = (self.grabS / self.grab) * 100
		DrawTextD3DX(100, 100, " grab: "..tostring(self.grab).." grab successful: " ..tostring(self.grabS).. " grab successful % : " ..tostring(percent).. "%", Lua_ARGB(255, 0, 255, 10))
	end
end

function Thresh:OnUpdateBuff(source, unit, buff, stacks)
	if unit.IsEnemy and buff.Name == "ThreshQ" then
		self.Marked = unit
	end
end

function Thresh:OnRemoveBuff(unit, buff)
	if unit.IsEnemy and buff.Name == "ThreshQ" then
		self.Marked = nil
	end
end

function Thresh:OnAntiGapClose(target, EndPos)
	hero = GetAIHero(target.Addr)
    if GetDistance(EndPos) < 500 or GetDistance(hero) < 500 then
        if self.autoW6 then
          	for i,hero in pairs(GetAllyHeroes()) do
				if hero ~= nil then
					ally = GetAIHero(hero)
					if not ally.IsMe and not ally.IsDead and GetDistance(ally.Addr) < self.W.range + 400 and CanCast(_W) then
						--CastSpellToPos(ally.x, ally.z, _W)
						self:CastW(Vector(ally))
					end
				end
			end
        end
        if self.menu_Combo_Egap and CanCast(_E) then
          	CastSpellToPos(target.x, target.z, _E)
        elseif CanCast(_Q) and self.GapQ then
          	CastSpellToPos(target.x, target.z, _Q)
        end
    end
end

function Thresh:AntiGapCloser()
	for i, heros in pairs(GetEnemyHeroes()) do
    	if heros ~= nil then
      		local hero = GetAIHero(heros)
      		--if hero.IsDash then
        		local TargetDashing, CanHitDashing, DashPosition = vpred:IsDashing(hero, 0.09, 65, 2000, myHero, false)
        		local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
        		if DashPosition ~= nil then
          			if GetDistance(DashPosition) < 400 and CanCast(_E) then
          				if self.autoW6 then
          					for i,hero in pairs(GetAllyHeroes()) do
								if hero ~= nil then
									ally = GetAIHero(hero)
									if not ally.IsMe and not ally.IsDead and GetDistance(ally.Addr) < self.W.range + 400 then
										--CastSpellToPos(ally.x, ally.z, _W)
										self:CastW(Vector(ally))
									end
								end
							end
          				end
          				if self.menu_Combo_Egap and not IsValidTarget(self.Marked.Addr, 1000) then
          					CastSpellToPos(DashPosition.x, DashPosition.z, _E)
          				elseif CanCast(_Q) and self.GapQ then
          					CastSpellToPos(DashPosition.x, DashPosition.z, _Q)
          				end 
          			end
        		end
      		--end
    	end
	end
end

function Thresh:LogicE()
	local TargetE = GetTargetSelector(self.E.range, 0)
	--__PrintTextGame(tostring(TargetE))
	if TargetE ~= 0 and self.Marked == nil then
		target = GetAIHero(TargetE)
		if self:CanMove(target) then
			if CanCast(_E) and GetKeyPress(self.menu_Combo_Epull) > 0 and IsValidTarget(target.Addr, self.E.range) then
				self:Pull(target)
			end
			if CanCast(_E) and GetKeyPress(self.menu_Combo_Epush) > 0 and IsValidTarget(target.Addr, self.E.range) then
				self:Push(target)
			end
		end
	end
end

function Thresh:LogicQ()
	local TargetQ = GetTargetSelector(self.maxGrab, 0)
	if CanCast(_Q) and TargetQ ~= 0 then
		target = GetAIHero(TargetQ)
		--local QPos, QHitChance = HPred:GetPredict(self.HPred_Q_M, target, myHero)
		--local CastPosition, HitChance, Position = vpred:GetLineCastPosition(target, self.Q.delay, self.Q.width, self.Q.range, self.Q.speed, myHero, true)
		local CastPosition, HitChance, Position = self:GetQLinePreCore(target)
		
		if (GetDistance(CastPosition) < self.maxGrab and GetDistance(target.Addr) > self.minGrab)  or CountEnemyChampAroundObject(target.Addr, 1500) == 1 then
			if self.menu_Combo_Q and GetKeyPress(self.Combo) > 0 and not self:Qstat(target) and self.Marked == nil then
		        if HitChance >= self:HitChanceManager(self.qHC) then
		        	CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
		        end
		    end
		end
		if self.menu_Combo_Q2 and GetTimeGame() - self.lastQ > 1 and self:Qstat(target) then
				CastSpellTarget(myHero.Addr, _Q)
		end
	end

	for i, enemy in pairs(GetEnemyHeroes()) do
		if enemy ~= nil then
			target = GetAIHero(enemy)
			--local QPos, QHitChance = HPred:GetPredict(self.HPred_Q_M, self.ts_prio[i].Enemy, myHero)
			--local CastPosition, HitChance, Position = vpred:GetLineCastPosition(self.ts_prio[i].Enemy, self.Q.delay, self.Q.width, self.Q.range, self.Q.speed, myHero, true)
			local CastPosition, HitChance, Position = self:GetQLinePreCore(target)
		    if self.ts_prio[i].Menu then	    			    	
		    	if IsValidTarget(target.Addr, self.maxGrab) then
		    		if target.NetworkId == self.ts_prio[i].Enemy.NetworkId and self:CanHarras() then				    
						if not self:Qstat(self.ts_prio[i].Enemy) and self.Marked == nil then
							if HitChance >= self:HitChanceManager(self.qHC) then
					        	CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
					        end
						end
					end
		    	end
		    end

		    if IsValidTarget(target.Addr, self.maxGrab) then
		    	if not self:CanMove(target) and self.qCC then
		    		local Collision = CountCollision(myHero.x, myHero.z, target.x, target.z, self.Q.delay, self.Q.width, self.Q.range, self.Q.speed, 0, 5, 5, 5, 5)
					--local Collision = CountObjectCollision(0, target.Addr, myHero.x, myHero.z, target.x, target.z, self.Q.width, self.Q.range, 65)
				    if Collision == 0 and not self:Qstat(target) and self.Marked == nil then
				        CastSpellToPos(target.x, target.z, _Q)
				    end
				end
		    end

		    if IsValidTarget(target.Addr, self.maxGrab) and self.qTur then
				if self:IsUnderAllyTurret(Vector(target)) then
					if HitChance >= self:HitChanceManager(self.qHC) and self.Marked == nil then
					    CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
					end
				end
		    end
		end
	end
end

function Thresh:autoQtoEndDash()
	for i, enemy in pairs(GetEnemyHeroes()) do
		if enemy ~= nil then
		    target = GetAIHero(enemy)
		    if IsValidTarget(target, 2000) then
				local TargetDashing, CanHitDashing, DashPosition = vpred:IsDashing(target, 0.25, 65, 2000, myHero)
			    if DashPosition ~= nil then
			    	if GetDistance(DashPosition) <= self.Q.range then
				  		local Collision = CountCollision(myHero.x, myHero.z, DashPosition.x, DashPosition.z, self.Q.delay, self.Q.width, self.Q.range, self.Q.speed, 0, 5, 5, 5, 5)
				  		if Collision == 0 and not self:Qstat(target) and self.Marked == nil then
					    	CastSpellToPos(DashPosition.x, DashPosition.z, _Q)
					    end
					end
					if GetDistance(DashPosition) < self.E.range then
						CastSpellToPos(DashPosition.x, DashPosition.z, _E)
					end
				end
			end
		end
	end
end

function Thresh:LogicR()
	local rCountOut = CountEnemyChampAroundObject(myHero.Addr, self.R.range)
	local rCountIn = CountEnemyChampAroundObject(myHero.Addr, 250)
	if rCountOut > rCountIn then
		if rCountOut >= self.menu_Combo_Reneme then
			CastSpellTarget(myHero.Addr, _R)
		end
		if self.comboR then
			local TargetR = GetTargetSelector(self.R.range, 0)
			if TargetR ~= 0 then
				target = GetAIHero(TargetR)
				if self:IsUnderAllyTurret(Vector(myHero)) or GetKeyPress(self.Combo) > 0 then
					if GetDistance(Vector(target)) < self.R.range - 100 then
						CastSpellTarget(myHero.Addr, _R)
					end
				end
			end
		end
	end
end

function Thresh:LogicW()
	if self.autoW then
		for i,hero in pairs(GetAllyHeroes()) do
			if hero ~= nil then
				ally = GetAIHero(hero)
				if not ally.IsMe and not ally.IsDead and GetDistance(ally.Addr) < self.W.range + 400 then
					if self.autoW4 and ally.Name == "Blitzcrank" then
						if ally.HasBuff("rocketgrab2") and CanCast(_W) then
							--CastSpellToPos(ally.x, ally.z, _W)
							self:CastW(Vector(ally))
						end
					end
					if self.autoW7 then
						if CountBuffByType(ally.Addr, 5) > 0 or CountBuffByType(ally.Addr, 5) > 0 then
							--CastSpellToPos(ally.x, ally.z, _W)
							self:CastW(Vector(ally))
						end
					end
					local nearEnemys = CountEnemyChampAroundObject(ally.Addr, 900)
					if nearEnemys >= self.wCount then
						--CastSpellToPos(ally.x, ally.z, _W)
						self:CastW(Vector(ally))
					end
					if self.Wdmg >= ally.HP / ally.MaxHP * 100 then
						--CastSpellToPos(ally.x, ally.z, _W)
						self:CastW(Vector(ally))
					end
				end
			end
		end
	end  
	if myHero.HP / myHero.HP * 100 <= self.Wdmg then
		CastSpellToPos(myHero.x, myHero.z, _W)
	end
end

function Thresh:CanHarras()
	local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
	if not self:IsUnderTurretEnemy(myHeroPos) then
		return true
	end
	return false
end

function Thresh:CanMove(unit)
	if (CountBuffByType(unit.Addr, 5) == 1 or CountBuffByType(unit.Addr, 21) == 1 or CountBuffByType(unit.Addr, 11) == 1 or CountBuffByType(unit.Addr, 29) == 1 or
		unit.HasBuff("recall") or CountBuffByType(unit.Addr, 30) == 1 or CountBuffByType(unit.Addr, 22) == 1 or CountBuffByType(unit.Addr, 8) == 1 or CountBuffByType(unit.Addr, 24) == 1
		or CountBuffByType(unit.Addr, 20) == 1 or CountBuffByType(unit.Addr, 18) == 1) then
		return false
	end
	return true
end

function Thresh:Qstat(target)
	--target = t or GetTargetSelector(self.Q.range - 150, 0)
	if not self.Q:IsReady() then
		return false
	end
	if GetBuffByName(target.Addr, "ThreshQ") > 0 then
		return true
	end
	return false
end

function Thresh:OnProcessSpell(unit, spell)
	if spell and unit.IsMe and spell.Name == "ThreshQ" then
		self.grab = self.grab + 1
	end

	if spell and unit.IsEnemy and IsValidTarget(unit.Addr, self.Q.range) and self.Qspell and self.Q:IsReady() then
		--local CastPosition, HitChance, Position = vpred:GetLineCastPosition(unit, self.Q.delay, self.Q.width, self.Q.range, self.Q.speed, myHero, false)
		local Collision = CountObjectCollision(0, unit.Addr, myHero.x, myHero.z, unit.x, unit.z, self.Q.width, self.Q.range, 65)
  		if Collision == 0 and self.Spells[spellName] ~= nil then
	    	CastSpellToPos(unit.x, unit.z, _Q)
	    end
    end

	if spell and unit.IsEnemy then
        if self.listSpellInterrup[spell.Name] ~= nil then
			local vp_distance = VPGetLineCastPosition(unit.Addr, self.Q.delay, self.Q.speed)
			local targetPos = Vector(unit.x, unit.y, unit.z)
			local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
			if self.menu_Combo_Qinterrup and IsValidTarget(unit.Addr, self.Q.range) then
				if not GetCollision(unit.Addr, self.Q.width, self.Q.range, vp_distance) then
					CastSpellToPredictionPos(unit.Addr, _Q, vp_distance)
				end
			end
			if self.menu_Combo_Einterrup and IsValidTarget(unit.Addr, self.E.range) then
				CastSpellTarget(unit.Addr, _E)
			end
		end
	end
end

function Thresh:CountAlliesInRange(unit, range)
	return CountAllyChampAroundObject(unit, range)
end

function Thresh:CountEnemiesInRange(unit, range)
	return CountEnemyChampAroundObject(unit, range)
end

function Thresh:IsUnderAllyTurret(pos)
    GetAllUnitAroundAnObject(myHero.Addr, 2000)
	for k,v in pairs(pUnit) do
		if not IsDead(v) and IsTurret(v) and IsAlly(v) then
			local turretPos = Vector(GetPosX(v), GetPosY(v), GetPosZ(v))
			if GetDistance(turretPos,pos) < 915 then
				return true
			end
		end
	end
    return false
end

function Thresh:KillSteal()
	for i, heros in ipairs(GetEnemyHeroes()) do
		if heros ~= nil then
			local hero = GetAIHero(heros)
			local CastPosition, HitChance, Position = vpred:GetLineCastPosition(hero, self.Q.delay, self.Q.width, self.Q.range, self.Q.speed, myHero, false)
			if IsValidTarget(hero.Addr, self.R.range - 150) and CanCast(_R) and self.menu_Combo_Rks and GetDamage("R", hero) > GetHealthPoint(hero.Addr) then
				CastSpellTarget(myHero.Addr, _R)
			end

			if IsValidTarget(hero.Addr, self.Q.range - 150) and CanCast(_Q) and self.menu_Combo_Qks and GetDamage("Q", hero) > GetHealthPoint(hero.Addr) then				
				local distance = VPGetLineCastPosition(hero.Addr, self.Q.delay, self.Q.speed)
				if not GetCollision(target.Addr, self.Q.width, self.Q.range, distance, 1) then
					CastSpellToPos(CastPosition.x, CastPosition.z, _Q)
				end
			end

			if IsValidTarget(hero.Addr, self.E.range) and CanCast(_E) and self.menu_Combo_Eks and GetDamage("E", hero) > GetHealthPoint(hero.Addr) then
				pos = Vector(myHero):Extended(CastPosition, - self.E.range)
				CastSpellToPos(pos.x, pos.z, _E)
			end
		end
	end
end

function Thresh:Push(target)
	--target = t --or GetTargetSelector(self.E.range, 0)
	if(target ~= nil) then
		--hero = GetAIHero(target)
		CastSpellToPos(target.x,target.z, _E)
	end
end

function Thresh:Pull(target)
	--target = t --or GetTargetSelector(self.E.range, 0)
	if(target ~= nil) then
		local targetPos = Vector(target)
		local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
		--pos = Vector(myHeroPos) + (Vector(myHeroPos) - Vector(targetPos)):Normalized()*400
		pos = myHeroPos:Extended(targetPos, - self.E.range)
		CastSpellToPos(pos.x, pos.z, _E)
	end
end

function Thresh:GetUglyAlly(range)
    local result = nil
    local N = math.huge
    for i,hero in pairs(GetAllyHeroes()) do
	table.sort(GetAllyHeroes(), function(a, b) return GetDistance(a) < GetDistance(b) end)
        if hero~= 0 and not IsDead(hero) and IsAlly(hero) and GetDistance(hero) < range then
            local tokill = GetHealthPoint(hero)
            if tokill > N or result == nil then
                N = tokill
                result = hero
            end
        end
    end
    return result
end

function Thresh:CastW(pos) 
	if GetDistance(pos) < self.W.range then
		CastSpellToPos(pos.x, pos.z, _W)
	else
		pos1 = Vector(myHero):Extended(pos, self.W.range)
		CastSpellToPos(pos1.x, pos1.z, _W)
	end
end

function Thresh:autoW()

	local ally = self:GetUglyAlly(self.W.range + 500)
	local allyPos = Vector(GetPosX(ally), GetPosY(ally), GetPosZ(ally))
	local myHeroPos = Vector(GetPosX(myHero.Addr), GetPosY(myHero.Addr), GetPosZ(myHero.Addr))
	local posW1 = allyPos:Extended(myHeroPos, 300)
	local posW2 = myHeroPos:Extended(allyPos, self.W.range - 100)

	local TargetQ = GetTargetSelector(self.Q.range, 0)
	if TargetQ ~= 0 then
		target = GetAIHero(TargetQ)
		if self:Qstat(target) and CanCast(_W) then
			if GetDistance(allyPos) < self.W.range + 100 then
				CastSpellToPos(posW1.x, posW1.z, _W)
			else
				CastSpellToPos(posW2.x, posW2.z, _W)
			end
		end
	end
end

local function GetDistanceSqr(p1, p2)
    p2 = GetOrigin(p2) or GetOrigin(myHero)
    return (p1.x - p2.x) ^ 2 + ((p1.z or p1.y) - (p2.z or p2.y)) ^ 2
end

function Thresh:IsUnderTurretEnemy(pos)			--Will Only work near myHero
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

function Thresh:IsUnderAllyTurret(pos)
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

function Thresh:IsImmobileTarget(unit)
	if (CountBuffByType(unit, 5) == 1 or CountBuffByType(unit, 11) == 1 or CountBuffByType(unit, 29) == 1 or CountBuffByType(unit, 24) == 1 or CountBuffByType(unit, 10) == 1 or CountBuffByType(unit, 29) == 1) then
		return true
	end
	return false
end

function Thresh:aa()

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

	self.listEndDash =
	{
		{Name = "ZoeR", RangeMin = 570, Range = 570, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "MaokaiW", RangeMin = 0, Range = math.huge, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "CamilleE", RangeMin = 0, Range = math.huge, Type = 1, Duration = 1.25}, --MaokaiW
		--{Name = "BlindMonkQTwo", RangeMin = 0, Range = math.huge, Type = 1, Duration = 0.25}, --MaokaiW
		{Name = "BlindMonkWOne", RangeMin = 0, Range = math.huge, Type = 1, Duration = 0.25}, --MaokaiW
		{Name = "NocturneParanoia2", RangeMin = 0, Range = math.huge, Type = 1, Duration = 0.25}, --MaokaiW
		{Name = "XinZhaoE", RangeMin = 0, Range = 100, Type = 2, Duration = 0.25}, --CHUAN
		{Name = "PantheonW", RangeMin = 0, Range = 200, Type = 2, Duration = 0.25}, --CHUAN
		{Name = "AkaliShadowDance", RangeMin = 0, Range = - 100, Type = 2, Duration = 0.25}, --CHUAN
		{Name = "AkaliSmokeBomb", RangeMin = 0, Range = 250, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "Headbutt", RangeMin = 0, Range = math.huge, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "BraumW", RangeMin = 0, Range = - 140, Type = 2, Duration = 0.25}, --CHUAN
		{Name = "DianaTeleport", RangeMin = 0, Range = 80, Type = 2, Duration = 0.25}, --50% CHUAN
		{Name = "JaxLeapStrike", RangeMin = 0, Range = math.huge, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "MonkeyKingNimbus", RangeMin = 0, Range = math.huge, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "PoppyE", RangeMin = 0, Range = math.huge, Type = 1, Duration = 0.25}, --MaokaiW
		{Name = "IreliaGatotsu", RangeMin = 0, Range = math.huge, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "UFSlash", RangeMin = 0, Range = math.huge, Type = 1, Duration = 0.25}, --CHUAN MalphiteR
		{Name = "LucianE", RangeMin = 200, Range = 430, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "EzrealArcaneShift", RangeMin = 0, Range = 470, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "TristanaW", RangeMin = 0, Range = 900, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "SummonerFlash", RangeMin = 0, Range = 400, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "AhriTumble", RangeMin = 0, Range = 500, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "CarpetBomb", RangeMin = 300, Range = 600, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "FioraQ", RangeMin = 0, Range = 400, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "KindredQ", RangeMin = 0, Range = 300, Type = 1, Duration = 0.25}, --CHUAn
		{Name = "RiftWalk", RangeMin = 0, Range = 500, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "FizzETwo", RangeMin = 0, Range = 300, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "FizzE", RangeMin = 0, Range = 400, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "CamilleEDash2", RangeMin = 0, Range = 400, Type = 1, Duration = 0.25}, --50% CHUAN
		{Name = "AatroxQ", RangeMin = 0, Range = 650, Type = 1, Duration = 0.5}, --CHUAN
		{Name = "RakanW", RangeMin = 0, Range = 650, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "QuinnE", RangeMin = 0, Range = 600, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "JarvanIVDemacianStandard", RangeMin = 0, Range = 850, Type = 1, Duration = 0.25}, --Ezreal E
		{Name = "ShyvanaTransformLeap", RangeMin = 0, Range = 1000, Type = 1, Duration = 0.25}, --Ezreal E
		{Name = "ShenE", RangeMin = 300, Range = 600, Type = 1, Duration = 0.5}, --CHUAN
		{Name = "Deceive", RangeMin = 0, Range = 400, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "SejuaniQ", RangeMin = 0, Range = 650, Type = 1, Duration = 0.25}, --Ezreal E
		{Name = "KhazixE", RangeMin = 0, Range = 700, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "KhazixELong", RangeMin = 0, Range = 900, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "TryndamereE", RangeMin = 0, Range = 650, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "LeblancW", RangeMin = 0, Range = 600, Type = 1, Duration = 0.25}, --Ezreal E
		{Name = "GalioE", RangeMin = 0, Range = 625, Type = 1, Duration = 0.5}, --Ezreal E
		{Name = "ZacE", RangeMin = 0, Range = 1200, Type = 1, Duration = 1}, --Ezreal E
		--{Name = "ViQ", RangeMin = 0, Range = 720, Type = 1, Duration = 0.25}, --Ezreal E
		{Name = "EkkoEAttack", RangeMin = 0, Range = 150, Type = 2, Duration = 0.25}, --CHUAN
		{Name = "TalonQ", RangeMin = 0, Range = 120, Type = 2, Duration = 0.25}, --CHUAN
		{Name = "EkkoE", RangeMin = 350, Range = 350, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "FizzQ", RangeMin = 550, Range = 600, Type = 1, Duration = 0.25}, --50% CHUAN
		{Name = "GragasE", RangeMin = 700, Range = 600, Type = 1, Duration = 0.25}, --Ezreal E
		{Name = "GravesMove", RangeMin = 280, Range = 370, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "OrnnE", RangeMin = 650, Range = 650, Type = 1, Duration = 0.75}, --CHUAN
		{Name = "Pounce", RangeMin = 370, Range = 370, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "RivenFeint", RangeMin = 250, Range = 250, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "KaynQ", RangeMin = 350, Range = 350, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "RenektonSliceAndDice", RangeMin = 450, Range = 450, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "RenektonDice", RangeMin = 450, Range = 450, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "VayneTumble", RangeMin = 300, Range = 300, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "UrgotE", RangeMin = 470, Range = 470, Type = 3, Duration = 0.25}, --Ezreal E
		{Name = "JarvanIVDragonStrike", RangeMin = 850, Range = 850, Type = 1, Duration = 0.25}, --Ezreal E
		{Name = "WarwickR", RangeMin = 1000, Range = 1000, Type = 1, Duration = 1}, --CHUAN
		{Name = "YasuoDashWrapper", RangeMin = 480, Range = 480, Type = 1, Duration = 0.25}, --CHUAN
		{Name = "CaitlynEntrapment", RangeMin = -380, Range = -380, Type = 1, Duration = 0.25}, --CHUAN
	}
end


