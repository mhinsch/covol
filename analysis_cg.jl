using MiniObserve

# mean and variance
const MVA = MeanVarAcc{Float64}
# maximum, minimum
const MMA = MaxMinAcc{Float64}

@observe Data world pars t begin
    @for person in world.pop begin
        @stat("n_inf", CountAcc) <| (person.immune.status == IStatus.infected)
        @stat("n_rec", CountAcc) <| (person.immune.status == IStatus.recovered)
    end

    @for inf in Iterators.filter(p->infectious(p), world.pop) begin
        @stat("ief", MVA, MMA) <| inf.virus.ief_0
        #@stat("r0", MVA, HistAcc(0.0, 1.0)) <| (pars.mean_k * pars.p_inf_base^(1/inf.virus.e_ief) / 
        #                         pars.p_rec)
        @stat("r0", MVA, HistAcc(0.0, 1.0)) <| (pars.mean_k * (1-(1-pars.p_inf_base)^inf.virus.e_ief) / 
                                 pars.p_rec)
    end


end


function ticker(model, t, data)
    println("step: ", t, "\tinf: ", data.n_inf.n, "\tief: ", data.ief.mean)
end
