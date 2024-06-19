using EnumX

using DailySchedule


@enumx PlaceT residential=1 school hospital supermarket work leisure transport nowhere


struct Pos
    x :: Int
    y :: Int
end

mutable struct PlaceG{AGENT}
    type :: PlaceT.T
    pos :: Pos
    present :: Vector{AGENT}
    n_infections :: Int
end

PlaceG{AGENT}(t, p) where {AGENT} = PlaceG{AGENT}(t, p, [], 0)

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

mutable struct TransportG{PLACE}
    p1 :: PLACE
    p2 :: PLACE

    cars :: Vector{PLACE}
    car_cap :: Int
end


mutable struct World{PLACE, TRANSPORT, AGENT}
    # houses arranged spatially
    map :: Matrix{PLACE}
    # houses by type
    houses :: Vector{Vector{PLACE}}
    pop :: Vector{AGENT}
    transports :: Vector{TRANSPORT}
    t_cache :: Matrix{Vector{TRANSPORT}}
    schedules :: Vector{Schedule{FlexibleDaySched}}
    
    alarm :: Float64
    isolation :: Bool
    require_masks :: Bool
    lockdown :: Bool
end


get_rand_work(world) = rand(world.houses[Int(PlaceT.work)])

get_rand_school(world) = rand(world.houses[Int(PlaceT.school)])

get_rand_schedule(world) = rand(world.schedules)

