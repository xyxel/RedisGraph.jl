using Test

using RedisGraph: Graph, getdatabase, setconfig, getconfig


function creategraph()
    db_conn = getdatabase()
    g = Graph("TestGraph1", db_conn)
    return g
end


function deletegraph!(g::Graph)
    delete(g)
end


@testset "Basic check commands" begin
    g = creategraph()
    try
        setconfig(g, "MAX_QUEUED_QUERIES", 500)
        @test getconfig(g, "MAX_QUEUED_QUERIES") == ["MAX_QUEUED_QUERIES", 500]
        setconfig(g, "MAX_QUEUED_QUERIES", 600)
        @test getconfig(g, "MAX_QUEUED_QUERIES") == ["MAX_QUEUED_QUERIES", 600]
        @test length(getconfig(g, "*")) > 2
    finally
        deletegraph!(g)
    end
end
