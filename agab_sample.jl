function gene_dist(ga, gb)
    d = 0.0
    for (a, b) in zip(ga, gb)
        d += abs(a-b)
    end
    
    d/length(ga)
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
    
    dists = Float64[]
    
    if length(inf_pop) <= 1
        return dists
    end
    
    for i in 1:n
        ag_a = rand(inf_pop)
        while (ag_b = rand(inf_pop)) == ag_a end
            
        push!(dists, gene_dist(ag_a.virus.antigens, ag_b.virus.antigens))
    end
    
    dists
end
