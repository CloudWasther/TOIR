IncludeFile("Lib\\TOIR_SDK.lua")
ChallengerAntiGapcloser = class()

function ChallengerAntiGapcloser:__init(menu, func)
  self.callbacks = {}
  self.activespells = {}
  self.spells = {
    ["AatroxQ"]                        = {Name = "Aatrox",       spellname = "Q | Dark Flight"},
    ["AhriTumble"]                     = {Name = "Ahri",         spellname = "R | Spirit Rush"},
    ["AkaliShadowDance"]               = {Name = "Akali",        spellname = "R | Shadow Dance"},
    ["AlphaStrike"]                    = {Name = "MasterYi",     spellname = "Q | Alpha Strike"},
    ["BandageToss"]                    = {Name = "Amumu",        spellname = "Q | Bandage Toss"},
    ["Crowstorm"]                      = {Name = "FiddleSticks", spellname = "R | Crowstorm "},
    ["DianaTeleport"]                  = {Name = "Diana",        spellname = "R | Lunar Rush"},
    ["EliseSpiderEDescent"]            = {Name = "Elise",        spellname = "E | Rappel"},
    ["EliseSpiderQCast"]               = {Name = "Elise",        spellname = "Q | Venomous Bite"},
    ["FioraQ"]                         = {Name = "Fiora",        spellname = "Q | Lunge"},
    ["FizzPiercingStrike"]             = {Name = "Fizz",         spellname = "E | Urchin Strike"},
    ["GarenQ"]                         = {Name = "Garen",        spellname = "Q | Decisive Strike"},
    ["GnarBigE"]                       = {Name = "Gnar",         spellname = "E | Crunch"},
    ["GnarE"]                          = {Name = "Gnar",         spellname = "E | Hop"},
    ["GragasE"]                        = {Name = "Gragas",       spellname = "E | Body Slam"},
    ["GravesMove"]                     = {Name = "Graves",       spellname = "E | Quickdraw"},
    ["Headbutt"]                       = {Name = "Alistar",      spellname = "W | Headbutt"},
    ["HecarimUlt"]                     = {Name = "Hecarim",      spellname = "R | Onslaught of Shadows"},
    ["IreliaGatotsu"]                  = {Name = "Irelia",       spellname = "Q | Bladesurge"},
    ["JarvanIVCataclysm"]              = {Name = "JarvanIV",     spellname = "R | Cataclysm"},
    ["JarvanIVDragonStrike"]           = {Name = "JarvanIV",     spellname = "Q | Dragon Strike"},
    ["JaxLeapStrike"]                  = {Name = "Jax",          spellname = "Q | Leap Strike"},
    ["JayceToTheSkies"]                = {Name = "Jayce",        spellname = "W | To The Skies!"},
    ["KatarinaE"]                      = {Name = "Katarina",     spellname = "E | Shunpo"},
    ["KennenLightningRush"]            = {Name = "Kennen",       spellname = "E | Lightning Rush"},
    ["KhazixE"]                        = {Name = "Khazix",       spellname = "E | Leap"},
    ["LeblancSlide"]                   = {Name = "Leblanc",      spellname = "W | Distortion"},
    ["LeblancSlideM"]                  = {Name = "Leblanc",      spellname = "R | Distortion"},
    ["LeonaZenithBlade"]               = {Name = "Leona",        spellname = "E | Zenith Blade"},
    ["LissandraE"]                     = {Name = "Lissandra",    spellname = "E | Glacial Path"},
    ["LucianE"]                        = {Name = "Lucian",       spellname = "E | Relentless Pursuit"},
    ["MaokaiUnstableGrowth"]           = {Name = "Maokai",       spellname = "W | Twisted Advance"},
    ["MonkeyKingNimbus"]               = {Name = "MonkeyKing",   spellname = "E | Nimbus Strike"},
    ["NautilusAnchorDrag"]             = {Name = "Nautilus",     spellname = "Q | Dredge Line"},
    ["Pantheon_LeapBash"]              = {Name = "Pantheon",     spellname = "W | Aegis of Zeonia"},
    ["PoppyHeroicCharge"]              = {Name = "Poppy",        spellname = "E | Heroic Charge"},
    ["QuinnE"]                         = {Name = "Quinn",        spellname = "E | Vault"},
    ["RenektonSliceAndDice"]           = {Name = "Renekton",     spellname = "E | Slice"},
    ["RiftWalk"]                       = {Name = "Kassadin",     spellname = "R | Riftwalk"},
    ["RivenTriCleave"]                 = {Name = "Riven",        spellname = "Q | Broken Wings"},
    ["RocketJump"]                     = {Name = "Tristana",     spellname = "W | Rocket Jump"},
    ["SejuaniArcticAssault"]           = {Name = "Sejuani",      spellname = "Q | Arctic Assault"},
    ["ShenShadowDash"]                 = {Name = "Shen",         spellname = "ShenE", RangeMin = 300, Range = 600, Type = 1, Duration = 0.5},
    ["TalonCutThroat"]                 = {Name = "Talon",        spellname = "E | Cutthroat"},
    ["UFSlash"]                        = {Name = "Malphite",     spellname = "R | Unstoppable Force"},
    ["UdyrBearStance"]                 = {Name = "Udyr",         spellname = "E | Bear Stance"},
    ["Valkyrie"]                       = {Name = "Corki",        spellname = "W | Valkyrie"},
    ["ViQ"]                            = {Name = "Vi",           spellname = "Q | Vault Breaker"},
    ["VolibearQ"]                      = {Name = "Volibear",     spellname = "Q | Rolling Thunder"},
    ["XenZhaoSweep"]                   = {Name = "XinZhao",      spellname = "E | Crescent Sweep"},
    ["YasuoDashWrapper"]               = {Name = "Yasuo",        spellname = "E | Sweeping Blade"},
    ["blindmonkqtwo"]                  = {Name = "LeeSin",       spellname = "Q | Resonating Strike"},
    ["khazixelong"]                    = {Name = "Khazix",       spellname = "E | Leap"},
    ["reksaieburrowed"]                = {Name = "RekSai",       spellname = "E | Tunnel"},
    ["TryndamereE"]                    = {Name = "Tryndamere",   spellname = "E | Spinning Slash"},

    --{Name = "ShenE", RangeMin = 300, Range = 600, Type = 1, Duration = 0.5}, --CHUAN
  }

  if menu then
    self:LoadToMenu(menu)
  end

  if func then
    table.insert(self.callbacks, func)
  end
  
  self.posEndDash = Vector(0, 0, 0)
  self.DurationEx = 0
  self.lastCast = 0

  Callback.Add("Tick", function(...) self:OnTick(...) end)
  Callback.Add("ProcessSpell", function(...) self:OnProcessSpell(...) end)
  Callback.Add("Draw", function(...) self:OnDraw(...) end)
end

function ChallengerAntiGapcloser:LoadToMenu(menu)
  self.menu = menu
  local SpellAdded = false
  local EnemyNames = {}
  self.enabled = nil
  self.EnableAntiGap = self.menu.addItem(MenuBool.new("Enabled", true))
	for _, enemy in pairs(GetEnemyHeroes()) do   
      table.insert(EnemyNames, GetAIHero(enemy).CharName)
  end

    self.menu_evade_spells = {}
    for i, spells in pairs(self.spells) do
       if table.contains(EnemyNames, spells.Name) then
            table.insert(self.menu_evade_spells, { 
              spellsName = spells.Name,
              spellsspellname = spells.spellname,
              enabled = self.menu.addItem(MenuBool.new(spells.Name.." | "..spells.spellname, true))
              })        
        end
    end

  if not SpellAdded then
		self.menu.addItem(MenuSeparator.new("No spell available to interrupt"))
  end
end

function ChallengerAntiGapcloser:OnDraw()
  if self.posEndDash ~= 0 then
    DrawCircleGame(self.posEndDash.x , self.posEndDash.y, self.posEndDash.z, 200, Lua_ARGB(255,255,0,0))
  end

  local targets = (GetEnemyChampNearest(1000))
  if targets ~= 0 then
    --local target = GetAIHero(targets)
    local targetPos = Vector(GetPosX(targets), GetPosY(targets), GetPosZ(targets))
    DrawCircleGame(targetPos.x , targetPos.y, targetPos.z, 200, Lua_ARGB(255,255,0,0))
  end
end

function ChallengerAntiGapcloser:TriggerCallbacks(unit, spell)
  for i, cb in pairs(self.callbacks) do
    cb(unit, spell)
  end
end

local function GetDistanceSqr(Pos1, Pos2)
  local Pos2 = Pos2 or Vector(myHero)
  --local P2 = GetOrigin(P2) or GetOrigin(myHero)
  --local P1 = GetOrigin(P1)
  local dx = Pos1.x - Pos2.x
  local dz = (Pos1.z or Pos1.y) - (Pos2.z or Pos2.y)
  return dx * dx + dz * dz
end

function ChallengerAntiGapcloser:getPosDash(spell)
  local Target = self.menu_ts:GetTarget(math.huge)
    --local TargetDashing, CanHitDashing, DashPosition 
    if IsValidTarget(Target) then
      target = GetAIHero(Target)
      local TargetDashing, CanHitDashing, DashPosition = vpred:IsDashing(target, spell.delay, spell.width, spell.speed, myHero, true)       
      if DashPosition ~= nil then
        return DashPosition
      end
    end 
end

function ChallengerAntiGapcloser:OnProcessSpell(unit, spell)

  if not unit.IsMe then
    return
  end

  for i = 1, #self.menu_evade_spells do   
    --if self.menu_evade_spells[i].spellsName == spell.Name then
      self.enabled = self.menu_evade_spells[i].enabled.getValue()
      __PrintTextGame(tostring(self.menu_evade_spells[i].enabled.getValue()))
    --end    
  end

  --if not self.EnableAntiGap or unit.TeamId == myHero.TeamId or unit.Type ~= 0 then return end
  --if not self.enabled then return end
  
  local target = GetEnemyChampNearest(1000)
  local myHeroPos = Vector(myHero.x, myHero.y, myHero.z)
  local targetPos = Vector(GetPosX(target), GetPosY(target), GetPosZ(target))
  local added =  GetTargetById(spell.TargetId) == target and true or false
  
    

  local endPos = self.posEndDash
  --__PrintTextGame(tostring(GetDistance(targetPos, self.posEndDash)))
  --__PrintTextGame(tostring(GetDistanceSqr(target))..">>"..tostring(GetDistanceSqr(Vector(target) + 300 * (endPos - Vector(target)):Normalized())))
  --local endGap = myHeroPos:Extended(PosMouseAfterCast, spellRangeMin)

  --if GetChampName(GetTargetById(spell.TargetId)) == "NULL" and (GetDistance(target) > GetDistance(Vector(target) + 300 * (endPos - Vector(target)):Normalized()) or 
                                                                --GetDistance(target) < GetDistance(Vector(target) + 100 * (endPos - Vector(target)):Normalized()))  then
  local i = 0
  if GetChampName(GetTargetById(spell.TargetId)) == "NULL" then -- and 300 >  GetDistance(targetPos, self.posEndDash) then
    i = i + 1
    added = true    
  end
  
  if added then
    local data = {unit = unit, spell = spell, endTime = GetTimeGame() + 900}
    table.insert(self.activespells, data)
    self:TriggerCallbacks(data.unit, data)
  end
end

function ChallengerAntiGapcloser:OnTick()
  for i = #self.activespells, 1, -1 do
    if self.activespells[i].endTime - GetTickCount() > 0 then
      self:TriggerCallbacks(self.activespells[i].unit, self.activespells[i])
    else
      table.remove(self.activespells, i)
    end
  end
end


--https://github.com/KeVuong/GoS/blob/master/Common/Inspired.lua
