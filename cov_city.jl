using CompositeStructs

include("main_util.jl")

add_to_load_path!(joinpath(@__DIR__, "src/basic_ief"))

include("src/util.jl")
include("src/ief_infection.jl")
include("src/agab/antigen_antibody.jl")
include("src/agab/immune.jl")
include("src/agab/params.jl")
include("src/agief_virus.jl")
include("src/agief_disease.jl")
include("src/cov_city/agents.jl")
include("src/cov_city/model.jl")
include("src/cov_city/setup.jl")
include("src/cov_city/params.jl")
include("src/cov_city/update.jl")
include("src/cov_city/activity.jl")


@composite @kwdef mutable struct AllParams
    Params...
    IEFParams...
    AgabParams...
end
