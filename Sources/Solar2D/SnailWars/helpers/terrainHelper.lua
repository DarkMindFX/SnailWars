
local terrainHelper = {}

function terrainHelper:generateSingleLine(length)
    local soilLine = {}

    local hexagonShape = {-40, 0, 
                          -10, -35,
                          10, -35,
                          40, 0,
                          10, 35,
                          -10, 35}

    for i = 0, length - 1, 1 do
        local brick = display.newImage("images/assets/hexagon_red.png")
        brick.properties = {
            type = "brick"
        }
        physics.addBody(brick, "static", { 
            shape = hexagonShape, 
            isSensor = true
        } )
        brick.x = i * brick.width
        brick.y = 0

        table.insert(soilLine, brick)
    end

    return soilLine
end

function terrainHelper:createWater()
    local grpWater = display.newGroup()

    grpWater.img = display.newImage("images/background/water_5000.png")
    grpWater.img.x = 0
    grpWater.img.y = 0

    grpWater.properties = {
        type = "water"
    }

    grpWater:insert(grpWater.img)

    physics.addBody(grpWater, "static", 
        { 
            isSensor = true 
        }
    )

    return grpWater
end

return terrainHelper