
local FreshWater1 = PolyZone:Create({
 vector2(-1604.55, 1415.15),
 vector2(-1586.36, 1480.30),
 vector2(-1606.06, 1622.73),
 vector2(-1580.30, 1748.48),
 vector2(-1537.88, 1936.36),
 vector2(-1734.85, 2066.67),
 vector2(-1675.76, 2542.42),
 vector2(-1515.15, 2545.45),
 vector2(-1362.12, 2307.58),
 vector2(-1348.48, 2019.70),
 vector2(-1354.55, 1827.27),
 vector2(-1433.33, 1345.45),
 vector2(-1581.82, 1259.09)
}, { name="FreshWater1" })

local CrabArea1 = PolyZone:Create({
 vector2(-2613.64, 2889.39),
 vector2(-2695.45, 2334.85),
 vector2(-1700.00, 2489.39),
 vector2(-1490.91, 2534.85),
 vector2(-1559.09, 2743.94)
}, { name="CrabArea1" })

local FlyFishSalt1 = PolyZone:Create({
 vector2(-1445.45, 2693.94),
 vector2(-1343.94, 2530.30),
 vector2(-1037.88, 2740.91),
 vector2(-716.67, 2737.88),
 vector2(-603.03, 2868.18),
 vector2(-424.24, 2851.52),
 vector2(-316.67, 2943.94),
 vector2(-178.79, 2907.58),
 vector2(-71.21, 3025.76),
 vector2(145.45, 3106.06),
 vector2(193.94, 3301.52),
 vector2(315.15, 3483.33),
 vector2(371.21, 3607.58),
 vector2(140.91, 3640.91),
 vector2(-15.15, 3166.67),
 vector2(-689.39, 2998.48),
 vector2(-1180.30, 2875.76)
}, { name="FlyFishSalt1" })

local FlyFishSalt2 = PolyZone:Create({
 vector2(-104.55, 4286.36),
 vector2(-260.61, 4124.24),
 vector2(-537.88, 4290.91),
 vector2(-821.21, 4330.30),
 vector2(-1124.24, 4275.76),
 vector2(-1318.18, 4233.33),
 vector2(-1628.79, 4246.97),
 vector2(-1875.76, 4472.73),
 vector2(-1954.55, 4554.55),
 vector2(-1769.70, 4733.33),
 vector2(-1556.06, 4531.82),
 vector2(-1324.24, 4466.67),
 vector2(-1083.33, 4493.94),
 vector2(-809.09, 4504.55),
 vector2(-506.06, 4559.09),
 vector2(-206.06, 4500.00)
}, { name="FlyFishSalt2" })

local MainIsland = PolyZone:Create({
 vector2(-28.79, 7777.27),
 vector2(-513.64, 6965.15),
 vector2(-1301.52, 6274.24),
 vector2(-2271.21, 5522.73),
 vector2(-2537.88, 4710.61),
 vector2(-3083.33, 3753.03),
 vector2(-3313.64, 3122.73),
 vector2(-3422.73, 2104.55),
 vector2(-3543.94, 953.03),
 vector2(-3410.61, -150.00),
 vector2(-2671.21, -707.58),
 vector2(-2150.00, -1350.00),
 vector2(-1628.79, -2040.91),
 vector2(-2246.97, -3228.79),
 vector2(-1653.03, -3786.36),
 vector2(-695.45, -3859.09),
 vector2(-453.03, -3386.36),
 vector2(250.00, -3531.82),
 vector2(1365.15, -3592.42),
 vector2(1765.15, -3277.27),
 vector2(2407.58, -2792.42),
 vector2(2819.70, -2295.45),
 vector2(3159.09, -1543.94),
 vector2(3243.94, -840.91),
 vector2(3643.94, -40.91),
 vector2(3450.00, 625.76),
 vector2(3268.18, 1607.58),
 vector2(3474.24, 2201.52),
 vector2(3910.61, 2868.18),
 vector2(4250.00, 3631.82),
 vector2(4286.36, 4662.12),
 vector2(3862.12, 5534.85),
 vector2(3462.12, 6468.18),
 vector2(2407.58, 6940.91)
}, { name="deep" })

local CayoIsland = PolyZone:Create({
  vector2(3737.1110839844, -4615.3295898438),
  vector2(3798.2736816406, -4931.279296875),
  vector2(4310.5615234375, -4757.0522460938),
  vector2(4422.9150390625, -4939.7446289062),
  vector2(4556.2470703125, -5208.8139648438),
  vector2(4659.4072265625, -5214.0078125),
  vector2(4758.83984375, -5302.8388671875),
  vector2(4586.5454101562, -5674.0112304688),
  vector2(4717.8862304688, -6043.4291992188),
  vector2(4812.0317382812, -6121.5200195312),
  vector2(5523.4135742188, -5993.9750976562),
  vector2(5868.6528320312, -5508.6547851562),
  vector2(5672.8208007812, -5167.4038085938),
  vector2(5286.8041992188, -4610.140625),
  vector2(4841.689453125, -4204.29296875),
  vector2(4193.3579101562, -4254.56640625)
}, { name="CayoIsland" })

exports("InDeepsea", function()
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  local onMainLAnd = MainIsland:isPointInside(pos)
  local onCayo = CayoIsland:isPointInside(pos)
  return not onMainLAnd and not onCayo
end)

exports("InSaltwaterFlyfish", function()
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  local area1 = FlyFishSalt1:isPointInside(pos)
  local area2 = FlyFishSalt2:isPointInside(pos)
  return area1 or area2
end)

exports("InFreshwaterFlyfish", function()
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  local area1 = FreshWater1:isPointInside(pos)
  return area1
end)

exports("InCrabArea", function()
  local ped = PlayerPedId()
  local pos = GetEntityCoords(ped)
  local area1 = CrabArea1:isPointInside(pos)
  return area1
end)
