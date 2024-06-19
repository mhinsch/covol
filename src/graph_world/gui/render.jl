
offset_node(hx, hy, o, s) = (x = o.x + (hx-1) * s.x,
                    y = o.y + (hy-1) * s.y)

function drawModel(model, offset, nsize)
    s = max(nsize.x, nsize.y) ÷ 2
    for (i, node) in enumerate(model.world.pop)
        t_offset = offset_node(i ÷ 100, i % 100, offset, nsize)

        t = node.immune.status
        col = 
            if t == IStatus.naive
                RL.GREEN
            elseif t == IStatus.infected
                RL.RED
            elseif t == IStatus.recovered
                RL.BLUE
            elseif t == IStatus.vaccinated
                RL.YELLOW
            else
                error("unknown state")
            end
        RL.DrawCircle(t_offset.x, t_offset.y, s, col)
    end
end
    
