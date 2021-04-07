# RedisGraph Julia client

## Usage example

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

## Prerequisites

julia >= 1.6.0  
redisgraph >= 2.0  

## Setup

1. redisgraph needs to be running.

You can install it [manually](https://docs.redislabs.com/latest/modules/redisgraph/redisgraph-quickstart/)  
Or you can use [docker container](https://hub.docker.com/r/redislabs/redisgraph) instead of. For example:

```
docker run -p 6379:6379 -it --rm redislabs/redisgraph
```

2. add the [Redis Package](https://github.com/JuliaDatabases/Redis.jl)

```julia
julia> ]
pkg> add Redis
```

3. add RedisGraph from the github repo

```julia
pkg> add https://github.com/xyxel/RedisGraph.jl
```

More information about package management: https://pkgdocs.julialang.org/v1/
