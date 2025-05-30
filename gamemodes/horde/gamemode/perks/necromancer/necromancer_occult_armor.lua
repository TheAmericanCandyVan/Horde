PERK.PrintName = "Occult Armor"
PERK.Description =
[[Uses Mind to lessen damage taken, up to {1}.
The more Mind you have, the less damage you take.
Requires at least 35 Mind to activate.]]
PERK.Icon = "materials/perks/necromancer/occult_armor.png"

PERK.Params = {
    [1] = { value = 0.5, percent = true },
}

PERK.Hooks = {}

PERK.Hooks.Horde_OnPlayerDamageTaken = function ( ply, dmginfo, bonus )
    if not ply:Horde_GetPerk( "necromancer_occult_armor" ) then return end

    if ply:Horde_GetMind() >= 35 then
        local mind_taken = math.min( 30, dmginfo:GetDamage() / 2.5 )
        bonus.less = bonus.less * ( 1 - math.max( 0.15, 0.5 * ply:Horde_GetMind() / 100 ) )
        ply:Horde_SetMind( math.max( 5, ply:Horde_GetMind() - mind_taken ) )
    end
end