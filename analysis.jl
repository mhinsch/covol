using MiniObserve

# mean and variance
const MVA = MeanVarAcc{Float64}
# maximum, minimum
const MMA = MaxMinAcc{Float64}

function n_infected_transport(t)
    n = 0
    for car in t.cars, p in car.present
        if p.immune.status == IStatus.infected
            n += 1
        end
    end
    n
end

@observe Data world begin
    @for house in world.map begin
        # format:
        # @stat(name, accumulators...) <| expression
        @stat("n_inf_houses", CountAcc) <| 
            (findfirst(p->p.immune.status == IStatus.infected, house.present) != nothing)
    end

    @for transport in world.transports begin
        @stat("p_inf_transport", MVA) <| Float64(n_infected_transport(transport))
    end

    @for person in world.pop begin
        @stat("n_inf", CountAcc) <| (person.immune.status == IStatus.infected)
        @stat("n_rec", CountAcc) <| (person.immune.status == IStatus.recovered)
    end
end
