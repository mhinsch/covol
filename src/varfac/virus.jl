using Distributions
using PDMats:ScalMat


struct Virus
    phenotype :: Vector{Float64}
end

Virus() = Virus([])


function mutate_virus(virus, dist)
    # normal distributed delta 
    Virus(virus.phenotype .+ rand(MvNormal(ScalMat(length(virus.phenotype), dist))))
end

function mutate_virus2!(virus, n, dist)
    # normal distributed delta
    bd = Binomial(20)
    for i in 1:n
        virus.phenotype[rand(1:length(virus.phenotype))] += (rand(bd)-10) * dist
    end
    
    #print("m")
end

transmit(virus, pars) = Virus(copy(virus.phenotype))
