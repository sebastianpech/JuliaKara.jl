module Kara
using Gtk.ShortNames, Graphics
include("Kara_noGUI.jl"); using .Kara_noGUI
include("Kara_Base_GUI.jl"); using .Kara_Base_GUI

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
    store,
    reset

import .Kara_noGUI:World,
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
    world_export

import Base.reset

mutable struct World_GUI
    world::World
    canvas::Gtk.GtkCanvas
    saved_world::World
    drawing_delay::Float64
end

function world_redraw(wo::World_GUI)
    draw(wo.canvas)
    reveal(wo.canvas)
    sleep(wo.drawing_delay/1000)
end

function World(height::Int,width::Int,name::AbstractString)
    world = World(height,width)
    builder,window,canvas = world_init(name)
    show(canvas)
    world_gui = World_GUI(
        world,
        canvas,
        Kara_noGUI.world_export(world),
        0,
    )
    kara_world_draw(world_gui)
    reveal(canvas)
    gtk_create_callback(builder,world_gui)
    return world_gui
end

function gtk_create_callback(b,wo::World_GUI)
    signal_connect(
        wrap_slider_value_changed_callback(wo),
        b["adj_speed"],
        "value-changed"
    )
    signal_connect(
        wrap_toolbar_btn_reset_callback(wo),
        b["toolbar_btn_reset"],
        "clicked"
    )
    signal_connect(
        wrap_button_down_callback(wo,b),
        b["frame_canvas"],
        "button-release-event"
    )
    signal_connect(
        wrap_button_edit_tree(wo,b),
        b["edit_btn_tree"],
        "toggled"
    )
    signal_connect(
        wrap_button_edit_mushroom(wo,b),
        b["edit_btn_mushroom"],
        "toggled"
    )
    signal_connect(
        wrap_button_edit_leaf(wo,b),
        b["edit_btn_leaf"],
        "toggled"
    )
    signal_connect(
        wrap_button_edit_kara(wo,b),
        b["edit_btn_kara"],
        "toggled"
    )
end

function wrap_slider_value_changed_callback(wo::World_GUI)
    function(widget)
        wo.drawing_delay = getproperty(widget,:value,Float64)
    end
end

function wrap_toolbar_btn_reset_callback(wo::World_GUI)
    function(widget)
        reset(wo)
    end
end

function wrap_button_down_callback(wo::World_GUI,b)
    ctxid = Gtk.context_id(b["statusbar"], "Kara")
    function(widget,event)
        x,y = Kara_Base_GUI.grid_coordinate_virt(
            grid_generate(wo),
            event.x,event.y
        )
    end
end

function wrap_button_edit_tree(wo::World_GUI,b)
    ctxid = Gtk.context_id(b["statusbar"], "Kara")
    function (widget)
        push!(b["statusbar"],ctxid,"[Edit] Tree")
    end
end

function wrap_button_edit_mushroom(wo::World_GUI,b)
    ctxid = Gtk.context_id(b["statusbar"], "Kara")
    function (widget)
        push!(b["statusbar"],ctxid,"[Edit] Mushroom")
    end
end

function wrap_button_edit_leaf(wo::World_GUI,b)
    ctxid = Gtk.context_id(b["statusbar"], "Kara")
    function (widget)
        push!(b["statusbar"],ctxid,"[Edit] Leaf")
    end
end

function wrap_button_edit_kara(wo::World_GUI,b)
    ctxid = Gtk.context_id(b["statusbar"], "Kara")
    function (widget)
        push!(b["statusbar"],ctxid,"[Edit] Kara")
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
    Kara_Base_GUI.Grid(grid_x,
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
        # Sort by passable. This way all passable objects are drawn
        # first and thus are displayed on the bottom layer
        for ac in sort(wo.world.actors,by=a->a.actor_definition.passable,rev=true)
            if ac.actor_definition == Kara_noGUI.ACTOR_DEFINITIONS[:kara]
                set_source_rgb(ctx,0,0,0)
                symbol_triangle(gr,ctx,
                                ac.location.x,
                                ac.location.y,
                                orientation_to_rad(ac.orientation)-π/2)
            elseif ac.actor_definition == Kara_noGUI.ACTOR_DEFINITIONS[:mushroom]
                set_source_rgb(ctx,1,0,0)
                symbol_circle(gr,ctx,ac.location.x,ac.location.y)
            elseif ac.actor_definition == Kara_noGUI.ACTOR_DEFINITIONS[:tree]
                set_source_rgb(ctx,0.5,0.3,0)
                symbol_circle(gr,ctx,ac.location.x,ac.location.y)
            elseif ac.actor_definition == Kara_noGUI.ACTOR_DEFINITIONS[:leaf]
                set_source_rgb(ctx,0,0.5,0)
                symbol_star(gr,ctx,ac.location.x,ac.location.y)
            else
                error("Missing actor definition, cant draw shape.")
            end
        end
    end
end

function place_kara(wo::World_GUI,x::Int,y::Int,direction::Symbol=Kara_noGUI.ActorsWorld.DIRECTIONS[1])
    ac = place_kara(wo.world,x,y,direction)
    world_redraw(wo)
    return ac
end

function place_tree(wo::World_GUI,x::Int,y::Int)
    ac = place_tree(wo.world,x,y)
    world_redraw(wo)
    return ac
end

function place_leaf(wo::World_GUI,x::Int,y::Int)
    ac = place_leaf(wo.world,x,y)
    world_redraw(wo)
    return ac
end

function place_mushroom(wo::World_GUI,x::Int,y::Int)
    ac = place_mushroom(wo.world,x,y)
    world_redraw(wo)
    return ac
end

function move(wo::World_GUI,ac::Actor)
    move(wo.world,ac)
    world_redraw(wo)
end

function turnLeft(wo::World_GUI,ac::Actor)
    turnLeft(wo.world,ac)
    world_redraw(wo)
end

function turnRight(wo::World_GUI,ac::Actor)
    turnRight(wo.world,ac)
    world_redraw(wo)
end

function removeLeaf(wo::World_GUI,ac::Actor)
    removeLeaf(wo.world,ac)
    world_redraw(wo)
end

function putLeaf(wo::World_GUI,ac::Actor)
    putLeaf(wo.world,ac)
    world_redraw(wo)
end

treeLeft(wo::World_GUI,ac::Actor) = treeLeft(wo.world,ac)
treeRight(wo::World_GUI,ac::Actor) = treeRight(wo.world,ac)
treeFront(wo::World_GUI,ac::Actor) = treeFront(wo.world,ac)
mushroomFront(wo::World_GUI,ac::Actor) = mushroomFront(wo.world,ac)
onLeaf(wo::World_GUI,ac::Actor) = onLeaf(wo.world,ac)

macro World(definition)
    esc(quote
            if typeof($definition) == String
                world = load_world(
                    $definition,
                    "Kara"
                )
            else
                world = World($definition...,"Kara")
                place_kara(world,1,1)
            end
            kara = get_kara(world)
            import Kara.Kara_noGUI:move,
                turnLeft,
                turnRight,
                putLeaf,
                removeLeaf,
                treeFront,
                treeLeft,
                treeRight,
                mushroomFront
            function move(ac::Kara.Kara_noGUI.Actor)
                move(world,ac)
            end
            function turnLeft(ac::Kara.Kara_noGUI.Actor)
                turnLeft(world,ac)
            end
            function turnRight(ac::Kara.Kara_noGUI.Actor)
                turnRight(world,ac)
            end
            function putLeaf(ac::Kara.Kara_noGUI.Actor)
                putLeaf(world,ac)
            end
            function removeLeaf(ac::Kara.Kara_noGUI.Actor)
                removeLeaf(world,ac)
            end
            function treeFront(ac::Kara.Kara_noGUI.Actor)
                treeFront(world,ac)
            end
            function treeLeft(ac::Kara.Kara_noGUI.Actor)
                treeLeft(world,ac)
            end
            function treeRight(ac::Kara.Kara_noGUI.Actor)
                treeRight(world,ac)
            end
            function mushroomFront(ac::Kara.Kara_noGUI.Actor)
                mushroomFront(world,ac)
            end
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
    end)
end

function load_world(path::AbstractString,name::AbstractString)
    loaded_wo = Kara_noGUI.load_world(path)
    wo = World(loaded_wo.size.width,loaded_wo.size.height,name)
    wo.world = loaded_wo
    wo.saved_world = copy(loaded_wo)
    world_redraw(wo)
    return wo
end

function save_world(wo::World_GUI,path::AbstractString)
    Kara_noGUI.save_world(wo.world,path)
end

get_kara(wo::World_GUI) = get_kara(wo.world)
store(wo::World_GUI) = world_export(wo.world)

function reset(wo::World_GUI,woi::World)
    wo.world = woi
    world_redraw(wo)
    nothing
end

function reset(wo::World_GUI)
    reset(wo,wo.saved_world)
end

end
