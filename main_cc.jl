include("main_util.jl")
include("cov_city.jl")
include("agab_sample.jl")
include("analysis_cc.jl")

using Random


function setup_logs()
    file = open("data.tsv", "w")

    print_header(file, Data)

    file
end


function run(model, pars, log_freq, log_file = nothing)
    data = observe(Data, model.world, 0, pars)
    for i in 1:pars.n_steps
        step!(model, pars)
        if model.time % pars.obs_freq == 0
            data = observe(Data, model.world, i, pars)
            ticker(model, data)
        end
        if model.time % log_freq == 0
            if log_file != nothing
                log_results(log_file, data)
            end
        end
    end
end


const allpars, args = load_parameters(ARGS, AllParams, cmdl = ( 
    ["--log-freq"],
    Dict(:help => "set time steps between log calls", :default => 23*60, :arg_type => Int)))
    
const pars = allpars[1]

Random.seed!(pars.seed)

const model = setup_model(pars)
const log_freq = args[:log_freq]
const log_file = setup_logs()


if !isinteractive()
    @time run(model, pars, log_freq, log_file)
end
