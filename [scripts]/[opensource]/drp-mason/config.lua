Config = {}

Config.RepairSpots = {
    vector4(462.11, -1015.15, 27.07, 272.13),
    -- Add more spots here
    -- vector4(x, y, z, heading),
}

Config.AllowedJobs = {
    'police',
    'ambulance'
}

Config.RepairTime = 5000

Config.MarkerSettings = {
    type = 27, -- MarkerTypeHorizontalSplitArrowCircle
    size = {x = 1.5, y = 1.5, z = 1.0},
    color = {r = 0, g = 255, b = 0, a = 100},
    distance = 5.0,
    interactDistance = 3.0
}
