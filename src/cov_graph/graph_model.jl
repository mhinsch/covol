using EnumX
using Parameters
using Distributions
using Erdos: erdos_renyi, edges, src, dst


mutable struct Agent
    virus :: Virus
    immune :: Immune
    risk :: Float64
    contacts :: Vector{Agent}
end

Agent() = Agent(Virus(), Immune(), 1.0, [])

infectivity(agent) = agent.virus.e_ief
infectious(agent) = agent.immune.status == IStatus.infected
susceptible(agent) = !infectious(agent)

function connect!(ag1, ag2)
    push!(ag1.contacts, ag2)
    push!(ag2.contacts, ag1)
end


mutable struct World
    pop :: Vector{Agent}
    ief :: IEF
end

mutable struct Model
    world :: World
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

    model = Model(World(agents, IEFModel.setup_ief(iefpars)))

    initial_infected!(model.world, pars)

    model
end


function step!(model, pars, iefpars)
    for a in model.world.pop
        disease!(a, model.world, pars, iefpars)
    end

    # avoid order effects on interaction
    spop = shuffle(model.world.pop)

    for a in spop
        if a.immune.status == IStatus.infected
            for c in a.contacts
                if c.immune.status != IStatus.infected
                    encounter!(a, c, model.world.ief, pars, iefpars)
                end
            end
        end
    end
end

