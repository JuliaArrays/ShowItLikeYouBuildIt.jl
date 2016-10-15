# ShowItLikeYouBuildIt

[![Build Status](https://travis-ci.org/JuliaArrays/ShowItLikeYouBuildIt.jl.svg?branch=master)](https://travis-ci.org/JuliaArrays/ShowItLikeYouBuildIt.jl)

[![codecov.io](http://codecov.io/github/JuliaArrays/ShowItLikeYouBuildIt.jl/coverage.svg?branch=master)](http://codecov.io/github/JuliaArrays/ShowItLikeYouBuildIt.jl?branch=master)

ShowItLikeYouBuildIt is designed to simplify the printing of type
information (in certain contexts) in Julia. Specifically, this package
currently provides tools for simplifying the `summary` of arrays.

# Example of usage

Currently, the printing of a simple array looks like this:

```jl
julia> a = reshape(1:12, 3, 4)
3×4 Base.ReshapedArray{Int64,2,UnitRange{Int64},Tuple{}}:
 1  4  7  10
 2  5  8  11
 3  6  9  12
```

It's worth noting that printing of the type information in the first
line---produced by the Base function `summary`---is both longer and
more complex than the sequence of commands needed to construct the
object.

The idea of this package is to simplify the type information by
instead showing a sequence of function calls that would create an
identical type. To implement this for your own `AbstractArray` type,
the first step is to specialize the `showarg` function (which shows an
object `x` as if it were an argument to a function) for your array
type:

```jl
function ShowItLikeYouBuildIt.showarg(io::IO, A::Base.ReshapedArray)
    print(io, "reshape(")
    showarg(io, parent(A))
    print(io, ", ", A.dims, ')')
end
```

Next, we hook this up so that it gets called by Base's `summary` function:

```jl
Base.summary(A::Base.ReshapedArray) = summary_build(A)
```

`summary_build` is a simple function that prints the dimension string,
calls `showarg` on `A`, and then prints the element type. If you
wanted, you could customize `summary` differently from this; as long
as your method calls `showarg` on `A`, the machinery we've defined
will be actived.

Now the printing of this array looks like this:
```jl
julia> a = reshape(1:12, 3, 4)
3×4 reshape(::UnitRange{Int64}, (3,4)) with element type Int64:
 1  4  7  10
 2  5  8  11
 3  6  9  12
```

The noteworthy thing here is that we're displaying the type via a set
of function calls that would produce an object with this type. The
printing of the "inner" array as `::UnitRange{Int64}` is the default
behavior of `showarg`, printing information about the object in terms
of its type (as an argument to a function, not as a type-parameter,
hence the `::`).

In general, `showarg` methods for `AbstractArray` types that wrap
other arrays should call `showarg` on at least the "main" array in the
container. This allows the summary of a type to be printed as a nested
call sequence; for example, if one added a suitable definition of `showarg`
for `SubArray` (see `?showarg`), one might obtain the following:

```jl
a = rand(3,5,7)
v = view(a, :, 3, 2:5)
c = reshape(v, 4, 3)

julia> summary(c)
"4×3 reshape(view(::Array{Float64,3}, Colon(), 3, 2:5), (4,3)) with element type Float64"
```

which may be someone easier to understand than the default

```jl
"4×3 Base.ReshapedArray{Float64,2,SubArray{Float64,2,Array{Float64,3},Tuple{Colon,Int64,UnitRange{Int64}},false},Tuple{Base.MultiplicativeInverses.SignedMultiplicativeInverse{Int64}}}"
```

You can optionally supply a "complexity threshold" to `summary_build`;
objects whose types have complexity less than or equal to the
threshold will be printed using the traditional type-based
summary. See the documentation for `summary_build` and
`type_complexity` for more information.

It's worth emphasizing that this package does **not** itself change
the display of any objects; it simply provides the necessary tools. If
you're a package author and interested in using ShowItLikeYouBuildIt,
please keep the following guidelines in mind:

- it is reasonable to customize the printing of objects whose types are
  defined in your package.

- be wary about changing the display of types defined in `Base` (as we
  did above, for the purposes of illustration, with `ReshapedArray`
  and `SubArray`) or of types defined in other packages. Such changes
  will affect the printing of *all* such objects, and thus might have
  unintended consequences.
