### A Pluto.jl notebook ###
# v0.12.10

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 8d49d5a0-498f-11ec-09fd-cd88723d8f4e
begin
	using Plots
	using PlutoUI
	using DelimitedFiles
	
	"""
	This is from the Julia source code (evalfile in base/loading.jl)
	but with the modification that it returns the module instead of the last object
	"""
	function ingredients(path::String)
		name = Symbol(basename(path))
		m = Module(name)
		Core.eval(m,
			Expr(:toplevel,
				 :(eval(x) = $(Expr(:core, :eval))($name, x)),
				 :(include(x) = $(Expr(:top, :include))($name, x)),
				 :(include(mapexpr::Function, x) = $(Expr(:top, :include))(mapexpr, $name, x)),
				 :(include($path))))
	m
	end
end

# ╔═╡ 5cb6fc50-499a-11ec-0f1b-514e41a2c1e4
md"# SCGLE Parte 3"

# ╔═╡ 7f2f7470-4bab-11ec-02c0-4f394e26cebe
md"""Numéricamente, el sistema de ecuaciones que resolvemos en la teoría son

$\frac{dF_s(k,\tau)}{d\tau} = -k^2D_0F_s(k,\tau) +\lambda(k)\Delta\zeta(\tau)- \frac{d}{d\tau}\int_0^\tau d\tau'\lambda(k)\Delta\zeta(\tau-\tau')F_s(k, \tau')$

$\frac{dF(k,\tau)}{d\tau} = -\frac{k^2D_0}{S(k)}F(k,\tau) +\lambda(k)\Delta\zeta(\tau)S(k)- \frac{d}{d\tau}\int_0^\tau d\tau'\lambda(k)\Delta\zeta(\tau-\tau')F(k, \tau')$

$Δ\zeta (\tau) = \frac{D_0}{24\pi^3 \rho}\int d^3k k^2\left[\frac{S(k)-1}{S(k)}\right]^2F(k, \tau)F_s(k, \tau)$

donde $\lambda(k)$ es una _función de interpolación_ definida como

$\lambda(k) = 1/[1+(k/k_c)^2]$

En este caso hemos escrito las funciones de dispersión intermedias en el espacio temporal, dado que utilizamos el método de Euler para resolver las ecuacioens integrodiferenciales.
"""

# ╔═╡ 013778f0-4bb1-11ec-1055-5906105b6738
md"## Correlación en la densidad
La evolución temporal de la función de dispersión intermedia $F(k,\tau)$ mide la correlación entre diferentes valores de la densidad local $ρ(k, t)$ de la densidad luego de un cierto tiempo de correlación $\tau$

$F(k, \tau) = \left\langle\rho(k,t+\tau)\rho^\dagger(k,t)\right\rangle$

en situaciones ideales, es decir, si no la función de memoria $\Delta\zeta(\tau) = 0$ la ecuaciones integrodiferenciales de arriba tienen la solución

$F(k,\tau) = S(k)\exp\left[-\frac{k^2D_0}{S(k)}t\right]$ y el escenario que esperamos se grafica a continuación.
"

# ╔═╡ 23a39a20-4992-11ec-02aa-a18b67ba24b0
SCGLE = ingredients("..\\src\\Dynamics.jl");

# ╔═╡ 3c71f9e0-4995-11ec-062e-09551a45e5e5
@bind tiempo html"<input type=range min=0 max=20 step = 1 name = 't'>"

# ╔═╡ 48926070-4995-11ec-079c-7326278c012e
begin
	time = 1e-6*(2<<tiempo)
	md"t = $time"
end

# ╔═╡ 2f21f450-4992-11ec-0632-63c9e3912beb
begin
	G_ = SCGLE.Grid(0, 15*π, 1000)
	phi = 0.5
	F_ = SCGLE.simple_ISF(phi, time, G_)
	plot(
		G_.x, F_,
		yrange = (0,3),
		xrange = (0, 15*π),
		label = nothing,
		title = "Función de dispersión intermedia F(k, τ = "*string(time)*")",
		xlabel = "kσ"
	)
	Fs_ = exp.(-(G_.x.^2)*time)
	plot!(
		G_.x, Fs_,
		label = "Fₛ"
	)
end

# ╔═╡ e35c4660-4bb2-11ec-301f-ef2a933012cb
md"""Para un sistema ergódigo esperamos que se cumpla la siguiente relación

$\lim_{\tau\to\infty}F(k, \tau) = \lim_{\tau\to\infty}\left\langle\rho(k,t+\tau)\rho^\dagger(k,t)\right\rangle = 0$

es decir, que despues de un tiempo lo suficientemente largo la densidad se encuentre decorrelacionada.

Para un sistema arrestado, lo que se espera que que la función se quede estacionada en algún valor mayor que cero, a esa relación se le conoce como factor de ergodicidad y se define como

$\lim_{\tau\to\infty}F(k, \tau) = S(k)\psi(k)$

Este factor termina ciendo una medida de la correlación del sistema. La SCGLE es capás de calcular estos factores de ergodicidad, simplemente calculamos la longitud de localización $\gamma$ de la libreta pasada y evaluamos

$\psi(k) = \lim_{t\to\infty}\frac{F(k,t)}{S(k)} = \frac{\lambda(k)S(k)}{\lambda(k)S(k) + k^2\lambda(k)}$

Para los casos donde la interacción entre partículas es relavante, la teoría predice una fricción efectiva la cual calculamos a continuación.
"""

# ╔═╡ dd53dcde-4bb4-11ec-3e4e-c99132a6ebf2
md"## SCGLE para esferas duras
Una vez más consideremos el sistema de esferas duras, para una cierta fracción de volumen ϕ dada
"

# ╔═╡ d86aec80-499a-11ec-210f-d73dc1bd5d03
@bind ϕ html"<input type=range min=0.4 max=0.66 step = 0.001 name = 'phi'>"
#ϕ = 0.5

# ╔═╡ ed1a2e70-499a-11ec-0a4f-5ffdf99fb031
md"ϕ = $ϕ"

# ╔═╡ edcf91d0-4bb5-11ec-16db-37dab7d2f5d7
md"Una vez más, llamamos a los objetos `Grid` y `Liquid` para obtener el factor de estructura estático `S`"

# ╔═╡ bd17f2d0-4999-11ec-3a76-35d4621a1004
begin
	G = SCGLE.Grid(0, 15*π, 10000);
	L = SCGLE.Liquid(ϕ);
	S = SCGLE.SF(L, G, SCGLE.HS, VerletWeis = true);
end

# ╔═╡ 0eb5a880-4bb6-11ec-2cb5-3b7d74ec7a79
md"""la función que resuelve de manera autoconsistente las ecuaciones de la teoría tiene la siguiente sintaxis
```julia
dynamics(L:: Liquid, G::Grid, S::{Array, Real}, k₀, τ₀, n, decimaciones::Integer)
```
y la forma en la que trabajamos con la función es
"""

# ╔═╡ 639f3720-499b-11ec-2dcf-2bd2fc7b7bbe
begin
	k₀ = 7.2
	namefile = "..\\DAT\\memoria"*SCGLE.num2text(ϕ)*".dat"
	if isfile(namefile)
		File = readdlm(namefile, Float64)
		τ, Fs, F, Δζ, Δη, W, δζ = File[:,1], File[:,2], File[:,3], File[:,4], File[:,5], File[:,6], File[:,7]
	else
		τ, Fs, F, Δζ, Δη = SCGLE.dynamics(L, G, S, k₀, 1e-10, 5, 50)
		W, δζ = SCGLE.MSD(τ, Δζ)
		SCGLE.save_data(namefile, [τ Fs F Δζ Δη W δζ])
	end
end

# ╔═╡ f38713f0-4a39-11ec-38e8-fff5f8471196
begin
	plot(
		τ[2:end], Fs[2:end],
		yrange = (0, 1),
		xrange = (1e-6, 1e6),
		xaxis = :log,
		label = "Función de autocorelación Fₛ(k=7.2σ, τ)",
		title = "Outputs para ϕ = "*string(ϕ),
		xlabel = "τ"
	)
	plot!(
		τ[2:end], Δζ[2:end]/Δζ[1],
		label = "Memoria Δζ(τ)/Δζ(0)"
	)
end

# ╔═╡ 372502b0-4bbc-11ec-19f5-7976ca4a263b
md"Adicionalmente, podemos trabajar con las salidas de la función para calcular propiedades como el desplazamiendo cuadrático medio o la fricción efectiva del sistema coloidal."

# ╔═╡ a1c03aa0-4bbb-11ec-1dc1-695800940656
begin
	plot(
		τ[2:end], W[2:end],
		yrange = (1e-6, 1e8),
		xrange = (1e-6, 1e6),
		xaxis = :log,
		yaxis = :log,
		label = "MSD",
		title = "Funciones post-cálculo para ϕ = "*string(ϕ),
		xlabel = "τ"
	)
	plot!(τ[2:end], δζ[2:end], label = "Fricción efectiva", legend = :topleft)
end

# ╔═╡ cefe30ae-4bbd-11ec-15fe-518c94f389e2
md"## Reflexión final
Con la presente librería es posible entrar de lleno a trabajar con la SCGLE, ya sea que se tengan resultados experimetales, simulaciones y alguna solución numérica o analítica del factor de estructura estático. Este código es libre y a disposición de todos.
"

# ╔═╡ Cell order:
# ╟─5cb6fc50-499a-11ec-0f1b-514e41a2c1e4
# ╟─7f2f7470-4bab-11ec-02c0-4f394e26cebe
# ╟─013778f0-4bb1-11ec-1055-5906105b6738
# ╟─8d49d5a0-498f-11ec-09fd-cd88723d8f4e
# ╠═23a39a20-4992-11ec-02aa-a18b67ba24b0
# ╟─3c71f9e0-4995-11ec-062e-09551a45e5e5
# ╟─48926070-4995-11ec-079c-7326278c012e
# ╟─2f21f450-4992-11ec-0632-63c9e3912beb
# ╟─e35c4660-4bb2-11ec-301f-ef2a933012cb
# ╟─dd53dcde-4bb4-11ec-3e4e-c99132a6ebf2
# ╟─d86aec80-499a-11ec-210f-d73dc1bd5d03
# ╟─ed1a2e70-499a-11ec-0a4f-5ffdf99fb031
# ╟─edcf91d0-4bb5-11ec-16db-37dab7d2f5d7
# ╠═bd17f2d0-4999-11ec-3a76-35d4621a1004
# ╟─0eb5a880-4bb6-11ec-2cb5-3b7d74ec7a79
# ╠═639f3720-499b-11ec-2dcf-2bd2fc7b7bbe
# ╟─f38713f0-4a39-11ec-38e8-fff5f8471196
# ╟─372502b0-4bbc-11ec-19f5-7976ca4a263b
# ╟─a1c03aa0-4bbb-11ec-1dc1-695800940656
# ╟─cefe30ae-4bbd-11ec-15fe-518c94f389e2
