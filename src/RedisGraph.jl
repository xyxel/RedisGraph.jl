module RedisGraph

export Node, Edge, Graph, SimpleEdge, QueryResult

export addnode!, addedge!

export commit, query, flush!, delete, merge

include("node.jl")
include("edge.jl")
include("graph.jl")
include("result.jl")
end
