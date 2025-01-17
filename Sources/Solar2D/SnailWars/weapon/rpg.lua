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

    rpg.properties = {
        radius = 300,
        damage = 50,
        name = "rpg",
        hasProjectile = true
    }

    rpg.launcher = launcher
    rpg.grenade = grenade

    function rpg:shoot(x0, y0, power, angle, direction, projectile)
        self.grenade.isVisible = false
        
        local gx, gy = physics.getGravity()
        local V0 = power * 1000
        print("RPG shoot: x0 =" .. x0 .. " y0 = " .. y0 .. " power = " .. power, " angle = " .. angle .. " gy = " .. gy)
        
        if(projectile ~= nil) then
            local xVel = V0 * math.cos( angle * math.pi / 180 )
            local yVel = V0 * math.sin( angle * direction * math.pi / 180 )
            projectile:setLinearVelocity( xVel , yVel  )
        end
        
    end

    function rpg:getProjectileStartPoint(x0, y0, direction, angle)
        local angleRad = angle * math.pi / 180
        local distance = self.grenade.x - self.launcher.x
        local localX = math.cos( angleRad ) * distance * direction
        local localy = math.sin( angleRad ) * distance 
        return {
            x = x0 + localX, 
            y = y0 + localy
        }
    end

    function rpg:createProjectile()
        local grenade = display.newGroup()        
        grenade.img = display.newImage("images/weapon/rocket_launcher_grenade.png")
 
        grenade.properties = {
            damage = self.properties.damage,
            type = "rpg_grenade"
        } 

        function grenade:createExplistion(onExplistionComplete)
            local explistion = display.newGroup()

            explistion.img = display.newImage("images/weapon/rpg_explosion.png")
            explistion.img:scale(0.1, 0.1)
            explistion:insert(explistion.img)
            explistion.onExplistionComplete = onExplistionComplete

            function explistion:explode()
                transition.to( explistion.img, { time = 200, xScale = 1, yScale = 1, rotation = 45, onComplete = self.onExplistionComplete } )
            end
            
            return explistion
        end

        grenade:insert(grenade.img)

        physics.addBody(grenade, "dynamic", 
        {
            density = 3.0, 
            friction = 0.5, 
            bounce = 0.3,
            radius = 50
        })

        local function onExplistionComplete(obj)
            obj:removeSelf()
        end

        local function onGrenadeCollision(self, event)
            
            print("onGrenadeCollision")

            if ( event.phase == "ended" ) then

                print( "began: " .. self.properties.type .. " vs " .. event.other.properties.type)

                if(event.other.properties.type == "snail") then
                    local otherSnail = event.other

                    otherSnail.properties.health = math.max(0, otherSnail.properties.health - self.properties.damage)

                    print("Snail ".. otherSnail.properties.team .. " id = ".. otherSnail.properties.id .. ": health = " .. otherSnail.properties.health)

                    local explistion = self:createExplistion(onExplistionComplete)

                    self:removeSelf() -- removing grenade

                    otherSnail:insert(explistion)
                    explistion:explode()

                elseif(event.other.properties.type == "water") then
                    print("Grenade in water")
                elseif(event.other.properties.type == "brick") then
                    local explistion = self:createExplistion(onExplistionComplete)

                    self:removeSelf() -- removing grenade

                    explistion:explode()
                end
            
            end

        end
        
        grenade.collision = onGrenadeCollision
        grenade:addEventListener("collision")

        return grenade
    end

    rpg:insert(launcher)
    rpg:insert(grenade)

    return rpg
end

return rpgFactory