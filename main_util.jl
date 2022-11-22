include("src/util.jl")
include("src/schedule.jl")
include("src/ief.jl")
include("src/agents.jl")
include("src/model.jl")
include("src/setup.jl")
include("src/params.jl")
include("src/update.jl")


function add_to_load_path!(paths...)
    for path in paths
        if ! (path in LOAD_PATH)
            push!(LOAD_PATH, path)
        end
    end
end


using ArgParse
using YAML

add_to_load_path!("lib")

using ParamUtils


function load_parameters(argv, cmdl...)
	arg_settings = ArgParseSettings("run simulation", autofix_names=true)

	@add_arg_table! arg_settings begin
		"--par-file", "-p"
            help = "parameter file"
            default = ""
        "--par-out-file", "-P"
			help = "file name for parameter output"
			default = "parameters.run.yaml"
	end

    if ! isempty(cmdl)
        add_arg_table!(arg_settings, cmdl...)
    end

    # setup command line arguments with docs 
    
	add_arg_group!(arg_settings, "Simulation Parameters")
    fields_as_args!(arg_settings, Params)

    # parse command line
	args = parse_args(argv, arg_settings, as_symbols=true)

    # read parameters from file if provided or set to default
    pars = load_parameters_from_file(args[:par_file])

    # override values that were provided on command line

    override_pars_cmdl!(pars, args)

    # set time dependent seed
#    if simpars.seed == 0
#        simpars.seed = floor(Int, time())
#    end

    # keep a record of parameters used (including seed!)
    save_parameters_to_file(pars, args[:par_out_file])

    pars, args
end


function save_parameters_to_file(pars, fname)
    dict = Dict{Symbol, Any}()

    dict[:Params] = par_to_yaml(pars)
    
    YAML.write_file(fname, dict)
end


function load_parameters_from_file(fname)
    DT = Dict{Symbol, Any}
    yaml = fname == "" ? DT() : YAML.load_file(fname, dicttype=DT)

    par_from_yaml(yaml, Params, "Params") 
end



