using Distributions
using PDMats:ScalMat


struct Virus
    phenotype :: Vector{Float64}
end

Virus() = Virus([])


function mutate_virus(virus, dist)
    Virus(virus.phenotype .+ rand(MvNormal(ScalMat(length(virus), dist))))
end


transmit(virus, pars) = Virus(copy(virus.phenotype))
