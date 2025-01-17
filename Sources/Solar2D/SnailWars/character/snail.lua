

local rpgFactory = require("weapon.rpg")

local snailFactory = {}

function snailFactory:createSnail(team, id, img, game)
    local grpSnail = display.newGroup()
    
    grpSnail.properties = {
        team = team,
        id = id,
        health = 100,
        direction = 1,  -- -1 = left, 1 = right,
        aimDirection = math.pi / 180 * -45, -- angle in radians
        aimPower = 0,
        type = "snail"
    }

    grpSnail.img = display.newImage("images/character/" .. img);
    grpSnail:insert(grpSnail.img);
    grpSnail.img.x = 0
    grpSnail.img.y = 0
    grpSnail.img.parent = grpSnail

    physics.addBody(grpSnail, "static",
    {
        density = 3.0, 
        friction = 0.5, 
        bounce = 0.3,
    })

    grpSnail.aimPointer = display.newImage("images/assets/aim_red.png")
    grpSnail.aimPointer.isVisible = false
    grpSnail:insert(grpSnail.aimPointer);

    grpSnail.weapon = nil

    grpSnail:scale(1, grpSnail.properties.direction)

    function grpSnail:touch(event)

        if event.phase == "began" then
            game:onSnailTap(self)
            print("Snail tapped - Team = " , self.properties.team, " ID = ", self.properties.id)

            display.getCurrentStage():setFocus( self )
            self.isFocus = true
            self.xStart = self.img.x
            self.yStart = self.img.y
        end
        if self.isFocus and event.phase == "moved" then
            local newAngle = math.asin( event.yDelta / event.xDelta ) * self.properties.direction * (180 / math.pi)
            if(newAngle < 180) then
                self.properties.aimDirection = newAngle
                -- print("aimDirection = " .. self.properties.aimDirection)            
            end
            local newPower = math.sqrt( event.yDelta * event.yDelta + event.xDelta * event.xDelta ) / 300 
            if(newPower >= 0 and newPower < 1) then
                self.properties.aimPower = newPower
            end
            -- print("aimPower = " .. self.properties.aimPower) 
            self:showAim()       
        end 
        if event.phase == "ended" or event.phase == "cancelled" then

            if(event.phase == "ended" and self.properties.aimPower > 0) then
                game:snailShoot()
            end

            display.getCurrentStage():setFocus( nil )
            self.isFocus = false
        end
        return true
    end

    function grpSnail:showAim()

        if(self.weapon == nil) then
            local weapon = rpgFactory:create()
            weapon.x = 0
            weapon.y = 0

            self:insert(weapon)
            self.weapon = weapon
        end

        self.aimPointer.isVisible = true
        self.aimPointer.x = self.img.x + 200 * math.cos(self.properties.aimDirection * math.pi / 180)
        self.aimPointer.y = self.img.y + 200 * math.sin(self.properties.aimDirection * math.pi / 180)

        if(self.weapon ~= nil) then
            self.weapon.rotation = self.properties.aimDirection
        end

    end

    function grpSnail:hideAim()
        self.weapon:removeSelf()
        self.weapon = nil
        self.aimPointer.isVisible = false
    end

    grpSnail:addEventListener("touch", self.grpSnail)

    return grpSnail
end

return snailFactory