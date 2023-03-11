function step!(model, pars)
    model.time += pars.timestep

    if model.time / 60 >= 24
        model.day += 1
        if model.day == 8
            model.day = 1
            model.week += 1
        end
        model.time = 0
    end

    world = model.world
    
    #println("activity")
    for agent in world.pop
        activity!(agent, world, model.day, model.time, pars)
    end

    #println("disease")
    #if model.time % pars.dt_disease == 0
        for agent in world.pop
            disease!(agent, world, pars)
        end
    #end

    #println("infection")
    for house in world.map
        infection!(house, world, pars)
    end

    #println("infection II")
    for transp in world.transports, car in transp.cars
        infection!(car, world, pars)
    end
    
    #println("experience")
    if model.time % pars.dt_exp == 0
        for agent in world.pop
            covid_experience!(agent, world, pars)
        end
    end
    
    #println("policies")
    if model.time % pars.policy_check_dt == 0
    	check_policies!(world, pars)
	end
end
        
