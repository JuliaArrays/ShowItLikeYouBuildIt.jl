# ShowItLikeYouBuildIt

[![Build Status](https://travis-ci.org/JuliaArrays/ShowItLikeYouBuildIt.jl.svg?branch=master)](https://travis-ci.org/JuliaArrays/ShowItLikeYouBuildIt.jl)

[![codecov.io](http://codecov.io/github/JuliaArrays/ShowItLikeYouBuildIt.jl/coverage.svg?branch=master)](http://codecov.io/github/JuliaArrays/ShowItLikeYouBuildIt.jl?branch=master)

ShowItLikeYouBuild it is designed to simplify the printing of certain
types in Julia. Specifically, this package currently provides tools
for simplifying the `summary` of arrays.

# Example of usage

Currently, the printing of a simple array looks like this:
```jl
julia> a = reshape(1:12, 3, 4)
3×4 Base.ReshapedArray{Int64,2,UnitRange{Int64},Tuple{}}:
 1  4  7  10
 2  5  8  11
 3  6  9  12
```
It's worth noting that printing of the type information is both longer and more complex than the sequence of commands needed to construct the object.

The idea of this package is that it might simplify the type information if one instead showed a sequence of function calls that might do something similar. First, we have to define a special `show` function:

```
function ShowItLikeYouBuildIt.showtypeof(io::IO, A::Base.ReshapedArray)
    P = parent(A)
    print(io, "reshape(")
    if ShowItLikeYouBuildIt.shows_compactly(typeof(P))
        print(io, "::", typeof(P))
    else
        ShowItLikeYouBuildIt.showtypeof(io, P)
    end
    print(io, ", ", A.dims, ')')
end
```
and then we hook this up to the `summary` function:
```jl
Base.summary(A::Base.ReshapedArray) = summary_compact(A)
```

Now the printing of this array looks like this:
```jl
julia> a = reshape(1:12, 3, 4)
3×4 reshape(::UnitRange{Int64}, (3,4)) with element type Int64:
 1  4  7  10
 2  5  8  11
 3  6  9  12
```

The noteworthy thing here is that we're displaying the type via a set
of function calls that would produce an object with this type.
