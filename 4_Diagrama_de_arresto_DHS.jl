include("src\\AsymptoticDHS.jl")

kₘᵢₙ = 0.0
kₘₐₓ = 20*π
N = 2000

G = Grid(kₘᵢₙ, kₘₐₓ, N)
L = Liquid()
L.T = 0.1

function condicion(ϕ₀)
	println("probando ϕ = ", ϕ₀)
	ϕ = [ϕ₀]
	σ = [1.0]
	L.setDistribution(ϕ, σ, phi = true)
	S₀₀, S₁₀, S₁₁ = SF(L, G, dd; VerletWeis = true)
	iteraciones, gammas, sistema = Asymptotic(L, G, S₀₀, S₁₀, S₁₁, flag = true)
	return (sistema == TraslationalArrest()) || (sistema == TotalArrest())
end

ϕ_min = 0.01
ϕ_max = 0.9
δϕ = 0.0001
ϕᵃ = biseccion(condicion, ϕ_max, ϕ_min, δϕ; flag = false) # Aquiles inicia en ϕ_max, la tortuga está en ϕ_min
println()
print("ϕᵃ = ", ϕᵃ)
