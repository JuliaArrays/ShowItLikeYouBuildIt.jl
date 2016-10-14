using ShowItLikeYouBuildIt
using Compat # for redirection of I/O
using Base.Test

for T in (Float64, Bool, Int8, UInt16, Symbol, String)
    @test shows_compactly(T)
end

@test ShowItLikeYouBuildIt.dimstring(()) == "0-dimensional"

# Test the display of an actual object.
# Note that this alters how ReshapedArrays and PermutedDimsArrays are displayed; if you
# care, beware running this in anything other than a "throwaway" julia session.

function ShowItLikeYouBuildIt.showtypeof{T,N,perm}(io::IO, A::Base.PermutedDimsArrays.PermutedDimsArray{T,N,perm})
    P = parent(A)
    print(io, "permuteddimsview(")
    if ShowItLikeYouBuildIt.shows_compactly(typeof(P))
	print(io, "::", typeof(P))
    else
	ShowItLikeYouBuildIt.showtypeof(io, P)
    end
    print(io, ", ", perm, ')')
end

Base.summary(A::Base.PermutedDimsArrays.PermutedDimsArray) = summary_compact(A)

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

Base.summary(A::Base.ReshapedArray) = summary_compact(A)

a = reshape(1:24, 3, 4, 2)
b = Base.PermutedDimsArrays.PermutedDimsArray(a, (2,3,1))
str = summary(b)
intstr = string("Int", Sys.WORD_SIZE)
@test startswith(str, "4×2×3 permuteddimsview(reshape(::UnitRange{$intstr}, (3,4,2)), (2,3,1)) with element type $intstr")
