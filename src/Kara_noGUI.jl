module Kara_noGUI

include("ActorsWorld.jl"); using .ActorsWorld

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
    load_world,
    save_world,
    get_kara

const ACTOR_DEFINITIONS = Dict(
    :kara => Actor_Definition(
        moveable=true,
        turnable=true
    ),
    :tree => Actor_Definition(),
    :mushroom => Actor_Definition(
        moveable=true
    ),
    :leaf => Actor_Definition(
        passable=true,
        grabable=true
    )
)

function place_kara(wo::World,x::Int,y::Int,direction::Symbol=ActorsWorld.DIRECTIONS[1])
    actor_create!(
        wo,
        ACTOR_DEFINITIONS[:kara],
        Location(x,y),
        Orientation(direction)
    )
end

function place_tree(wo::World,x::Int,y::Int)
    actor_create!(
        wo,
        ACTOR_DEFINITIONS[:tree],
        Location(x,y),
        Orientation(ActorsWorld.DIRECTIONS[1])
    )
end

function place_leaf(wo::World,x::Int,y::Int)
    actor_create!(
        wo,
        ACTOR_DEFINITIONS[:leaf],
        Location(x,y),
        Orientation(ActorsWorld.DIRECTIONS[1])
    )
end

function place_mushroom(wo::World,x::Int,y::Int)
    actor_create!(
        wo,
        ACTOR_DEFINITIONS[:mushroom],
        Location(x,y),
        Orientation(ActorsWorld.DIRECTIONS[1])
    )
end

function get_kara(wo::World)
    k_found = Actor[]
    for ac in wo.actors
        if ac.actor_definition == ACTOR_DEFINITIONS[:kara]
            push!(k_found,ac)
        end
    end
    # Return kara explicitly if only one was found
    # This is not a good style but in terms of usability
    # its better.
    return length(k_found) == 1 ? k_found[1] : k_found
end

function move(wo::World,ac::Actor)
    actor_move!(wo,ac,ac.orientation.value)
end

function turnLeft(wo::World,ac::Actor)
    actor_rotate!(ac,false)
end

function turnRight(wo::World,ac::Actor)
    actor_rotate!(ac,true)
end

function removeLeaf(wo::World,ac::Actor)
    actor_pickup!(wo,ac)
end

function putLeaf(wo::World,ac::Actor)
    actor_putdown!(wo,ac,ACTOR_DEFINITIONS[:leaf])
end

function treeLeft(wo::World,ac::Actor)
    is_actor_definition_left(wo,ac,ACTOR_DEFINITIONS[:tree])
end

function treeRight(wo::World,ac::Actor)
    is_actor_definition_right(wo,ac,ACTOR_DEFINITIONS[:tree])
end

function treeFront(wo::World,ac::Actor)
    is_actor_definition_front(wo,ac,ACTOR_DEFINITIONS[:tree])
end

function mushroomFront(wo::World,ac::Actor)
    is_actor_definition_front(wo,ac,ACTOR_DEFINITIONS[:mushroom])
end

function onLeaf(wo::World,ac::Actor)
    is_actor_definition_here(wo,ac,ACTOR_DEFINITIONS[:leaf])
end

include("Kara_interface_xml.jl")
save_world = xml_save_world
load_world = xml_load_world

end
