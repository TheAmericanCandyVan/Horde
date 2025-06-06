PERK.PrintName = "Necromancer Base"
PERK.Description = [[
COMPLEXITY: MEDIUM

Inflicts Frostbite buildup by {1} of base Cold damage. ({2} + {3} per level, up to {4}).
{5} increased Cold damage resistance. ({6} per level, up to {7}).
{8} increased minion damage. ({9} per level, up to {10}).
{11} extra spectres. ({12} per {13} levels, up to {14}).

Uses Mind instead of Armor.
Has access to spells for Void Projector.]]
PERK.Icon = "materials/subclasses/necromancer.png"

PERK.Params = {
    [1] = { percent = true, base = 0.15, level = 0.01, max = 0.4, classname = "Necromancer" },
    [2] = { value = 0.15, percent = true },
    [3] = { value = 0.01, percent = true },
    [4] = { value = 0.4, percent = true },
    [5] = { percent = true, base = 0, level = 0.01, max = 0.25, classname = "Necromancer" },
    [6] = { value = 0.01, percent = true },
    [7] = { value = 0.25, percent = true },
    [8] = { percent = true, level = 0.01, max = 0.20, classname = "Necromancer" },
    [9] = { value = 0.01, percent = true },
    [10] = { value = 0.20, percent = true },
    [11] = { level_scaling = true, base = 1, level = 1, per_level = 5, max = 5, classname = "Necromancer" },
    [12] = { value = 1 },
    [13] = { value = 5 },
    [14] = { value = 5 },
}

PERK.Hooks = {}

function UpdateSpectreMaxCount(ply)
    if not ply:Horde_GetPerk("necromancer_base") then
        ply.Horde_Spectre_Max_Count = 0
        return
    end

    local level_bonus = math.min(5, math.floor(ply:Horde_GetLevel("Necromancer") / 5))
    local count = 1 + level_bonus

    if ply:Horde_GetPerk("necromancer_hollow_essence") then
        count = count + 1
    end
    if ply:Horde_GetPerk("necromancer_abyssal_might") then
        count = count + 1
    end
    if ply:Horde_GetPerk("necromancer_necromastery") then
        count = count + 1
    end

    ply.Horde_Spectre_Max_Count = count
end

PERK.Hooks.Horde_OnPlayerDamageTaken = function(ply, dmginfo, bonus)
    if not ply:Horde_GetPerk("necromancer_base") then return end
    if HORDE:IsColdDamage(dmginfo) then
        bonus.resistance = bonus.resistance + ply:Horde_GetPerkLevelBonus("necromancer_base")
    end
end

PERK.Hooks.Horde_OnPlayerDamage = function(ply, npc, _, _, dmginfo)
    if not ply:Horde_GetPerk("necromancer_base") then return end
    if HORDE:IsColdDamage(dmginfo) then
        npc:Horde_AddDebuffBuildup(
            HORDE.Status_Frostbite,
            dmginfo:GetDamage() * (0.15 + ply:Horde_GetPerkLevelBonus("necromancer_base")),
            ply, dmginfo:GetDamagePosition()
        )
    end
end

PERK.Hooks.Horde_OnPlayerMinionDamage = function(ply, npc, bonus, dmginfo)
    if ply:Horde_GetPerk("necromancer_base") then
        bonus.increase = bonus.increase + ply:Horde_GetPerkLevelBonus("necromancer_base_minion_damage")
    end
end

PERK.Hooks.Horde_OnSetPerk = function(ply, perk)
    if SERVER and perk == "necromancer_base" then
        ply:Horde_SetMindRegenTick(0.25)
        ply:SetMaxArmor(0)
        UpdateSpectreMaxCount(ply)

        if ply:HasWeapon("horde_void_projector") == true then return end

        ply:Horde_UnsetSpellWeapon()
        ply:StripWeapons()

        timer.Simple(0, function()
            if not ply:Alive() then return end

            if not ply:Horde_GetPerk("necromancer_base") then return end
            ply:Give("horde_void_projector")

            if (not ply:Horde_GetPrimarySpell() or (ply:Horde_GetPrimarySpell().Weapon ~= nil
            and not table.HasValue(ply:Horde_GetPrimarySpell().Weapon, "horde_void_projector"))) then
                ply:Horde_SetSpell("void_sphere")
            end

            if (not ply:Horde_GetSecondarySpell() or (ply:Horde_GetSecondarySpell().Weapon ~= nil
            and not table.HasValue(ply:Horde_GetSecondarySpell().Weapon, "horde_void_projector"))) then
                ply:Horde_SetSpell("raise_spectre")
            end

            if (not ply:Horde_GetUtilitySpell() or (ply:Horde_GetUtilitySpell().Weapon ~= nil
            and not table.HasValue(ply:Horde_GetUtilitySpell().Weapon, "horde_void_projector"))) then
                ply:Horde_SetSpell("illuminate")
            end

            if (ply:Horde_GetUltimateSpell() and (ply:Horde_GetUltimateSpell().Weapon ~= nil
            and not table.HasValue(ply:Horde_GetUltimateSpell().Weapon, "horde_void_projector"))) then
                ply:Horde_UnsetSpell(ply:Horde_GetUltimateSpell().ClassName)
            end

            ply:Horde_RecalcAndSetMaxMind()
        end)
    end
end

PERK.Hooks.Horde_OnUnsetPerk = function(ply, perk)
    if SERVER and perk == "necromancer_base" then
        ply:Horde_SetMaxMind(0)
        ply:Horde_SetMind(0)
        ply:Horde_SetMindRegenTick(0)
        ply:SetMaxArmor(100)
        UpdateSpectreMaxCount(ply)
    end
end

PERK.Hooks.Horde_PrecomputePerkLevelBonus = function(ply)
    if SERVER then
        ply:Horde_SetPerkLevelBonus("necromancer_base", math.min(0.25, 0.01 * ply:Horde_GetLevel("Necromancer")))
        ply:Horde_SetPerkLevelBonus("necromancer_base_minion_damage", math.min(0.20, 0.01 * ply:Horde_GetLevel("Necromancer")))
    end
end