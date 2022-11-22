using Distributions


function fitness(n_mutations, distribution)
    f = 1.0

    for i in 1:n_mutations
        f_factor = max(0.0, rand(distribution))
        f *= f_factor
    end
    
    f
end

function step_population!(pop, distr)
    for i in eachindex(pop)
        pop[i] += rand(distr)
    end
end

mut_distr(p_mutation, n_basepairs) = Poisson(p_mutation * n_basepairs)


function ief_instance(pop, n_samples, fit_distr)
    fitnesses = [fitness(n, fit_distr) for n in pop]
    w_fitnesses = cumsum(fitnesses)

    [ weighted_choice(fitnesses, w_fitnesses) for i in 1:n_samples ], 
        w_fitnesses[end]/length(w_fitnesses)
end

struct Lookup{V, W}
    values :: Vector{V}
    weights :: Vector{W}
end

function lookup_table(samples, n_bins)
    mi, ma = extrema(samples)

    bw = (ma-mi)/n_bins
    values = [ mi + i*bw - bw/2 for i in 1:n_bins ]

    bins = zeros(Int, n_bins)
    for s in samples
        # max value goes into last bin as well
        bins[min(n_bins, floor(Int, (s-mi)/bw)+1)] += 1
    end

    Lookup(values, cumsum(bins))
end

draw(lookup :: Lookup) = weighted_choice(lookup.values, lookup.weights)

weighted_choice(values, weights) = values[searchsortedfirst(weights, rand_weight_range(weights[end]))]

rand_weight_range(w :: Float64) = rand() * w
rand_weight_range(w :: Int) = rand(1:w)


function pdf(lookup::Lookup)
    vec = lookup.weights

    res = zeros(Int, length(vec))
    x = 0
    for (i,v) in enumerate(vec)
        res[i] = v - x
        x = v
    end
    res
end
