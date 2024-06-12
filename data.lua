local modName = "__Simple_Circuit_Trains__"

data:extend({
    {
        type = "sprite",
        name = "simple-stop-icon",
        filename = modName .. "/images/smart-stop-icon.png",
        priority = "extra-high-no-scale",
        size = 32
    },
    {
        type = "sprite",
        name = "simple-add-white",
        filename = modName .. "/images/add-icon-white.png",
        priority = "extra-high-no-scale",
        size = 32
    },
    {
        type = "sprite",
        name = "simple-change-recipe-white",
        filename = modName .. "/images/change-recipe-white.png",
        priority = "extra-high-no-scale",
        size = 64,
        scale = 0.5
    },
    {
        type = "tips-and-tricks-item-category",
        name = "luzifers-mods",
        order = "s-[luzifers-mods]"
    },
    {
        type = "tips-and-tricks-item",
        name = "simple-circuit-trains",
        category = "luzifers-mods",
        order = "b",
        is_title = true,
        dependencies = { "train-stops", "circuit-network" },
        image = modName .. "/images/guiExplanation.png",
        tutorial = "simple-circuit-trains"
    },
    {
        type = "tutorial",
        name = "simple-circuit-trains",
        scenario = "SCT"
    }
})

if mods["Automatic_Coupling_System"] then
    data:extend({
        {
            type = "tips-and-tricks-item",
            name = "automatic-coupling-system-and-simple-circuit-trains",
            category = "luzifers-mods",
            order = "c",
            is_title = true,
            dependencies = { "simple-circuit-trains", "automatic-coupling-system" },
            tutorial = "automatic-coupling-system-and-simple-circuit-trains"
        },
        {
            type = "tutorial",
            name = "automatic-coupling-system-and-simple-circuit-trains",
            scenario = "ATC_SCT"
        }
    })
end
