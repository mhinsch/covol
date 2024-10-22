include("main_util.jl")
include("src/varfac_city_model.jl")
include("analysis_cc_varfac.jl")
include("varfac_sample.jl")

include("main.jl")

if !isinteractive()
    @time run(model, pars, log_freq, log_file)
end
