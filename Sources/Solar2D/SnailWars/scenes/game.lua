local composer = require("composer")
local math = require("math")

local rpgFactory = require("weapon.rpg")

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
        -- self.scene.grpFieldContent.arrowCurrSnail.isVisible = true
        self.currSnail:showAim()
    end
end

function game:snailShoot()
    if (self.currSnail ~= nil ) then
        physics.start()

        local power = 10 * self.currSnail.properties.aimPower

        --self.currSnail.weapon:shoot(0, 0)

    end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

function scene:createCharacter(team, id, img)
    local grpSnail = display.newGroup()
    
    grpSnail.properties = {
        team = team,
        id = id,
        health = 100,
        direction = 1,  -- -1 = left, 1 = right,
        aimDirection = math.pi / 180 * -45, -- angle in radians
        aimPower = 0
    }

    grpSnail.img = display.newImage("images/character/" .. img);
    grpSnail:insert(grpSnail.img);
    grpSnail.img.x = 0
    grpSnail.img.y = 0

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
                print("aimDirection = " .. self.properties.aimDirection)            
            end
            local newPower = math.sqrt( event.yDelta * event.yDelta + event.xDelta * event.xDelta ) / 300 
            if(newPower >= 0 and newPower < 1) then
                self.properties.aimPower = newPower
            end
            print("aimPower = " .. self.properties.aimPower) 
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
            weapon.x = self.x
            weapon.y = self.yDelta

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

function scene:createTerrain()
    local grpTerrain = display.newGroup()

    grpTerrain.img = display.newImage("images/background/ground_5000.png")
    grpTerrain.img.x = 0
    grpTerrain.img.y = 0

    grpTerrain:insert(grpTerrain.img)

    return grpTerrain
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

function scene:createPlayField()
    local grpFieldContent = display.newGroup() -- contains playing field, characters etc, NOT including screen controls

    -- create terrain
    local grpTerrain = self:createTerrain();
    grpFieldContent:insert(grpTerrain)

    grpTerrain.x = display.contentWidth / 2
    grpTerrain.y = display.contentHeight - grpTerrain.height / 2
    -- create teams

    local grpPlayer1 = self:createCharacter(0, 0, "snail_green.png");
    local grpPlayer2 = self:createCharacter(1, 0, "snail_brown.png");
    
    grpPlayer1.x = display.contentWidth / 2 - 500
    grpPlayer1.y = grpTerrain.y - grpTerrain.height / 2 - grpPlayer1.height / 2

    grpPlayer2.x = display.contentWidth / 2 + 500
    grpPlayer2.y = grpTerrain.y - grpTerrain.height / 2 - grpPlayer2.height / 2

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
        physics.start()
        physics.pause()
        physics.setGravity(0, 9.8)
        

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