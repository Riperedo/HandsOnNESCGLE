include("src\\NEprocesses.jl")

kₘᵢₙ = 0.0
kₘₐₓ = 20*π
N = 10000

G = Grid(kₘᵢₙ, kₘₐₓ, N)


# initial state
ϕi = 0.4
Ti = 1.0
# final state
phi = [0.45, 0.5, 0.55, 0.56, 0.57, 0.58, 0.581, 0.582, 0.583, 0.585, 0.59, 0.6, 0.61, 0.62, 0.63, 0.64, 0.65, 0.7]

# instantaneous process
for ϕf in phi
	Tf = 1.0
	instantaneous_process(ϕi, Ti, ϕf, Tf, G; VerletWeis = true, soft = false, k₀ = 7.2, u_max = 10.0, u_min = 1e-6, factor = 2.0, mute = false, save_path = "")
end