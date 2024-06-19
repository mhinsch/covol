@kwdef struct IEFAgent

    "current health"
    health 		:: Float64			= 1.0
    "immune status + history"
    immune_system:: ImmuneSystem	= ImmuneSystem()
    "virus population"
    virus 		:: AGIEFVirus		= AGIEFVirus()
    immune_strength :: Float64		= 1.0
    # might not be needed / part of immune status
    "prior physiological risk"
    risk 		:: Float64			= 0.0
    
end



