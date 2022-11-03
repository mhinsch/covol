
offset_house(hx, hy, o, s) = (x = o.x + (hx-1) * s.x,
                    y = o.y + (hy-1) * s.y)

function drawModel(model, offset, hsize)

    for house in model.world.map
        pos = house.pos
        # top left corner of house
        t_offset = offset_house(pos.x, pos.y, offset, hsize)
        
        t = house.type
        col = 
            if t == PlaceT.residential
                RL.GREEN
            elseif t == PlaceT.school
                RL.BROWN
            elseif t == PlaceT.hospital
                RL.WHITE
            elseif t == PlaceT.supermarket
                RL.YELLOW
            elseif t == PlaceT.work
                RL.BLUE
            elseif t == PlaceT.leisure
                RL.ORANGE
            else
                RL.BLACK
            end

        RL.DrawRectangleLinesEx(
            RL.RayRectangle(t_offset.x, t_offset.y, hsize.x-1, hsize.y-1), 1.0, col)

        for p in house.present
            px = rand(2:(hsize.x-2))
            py = rand(2:(hsize.y-2))
            RL.DrawPixel(t_offset.x + px, t_offset.y + py, RL.RED)
        end
    end

    for transport in model.world.transports
        pos1 = transport.p1.pos
        pos2 = transport.p2.pos
        o1 = offset_house(pos1.x, pos1.y, offset, hsize) 
        o2 = offset_house(pos2.x, pos2.y, offset, hsize) 

        RL.DrawLine(o1.x, o1.y, o2.x, o2.y, RL.PURPLE)
    end
end
    
