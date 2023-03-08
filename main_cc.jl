include("main_util.jl")
include("cov_city.jl")
include("analysis_cc.jl")

using Random


function setup_logs()
    file = open("data.tsv", "w")

    print_header(file, Data)

    file
end


function run(model, pars, log_freq, log_file = nothing)
    for i in 1:pars.n_steps
        step!(model, pars)
        if (i-1) % log_freq == 0
            data = observe(Data, model.world)
            ticker(model, data)
            if log_file != nothing
                log_results(log_file, data)
            end
        end
    end
end


const (pars,), args = load_parameters(ARGS, (AllParams,), 
    ["--log-freq"],
    Dict(:help => "set time steps between log calls", :default => 1, :arg_type => Int))

Random.seed!(pars.seed)

const model = setup_model(pars)
const log_freq = args[:log_freq]
const log_file = setup_logs()


if !isinteractive()
    @time run(model, pars, log_freq, log_file)
end
