
local physicsHelper = {}

function physicsHelper.CalcTrajectory(x0, y0, V0, a, dir, gy)
    local aRad = a * math.pi / 180
    print("physicsHelper:CalcTrajectory: x0 = " .. x0 .. " y0 = " .. y0 .. " V0 = " .. V0 .. " a (rad) = " .. aRad .. " direction = " .. dir .. " g = " .. gy)
    S = (dir * -1) * math.pow(V0, 2) * math.sin( 2 * aRad ) / gy -- distance 
    h =  math.pow(V0, 2) * math.pow( math.sin( aRad ), 2 ) / ( 2 * gy ) -- height
    t = 2 * V0 * math.sin(aRad) / gy -- time

    print("S = " .. S .. " h = " .. h .. " t = " ..t)

    -- calculating trajectory - https://rep.bntu.by/bitstream/handle/data/24233/%D0%A1.%20247-260.pdf?sequence=1&isAllowed=y
    local trajectory = {}
    for x = x0, x0 + S, 1 
    do
        y = V0 * math.sin(aRad) * (x / (V * math.cos(aRad)) ) 
            - (g * math.pow(x, 2)) / (2 * math.pow(V0, 2) * math.pow( math.cos(aRad) , 2) )

        trajectory.insert(x, y)
    end

    return trajectory
end

return physicsHelper