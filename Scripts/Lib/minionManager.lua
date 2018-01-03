---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- minionManager
--[[
        minionManager Class :
    Methods:
        minionArray = minionManager(mode, range, fromPos, sortMode)     --return a minionArray instance
    Functions :
        minionArray:update()                -- update the minionArray instance
    Members:
        minionArray.objects                 -- minionArray objects table
        minionArray.iCount                  -- minionArray objects count
        minionArray.mode                    -- minionArray instance mode (MINION_ALL, etc)
        minionArray.range                   -- minionArray instance range
        minionArray.fromPos                 -- minionArray instance x, z from which the range is based (player by default)
        minionArray.sortMode                -- minionArray instance sort mode (MINION_SORT_HEALTH_ASC, etc... or nil if no sorted)
    Usage ex:
        function OnLoad()
            enemyMinions = minionManager(MINION_ENEMY, 600, player, MINION_SORT_HEALTH_ASC)
            allyMinions = minionManager(MINION_ALLY, 300, player, MINION_SORT_HEALTH_DES)
        end
        function OnTick()
            enemyMinions:update()
            allyMinions:update()
            for index, minion in pairs(enemyMinions.objects) do
                -- what you want
            end
            -- ex changing range
            enemyMinions.range = 250
            enemyMinions:update() --not needed
        end
]]
player = GetMyHero()
myHero = player
local _minionTable = { {}, {}, {}, {}, {} }
local _minionManager = { init = true, tick = 0, ally = "##", enemy = "##" }

local function GetDistanceSqr(Pos1, Pos2)
  local Pos2 = Pos2 or Vector(myHero)
  --local P2 = GetOrigin(P2) or GetOrigin(myHero)
  --local P1 = GetOrigin(P1)
  local dx = Pos1.x - Pos2.x
  local dz = (Pos1.z or Pos1.y) - (Pos2.z or Pos2.y)
  return dx * dx + dz * dz
end

-- Class related constants
MINION_ALL = 1
MINION_ENEMY = 2
MINION_ALLY = 3
MINION_JUNGLE = 4
MINION_OTHER = 5
MINION_SORT_HEALTH_ASC = function(a, b) return a.health < b.health end
MINION_SORT_HEALTH_DEC = function(a, b) return a.health > b.health end
MINION_SORT_MAXHEALTH_ASC = function(a, b) return a.maxHealth < b.maxHealth end
MINION_SORT_MAXHEALTH_DEC = function(a, b) return a.maxHealth > b.maxHealth end
MINION_SORT_AD_ASC = function(a, b) return a.ad < b.ad end
MINION_SORT_AD_DEC = function(a, b) return a.ad > b.ad end
local __minionManager__OnCreateObj
local function minionManager__OnLoad()
    if _minionManager.init then
        local mapIndex = 15 --GetGame().map.index
        if mapIndex ~= 4 then
            --_minionManager.ally = "Minion_T" .. player.TeamId
            --_minionManager.enemy = "Minion_T" .. TEAM_ENEMY
        --else
            --_minionManager.ally = (player.team == TEAM_BLUE and "Blue" or "Red")
            --_minionManager.enemy = (player.team == TEAM_BLUE and "Red" or "Blue")
        end
        if not __minionManager__OnCreateObj then
            function __minionManager__OnCreateObj(object)
                if object and object.IsValid and object.Type == 1 then
                    DelayAction(function(object)
                        if object and object.IsValid and object.Type == 1 and object.Name and not object.IsDead then
                            local name = object.Name
                            table.insert(_minionTable[MINION_ALL], object)
                            if name:sub(1, #_minionManager.ally) == _minionManager.ally then table.insert(_minionTable[MINION_ALLY], object)
                            elseif name:sub(1, #_minionManager.enemy) == _minionManager.enemy then table.insert(_minionTable[MINION_ENEMY], object)
                            elseif object.TeamId == 300 then table.insert(_minionTable[MINION_JUNGLE], object)
                            else table.insert(_minionTable[MINION_OTHER], object)
                            end
                        end
                    end, 0, { object })
                end
            end
            AddCreateObjCallback(__minionManager__OnCreateObj)
        end

        for i = 1, objManager.maxObjects do
            __minionManager__OnCreateObj(objManager:getObject(i))
        end
        _minionManager.init = nil
    end
end

minionManager = class()
function minionManager:__init(mode, range, fromPos, sortMode)
    assert(type(mode) == "number" and type(range) == "number", "minionManager: wrong argument types (<mode>, <number> expected)")
    minionManager__OnLoad()
    self.mode = mode
    self.range = range
    self.fromPos = fromPos or player
    self.sortMode = type(sortMode) == "function" and sortMode
    self.objects = {}
    self.iCount = 0
    self:update()
end

function minionManager:update()
    self.objects = {}
    for _, object in pairs(_minionTable[self.mode]) do
        if object and object.IsValid and not object.IsDead and object.IsVisible and GetDistanceSqr(self.fromPos, object) <= (self.range) ^ 2 then
            table.insert(self.objects, object)
        end
    end
    if self.sortMode then table.sort(self.objects, self.sortMode) end
    self.iCount = #self.objects
end
