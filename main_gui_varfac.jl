using Random
using Dates

include("main_util.jl")
include("src/varfac_city_model.jl")
include("analysis_cc_varfac.jl")
include("varfac_sample.jl")

using GLMakie

include("gui_helpers.jl")


function main(par_overrides...)
    args = copy(ARGS)

    for pov in par_overrides
        push!(args, string(pov))
    end

    # need to do that first, otherwise it blocks the GUI
    (pars,), args = load_parameters(args, AllParams, cmdl = (
        ["--gui-scale"], 
        Dict(:help => "set gui scale", :default => 1.0, :arg_type => Float64)))

    Random.seed!(pars.seed)

    model = setup_model(pars)
#    logfile = setupLogging(simPars)

    GLMakie.activate!()
    fig = Figure(size=(1600,900))
    display(GLMakie.Screen(), fig)
    
    #obs_hamdists, ax_hamdists = create_barplot(fig[2,1][1,1], "gene distances")
    obs_hamhists, ax_hamhists = create_heatmap(fig[1,1])
    
    obs_exp, ax_exp = create_series(fig[1,2][1,1], ["mean experience", "max experience", "alarm"])
    obs_sick, ax_sick = create_series(fig[1,2][1,2], ["sick", "infected"])
    obs_health, ax_health = create_barplot(fig[1,2][2,1], "health")
    obs_tenure, ax_tenure = create_barplot(fig[1,2][2,2], "tenure")
    
    obs_nimm, ax_nimm = create_barplot(fig[1,2][3,1], "#immune")
    obs_nvir, ax_nvir = create_barplot(fig[1,2][3,2], "variants")
    obs_immune, ax_immune = create_histogram(fig[1,2][4,1], "immunity", normalization=:pdf)
    obs_mean_imm, ax_mean_imm = create_series(fig[1,2][4,2], ["cross", "self"])
    
    runbutton = Button(fig[2,2][1,1]; label = "run", tellwidth = false)    
    pause = Observable(false)
    on(runbutton.clicks) do clicks; pause[] = !pause[]; end
    quitbutton = Button(fig[2,2][1,2]; label = "quit", tellwidth = false)    
    goon = Observable(true)
    on(quitbutton.clicks) do clicks; goon[]=false; end
    
    obs_year = Observable("")
    Label(fig[2,1][1,1], obs_year, tellwidth=false, fontsize=25)
    
    
    cur_step = 0
    #a_idx = findfirst(infected, model.world.pop)
    #ancestor = model.world.pop[a_idx].viruses[1].phenotype
#    time = Rational(simPars.startTime)
    while goon[]

        if !pause[] #&& time <= simPars.finishTime
            for s in 1:1#steps_per_frame
                step!(model, pars)
                cur_step += 1
                println(model.time)
                if model.time % pars.obs_freq == 0
                    popsize = length(model.world.pop)
                    
                    data = observe(Data, model.world, model.time, pars)
                    #log_results(logfile, data)
                    
                    # add values to graph objects
                    add_series_point!(obs_exp[][1], data.exp.mean)
                    add_series_point!(obs_exp[][2], data.exp.max)
                    add_series_point!(obs_exp[][3], model.world.alarm)
                    add_series_point!(obs_sick[][1], data.n_sick.n/popsize)
                    add_series_point!(obs_sick[][2], data.n_inf.n/popsize)
                    
                    #setto!(obs_hamdists[], data.hamming.bins/1000)
                    append!(obs_hamhists[3][], data.hamming.bins)
                    append!(obs_hamhists[1][], [i * 0.01 for i in 1:length(data.hamming.bins)])
                    append!(obs_hamhists[2][], repeat([cur_step], length(data.hamming.bins)))
                    
                    setto!(obs_nvir[], data.n_virus.bins)
                    setto!(obs_health[], data.health.bins/popsize)
                    setto!(obs_tenure[], data.duration.bins/popsize)
                    setto!(obs_nimm[], data.n_imm.bins/popsize)
                    imm, imm_self = sample_immunity(model.world.pop, 1000, pars)
                    setto!(obs_immune[], imm)
                    add_series_point!(obs_mean_imm[][1], mean(imm))
                    add_series_point!(obs_mean_imm[][2], mean(imm_self))
                    #add_value!(graph_rec, data.n_rec.n/length(model.world.pop))
                    #set_data!(graph_n_imm, data.n_imm.bins, minm=0.0)
                    #add_value!(graph_n_imm_max, data.n_imm.max)
                    #add_value!(graph_ief_mn, data.ief.mean)
                    #add_value!(graph_ief_mx, data.ief.max)
                end
            end
        else # if pause[]
            sleep(0.001)
        end

        #println(data.n_inf.n, " ", data.n_inf_houses.n)#, " ", 1.0/ft)
        if model.time >= 23 * 60 - pars.timestep
            #vir_genes, dist1, dist2 = sample_virus_genes(model.world.pop, ancestor)
            #dist1 ./= pars.max_antigen
            #dist2 ./= pars.max_antigen
        end
        
        notify(obs_exp)
        autolimits!(ax_exp)
        notify(obs_sick)
        autolimits!(ax_sick)
        notify(obs_hamhists[3])
        autolimits!(ax_hamhists)
        notify(obs_nvir)
        autolimits!(ax_nvir)
        notify(obs_health)
        autolimits!(ax_health)
        notify(obs_tenure)
        autolimits!(ax_tenure)
        notify(obs_nimm)
        autolimits!(ax_nimm)
        notify(obs_immune)
        autolimits!(ax_immune)
        notify(obs_mean_imm)
        autolimits!(ax_mean_imm)
        
        text_int = (model.world.isolation ? "ISOLATION\n" : "\n") *
            (model.world.require_masks ? "MASKS\n" : "\n") *
            (model.world.lockdown ? "LOCKDOWN\n" : "\n")
            
        date = Date(2020, 1, 5) + Week(model.week) + Day(model.day)
        obs_year[] = "$(dayabbr(date)), $(date) $(model.time/60)" * "\n" * text_int
    end

#    close(logfile)
end

if ! isinteractive()
    main()
end
