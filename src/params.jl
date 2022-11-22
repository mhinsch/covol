using Parameters

"simulation parameters"
@with_kw mutable struct Params
    "number of steps to run the model"
    n_steps         :: Int              = 24 * 4 * 365
    "randum seed"
    seed            :: Int              = 42

    "number of houses in x direction"
    x_size          :: Int              = 100
    "number of houses in y direction"
    y_size          :: Int              = 100
    "number of schools and nurseries"
    n_schools       :: Int              = 50
    "number of hospitals"
    n_hospitals     :: Int              = 50
    "number of supermarkets"
    n_smarkets      :: Int              = 50
    "number of other commercial buildings (work places)"
    n_commercial    :: Int              = 50
    "number of leisure buildings"
    n_leisure       :: Int              = 50

    "number of transport connections"
    n_transport     :: Int              = 100
    "number of carriages per transport"
    n_cars          :: Int              = 5

    "number of agents"
    n_agents        :: Int              = 10000
    "initial number of infected agents"
    n_infected      :: Int              = 10

    "distance agents are willing to walk to their transport"
    walk_dist       :: Float64          = 3
    "number of passenger per carriage"
    car_cap         :: Int              = 20

    "probability (per time step) for two given agents to encounter each other at a shared location"
    p_encounter     :: Float64          = 0.01
    "probability to become infected after exposure"
    p_inf           :: Vector{Float64}  = [0.05, 0.05, 0.05, 0.05]
    "probability (per time step) to recover"
    p_rec           :: Float64          = 1.0 / (7*24*4)

    "virus population size for ief fitness pre-computation"
    ief_pre_N       :: Int              = 10000
    "ief mutation probability per cycle"
    ief_p_mut       :: Float64          = 10^-6
    "length of genome"
    n_basepairs     :: Int              = 30000
    "mean of normal dist describing fitness effect of ief mutation"
    ief_mut_mu      :: Float64          = 0.9
    "sigma of normal dist describing fitness effect of ief mutation"
    ief_mut_sigma   :: Float64          = 0.1
    "number of time steps to pre-compute ief fitness for"
    ief_pre_n_steps :: Int              = floor(Int, 14 * 24 / 10)
    "number of samples to base fitness calculation on"
    ief_pre_n_samples :: Int            = 10000
    "number of bins in fitness lookup table"
    ief_pre_n_bins  :: Int              = 100
    "time steps per virus reproduction cycle"
    t_repr_cycle    :: Int              = 40

    "length of a time step in minutes"
    timestep        :: Int              = 15
end
