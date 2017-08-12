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
    @World

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
    Actor

mutable struct World_GUI
    world::World
    canvas::Gtk.GtkCanvas
end

function world_redraw(wo::World_GUI)
    draw(wo.canvas)
    reveal(wo.canvas)
end

function World(height::Int,width::Int,name::AbstractString)
    world = World(height,width)
    window,canvas = world_init(name)
    show(canvas)
    world_gui = World_GUI(world,canvas)
    kara_world_draw(world_gui)
    reveal(canvas)
    return world_gui
end

function kara_world_draw(wo::World_GUI)
    @guarded draw(wo.canvas) do widget
        ctx = getgc(wo.canvas)
        # Draw Background
        set_source_rgb(ctx,0.85,0.85,0.85)
        paint(ctx)
        # Draw Grid
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
        gr = Kara_Base_GUI.Grid(grid_x,
                                  grid_y,
                                  grid_width,
                                  grid_height,
                                  wo.world.size.width,
                                  wo.world.size.height
                                  )
        set_source_rgb(ctx,1,1,1) # Black
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

macro World(name,size)
    str_name = string(name)
    esc(quote
        $name = World($size...,$str_name)
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

end
