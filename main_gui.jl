using Random

using Raylib
using Raylib: rayvector

# make this less annoying
const RL = Raylib

include("main_util.jl")
include("analysis.jl")

include("src/gui/render.jl")

using SimpleGraph

function main(par_overrides...)
    args = copy(ARGS)

    for pov in par_overrides
        push!(args, string(pov))
    end

    # need to do that first, otherwise it blocks the GUI
    pars, args = load_parameters(args, 
        ["--gui-scale"], 
        Dict(:help => "set gui scale", :default => 1.0, :arg_type => Float64))

    Random.seed!(pars.seed)

    model = setup_model(pars)
#    logfile = setupLogging(simPars)

    scale = args[:gui_scale]
    screenWidth = floor(Int, 1600 * scale)
    screenHeight = floor(Int, 900 * scale)

    RL.InitWindow(screenWidth, screenHeight, "this is a test")
    RL.SetTargetFPS(30)
    camera = RL.RayCamera2D(
        rayvector(10, 10),
        rayvector(0, 0),
        #rayvector(500, 500),
        0,
        scale 
    )

    # create graph objects with colour
    graph_ihouses = Graph{Float64}(RL.BLUE)
    graph_ipersons = Graph{Float64}(RL.RED)
    graph_rec = Graph{Float64}(RL.GREEN)

    pause = false
#    time = Rational(simPars.startTime)
    while !RL.WindowShouldClose()

        if !pause #&& time <= simPars.finishTime
            step!(model, pars)
            data = observe(Data, model.world)
            #log_results(logfile, data)
            # add values to graph objects
            add_value!(graph_ihouses, data.n_inf_houses.n)
            add_value!(graph_ipersons, data.n_inf.n)
            add_value!(graph_rec, data.n_rec.n)
            h = rand(model.world.map)
            println(h.pos, ": ", h.type, " ", length(h.present))
            #println(data.hh_size.max, " ", data.alive.n, " ", data.eligible.n, " ", data.eligible2.n)
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

        # draw graphs
        draw_graph(floor(Int, screenWidth*2/3), 0, 
                   floor(Int, screenWidth/3), floor(Int, screenHeight/2) - 10, 
            [graph_ipersons, graph_rec],
            single_scale = true, 
            labels = ["infected", "recovered"],
            fontsize = floor(Int, 15 * scale))
        
        draw_graph(floor(Int, screenWidth*2/3), floor(Int, screenHeight/2) + 20, 
                   floor(Int, screenWidth/3), floor(Int, screenHeight/2) - 10, 
            [graph_ihouses],
            single_scale = false, 
            labels = ["inf houses"],
            fontsize = floor(Int, 15 * scale))

        RL.DrawText("$(model.day):$(model.time/60)", 0, 
                    screenHeight - floor(Int, 20 * scale), 
                    floor(Int, 20 * scale), RL.BLACK)

        RL.EndDrawing()
    end

    RL.CloseWindow()

    close(logfile)
end

if ! isinteractive()
    main()
end
