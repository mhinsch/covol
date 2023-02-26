using EnumX
using Distributions
using Base: @kwdef

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


@enumx Activity home=1 working leisure shopping hospital travel stay_home none

@kwdef mutable struct Agent
    home 		:: PlaceG{Agent}
    work 		:: PlaceG{Agent}
    family 		:: Vector{Agent}	= []
    friends 	:: Vector{Agent}	= []
#    shops 		:: Vector{PlaceG{Agent}} = []
    fun 		:: Vector{PlaceG{Agent}} = []
    
    schedule 	:: Schedule
    activity	:: Activity.T		= Activity.home
    loc 		:: PlaceG{Agent}	= home
    dest 		:: PlaceG{Agent}	= home
    plan 		:: Activity.T		= Activity.home
#    "socio economic status"
#    soc_status 	:: Int				= 0
#    age :: Float64

    "current health"
    health 		:: Float64			= 1.0
    "immune status + history"
    immune 		:: Immune			= Immune(IStatus.naive)
    "virus population"
    virus 		:: Virus			= Virus()
    # might not be needed / part of immune status
    "prior physiological risk"
    risk 		:: Float64			= 0.0
    
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


Agent(home, work, schedule) = Agent(;home, work, schedule)

infectivity(agent) = agent.virus.e_ief
sick(agent) = agent.immune.status == IStatus.infected
infectious(agent) = agent.immune.status == IStatus.infected
susceptible(agent) = !infectious(agent)

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
    schedules :: Vector{Schedule}
    ief :: IEF
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
