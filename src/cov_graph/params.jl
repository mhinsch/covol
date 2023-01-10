using Parameters

"simulation parameters"
@with_kw mutable struct Params
    "number of nodes (agents)"
    n_nodes :: Int = 5000
    "mean #connections per node"
    mean_k :: Float64 = 15.0

    "initial number of infected individuals"
    n_infected :: Int = 10

    p_inf_base      :: Float64          = 0.001
    "probability to become infected after exposure (per state)"
    p_inf           :: Vector{Float64}  = [1.0, 0.0, 1.0, 1.0]
    "probability (per time step) to recover"
    p_rec           :: Float64          = 1.0 / (7*24*4)

    seed :: Int = 42
    n_steps :: Int = 5000
end
