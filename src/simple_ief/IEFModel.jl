module IEFModel

export IEF, setup_ief, expected_ief_factor, transmitted_ief_factor, IEFParams

include("ief.jl")
include("ief_pars.jl")


"Pre-generated IEF lookup tables and their expected values for multiple time points."
struct IEF
    fitness :: Vector{Lookup{Float64, Int}}
    mean :: Vector{Float64}
end


function setup_ief(pars)
    pop = zeros(Int, pars.ief_pre_N)

    n_mutation_d = mut_distr(pars.ief_p_mut, pars.n_basepairs)
    fitness_d = Normal(pars.ief_mut_mu, pars.ief_mut_sigma)

    ief = IEF([], [])

    for i in 1:pars.ief_pre_n_steps
        step_population!(pop, n_mutation_d)
        samples, exp_value = ief_instance(pop, pars.ief_pre_n_samples, fitness_d)
        table = lookup_table(samples, pars.ief_pre_n_bins)
        push!(ief.fitness, table)
        push!(ief.mean, exp_value)
    end

    ief
end


"Expected ief of a population with given age."
function expected_ief_factor(age, ief, pars)
    t = min(pars.ief_pre_n_steps, floor(Int, age / pars.t_repr_cycle))
    
    t == 0 ? 1.0 : ief.mean[t]
end


"Sample an ief value after transmission from a population with a given age."
function transmitted_ief_factor(age, ief, pars)
    t = min(pars.ief_pre_n_steps, floor(Int, age / pars.t_repr_cycle))

    t_ief = t == 0 ? 1.0 : draw(ief.fitness[t])

    t_ief
end

end
