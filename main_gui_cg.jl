using Random
using Dates

using Raylib
using Raylib: rayvector

# make this less annoying
const RL = Raylib

include("main_util.jl")
include("cov_graph.jl")
include("analysis_cg.jl")

include("src/cov_graph/gui/render.jl")

using SimpleGraph

function main(par_overrides...)
    args = copy(ARGS)

    for pov in par_overrides
        push!(args, string(pov))
    end

    # need to do that first, otherwise it blocks the GUI
    (pars, iefpars), args = load_parameters(args, (Params, IEFParams),
        ["--gui-scale"], 
        Dict(:help => "set gui scale", :default => 1.0, :arg_type => Float64))

    Random.seed!(pars.seed)

    model = setup_model(pars, iefpars)
#    logfile = setupLogging(simPars)

    scale = args[:gui_scale]
    screenWidth = floor(Int, 1600 * scale)
    screenHeight = floor(Int, 900 * scale)

    RL.InitWindow(screenWidth, screenHeight, "Covol 0.1 [graph]")
    RL.SetTargetFPS(30)
    camera = RL.RayCamera2D(
        rayvector(10, 10),
        rayvector(0, 0),
        #rayvector(500, 500),
        0,
        scale 
    )

    # create graph objects with colour
    graph_ipersons = Graph{Float64}(RL.RED)
    graph_rec = Graph{Float64}(RL.BLUE)
    graph_ief_mn = Graph{Float64}(RL.BLACK)
    graph_ief_mx = Graph{Float64}(RL.WHITE)
    graph_R0 = Graph{Float64}(RL.PURPLE)
    
    t = 0
    pause = false
#    time = Rational(simPars.startTime)
    while !RL.WindowShouldClose()

        if !pause #&& time <= simPars.finishTime
            t += 1 
            step!(model, pars, iefpars)
            data = observe(Data, model.world, pars, iefpars)
            #log_results(logfile, data)
            # add values to graph objects
            add_value!(graph_ipersons, data.n_inf.n)
            add_value!(graph_rec, data.n_rec.n)
            add_value!(graph_ief_mn, data.ief.mean)
            add_value!(graph_ief_mx, data.ief.max)
            add_value!(graph_R0, data.r0.mean)
            println(data.n_inf.n, " ", data.n_rec.n)
        end

        if RL.IsKeyPressed(Raylib.KEY_SPACE)
            pause = !pause
            sleep(0.2)
        end

        RL.BeginDrawing()

        RL.ClearBackground(RL.LIGHTGRAY)
        
        RL.BeginMode2D(camera)
        
        drawModel(model, (x=0, y=0), (x=8, y=8))

        RL.EndMode2D()

        draw_graph(floor(Int, screenWidth*1/3), 0, 
                   floor(Int, screenWidth/3), floor(Int, screenHeight/2) - 30, 
            [graph_R0],
            single_scale = true, 
            labels = ["R0"],
            fontsize = floor(Int, 15 * scale))

        # draw graphs
        draw_graph(floor(Int, screenWidth*2/3), 0, 
                   floor(Int, screenWidth/3), floor(Int, screenHeight/2) - 30, 
            [graph_ipersons, graph_rec],
            single_scale = true, 
            labels = ["infected", "recovered"],
            fontsize = floor(Int, 15 * scale))
        
        draw_graph(floor(Int, screenWidth*2/3), floor(Int, screenHeight/2), 
                   floor(Int, screenWidth/3), floor(Int, screenHeight/2) - 30, 
     #       [graph_ihouses, graph_inf_trans, graph_ief_mn, graph_ief_mx],
            [graph_ief_mn, graph_ief_mx],
            single_scale = true, 
     #       labels = ["inf houses", "inf transp", "mean ief", "max ief"],
            labels = ["mean ief", "max ief"],
            fontsize = floor(Int, 15 * scale))

        #date = Date(2020) + Week(model.week) + Day(model.day)
        RL.DrawText("$(trunc(Int, t/iefpars.t_repr_cycle))", 0, 
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
