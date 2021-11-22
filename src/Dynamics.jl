include("Asymptotic.jl")

#########################
#		Dynamics		#
#########################

function G_(G, Fⱼ₋₁, Fⱼ, Fⱼ₊₁, τⱼ₋₁, τⱼ, τⱼ₊₁, S)
	integrando = zeros(G.n)
	for i in 2:(G.n-1)
		dSdk = 0.5*((S[i-1] - S[i])/(G.x[i-1]-G.x[i])+(S[i] - S[i+1])/(G.x[i]-G.x[i+1]))
		dτⱼ = τⱼ*(log(τⱼ₋₁/τⱼ))
		dτⱼ₊₁ = τⱼ₊₁*(log(τⱼ/τⱼ₊₁))
		dFⱼ = Fⱼ[i]log(Fⱼ₋₁[i]/Fⱼ[i])
		dFⱼ₊₁ = Fⱼ₊₁[i]log(Fⱼ[i]/Fⱼ₊₁[i])
		dFdτ = 0.5*(dFⱼ/dτⱼ + dFⱼ₊₁/dτⱼ₊₁)
		k⁴ = G.x[i]^4
		integrando[i] = k⁴*(dSdk^2)*Fⱼ[i]*dFdτ/(S[i]^4)
	end
	return -integral(G, integrando; rule = "trapezoidal")/(10*π)
end

function Δη_(G, F, S)
	integrando = zeros(G.n)
	for i in 2:G.n
		dSdk = (S[i] - S[i-1])/(G.x[i] - G.x[i-1])
		k = G.x[i]
		integrando[i] = (k^4)*(dSdk^2)*(F[i]^2)/(S[i]^4)
	end
	return integral(G, integrando; rule = "trapezoidal")/(20*π)
end

function memoria(L, G, S, F, Fs)
	ONE = ones(G.n)
	k = G.x
	integrando = (k.^4).*((S-ONE).^2).*F.*Fs./(S.^2)
	return integral(G, integrando; rule = "trapezoidal")/(6*π*π*L.ρ[1])
end

function decimation(G, S, T, Δζ, Fs, F, T_save, Δζ_save, Fs_save, F_save, Δη_save, index)
	N = length(T)
	for n in Int(N//2):N
		if n%2 == 1
			append!(T_save, T[n])
			append!(Δζ_save, Δζ[n])
			append!(Fs_save, Fs[index, n])
			append!(F_save, F[index, n])
			append!(Δη_save, Δη_(G, F[:,n], S))
			#append!(G_save, G_(G, F[:,n-1], F[:,n], F[:,n+1], T[n-1], T[n], T[n+1], S)) #G_(G, Fⱼ₋₁, Fⱼ, Fⱼ₊₁, τⱼ₋₁, τⱼ, τⱼ₊₁, S)
		end
	end

	for n in 1:Int(N//2)
		T[n] = T[2*n]
		Δζ[n] = Δζ[2*n]
		Fs[:,n] = Fs[:,2*n]
		F[:,n] = F[:,2*n]
	end
	for n in Int(N//2):N
		T[n] = 0.0
		Δζ[n] = 0.0
		Fs[:,n] .= 0.0
		F[:,n] .= 0.0
	end
	return T, Δζ, Fs, F, T_save, Δζ_save, Fs_save, F_save, Δη_save#, G_save
end

function step_free(L, G, S, F, Fs, Δζ, T, dt, n)
	ONE = ones(G.n)
	k = G.x
	α = ONE + dt*(k.*k)./S
	F[:,n+1] = F[:,n]./α
	α = ONE + dt*(k.*k)
	Fs[:,n+1] = Fs[:,n]./α
	Δζ[n+1] = memoria(L, G, S, F[:, n+1], Fs[:, n+1])
	T[n+1] = dt*n
	return T, F, Fs, Δζ
end

function Σᵢ(Δζ, F, n)
	Total = zeros(length(F[:,1]))
	for i in 2:(n-1)
		Total = Total + (Δζ[n+1-i]-Δζ[n-i])*F[:, i]
	end
	return Total
end

function F_dump(L, G, S, F, Δζ, dt, n)
	"""
F_dump(k, n) = α(k)λ(k){Δζₙ₋₁F₁(k) - Σᵢ₌₂ⁿ⁻¹[Δζₙ₊₁₋ᵢ-Δζₙ₋ᵢ]Fᵢ(k)} + Δt⁻¹α(k)Fₙ₋₁(k)
	"""
	ONE = ones(G.n)
	k = G.x
	kc = 2*π*1.305
	λ = ONE./(ONE + (k.*k)/(kc^2))
	α = ONE./(ONE/dt + (k.*k)./S + λ*Δζ[1])
	return α.*(λ.*(Δζ[n-1]*F[:,1] - Σᵢ(Δζ, F, n)) + F[:,n-1]/dt)
end

function F_it(L, G, S, F, Δζ, dt, n)
	"""
F_it(k, n) = α(k)λ(k)Δζₙ[S(k)-F₁(k)]
	"""
	ONE = ones(G.n)
	k = G.x
	kc = 2*π*1.305
	λ = ONE./(ONE + (k.*k)/(kc^2))
	α = ONE./(ONE/dt + (k.*k)./S + λ*Δζ[1])
	return α.*λ.*(S[:]-F[:,1])*Δζ[n]
end

function step(L, G, S, F, Fs, Δζ, T, dt, n)
	"""
Fₙ(k) = α(k)λ(k){Δζₙ₋₁F₁(k) - Σᵢ₌₂ⁿ⁻¹[Δζₙ₊₁₋ᵢ-Δζₙ₋ᵢ]Fᵢ(k)} + Δt⁻¹α(k)Fₙ₋₁(k)
		+ α(k)λ(k)Δζₙ[S(k)-F₁(k)]
	 = F_dump(k, n) + F_it(k, n)
where
F_dump(k, n) = α(k)λ(k){Δζₙ₋₁F₁(k) - Σᵢ₌₂ⁿ⁻¹[Δζₙ₊₁₋ᵢ-Δζₙ₋ᵢ]Fᵢ(k)} + Δt⁻¹α(k)Fₙ₋₁(k)
F_it(k, n) = α(k)λ(k)Δζₙ[S(k)-F₁(k)]
and
α(k) = [Δτ⁻¹I + k²DS⁻¹(k) + λ(k)Δζ₁(k)]⁻¹
	"""
	s = ones(G.n)
	Dump = F_dump(L, G, S, F, Δζ, dt, n)
	dump = F_dump(L, G, s, Fs, Δζ, dt, n)
	Δζ[n+1] = Δζ[n]
	F[:,n+1] = Dump + F_it(L, G, S, F, Δζ, dt, n)
	Fs[:,n+1] = dump + F_it(L, G, s, Fs, Δζ, dt, n)
	Δζ[n+1] = memoria(L, G, S, F[:, n+1], Fs[:, n+1])
	#while true
	for t in 1:10
		F[:,n+1] = Dump + F_it(L, G, S, F, Δζ, dt, n)
		Fs[:,n+1] = dump + F_it(L, G, s, Fs, Δζ, dt, n)
		Δζ_new = memoria(L, G, S, F[:, n+1], Fs[:, n+1])
		if (Δζ[n+1]-Δζ_new)^2 < 1e-10 break end
		Δζ[n+1] = Δζ_new
	end
	T[n+1] = dt*n
	return T, F, Fs, Δζ
end

function step_longtimes(L, G, S, F, Fs, Δζ, T, dt, n, Δζ∞, F∞, Fs∞)
	F[:,n+1] = F∞[:]
	Fs[:,n+1] = Fs∞[:]
	Δζ[n+1] = Δζ∞ < 1e-10 ? 0.0 : Δζ∞
	T[n+1] = dt*n
	return T, F, Fs, Δζ
end


"""
`dynamics(L, G, S, k_max, dt, nT, decimaciones; save = false, path = "")`
# Argumentos
`L::Liquid` Parámetros físicos del sistema
`G::Grid`, Mallado del vector de onda
`S::{Array, Real}` Factor de estructura estático
`k_max::Real` Corte de la función de dispersión intermedia
`dt::Real` Valor inicial del tiempo de correlación
`nT::Integer` Número de tiempos intermedios `N = 2<<nT`
`decimaciones::Integer` Número de decimaciones
# Salida
`τ::{Array, FLoat64}` Tiempo de correlación
`Fs::{Array, FLoat64}` Función de autocorrelación `Fs(k_max, τ)`
`F::{Array, FLoat64}` Función de dispersión intermedia `F(k_max, τ)`
`Δζ::{Array, FLoat64}` Memoria del sistema
`Δη::{Array, FLoat64}` Viscosidad del sistema
función que resuelve demanea autoconsistente las ecuaciones de la SCGLE.
"""
function dynamics(L, G, S, k_max, dt, nT, decimaciones; save = false, path = "")
	# grid temporal
	N = 2<<nT
	F = zeros(G.n, N)
	Fs = zeros(G.n, N)
	Δζ = zeros(N)
	T = zeros(N)

	# output
	index = G.find(k_max)
	T_save = []
	Δζ_save = []
	Fs_save = []
	F_save = []
	Δη_save = []
	#G_save = []

	#initial conditions
	ONE = ones(G.n)
	kc = 2*π*1.305
	F[:, 1] = S
	Fs[:, 1] = ONE
	Δζ[1] = memoria(L, G, S, F[:, 1], Fs[:, 1])
	
	# Asymptotic behavior
	Δζ∞, Fs∞, F∞ = Asymptotic_structure(L, G, S)
	longtimes = false

	# first steps
	
	# free diffusion
	for n in 1:N-1
		T, F, Fs, Δζ = step_free(L, G, S, F, Fs, Δζ, T, dt, n)
	end
	
	# Intermediate-long times
	for d in 1:decimaciones
		# decimation
		if save
			save_data(path*"decimacion"*num2text(d)*".dat", [G.x Fs[:, end] F[:, end]])
		end
		T, Δζ, Fs, F, T_save, Δζ_save, Fs_save, F_save, Δη_save = decimation(G, S, T, Δζ, Fs, F, T_save, Δζ_save, Fs_save, F_save, Δη_save, index)
		dt *= 2
		for n in Int(N//2):N
			if !longtimes 
				#T, F, Fs, Δζ = step_free(L, G, S, F, Fs, Δζ, T, dt, n-1)
				T, F, Fs, Δζ = step(L, G, S, F, Fs, Δζ, T, dt, n-1)
				if Δζ[n] < Δζ∞ || Δζ[n] < 1e-10 longtimes = true end
			else
				T, F, Fs, Δζ = step_longtimes(L, G, S, F, Fs, Δζ, T, dt, n-1, Δζ∞, F∞, Fs∞)
			end
		end
		println("Decimacion ", d)
	end

	# saving final steps
	for n in Int(N//2):(N-1)
		append!(T_save, T[n])
		append!(Δζ_save, Δζ[n])
		append!(Fs_save, Fs[index, n])
		append!(F_save, F[index, n])
		append!(Δη_save, Δη_(G, F[:,n], S))
		#append!(G_save, G_(G, F[:,n-1], F[:,n], F[:,n+1], T[n-1], T[n], T[n+1], S)) #G_(G, Fⱼ₋₁, Fⱼ, Fⱼ₊₁, τⱼ₋₁, τⱼ, τⱼ₊₁, S)
	end
	#=	
	G_fb = zeros(length(Δη_save))
	for n in 2:(length(Δη_save)-1)
		dτₙ = T_save[n]*(log(T_save[n-1]/T_save[n]))
		dτₙ₊₁ = T_save[n+1]*(log(T_save[n]/T_save[n+1]))
		dηₙ = Δη_save[n]*(log(Δη_save[n-1]/Δη_save[n]))
		dηₙ₊₁ = Δη_save[n+1]*(log(Δη_save[n]/Δη_save[n+1]))
		G_fb[n] = -0.5*(dηₙ/dτₙ + dηₙ₊₁/dτₙ₊₁)
	end
	=#
	return T_save, Fs_save, F_save, Δζ_save, Δη_save#, G_save, G_fb
end

"""
`simple_ISF(ϕ::Real, τ::Real, G::Any)`
# Argumentos
`ϕ::Real` Fracción de volumen
`τ::Real` tiempo de correlación
`G::Any` grid
Evalua la función de dispersión intermedia para esferas duras sin memoria.
`F(k, τ) = S(k)exp[-k²D₀τ/S(k)]`
"""
function simple_ISF(ϕ::Real, τ::Real, G::Any)
	L = Liquid(ϕ)
	S = SF(L, G, HS, VerletWeis = true)
	return S.*exp.(-(G.x.^2)*τ./S)
end

"""
calculando MSD de la forma

 <Δr²(t)>    t             t         D₀

---------- = ∫ dt' D(t') = ∫ dt' ----------

   2n        0             0     1 + δζ(t')
	
donde   t

δζ(t) = ∫dt'Δζ(t')/ζ₀

		0
"""
function MSD(τ, Δζ)
	W = zeros(length(τ))
	δζ = zeros(length(τ))
	for ii in 1:length(τ)-1
		dt = τ[ii+1] - τ[ii]
		δζ[ii+1] = δζ[ii] + dt*0.5*(Δζ[ii] + Δζ[ii+1])
		W[ii+1] = W[ii] + dt*0.5*(1/(1+δζ[ii+1])+1/(1+δζ[ii]))
	end
	return W, δζ	
end