@kwdef struct IEFAgent{VIRUS}

    "current health"
    health 		:: Float64			= 1.0
    "immune status + history"
    immune_system:: ImmuneSystem	= ImmuneSystem()
    "virus population"
    virus 		:: VIRUS			= VIRUS()
    immune_strength :: Float64		= 1.0
end



