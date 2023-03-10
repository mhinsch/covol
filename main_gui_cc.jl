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
    graph_ief_mn = Graph{Float64}(RL.BLACK)
    graph_ief_mx = Graph{Float64}(RL.WHITE)
    
    vir_genes = []
    pause = false
    steps_per_frame = 1
    data = observe(Data, model.world)
#    time = Rational(simPars.startTime)
    while !RL.WindowShouldClose()

        if !pause #&& time <= simPars.finishTime
            for s in 1:steps_per_frame
                step!(model, pars)
                data = observe(Data, model.world)
                #log_results(logfile, data)
                # add values to graph objects
                add_value!(graph_mean_exp, data.exp.mean)
                add_value!(graph_max_exp, data.exp.max)
                add_value!(graph_alarm, model.world.alarm)
                add_value!(graph_sick, data.n_sick.n/length(model.world.pop))
                add_value!(graph_inf, data.n_inf.n/length(model.world.pop))
                add_value!(graph_rec, data.n_rec.n/length(model.world.pop))
                add_value!(graph_ief_mn, data.ief.mean)
                add_value!(graph_ief_mx, data.ief.max)
            end
            h = rand(model.world.map)
            ft = RL.GetFrameTime()
            println(data.n_inf.n, " ", data.n_inf_houses.n, " ", 1.0/ft)
            if model.time >= 23 * 60 - pars.timestep
                vir_genes = sample_virus_genes(model.world.pop)
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
            labels = ["infected", "recovered", "sick"],
            fontsize = floor(Int, 15 * scale))
        
        draw_graph(floor(Int, screenWidth*3/4), floor(Int, screenHeight/2), 
                   floor(Int, screenWidth/4), floor(Int, screenHeight/2) - 30, 
     #       [graph_ihouses, graph_inf_trans, graph_ief_mn, graph_ief_mx],
            [graph_ief_mn, graph_ief_mx],
            single_scale = true, 
     #       labels = ["inf houses", "inf transp", "mean ief", "max ief"],
            labels = ["mean ief", "max ief"],
            fontsize = floor(Int, 15 * scale))
        
        if !isempty(vir_genes)
            for i in 0:4
                if i >= length(vir_genes)
                    break
                end
                genes = vir_genes[length(vir_genes)-i]
                RL.DrawText(join(genes[1], ".") * " " * string(genes[2]), 0,
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
        date = Date(2020, 1, 5) + Week(model.week) + Day(model.day)
        RL.DrawText("$(dayabbr(date)), $(date) $(model.time/60)", 0, 
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
