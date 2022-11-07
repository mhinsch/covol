function step!(model, pars)
    model.time += pars.timestep

    if model.time / 60 >= 24
        model.day = (model.day) % 7 + 1
        model.time = 0
    end

    world = model.world

    for agent in world.pop
        activity!(agent, world, model.day, model.time, pars)
    end

    for agent in world.pop
        disease!(agent, pars)
    end

    for house in world.map
        infection!(house, pars)
    end

    for transp in world.transports, car in transp.cars
        infection!(car, pars)
    end
end
        
