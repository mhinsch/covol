using Parameters

"simulation parameters"
@with_kw mutable struct Params
    n_nodes :: Int = 5000
    mean_k :: Float64 = 15.0
end
