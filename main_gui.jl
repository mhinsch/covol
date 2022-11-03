using Raylib
using Raylib: rayvector

# make this less annoying
const RL = Raylib

include("main_util.jl")

include("src/RayGUI/render.jl")

include("src/RayGUI/SimpleGraph.jl")
using .SimpleGraph

function main(parOverrides...)
#    args = copy(ARGS)

#    for pov in parOverrides
#        push!(args, string(pov))
#    end

    # need to do that first, otherwise it blocks the GUI
#    simPars, pars, args = loadParameters(args, 
#        ["--gui-scale"], 
#        Dict(:help => "set gui scale", :default => 1.0, :arg_type => Float64))

    pars = Params()
    model = setup_model(pars)
#    logfile = setupLogging(simPars)

    scale = 2.0 # args[:gui_scale]
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
#    graph_pop = Graph{Float64}(RL.BLUE)
#    graph_hhs = Graph{Float64}(RL.WHITE)
#    graph_marr = Graph{Float64}(RL.BLACK)
#    graph_age = Graph{Float64}(RL.RED)

    pause = false
#    time = Rational(simPars.startTime)
    while !RL.WindowShouldClose()

        if !pause #&& time <= simPars.finishTime
            step!(model, pars)
            #data = observe(Data, model)
            #log_results(logfile, data)
            # add values to graph objects
            #add_value!(graph_pop, data.alive.n)
            #add_value!(graph_hhs, data.hh_size.mean)
            #add_value!(graph_marr, data.married.n)
            #set_data!(graph_age, data.hist_age.bins, minm=0)
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
        #draw_graph(floor(Int, screenWidth/3), 0, floor(Int, screenWidth*2/3), screenHeight, 
        #           [graph_pop, graph_hhs, graph_marr, graph_age], 
        #           single_scale = false, 
        #           labels = ["#alive", "hh size", "#married", "age"],
        #           fontsize = floor(Int, 15 * scale))
        

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
