const SCALAR_TYPE_UNKNOWN = 0
const SCALAR_TYPE_NULL = 1
const SCALAR_TYPE_STRING = 2
const SCALAR_TYPE_INTEGER = 3
const SCALAR_TYPE_BOOLEAN = 4
const SCALAR_TYPE_DOUBLE = 5

const ENTRY_TYPE_UNKNOWN = 0
const ENTRY_TYPE_SCALAR = 1
const ENTRY_TYPE_NODE = 2
const ENTRY_TYPE_RELATION = 3


function parsescalar(raw_value_tuple)
    scalar_type = raw_value_tuple[1]
    raw_value = raw_value_tuple[2]
    if scalar_type == SCALAR_TYPE_NULL
        value = nothing
    elseif scalar_type == SCALAR_TYPE_STRING
        value = raw_value  # string(raw_value)
    elseif scalar_type == SCALAR_TYPE_INTEGER
        value = raw_value  # parse(Int, raw_value)
    elseif scalar_type == SCALAR_TYPE_BOOLEAN
        value = parse(Bool, raw_value)
    elseif scalar_type == SCALAR_TYPE_DOUBLE
        value = parse(Float64, raw_value)
    else
        @assert false "Unknown scalar type"
    end
    value
end


function parseprops(g::Graph, raw_props)
    props = Dict()
    for raw_prop in raw_props
        prop_name = getprop(g, raw_prop[1])
        prop_value = parsescalar(raw_prop[2:length(raw_prop)])
        props[prop_name] = prop_value
    end
    return props
end


function parsenode(g::Graph, raw_entry)
    node_id = raw_entry[1]
    label = NaN
    if length(raw_entry[2]) != 0
        label = getlabel(g, raw_entry[2][1])
    end
    properties = parseprops(g, raw_entry[3])
    return Node(node_id, "", label, properties)
end


function parseedge(g::Graph, raw_entry)
    edge_id = raw_entry[1]
    relation = getrelation(g, raw_entry[2])
    src_node_id = raw_entry[3]
    dst_node_id = raw_entry[4]
    properties = parseprops(g, raw_entry[5])
    return SimpleEdge(edge_id, relation, src_node_id, dst_node_id, properties)
end


function parseentry(g::Graph, raw_entry, entry_type::UInt)
    if entry_type == ENTRY_TYPE_UNKNOWN
        @assert false "Unknown result entry"
    elseif entry_type == ENTRY_TYPE_SCALAR
        return parsescalar(raw_entry)
    elseif entry_type == ENTRY_TYPE_NODE
        return parsenode(g, raw_entry)
    elseif entry_type == ENTRY_TYPE_RELATION
        return parseedge(g, raw_entry)
    else
        @assert false "Unknown entry type"
    end
end


function parsestatistics(raw_stats::Vector{Any})
    statistics = Dict()
    for stat in raw_stats
        stat_name, stat_value = split(stat, ": ")
        statistics[stat_name] = parse(Float64, split(stat_value, " ")[1])
    end
    return statistics
end


function parseresults(g::Graph, raw_results)
    header = nothing
    results = nothing
    if length(raw_results) != 0
        header = ResultHeaderEntry.(raw_results[1])
        results = Vector{Any}()
        for row in raw_results[2]
            for (header_entry, raw_result_entry) in zip(header, row)
                entry = parseentry(g, raw_result_entry, header_entry.r_entry_type)
                push!(results, entry)
            end
        end
    end
    return header, results
end


function parsequery(g::Graph, raw_query_result)
    stats = parsestatistics(raw_query_result[length(raw_query_result)])
    header, results = parseresults(g, raw_query_result[1:length(raw_query_result)-1])
    stats, header, results
end


struct ResultHeaderEntry
    r_entry_type::UInt
    r_entry_name::String
    ResultHeaderEntry(raw_header_entry) = new(raw_header_entry[1], raw_header_entry[2])
end


struct QueryResult
    statistics::Dict{String, Float64}
    header::Union{Vector{ResultHeaderEntry}, Nothing}
    results::Union{Vector{Any}, Nothing}
    function QueryResult(g::Graph, raw_query_result)
        stats, header, results = parsequery(g, raw_query_result)
        new(stats, header, results)
    end
end


function isempty(result::QueryResult)
    length(result.header) == 0
end
