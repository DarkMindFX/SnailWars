local composer = require( "composer" )

function main()
    printDisplayInfo()
end

function printDisplayInfo()
    print("*** Display Info ***")
    print("display.contentWidth", display.contentWidth)
    print("display.contentHeight", display.contentHeight)

    print("display.actualContentWidth", display.actualContentWidth)
    print("display.actualContentHeight", display.actualContentHeight)

    print("display.pixelWidth", display.pixelWidth)
    print("display.pixelHeight", display.pixelHeight)

    print("display.contentScaleX", display.contentScaleX)
    print("display.contentScaleY", display.contentScaleY)

    print("system.orientation", system.orientation)


    composer.gotoScene("scenes.game",  
        {   effect = "fade",
            time = 300,
            params = {
                numPlayersPerTeam = 5,
                scale = 0.2
            } }
    )

end

main()
