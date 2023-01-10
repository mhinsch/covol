include("main_util.jl")
include("cov_graph.jl")
include("analysis_cg.jl")

using Random

function setup_logs()
    file = open("data.tsv", "w")

    print_header(file, Data)

    file
end

function run(model, pars, iefpars, log_file = nothing)
    for i in 1:pars.n_steps
        step!(model, pars, iefpars)
        data = observe(Data, model.world, pars, iefpars)
        #ticker(model, i, data)
        if log_file != nothing
            log_results(log_file, data)
        end
    end
end


const (pars, iefpars), args = load_parameters(ARGS, (Params, IEFParams))

Random.seed!(pars.seed)

const model = setup_model(pars, iefpars)


if !isinteractive()
    const f = setup_logs()
    @time run(model, pars, iefpars, f)
    close(f)
end
