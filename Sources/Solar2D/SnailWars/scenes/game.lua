local composer = require("composer")
local math = require("math")

local snailFactory = require("character.snail")
local terrainHelper = require("helpers.terrainHelper")

local scene = composer.newScene();

local team = {
    name = "",
    snails = {}
}

local game = {

    teams = {},

    currTeam = nil,

    currSnail = nil,

    scene = nil
}

function game:onSnailTap(snail)
    
    if(snail ~= self.currSnail) then

        if(self.currSnail ~= nil) then
            self.currSnail:hideAim()
        end

        self.scene.grpFieldContent:pointToSnail(snail)

        self.currSnail = snail

        self.currSnail:showAim()
        print("Snail selected: Team = ", snail.properties.team, " Snail = ", snail.properties.id, " Health = ", snail.properties.health)
    end
end

function game:moveSnail(diff)

    self.scene.grpFieldContent.arrowCurrSnail.isVisible = false
    
    if (self.currSnail ~= nil ) then

        if(self.currSnail.properties.direction * diff < 0) then
            self.currSnail.properties.direction = diff / math.abs(diff)

            self.currSnail.xScale = self.currSnail.properties.direction
        end

        self.currSnail.x = self.currSnail.x + diff
        self.scene.grpFieldContent.arrowCurrSnail.x = self.currSnail.x
        self.currSnail:showAim()
    end
end

function game:snailShoot()
    if (self.currSnail ~= nil ) then

        local projectile = nil

        if(self.currSnail.weapon.properties.hasProjectile) then
            local projStartPoint = self.currSnail.weapon:getProjectileStartPoint(
                self.currSnail.x, 
                self.currSnail.y, 
                self.currSnail.properties.direction, 
                self.currSnail.properties.aimDirection
            )

            projectile = self.currSnail.weapon:createProjectile()
            projectile.x = projStartPoint.x
            projectile.y = projStartPoint.y

            self.scene.grpFieldContent:insert(projectile)
            
            self.currSnail.weapon:shoot(self.currSnail.x, 
                                    self.currSnail.y,
                                    self.currSnail.properties.aimPower, 
                                    self.currSnail.properties.aimDirection,
                                    self.currSnail.properties.direction,
                                    projectile)

        end

    end
end

function game:moveStart()
end

function game:moveEnd()
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

function scene:createCharacter(team, id, img)
    local grpSnail = snailFactory:createSnail(team, id, img, game)

    return grpSnail
 
end

function scene:createControls(callbacks)
    local grpContros = display.newGroup()

    -- Button to move snail left
    grpContros.btnMoveLeft = display.newImage("images/assets/move_left_arrow.png")
    grpContros.btnMoveLeft.x = (display.contentWidth - display.actualContentWidth) / 2 + grpContros.btnMoveLeft.width / 2
    grpContros.btnMoveLeft.y = display.contentHeight - grpContros.btnMoveLeft.height / 2

    function grpContros.btnMoveLeft:tap(event)
        game:moveSnail(-10)
    end

    grpContros.btnMoveLeft:addEventListener("tap", grpContros.btnMoveLeft)

    -- Button to move snail right
    grpContros.btnMoveRight = display.newImage("images/assets/move_right_arrow.png")
    grpContros.btnMoveRight.x = display.actualContentWidth - (display.actualContentWidth - display.contentWidth) / 2 - grpContros.btnMoveLeft.width / 2
    grpContros.btnMoveRight.y = display.contentHeight - grpContros.btnMoveRight.height / 2

    function grpContros.btnMoveRight:tap(event)
        game:moveSnail(10)
    end

    grpContros.btnMoveRight:addEventListener("tap", grpContros.btnMoveRight)

    grpContros:insert(grpContros.btnMoveLeft)
    grpContros:insert(grpContros.btnMoveRight)

    return grpContros
end

function scene:createSoilPlatform(grpFieldContent, x0, y0)
    local height = 3
    for r = 1, height, 1 do
        local soilLine = terrainHelper:generateSingleLine(10)
        
        for i = 1, table.getn(soilLine), 1 do
            local brick = soilLine[i]

            brick.x = brick.x + x0
            brick.y = brick.y + y0 + r * brick.height

            grpFieldContent:insert(brick)
        end
    end
end

function scene:createPlayField()
    local grpFieldContent = display.newGroup() -- contains playing field, characters etc, NOT including screen controls

    -- create terrain
    local water = terrainHelper:createWater();
    grpFieldContent:insert(water)

    water.x = display.contentWidth / 2
    water.y = display.contentHeight - water.height / 2

    -- creating soil platforms
    self:createSoilPlatform(grpFieldContent, 100, 100)

    -- create teams

    local grpPlayer1 = self:createCharacter(0, 0, "snail_green.png");
    local grpPlayer2 = self:createCharacter(1, 0, "snail_brown.png");
    
    grpPlayer1.x = display.contentWidth / 2 - 500
    grpPlayer1.y = water.y - water.height / 2 - grpPlayer1.height / 2

    grpPlayer2.x = display.contentWidth / 2 + 500
    grpPlayer2.y = water.y - water.height / 2 - grpPlayer2.height / 2

    grpFieldContent:insert(grpPlayer1)
    grpFieldContent:insert(grpPlayer2)

    
    function grpFieldContent:touch(event)
        if event.phase == "began" then
            display.getCurrentStage():setFocus( self )
            self.isFocus = true
            self.xStart = self.x
        end
        if self.isFocus and event.phase == "moved" then

            self.x = self.xStart + event.xDelta
            
        end 
        if event.phase == "ended" or event.phase == "cancelled" then
            display.getCurrentStage():setFocus( nil )
            self.isFocus = false
        end
        return true
    end
    

    grpFieldContent:addEventListener("touch", self.grpFieldContent)

    -- snail pointer
    local arrowCurrSnail = display.newImage("images/assets/snail_selected_arrow.png")    
    arrowCurrSnail.isVisible = false

    grpFieldContent.arrowCurrSnail = arrowCurrSnail
    
    function grpFieldContent:pointToSnail(snail)
        grpFieldContent.arrowCurrSnail.isVisible = false
    
        grpFieldContent.arrowCurrSnail.x = snail.x
        grpFieldContent.arrowCurrSnail.y = -20
    
        grpFieldContent.arrowCurrSnail.isVisible = true
    
        transition.to(grpFieldContent.arrowCurrSnail, {
            y = snail.y - snail.height / 2 - grpFieldContent.arrowCurrSnail.height / 2,
            time = 300
        })
    
    end

    grpFieldContent:insert(arrowCurrSnail)    

    -- aim pointer
    local aimPointer = display.newImage("images/assets/aim_red.png")
    aimPointer.isVisible = false
    aimPointer.direction = math.pi / 180 * -45

    grpFieldContent.aimPointer = aimPointer

    grpFieldContent:insert(aimPointer)

    -- return full field content

    return grpFieldContent;
end



-- create()
function scene:create( event )
    
    physics.start()
    physics.setGravity(0, 9.8)
    

    local sceneSelf = self
	local sceneGroup = self.view
	local params = event.params

    local grpSceneContent = display.newGroup() -- contains ALL scene objects (incl. world, buttons etc)

    -- Creat playing field
    local grpFieldContent = self:createPlayField()    

    grpSceneContent:insert(grpFieldContent)

    -- Create controls
    local grpControls = self:createControls(nil)

    grpSceneContent:insert(grpControls)

    self.grpFieldContent = grpFieldContent
    self.grpSceneContent = grpSceneContent
    self.grpControls = grpControls

    game.scene = self

	sceneGroup:insert(grpSceneContent)

end

-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
        
        

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)


	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------


return scene