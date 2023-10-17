using Test

using RedisGraph: Node, string


@testset "RedisGraph.jl node unittests" begin
    @testset "check node string" begin
        @test string(Node("MyAlias", ["MyLabel1", "MyLabel2"])) == "(MyAlias:MyLabel1:MyLabel2 )"
        node_with_props = Node("MyAlias", ["MyLabel1"], Dict("IntProp" => 1, "StringProp" => "node prop", "BoolProp" => false))
        @test string(node_with_props) == "(MyAlias:MyLabel1 {StringProp: \"node prop\",IntProp: 1,BoolProp: false})" 
    end

    @testset "check node isequal" begin
        @test Node(2) == Node(2)
        @test Node(3) != Node(2)
        node = Node(4, ["Label4"], Dict("IntProp" => 1, "StringProp" => "node prop", "BoolProp" => false))
        node_the_same = Node(4, ["Label4"], Dict("IntProp" => 1, "StringProp" => "node prop", "BoolProp" => false))
        node_wrong_id = Node(3, ["Label4"], Dict("IntProp" => 1, "StringProp" => "node prop", "BoolProp" => false))
        node_wrong_label = Node(4, ["Labe4"], Dict("IntProp" => 1, "StringProp" => "node prop", "BoolProp" => false))
        node_wrong_label_amount = Node(4, ["Label4", "Label2"], Dict("IntProp" => 1, "StringProp" => "node prop", "BoolProp" => false))
        node_wrong_props = Node(4, ["Label4"], Dict("IntProp" => 2, "StringProp" => "node prop", "BoolProp" => false))

        @test node == node_the_same
        @test node != node_wrong_id
        @test node != node_wrong_label
        @test node != node_wrong_label_amount
        @test node != node_wrong_props
    end
end
