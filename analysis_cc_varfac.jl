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

@observe Data world t pars begin
    @record "time" Int t
    
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
        @stat("n_inf", CountAcc) <| (infected(person))
        @stat("n_sick", CountAcc) <| (sick(person, pars))
        @stat("n_imm", MVA, MMA, HistAcc(0.0, 1.0)) <| Float64(length(person.immune.immunities))
        @stat("n_virus", MVA, MMA, HistAcc(1.0, 1.0)) <| Float64(length(person.viruses))
        @stat("health", MVA, HistAcc(0.0, 0.05, 1.0)) <| person.health
        @stat("duration", MVA, HistAcc(0.01, 2.0*24*4)) <| Float64(person.inf_duration)
        @stat("exp", MVA, MMA) <| person.cov_experience
# TODO activity of most active immunity
#        @if infected(person) @stat("imm", MVA, MMA) <| 
    end

    @for d in hamming_dists(world.pop, 1000) begin
        @stat("hamming", MVA, HistAcc(0.0, pars.mutate_dist/7)) <| d
    end
end


function ticker(model, data)
    println("time: ", model.week, ":", model.day, ":", model.time/60, "\timm: ", data.n_imm.mean, "\t", data.n_imm.max, "\tvirus: ", data.n_virus.mean, "\t", data.n_virus.max)
end
