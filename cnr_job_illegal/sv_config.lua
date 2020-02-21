
-- config (server)

local crates = {
	{cont = SUPPLY_CTRL, mdl = "prop_boxpile_06b"},  -- Controlled Substances
	{cont = SUPPLY_CTRL, mdl = "prop_box_wood05a"},  -- Controlled Substances
	{cont = SUPPLY_CTRL, mdl = "prop_boxpile_04a"},  -- Controlled Substances
	{cont = SUPPLY_CTRL, mdl = "prop_box_wood01a"},  -- Controlled Substances
	{cont = SUPPLY_CHOP, mdl = "prop_boxpile_06a"},  -- Chop Shop
	{cont = SUPPLY_CHOP, mdl = "prop_boxpile_08a"},
	{cont = SUPPLY_CHOP, mdl = "prop_boxpile_07a"},
	{cont = SUPPLY_GUNS, mdl = "prop_mil_crate_01"}, -- Gun Parts
	{cont = SUPPLY_GUNS, mdl = "prop_box_wood03a"},
	{cont = SUPPLY_GUNS, mdl = "prop_mb_crate_01a"},
	{cont = SUPPLY_CTRL, mdl = "prop_box_wood06a"},
	{cont = SUPPLY_GUNS, mdl = "prop_box_wood08a"},
	{cont = SUPPLY_CHOP, mdl = "prop_boxpile_07d"} 
}


local cratedrops = {
  {pos = vector3(-26.97,-1215.34,28.81),h=274.86,title="Strawberry"},
  {pos = vector3(653.12,-1730.72,9.17),h=354.6,title="Cypress"},
  {pos = vector3(142.34,-1205.8,28.77),h=95.3,title="Strawberry"},
  {pos = vector3(-53.45,-1493.28,31.65),h=87.42,title="LS Projects"},
  {pos = vector3(173.61,-1697.98,29.29),h=231.8,title="South Central"},
  {pos = vector3(178.23,-1688.91,29.59),h=100.28,title="South Central"},
  {pos = vector3(1027.72,-1837.15,32.48),h=82.71,title="East LS"},
  {pos = vector3(1149.51,-1643.41,36.33),h=20.48,title="East LS"},
  {pos = vector3(472.68,-1873.85,26.84),h=292.97,title="East LS"},
  {pos = vector3(354.8,-1851.77,27.71),h=307.35,title="East LS"},
  {pos = vector3(297.4,-1719.32,29.26),h=52.24,title="East LS"},
  {pos = vector3(550.41,-896.43,12.19),h=44.08,title="LS River"},
  {pos = vector3(726.42,-549.26,26.57),h=193.14,title="LS River"},
  {pos = vector3(749.26,-650.4,28.57),h=79.05,title="LS River"},
  {pos = vector3(712.47,-726.43,26.02),h=261.93,title="LS River"},
  {pos = vector3(692.3,-786.38,24.64),h=99.2,title="LS River"},
  {pos = vector3(486.66,-1522.79,29.29),h=299.73,title="East LS"},
  {pos = vector3(-96.94,-976.24,21.27),h=350.33,title="Construction"},
  {pos = vector3(-337.51,-1315.44,31.33),h=245.63,title="Alleyway"},
  {pos = vector3(-971.17,-1953.17,13.39),h=313.45,title="Alleyway"},
  {pos = vector3(-1183.92,-2080.63,14.22),h=189.32,title="LSX"},
  {pos = vector3(1281.31,-3253.7,5.9),h=73.66,title="Port of LS"},
  {pos = vector3(358.79,-2444.95,6.4),h=341.23,title="Port of LS"},
  {pos = vector3(715.49,-1069.28,22.27),h=177.8,title="LS River"},
  {pos = vector3(700.05,-1125.65,23.17),h=178.04,title="LS River"},
  {pos = vector3(746.77,-667.31,27.81),h=273.03,title="LS River"},
  {pos = vector3(743.67,-628.8,28.8),h=283.77,title="LS River"},
  {pos = vector3(703.37,-627.94,27.08),h=261.71,title="LS River"},
  {pos = vector3(706.94,-595.66,26.16),h=165.85,title="LS River"},
  {pos = vector3(1487.76,-1606.44,71.98),h=63.05,title="LS Oilfields"},
  {pos = vector3(1325.72,-183.62,108.43),h=320.38,title="East LS"},
  {pos = vector3(1406.17,-130.34,129.91),h=257.78,title="East LS"},
  {pos = vector3(1836.47,259.17,162.65),h=15.24,title="East LS"},
  {pos = vector3(1831.82,292.22,162.85),h=1.44,title="East LS"},
  {pos = vector3(1869.97,431.34,163.29),h=323.62,title="East LS"},
  {pos = vector3(-304.87,-2211.72,9.88),h=53.8,title="South LS"},
  {pos = vector3(-143.28,-2239.21,7.83),h=301.81,title="South LS"},
  {pos = vector3(-28.73,-2214.43,7.83),h=301.66,title="South LS"},
  {pos = vector3(-30.62,-1260.73,29.24),h=269.12,title="Strawberry"},
  {pos = vector3(648.15,-1093.41,22.19),h=180.5,title="LS River"},
  {pos = vector3(-471.4,-1024.71,23.24),h=226.33,title="Construction"},
  {pos = vector3(998.42,-107.94,73.45),h=273.86,title="East Vinewood"},
  {pos = vector3(951.63,-205.46,72.6),h=124.83,title="East Vinewood"},
  {pos = vector3(967.51,-197.99,72.66),h=327.32,title="East Vinewood"},
  {pos = vector3(343.07,-1097.34,28.91),h=227.05,title="Mission Row"},
  {pos = vector3(1402.74,-700.31,66.73),h=142.81,title="East LS"},
  {pos = vector3(1391.12,-782.59,67.41),h=275.36,title="East LS"},
  {pos = vector3(1102.02,-904.04,49.08),h=61.53,title="East LS"},
  {pos = vector3(1103.13,-996.67,44.74),h=151.98,title="East LS"},
  {pos = vector3(1101.67,-1149.74,28.04),h=194.4,title="East LS"},
  {pos = vector3(1092.71,-1136.49,27.58),h=253.92,title="East LS"},
  {pos = vector3(1177.31,-1126.25,27.51),h=311.45,title="East LS"},
  {pos = vector3(1098.38,-1260.58,20.35),h=140.29,title="East LS"},
  {pos = vector3(1048.19,-1301.36,19.85),h=66.53,title="East LS"},
  {pos = vector3(891.95,-1447.08,11.97),h=331.76,title="East LS"},
  {pos = vector3(1268.8,-2181.45,49.24),h=188.25,title="East LS"},
  {pos = vector3(697.41,-1732.29,9.68),h=354.77,title="East LS"},
  {pos = vector3(467.22,-1063.07,29.21),h=336.44,title="East LS"}
}


--- GetCrateSpawn()
-- Chooses a random crate to spawn into the world for collection.
-- Return must compensate for a nil return
-- @return Crate Info from 'cratedrops'. Returns nil if no crates are eligible
function GetCrateSpawn()
  local stopSpawn = false
  local i = math.random(#cratedrops)
  print("DEBUG - Selecting Crate #"..i.." at location ("..(cratedrops[i].title)..")")
  local waitTime = GetGameTimer() + 5000
  if cratedrops[i].active then 
    while cratedrops[i].active do
      print("DEBUG - Crate already spawned, picking another.")
      Wait(10)
      i = math.random(#cratedrops)
      if waitTime < GetGameTimer() then 
        print("[SRP ILLICIT] All eligible crates have been spawned.")
        stopSpawn = true -- Stop this process; No crates eligible
        break
      end
    end
  end
  if stopSpawn then return nil
  else return cratedrops[i] end
end


--- GenerateCrate()
-- Returns a table of the crate information given from 'crates' Table
-- @return Table {cont = (int)type, mdl = (str)model}
function GenerateCrate()
  local i = math.random(#crates)
  print("DEBUG - i["..i.."]; Contents["..(crates[i].cont).."]")
  return crates[i]
end