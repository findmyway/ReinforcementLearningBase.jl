using DataStructures
import DataStructures:isfull, capacity 
import Base:push!, getindex, lastindex, view, length, size, empty!
export AbstractBuffer, AbstractSARDBuffer,
       CircularSARDBuffer, EpisodeSARDBuffer,
       isfull

include("abstractbuffer.jl")
include("sardbuffer.jl")