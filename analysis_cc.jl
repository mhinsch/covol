using MiniObserve

# mean and variance
const MVA = MeanVarAcc{Float64}
# maximum, minimum
const MMA = MaxMinAcc{Float64}

function n_infected_transport(t)
    n = 0
    for car in t.cars, p in car.present
        if infected(p)
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
            (findfirst(infected, house.present) != nothing)
    end

    @for transport in world.transports begin
        @stat("p_inf_transport", MVA) <| Float64(n_infected_transport(transport))
        @stat("n_commute", SumAcc{Int}) <| sum(c->length(c.present), transport.cars)
    end

    @for person in world.pop begin
        @stat("n_inf", CountAcc) <| (infectious(person))
        @stat("n_asym", CountAcc) <| (infected(person))
        @stat("n_rec", CountAcc) <| (length(person.immune_system) > 1)
        @stat("exp", MVA, MMA) <| person.cov_experience
    end

    @for inf in Iterators.filter(p->infectious(p), world.pop) begin
        @stat("ief", MVA, MMA) <| inf.virus.ief_0
    end
end


function ticker(model, data)
    println("day: ", model.day, "\ttime: ", model.time/60, "\t", data.n_commute.n)
end
