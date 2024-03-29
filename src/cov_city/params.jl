using Parameters

"simulation parameters"
@with_kw mutable struct Params
    "number of steps to run the model"
    n_steps         :: Int              = 24 * 4 * 365
    "randum seed"
    seed            :: Int              = 42
   
    obs_freq		:: Int				= 60
    
    "length of a time step in minutes"
    timestep        :: Int              = 15
    
    "read population from file"
    pop_file		:: String			= ""
    houses_file		:: String			= ""
    
    "number of houses in x direction"
    x_size          :: Int              = 100
    "number of houses in y direction"
    y_size          :: Int              = 100
    "ratio of number of inhabitants to number of dwellings"
    ratio_pop_dwellings :: Float64		= 2.5
    "proportion of children that go to school/nursery in population"
    prop_children	:: Float64			= 0.17
    "school/nursery class sizes"
    class_size		:: Int              = 30
    "people per workplace"
    workplace_size	:: Int				= 10
    "number of hospitals"
    n_hospitals     :: Int              = 50
    "number of supermarkets"
    n_smarkets      :: Int              = 50
    "number of leisure buildings"
    prop_leisure       :: Float64       = 0.005
   
    "mean number of friends per agent" 
    mean_n_friends		:: Float64		= 15
    "number of different leisure places people go to"
    n_leisure_pp		:: Int			= 5
   
    "number of transport connections"
    n_transport     :: Int              = 100
    "number of carriages per transport"
    n_cars          :: Int              = 5

    "initial number of infected agents"
    n_infected      :: Int              = 10
    mixed_ini_inf	:: Bool				= false

    "distance agents are willing to walk to their transport"
    walk_dist       :: Float64          = 3
    "number of passenger per carriage"
    car_cap         :: Int              = 20

    "probability (per time step) for two given agents to encounter each other at a shared location"
    p_encounter     :: Float64          = 0.01
    p_inf_base      :: Float64          = 0.05
#    "probability to become infected after exposure"
#    p_inf           :: Vector{Float64}  = [1.0, 0.0, 0.0, 0.2, 0.2]
    "probability (per time step) to become symptomatic"
    p_sympt         :: Float64          = 1.0 / (2*24*4)
    "probability (per time step) to recover"
    p_rec           :: Float64          = 1.0 / (7*24*4)
    
    # disease dynamics
    "reaction strength required to remove virus"
    rec_threshold :: Float64 = 0.9
 
    "probability to do a leisure activity on a weekend day" 
    p_leisure_we	:: Float64			= 0.25
    "time a leisure activity takes"
    t_leisure		:: Vector{Int}		= [60, 300]
  
    "initial range of recklessness"
    reck_range		:: Vector{Float64}	= [0.0, 1.0]
    "initial range of obstinacy"
    obst_range		:: Vector{Float64}	= [0.0, 1.0]
    "proportion of at risk population"
    p_at_risk		:: Float64			= 0.05
    "initial range of risk"
    risk_range		:: Vector{Float64}	= [0.0, 1.0]
    
    "time steps between experience updates"
    dt_exp			:: Int				= 60 * 24 - 1 # once per day
    "decay in covid experience if noone is sick"
    exp_decay		:: Float64			= 0.05
    "weight of own covid experience"
    exp_self_weight	:: Float64			= 0.2
    "weight of family covid experience"
    exp_family_weight :: Float64		= 0.1
    "weight of friends' covid experience"
    exp_friends_weight :: Float64		= 0.05
    "how cautious to be about going to work"
    caution_work 	:: Float64			= 1.0
    "how cautious to be about taking public transport"
    caution_pub_transp :: Float64		= 2.0
    "how cautious to be about going to leisure activities"
    caution_leisure	:: Float64			= 1.0
    
    alarm_inc_thresh :: Float64			= 0.1
    alarm_dec_thresh :: Float64			= 0.1
    alarm_inc_d		:: Float64			= 0.1
    alarm_dec_d		:: Float64			= 0.1
    isolate_trigger :: Float64			= 0.1
    masks_trigger	:: Float64			= 0.1
    masks_effect	:: Float64			= 0.5
    lockdown_trigger:: Float64			= 0.3
    lockdown_sev	:: Int				= 1
    policy_check_dt :: Int				= 60 * 24 - 1
end
