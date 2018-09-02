@testset "buffer" begin

@testset "CircularSARDBuffer" begin
    buffer = CircularSARDBuffer(Matrix{Int}, Vector{Int}, Float64; capacity=3)
    @test isfull(buffer) == false
    @test capacity(buffer) == 3

    push!(buffer, ([[1 2]; [3 4]], [0], 0.0, false))
    push!(buffer, ([[1 2]; [3 4]], [1], 1.0, false))
    push!(buffer, ([[1 2]; [3 4]], [2], 2.0, false))
    @test isfull(buffer) == true
    @test buffer[1]  == ([[1 2]; [3 4]], [0], 0.0, false)

    push!(buffer, ([[1 2]; [3 4]], [3], 3.0, false))
    @test buffer[end] == ([[1 2]; [3 4]], [3], 3.0, false)
end

@testset "EpisodeSARDBuffer" begin
    buffer = EpisodeSARDBuffer(Matrix{Int}, Vector{Int}, Float64)

    push!(buffer, ([[1 2]; [3 4]], [0], 0.0, false))
    push!(buffer, ([[1 2]; [3 4]], [1], 1.0, false))
    push!(buffer, ([[1 2]; [3 4]], [2], 2.0, false))
    @test length(buffer) == 3

    push!(buffer, ([[1 2]; [3 4]], [3], 3.0, true))
    @test length(buffer) == 4
    @test isfull(buffer) == false
    @test buffer[1]  == ([[1 2]; [3 4]], [0], 0.0, false)
    @test buffer[end] == ([[1 2]; [3 4]], [3], 3.0, true)

    push!(buffer, ([[1 2]; [3 4]], [5], 5.0, false))
    @test length(buffer) == 1
    @test isfull(buffer) == false
    @test buffer[1]  == ([[1 2]; [3 4]], [5], 5.0, false)
    @test buffer[end]  == ([[1 2]; [3 4]], [5], 5.0, false)
end

end