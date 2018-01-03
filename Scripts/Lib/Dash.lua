IncludeFile("Lib\\TOIR_SDK.lua")

local function GetDistanceSqr(Pos1, Pos2)
  local Pos2 = Pos2 or Vector(myHero)
  --local P2 = GetOrigin(P2) or GetOrigin(myHero)
  --local P1 = GetOrigin(P1)
  local dx = Pos1.x - Pos2.x
  local dz = (Pos1.z or Pos1.y) - (Pos2.z or Pos2.y)
  return dx * dx + dz * dz
end

local function IsUnderAllyEnemy(pos)			--Will Only work near myHero
	GetAllUnitAroundAnObject(myHero.Addr, 2000)
	local objects = pUnit
	for k,v in pairs(objects) do
		if IsTurret(v) and IsDead(v) == false and IsEnemy(v) and GetTargetableToTeam(v) == 4 then
			local turretPos = Vector(GetPosX(v), GetPosY(v), GetPosZ(v))
			if GetDistanceSqr(turretPos,pos) < 915*915 then
				return true
			end
		end
	end
	return false
end

local function CountObjectsNearPos(pos, range)
    local n = 0
    GetAllUnitAroundAnObject(myHero.Addr, 2000)
    for i, object in ipairs(pUnit) do
        --local r = radius --+ object.boundingRadius
        if _GetDistanceSqr(pos, object) <= math.pow(range, 2) then
            n = n + 1
        end
    end

    return n
end

local DashSpell
function IsGoodPosition(dashPos)
	local segment = DashSpell.range / 5;
	local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
	for i = 1, 5, 1 do   
		pos = IsWall(myHeroPos:Extended(dashPos, i * segment))
		if IsWall(pos.x, pos.y, pos.z) then
			return false
		end
	end

	if IsUnderAllyEnemy(dashPos) then
		return false
	end

	local enemyCheck = Config.Item("EnemyCheck", true).GetValue<Slider>().Value;
    local enemyCountDashPos = CountObjectsNearPos(dashPos, 600);
    if enemyCheck > enemyCountDashPos then
    	return true
    end
    local enemyCountPlayer = CountEnemyChampAroundObject(myHero.Addr, 400)
    if enemyCountDashPos <= enemyCountPlayer then
    	return true
    end

    return false
end

