using Redis: execute_command, flatten


function commit(g::Graph)
    if (length(g.nodes) == 0 && length(g.edges) == 0)
        return
    end

    items = vcat(string.(values(g.nodes)), string.(g.edges))

    query_str = "CREATE " * join(items, ",")
    return query(g, query_str)
end


function query(g::Graph, q::String)
    response = execute_command(g.redis_conn, flatten(["GRAPH.QUERY", g.id, q, "--compact"]))
    return QueryResult(g, response)
end


function ro_query(g::Graph, q::String)
    response = execute_command(g.redis_conn, flatten(["GRAPH.RO_QUERY", g.id, q, "--compact"]))
    return QueryResult(g, response)
end


function profile(g::Graph, q::String)
    response = execute_command(g.redis_conn, flatten(["GRAPH.PROFILE", g.id, q, "--compact"]))
return QueryResult(g, response)
end


function show_log(g::Graph)
    response = execute_command(g.redis_conn, flatten(["GRAPH.SHOWLOG", g.id]))
    return response
end


function flush!(g::Graph)
    commit(g)
    g.nodes = Dict()
    g.edges = Array{Edge, 1}()
end


function delete(g::Graph)
    execute_command(g.redis_conn, flatten(["GRAPH.DELETE", g.id]))
end


function merge(g::Graph, pattern::String)
    query_str = "MERGE $pattern"
    return query(g, query_str)
end


function setconfig(g::Graph, param_name::String, value)
    return execute_command(g.redis_conn, flatten(["GRAPH.CONFIG", "SET", param_name, value]))
end


function getconfig(g::Graph, param_name::String)
    return execute_command(g.redis_conn, flatten(["GRAPH.CONFIG", "GET", param_name]))
end
