function step!(model, pars, iefpars)
    model.time += pars.timestep

    if model.time / 60 >= 24
        model.day += 1
        if model.day == 8
            model.day = + 1
            model.week += 1
        end
        model.time = 0
    end

    world = model.world

    for agent in world.pop
        activity!(agent, world, model.day, model.time, pars)
    end

    for agent in world.pop
        disease!(agent, world, pars, iefpars)
    end

    for house in world.map
        infection!(house, world, pars, iefpars)
    end

    for transp in world.transports, car in transp.cars
        infection!(car, world, pars, iefpars)
    end
end
        
