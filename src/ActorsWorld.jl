module ActorsWorld

import Base.==
import Base.copy

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
    location_fix_ooBound,
    wrap_actor_move,
    wrap_actor_rotate,
    wrap_actor_putdown,
    wrap_actor_pickup,
    actor_definition_at_location,
    is_actor_definition_left,
    is_actor_definition_right,
    is_actor_definition_front,
    is_actor_definition_here,
    wrap_actor_definition_left,
    wrap_actor_definition_right,
    wrap_actor_definition_front,
    wrap_actor_definition_here,
    orientation_to_rad,
    AbstractActorsWorldException,
    InvalidDirectionError,
    LocationFullError,
    ActorNotPassableError,
    LocationOutsideError,
    ActorNotFound,
    ActorInvalidRotationError,
    ActorInvalidMovementError,
    ActorInvalidMultipleMovementError,
    ActorInvalidGrabError,
    ActorGrabNotFoundError,
    WorldCorrupError,
    copy

abstract type AbstractActorsWorldException <: Exception end
struct InvalidDirectionError <: AbstractActorsWorldException
    direction::Symbol
end
function Base.showerror(io::IO,e::InvalidDirectionError)
    print(io,"direction $(e.direction) is invalid")
end
struct LocationFullError <: AbstractActorsWorldException end
function Base.showerror(io::IO,e::LocationFullError)
    print(io,"can't place more than two actors at one location")
end
struct ActorNotPassableError <: AbstractActorsWorldException end
function Base.showerror(io::IO,e::ActorNotPassableError)
    print(io,"can't place two not passable actors at one location")
end
struct LocationOutsideError <: AbstractActorsWorldException end
function Base.showerror(io::IO,e::LocationOutsideError)
    print(io,"location is outside of this world")
end
struct ActorNotFound <: AbstractActorsWorldException end
function Base.showerror(io::IO,e::ActorNotFound)
    print(io,"actor is not in this world")
end
struct ActorInvalidRotationError <: AbstractActorsWorldException end
function Base.showerror(io::IO,e::ActorInvalidRotationError)
    print(io,"actor is not turnable")
end
struct ActorInvalidMovementError <: AbstractActorsWorldException end
function Base.showerror(io::IO,e::ActorInvalidMovementError)
    print(io,"actor is not moveable")
end
struct ActorInvalidMultipleMovementError <: AbstractActorsWorldException end
function Base.showerror(io::IO,e::ActorInvalidMultipleMovementError)
    print(io,"too many actors to move")
end
struct ActorInvalidGrabError <: AbstractActorsWorldException end
function Base.showerror(io::IO,e::ActorInvalidGrabError)
    print(io,"actor is not grabable")
end
struct ActorGrabNotFoundError <: AbstractActorsWorldException end
function Base.showerror(io::IO,e::ActorGrabNotFoundError)
    print(io,"there is not actor to grab")
end
struct WorldCorrupError <: AbstractActorsWorldException end
function Base.showerror(io::IO,e::WorldCorrupError)
    print(io,"this world is corrupted. This should not happen")
end

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
        value in DIRECTIONS || throw(InvalidDirectionError(value))
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
        throw(InvalidDirectionError(or.value))
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
        throw(InvalidDirectionError(or.value))
    end
end

function orientation_to_rad(or::Orientation)
    if or.value == DIRECTIONS[1]
        return π/2
    elseif or.value == DIRECTIONS[2]
        return 0
    elseif or.value == DIRECTIONS[3]
        return 3π/2
    elseif or.value == DIRECTIONS[4]
        return π
    else
        throw(InvalidDirectionError(or.value))
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

Defines the behavior and the constraints of an actor.

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

function copy(ac::Actor)
    Actor(
        ac.actor_definition,
        ac.location,
        ac.orientation
    )
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

function copy(wo::World)
    c_wo = World(wo.size.width,wo.size.height)
    for ac in wo.actors
        push!(c_wo.actors,copy(ac))
    end
    return c_wo
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
        throw(LocationFullError())
    end
    if length(ac_at_lo) == 1 && !ac_at_lo[1].actor_definition.passable && !a_def.passable
        throw(ActorNotPassableError())
    end
    # Check if the position is within the world
    if !location_within_world(wo,lo)
        throw(LocationOutsideError())
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
    i != 0 || throw(ActorNotFound())
    deleteat!(wo.actors,i)
end

"""
    get_actors_at_location(wo::World,lo::Location)

Return a list of actors at `lo`. If no actor is at `lo` return `[]`.
"""
function get_actors_at_location(wo::World,lo::Location)
    filter(a->a.location == lo,wo.actors)
end

function actor_definition_at_location(wo::World,lo::Location,acd::Actor_Definition)
    for ac in get_actors_at_location(wo,lo)
        if ac.actor_definition == acd
            return true
        end
    end
    return false
end

"""
    actor_rotate!(ac::Actor,direction::Bool)

Rotate an actor `ac` by 1 step counter-clockwise for `false` and clockwise
for `true`.
"""
function actor_rotate!(ac::Actor,direction::Bool)
    ac.actor_definition.turnable || throw(ActorInvalidRotationError())
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
    ac.actor_definition.moveable || throw(ActorInvalidMovementError())
    new_lo = location_move(ac.location,Orientation(direction))
    new_lo = location_fix_ooBound(wo,new_lo)

    for a in get_actors_at_location(wo,new_lo)
        if a.actor_definition.moveable && !a.actor_definition.passable
            if !parent
                throw(ActorInvalidMultipleMovementError())
            end
            actor_move!(wo,a,direction,false)
        elseif a.actor_definition.passable
            continue
        else
            throw(ActorNotPassableError())
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
        throw(ActorGrabNotFoundError())
    end
    if length(actrs) > 2
        throw(WorldCorruptError())
    end
    filter!(a->a!=ac,actrs)
    if !actrs[1].actor_definition.grabable
        throw(ActorInvalidGrabError())
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
        throw(ActorInvalidGrabError())
    end
    actor_create!(wo,acd_put,ac.location,ac.orientation)
end

function is_actor_definition_left(wo::World,ac::Actor,acd::Actor_Definition)
    lo_left = location_move(ac.location,orientation_rotate(ac.orientation,Val{false}))
    return actor_definition_at_location(wo,lo_left,acd)
end

function is_actor_definition_right(wo::World,ac::Actor,acd::Actor_Definition)
    lo_left = location_move(ac.location,orientation_rotate(ac.orientation,Val{true}))
    return actor_definition_at_location(wo,lo_left,acd)
end

function is_actor_definition_front(wo::World,ac::Actor,acd::Actor_Definition)
    lo_left = location_move(ac.location,ac.orientation)
    return actor_definition_at_location(wo,lo_left,acd)
end

function is_actor_definition_here(wo::World,ac::Actor,acd::Actor_Definition)
    return actor_definition_at_location(wo,ac.location,acd)
end

end
