using MiniObserve

# mean and variance
const MVA = MeanVarAcc{Float64}
# maximum, minimum
const MMA = MaxMinAcc{Float64}

@observe Data world begin
    @for person in world.pop begin
        @stat("n_inf", CountAcc) <| (person.immune.status == IStatus.infected)
        @stat("n_rec", CountAcc) <| (person.immune.status == IStatus.recovered)
    end

    @for inf in Iterators.filter(p->infectious(p), world.pop) begin
        @stat("ief", MVA, MMA) <| inf.virus.ief_0
    end
end


function ticker(model, t, data)
    println("step: ", t, "\tief: ", data.ief.mean)
end
