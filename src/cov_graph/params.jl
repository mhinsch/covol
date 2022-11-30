using Parameters

"simulation parameters"
@with_kw mutable struct Params
    n_nodes :: Int = 5000
    mean_k :: Float64 = 15.0

    n_infected :: Int = 10

    "probability to become infected after exposure"
    p_inf           :: Vector{Float64}  = [0.05, 0.05, 0.05, 0.05]
    "probability (per time step) to recover"
    p_rec           :: Float64          = 1.0 / (7*24*4)

    seed :: Int = 42
    n_steps :: Int = 1000
end
