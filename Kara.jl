module Kara

import Base.==
export
    Location,
    Orientation,
    orientation_rotate,
    Actor,
    World,
    Actor_Definition,
    actor_create!,
    actor_delete!,
    actor_rotate!,
    actor_move!,
    get_actors_at_location,
    location_move,
    location_fix_ooBound

const DIRECTIONS = [
    :NORTH,
    :EAST,
    :SOUTH,
    :WEST
]

struct Orientation
    value::Symbol
    Orientation(value) = begin
        value in DIRECTIONS || error("Invalid direction, use $DIRECTIONS")
        new(value)
    end
end

function orientation_rotate(or::Orientation,::Type{Val{false}})
    if or.value == DIRECTIONS[1]
        return Orientation(DIRECTIONS[4])
    elseif or.value == DIRECTIONS[2]
        return Orientation(DIRECTIONS[1])
    elseif or.value == DIRECTIONS[3]
        return Orientation(DIRECTIONS[2])
    elseif or.value == DIRECTIONS[4]
        return Orientation(DIRECTIONS[3])
    else
        error("Invalid direction, use $DIRECTIONS")
    end
end

function orientation_rotate(or::Orientation,::Type{Val{true}})
    if or.value == DIRECTIONS[1]
        return Orientation(DIRECTIONS[2])
    elseif or.value == DIRECTIONS[2]
        return Orientation(DIRECTIONS[3])
    elseif or.value == DIRECTIONS[3]
        return Orientation(DIRECTIONS[4])
    elseif or.value == DIRECTIONS[4]
        return Orientation(DIRECTIONS[1])
    else
        error("Invalid direction, use $DIRECTIONS")
    end
end

struct Location
    x::Int
    y::Int
end

function location_move(lo::Location,or::Orientation)
    if or.value == DIRECTIONS[1]
        return Location(lo.x,lo.y+1)
    elseif or.value == DIRECTIONS[2]
        return Location(lo.x+1,lo.y)
    elseif or.value == DIRECTIONS[3]
        return Location(lo.x,lo.y-1)
    else
        return Location(lo.x+1,lo.y)
    end
end

==(a::Location,b::Location) = a.x == b.x && a.y == b.y

struct Size
    width::Int
    height::Int
end

struct Actor_Definition
    moveable::Bool
    turnable::Bool
    passable::Bool
    grabable::Bool
    Actor_Definition(;moveable::Bool=false,
                     turnable::Bool=false,
                     passable::Bool=false,
                     grabable::Bool=false
                     ) = new(moveable,turnable,passable,grabable)
end

mutable struct Actor
    actor_definition::Actor_Definition
    location::Location
    orientation::Orientation
end

struct World
    size::Size
    actors::Vector{Actor}
    World(width::Int,height::Int) = new(Size(width,height),Actor[])
end

function actor_create!(wo::World,a_def::Actor_Definition,lo::Location,or::Orientation)
    ac = Actor(a_def,lo,or)
    push!(wo.actors,ac)
    return ac
end

function actor_delete!(wo::World,ac::Actor)
    i = findnext(wo.actors,ac,1)
    i != 0 || error("Actor not in this world!")
    deleteat!(wo.actors,i)
end

function get_actors_at_location(wo::World,lo::Location)
    filter(a->a.location == lo,wo.actors)
end

function actor_rotate!(ac::Actor,direction::Bool)
    ac.actor_definition.turnable || error("Invalid Operation: Actor is not turnable")
    ac.orientation = orientation_rotate(ac.orientation,Val{direction})
end

function location_fix_ooBound(wo::World,lo::Location)
    if lo.x > 0 && lo.x <= wo.size.width && lo.y > 0 && lo.y <= wo.size.height
        return lo
    else
        x = lo.x; y=lo.y
        if lo.x <= 0
            x = wo.size.width + lo.x
        elseif lo.x > wo.size.width
            x = lo.x - wo.size.width
        end
        if lo.y <= 0
            y = wo.size.height + lo.y
        elseif lo.y > wo.size.height
            y = lo.y - wo.size.height
        end
        return Location(x,y)
    end
end

function actor_move!(wo::World,ac::Actor,direction::Symbol,parent::Bool=true)
    ac.actor_definition.moveable || error("Invalid Operation: Actor is not moveable")
    new_lo = location_move(ac.location,Orientation(direction))
    new_lo = location_fix_ooBound(wo,new_lo)

    for a in get_actors_at_location(wo,new_lo)
        if a.actor_definition.moveable && !a.actor_definition.passable
            if !parent
                error("Error: Can't move more than one element")
            end
            actor_move!(wo,a,direction,false)
        elseif a.actor_definition.passable
            continue
        else
            error("Error: Can't access field, actor is not passable")
        end
    end
    ac.location = new_lo
end
end
