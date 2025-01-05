local composer = require("composer")
local math = require("math")

local scene = composer.newScene();

local team = {
    name = "",
    snails = {}
}

local game = {

    teams = {},

    currTeam = nil,

    currSnail = nil
}

function game:onSnailTap(snail)
    self.currSnail = snail

    print("Snail selected: Team = ", snail.properties.team, " Snail = ", snail.properties.id, " Health = ", snail.properties.health)
end

function game:moveSnail(diff)
    
    if (self.currSnail ~= nil ) then

        if(self.currSnail.properties.direction * diff < 0) then
            self.currSnail.properties.direction = diff / math.abs(diff)

            self.currSnail.xScale = self.currSnail.properties.direction
        end

        print("Snail direction: ", self.currSnail.properties.direction)

        

        self.currSnail.x = self.currSnail.x + diff
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
        direction = 1 -- -1 = left, 1 = right
    }

    grpSnail.img = display.newImage("images/character/" .. img);
    grpSnail:insert(grpSnail.img);
    grpSnail.img.x = 0
    grpSnail.img.y = 0
    grpSnail:scale(1, grpSnail.properties.direction)

    function grpSnail:tap(event)
        local snail = event.target
        print("Snail tapped - Team = " , snail.properties.team, " ID = ", snail.properties.id)
        game:onSnailTap(snail)
    end

    grpSnail:addEventListener("tap", self.grpSnail)

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
            -- can move house content only horizontally
            self.x = self.xStart + event.xDelta
            
        end 
        if event.phase == "ended" or event.phase == "cancelled" then
            display.getCurrentStage():setFocus( nil )
            self.isFocus = false
        end
        return true
    end

    grpFieldContent:addEventListener("touch", self.grpFieldContent)

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