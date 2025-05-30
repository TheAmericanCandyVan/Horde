GADGET.PrintName = "Hardening Injection"
GADGET.Description = "{1} reduced movement speed.\n{2} increased Global damage resistance.\n{3} increased Physical damage resistance."
GADGET.Icon = "items/gadgets/hardening_injection.png"
GADGET.Duration = 5
GADGET.Cooldown = 15
GADGET.Active = true
GADGET.Params = {
    [1] = { value = 0.5, percent = true },
    [2] = { value = 0.25, percent = true },
    [3] = { value = 0.25, percent = true },
}
GADGET.Hooks = {}

GADGET.Hooks.Horde_UseActiveGadget = function (ply)
    if CLIENT then return end
    if ply:Horde_GetGadget() ~= "gadget_hardening_injection" then return end
    sound.Play("horde/gadgets/injection.ogg", ply:GetPos())
    sound.Play("horde/gadgets/energy_shield_in.ogg", ply:GetPos())
    ply.Horde_In_Hardening_Injection = true
    ply:ScreenFade(SCREENFADE.IN, Color(50, 200, 200, 25), 0.1, 5)
    timer.Simple(5, function()
        if ply:IsValid() then ply.Horde_In_Hardening_Injection = nil return end
    end)
end

GADGET.Hooks.Horde_OnPlayerDamageTaken = function (ply, dmginfo, bonus)
    if ply:Horde_GetGadget() ~= "gadget_hardening_injection" then return end
    if not ply.Horde_In_Hardening_Injection then return end
    bonus.resistance = bonus.resistance + 0.25
    if HORDE:IsPhysicalDamage(dmginfo) then
        bonus.resistance = bonus.resistance + 0.25
    end
end

GADGET.Hooks.Horde_PlayerMoveBonus = function(ply, bonus_walk, bonus_run, bonus_jump)
    if ply:Horde_GetGadget() ~= "gadget_hardening_injection" then return end
    if not ply.Horde_In_Hardening_Injection then return end
    bonus_walk.more = bonus_walk.more * 0.5
    bonus_run.more = bonus_run.more * 0.5
end