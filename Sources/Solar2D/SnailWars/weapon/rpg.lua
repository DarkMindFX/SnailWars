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
        power = 50,
        name = "rpg"
    }

  

    rpg.launcher = launcher
    rpg.grenade = grenade

    function rpg:shoot(x, y)
        self.grenade:applyForce(x, y, 0, 0)
    end

    rpg:insert(launcher)
    rpg:insert(grenade)

    return rpg
end

return rpgFactory