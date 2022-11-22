using EnumX
using Parameters
using Distributions

@enumx PlaceT residential=1 school hospital supermarket work leisure transport nowhere

struct Pos
    x :: Int
    y :: Int
end

mutable struct PlaceG{AG}
    type :: PlaceT.T
    pos :: Pos
    present :: Vector{AG}
end

isnowhere(place) = place.type == PlaceT.nowhere

add_agent!(place, agent) = push!(place.present, agent)
remove_agent!(place, agent) = remove_unsorted!(place.present, agent)


# TODO replace with proper model
@enumx IStatus naive = 1 infected recovered vaccinated

mutable struct Immune
    status :: IStatus.T
end


# TODO replace with proper model
mutable struct Virus
    # time since infection
    age :: Int
    # inter host fitness of infecting strain
    ief :: Float64
    # expected IEF (needed for inf prob)
    e_ief :: Float64
end

Virus() = Virus(0, 0.0, 0.0)

function expected_ief(virus, ief, pars)
    t = min(pars.ief_pre_n_steps, floor(Int, virus.age / pars.t_repr_cycle))
    
    virus.ief * (t == 0 ? 1.0 : ief.mean[t])
end

# sample an ief value *after* transmission
function transmitted_ief(virus, ief, pars)
    t = min(pars.ief_pre_n_steps, floor(Int, virus.age / pars.t_repr_cycle))

    t_ief = t == 0 ? 1.0 : draw(ief.fitness[t])

    virus.ief * t_ief
end


@enumx Activity home=1 working leisure shopping hospital travel none

@with_kw mutable struct Agent
    # admin, possibly subsume in others
    activity :: Activity.T
    loc :: PlaceG{Agent}
    dest :: PlaceG{Agent}
    plan :: Activity.T
    "socio economic status"
    soc_status :: Int
    age :: Float64

    "current health"
    health :: Float64
    "immune status + history"
    immune :: Immune
    "virus population"
    virus :: Virus
    # might not be needed / part of immune status
    "prior physiological risk"
    risk :: Float64

    "tendency to refuse official advice"
    obstinacy :: Float64
    "seen or experienced Covid"
    cov_experience :: Float64
    "need to be present at job"
    job_presence :: Float64
    "ability to risk job"
    job_independence :: Float64

    family :: Vector{Agent}
    friends :: Vector{Agent}
    home :: PlaceG{Agent}
    work :: PlaceG{Agent}
    shops :: Vector{PlaceG{Agent}}
    fun :: Vector{PlaceG{Agent}}

    schedule :: Schedule
end


Agent(h, w, schedule) = Agent(Activity.home, h, h, Activity.home, 0, 30, 
    1.0, Immune(IStatus.naive), Virus(), rand(), 
    rand(), 0.0, 0.0, 0.5, 
    [], [], h, w, [], [], 
    schedule)

infectivity(agent) = agent.virus.e_ief
infectious(agent) = agent.immune.status == IStatus.infected
susceptible(agent) = !infectious(agent)

const Place = PlaceG{Agent}

const Nowhere = Place(PlaceT.nowhere, Pos(-1, -1), [])

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


struct IEF
    fitness :: Vector{Lookup{Float64, Int}}
    mean :: Vector{Float64}
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
