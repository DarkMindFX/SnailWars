local physicsHelper = require("helpers.physicsHelper")

local rpgFactory = {}

function rpgFactory:create()
    print("Creating RPG")

    local rpg = display.newGroup()

    local launcher = display.newImage("images/weapon/rocket_launcher.png")
    launcher.x = 0
    launcher.y = 0

    local grenade = display.newImage("images/weapon/rocket_launcher_grenade.png")
    grenade.x = launcher.x + launcher.width / 2 + grenade.width / 2
    grenade.y = -10
    grenade.properties = {
        radius = 300,
        damage = 50,
        name = "rpg"
    }

    physics.addBody( grenade, "static", { bounce = 0, radius = 50 } )

    rpg.launcher = launcher
    rpg.grenade = grenade

    function rpg:shoot(x0, y0, power, angle, direction)
        local gx, gy = physics.getGravity()
        print("RPG shoot: x0 =" .. x0 .. " y0 = " .. y0 .. " power = " .. power, " angle = " .. angle .. " gy = " .. gy)
        
        physicsHelper.CalcTrajectory(x0, y0, power * 100, angle, direction, gy, nil)
    end

    rpg:insert(launcher)
    rpg:insert(grenade)

    return rpg
end

return rpgFactory