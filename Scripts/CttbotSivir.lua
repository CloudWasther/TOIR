IncludeFile("Lib\\TOIR_SDK.lua")

Sivir = class()

function OnLoad()
	if GetChampName(GetMyChamp()) == "Sivir" then
		Sivir:__init()
	end
end

function Sivir:__init()
	-- VPrediction
	vpred = VPrediction(true)
	HPred = HPrediction()
	AntiGap = AntiGapcloser(nil)

	--TS
    --self.menu_ts = TargetSelector(1750, 0, myHero, true, true, true)


    self.Q = Spell(_Q, 1350)
    self.W = Spell(_W, GetTrueAttackRange())
    self.E = Spell(_E, GetTrueAttackRange())
    self.R = Spell(_R, GetTrueAttackRange())

    self.Q:SetSkillShot(0.25, 1400, 90, true)
    self.W:SetTargetted()
    self.E:SetTargetted()
    self.R:SetTargetted()

    self.AAspelss =
{
    ["UdyrBearAttack"] = {},
    ["RedCardPreAttack"] = {},
    ["BlueCardPreAttack"] = {},
    ["NautilusRavageStrikeAttack"] = {},
    ["PowerFist"] = {},
    ["LeonaShieldOfDaybreak"] = {},
}

    self.AAspelssBuffs =
{
    ["VolibearQ"] = {},
    ["goldcardpreattack"] = {},
    ["PowerFist"] = {},
    ["LeonaShieldOfDaybreak"] = {},
}

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

self.FAKER = {["AkaliMota"] = {delay = 0.1, ult = false, tricky = false},
["Headbutt"] = {delay = 0.1, ult = false, tricky = false},
["CaitlynAceintheHole"] = {delay = 1, ult = false, tricky = true},
["Feast"] = {delay = 0.1, ult = true, tricky = false},
["DariusExecute"] = {delay = 0.1, ult = true, tricky = true},
["VolibearW"] = {delay = 0.1, ult = false, tricky = false},
["GarenR"] = {delay = 0.1, ult = true, tricky = false},
["JudicatorReckoning"] = {delay = 0.1, ult = false, tricky = false},
["DianaTeleport"] = {delay = 0.1, ult = false, tricky = false},
["Terrify"] = {delay = 0, ult = false, tricky = true},
["FiddlesticksDarkWind"] = {delay = 0.1, ult = false, tricky = false},
["TristanaR"] = {delay = 0.1, ult = false, tricky = false},
["TristanaE"] = {delay = 0.1, ult = false, tricky = false},
["KhazixQ"] = {delay = 0.1, ult = false, tricky = false},
["LuluWTwo"] = {delay = 0.1, ult = false, tricky = true},
["khazixqlong"] = {delay = 0.1, ult = false, tricky = false},
["TwoShivPoison"] = {delay = 0.1, ult = false, tricky = false},
["BlindMonkRKick"] = {delay = 0.1, ult = false, tricky = true},
["AlZaharNetherGrasp"] = {delay = 0, ult = false, tricky = true},
["LissandraR"] = {delay = 0.1, ult = true, tricky = true},
["MaokaiUnstableGrowth"] = {delay = 0.1, ult = false, tricky = true},
["MordekaiserChildrenOfTheGrave"] = {delay = 0, ult = false, tricky = false},
["NasusW"] = {delay = 0.1, ult = false, tricky = false},
["NocturneUnspeakableHorror"] = {delay = 0, ult = false, tricky = false},
["IceBlast"] = {delay = 0.1, ult = false, tricky = false},
["OlafRecklessStrike"] = {delay = 0.1, ult = false, tricky = false},
["PantheonW"] = {delay = 0.1, ult = false, tricky = true},
["PuncturingTaunt"] = {delay = 0, ult = false, tricky = false},
["RyzeW"] = {delay = 0, ult = false, tricky = true},
["BrandWildfire"] = {delay = 0.1, ult = false, tricky = false},
["Fling"] = {delay = 0, ult = false, tricky = false},
["SkarnerImpale"] = {delay = 0.1, ult = false, tricky = true},
["IreliaEquilibriumStrike"] = {delay = 0.1, ult = false, tricky = true},
["JayceThunderingBlow"] = {delay = 0, ult = false, tricky = false},
["LeblancChaosOrb"] = {delay = 0.1, ult = false, tricky = true},
["LeblancChaosOrbM"] = {delay = 0.1, ult = false, tricky = false},
["tahmkenchw"] = {delay = 0.1, ult = false, tricky = false},
["SyndraR"] = {delay = 0.1, ult = false, tricky = false},
["Dazzle"] = {delay = 0.1, ult = false, tricky = false},
["BlindingDart"] = {delay = 0.1, ult = false, tricky = false},
["bluecardpreattack"] = {delay = 0.1, ult = false, tricky = false},
["redcardpreattack"] = {delay = 0.1, ult = false, tricky = false},
["VayneCondemn"] = {delay = 0.1, ult = false, tricky = true},
["VeigarPrimordialBurst"] = {delay = 0.1, ult = true, tricky = false},
["InfiniteDuress"] = {delay = 0, ult = false, tricky = false},
["zedult"] = {delay = 0.74, ult = true, tricky = false},
["Parley"] = {delay = 0.1, ult = false, tricky = false},
["KarthusFallenOne"] = {delay = 2.5, ult = false, tricky = true},
["Disintegrate"] = {delay = 0.1, ult = false, tricky = false},
["ViR"] = {delay = 0.1, ult = false, tricky = true}
}

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
	self.spellstart = nil
	self.spellend = nil
	self.MissileEndPos = nil
	self.Missile = nil
	self.ECasted = false
	self.ETimestamp = 0

	Callback.Add("Tick", function(...) self:OnTick(...) end)
	Callback.Add("Update", function(...) self:OnUpdate(...) end)	
    Callback.Add("Draw", function(...) self:OnDraw(...) end)
    Callback.Add("ProcessSpell", function(unit, spell) self:OnProcessSpell(unit, spell) end)
    --Callback.Add("BeforeAttack", function(...) self:OnBeforeAttack(...) end)
    --Callback.Add("NewPath", function(...) self:OnNewPath(...) end)
    Callback.Add("CreateObject", function(...) self:OnCreateObject(...) end)
    Callback.Add("DeleteObject", function(...) self:OnDeleteObject(...) end)
    Callback.Add("AntiGapClose", function(target, EndPos) self:OnAntiGapClose(target, EndPos) end)
    Callback.Add("AfterAttack", function(...) self:OnAfterAttack(...) end)
    Callback.Add("DrawMenu", function(...) self:OnDrawMenu(...) end)
    self:MenuValueDefault()
end

function Sivir:MenuValueDefault()
	self.menu = "Sivir_Magic"
	self.Draw_When_Already = self:MenuBool("Draw When Already", false)
	self.menu_Draw_Q = self:MenuBool("Draw Q Range", false)

	self.qcb = self:MenuBool("Auto Q Combo)", true)
	self.farmQ = self:MenuBool("Lane clear Q", true)
	self.aim = self:MenuBool("Auto aim returned missile", true)

	self.harassW = self:MenuBool("Harass W", true)
	self.farmW = self:MenuBool("Lane clear W", true)
	for i, enemy in pairs(GetEnemyHeroes()) do
        table.insert(self.ts_prio, { Enemy = GetAIHero(enemy), Menu = self:MenuBool(GetAIHero(enemy).CharName, true)})
    end

	self.autoE = self:MenuBool("Auto E", true)
	self.autoEmissile = self:MenuBool("Block unknown missile", true)
	self.AGC = self:MenuBool("AntiGapcloser E", true)
	self.Edmg = self:MenuSliderInt("Block under % hp", 50)
	self.blockmove = self:MenuBool("Spell Shield Block Movement", false)
	--self.blockduration = self:MenuSliderInt("Spell Shield Block Duration ms", 300)

	self.autoR = self:MenuBool("Auto R", true)

	self.Enalble_Mod_Skin = self:MenuBool("Enalble Mod Skin", false)
	self.Set_Skin = self:MenuSliderInt("Set Skin", 5)

	self.Combo = self:MenuKeyBinding("Combo", 32)
	self.Harass = self:MenuKeyBinding("Harass", 67)
	self.Lane_Clear = self:MenuKeyBinding("Lane Clear", 86)
	self.Last_Hit = self:MenuKeyBinding("Last Hit", 88)
end

function Sivir:OnDrawMenu()
	if Menu_Begin(self.menu) then
		if Menu_Begin("Q Setting") then
			self.qcb = Menu_Bool("Auto Q Combo", self.qcb, self.menu)	
			self.farmQ = Menu_Bool("Lane clear Q", self.farmQ, self.menu)	
			self.aim = Menu_Bool("Auto aim returned missile", self.aim, self.menu)
			Menu_End()
		end

		if Menu_Begin("W Setting") then
			self.harassW = Menu_Bool("Harass W", self.harassW, self.menu)
			self.farmW = Menu_Bool("Lane clear W", self.farmW, self.menu)
			Menu_Text("Harass Enemy")
			for i, enemy in pairs(GetEnemyHeroes()) do
            	self.ts_prio[i].Menu = Menu_Bool(GetAIHero(enemy).CharName, self.ts_prio[i].Menu, self.menu)
        	end	
			Menu_End()
		end

		if Menu_Begin("E Setting") then
			self.autoE = Menu_Bool("Auto E", self.autoE, self.menu)	
			self.autoEmissile = Menu_Bool("Block unknown missile", self.autoEmissile, self.menu)
			self.AGC = Menu_Bool("AntiGapcloser E", self.AGC, self.menu)	
			self.Edmg = Menu_SliderInt("Block under % hp", self.Edmg, 0, 100, self.menu)
			self.blockmove = Menu_Bool("Spell Shield Block Movement", self.blockmove, self.menu)	
			--self.blockduration = Menu_SliderInt("Spell Shield Block Duration ms", self.blockduration, 50, 500, self.menu)
			Menu_End()
		end

		if Menu_Begin("R Setting") then
			self.autoR = Menu_Bool("Auto R", self.autoR, self.menu)	
			Menu_End()
		end

		if Menu_Begin("Draw Spell") then
			self.menu_Draw_Q = Menu_Bool("Draw Q Range", self.menu_Draw_Q, self.menu)
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

function Sivir:MenuBool(stringKey, bool)
	return ReadIniBoolean(self.menu, stringKey, bool)
end

function Sivir:MenuSliderInt(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Sivir:MenuSliderFloat(stringKey, valueDefault)
	return ReadIniFloat(self.menu, stringKey, valueDefault)
end

function Sivir:MenuComboBox(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Sivir:MenuKeyBinding(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Sivir:OnAntiGapClose(target, EndPos)
	hero = GetAIHero(target.Addr)
    if GetDistance(EndPos) < 500 or GetDistance(hero) < 500 then
    	if self.AGC then
    		CastSpellTarget(myHero.Addr, _E)
    	end
    end
end

function Sivir:OnCreateObject(obj)
	missile = GetMissile(obj)
	if missile ~= nil and missile.TeamId == myHero.TeamId then
		if missile.Name == "SivirQMissile" or missile.Name == "SivirQMissileReturn" then
			self.Missile = missile
		end
	end

	if missile ~= nil and self.autoEmissile then
		--__PrintTextGame(tostring(GetTargetById(missile.OwnerId)))
		for i,hero in pairs(GetEnemyHeroes()) do
			if IsValidTarget(hero, 2000) then
				target = GetAIHero(hero)
				--__PrintTextGame(tostring(target.Id).."--"..tostring(GetTargetById(missile.OwnerId)))
			end
		end
		if not self:IsAutoAttack(missile.Name) and GetTargetById(missile.OwnerId) == myHero.Addr and IsEnemy(missile.Addr) and IsChampion(missile.Addr) then
			CastSpellTarget(myHero.Addr, _E)
		end
	end
end

function Sivir:OnDeleteObject(obj)
	missile = GetMissile(obj)
	if missile ~= nil and missile.TeamId == myHero.TeamId then
		if missile.Name == "SivirQMissile" or missile.Name == "SivirQMissileReturn" then
			self.Missile = nil
		end
	end
end

function Sivir:CalculateReturnPos(target)
	if self.Missile ~= nil and IsValidTarget(target.Addr, self.Q.range) then
		local finishPosition = Vector(self.Missile)	
		if self.Missile.Name == "SivirQMissile" then
			finishPosition = self.MissileEndPos;
		end
		if finishPosition ~= nil then
			local misToPlayer = GetDistance(finishPosition)
			local tarToPlayer = GetDistance(target)
			if misToPlayer > tarToPlayer then
				local misToTarget = GetDistance(finishPosition, target)
				if misToTarget < self.Q.range and misToTarget > 50 then
					local cursorToTarget = GetDistance(target, Vector(myHero):Extended(GetMousePos(), 100))
					local ext = finishPosition:Extended(target, cursorToTarget + misToTarget)
					if GetDistance(ext) < 800 and self:CountEnemiesInRange(ext, 400) < 2 then
						return ext
					end
				end
			end
		end
	end
	return nil
end

function Sivir:IsAutoAttack(spell)
    return (string.find(string.lower(spell), "attack") ~= nil and not self.NotAttackSpell[string.lower(spell)]) or self.SpellAttack[string.lower(spell)]
end

function Sivir:OnProcessSpell(unit, spell)
	if unit.IsMe then
		if spell.Name == "SivirE" then
			if not self.ECasted and self.blockmove then
				self.ECasted = true
				self.ETimestamp = GetTimeGame()
				BlockMove()
			end
		end
	end
	if not CanCast(_E) or unit.Type ~= 0 or not unit.IsEnemy or myHero.HP / myHero.MaxHP * 100 > self.Edmg or not self.autoE or string.lower(spell.Name) == "tormentedsoil" then
		return
	end

	if spell ~= nil and spell.TargetId ~= nil and unit ~= nil then
		if self.FAKER[spell.Name] and GetTargetById(spell.TargetId) == myHero.Addr and self.autoE then
			--__PrintTextGame(tostring(self.FAKER[spell.Name]).."--"..tostring(myHero.Addr).."--"..tostring(spell.Name).."--"..tostring(self.FAKER[spell.Name].delay))
			DelayAction(function() CastSpellTarget(myHero.Addr, _E) end, self.FAKER[spell.Name].delay) 
		end
	end

	if GetTargetById(spell.TargetId) ~= nil and self:IsAutoAttack(spell.Name) and GetTargetById(spell.TargetId) == myHero.Addr then
		if self.AAspelss[(spell.Name)] then
			CastSpellTarget(myHero.Addr, _E)
		end
		target = GetAIHero(unit.Addr)
		if target.HasBuff("PowerFist") or target.HasBuff("LeonaShieldOfDaybreak") or target.HasBuff("VolibearQ") or target.HasBuff("GoldCardPreAttack") then
			CastSpellTarget(myHero.Addr, _E)
		end
	end

	self.MissileEndPos = Vector(myHero):Extended(Vector(spell.DestPos_x, spell.DestPos_y, spell.DestPos_z), self.Q.range - 200)

	if unit.IsEnemy then
		if GetChampName(GetTargetById(spell.TargetId)) == "NULL" then
			if self:CanHitSkillShot(myHero, Vector(spell.SourcePos_x, spell.SourcePos_y, spell.SourcePos_z), Vector(spell.DestPos_x, spell.DestPos_y, spell.DestPos_z), spell.Width) then
				CastSpellTarget(myHero.Addr, _E)
			else
				if self:CanHitSkillShot(myHero, Vector(spell.SourcePos_x, spell.SourcePos_y, spell.SourcePos_z), Vector(spell.CursorPos_x, spell.CursorPos_y, spell.CursorPos_z), spell.Width) then
					CastSpellTarget(myHero.Addr, _E)
				end
			end
		end
	end	
end

function Sivir:ProjectOn(point, segmentStart, segmentEnd)
	local cx = point.x;
    local cy = point.z;
    local ax = segmentStart.x;
    local ay = segmentStart.z;
    local bx = segmentEnd.x;
    local by = segmentEnd.z;
    local rL = ((cx - ax) * (bx - ax) + (cy - ay) * (by - ay)) / (math.pow(bx - ax, 2) + math.pow(by - ay, 2));
    local pointLine = Vector(ax + rL * (bx - ax), 0, ay + rL * (by - ay))
    if (rL < 0) then
        rS = 0;
    elseif (rL > 1) then
        rS = 1;
    else
        rS = rL;
    end
    if rS == rL then
    	isOnSegment = true
    	pointSegment = pointLine
    else
    	isOnSegment = false
    	pointSegment = Vector(ax + rS * (bx - ax), 0, ay + rS * (by - ay))
    end
    return isOnSegment, pointSegment
end

local function GetDistanceSqr(p1, p2)
    p2 = GetOrigin(p2) or GetOrigin(myHero)
    return (p1.x - p2.x) ^ 2 + ((p1.z or p1.y) - (p2.z or p2.y)) ^ 2
end

function Sivir:Distance(point, segmentStart, segmentEnd, onlyIfOnSegment, squared)
	local isOnSegment, pointSegment = self:ProjectOn(point, segmentStart, segmentEnd)
	if isOnSegment or onlyIfOnSegment == false then
		if squared then
			return GetDistanceSqr(pointSegment, point)
		else
			return GetDistance(pointSegment, point)
		end
	end
	return math.huge
end

function Sivir:CanHitSkillShot(target, Start, End, Width)
	if IsValidTarget(target.Addr, 2000) then
		if GetDistance(target, Start) > 1600 then
			return false
		end
		if Width > 0 then
			local powCalc = math.pow(Width + GetBoundingRadius(target.Addr), 2)
			if self:Distance(target, End, Start, true, true) <= powCalc then
				return true
			end
		elseif GetDistance(target, End) < 50 + GetBoundingRadius(target.Addr) then
			return true			
		end
	end
	return false
end

function Sivir:IsAutoAttack(spell)
    --return spell:find("attack") or spell:find("attack") or self.AttacksTbl[spell]
    return (string.find(string.lower(spell), "attack") ~= nil and not self.NotAttackSpell[string.lower(spell)]) or self.SpellAttack[string.lower(spell)]
end

function Sivir:OnAfterAttack(unit, target)
	if unit.IsMe then
		if target ~= nil and target.Type == 0 and CanCast(_W) then
    		if GetAADamageHitEnemy(target.Addr) * 3 > GetHealthPoint(target.Addr) then
    			CastSpellTarget(myHero.Addr, _W)
    		end

    		if GetKeyPress(self.Combo) > 0 and myHero.MP > 160 then
    			CastSpellTarget(myHero.Addr, _W)
    		elseif self.harassW and not self.IsUnderTurretEnemy(myHero) and myHero.MP > 220 then
    			--for i, heros in ipairs(GetEnemyHeroes()) do
					--if heros ~= nil then			
			    		if self.ts_prio[i].Menu then	    			    	
			    			if IsValidTarget(target.Addr, self.Q.range - 150) then
			    				if target.NetworkId == self.ts_prio[i].Enemy.NetworkId and self:CanHarras() then	
			    					CastSpellTarget(myHero.Addr, _W)
			    				end
			    			end
			    		end
			    	--end		    						
				--end			
    		end
    	end
    	if target ~= nil and target.Type == 1 and CanCast(_W) and self.farmW then
    		if GetEnemyMinionAroundObject(target.Addr, 500) > 4 and not self.IsUnderTurretEnemy(myHero) and CountEnemyChampAroundObject(target.Addr, 300) > 0 then
    			if GetKeyPress(self.Lane_Clear) > 0 then
    				CastSpellTarget(myHero.Addr, _W)
    			end
    		end
    	end
	end
end


function Sivir:OnTick()
	if (IsDead(myHero.Addr) or myHero.IsRecall or IsTyping() or IsDodging()) then return end
	SetLuaCombo(true)

	self.HPred_Q_M = HPSkillshot({type = "DelayLine", delay = self.Q.delay, range = self.Q.range, speed = self.Q.speed, width = self.Q.width})

	--__PrintTextGame(tostring(myHero.HasBuff("GoldCardPreAttack")))
	--self:CatchAxe()
	--local stack = GetBuff(GetBuffByName(myHero.Addr, "SivirSpinningAttack"))
	--__PrintTextGame(tostring(self:QCount()))

	--[[GetAllBuffNameActive(myHero.Addr)
		for i,v in pairs(pBuffName) do
		__PrintDebug(tostring(v))				      
	end]]
	--self:AntiGapCloser()

	if CanCast(_Q) then
		self:LogicQ()
	end

	if CanCast(_R) and self.autoR then
		self:LogicR()
	end
	--__PrintTextGame(tostring(GetName_Casting(GetSpellCasting(myHero.Addr))))
		

	if self.Enalble_Mod_Skin then
		ModSkin(self.Set_Skin)
	end		
end

function Sivir:OnUpdate()
	local TargetQ = GetTargetSelector(self.Q.range, 1)
	if TargetQ ~= 0 and self.aim then
		target = GetAIHero(TargetQ)	
		local aa = self:CalculateReturnPos(target)
		--__PrintTextGame(tostring(aa))
		if aa ~= nil then
			if GetKeyPress(self.Combo) > 0 then
				SetOrbwalkingPoint(aa.x, aa.z)
			else
				MoveToPos(aa.x, aa.z)
			end
		else
			SetOrbwalkingPoint(0, 0)
		end
	else
		SetOrbwalkingPoint(0, 0)
	end

	if self.ECasted and GetTimeGame() - self.ETimestamp > 0.25 then
		if not myHero.HasBuff("SivirE") then
			self.ECasted = false;
			UnBlockMove()
		end
		
	end
end

function Sivir:LogicQ()
	local TargetQ = GetTargetSelector(self.Q.range - 100, 1)
	--__PrintTextGame(tostring(TargetQ))
	if TargetQ ~= 0 then
		target = GetAIHero(TargetQ)
		local QPos, QHitChance = HPred:GetPredict(self.HPred_Q_M, target, myHero)
		local qDmg = GetDamage("Q", target)
		if GetDistance(target) < GetTrueAttackRange() then
			qDmg = qDmg + GetAADamageHitEnemy(target.Addr) * 3
		end
		if qDmg > target.HP then
			if QHitChance >= 2 then
				CastSpellToPos(QPos.x, QPos.z, _Q)
			end
		elseif GetKeyPress(self.Combo) > 0 and myHero.MP > 170 then
			--UnBlockMove()
			if QHitChance >= 2 then
				CastSpellToPos(QPos.x, QPos.z, _Q)
			end
		else
			for i, heros in ipairs(GetEnemyHeroes()) do
				if heros ~= nil then
					local target = GetAIHero(heros)				
			    	if self.ts_prio[i].Menu then	    			    	
			    		if IsValidTarget(target.Addr, self.Q.range - 150) then
			    			if target.NetworkId == self.ts_prio[i].Enemy.NetworkId and self:CanHarras() then	
			    				local QPos, QHitChance = HPred:GetPredict(self.HPred_Q_M, target, myHero)
			    				if QHitChance >= 2 and not self.IsUnderTurretEnemy(myHero) then
									CastSpellToPos(QPos.x, QPos.z, _Q)
								end
			    			end
			    		end
			    	end
			    	if not self:CanMove(target) and IsValidTarget(target.Addr, self.Q.range - 100) then
				       	--CastSpellToPos(target.x, target.z, _Q)
					end
					local TargetDashing, CanHitDashing, DashPosition = vpred:IsDashing(target, self.Q.delay, self.Q.width, self.Q.speed, myHero)
					if DashPosition ~= nil then
				    	if GetDistance(DashPosition) <= self.Q.range then
				    		CastSpellToPos(DashPosition.x, DashPosition.z, _Q)
				    	end
					end	
			   	end		    						
			end
		end
	end
end

function Sivir:LogicR()
	local TargetR = GetTargetSelector(800, 1)
	if TargetR ~= 0 then
		target = GetAIHero(TargetR)
		if CountEnemyChampAroundObject(myHero.Addr, 800) > 3 then
			CastSpellTarget(myHero.Addr, _R)
		elseif GetTargetOrb() == nil and GetKeyPress(self.Combo) > 0 and GetAADamageHitEnemy(target.Addr) * 2 > target.HP and not CanCast(_Q) and CountEnemyChampAroundObject(target.Addr, 800) < 3 then
			CastSpellTarget(myHero.Addr, _R)
		end
	end
end

function Sivir:GetBestLineFarmLocation(minionPositions, width, range)
	local result = {}
	local minionCount = 0
	local startPos = Vector(myHero)
	local posiblePositions = {}
	merge(posiblePositions, minionPositions)
end

local function merge(t1, t2)
    for k, v in pairs(t2) do
        if (type(v) == "table") and (type(t1[k] or false) == "table") then
            merge(t1[k], t2[k])
        else
            t1[k] = v
        end
    end
    return t1
end

function Sivir:CanMoveOrb(extraWindup)
    return GetTimeGame() + self:GamePing() > GetLastBATick() + GetWindupBA(myHero.Addr) + extraWindup --self.menu_advanced_delayWindup.getValue() /1000
end

function Sivir:CanHarras()
	local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
	if not self:IsUnderTurretEnemy(myHeroPos) then
		return true
	end
	return false
end

function Sivir:ValidUlt(unit)
	if CountBuffByType(unit.Addr, 16) == 1 or CountBuffByType(unit.Addr, 15) == 1 or CountBuffByType(unit.Addr, 17) == 1 or unit.HasBuff("kindredrnodeathbuff") or CountBuffByType(unit.Addr, 4) == 1 then
		return false
	end
	return true
end

function Sivir:OnDraw()
	if self.menu_Draw_Already then
		if self.menu_Draw_Q and self.Q:IsReady() then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.Q.range, Lua_ARGB(255,255,0,0))
		end
	else
		if self.menu_Draw_Q then
			DrawCircleGame(myHero.x , myHero.y, myHero.z, self.Q.range, Lua_ARGB(255,255,0,0))
		end
	end

	--[[local TargetQ = GetTargetSelector(self.Q.range, 1)
	if TargetQ ~= 0 and self.aim then
		target = GetAIHero(TargetQ)	
		local aa = self:CalculateReturnPos(target)
		if aa ~= nil then
			DrawCircleGame(aa.x , aa.y, aa.z, 100, Lua_ARGB(255,255,0,0))
		end
	end]]
end

function Sivir:IsImmobileTarget(unit)
	if (CountBuffByType(unit, 5) == 1 or CountBuffByType(unit, 11) == 1 or CountBuffByType(unit, 29) == 1 or CountBuffByType(unit, 24) == 1 or CountBuffByType(unit, 10) == 1 or CountBuffByType(unit, 29) == 1) then
		return true
	end
	return false
end

function Sivir:CanMove(unit)
	if (unit.MoveSpeed < 50 or CountBuffByType(unit.Addr, 5) == 1 or CountBuffByType(unit.Addr, 21) == 1 or CountBuffByType(unit.Addr, 11) == 1 or CountBuffByType(unit.Addr, 29) == 1 or
		unit.HasBuff("recall") or CountBuffByType(unit.Addr, 30) == 1 or CountBuffByType(unit.Addr, 22) == 1 or CountBuffByType(unit.Addr, 8) == 1 or CountBuffByType(unit.Addr, 24) == 1
		or CountBuffByType(unit.Addr, 20) == 1 or CountBuffByType(unit.Addr, 18) == 1) then
		return false
	end
	return true
end

function Sivir:CheckWalls(enemyPos)
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

function Sivir:IsUnderTurretEnemy(pos)			--Will Only work near myHero
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

function Sivir:IsUnderAllyTurret(pos)
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

function Sivir:CountEnemiesInRange(pos, range)
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

function Sivir:CountAlliesInRange(pos, range)
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

