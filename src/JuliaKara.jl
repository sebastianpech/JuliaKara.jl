module JuliaKara
using Gtk.ShortNames, Graphics
include("JuliaKara_noGUI.jl"); using .JuliaKara_noGUI
include("JuliaKara_Base_GUI.jl"); using .JuliaKara_Base_GUI

export
    World,
    place_kara,
    place_tree,
    place_leaf,
    place_mushroom,
    move,
    turnLeft,
    turnRight,
    putLeaf,
    removeLeaf,
    treeLeft,
    treeFront,
    treeRight,
    mushroomFront,
    onLeaf,
    @World,
    save_world,
    load_world,
    get_kara,
    store!,
    reset!,
    world_state_save
    
import .JuliaKara_noGUI:World,
    place_kara,
    place_tree,
    place_leaf,
    place_mushroom,
    move,
    turnLeft,
    turnRight,
    removeLeaf,
    putLeaf,
    treeLeft,
    treeRight,
    treeFront,
    mushroomFront,
    onLeaf,
    orientation_to_rad,
    Actor,
    get_kara,
    reset!

"""
    World_GUI(world::World,canvas::GtkCanvas,saved_world::World_State,drawing_delay::Float64)

Creates a new World with a GUI component. Contains the actual `world` the `canvas` used for drawing.
A state `saved_world` the world can be reverted to and a `drawing_delay`.
Is used for every GUI communication.
"""
mutable struct World_GUI
    world::World
    canvas::Gtk.GtkCanvas
    builder::Gtk.GtkBuilder
    window::Gtk.GtkWindow
    saved_world::World_State
    drawing_delay::Float64
    edit_mode::Symbol
    drag_mode::Bool
    drag_handler::Culong
    drag_actor::Any
    World_GUI(world,canvas,builder,window,saved_world,drawing_delay) = begin
        new(world,canvas,builder,window,saved_world,drawing_delay,:none,false,Culong(0),nothing)
    end
end

"""
    world_redraw(wo::World_GUI,no_delay::Bool=false)

Redraws the world `wo`. If `no_delay` is `true` the delay controlled by `wo.drawing_delay`
which controls the 
"""
function world_redraw(wo::World_GUI,no_delay::Bool=false)
    draw(wo.canvas)
    reveal(wo.canvas)
    if !no_delay
        sleep(wo.drawing_delay/1000)
    end
    nothing
end

"""
    World(height::Int,width::Int,name::AbstractString)

Creates a new world of size `width` x `height`. `name` is used as a title for the
GTK window.
"""
function World(height::Int,width::Int,name::AbstractString)
    world = World(height,width)
    builder,window,canvas = world_init(name)
    show(canvas)
    world_gui = World_GUI(
        world,
        canvas,
        builder,
        window,
        world_state_save(world),
        0,
    )
    kara_world_draw(world_gui)
    reveal(canvas)
    gtk_create_callback(builder,world_gui,canvas)
    return world_gui
end

function gtk_create_callback(b,wo::World_GUI,canvas)
    signal_connect(
        wrap_slider_value_changed_callback(wo),
        b["adj_speed"],
        "value-changed"
    )
    signal_connect(
        wrap_toolbar_btn_open_callback(wo,b),
        b["toolbar_btn_open"],
        "clicked"
    )
    signal_connect(
        wrap_toolbar_btn_save_callback(wo,b),
        b["toolbar_btn_save"],
        "clicked"
    )
    signal_connect(
        wrap_button_down_callback(wo,b,canvas),
        canvas,
        "button-press-event"
    )
    signal_connect(
        wrap_button_release_callback(wo,b,canvas),
        canvas,
        "button-release-event"
    )
    # LEAVE Events apparently dont occour when added to the frame
    # containing the canvas. Therefore the event is added directly
    # to the canvas.
    add_events(canvas,Gtk.GdkEventMask.LEAVE_NOTIFY)
    signal_connect(
        wrap_leave_canvas_callback(wo,b,canvas),
        canvas,
        "leave-notify-event"
    )
    signal_connect(
        wrap_button_edit_tree(wo,b),
        b["edit_btn_tree"],
        "clicked"
    )
    signal_connect(
        wrap_button_edit_mushroom(wo,b),
        b["edit_btn_mushroom"],
        "clicked"
    )
    signal_connect(
        wrap_button_edit_leaf(wo,b),
        b["edit_btn_leaf"],
        "clicked"
    )
    signal_connect(
        wrap_button_edit_kara(wo,b),
        b["edit_btn_kara"],
        "clicked"
    )
    signal_connect(
        wrap_key_press(wo,b),
        b["win_main"],
        "key-release-event"
    )
end

function wrap_key_press(wo::World_GUI,b)
    ctxid = Gtk.context_id(b["statusbar"], "JuliaKara")
    function(widget,key)
        if key.keyval == Gtk.GdkKeySyms.Escape
            push!(b["statusbar"],ctxid,"")
            wo.edit_mode = :none
        end
    end
end

function wrap_slider_value_changed_callback(wo::World_GUI)
    function(widget)
        wo.drawing_delay = getproperty(widget,:value,Float64)
    end
end

function wrap_toolbar_btn_open_callback(wo::World_GUI,b)
    function(widget)
        path = open_dialog("Pick a World-File", b["win_main"], ("*.world",))
        if path != ""
            wo.world = JuliaKara_noGUI.load_world(path)
            wo.saved_world = world_state_save(wo.world)
            world_redraw(wo,true)
        end
    end
end

function wrap_toolbar_btn_save_callback(wo::World_GUI,b)
    function(widget)
        path = save_dialog("Save as ...", b["win_main"], ("*.world",))
        if path != ""
            save_world(
                wo,
                path
            )
        end
    end
end

function wrap_button_down_callback(wo::World_GUI,b,canvas)
    ctxid = Gtk.context_id(b["statusbar"], "JuliaKara")
    function (widget,event)
        if wo.edit_mode==:none
            x,y = JuliaKara_Base_GUI.grid_coordinate_virt(
                grid_generate(wo),
                event.x,event.y
            )
            actors_at_field = JuliaKara_noGUI.ActorsWorld.get_actors_at_location(
                wo.world,
                JuliaKara_noGUI.Location(x,y)
            )
            if length(actors_at_field) > 0
                wo.drag_handler = signal_connect(
                    wrap_actor_drag(wo,actors_at_field[1],b),
                    canvas,
                    "motion-notify-event"
                )
                wo.drag_mode = true
                wo.drag_actor = actors_at_field[1]
            end
            return nothing
        end
    end
end

function wrap_actor_drag(wo::World_GUI,ac::JuliaKara_noGUI.Actor,b)
    function(widget,event)
        ctx = getgc(wo.canvas)
        gr = grid_generate(wo)
        x,y = JuliaKara_Base_GUI.grid_coordinate_virt(
            gr,
            event.x,event.y
        )
        if JuliaKara_noGUI.location_within_world(wo.world,JuliaKara_noGUI.Location(x,y))
            world_redraw(wo,true)
            if ac.actor_definition == JuliaKara_noGUI.ACTOR_DEFINITIONS[:kara]
                image_name = :kara
            elseif ac.actor_definition == JuliaKara_noGUI.ACTOR_DEFINITIONS[:mushroom]
                image_name = :mushroom
            elseif ac.actor_definition == JuliaKara_noGUI.ACTOR_DEFINITIONS[:tree]
                image_name = :tree
            elseif ac.actor_definition == JuliaKara_noGUI.ACTOR_DEFINITIONS[:leaf]
                image_name = :leaf
            else
                error("Missing actor definition, cant draw shape.")
            end
            symbol_image(gr,ctx,
                         x,
                         y,
                         orientation_to_rad(ac.orientation)-π/2,
                         image_name
                         )
            reveal(widget)
        end
    end
end

function wrap_leave_canvas_callback(wo::World_GUI,b,canvas)
    function (widget,event)
        if wo.drag_mode
            signal_handler_disconnect(
                canvas,
                wo.drag_handler
            )
            wo.drag_handler = Culong(0)
            wo.drag_mode = false
            world_redraw(wo)
        end
    end
end

function wrap_button_release_callback(wo::World_GUI,b,canvas)
    ctxid = Gtk.context_id(b["statusbar"], "JuliaKara")
    function(widget,event)
        if wo.edit_mode != :none
            try
                x,y = JuliaKara_Base_GUI.grid_coordinate_virt(
                    grid_generate(wo),
                    event.x,event.y
                )
                actors_at_field = JuliaKara_noGUI.ActorsWorld.get_actors_at_location(
                    wo.world,
                    JuliaKara_noGUI.Location(x,y)
                )
                # In case one of the acors at x,y is of the same type as the editing
                # type, delete it. Else just proceed
                for ac in actors_at_field
                    if ac.actor_definition == JuliaKara_noGUI.ACTOR_DEFINITIONS[wo.edit_mode]
                        JuliaKara_noGUI.ActorsWorld.actor_delete!(
                            wo.world,
                            ac
                        )
                        world_redraw(wo,true)
                        return nothing
                    end
                end
                JuliaKara_noGUI.actor_create!(
                    wo.world,
                    JuliaKara_noGUI.ACTOR_DEFINITIONS[wo.edit_mode],
                    JuliaKara_noGUI.Location(x,y),
                    JuliaKara_noGUI.Orientation(
                        JuliaKara_noGUI.ActorsWorld.DIRECTIONS[1]
                    )
                )
                world_redraw(wo,true)
            catch e
                # Only catch known errors
                if !(e == JuliaKara_noGUI.LocationFullError() || e == JuliaKara_noGUI.LocationOutsideError())
                    throw(e)
                end    
            end
            return nothing
        elseif wo.drag_mode
            try
                signal_handler_disconnect(
                    canvas,
                    wo.drag_handler
                )
                wo.drag_handler = Culong(0)
                wo.drag_mode = false

                x,y = JuliaKara_Base_GUI.grid_coordinate_virt(
                    grid_generate(wo),
                    event.x,event.y
                )
                actors_at_field = JuliaKara_noGUI.ActorsWorld.get_actors_at_location(
                    wo.world,
                    JuliaKara_noGUI.Location(x,y)
                )

                JuliaKara_noGUI.actor_moveto!(
                    wo.world,
                    wo.drag_actor,
                    JuliaKara_noGUI.Location(
                        x,y
                    )
                )
            catch e
                # Only catch known errors
                if !(e == JuliaKara_noGUI.LocationFullError() || e == JuliaKara_noGUI.LocationOutsideError())
                    throw(e)
                end
            end

            world_redraw(wo,true)
        end
        nothing
    end
end

function wrap_button_edit_tree(wo::World_GUI,b)
    ctxid = Gtk.context_id(b["statusbar"], "JuliaKara")
    function (widget)
        push!(b["statusbar"],ctxid,"[Edit] Tree. <ESC> to leave.")
        wo.edit_mode = :tree
    end
end

function wrap_button_edit_mushroom(wo::World_GUI,b)
    ctxid = Gtk.context_id(b["statusbar"], "JuliaKara")
    function (widget)
        push!(b["statusbar"],ctxid,"[Edit] Mushroom. <ESC> to leave.")
        wo.edit_mode = :mushroom
    end
end

function wrap_button_edit_leaf(wo::World_GUI,b)
    ctxid = Gtk.context_id(b["statusbar"], "JuliaKara")
    function (widget)
        push!(b["statusbar"],ctxid,"[Edit] Leaf. <ESC> to leave.")
        wo.edit_mode = :leaf
    end
end

function wrap_button_edit_kara(wo::World_GUI,b)
    ctxid = Gtk.context_id(b["statusbar"], "JuliaKara")
    function (widget)
        wo.edit_mode = :kara
        push!(b["statusbar"],ctxid,"[Edit] Kara. <ESC> to leave.")
    end
end

function grid_generate(wo::World_GUI)
    # Calculate grid size to ensure that every field is quadratic
    #
    # Available dimensions:
    avail_w = width(wo.canvas)-20
    avail_h = height(wo.canvas)-20
    # Needed dimensions
    needed_cell_width = avail_w/wo.world.size.width
    needed_cell_height = avail_h/wo.world.size.height
    # Decisive dimension
    needed_cell_dim = min(needed_cell_width,needed_cell_height)
    # Grid height and width
    grid_width = needed_cell_dim * wo.world.size.width
    grid_height = needed_cell_dim * wo.world.size.height
    # Grid coordinates
    grid_x = (width(wo.canvas)-grid_width)/2
    grid_y = (height(wo.canvas)-grid_height)/2
    # Construct grid
    JuliaKara_Base_GUI.Grid(grid_x,
                       grid_y,
                       grid_width,
                       grid_height,
                       wo.world.size.width,
                       wo.world.size.height
                       )
end

function kara_world_draw(wo::World_GUI)
    @guarded draw(wo.canvas) do widget
        ctx = getgc(wo.canvas)
        # Draw Background
        set_source_rgb(ctx,0.85,0.85,0.85)
        paint(ctx)
        # Draw Grid
        set_source_rgb(ctx,1,1,1) # Black
        gr = grid_generate(wo)
        grid_draw(gr,ctx)
        # Draw Actors
        # Sort by layer
        # first and thus are displayed on the bottom layer
        for ac in sort(wo.world.actors,by=a->a.actor_definition.layer)
            # Dont draw the actor if it is currently draged
            if wo.drag_mode && wo.drag_actor === ac
                continue
            end
            if ac.actor_definition == JuliaKara_noGUI.ACTOR_DEFINITIONS[:kara]
                image_name = :kara
            elseif ac.actor_definition == JuliaKara_noGUI.ACTOR_DEFINITIONS[:mushroom]
                image_name = :mushroom
            elseif ac.actor_definition == JuliaKara_noGUI.ACTOR_DEFINITIONS[:tree]
                image_name = :tree
            elseif ac.actor_definition == JuliaKara_noGUI.ACTOR_DEFINITIONS[:leaf]
                image_name = :leaf
            else
                error("Missing actor definition, cant draw shape.")
            end
            symbol_image(gr,ctx,
                         ac.location.x,
                         ac.location.y,
                         orientation_to_rad(ac.orientation)-π/2,
                         image_name
                         )
        end
    end
end

"""
    place_kara(wo::World_GUI,x::Int,y::Int,direction::Symbol=:NORTH)

Places kara in world `wo` at location `x`, `y` in direction `direction`.
`direction` is either of :NORTH, :EAST, :SOUTH, :WEST.
Returns a reference to the created object.

This function is a wrapper around [`JuliaKara_noGUI.place_kara`](@ref) to support GUI.
"""
function place_kara(wo::World_GUI,x::Int,y::Int,direction::Symbol=JuliaKara_noGUI.ActorsWorld.DIRECTIONS[1])
    ac = place_kara(wo.world,x,y,direction)
    world_redraw(wo)
    return ac
end

"""
    place_tree(wo::World_GUI,x::Int,y::Int)

Places a tree in world `wo` at location `x`, `y`.
Returns a referenc to the created object.

This function is a wrapper around [`JuliaKara_noGUI.place_tree`](@ref) to support GUI.
"""
function place_tree(wo::World_GUI,x::Int,y::Int)
    ac = place_tree(wo.world,x,y)
    world_redraw(wo)
    return ac
end

"""
    place_leaf(wo::World_GUI,x::Int,y::Int)

Places a leaf in world `wo` at location `x`, `y`.
Returns a referenc to the created object.

This function is a wrapper around [`JuliaKara_noGUI.place_leaf`](@ref) to support GUI.
"""
function place_leaf(wo::World_GUI,x::Int,y::Int)
    ac = place_leaf(wo.world,x,y)
    world_redraw(wo)
    return ac
end

"""
    place_mushroom(wo::World_GUI,x::Int,y::Int)

Places a mushroom in world `wo` at location `x`, `y`.
Returns a referenc to the created object.

This function is a wrapper around [`JuliaKara_noGUI.place_mushroom`](@ref) to support GUI.
"""
function place_mushroom(wo::World_GUI,x::Int,y::Int)
    ac = place_mushroom(wo.world,x,y)
    world_redraw(wo)
    return ac
end

"""
    move(wo::World_GUI,ac::Actor)

Moves the actor `ac` a step forward in the world `wo`.

This function is a wrapper around [`JuliaKara_noGUI.move`](@ref) to support GUI.
"""
function move(wo::World_GUI,ac::Actor)
    move(wo.world,ac)
    world_redraw(wo)
end

"""
    turnLeft(wo::World_GUI,ac::Actor)

Turns the actor `ac` counter clockwise.

This function is a wrapper around [`JuliaKara_noGUI.turnLeft`](@ref) to support GUI.
"""
function turnLeft(wo::World_GUI,ac::Actor)
    turnLeft(wo.world,ac)
    world_redraw(wo)
end

"""
    turnRight(wo::World_GUI,ac::Actor)

Turns the actor `ac` clockwise.

This function is a wrapper around [`JuliaKara_noGUI.turnRight`](@ref) to support GUI.
"""
function turnRight(wo::World_GUI,ac::Actor)
    turnRight(wo.world,ac)
    world_redraw(wo)
end

"""
    removeLeaf(wo::World_GUI,ac::Actor)

Removes an actor of type leaf from the location `ac` is at.

This function is a wrapper around [`JuliaKara_noGUI.removeLeaf`](@ref) to support GUI.
"""
function removeLeaf(wo::World_GUI,ac::Actor)
    removeLeaf(wo.world,ac)
    world_redraw(wo)
end

"""
    putLeaf(wo::World_GUI,ac::Actor)

Places an actor of type leaf the location `ac` is at.

This function is a wrapper around [`JuliaKara_noGUI.putLeaf`](@ref) to support GUI.
"""
function putLeaf(wo::World_GUI,ac::Actor)
    putLeaf(wo.world,ac)
    world_redraw(wo)
end

"""
    treeLeft(wo::World_GUI,ac::Actor)

Checks if there is an actor of type tree left of actor `ac`.

This function is a wrapper around [`JuliaKara_noGUI.treeLeft`](@ref) to support GUI.
"""
treeLeft(wo::World_GUI,ac::Actor) = treeLeft(wo.world,ac)

"""
    treeRight(wo::World_GUI,ac::Actor)

Checks if there is an actor of type tree right of actor `ac`.

This function is a wrapper around [`JuliaKara_noGUI.treeRight`](@ref) to support GUI.
"""
treeRight(wo::World_GUI,ac::Actor) = treeRight(wo.world,ac)

"""
    treeFront(wo::World_GUI,ac::Actor)

Checks if there is an actor of type tree in front of actor `ac`.

This function is a wrapper around [`JuliaKara_noGUI.treeFront`](@ref) to support GUI.
"""
treeFront(wo::World_GUI,ac::Actor) = treeFront(wo.world,ac)

"""
    mushroomFront(wo::World_GUI,ac::Actor)

Checks if there is an actor of type mushroom in front of actor `ac`.

This function is a wrapper around [`JuliaKara_noGUI.mushroomFront`](@ref) to support GUI.
"""
mushroomFront(wo::World_GUI,ac::Actor) = mushroomFront(wo.world,ac)

"""
    onLeaf(wo::World_GUI,ac::Actor)

Checks if there is an actor of type leaf below of actor `ac`.

This function is a wrapper around [`JuliaKara_noGUI.onLeaf`](@ref) to support GUI.
"""
onLeaf(wo::World_GUI,ac::Actor) = onLeaf(wo.world,ac)

"""
    @World [name] defintion

`definition` is either a `String` describing the path to a world-file which
should be loaded or a `Tuple{Int,Int}` describing the height and the width
of the world

In case a `name` is provided (Must be a name that can be used as a variable name)
a variable in global scope named `name` and a macro named `@name` are created
which allow access to the world (See Examples).

In case no `name` is provided the world is stored in global scope in a variable
named `world` and kara is placed at location 1,1 and refereced with
a global variable named `kara`. Furthermore all function used for interaction
with kara (`move()`, `turnLeft()`, ...) are extended with methods to allow
calls like `move(kara)`.

# Examples
```julia-repl
julia> @World (10,10)
julia> move(kara) # moves kara in world
julia> @world testw (10,10)
julia> lara = @testw place_kara()
julia> @testw move(lara) # moves lara in testw
```
"""
macro World(definition)
    esc(quote
            if typeof($definition) == String
                world = load_world(
                    $definition,
                    "JuliaKara"
                )
            else
                world = World($definition...,"JuliaKara")
                place_kara(world,1,1)
            end
            kara = get_kara(world)
            import JuliaKara.JuliaKara_noGUI:move,
                turnLeft,
                turnRight,
                putLeaf,
               removeLeaf,
                onLeaf,
                treeFront,
                treeLeft,
                treeRight,
                mushroomFront
            function move(ac::JuliaKara.JuliaKara_noGUI.Actor)
                move(world,ac)
            end
            function turnLeft(ac::JuliaKara.JuliaKara_noGUI.Actor)
                turnLeft(world,ac)
            end
            function turnRight(ac::JuliaKara.JuliaKara_noGUI.Actor)
                turnRight(world,ac)
            end
            function putLeaf(ac::JuliaKara.JuliaKara_noGUI.Actor)
                putLeaf(world,ac)
            end
            function removeLeaf(ac::JuliaKara.JuliaKara_noGUI.Actor)
                removeLeaf(world,ac)
            end
            function onLeaf(ac::JuliaKara.JuliaKara_noGUI.Actor)
                onLeaf(world,ac)
            end
            function treeFront(ac::JuliaKara.JuliaKara_noGUI.Actor)
                treeFront(world,ac)
            end
            function treeLeft(ac::JuliaKara.JuliaKara_noGUI.Actor)
                treeLeft(world,ac)
            end
            function treeRight(ac::JuliaKara.JuliaKara_noGUI.Actor)
                treeRight(world,ac)
            end
            function mushroomFront(ac::JuliaKara.JuliaKara_noGUI.Actor)
                mushroomFront(world,ac)
            end
            nothing
        end
        )
end

macro World(name,definition)
    str_name = string(name)
    esc(quote
        if typeof($definition) == String
            $name = load_world(
                $definition,
                $str_name
            )
        else
            $name = World($definition...,$str_name)
        end
        macro $name(command)
            if command.head == :block
                for ca in command.args
                    if ca.head == :call
                        insert!(ca.args,2,$name)
                    end
                end
            elseif command.head == :call
                insert!(command.args,2,$name)
        end
        return command

        end
        nothing
        end)
end

"""
    load_world(path::AbstractString,name::AbstractString)

Loads a world-file from `path` and names the new window `name`.
Creates a new GTK window.
"""
function load_world(path::AbstractString,name::AbstractString)
    loaded_wo = JuliaKara_noGUI.load_world(path)
    wo = World(loaded_wo.size.width,loaded_wo.size.height,name)
    wo.world = loaded_wo
    wo.saved_world = world_state_save(wo.world)
    world_redraw(wo,true)
    return wo
end

"""
    save_world(wo::World_GUI,path::AbstractString)

Saves a world `wo` into a world-file at `path`.
"""
function save_world(wo::World_GUI,path::AbstractString)
    JuliaKara_noGUI.save_world(wo.world,path)
end

get_kara(wo::World_GUI) = get_kara(wo.world)

"""
    store!(wo::World_GUI)

Stores a state of a world `wo` in `wo.saved_world`.
Can be restored by using `reset!(wo::World)`.

# Exaples
```julia-repl
julia> store!(wo)
julia> # do something in wo
julia> reset!(wo)
```
"""
function store!(wo::World_GUI)
    wo.saved_world = world_state_save(wo.world)
end

function reset!(wo::World_GUI,wst::World_State)
    reset!(wo.world,wst)
    world_redraw(wo,true)
    nothing
end

"""
    reset!(wo::World_GUI)

Resets a world `wo` back to a given state `wo.saved_world`.
Can be stored using `store!(wo)`.
Loading a world from a file stores to state at time of loading.

# Examples
```julia-repl
julia> store!(wo)
julia> # Do something in wo
julia> reset!(wo)
```
"""
function reset!(wo::World_GUI)
    reset!(wo,wo.saved_world)
end

end
