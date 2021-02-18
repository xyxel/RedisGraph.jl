const VALUE_TYPE_UNKNOWN = 0
const VALUE_TYPE_NULL = 1
const VALUE_TYPE_STRING = 2
const VALUE_TYPE_INTEGER = 3
const VALUE_TYPE_BOOLEAN = 4
const VALUE_TYPE_DOUBLE = 5
const VALUE_TYPE_ARRAY = 6
const VALUE_TYPE_EDGE = 7
const VALUE_TYPE_NODE = 8
const VALUE_TYPE_PATH = 9
const VALUE_TYPE_MAP = 10

struct VALUE_TYPE{x}
end

VALUE_TYPE(x) = VALUE_TYPE{x}()

const ENTRY_TYPE_UNKNOWN = 0
const ENTRY_TYPE_SCALAR = 1
const ENTRY_TYPE_NODE = 2  # Unused, retained for client compatibility.
const ENTRY_TYPE_RELATION = 3  # Unused, retained for client compatibility.

struct ENTRY_TYPE{x}
end

ENTRY_TYPE(x) = ENTRY_TYPE{x}()


function parsevalue(g::Graph, ::VALUE_TYPE{VALUE_TYPE_UNKNOWN}, raw_value::String) @assert false "Unknown scalar type" end
function parsevalue(g::Graph, ::VALUE_TYPE{VALUE_TYPE_NULL}, raw_value::String) return nothing end
function parsevalue(g::Graph, ::VALUE_TYPE{VALUE_TYPE_STRING}, raw_value::String) return raw_value end
function parsevalue(g::Graph, ::VALUE_TYPE{VALUE_TYPE_INTEGER}, raw_value::Int) return raw_value end
function parsevalue(g::Graph, ::VALUE_TYPE{VALUE_TYPE_BOOLEAN}, raw_value::String) return parse(Bool, raw_value) end
function parsevalue(g::Graph, ::VALUE_TYPE{VALUE_TYPE_DOUBLE}, raw_value::String) return parse(Float64, raw_value) end
function parsevalue(g::Graph, ::VALUE_TYPE{VALUE_TYPE_EDGE}, raw_entry::Vector{T} where T) return parseedge(g, raw_entry) end
function parsevalue(g::Graph, ::VALUE_TYPE{VALUE_TYPE_NODE}, raw_entry::Vector{T} where T) return parsenode(g, raw_entry) end


function parseprops(g::Graph, raw_props::Vector{T} where T)
    props = Dict()
    for raw_prop in raw_props
        prop_name = getprop(g, raw_prop[1])
        prop_value = parsescalar(SCALAR_TYPE(raw_prop[2]), raw_prop[3])
        props[prop_name] = prop_value
    end
    return props
end


function parsenode(g::Graph, raw_entry::Vector{T} where T)
    node_id = raw_entry[1]
    label = NaN
    if length(raw_entry[2]) != 0
        label = getlabel(g, raw_entry[2][1])
    end
    properties = parseprops(g, raw_entry[3])
    return Node(node_id, "", label, properties)
end


function parseedge(g::Graph, raw_entry::Vector{T} where T)
    edge_id = raw_entry[1]
    relation = getrelation(g, raw_entry[2])
    src_node_id = raw_entry[3]
    dst_node_id = raw_entry[4]
    properties = parseprops(g, raw_entry[5])
    return Edge(edge_id, relation, src_node_id, dst_node_id, properties)
end


function parseentry(g::Graph, raw_entry::Vector{T} where T, ::ENTRY_TYPE{ENTRY_TYPE_UNKNOWN}) @assert false "Unknown result entry" end
function parseentry(g::Graph, raw_entry::Vector{T} where T, ::ENTRY_TYPE{ENTRY_TYPE_SCALAR}) return parsevalue(g, VALUE_TYPE(raw_entry[1]), raw_entry[2]) end
function parseentry(g::Graph, raw_entry::Vector{T} where T, ::ENTRY_TYPE{ENTRY_TYPE_NODE}) return parsenode(g, raw_entry) end
function parseentry(g::Graph, raw_entry::Vector{T} where T, ::ENTRY_TYPE{ENTRY_TYPE_RELATION}) return parseedge(g, raw_entry) end


function parsestatistics(raw_stats::Vector{String})
    statistics = Dict()
    for stat in raw_stats
        stat_name, stat_value = split(stat, ": ")
        statistics[stat_name] = parse(Float64, split(stat_value, " ")[1])
    end
    return statistics
end


function parseresults(g::Graph, raw_results::Vector{Vector{T} where T})
    if length(raw_results) == 0
        return nothing, nothing
    end

    header = ResultHeaderEntry.(raw_results[1])
    results = Vector{Any}()
    for row in raw_results[2]
        for (header_entry, raw_result_entry) in zip(header, row)
            entry = parseentry(g, raw_result_entry, ENTRY_TYPE(header_entry.r_entry_type))
            push!(results, entry)
        end
    end
    return header, results
end


struct ResultHeaderEntry
    r_entry_type::Int
    r_entry_name::String
    ResultHeaderEntry(raw_header_entry) = new(raw_header_entry[1], raw_header_entry[2])
end


struct QueryResult
    statistics::Dict{String, Float64}
    header::Union{Vector{ResultHeaderEntry}, Nothing}
    results::Union{Vector{Any}, Nothing}
    function QueryResult(g::Graph, raw_query_result::Vector{Vector{String}})
        stats = parsestatistics(raw_query_result[length(raw_query_result)])
        new(stats, nothing, nothing)
    end
    function QueryResult(g::Graph, raw_query_result::Vector{Vector{T} where T})
        stats = parsestatistics(raw_query_result[length(raw_query_result)])
        header, results = parseresults(g, raw_query_result[1:length(raw_query_result)-1])
        new(stats, header, results)
    end
end


function isempty(result::QueryResult)
    length(result.header) == 0
end
