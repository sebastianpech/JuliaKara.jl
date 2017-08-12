module kara_xml

using Base.Test
include("../src/Kara_noGUI.jl"); using .Kara_noGUI

@testset "Kara XML" begin
    path = joinpath(@__DIR__,"..","test","example.world")
    load_world = kara_xml.Kara_noGUI.xml_load_world(path)
    act = load_world.actors
    
    @test Kara_noGUI.get_actors_at_location(load_world,Kara_noGUI.Location(7, 8))[1].actor_definition == Kara_noGUI.ACTOR_DEFINITIONS[:tree]
    @test Kara_noGUI.get_actors_at_location(load_world,Kara_noGUI.Location(7, 7))[1].actor_definition == Kara_noGUI.ACTOR_DEFINITIONS[:tree]
    @test Kara_noGUI.get_actors_at_location(load_world,Kara_noGUI.Location(7, 6))[1].actor_definition == Kara_noGUI.ACTOR_DEFINITIONS[:tree]
    @test Kara_noGUI.get_actors_at_location(load_world,Kara_noGUI.Location(3, 5))[1].actor_definition == Kara_noGUI.ACTOR_DEFINITIONS[:mushroom]
    @test Kara_noGUI.get_actors_at_location(load_world,Kara_noGUI.Location(3, 4))[1].actor_definition == Kara_noGUI.ACTOR_DEFINITIONS[:mushroom]
    @test Kara_noGUI.get_actors_at_location(load_world,Kara_noGUI.Location(3, 3))[1].actor_definition == Kara_noGUI.ACTOR_DEFINITIONS[:mushroom]
    @test Kara_noGUI.get_actors_at_location(load_world,Kara_noGUI.Location(7, 3))[1].actor_definition == Kara_noGUI.ACTOR_DEFINITIONS[:leaf]
    @test Kara_noGUI.get_actors_at_location(load_world,Kara_noGUI.Location(8, 3))[1].actor_definition == Kara_noGUI.ACTOR_DEFINITIONS[:leaf]
    @test Kara_noGUI.get_actors_at_location(load_world,Kara_noGUI.Location(9, 3))[1].actor_definition == Kara_noGUI.ACTOR_DEFINITIONS[:leaf]
    @test Kara_noGUI.get_actors_at_location(load_world,Kara_noGUI.Location(3, 8))[1].actor_definition == Kara_noGUI.ACTOR_DEFINITIONS[:kara]
    
    path_save = joinpath(@__DIR__,"..","test","example_save.world")
    kara_xml.Kara_noGUI.xml_save_world(load_world,path_save)
    @test isfile(path_save) == true
    rm(path_save)
    @test isfile(path_save) == false
end

end
