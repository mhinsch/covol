

function sample_virus_genes(pop)
    cdict = Dict{typeof(pop[1].virus.antigens), Int}() 
    for a in pop
        if ! isempty(a.virus.antigens)
            get!(cdict, a.virus.antigens, 0)
            cdict[a.virus.antigens] += 1
        end
    end
    
    sort!(collect(cdict), by = x->x.second)
end
        
