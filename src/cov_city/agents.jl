using EnumX
using Distributions
using CompositeStructs

using DailySchedule
using IEFModel

@enumx PlaceT residential=1 school hospital supermarket work leisure transport nowhere

struct Pos
    x :: Int
    y :: Int
end

mutable struct PlaceG{AG}
    type :: PlaceT.T
    pos :: Pos
    present :: Vector{AG}
    n_infections :: Int
end

PlaceG{AG}(t, p) where {AG} = PlaceG{AG}(t, p, [], 0)

isnowhere(place) = place.type == PlaceT.nowhere

add_agent!(place, agent) = push!(place.present, agent)
remove_agent!(place, agent) = remove_unsorted!(place.present, agent)


@enumx Activity home=1 prepare_work working prepare_leisure leisure travel stay_home none


@kwdef struct CityAgent{AGENT}
    home 		:: PlaceG{AGENT}
    work 		:: PlaceG{AGENT}
    family 		:: Vector{AGENT}	= []
    friends 	:: Vector{AGENT}	= []
#    shops 		:: Vector{PlaceG{AGENT}} = []
    fun 		:: Vector{PlaceG{AGENT}} = []
    
    schedule 	:: Schedule
    activity	:: Activity.T		= Activity.home
    loc 		:: PlaceG{AGENT}	= home
    dest 		:: PlaceG{AGENT}	= home
    plan 		:: Activity.T		= Activity.home
    t_next_act	:: Int				= 0
#    "socio economic status"
#    soc_status 	:: Int				= 0
#    age :: Float64
    "tendency to ignore covid experience"
    recklessness :: Float64			= 0.0
    "tendency to refuse official advice"
    obstinacy 	:: Float64			= 0.0
    "seen or experienced Covid"
    cov_experience :: Float64		= 0.0
#    "need to be present at job"
#    job_presence :: Float64
#    "ability to risk job"
#    job_independence :: Float64
end


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


@composite @kwdef mutable struct Agent
    CityAgent{Agent}...
    IEFAgent...
end


Agent(home, work, schedule) = Agent(;home, work, schedule)


const Place = PlaceG{Agent}

const Nowhere = Place(PlaceT.nowhere, Pos(-1, -1), [], 0)

function change_loc!(agent, new_loc)
    if agent.loc != Nowhere
        remove_agent!(agent.loc, agent)
    end
    assign_loc!(agent, new_loc)
end

function assign_loc!(agent, loc)
    agent.loc = loc
    if loc != Nowhere
        add_agent!(loc, agent)
    end
end

mutable struct Transport
    p1 :: Place
    p2 :: Place

    cars :: Vector{Place}
    car_cap :: Int
end


mutable struct World
    # houses arranged spatially
    map :: Matrix{Place}
    # houses by type
    houses :: Vector{Vector{Place}}
    pop :: Vector{Agent}
    transports :: Vector{Transport}
    t_cache :: Matrix{Vector{Transport}}
    schedules :: Vector{Schedule{FlexibleDaySched}}
    ief :: IEF
    
    alarm :: Float64
    isolation :: Bool
    require_masks :: Bool
    lockdown :: Bool
end


mutable struct Model
    world :: World
    # overall week
    week :: Int
    # day of the week
    day :: Int
    # time of day in minutes
    time :: Int
end
