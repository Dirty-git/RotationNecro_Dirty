local my_utility = require("my_utility/my_utility")
local spell_data = require("my_utility/spell_data")

local menu_elements =
{
    tree_tab       = tree_node:new(1),
    main_boolean   = checkbox:new(true, get_hash(my_utility.plugin_label .. "blight_base_main_bool")),
    targeting_mode = combo_box:new(1, get_hash(my_utility.plugin_label .. "blight_base_targeting_mode")),
    debuff_only    = checkbox:new(true, get_hash(my_utility.plugin_label .. "blight_base_debuff_only")),
    elites_only    = checkbox:new(true, get_hash(my_utility.plugin_label .. "blight_base_elites_only")),
}

local function menu()
    if menu_elements.tree_tab:push("Blight") then
        menu_elements.main_boolean:render("Enable Spell", "")

        if menu_elements.main_boolean:get() then
            menu_elements.targeting_mode:render("Targeting Mode", my_utility.targeting_modes,
                my_utility.targeting_mode_description)
            menu_elements.debuff_only:render("Only cast if debuff is not active on target", "")
            menu_elements.elites_only:render("Only cast on elite or higher enemies", "")
        end

        menu_elements.tree_tab:pop()
    end
end

local next_time_allowed_cast = 0.0;

local function logics(target)
    if not target then return false end;
    local menu_boolean = menu_elements.main_boolean:get();
    local is_logic_allowed = my_utility.is_spell_allowed(
        menu_boolean,
        next_time_allowed_cast,
        spell_data.blight.spell_id);

    if not is_logic_allowed then return false end;

    -- Check for debuff
    local debuff_only = menu_elements.debuff_only:get();
    if debuff_only then
        local is_debuff_active = my_utility.is_debuff_active(target, spell_data.blight.spell_id,
            spell_data.blight.debuff_id);
        if is_debuff_active then
            return false;
        end;
    end

    local elites_only = menu_elements.elites_only:get();
    if elites_only then
        local is_elite = target:is_elite() or target:is_champion() or target:is_boss()
        if not is_elite then
            return false;
        end;
    end

    if cast_spell.target(target, spell_data.blight.spell_id, 0, false) then
        local current_time = get_time_since_inject();
        next_time_allowed_cast = current_time + my_utility.spell_delays.regular_cast;

        console.print("Cast Blight - Target: " ..
            my_utility.targeting_modes[menu_elements.targeting_mode:get() + 1]);
        return true;
    end;

    return false;
end


return
{
    menu = menu,
    logics = logics,
    menu_elements = menu_elements
}
