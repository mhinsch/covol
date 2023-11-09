include("main_util.jl")
include("cov_city.jl")

const (pars,), args = load_parameters(ARGS, (AllParams,)) 

println("#houses: ", n_houses(pars))
println("#agents: ", pop_size(pars))
println("#children: ", n_children(pars))
println("#schools: ", n_schools(pars))
println("#commercial: ", n_commercial(pars))
println("#residential: ", n_residential(pars))
