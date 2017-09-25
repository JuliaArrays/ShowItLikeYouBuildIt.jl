__precompile__()

module ShowItLikeYouBuildIt

export showarg, summary_build, type_complexity

# This is just a stub package on Julia after the merger of #23389
if VERSION < v"0.7.0-DEV.1790"
    include("code.jl")
else
    include("stub.jl")
end

dimstring(inds) = Base.inds2string(inds)
dimstring(inds::Tuple{Vararg{Base.OneTo}}) = Base.dims2string(map(length, inds))

end # module
