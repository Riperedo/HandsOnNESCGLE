include("utils.jl")
include("Grid.jl")
include("Liquid.jl")
include("Potentials.jl")

#############################################
# 	Structure Factor for a monodisperese 	#
#	dipole hard spheres colloid				#
#	Wertheim 1971							#
#############################################

#################################
#	Some derivates funtions		#
#################################

# Some special functions
js(ν, x) = sphericalbesselj(ν, x)
Si(x) = sinint(x)
Ci(x) = cosint(x)


# Percus-Yevick solution's coeficients
α₁(ϕ) =  -(1.0 + 2.0*ϕ)^2/(1.0 - ϕ)^4
α₂(ϕ) = 6.0*ϕ*(1.0 + 0.5*ϕ)^2/(1.0 - ϕ)^4
α₃(ϕ) = 0.5*ϕ*α₁(ϕ)

# Some usefull integrals
# ∫(0,1) dx x² j₀(kx)
I₁(k) = k == 0.0 ? 1/3 : (sin(k) - k*cos(k))/k^3
# ∫(0,1) dx x² xj₀(kx)
I₂(k) = k == 0.0 ? 1/4 : (-(k^2 - 2.0)*cos(k) + 2.0*k*sin(k) - 2.0)/k^4
# ∫(0,1) dx x² x³j₀(kx)
I₃(k) = k == 0.0 ? 1/6 : (4.0*k*(k^2 - 6.0)*sin(k) - (k^4 - 12.0*k^2 + 24.0)*cos(k) + 24.0)/k^6
# ∫(0,1) dx x² xj₂(kx)
I₄(k) = k == 0.0 ? 0.0 : ((k^2 - 8.0)*cos(k) - 5.0*k*sin(k) + 8.0)/k^4
# ∫(0,1) dx x² x³j₂(kx)
I₅(k) = k == 0.0 ? 0.0 : ((48.0*k - 7.0*k^3)*sin(k) + (k^4 - 24.0*k^2 + 48.0)*cos(k) - 48.0)/k^6
# ∫(1,∞) dx x² j₂(kx)/x³
I₆(k) = k < 0.5 ? 1/3 - k^2/30 + k^4/840 : js(1,k)/k

# FT of Wertheim's direct correlation functions
c(ϕ, k) = α₁(ϕ)*I₁(k) + α₂(ϕ)*I₂(k) + α₃(ϕ)*I₃(k)
cΔ(ϕ, κ, k) = 2*κ*((α₁(2*κ*ϕ) - α₁(-κ*ϕ))*I₁(k) + (α₂(2*κ*ϕ) - α₂(-κ*ϕ))*I₂(k) + (α₃(2*κ*ϕ) - α₃(-κ*ϕ))*I₃(k))
cD(ϕ, κ, λ, k) = -0.25*κ*(2*α₂(2*κ*ϕ) + α₂(-κ*ϕ))*I₄(k) - 0.5*κ*(2*α₃(2.0*κ*ϕ) + α₃(-κ*ϕ))*I₅(k) - λ*I₆(k)

# Static structure factor
function SF_PY(ϕ :: Real, k :: Real)
	ρ = ϕ2ρ(ϕ)
	return 1.0/(1.0 - 4.0*π*ρ*c(ϕ, k))
end

function SF_Wertheim(ϕ :: Real, κ :: Real, λ :: Real, k :: Real)
	ρ = ϕ2ρ(ϕ)
	c¹¹₀ = 1.0 - 4.0*π*ρ*(cΔ(ϕ, κ, k) + 2*cD(ϕ, κ, λ, k))/3
	c¹¹₁ = 1.0 - 4.0*π*ρ*(cΔ(ϕ, κ, k) - cD(ϕ, κ, λ, k))/3
	return 1/c¹¹₀, 1/c¹¹₁
end

#function SF(L ::  Liquid, G :: Grid, P :: Potential; VerletWeis = false)
function SF(L, G, P; VerletWeis = false)
	ϕ = L.ϕ[1]
	σ = L.σ[1]
	if P.spherical
		if VerletWeis & (P == HS)
			σ = (1 - L.ϕ[1]/16)^(1/3)
			ϕ = L.ϕ[1] - (L.ϕ[1]^2)/16
		end
		if L.soft
			T = L.T
			λ = T != 0.0 ? blip(1/T) : 1.0
			λ3 = λ^3
			σ = λ*((1 - λ3*L.ϕ[1]/16)^(1/3))
			ϕ = λ3*L.ϕ[1]*(1 - λ3*L.ϕ[1]/16)
		end
		S = zeros(G.n)
		ρ = L.ρ_total
		for i in 1:G.n
			k = G.x[i]
			Sᵛʷ = SF_PY(ϕ, k*σ)
			U = P.FT(k, L)[1,1]
			Sₛₛ⁻¹ = 1/Sᵛʷ + ρ*U # (1 - ρ(CHS - βU))
			S[i] = 1/Sₛₛ⁻¹
		end
		return S
	else
		if VerletWeis
			ϕ = L.ϕ[1] - (L.ϕ[1]^2)/16
		end
		λ = 1/L.T
		y = 8*λ*ϕ/3
		κ = ξ(y)/ϕ
		S00 = zeros(G.n)
		S10 = zeros(G.n)
		S11 = zeros(G.n)
		for i in 1:G.n
			k = G.x[i]
			S00[i] = SF_PY(ϕ, k)
			S10[i], S11[i] = SF_Wertheim(ϕ, κ, 1/L.T, k)
		end
		return S00, S10, S11
	end
end

#########################################
#	Structure Factor Blip function 	#
#########################################

function blip(ϵ :: Float64; ν = 6, flag = false)
	λ = 0.0
	dx = 1/1000
	for i in 1:1000
		x = i*dx
		λ -= x*x*exp(-ϵ*(1/x^(2*ν)-2/x^ν+1))
	end
	λ *= 3*dx
	λ += 1.0
	λ = λ^(1/3)
	if flag println("blip function computed ", λ) end
	return λ
end

#####################
#	κ parameter 	#
#####################

function ξ(y₀ :: Real)
	δξ = 0.0001
	ξf = 0.5
	q(ϕ) = -α₁(ϕ)
	function condicion(ξ)
		y(ξ) = (q(2*ξ)-q(-ξ))/3
		return y(ξ) < y₀
	end
	ξ = biseccion(condicion, 0.0, ξf, δξ) # Aquiles inicia en cero, la tortuga está en ξf
	return ξ
end
