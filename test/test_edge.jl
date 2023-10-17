using Test

using RedisGraph: Node, Edge, string


@testset "RedisGraph.jl edge unittests" begin
    @testset "check edge string" begin
        node_src = Node("SrcAlias", ["MyLabel1"], Dict("IntProp" => 1))
        node_dst = Node("DstAlias", ["MyLabel1", "MyLabel2"], Dict("BoolProp" => false))
        node_src_str = string(node_src)
        node_dst_src = string(node_dst)

        edge = Edge("Rel", node_src, node_dst)
        @test string(edge) == "$node_src_str-[:Rel ]->$node_dst_src"

        edge = Edge("", node_src, node_dst)
        @test string(edge) == "$node_src_str-[ ]->$node_dst_src"

        edge = Edge("Rel", node_src, node_dst, Dict("IntProp" => 1))
        @test string(edge) == "$node_src_str-[:Rel {IntProp: 1}]->$node_dst_src"
    end

    @testset "check edge isequal" begin
        node_src = Node(2)
        node_dst = Node(3)
        node_wrong = Node(4)
        edge = Edge("Rel", node_src, node_dst)
        @test edge == Edge("Rel", node_src, node_dst)
        @test edge != Edge("Rel", node_dst, node_src)
        @test edge != Edge("WrongRel", node_src, node_dst)
        @test edge != Edge("Rel", node_wrong, node_dst)
        @test edge != Edge("Rel", node_src, node_wrong)
        @test edge != Edge("Rel", node_src, node_dst, Dict("IntProp" => 1))
    end
end
