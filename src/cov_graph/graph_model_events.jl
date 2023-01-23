using EnumX
using Parameters
using Distributions
using Erdos: erdos_renyi, edges, src, dst

using MiniEvents


mutable struct Agent
    virus :: Virus
    immune :: Immune
    risk :: Float64
    contacts :: Vector{Agent}
end

Agent() = Agent(Virus(), Immune(), 1.0, [])

infectivity(agent) = agent.virus.e_ief
infected(agent) = agent.immune.status == IStatus.infected
infectious(agent) = infected(agent)
susceptible(agent) = !infected(agent)
recover!(agent) = agent.immune.status = IStatus.recovered

function connect!(ag1, ag2)
    push!(ag1.contacts, ag2)
    push!(ag2.contacts, ag1)
end


mutable struct World
    pop :: Vector{Agent}
    ief :: IEF
end


function initial_infected!(world, pars)
    for i in 1:pars.n_infected
        inf = rand(world.pop)
        inf.immune.status = IStatus.infected
        inf.virus.ief_0 = 1.0
        inf.virus.e_ief = 1.0
    end
end


function setup_model(pars, iefpars)
    graph = erdos_renyi(pars.n_nodes, pars.mean_k/pars.n_nodes)

    agents = [Agent() for i in 1:pars.n_nodes]

    for e in edges(graph)
        connect!(agents[src(e)], agents[dst(e)])
    end

    model = Model(World(agents, IEFModel.setup_ief(iefpars)), pars, iefpars)

    initial_infected!(model.world, pars)

    model
end


function select_weighted(weight_fn, elems)
    weights = [ weight_fn(e) for e in elems ] |> cumsum
    i = searchsortedfirst(weights, rand() * weights[end])
    elems[i]
end


@events agent::Agent begin
    @debug
    @rate(sum(c -> inf_rate(agent, c.virus, @sim().pars), agent.contacts)) ~
        susceptible(agent) => begin
            infect!(agent, 
                select_weighted(c -> inf_rate(agent, c.virus, @sim().pars), agent.contacts).virus,
                @sim().world.ief, @sim().pars, @sim().iefpars)
                
            MiniEvents.scheduled_action!(agent, @sim())
            @r agent agent.contacts
        end
        
    @rate(@sim().pars.r_rec) ~
        infected(agent) => begin
            recover!(agent)
            @r agent agent.contacts
        end
        
      
    @repeat(@sim().iefpars.t_repr_cycle, @sim().iefpars.t_repr_cycle) => begin
            if !infected(agent)
                return
            end
            update_virus!(agent.virus, @sim().world.ief, @sim().iefpars)
            @r agent agent.contacts
        end
end

@simulation Model Agent begin
    world :: World
    pars :: Params
    iefpars :: IEFParams
end
    
    
function MiniEvents.spawn!(model::Model)
    for a in model.world.pop
        spawn!(a, model)
    end
end
