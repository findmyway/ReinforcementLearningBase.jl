mutable struct CircularArrayBuffer{T, N} <: AbstractArray{T, N}
    buffer::Array{T, N}
    first::Int
    length::Int
    stepsize::Int
    CircularArrayBuffer{T}(capacity::Int, dims::Tuple{Vararg{Int}}) where T = new{T, length(dims)+1}(Array{T}(undef, dims..., capacity), 1, 0, *(dims...))
end

size(cb::CircularArrayBuffer{T, N}) where {T, N} = (size(cb.buffer)[1:N-1]..., cb.length)
getindex(cb::CircularArrayBuffer{T, N}, i::Int) where {T, N} = getindex(cb.buffer, [(:) for _ in 1 : N-1]...,  _buffer_index(cb, i))
getindex(cb::CircularArrayBuffer{T, N}, I::Vararg{Int, N}) where {T, N} = getindex(cb.buffer, I[1:N-1]...,  _buffer_index(cb, I[end]))
setindex!(cb::CircularArrayBuffer{T, N}, v, i::Int) where {T, N} = setindex!(cb.buffer, v, [(:) for _ in 1 : N-1]...,  _buffer_index(cb, i))
setindex!(cb::CircularArrayBuffer{T, N}, v, I::Vararg{Int, N}) where {T, N} = setindex!(cb.buffer, v, I[1:N-1]...,  _buffer_index(cb, I[end]))

""""
    capacity(cb)
Return capacity of CircularArrayBuffer.
"""
capacity(cb::CircularArrayBuffer) = size(cb.buffer)[end]

"""
    length(cb)
Return the number of elements currently in the buffer.
"""
Base.length(cb::CircularArrayBuffer) = cb.length

"""
    isfull(cb)
Test whether the buffer is full.
"""
isfull(cb::CircularArrayBuffer) = length(cb) == capacity(cb)

"""
    push!(cb)
Add an element to the back and overwrite front if full.
"""
@inline function Base.push!(cb::CircularArrayBuffer, data)
    # if full, increment and overwrite, otherwise push
    if cb.length == capacity(cb)
        cb.first = (cb.first == capacity(cb) ? 1 : cb.first + 1)
    else
        cb.length += 1
    end
    nxt_idx = _buffer_index(cb, cb.length)
    cb.buffer[cb.stepsize * (nxt_idx - 1) + 1: cb.stepsize * nxt_idx] = data
    cb
end

"""
    empty!(cb)
Reset the buffer.
"""
function Base.empty!(cb::CircularArrayBuffer)
    cb.length = 0
    cb
end

@inline function _buffer_index(cb::CircularArrayBuffer, i::Int)
    n = capacity(cb)
    idx = cb.first + i - 1
    if idx > n
        idx - n
    else
        idx
    end
end