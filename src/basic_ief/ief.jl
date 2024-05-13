using Distributions


"Generate fitness effect of `n_mutations` repeat mutations based on `distribution` of fitness effects of a single mutation (1.0 == neutral)."
function fitness(n_mutations, distribution)
    f = 1.0

    for i in 1:n_mutations
        f_factor = max(0.0, rand(distribution))
        f *= f_factor
    end
    
    f
end

"Increase mutation count in population `pop` using distribution of number of mutations `distr`."
function step_population!(pop, distr)
    for i in eachindex(pop)
        pop[i] += rand(distr)
    end
end

mut_distr(p_mutation, n_basepairs) = Poisson(p_mutation * n_basepairs)


"Draw `n_samples` fitness values from `pop` using distribution of fitness effects `fit_distr` under the assumption that the probability of an individual being sampled is proportional to its fitness."
function ief_instance(pop, n_samples, fit_distr)
    fitnesses = [fitness(n, fit_distr) for n in pop]
    w_fitnesses = cumsum(fitnesses)
    
    [ weighted_choice(fitnesses, w_fitnesses) for i in 1:n_samples ], 
        w_fitnesses[end]/length(w_fitnesses)
end

"Lookup table for fitness values."
struct Lookup{V, W}
    values :: Vector{V}
    weights :: Vector{W}
end

"Compress a sample of fitness values into a lookup table with `n_bins` bins."
function lookup_table(samples, n_bins)
    mi, ma = extrema(samples)
    
    bw = (ma-mi)/n_bins
            
    values = [ mi + i*bw - bw/2 for i in 1:n_bins ]
    
    # set bin width to infinite if data has no range
    if bw == 0.0 bw=Inf end
    bins = zeros(Int, n_bins)
    for s in samples
        # max value goes into last bin as well
        bins[min(n_bins, floor(Int, (s-mi)/bw)+1)] += 1
    end

    Lookup(values, cumsum(bins))
end

"Draw a fitness value from a lookup table."
draw(lookup :: Lookup) = weighted_choice(lookup.values, lookup.weights)

"Draw a value from `values` using a list of cumulative sums of weights."
weighted_choice(values, weights) = values[searchsortedfirst(weights, rand_weight_range(weights[end]))]

"Generate random lookup index for a lookup table."
rand_weight_range(w :: Float64) = rand() * w
rand_weight_range(w :: Int) = rand(1:w)


"Convert lookup table weights from a cumulative sum to actual weight values."
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
