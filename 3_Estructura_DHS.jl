include("src\\StructureFactor.jl")
kₘᵢₙ = 0.0
kₘₐₓ = 7*π
N = 1000
G = Grid(kₘᵢₙ, kₘₐₓ, N)

Volume_fraction = 0.4
Temperature = 1.0

L = Liquid()
ϕ = [Volume_fraction]
L.setDistribution(ϕ, [1.0], phi = true)
L.T = Temperature
S₀₀, S₁₀, S₁₁ = SF(L, G, dd; VerletWeis = true)
save_data("DAT\\S_DHS_phi"*num2text(ϕ[1])*"T"*num2text(L.T)*".dat", [G.x S₀₀ S₁₀ S₁₁])
