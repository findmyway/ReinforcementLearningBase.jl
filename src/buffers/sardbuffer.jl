"The abstract buffer of State, Action, Reward and Done(SARD)"
abstract type AbstractSARDBuffer <: AbstractBuffer end

for s in [:capacity, :length, :size]
    @eval $s(b::AbstractSARDBuffer) = $s(b.states)
end

for s in [:getindex, :view, :empty!]
    @eval $s(b::AbstractSARDBuffer, args...) = ($s(b.states, args...),
                                                $s(b.actions, args...),
                                                $s(b.rewards, args...),
                                                $s(b.done, args...))
end

lastindex(b::AbstractBuffer) = length(b)

########################################
## CircularBuffer
########################################
"Using `CircularBuffer` to store turn info (SARD, State, Action, Reward and Done)"
struct CircularSARDBuffer{Ts, Ta, Tr} <: AbstractSARDBuffer
    states::CircularBuffer{Ts}
    actions::CircularBuffer{Ta}
    rewards::CircularBuffer{Tr}
    done::CircularBuffer{Bool}
end


"""
Initial a `CircularSARDBuffer` by specifying the type of state, action, reward.
The default `capacity` is set to 2.
"""
function CircularSARDBuffer(ts::Type{Ts}, ta::Type{Ta}, tr::Type{Tr}=Float64;
                            capacity = 2) where Ts where Ta where Tr
    CircularSARDBuffer(CircularBuffer{Ts}(capacity),
                       CircularBuffer{Ta}(capacity),
                       CircularBuffer{Tr}(capacity),
                       CircularBuffer{Bool}(capacity))
end

"Add a turn info into the `CircularSARDBuffer`"
function push!(b::CircularSARDBuffer{Ts, Ta, Tr}, sard::Tuple{Ts, Ta, Tr, Bool}) where Ts where Ta where Tr 
    s, a, r, d = sard
    push!(b.states, s)
    push!(b.actions, a)
    push!(b.rewards, r)
    push!(b.done, d)
end

isfull(b::CircularSARDBuffer) = isfull(b.states)

########################################
## EpisodeSARDBuffer
########################################
"""
Using a `Vector` to store turn info (SARD, State, Action, Reward and Done)
Once an episode finishes, the buffer is emptied.
"""
struct EpisodeSARDBuffer{Ts, Ta, Tr} <: AbstractSARDBuffer where Ts where Ta where Tr
    states::Vector{Ts}
    actions::Vector{Ta}
    rewards::Vector{Tr}
    done::Vector{Bool}
end

EpisodeSARDBuffer(ts::Type{Ts}, ta::Type{Ta}, tr::Type{Tr})  where Ts where Ta where Tr = EpisodeSARDBuffer(Vector{Ts}(), Vector{Ta}(), Vector{Tr}(), Vector{Bool}())

"Push turn info into the buffer. If last turn is the end of an episode, empty the buffer first."
function push!(b::EpisodeSARDBuffer{Ts, Ta, Tr}, sard::Tuple{Ts, Ta, Tr, Bool}) where Ts where Ta where Tr
    s, a, r, d = sard
    if length(b.done) > 0 && b.done[end]
        empty!(b.states); empty!(b.actions); empty!(b.rewards); empty!(b.done)
    end
    push!(b.states, s)
    push!(b.actions, a)
    push!(b.rewards, r)
    push!(b.done, d)
end

isfull(b::EpisodeSARDBuffer) = false