using Base: showarg

function summary_build(A)
    # This is just a copy of Base.summary, but copying it prevents a
    # StackOverflow
    io = IOBuffer()
    summary(io, A)
    String(take!(io))
end
function summary_build(A, cthresh)
    Base.depwarn("summary_build(A, cthresh) is deprecated (and cthresh isn't used), just use summary(A)", :summary_build)
    summary_build(A)
end

# Not perfect, but better to have this than not
Base.showarg(io::IO, x) = showarg(io, x, false)

function type_complexity(x)
    Base.depwarn("type_complexity is deprecated, please use 1", :type_complexity)
    1
end
