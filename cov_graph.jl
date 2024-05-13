using CompositeStructs


add_to_load_path!(joinpath(@__DIR__, "src/basic_ief"))

include("src/util.jl")
include("src/simple_immune.jl")
include("src/simple_disease.jl")
include("src/ief_infection.jl")
include("src/ief_virus.jl")
include("src/cov_graph/params.jl")
#include("src/cov_graph/graph_model_events.jl")
include("src/cov_graph/graph_model.jl")


@composite @kwdef mutable struct AllParams
    Params...
    IEFParams...
end
