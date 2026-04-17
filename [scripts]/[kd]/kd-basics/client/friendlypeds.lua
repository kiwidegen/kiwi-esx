-- ╔══════════════════════════════╗
-- ║        Friendly Peds         ║
-- ╚══════════════════════════════╝
if not Config.Modules.FriendlyPeds then return end

local playerGroup = GetHashKey('PLAYER')
local rel         = Config.FriendlyPeds.relationship

-- Set bidirectional relationship for every configured group toward PLAYER
for _, name in ipairs(Config.FriendlyPeds.groups) do
    local group = GetHashKey(name)
    SetRelationshipBetweenGroups(rel, group, playerGroup)
    SetRelationshipBetweenGroups(rel, playerGroup, group)
end
