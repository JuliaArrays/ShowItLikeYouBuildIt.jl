# Custom array type with nontraditional indices
# (we could use OffsetArrays, but that will have it's own `showarg` methods
#  and here we want to test fallbacks)
module ZArrays
using CustomUnitRanges: filename_for_zerorange
include(filename_for_zerorange)

export ZArray

struct ZArray{T,N} <: AbstractArray{T,N}
    parent::Array{T,N}
end
Base.indices(a::ZArray) = map(ZeroRange, size(a.parent))
end
