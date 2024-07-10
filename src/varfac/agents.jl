struct VarfacAgent
    immune :: Immune
    viruses :: Vector{Virus}
    health :: Float64
    immune_strength :: Float64
end

VarfacAgent() = VarfacAgent(Immune(), [], 1.0, 1.0)


function infect!(agent, virus, pars)
    push!(agent.viruses, transmit(virus, pars))
end


