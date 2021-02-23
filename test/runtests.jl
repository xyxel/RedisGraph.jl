using Test
using Redis: RedisConnection
using RedisGraph: Graph, Node, Edge, addnode!, addedge!, commit, delete, query


function creategraph()
    db_conn = RedisConnection()
    g = Graph("test1", db_conn)
    return g
end


function simplerelation!(g::Graph)
    node1 = Node("test1")
    node2 = Node("test2")
    edge = Edge("edge1", node1, node2)

    addnode!(g, node1)
    addnode!(g, node2)
    addedge!(g, edge)
    res = commit(g)
end


function rel_withprops!(g::Graph)
    node3 = Node("test3", Dict("a" => 1))
    node4 = Node("test4")
    edge2 = Edge(1, "edge2", node3, node4, Dict("b" => 1))

    addnode!(g, node3)
    addnode!(g, node4)
    addedge!(g, edge2)
    res = commit(g)
end


function deletegraph!(g::Graph)
    delete(g)
end


g = creategraph()
try
    simplerelation!(g)
    rel_withprops!(g)

    @test query(g, "RETURN null").results[1] === nothing
    @test query(g, "RETURN 2").results[1] == 2
    @test query(g, "RETURN 2.0").results[1] == 2.0
    @test query(g, "RETURN true").results[1] == true
    @test query(g, "RETURN [1, 2, 'test', 3.0, false]").results[1] == [1, 2, "test", 3.0, false]
    @test typeof(query(g, "MATCH (n1)-[e]->(n2) RETURN n1").results[1]) == Node
    @test typeof(query(g, "MATCH (n1)-[e]->(n2) RETURN e").results[1]) == Edge
finally
    deletegraph!(g)
end
