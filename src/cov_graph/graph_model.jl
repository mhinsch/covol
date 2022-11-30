using EnumX
using Parameters
using Distributions
using Erdos


mutable struct Agent
    virus :: Virus
    status :: Immune
    contacts :: Vector{Agent}
end

Agent() = Agent(Virus(), Immune(), [])


function connect!(ag1, ag2)
    push!(ag1.contacts, ag2)
    push!(ag2.contacts, ag1)
end


mutable struct World
    pop :: Vector{Agent}
    ief :: IEF
end


function setup(pars)
    graph = erdos_renyi(pars.n_nodes, pars.mean_k/pars.n_nodes)

    agents = [Agent() for i in 1:pars.n_nodes]

    for e in edges(graph)
        connect!(agents[src(e)], agents[dst(e)])
    end

    World(agents, setup_ief(pars))
end


function update!(model, pars)
    for a in model.pop
        disease!(a, model, pars)
    end

    # avoid order effects on interaction
    shuffle!(model.pop)

    for a in model.pop
        if a.immune.status == IStatus.infected
            for c in a.contacts
                encounter!(a, c, model.ief, pars)
            end
        end
    end
end

