using Redis
using RedisGraph, Test

function creategraph()
    db_conn = Redis.RedisConnection()
    g = RedisGraph.Graph("test1", db_conn)
    return g
end


function simplerelation!(g::RedisGraph.Graph)
    node1 = RedisGraph.Node("test1")
    node2 = RedisGraph.Node("test2")
    edge = RedisGraph.Edge("edge1", node1, node2)

    RedisGraph.addnode!(g, node1)
    RedisGraph.addnode!(g, node2)
    RedisGraph.addedge!(g, edge)
    res = RedisGraph.commit(g)
end    


function rel_withprops!(g::RedisGraph.Graph)
    node3 = RedisGraph.Node("test3", Dict("a" => 1))
    node4 = RedisGraph.Node("test4")
    edge2 = RedisGraph.Edge(1, "edge2", node3, node4, Dict("b" => 1))

    RedisGraph.addnode!(g, node3)
    RedisGraph.addnode!(g, node4)
    RedisGraph.addedge!(g, edge2)
    res = RedisGraph.commit(g)
end


function deletegraph!(g::RedisGraph.Graph)
    RedisGraph.delete(g)
end


g = creategraph()
simplerelation!(g)
rel_withprops!(g)

@test RedisGraph.query(g, "MATCH (n1)-[e]->(n2) RETURN 2").results[1] == 2
@test RedisGraph.query(g, "MATCH (n1)-[e]->(n2) RETURN 2.0").results[1] == 2.0
@test RedisGraph.query(g, "MATCH (n1)-[e]->(n2) RETURN true").results[1] == true
@test typeof(RedisGraph.query(g, "MATCH (n1)-[e]->(n2) RETURN n1").results[1]) == RedisGraph.Node
@test typeof(RedisGraph.query(g, "MATCH (n1)-[e]->(n2) RETURN e").results[1]) == RedisGraph.SimpleEdge
@test RedisGraph.getnode(g, 0).label == "test1" 

deletegraph!(g)
