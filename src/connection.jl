
using Redis: RedisConnection

function getdatabase(;host::AbstractString="127.0.0.1", port::Integer=6379, password::AbstractString="", db::Integer=0)
    db_conn = RedisConnection(host=host, port=port, password=password, db=db)
    return db_conn
end
