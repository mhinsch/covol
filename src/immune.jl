using EnumX

# TODO replace with proper model
@enumx IStatus naive = 1 infected symptomatic recovered vaccinated

mutable struct Immune
    status :: IStatus.T
end

Immune() = Immune(IStatus.naive)

