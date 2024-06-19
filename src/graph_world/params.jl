using Parameters


p_to_r(p, t) = -log(1-p)/t

"simulation parameters"
@with_kw mutable struct Params
    "number of nodes (agents)"
    n_nodes :: Int = 5000
    "mean #connections per node"
    mean_k :: Float64 = 15.0

    "initial number of infected individuals"
    n_infected :: Int = 10

    #p_inf_base      :: Float64          = 0.001
    #"probability to become infected after exposure (per state)"
    #p_inf           :: Vector{Float64}  = [1.0, 0.0, 1.0, 1.0]
    #"probability (per time step) to recover"
    #p_rec           :: Float64          = 1.0 / (7*24*4)

    r_inf_base      :: Float64          = p_to_r(0.001, 1)
    "probability to become infected after exposure (per state)"
    r_inf           :: Vector{Float64}  = [1.0, 0.0, 1.0, 1.0]
    "probability (per time step) to recover"
    r_rec           :: Float64          = p_to_r(1.0 / (7*24*4), 1)
    
    seed :: Int = 42
    n_steps :: Int = 5000
end
