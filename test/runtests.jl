using ShowItLikeYouBuildIt
using Base.Test
push!(LOAD_PATH, @__DIR__)
using ZArrays
pop!(LOAD_PATH)

const showit_old = VERSION < v"0.7.0-DEV.1790"
const eltype_string = showit_old ? "element type" : "eltype"

if showit_old
    printdims(io, dims) = print(io, dims)
else
    printdims(io, dims) = _printdims(io, dims...)
    _printdims(io, d1, d...) = (print(io, d1, ", "); _printdims(io, d...))
    _printdims(io, d1) = print(io, d1)
end
function printdims(dims)
    io = IOBuffer()
    printdims(io, dims)
    String(take!(io))
end

if showit_old
    for T in (Float64, Bool, Int8, UInt16, Symbol, String, Union{})
        @test type_complexity(T) == 1
    end
    @test type_complexity(Union{Float32,Int8}) == 2
    @test type_complexity(Array{Int,2}) == 3
    @test type_complexity(Array{Complex{Float32},2}) == 4
    @test type_complexity(Array{Array{Complex{Float32},1},2}) == 6
end

@test ShowItLikeYouBuildIt.dimstring(()) == "0-dimensional"

@test sprint(showarg, 3.0) == "::Float64"
@test sprint(showarg, Float64) == "::Type{Float64}"


# Display of objects

# Note that these next tests alter how SubArrays, ReshapedArrays, and
# PermutedDimsArrays are displayed; it's probably best to run this
# only in a "throwaway" julia session.

function ShowItLikeYouBuildIt.showarg(io::IO, v::SubArray)
    print(io, "view(")
    showarg(io, parent(v))
    print(io, ", ", join(v.indexes, ", "))
    print(io, ')')
end

function ShowItLikeYouBuildIt.showarg(io::IO, A::PermutedDimsArray{T,N,perm}) where {T,N,perm}
    print(io, "PermutedDimsArray(")
    showarg(io, parent(A))
    print(io, ", ", perm, ')')
end

function ShowItLikeYouBuildIt.showarg(io::IO, A::Base.ReshapedArray)
    print(io, "reshape(")
    showarg(io, parent(A))
    print(io, ", ")
    printdims(io, A.dims)
    print(io, ')')
end

Base.summary(A::SubArray) = summary_build(A)
Base.summary(A::Base.PermutedDimsArrays.PermutedDimsArray) = summary_build(A)
Base.summary(A::Base.ReshapedArray) = summary_build(A)

a = rand(3,5,7)
v = view(a, :, 3, 2:5)
view_name = showit_old ? "view(::Array{Float64,3}, $(v.indexes[1]), 3, 2:5)" :
                         "view(::Array{Float64,3}, :, 3, 2:5)"
@test summary(v) == "3×4 $view_name with $eltype_string Float64"

c = reshape(v, 4, 3)
str = summary(c)
dimstr = printdims((4, 3))
@test str == "4×3 reshape($view_name, $dimstr) with $eltype_string Float64"

a = reshape(1:24, 3, 4, 2)
b = PermutedDimsArray(a, (2,3,1))
str = summary(b)
intstr = string("Int", Sys.WORD_SIZE)
dimstr = printdims((3, 4, 2))
@test str == "4×2×3 PermutedDimsArray(reshape(::UnitRange{$intstr}, $dimstr), $((2, 3, 1))) with $eltype_string $intstr"

o = ZArray(rand(3,5))
vo = view(o, 0:2:2, :)
if showit_old
    @test summary(vo) == "Base.OneTo(2)×ZArrays.ZeroRange(5) view(::ZArrays.ZArray{Float64,2}, 0:2:2, $(vo.indexes[end])) with $eltype_string Float64"
else
    @test summary(vo) == "view(::ZArrays.ZArray{Float64,2}, 0:2:2, :) with eltype Float64 with indices Base.OneTo(2)×ZArrays.ZeroRange(5)"
end


if showit_old
    # Adding cthresh is deprecated
    Base.summary(A::SubArray) = summary_build(A,1000)
    @test summary(v) == "3×4 SubArray{Float64,2,Array{Float64,3},Tuple{$(typeof(v.indexes[1])),$Int,UnitRange{$Int}},false}"
end

nothing
