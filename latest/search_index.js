var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Kara.jl Documentation",
    "title": "Kara.jl Documentation",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#Kara.jl-Documentation-1",
    "page": "Kara.jl Documentation",
    "title": "Kara.jl Documentation",
    "category": "section",
    "text": ""
},

{
    "location": "index.html#Functions-1",
    "page": "Kara.jl Documentation",
    "title": "Functions",
    "category": "section",
    "text": "CurrentModule = Kara"
},

{
    "location": "index.html#Kara.@World",
    "page": "Kara.jl Documentation",
    "title": "Kara.@World",
    "category": "Macro",
    "text": "@World [name] defintion\n\ndefinition is either a String describing the path to a world-file which should be loaded or a Tuple{Int,Int} describing the height and the width of the world\n\nIn case a name is provided (Must be a name that can be used as a variable name) a variable in global scope named name and a macro named @name are created which allow access to the world (See Examples).\n\nIn case no name is provided the world is stored in global scope in a variable named world and kara is placed at location 1,1 and refereced with a global variable named kara. Furthermore all function used for interaction with kara (move(), turnLeft(), ...) are extended with methods to allow calls like move(kara).\n\nExamples\n\njulia> @World (10,10)\njulia> move(kara) # moves kara in world\njulia> @world testw (10,10)\njulia> lara = @testw place_kara()\njulia> @testw move(lara) # moves lara in testw\n\n\n\n"
},

{
    "location": "index.html#World-1",
    "page": "Kara.jl Documentation",
    "title": "World",
    "category": "section",
    "text": "@World"
},

{
    "location": "index.html#Kara.Kara_noGUI.move",
    "page": "Kara.jl Documentation",
    "title": "Kara.Kara_noGUI.move",
    "category": "Function",
    "text": "move(wo::World,ac::Actor)\n\nMoves the actor ac a step forward in the world wo.\n\n\n\nmove(wo::World_GUI,ac::Actor)\n\nMoves the actor ac a step forward in the world wo.\n\nThis function is a wrapper around Kara_noGUI.move to support GUI.\n\n\n\n"
},

{
    "location": "index.html#Kara.Kara_noGUI.turnLeft",
    "page": "Kara.jl Documentation",
    "title": "Kara.Kara_noGUI.turnLeft",
    "category": "Function",
    "text": "turnLeft(wo::World,ac::Actor)\n\nTurns the actor ac counter clockwise.\n\n\n\nturnLeft(wo::World_GUI,ac::Actor)\n\nTurns the actor ac counter clockwise.\n\nThis function is a wrapper around Kara_noGUI.turnLeft to support GUI.\n\n\n\n"
},

{
    "location": "index.html#Kara.Kara_noGUI.turnRight",
    "page": "Kara.jl Documentation",
    "title": "Kara.Kara_noGUI.turnRight",
    "category": "Function",
    "text": "turnRight(wo::World,ac::Actor)\n\nTurns the actor ac clockwise.\n\n\n\nturnRight(wo::World_GUI,ac::Actor)\n\nTurns the actor ac clockwise.\n\nThis function is a wrapper around Kara_noGUI.turnRight to support GUI.\n\n\n\n"
},

{
    "location": "index.html#Kara.Kara_noGUI.putLeaf",
    "page": "Kara.jl Documentation",
    "title": "Kara.Kara_noGUI.putLeaf",
    "category": "Function",
    "text": "putLeaf(wo::World,ac::Actor)\n\nPlaces an actor of type leaf the location ac is at.\n\n\n\nputLeaf(wo::World_GUI,ac::Actor)\n\nPlaces an actor of type leaf the location ac is at.\n\nThis function is a wrapper around Kara_noGUI.putLeaf to support GUI.\n\n\n\n"
},

{
    "location": "index.html#Kara.Kara_noGUI.removeLeaf",
    "page": "Kara.jl Documentation",
    "title": "Kara.Kara_noGUI.removeLeaf",
    "category": "Function",
    "text": "removeLeaf(wo::World,ac::Actor)\n\nRemoves an actor of type leaf from the location ac is at.\n\n\n\nremoveLeaf(wo::World_GUI,ac::Actor)\n\nRemoves an actor of type leaf from the location ac is at.\n\nThis function is a wrapper around Kara_noGUI.removeLeaf to support GUI.\n\n\n\n"
},

{
    "location": "index.html#Interaction-1",
    "page": "Kara.jl Documentation",
    "title": "Interaction",
    "category": "section",
    "text": "move\nturnLeft\nturnRight\nputLeaf\nremoveLeaf"
},

{
    "location": "index.html#Kara.Kara_noGUI.treeFront",
    "page": "Kara.jl Documentation",
    "title": "Kara.Kara_noGUI.treeFront",
    "category": "Function",
    "text": "treeFront(wo::World,ac::Actor)\n\nChecks if there is an actor of type tree in front of actor ac.\n\n\n\ntreeFront(wo::World_GUI,ac::Actor)\n\nChecks if there is an actor of type tree in front of actor ac.\n\nThis function is a wrapper around Kara_noGUI.treeFront to support GUI.\n\n\n\n"
},

{
    "location": "index.html#Kara.Kara_noGUI.treeLeft",
    "page": "Kara.jl Documentation",
    "title": "Kara.Kara_noGUI.treeLeft",
    "category": "Function",
    "text": "treeLeft(wo::World,ac::Actor)\n\nChecks if there is an actor of type tree left of actor ac.\n\n\n\ntreeLeft(wo::World_GUI,ac::Actor)\n\nChecks if there is an actor of type tree left of actor ac.\n\nThis function is a wrapper around Kara_noGUI.treeLeft to support GUI.\n\n\n\n"
},

{
    "location": "index.html#Kara.Kara_noGUI.treeRight",
    "page": "Kara.jl Documentation",
    "title": "Kara.Kara_noGUI.treeRight",
    "category": "Function",
    "text": "treeRight(wo::World,ac::Actor)\n\nChecks if there is an actor of type tree right of actor ac.\n\n\n\ntreeRight(wo::World_GUI,ac::Actor)\n\nChecks if there is an actor of type tree right of actor ac.\n\nThis function is a wrapper around Kara_noGUI.treeRight to support GUI.\n\n\n\n"
},

{
    "location": "index.html#Kara.Kara_noGUI.mushroomFront",
    "page": "Kara.jl Documentation",
    "title": "Kara.Kara_noGUI.mushroomFront",
    "category": "Function",
    "text": "mushroomFront(wo::World,ac::Actor)\n\nChecks if there is an actor of type mushroom in front of actor ac.\n\n\n\nmushroomFront(wo::World_GUI,ac::Actor)\n\nChecks if there is an actor of type mushroom in front of actor ac.\n\nThis function is a wrapper around Kara_noGUI.mushroomFront to support GUI.\n\n\n\n"
},

{
    "location": "index.html#Kara.Kara_noGUI.onLeaf",
    "page": "Kara.jl Documentation",
    "title": "Kara.Kara_noGUI.onLeaf",
    "category": "Function",
    "text": "onLeaf(wo::World,ac::Actor)\n\nChecks if there is an actor of type leaf below of actor ac.\n\n\n\nonLeaf(wo::World_GUI,ac::Actor)\n\nChecks if there is an actor of type leaf below of actor ac.\n\nThis function is a wrapper around Kara_noGUI.onLeaf to support GUI.\n\n\n\n"
},

{
    "location": "index.html#Sensors-1",
    "page": "Kara.jl Documentation",
    "title": "Sensors",
    "category": "section",
    "text": "treeFront\ntreeLeft\ntreeRight\nmushroomFront\nonLeaf"
},

{
    "location": "index.html#Index-1",
    "page": "Kara.jl Documentation",
    "title": "Index",
    "category": "section",
    "text": ""
},

{
    "location": "actorsworld.html#",
    "page": "Actors World",
    "title": "Actors World",
    "category": "page",
    "text": ""
},

{
    "location": "actorsworld.html#Actors-World-1",
    "page": "Actors World",
    "title": "Actors World",
    "category": "section",
    "text": ""
},

{
    "location": "actorsworld.html#Functions-1",
    "page": "Actors World",
    "title": "Functions",
    "category": "section",
    "text": "CurrentModule = Kara.Kara_noGUI.ActorsWorld"
},

{
    "location": "actorsworld.html#Kara.Kara_noGUI.ActorsWorld.Orientation",
    "page": "Actors World",
    "title": "Kara.Kara_noGUI.ActorsWorld.Orientation",
    "category": "Type",
    "text": "Orientation(value::Symbol)\n\nDefines a orientation. Possible values for value are defined in DIRECTIONS.\n\n\n\n"
},

{
    "location": "actorsworld.html#Kara.Kara_noGUI.ActorsWorld.orientation_rotate",
    "page": "Actors World",
    "title": "Kara.Kara_noGUI.ActorsWorld.orientation_rotate",
    "category": "Function",
    "text": "orientation_rotate(or::Orientation,::Type{Val{bool}})\n\nRotates a Orientation counter-clockwise for Val{false} and clockwise for Val{true}. Basically jumps to the next enty in DIRECTIONS. The last jumps to the first and the first to the last.\n\n\n\n"
},

{
    "location": "actorsworld.html#Kara.Kara_noGUI.ActorsWorld.Location",
    "page": "Actors World",
    "title": "Kara.Kara_noGUI.ActorsWorld.Location",
    "category": "Type",
    "text": "Location(x::Int,y::Int)\n\nStores a location defined by x and y on a gridded space.\n\n\n\n"
},

{
    "location": "actorsworld.html#Kara.Kara_noGUI.ActorsWorld.location_move",
    "page": "Actors World",
    "title": "Kara.Kara_noGUI.ActorsWorld.location_move",
    "category": "Function",
    "text": "location_move(lo::Location,or::Orientation)\n\nMoves one step into the direction defined by the Orientation or.\n\n\n\n"
},

{
    "location": "actorsworld.html#Kara.Kara_noGUI.ActorsWorld.Size",
    "page": "Actors World",
    "title": "Kara.Kara_noGUI.ActorsWorld.Size",
    "category": "Type",
    "text": "Size(width::Int,height::Int)\n\nStores the size of a grid.\n\n\n\n"
},

{
    "location": "actorsworld.html#Basic-1",
    "page": "Actors World",
    "title": "Basic",
    "category": "section",
    "text": "Orientation\norientation_rotate\nLocation\nlocation_move\nSize"
},

{
    "location": "actorsworld.html#Kara.Kara_noGUI.ActorsWorld.World",
    "page": "Actors World",
    "title": "Kara.Kara_noGUI.ActorsWorld.World",
    "category": "Type",
    "text": "World(width::Int,height::Int)\n\nCreates a new world with a given height and a given width.\n\n\n\n"
},

{
    "location": "actorsworld.html#Kara.Kara_noGUI.ActorsWorld.location_within_world",
    "page": "Actors World",
    "title": "Kara.Kara_noGUI.ActorsWorld.location_within_world",
    "category": "Function",
    "text": "location_within_world(wo::World,lo::Location)\n\nCheck if lo is within the bounds of the worlds size.\n\n\n\n"
},

{
    "location": "actorsworld.html#Kara.Kara_noGUI.ActorsWorld.location_fix_ooBound",
    "page": "Actors World",
    "title": "Kara.Kara_noGUI.ActorsWorld.location_fix_ooBound",
    "category": "Function",
    "text": "location_fix_ooBound(wo::World,lo::Location)\n\nFix a location lo which is out of bounds of the worlds size. The fix is made such that when leaving the world at one end the world is entered at the opposit end.\n\n\n\n"
},

{
    "location": "actorsworld.html#Kara.Kara_noGUI.ActorsWorld.world_state_save",
    "page": "Actors World",
    "title": "Kara.Kara_noGUI.ActorsWorld.world_state_save",
    "category": "Function",
    "text": "world_state_save(wo::World)\n\nConerts a world wo to a structure that holds all actors with their current location and orientation. Can be used with reset! to revert a world to a certain World_State.\n\nExamples\n\njulia> ws = world_state_save(some_world)\njulia> # Do something in some_world\njulia> reset!(some_world,ws)` # World is back to the saved state\n\n\n\n"
},

{
    "location": "actorsworld.html#Kara.Kara_noGUI.ActorsWorld.reset!",
    "page": "Actors World",
    "title": "Kara.Kara_noGUI.ActorsWorld.reset!",
    "category": "Function",
    "text": "reset!(wo::World,state::World_State)\n\nResets a wo back to a given state. The state is obtained from world_state_save.\n\nExamples\n\njulia> ws = world_state_save(some_world)\njulia> # Do something in some_world\njulia> reset!(some_world,ws)` # World is back to the saved state\n\n\n\nreset!(wo::World_GUI)\n\nResets a world wo back to a given state wo.saved_world. Can be stored using store!(wo). Loading a world from a file stores to state at time of loading.\n\nExamples\n\njulia> store!(wo)\njulia> # Do something in wo\njulia> reset!(wo)\n\n\n\n"
},

{
    "location": "actorsworld.html#World-1",
    "page": "Actors World",
    "title": "World",
    "category": "section",
    "text": "World\nlocation_within_world\nlocation_fix_ooBound\nworld_state_save\nreset!"
},

{
    "location": "actorsworld.html#Kara.Kara_noGUI.ActorsWorld.Actor_Definition",
    "page": "Actors World",
    "title": "Kara.Kara_noGUI.ActorsWorld.Actor_Definition",
    "category": "Type",
    "text": "Actor_Definition(;<keyword arguments>)\n\nDefines the behavior and the constraints of an actor.\n\nArgmuments\n\nmoveable::Bool: Defines the movement of this actor.\nturnable::Bool: Defines the rotation of this actor.\ngrabable::Bool: Defines if the actor can be picked-up and put-down\nlayer::Int    : Defines the leayer the actor moves on\n\n\n\n"
},

{
    "location": "actorsworld.html#Kara.Kara_noGUI.ActorsWorld.Actor",
    "page": "Actors World",
    "title": "Kara.Kara_noGUI.ActorsWorld.Actor",
    "category": "Type",
    "text": "Actor(actor_definition::Actor_Definition,location::Location,orientation::Orientation)\n\nDefines the actual actor which is placed on the world.\n\nExamples\n\nThe following creates an actor which can be moved and turned. It is placed at (0,0) in the world and looks north.\n\njulia> Actor(\n    Actor_Definition(moveable=true,turnable=true),\n    Location(0,0),\n    Orientation(:NORTH)\n)\n\n\n\n"
},

{
    "location": "actorsworld.html#Kara.Kara_noGUI.ActorsWorld.actor_create!",
    "page": "Actors World",
    "title": "Kara.Kara_noGUI.ActorsWorld.actor_create!",
    "category": "Function",
    "text": "actor_create!(wo::World,a_def::Actor_Definition,lo::Location,or::Orientation)\n\nCreates a new actor defined by the actor definition a_def at Location lo, oriented in or. The actor is added to the world wo.\n\nThe functions returns the newly generated actor, thus to enable interaction it should be stored.\n\nExamples\n\njulia> wo = World(10,10)\njulia> adef = Actor_Definition(\n    moveable=true,\n    turnable=true\n)\njulia> ac_new = actor_create(\n    wo,adef,\n    Location(1,1),Orientation(:NORTH)\n)\njulia> actor_move!(wo,ac_new,:NORTH)\n\n\n\n"
},

{
    "location": "actorsworld.html#Kara.Kara_noGUI.ActorsWorld.actor_delete!",
    "page": "Actors World",
    "title": "Kara.Kara_noGUI.ActorsWorld.actor_delete!",
    "category": "Function",
    "text": "actor_delete!(wo::World,ac::Actor)\n\nDelete the actor ac from the World wo.\n\n\n\n"
},

{
    "location": "actorsworld.html#Kara.Kara_noGUI.ActorsWorld.actor_moveto!",
    "page": "Actors World",
    "title": "Kara.Kara_noGUI.ActorsWorld.actor_moveto!",
    "category": "Function",
    "text": "actor_moveto!(wo::World,ac::Actor,lo::Location)\n\nMoves ac to lo after validating.\n\n\n\n"
},

{
    "location": "actorsworld.html#Kara.Kara_noGUI.ActorsWorld.actor_move!",
    "page": "Actors World",
    "title": "Kara.Kara_noGUI.ActorsWorld.actor_move!",
    "category": "Function",
    "text": "actor_move!(wo::World,ac::Actor,direction::Symbol[,parent::Bool])\n\nMove the actor ac one step in the direction direction with the world wo. The optional attribute parent should never be used directly as its purpos is to only allow the movemnt of one consecutive moveable actor. It actually stops the movement recursion by switching from true to false, which only allows one nested layer of recursion.\n\n\n\n"
},

{
    "location": "actorsworld.html#Kara.Kara_noGUI.ActorsWorld.actor_rotate!",
    "page": "Actors World",
    "title": "Kara.Kara_noGUI.ActorsWorld.actor_rotate!",
    "category": "Function",
    "text": "actor_rotate!(ac::Actor,direction::Bool)\n\nRotate an actor ac by 1 step counter-clockwise for false and clockwise for true.\n\n\n\n"
},

{
    "location": "actorsworld.html#Kara.Kara_noGUI.ActorsWorld.actor_pickup!",
    "page": "Actors World",
    "title": "Kara.Kara_noGUI.ActorsWorld.actor_pickup!",
    "category": "Function",
    "text": "actor_pickup!(wo::World,ac::Actor)\n\nRemove an grabable actor from the same location ac is at. Only elements one layer beneath the actors can be picked up.\n\n\n\n"
},

{
    "location": "actorsworld.html#Kara.Kara_noGUI.ActorsWorld.actor_putdown!",
    "page": "Actors World",
    "title": "Kara.Kara_noGUI.ActorsWorld.actor_putdown!",
    "category": "Function",
    "text": "actor_putdown!(wo::Word,ac::Actor,acd_put::Actor_Definition)\n\nCreate an actor of type acd_put at ac's location with ac's orientation. Only works if acd_put has grabable=true.\n\n\n\n"
},

{
    "location": "actorsworld.html#Kara.Kara_noGUI.ActorsWorld.actor_validate_location_move",
    "page": "Actors World",
    "title": "Kara.Kara_noGUI.ActorsWorld.actor_validate_location_move",
    "category": "Function",
    "text": "actor_validate_location_move(wo::World,a_def::Actor_Definition,lo::Location)\n\nValidate if it's possible to place an actor of type a_def at lo.\n\n\n\n"
},

{
    "location": "actorsworld.html#Kara.Kara_noGUI.ActorsWorld.get_actors_at_location",
    "page": "Actors World",
    "title": "Kara.Kara_noGUI.ActorsWorld.get_actors_at_location",
    "category": "Function",
    "text": "get_actors_at_location(wo::World,lo::Location)\n\nReturn a list of actors at lo. If no actor is at lo return [].\n\n\n\n"
},

{
    "location": "actorsworld.html#Kara.Kara_noGUI.ActorsWorld.get_actors_at_location_on_layer",
    "page": "Actors World",
    "title": "Kara.Kara_noGUI.ActorsWorld.get_actors_at_location_on_layer",
    "category": "Function",
    "text": "get_actors_at_location_on_layer(wo::World,lo::Location,layer::Int)\n\nReturn a list of actors at lo on layer. If no actor is at lo return [].\n\n\n\n"
},

{
    "location": "actorsworld.html#Kara.Kara_noGUI.ActorsWorld.actor_definition_at_location",
    "page": "Actors World",
    "title": "Kara.Kara_noGUI.ActorsWorld.actor_definition_at_location",
    "category": "Function",
    "text": "actor_definition_at_location(wo::World,lo::Location,acd::Actor_Definition)\n\nChecks if an actor of type acd is at lo in wo.\n\n\n\n"
},

{
    "location": "actorsworld.html#Kara.Kara_noGUI.ActorsWorld.is_actor_definition_left",
    "page": "Actors World",
    "title": "Kara.Kara_noGUI.ActorsWorld.is_actor_definition_left",
    "category": "Function",
    "text": "is_actor_definition_left(wo::World,ac::Actor,acd::Actor_Definition)\n\nChecks if an actor of type acd is left of ac.\n\n\n\n"
},

{
    "location": "actorsworld.html#Kara.Kara_noGUI.ActorsWorld.is_actor_definition_right",
    "page": "Actors World",
    "title": "Kara.Kara_noGUI.ActorsWorld.is_actor_definition_right",
    "category": "Function",
    "text": "is_actor_definition_right(wo::World,ac::Actor,acd::Actor_Definition)\n\nChecks if an actor of type acd is right of ac.\n\n\n\n"
},

{
    "location": "actorsworld.html#Kara.Kara_noGUI.ActorsWorld.is_actor_definition_front",
    "page": "Actors World",
    "title": "Kara.Kara_noGUI.ActorsWorld.is_actor_definition_front",
    "category": "Function",
    "text": "is_actor_definition_front(wo::World,ac::Actor,acd::Actor_Definition)\n\nChecks if an actor of type acd is front of ac.\n\n\n\n"
},

{
    "location": "actorsworld.html#Kara.Kara_noGUI.ActorsWorld.is_actor_definition_here",
    "page": "Actors World",
    "title": "Kara.Kara_noGUI.ActorsWorld.is_actor_definition_here",
    "category": "Function",
    "text": "is_actor_definition_here(wo::World,ac::Actor,acd::Actor_Definition)\n\nChecks if an actor of type acd is here of ac.\n\n\n\n"
},

{
    "location": "actorsworld.html#Actors-1",
    "page": "Actors World",
    "title": "Actors",
    "category": "section",
    "text": "Actor_Definition\nActor\nactor_create!\nactor_delete!\nactor_moveto!\nactor_move!\nactor_rotate!\nactor_pickup!\nactor_putdown!\nactor_validate_location_move\nget_actors_at_location\nget_actors_at_location_on_layer\nactor_definition_at_location\nis_actor_definition_left\nis_actor_definition_right\nis_actor_definition_front\nis_actor_definition_here\n"
},

{
    "location": "actorsworld.html#Index-1",
    "page": "Actors World",
    "title": "Index",
    "category": "section",
    "text": ""
},

]}
