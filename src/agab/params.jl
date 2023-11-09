using Parameters

"immunity parameters"
@with_kw mutable struct AgabParams
    # data type
    "number of elements in an antibody"
    n_antibodies :: Int = 2
    "number of elements in an antigen"
    n_antigens :: Int = 5
    "numerical range of antigen/antibody values"
    max_antigen :: Int = 100
    
    # virus dynamics
    "mutation probability for antigens"
    pmut_antigens :: Float64 = 0.001
    "mutation step size for antigens"
    dmut_antigens :: Int = 100
    
    # infection
    "stochastic difference between antigen and new antibody"
    stoch_imm :: Int = 5
    "initial strength value of newly acquired immunity"
    ini_imm_strength :: Float64 = 0.1
    
    # immune system dynamics
    "minimum match required for immune response to be considered valid"
    req_match :: Float64 = 0.66
    "max # of antibodies per agent"
    max_n_immune :: Int = 20
    "immunity increase during infection per time step (factor)"
    inc_imm :: Float64 = 2.0^(0.5/(4*24)) # doubles in two days
    "immunity decrease without infection per time step (factor)"
    dec_imm :: Float64 = 0.5^(1.0/(4*24*200)) # halves in 200 days
    "min match needed for immune system to increase immunity"
    inc_imm_threshold :: Float64 = 0.2
    "immune strength below which to delete immunity"
    del_imm_threshold :: Float64 = 0.05
end
    
