include("src\\Dynamics.jl")
#=
kₘᵢₙ = 0.0
kₘₐₓ = 20*π
N = 10000

G = Grid(kₘᵢₙ, kₘₐₓ, N)

L = Liquid()
ϕ = [0.5]
σ = [1.0]
L.setDistribution(ϕ, σ, phi = true)

S = SF(L, G, HS, VerletWeis = true)
=#
#k₀ = 7.2
#τ, Fs, F, Δζ, Δη = dynamics(L, G, S, k₀, 1e-10, 5, 50)

#= calculando MSD de la forma
 <Δr²(t)>    t             t         D₀
---------- = ∫ dt' D(t') = ∫ dt' ----------
   2n        0             0     1 + δζ(t')
	
donde   t
δζ(t) = ∫dt'Δζ(t')/ζ₀
		0
=#
#=
W = zeros(length(τ))
δζ = zeros(length(τ))
for ii in 1:length(τ)-1
	dt = τ[ii+1] - τ[ii]
	δζ[ii+1] = δζ[ii] + dt*0.5*(Δζ[ii] + Δζ[ii+1])
	W[ii+1] = W[ii] + dt*0.5*(1/(1+δζ[ii+1])+1/(1+δζ[ii]))
end	

save_data("DAT\\memoria"*num2text(ϕ[1])*".dat", [τ Fs F Δζ Δη W])
=#
phi = [0.45]
for ϕ in phi
	G = Grid(0.0, 15*π, 10000);
	L = Liquid(ϕ);
	S = SF(L, G, HS, VerletWeis = true);
	k₀ = 7.2
	namefile = "DAT\\memoria"*num2text(ϕ)*".dat"
	if isfile(namefile)
		File = readdlm(namefile, Float64)
		τ, Fs, F, Δζ, Δη, W, δζ = File[:,1], File[:,2], File[:,3], File[:,4], File[:,5], File[:,6], File[:,7]
	else
		τ, Fs, F, Δζ, Δη = dynamics(L, G, S, k₀, 1e-10, 5, 50)
		W, δζ = MSD(τ, Δζ)
		save_data(namefile, [τ Fs F Δζ Δη W δζ])
	end
end