module ActorsWorld

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
    actor_putdown!,
    actor_pickup!,
    get_actors_at_location,
    location_move,
    location_fix_ooBound

const DIRECTIONS = [
    :NORTH,
    :EAST,
    :SOUTH,
    :WEST
]

"""
    Orientation(value::Symbol)

Defines a orientation. Possible values for `value` are
defined in DIRECTIONS.
"""
struct Orientation
    value::Symbol
    Orientation(value) = begin
        value in DIRECTIONS || error("Invalid direction, use $DIRECTIONS")
        new(value)
    end
end

"""
    orientation_rotate(or::Orientation,::Type{Val{bool}})

Rotates a `Orientation` counter-clockwise for Val{false} and clockwise for
Val{true}. Basically jumps to the next enty in `DIRECTIONS`. The last jumps
to the first and the first to the last.
"""
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

"""
    Location(x::Int,y::Int)

Stores a location defined by x and y on a gridded space.
"""
struct Location
    x::Int
    y::Int
end

"""
    location_move(lo::Location,or::Orientation)

Moves one step into the direction defined by the Orientation `or`.
"""
function location_move(lo::Location,or::Orientation)
    if or.value == DIRECTIONS[1]
        return Location(lo.x,lo.y+1)
    elseif or.value == DIRECTIONS[2]
        return Location(lo.x+1,lo.y)
    elseif or.value == DIRECTIONS[3]
        return Location(lo.x,lo.y-1)
    else
        return Location(lo.x-1,lo.y)
    end
end

==(a::Location,b::Location) = a.x == b.x && a.y == b.y

"""
    Size(width::Int,height::Int)

Stores the size of a grid.
"""
struct Size
    width::Int
    height::Int
end

"""
    Actor_Definition(;<keyword arguments>)

Defines the behavior and the constrains of a actor.

# Argmuments
- `moveable::Bool`: Defines the movement of this actor.
- `turnable::Bool`: Defines the rotation of this actor.
- `passable::Bool`: Defines if this actor can share a field with another actor
- `grabable::Bool`: Defines if the actor can be picked-up and put-down
"""
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
"""
    Actor(actor_definition::Actor_Definition,location::Location,orientation::Orientation)

Defines the actual actor which is placed on the world.

# Examples
The following creates an actor which can be moved and turned. It is placed at
(0,0) in the world and looks north.

```julia-repl
julia> Actor(
    Actor_Definition(moveable=true,turnable=true),
    Location(0,0),
    Orientation(:NORTH)
)
```
"""
mutable struct Actor
    actor_definition::Actor_Definition
    location::Location
    orientation::Orientation
end
"""
    World(width::Int,height::Int)

Creates a new world with a given height and a given width.
"""
struct World
    size::Size
    actors::Vector{Actor}
    World(width::Int,height::Int) = new(Size(width,height),Actor[])
end
"""
    actor_create!(wo::World,a_def::Actor_Definition,lo::Location,or::Orientation)

Creates a new actor defined by the actor definition `a_def` at Location `lo`,
oriented in `or`. The actor is added to the world `wo`.

The functions returns the newly generated actor, thus to enable interaction it
should be stored.

# Examples
```julia-repl
julia> wo = World(10,10)
julia> adef = Actor_Definition(
    moveable=true,
    turnable=true
)
julia> ac_new = actor_create(
    wo,adef,
    Location(1,1),Orientation(:NORTH)
)
julia> actor_move!(wo,ac_new,:NORTH)
```
"""
function actor_create!(wo::World,a_def::Actor_Definition,lo::Location,or::Orientation)
    # Check if actors already exist at this location
    # One marke passable is ok
    ac_at_lo = get_actors_at_location(wo,lo)
    if length(ac_at_lo) > 1
        error("Error: Can't place new actor at this location, too many actors.")
    end
    if length(ac_at_lo) == 1 && !ac_at_lo[1].actor_definition.passable && !a_def.passable
        error("Error: Can't plane new actor at this location, actor not passable.")
    end
    # Check if the position is within the world
    if !location_within_world(wo,lo)
        error("Can't place new actor at this location, location is outside of this world")
    end
    ac = Actor(a_def,lo,or)
    push!(wo.actors,ac)
    return ac
end
"""
    actor_delete!(wo::World,ac::Actor)

Delete the actor `ac` from the World `wo`.
"""
function actor_delete!(wo::World,ac::Actor)
    i = findnext(wo.actors,ac,1)
    i != 0 || error("Actor not in this world!")
    deleteat!(wo.actors,i)
end
"""
    get_actors_at_location(wo::World,lo::Location)

Return a list of actors at `lo`. If no actor is at `lo` return `[]`.
"""
function get_actors_at_location(wo::World,lo::Location)
    filter(a->a.location == lo,wo.actors)
end
"""
    actor_rotate!(ac::Actor,direction::Bool)

Rotate an actor `ac` by 1 step counter-clockwise for `false` and clockwise
for `true`.
"""
function actor_rotate!(ac::Actor,direction::Bool)
    ac.actor_definition.turnable || error("Invalid Operation: Actor is not turnable")
    ac.orientation = orientation_rotate(ac.orientation,Val{direction})
end
"""
    location_within_world(wo::World,lo::Location)

Check if `lo` is within the bounds of the worlds size.
"""
function location_within_world(wo::World,lo::Location)
    lo.x > 0 && lo.x <= wo.size.width && lo.y > 0 && lo.y <= wo.size.height
end
"""
    location_fix_ooBound(wo::World,lo::Location)

Fix a location `lo` which is out of bounds of the worlds size.
The fix is made such that when leaving the world at one end
the world is entered at the opposit end.
"""
function location_fix_ooBound(wo::World,lo::Location)
    if location_within_world(wo,lo)
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
"""
    actor_move!(wo::World,ac::Actor,direction::Symbol[,parent::Bool])

Move the actor `ac` one step in the direction `direction` with the world `wo`.
The optional attribute `parent` should never be used directly as its purpos
is to only allow the movemnt of one consecutive moveable actor.
It actually stops the movement recursion by switching from true to false, which
only allows one nested layer of recursion.
"""
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


"""
    actor_pickup!(wo::World,ac::Actor)

Remove an `grabable` actor from the same location `ac` is at.
"""
function actor_pickup!(wo::World,ac::Actor)
    actrs = get_actors_at_location(wo,ac.location)
    if length(actrs) == 1
        error("There is nothing to pickup here.")
    end
    if length(actrs) > 2
        error("The world is corrupt! There are more than 2 actors on one field")
    end
    filter!(a->a!=ac,actrs)
    if !actrs[1].actor_definition.grabable
        error("The actor is not grabable")
    end
    actor_delete!(wo,actrs[1])
end

"""
    actor_putdown(wo::Word,ac::Actor,acd_put::Actor_Definition)

Create an actor of type `acd_put` at `ac`'s location with `ac`'s orientation.
Only works if `acd_put` has `grabable=true`.
""" 
function actor_putdown!(wo::World,ac::Actor,acd_put::Actor_Definition)
    if !acd_put.grabable
        error("The actor is not grabable")
    end
    actor_create!(wo,acd_put,ac.location,ac.orientation)
end

end
