function add_to_load_path!(paths...)
    for path in paths
        if ! (path in LOAD_PATH)
            push!(LOAD_PATH, path)
        end
    end
end


using ArgParse
using YAML

add_to_load_path!(joinpath(@__DIR__, "lib"))

using ParamUtils


function load_parameters(argv, partypes...; cmdl = nothing, override = nothing)
	arg_settings = ArgParseSettings("run simulation", autofix_names=true)

	@add_arg_table! arg_settings begin
		"--par-file", "-p"
            help = "parameter file"
            default = ""
        "--patch"
            help = "allow incomplete parameter files"
            action = :store_true
        "--par-out-file", "-P"
			help = "file name for parameter output"
			default = "parameters.run.yaml"
	end

    if cmdl != nothing
        add_arg_table!(arg_settings, cmdl...)
    end

    # setup command line arguments with docs 
    
	add_arg_group!(arg_settings, "Simulation Parameters")
    for ptype in partypes
        fields_as_args!(arg_settings, ptype)
    end

    # parse command line
	args = parse_args(argv, arg_settings, as_symbols=true)

    # read parameters from file if provided or set to default
    # returns a tuple!
    par_objects = load_parameters_from_file(args[:par_file], args[:patch], partypes...)

    # override values that were provided as arguments
    if override != nothing
        override_pars_cmdl!(override, par_objects...)
    end
    # override values that were provided on command line
    override_pars_cmdl!(args, par_objects...)

    # keep a record of parameters used 
    save_parameters_to_file(args[:par_out_file], par_objects...)

    par_objects, args
end


function save_parameters_to_file(fname, pars...)
    dict = pars_to_dict(pars...)
    
    YAML.write_file(fname, dict)
end


function load_parameters_from_file(fname, allow_incomplete, partypes...)
    DT = Dict{Symbol, Any}
    yaml = fname == "" ? DT() : YAML.load_file(fname, dicttype=DT)

    pars_from_dict(yaml, partypes..., require_all_fields = !allow_incomplete)
end



