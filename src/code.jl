"""
    type_complexity(T::Type) -> c

Return an integer `c` representing a measure of the "complexity" of
type `T`. For unnested types, `c = n+1` where `n` is the number of
parameters in type `T`. However, `type_complexity` calls itself
recursively on the parameters, so if the parameters have their own
parameters then the complexity of the type will be (potentially much)
higher than this.

# Examples

    # Array{Float64,2}
    julia> a = rand(3,5);

    julia> type_complexity(typeof(a))
    3

    julia> length(typeof(a).parameters)+1
    3

    # Create an object that has type:
    #    SubArray{Int64,2,Base.ReshapedArray{Int64,2,UnitRange{Int64},Tuple{}},Tuple{StepRange{Int64,Int64},Colon},false}
    julia> r = reshape(1:9, 3, 3);

    julia> v = view(r, 1:2:3, :);

    julia> type_complexity(typeof(v))
    15

    julia> length(typeof(v).parameters)+1
    6

The second example indicates that the total complexity of `v`'s type
is considerably higher than the complexity of just its "outer"
SubArray type.
"""
function type_complexity(::Type{T}) where T
    if isa(T, Union)
        1 + type_complexity(T.b)
    else
        isempty(T.parameters) ? 1 : sum(type_complexity, T.parameters)+1
    end
end
type_complexity(::Type{Union{}}) = 1
type_complexity(x)               = 1

# Fallback definitions
"""
    showarg(stream::IO, x)

Show `x` as if it were an argument to a function. This function is
used in the printing of "type summaries" in terms of sequences of
function calls on objects.

The fallback definition is to print `x` as `::\$(typeof(x))`,
representing argument `x` in terms of its type. However, you can
specialize this function for specific types to customize printing.

# Example

A SubArray created as `view(a, :, 3, 2:5)`, where `a` is a
3-dimensional Float64 array, has type

    SubArray{Float64,2,Array{Float64,3},Tuple{Colon,Int64,UnitRange{Int64}},false}

and this type will be printed in the summary. To change the printing of this object to

    view(::Array{Float64,3}, Colon(), 3, 2:5)

you could define

    function ShowItLikeYouBuildIt.showarg(io::IO, v::SubArray)
        print(io, "view(")
        showarg(io, parent(v))
        print(io, ", ", join(v.indexes, ", "))
        print(io, ')')
    end

Note that we're calling `showarg` recursively for the parent array
type.  Printing the parent as `::Array{Float64,3}` is the fallback
behavior, assuming no specialized method for `Array` has been defined.
More generally, this would display as

    view(<a>, Colon(), 3, 2:5)

where `<a>` is the output of `showarg` for `a`.

This printing might be activated any time `v` is a field in some other
container, or if you specialize `Base.summary` for `SubArray` to call
`summary_build`.

See also: summary_build.
"""
showarg(io::IO, ::Type{T}) where {T} = print(io, "::Type{", T, "}")
showarg(io::IO, x) = print(io, "::", typeof(x))

function summary_build(io::IO, A::AbstractArray, cthresh=default_cthresh(A))
    type_complexity(typeof(A)) <= cthresh && return show_summary_type(io, A)
    print(io, dimstring(indices(A)), ' ')
    showarg(io, A)
    print(io, " with element type ", eltype(A))
end

"""
    summary_build(A::AbstractArray, [cthresh])

Return a string representing `A` in terms of the sequence of function
calls that might be used to create `A`, along with information about
`A`'s size or indices and element type. This function should never be
called directly, but instead used to specialize `Base.summary` for
specific `AbstractArray` subtypes. For example, if you want to change
the summary of SubArray, you might define

    Base.summary(v::SubArray) = summary_build(v)

This function goes hand-in-hand with `showarg`. If you have defined a
`showarg` method for `SubArray` as in the documentation for `showarg`,
then the summary of a SubArray might look like this:

    3×4 view(::Array{Float64,3}, :, 3, 2:5) with element type Float64

instead of this:

    3×4 SubArray{Float64,2,Array{Float64,3},Tuple{Colon,Int64,UnitRange{Int64}},false}

The optional argument `cthresh` is a "complexity threshold"; objects
with type descriptions that are less complex than the specified
threshold will be printed using the traditional type-based
summary. The default value is `n+1`, where `n` is the number of
parameters in `typeof(A)`.  The complexity is calculated with
`type_complexity`. You can choose a `cthresh` of 0 if you want to
ensure that your `showarg` version is always used.

See also: showarg, type_complexity.
"""
function summary_build(A::AbstractArray, cthresh=default_cthresh(A))
    io = IOBuffer()
    summary_build(io, A, cthresh)
    String(io)
end

# This is effectively the "original summary" as defined in Base. We
# can't just use that function directly because `summary_build`
# should only be called by `summary` method that has been specialized
# for the type, so `summary` isn't available as a fallback.
show_summary_type(io::IO, A::AbstractArray) = print(io, dimstring(indices(A)), ' ', typeof(A))

default_cthresh(x) = default_cthresh(typeof(x))
default_cthresh(::Type{T}) where {T} = length(T.parameters)+1
