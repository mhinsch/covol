function gene_dist(ga, gb)
    d = 0.0
    for (a, b) in zip(ga, gb)
        d += abs(a-b)
    end
    
    d/length(ga)
end


function gene_dist(aga::VarfacCityAgent, agb::VarfacCityAgent)
    gene_dist(rand(aga.viruses).phenotype, rand(agb.viruses).phenotype)
end


function sample_immunity(pop, n, pars)
    imm = zeros(n)
    imm_self = zeros(n)
    
    count = 0
    # agents should be in random order
    for agent in pop
        if infected(agent)
            count += 1
            # random virus from infected individual
            v = rand(agent.viruses)
            # immune system of random other individual
            immune = rand(pop).immune
            _, imm[count] = find_best_match(immune, v, pars)
            _, imm_self[count] = find_best_match(agent.immune, v, pars)
            
            if count == n # we have enough
                break
            end
        end
    end
    
    resize!(imm, n)
    resize!(imm_self, n)
    
    imm, imm_self
end


"Sort genomes by frequency and calculate distance to most frequent one."
function sample_virus_genes(pop, compare = nothing)
    cdict = Dict{typeof(pop[1].virus.antigens), Int}() 
    for a in pop
        if ! isempty(a.virus.antigens)
            get!(cdict, a.virus.antigens, 0)
            cdict[a.virus.antigens] += 1
        end
    end
    
    genes = sort!(collect(cdict), by = x->x.second)
    
    if isempty(genes)
        return genes, Float64[], Float64[]
    end
    
    best = genes[end][1]
    
    dist1 = [ gene_dist(best, g[1]) for g in genes]
    if compare != nothing
        dist2 = [ gene_dist(compare, g[1]) for g in genes]
    else
        dist2 = Float64[]
    end
    
    genes, dist1, dist2
end


function hamming_dists(pop, n)
    inf_pop = [a for a in pop if infected(a)]
    
    if length(inf_pop) <= 1
        return zeros(2)
    end
    
    dists = Float64[]
    
    for i in 1:n
        ag_a = rand(inf_pop)
        while (ag_b = rand(inf_pop)) == ag_a end
            
        push!(dists, gene_dist(ag_a, ag_b))
    end
    
    dists
end
