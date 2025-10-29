# RedisGraph Julia client

## DEPRECATED

The repo will not be updated anymore. Please consider using FalkorDB.jl instead.

## Usage example

```julia
using RedisGraph

db_conn = getdatabase()
g = Graph("TestGraph", db_conn)

node1 = Node("FirstSimpleNode", ["Label1"], Dict("IntProp" => 1, "StringProp" => "node prop", "BoolProp" => true))
node2 = Node("SecondSimpleNode", ["Label2", "Label3"])
edge = Edge("SimpleEdge", node1, node2, Dict("IntProp" => 1, "StringProp" => "node prop", "BoolProp" => false))

addnode!(g, node1)
addnode!(g, node2)
addedge!(g, edge)
res = commit(g)

res = query(g, "MATCH (n1)-[e]->(n2) RETURN n1, e, n2")
println(res.results[1])

delete(g)
```

## Prerequisites

julia >= 1.6.0  
redisgraph >= 2.8  

## Setup

1. redisgraph needs to be running.

You can install it [manually](https://docs.redislabs.com/latest/modules/redisgraph/redisgraph-quickstart/)  
Or you can use [docker container](https://hub.docker.com/r/redislabs/redisgraph) instead of. For example:

```
docker run -p 6379:6379 -it --rm redislabs/redisgraph
```

2. add RedisGraph from the github repo

```julia
pkg> add https://github.com/xyxel/RedisGraph.jl
```

More information about package management: https://pkgdocs.julialang.org/v1/
