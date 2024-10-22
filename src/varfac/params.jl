using Parameters

"immunity parameters"
@with_kw mutable struct VarfacParams
    "bl;a"
    match_steep :: Float64		= 3.0 
    "meep"
    match_offs :: Float64		= 0.1
    
    n_antigens :: Int			= 10
    
    "minimum match to count as valid immune response"
    min_match_req :: Float64	= 0.5
    "sigma of distribution of new immunity around antigen"
    immune_dist :: Float64		= 0.001
    "max time without match after which to delete immunity"
    max_imm_age :: Float64		= 4 * 24 * 200
    "initial immune response strength"
    imm_ini_str :: Float64		= 0.05
    "parameter for immune response increase, leads to maximum at 5 days"
    imm_increase :: Float64		= 0.014
    "decay of immune response without challenge"
    imm_decay :: Float64		= 1.0/(4*24*200)
    
    "how probability to heal translates to health"
    health_shape :: Float64		= 0.1
    "minimum health to not feel sick"
    sick_threshold :: Float64	= 0.8
    "max health to stay at home"
    too_sick_threshold :: Float64 = 0.5
    "proportion of health recovered in each time step"
    speed_recov :: Float64		= 0.01
    "proportion of health lost while getting sick"
    speed_sick :: Float64		= 0.015
    
    heal_steep :: Float64		= 3.0
    heal_offs :: Float64		= 0.1
    max_heal_prob :: Float64	= 1.0
    
    mut_steep :: Float64		= 3.0
    mut_offs :: Float64			= 0.1
    max_prob_mut :: Float64		= 0.1
    base_prob_mut :: Float64	= 0.01
    mutate_dist :: Float64		= 0.1
    mut_rate :: Float64 		= 3.0
end
    
