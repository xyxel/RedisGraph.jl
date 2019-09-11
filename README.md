RedisGraph Julia client

Usage example:

```julia
using Redis
using RedisGraph

db_conn = Redis.RedisConnection()
g = RedisGraph.Graph("test1", db_conn)

node1 = RedisGraph.Node("test1", Dict("a" => 1))
node2 = RedisGraph.Node("test2")
edge = RedisGraph.Edge("edge1", node1, node2, Dict("b" => 1))

RedisGraph.addnode!(g, node1)
RedisGraph.addnode!(g, node2)
RedisGraph.addedge!(g, edge)
res = RedisGraph.commit(g)

res = RedisGraph.query(g, "MATCH (node) WHERE ID(node) = 1 RETURN node")
println(res.results[1])

RedisGraph.delete(g)
```
