module kara_ex01
using Base.Test
using Kara

@World wtest (10,10)
kara = @wtest place_kara(4,4)

function nextTest(world,kara)
    turnRight(world,kara)
    move(world,kara)
    turnLeft(world,kara)
end

@testset "Kara Example 01" begin


    @wtest begin
        place_tree(4,5)
        place_tree(5,6)
        place_mushroom(5,5)
        place_mushroom(6,5)
        place_mushroom(6,6)
        place_mushroom(7,5)
        place_leaf(8,5)
    end

    @test_throws Kara.Kara_noGUI.ActorNotPassableError @wtest move(kara)
    nextTest(wtest,kara)
    @test_throws Kara.Kara_noGUI.ActorNotPassableError @wtest move(kara)
    nextTest(wtest,kara)
    @test_throws Kara.Kara_noGUI.ActorInvalidMultipleMovementError @wtest move(kara)
    nextTest(wtest,kara)
    @wtest move(kara)
    @test (@wtest mushroomFront(kara)) == true
    @wtest begin
        turnLeft(kara)
        turnLeft(kara)
        move(kara)
        turnLeft(kara)
        turnLeft(kara)
    end
    @test (@wtest mushroomFront(kara)) == false
    nextTest(wtest,kara)
    @wtest move(kara)
    @test (@wtest onLeaf(kara)) == true
    @wtest removeLeaf(kara)
    @test (@wtest onLeaf(kara)) == false
    @test_throws Kara.Kara_noGUI.ActorGrabNotFoundError @wtest removeLeaf(kara)
    @wtest putLeaf(kara)
    @test (@wtest onLeaf(kara)) == true
    @test (@wtest treeLeft(kara)) == false
    @test (@wtest treeRight(kara)) == false
    @test (@wtest treeFront(kara)) == false
    @wtest place_tree(7,5)
    @wtest place_tree(9,5)
    @wtest place_tree(8,6)
    @test (@wtest treeLeft(kara)) == true
    @test (@wtest treeRight(kara)) == true
    @test (@wtest treeFront(kara)) == true
end
end
