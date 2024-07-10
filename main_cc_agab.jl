include("main_util.jl")

add_to_load_path!(joinpath(@__DIR__, "src/basic_ief"))


include("src/agief_city_model.jl")
include("agab_sample.jl")
include("analysis_cc.jl")

include("main.jl")

if !isinteractive()
    @time run(model, pars, log_freq, log_file)
end
