IncludeFile("Lib\\TOIR_SDK.lua")

Smite = class()

function OnLoad()
	Smite:__init()
end

function Smite:__init()

	Callback.Add("Tick", function(...) self:OnTick(...) end)
    Callback.Add("BeforeAttack", function(...) self:OnBeforeAttack(...) end)
    Callback.Add("DrawMenu", function(...) self:OnDrawMenu(...) end)
    self:MenuValueDefault()
end

function Smite:MenuValueDefault()
	self.menu = "Smite_Magic"

	self.Use_Smite_Kill_Steal = self:MenuBool("Use Smite Kill Steal", true)
	self.Use_Smite_in_Combo = self:MenuBool("Use Smite in Combo", true)
	self.Use_Smite_Small_Jungle = self:MenuBool("Use Smite Small Jungle", true)
	self.Use_Smite_Blue = self:MenuBool("Use Smite Blue", true)
	self.Use_Smite_Red = self:MenuBool("Use Smite Red", true)
	self.Use_Smite_Dragon = self:MenuBool("Use Smite Dragon", true)
	self.Use_Smite_Baron = self:MenuBool("Use Smite Baron", true)

	self.Combo = self:MenuKeyBinding("Combo", 32)
	self.Harass = self:MenuKeyBinding("Harass", 67)
	self.Lane_Clear = self:MenuKeyBinding("Lane Clear", 86)
	self.Last_Hit = self:MenuKeyBinding("Last Hit", 88)
end

function Smite:OnDrawMenu()
	if Menu_Begin(self.menu) then
		
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

function Smite:MenuBool(stringKey, bool)
	return ReadIniBoolean(self.menu, stringKey, bool)
end

function Smite:MenuSliderInt(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Smite:MenuSliderFloat(stringKey, valueDefault)
	return ReadIniFloat(self.menu, stringKey, valueDefault)
end

function Smite:MenuComboBox(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end

function Smite:MenuKeyBinding(stringKey, valueDefault)
	return ReadIniInteger(self.menu, stringKey, valueDefault)
end


function Smite:OnTick()
	if IsDead(myHero.Addr) then return end

	self:LogicSmiteJungle()
end

function Smite:GetIndexSmite()
	if GetSpellIndexByName("SummonerSmite") > -1 then
		return GetSpellIndexByName("SummonerSmite")
	elseif GetSpellIndexByName("S5_SummonerSmiteDuel") > -1 then
		return GetSpellIndexByName("S5_SummonerSmiteDuel")
	elseif GetSpellIndexByName("S5_SummonerSmitePlayerGanker") > -1 then
		return GetSpellIndexByName("S5_SummonerSmitePlayerGanker")
	end
	return -1
end

function Smite:GetSmiteDamage(target)
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

function Smite:LogicSmiteJungle()
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

    local TargetSmite = GetTargetSelector(650, 1)
	if TargetSmite ~= nil and IsValidTarget(TargetSmite, 650) and CanCast(self:GetIndexSmite()) and self.Use_Smite_Kill_Steal then
		if self:GetSmiteDamage(TargetSmite) > GetHealthPoint(TargetSmite) then
			CastSpellTarget(TargetSmite, self:GetIndexSmite())
		end
	end
end

function Smite:OnBeforeAttack(target)
    if target ~= nil and target.Type == 0 then
		if self:GetIndexSmite() > -1 and self.Use_Smite_in_Combo and GetKeyPress(self.Combo) > 0 then
			CastSpellTarget(target.Addr, self:GetIndexSmite())
		end
    end
end

function Smite:JungleTbl()
    GetAllUnitAroundAnObject(myHero.Addr, 2000)
    local result = {}
    for i, minions in pairs(pUnit) do
        if minions ~= 0 and not IsDead(minions) and not IsInFog(minions) and GetType(minions) == 3 then
            table.insert(result, minions)
        end
    end

    return result
end