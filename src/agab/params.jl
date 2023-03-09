using Parameters

"immunity parameters"
@with_kw mutable struct AgabParams
    # data type
    "number of elements in an antibody"
    n_antibodies :: Int = 2
    "number of elements in an antigen"
    n_antigens :: Int = 20
    "numerical range of antigen/antibody values"
    max_antigen :: Int = 100
    
    # virus dynamics
    "mutation probability for antigens"
    pmut_antigens :: Float64 = 0.1
    "mutation step size for antigens"
    dmut_antigens :: Int = 5
    
    # infection
    "stochastic difference between antigen and new antibody"
    stoch_imm :: Int = 2
    "initial strength value of newly acquired immunity"
    ini_imm_strength :: Float64 = 0.1
    
    # immune system dynamics
    "immunity increase during infection per time step (factor)"
    inc_imm :: Float64 = 2.0^(0.5/(4*24))
    "immunity decrease without infection per time step (factor)"
    dec_imm :: Float64 = 0.5^(1.0/(4*24*200))
    "min match needed for immune system to increase immunity"
    inc_imm_threshold :: Float64 = 0.2
    "immune strength below which to delete immunity"
    del_imm_threshold :: Float64 = 0.05
    
    # disease dynamics
    "reaction strength required to remove virus"
    rec_threshold :: Float64 = 0.9
end
    
