using Parameters

"immunity parameters"
@with_kw mutable struct VarfacParams
    match_steep :: Float64		= 3.0 
    match_offs :: Float64		= 0.1
    
    n_antigens :: Int			= 10
    
    min_match_req :: Float64	= 0.5
    immune_dist :: Float64		= 0.001
    
    heal_steep :: Float64		= 3.0
    heal_offs :: Float64		= 0.1
    max_heal_prob :: Float64	= 1.0
    
    mut_steep :: Float64		= 3.0
    mut_offs :: Float64			= 0.1
    max_prob_mut :: Float64		= 0.1
    mutate_dist :: Float64		= 0.1
end
    
