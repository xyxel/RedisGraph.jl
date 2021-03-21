RedisGraph Julia client

The client doesn't support redisgraph 1.x

Usage example:

```julia
using Redis
using RedisGraph

db_conn = Redis.RedisConnection()
g = RedisGraph.Graph("TestGraph", db_conn)

node1 = Node("FirstSimpleNode", Dict("IntProp" => 1, "StringProp" => "node prop", "BoolProp" => true))
node2 = Node("SecondSimpleNode")
edge = Edge("SimpleEdge", node1, node2, Dict("IntProp" => 1, "StringProp" => "node prop", "BoolProp" => false))

RedisGraph.addnode!(g, node1)
RedisGraph.addnode!(g, node2)
RedisGraph.addedge!(g, edge)
res = RedisGraph.commit(g)

res = RedisGraph.query(g, "MATCH (n1)-[e]->(n2) RETURN n1, e, n2")
println(res.results[1])

RedisGraph.delete(g)
```
