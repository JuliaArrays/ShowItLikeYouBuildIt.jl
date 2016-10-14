__precompile__()

module ShowItLikeYouBuildIt

export summary_compact, shows_compactly

show_complexity(x)            = 1
show_complexity{T}(::Type{T}) = isempty(T.parameters) ? 1 : sum(show_complexity, T.parameters)+1

shows_compactly{T}(::Type{T})  = show_complexity(T) <= length(T.parameters)+1

showtypeof(io::IO, x)                = show(io, typeof(x))
showtypeof{T}(io::IO, ::Type{T})     = show(io, T)

function summary_compact(io::IO, A::AbstractArray)
    shows_compactly(typeof(A)) && return print(io, summary(A))
    print(io, dimstring(indices(A)), ' ')
    showtypeof(io, A)
    print(io, " with element type ", eltype(A))
end
function summary_compact(A::AbstractArray)
    io = IOBuffer()
    summary_compact(io, A)
    String(io)
end

dimstring(inds) = Base.inds2string(inds)
dimstring(inds::Tuple{Vararg{Base.OneTo}}) = Base.dims2string(map(length, inds))

end # module
