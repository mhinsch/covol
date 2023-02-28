module DailySchedule

export SchedItem, trigger!, DaySched, FlexibleDaySched, Schedule, apply_day_schedule!, apply_schedule!

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
function trigger!(agent, world, pars, item::SchedItem, time)
    if isempty(item.probs)
        return
    end
    r = rand()
    sel = findfirst(>(r), item.probs)
    if sel == nothing 
        return
    end

    item.transs[sel](agent, world, pars)
    nothing
end

"Activate an activity in `item`."
function trigger!(agent, world, pars, decision, t)
    decision(agent, world, pars, t)
    nothing
end

"A daily schedule, consisting of a list of time points and associated schedule items."
const DaySched = Vector{Pair{Int, SchedItem}}

const FlexibleDaySched = Vector{Pair{Int, Function}}

"A full weekly schedule indexed by day and agent state."
mutable struct Schedule{DSCHED}
    # day x state
    at :: Matrix{DSCHED}
end

"Allocate a schedule for 7 days and a given number of potential states."
function Schedule{DSCHED}(n_activities::Int) where {DSCHED} 
    sched = [ DSCHED() for day in 1:7, activ in 1:n_activities ]
    Schedule(sched)
end 

"Allocate a schedule for 7 days and a given number of potential states."
function Schedule(n_activities::Int)
    Schedule{DaySched}(n_activities)
end 


"Apply the last schedule item in `sched` that has a time point earlier than `time`."
function apply_day_schedule!(agent, world, pars, sched, time)
    it_idx = 0
    for item in sched
        if item[1] > time
        	break
    	end
    	it_idx += 1
    end

    if it_idx == 0
        return
    end

    # we want the last one with lower time, so subtract 1
    t, item = sched[it_idx]

    trigger!(agent, world, pars, item, time)
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
