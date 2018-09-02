using DataStructures
import DataStructures:isfull, capacity 
import Base:push!, getindex, lastindex, view, length, empty!
export AbstractBuffer, AbstractSARDBuffer,
       CircularSARDBuffer, EpisodeSARDBuffer,
       isfull, capacity

include("abstractbuffer.jl")
include("circulararraybuffer.jl")
include("sardbuffer.jl")