struct SchedItem
    # probabilities (cumsum)
    probs :: Vector{Float64}
    # transitions
    transs :: Vector{Function}
end

function SchedItem(args...)
    p = Float64[]
    t = Function[]

    for a in args
        push!(p, a[1])
        push!(t, a[2])
    end

    SchedItem(p, t)
end

function trigger!(agent, world, pars, item)
    r = rand()
    sel = findfirst(>(r), item.probs)
    if sel == nothing 
        return
    end

    item.transs[sel](agent, world, pars)
end

# list of (time, item)
const DaySched = Vector{Pair{Int, SchedItem}}

mutable struct Schedule
    # day x state
    at :: Matrix{DaySched}
end

function Schedule(n_activities)
    sched = [ DaySched() for day in 1:7, activ in 1:n_activities ]
    Schedule(sched)
end 


function apply_day_schedule!(agent, world, pars, sched, time)
    it_idx = findfirst(sched) do item
        item[1] > time
    end

    if it_idx == nothing || it_idx == 1
        return
    end

    # we want the last one with lower time, so subtract 1
    t, item = sched[it_idx - 1]

    if isempty(item.probs)
        return
    end

    trigger!(agent, world, pars, item)
end


function apply_schedule!(agent, world, pars, day, time)
    day_sched = agent.schedule.at[day, Int(agent.activity)]

    if isempty(day_sched)
        return
    end

    apply_day_schedule!(agent, world, pars, day_sched, time)
end
