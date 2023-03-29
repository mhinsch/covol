using CompositeStructs


add_to_load_path!(joinpath(@__DIR__, "src/simple_ief"))

include("src/util.jl")
include("src/immune.jl")
include("src/disease.jl")
include("src/infection.jl")
include("src/virus.jl")
include("src/cov_graph/params.jl")
include("src/cov_graph/graph_model.jl")


@composite @kwdef mutable struct AllParams
    Params...
    IEFParams...
end
