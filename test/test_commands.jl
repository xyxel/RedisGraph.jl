using Test

using RedisGraph: Graph, getdatabase, setconfig, getconfig, query, ro_query, profile, slowlog


function creategraph()
    db_conn = getdatabase()
    g = Graph("TestGraph", db_conn)
    return g
end


function deletegraph!(g::Graph)
    delete(g)
end


@testset "Basic check commands" begin
    g = creategraph()
    try
        @test query(g, "RETURN null").results[1] === nothing

        @test ro_query(g, "RETURN [1, null, 'test', 3.0, false]").results[1] == [1, nothing, "test", 3.0, false]

        @test occursin("Records produced: 1", profile(g, "RETURN null")[1])

        commands_in_log =  [log_entry[2] for log_entry in slowlog(g)]
        @test "GRAPH.QUERY" in commands_in_log
        @test "GRAPH.RO_QUERY" in commands_in_log
        @test "GRAPH.PROFILE" in commands_in_log

        setconfig(g, "MAX_QUEUED_QUERIES", 500)
        @test getconfig(g, "MAX_QUEUED_QUERIES") == ["MAX_QUEUED_QUERIES", 500]
        setconfig(g, "MAX_QUEUED_QUERIES", 600)
        @test getconfig(g, "MAX_QUEUED_QUERIES") == ["MAX_QUEUED_QUERIES", 600]
        @test length(getconfig(g, "*")) > 2
    finally
        deletegraph!(g)
    end
end
