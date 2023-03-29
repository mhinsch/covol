include("main_util.jl")
include("cov_graph.jl")
include("analysis_cg.jl")

using Random

function setup_logs()
    file = open("data.tsv", "w")

    print_header(file, Data)

    file
end


function run(model, pars, obs_freq, log_freq, log_file = nothing)
    data = observe(Data, model.world, pars, 0)
    for i in 1:pars.n_steps
        step!(model, pars)
        if i % obs_freq == 0
            data = observe(Data, model.world, pars, i)
            ticker(model, i, data)
        end
        if i % log_freq == 0
            if log_file != nothing
                log_results(log_file, data)
            end
        end
    end
end


const (pars,), args = load_parameters(ARGS, (AllParams,), 
    ["--log-freq"],
    Dict(:help => "set time steps between log calls", :default => 100, :arg_type => Int),
    ["--obs-freq"],
    Dict(:help => "set time steps between model observations", :default => 100, :arg_type => Int))

Random.seed!(pars.seed)

const model = setup_model(pars)


if !isinteractive()
    const log_freq = args[:log_freq]
    const obs_freq = args[:obs_freq]
    const f = setup_logs()
    @time run(model, pars, obs_freq, log_freq, f)
    close(f)
end
