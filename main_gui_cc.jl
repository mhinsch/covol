using Random
using Dates

using Raylib
using Raylib: rayvector

# make this less annoying
const RL = Raylib

include("main_util.jl")
include("cov_city.jl")
include("analysis_cc.jl")
include("agab_sample.jl")

include("src/cov_city/gui/render.jl")

using SimpleGraph

function main(par_overrides...)
    args = copy(ARGS)

    for pov in par_overrides
        push!(args, string(pov))
    end

    # need to do that first, otherwise it blocks the GUI
    (pars,), args = load_parameters(args, (AllParams,),
        ["--gui-scale"], 
        Dict(:help => "set gui scale", :default => 1.0, :arg_type => Float64))

    Random.seed!(pars.seed)

    model = setup_model(pars)
#    logfile = setupLogging(simPars)

    scale = args[:gui_scale]
    screenWidth = floor(Int, 1600 * scale)
    screenHeight = floor(Int, 900 * scale)

    RL.InitWindow(screenWidth, screenHeight, "Covol 0.1 [city]")
    RL.SetTargetFPS(30)
    camera = RL.RayCamera2D(
        rayvector(10, 10),
        rayvector(0, 0),
        #rayvector(500, 500),
        0,
        scale 
    )

    # create graph objects with colour
    graph_mean_exp = Graph{Float64}(RL.BLUE)
    graph_max_exp = Graph{Float64}(RL.RED)
    graph_alarm = Graph{Float64}(RL.BLACK)
    graph_sick = Graph{Float64}(RL.BLUE)
    graph_inf = Graph{Float64}(RL.RED)
    graph_rec = Graph{Float64}(RL.DARKGREEN)
    graph_n_imm = Graph{Float64}(RL.DARKGREEN)
    #graph_n_imm_max = Graph{Float64}(RL.RED)
    graph_ief_mn = Graph{Float64}(RL.BLACK)
    graph_ief_mx = Graph{Float64}(RL.WHITE)
    
    vir_genes = []
    dist1 = []
    dist2 = []
    a_idx = findfirst(infected, model.world.pop)
    ancestor = model.world.pop[a_idx].virus.antigens
    pause = false
    steps_per_frame = 1
    data = observe(Data, model.world, 0)
#    time = Rational(simPars.startTime)
    while !RL.WindowShouldClose()

        if !pause #&& time <= simPars.finishTime
            for s in 1:steps_per_frame
                step!(model, pars)
                if model.time % pars.obs_freq == 0
                    data = observe(Data, model.world, model.time)
                    #log_results(logfile, data)
                    # add values to graph objects
                    add_value!(graph_mean_exp, data.exp.mean)
                    add_value!(graph_max_exp, data.exp.max)
                    add_value!(graph_alarm, model.world.alarm)
                    add_value!(graph_sick, data.n_sick.n/length(model.world.pop))
                    add_value!(graph_inf, data.n_inf.n/length(model.world.pop))
                    add_value!(graph_rec, data.n_rec.n/length(model.world.pop))
                    set_data!(graph_n_imm, data.n_imm.bins, minm=0.0)
                    #add_value!(graph_n_imm_max, data.n_imm.max)
                    add_value!(graph_ief_mn, data.ief.mean)
                    add_value!(graph_ief_mx, data.ief.max)
                end
            end
            ft = RL.GetFrameTime()
            println(data.n_inf.n, " ", data.n_inf_houses.n, " ", 1.0/ft)
            if model.time >= 23 * 60 - pars.timestep
                vir_genes, dist1, dist2 = sample_virus_genes(model.world.pop, ancestor)
                dist1 ./= pars.max_antigen
                dist2 ./= pars.max_antigen
            end
        end

        if RL.IsKeyPressed(Raylib.KEY_SPACE)
            pause = !pause
            sleep(0.2)
        elseif RL.IsKeyPressed(Raylib.KEY_PERIOD)
            steps_per_frame += 1
        elseif RL.IsKeyPressed(Raylib.KEY_COMMA)
            steps_per_frame = max(1, steps_per_frame-1)
        end

        RL.BeginDrawing()

        RL.ClearBackground(RL.LIGHTGRAY)
        
        RL.BeginMode2D(camera)
        
        drawModel(model, (x=0, y=0), (x=5, y=5))

        RL.EndMode2D()

        # draw graphs
        draw_graph(floor(Int, screenWidth*1/2), 0, 
                   floor(Int, screenWidth/4), floor(Int, screenHeight/2) - 30, 
            [graph_mean_exp, graph_max_exp, graph_alarm],
            single_scale = true, 
            labels = ["mean exp", "max exp", "alarm"],
            fontsize = floor(Int, 15 * scale))
            
        draw_graph(floor(Int, screenWidth*3/4), 0, 
                   floor(Int, screenWidth/4), floor(Int, screenHeight/2) - 30, 
            [graph_inf, graph_rec, graph_sick],
            single_scale = true, 
            labels = ["infected", "immunity", "sick"],
            fontsize = floor(Int, 15 * scale))
            
        draw_graph(floor(Int, screenWidth*1/2), floor(Int, screenHeight/2), 
                   floor(Int, screenWidth/4), floor(Int, screenHeight/2) - 30, 
            [graph_n_imm], #, graph_n_imm_max],
            single_scale = true, 
            labels = ["n imm"], #, "max n imm"],
            fontsize = floor(Int, 15 * scale))
        
        draw_graph(floor(Int, screenWidth*3/4), floor(Int, screenHeight/2), 
                   floor(Int, screenWidth/4), floor(Int, screenHeight/2) - 30, 
            [graph_ief_mn, graph_ief_mx],
            single_scale = true, 
            labels = ["mean ief", "max ief"],
            fontsize = floor(Int, 15 * scale))
        
        if !isempty(vir_genes)
            for i in 0:4
                if i >= length(vir_genes)
                    break
                end
                idx = length(vir_genes)-i                
                genes = vir_genes[idx]
                RL.DrawText(join(genes[1], ".") * "\t" * string(genes[2]) * "\t" * 
                    string(dist1[idx]) * "\t" * string(dist2[idx]), 0,
                    screenHeight - floor(Int, (9-i) * 20 * scale), 
                    floor(Int, 20 * scale), RL.BLACK)
            end
        end
            
        if model.world.isolation
            RL.DrawText("ISOLATE", 0, 
                    screenHeight - floor(Int, 4 * 20 * scale), 
                    floor(Int, 20 * scale), RL.RED)
        end
        if model.world.require_masks
            RL.DrawText("MASKS", 0, 
                    screenHeight - floor(Int, 3 * 20 * scale), 
                    floor(Int, 20 * scale), RL.RED)
        end
        if model.world.lockdown
            RL.DrawText("LOCKDOWN", 0, 
                    screenHeight - floor(Int, 2 * 20 * scale), 
                    floor(Int, 20 * scale), RL.RED)
        end
        
        delta_t = steps_per_frame * pars.timestep
        date = Date(2020, 1, 5) + Week(model.week) + Day(model.day)
        RL.DrawText("+$(delta_t) | $(dayabbr(date)), $(date) $(model.time/60)", 0, 
                    screenHeight - floor(Int, 20 * scale), 
                    floor(Int, 20 * scale), RL.BLACK)

        RL.EndDrawing()
    end

    RL.CloseWindow()

#    close(logfile)
end

if ! isinteractive()
    main()
end
