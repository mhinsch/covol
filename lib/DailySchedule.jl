module DailySchedule

export SchedItem, trigger!, DaySched, Schedule, apply_day_schedule!, apply_schedule!

"One schedule item with a list of activities and weights associated with them."
struct SchedItem
    # probabilities (cumsum)
    probs :: Vector{Float64}
    # transitions
    transs :: Vector{Function}
end

"Create a SchedItem from a list of pairs probability => activity."
function SchedItem(args...)
    p = Float64[]
    t = Function[]

    for a in args
        push!(p, a[1])
        push!(t, a[2])
    end

    SchedItem(cumsum(p), t)
end

"Activate an activity in `item`."
function trigger!(agent, world, pars, item)
    r = rand()
    sel = findfirst(>(r), item.probs)
    if sel == nothing 
        return
    end

    item.transs[sel](agent, world, pars)
end

"A daily schedule, consisting of a list of time points and associated schedule items."
const DaySched = Vector{Pair{Int, SchedItem}}

"A full weekly schedule indexed by day and agent state."
mutable struct Schedule
    # day x state
    at :: Matrix{DaySched}
end

"Allocate a schedule for 7 days and a given number of potential states."
function Schedule(n_activities::Int)
    sched = [ DaySched() for day in 1:7, activ in 1:n_activities ]
    Schedule(sched)
end 

"Apply the last schedule item in `sched` that has a time point earlier than `time`."
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

"Apply a week schedule at a given day and time."
function apply_schedule!(agent, world, pars, schedule, day, state, time)
    day_sched = schedule.at[day, state]

    if isempty(day_sched)
        return
    end

    apply_day_schedule!(agent, world, pars, day_sched, time)
end


end
