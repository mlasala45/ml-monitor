module Async
export async

function async(f::T, on_err::Function=e -> nothing) where {T<:Function}
    Threads.@spawn begin
        try
            f()
        catch e
            on_err()
        end
    end
end

end