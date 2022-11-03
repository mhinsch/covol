using Parameters

@with_kw mutable struct Params
    x_size          :: Int              = 100
    y_size          :: Int              = 100
    n_schools       :: Int              = 50
    n_hospitals     :: Int              = 50
    n_smarkets      :: Int              = 50
    n_commercial    :: Int              = 50
    n_leisure       :: Int              = 50

    n_transport     :: Int              = 100
    n_cars          :: Int              = 5

    n_agents        :: Int              = 10000

    walk_dist       :: Float64          = 3
    car_cap         :: Int              = 20

    p_encounter     :: Float64          = 0.1
    p_expose        :: Float64          = 0.1
    p_inf           :: Vector{Float64}  = [0.1, 0.1, 0.1, 0.1]

    # time step in minutes
    timestep        :: Int              = 15
end
