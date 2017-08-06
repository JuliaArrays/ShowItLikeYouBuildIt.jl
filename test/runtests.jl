using ShowItLikeYouBuildIt, OffsetArrays
using Base.Test

for T in (Float64, Bool, Int8, UInt16, Symbol, String, Union{})
    @test type_complexity(T) == 1
end
@test type_complexity(Union{Float32,Int8}) == 2
@test type_complexity(Array{Int,2}) == 3
@test type_complexity(Array{Complex{Float32},2}) == 4
@test type_complexity(Array{Array{Complex{Float32},1},2}) == 6

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

function ShowItLikeYouBuildIt.showarg{T,N,perm}(io::IO, A::Base.PermutedDimsArrays.PermutedDimsArray{T,N,perm})
    print(io, "permuteddimsview(")
    showarg(io, parent(A))
    print(io, ", ", perm, ')')
end

function ShowItLikeYouBuildIt.showarg(io::IO, A::Base.ReshapedArray)
    print(io, "reshape(")
    showarg(io, parent(A))
    print(io, ", ", A.dims, ')')
end

Base.summary(A::SubArray) = summary_build(A)
Base.summary(A::Base.PermutedDimsArrays.PermutedDimsArray) = summary_build(A)
Base.summary(A::Base.ReshapedArray) = summary_build(A)

a = rand(3,5,7)
v = view(a, :, 3, 2:5)
view_name = "view(::Array{Float64,3}, $(v.indexes[1]), 3, 2:5)"
@test summary(v) == "3×4 $view_name with element type Float64"

c = reshape(v, 4, 3)
str = summary(c)
@test str == "4×3 reshape($view_name, $((4, 3))) with element type Float64"

a = reshape(1:24, 3, 4, 2)
b = Base.PermutedDimsArrays.PermutedDimsArray(a, (2,3,1))
str = summary(b)
intstr = string("Int", Sys.WORD_SIZE)
@test str == "4×2×3 permuteddimsview(reshape(::UnitRange{$intstr}, $((3, 4, 2))), $((2, 3, 1))) with element type $intstr"

o = OffsetArray(rand(3,5), -1:1, -2:2)
vo = view(o, -1:2:1, :)
@test summary(vo) == "Base.OneTo(2)×-2:2 view(::OffsetArrays.OffsetArray{Float64,2,Array{Float64,2}}, -1:2:1, $(vo.indexes[end])) with element type Float64"


Base.summary(A::SubArray) = summary_build(A,1000)
@test summary(v) == "3×4 SubArray{Float64,2,Array{Float64,3},Tuple{$(typeof(v.indexes[1])),Int64,UnitRange{Int64}},false}"

nothing
