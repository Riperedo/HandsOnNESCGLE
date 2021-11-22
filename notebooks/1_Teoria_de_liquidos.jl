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

# ╔═╡ e75fd910-4627-11ec-0dc6-adab90533fd1
using Plots

# ╔═╡ e1f10af0-463e-11ec-0b4a-4960b479e61d
include("..\\src\\van_der_Waals.jl");

# ╔═╡ dc771940-4655-11ec-22be-11a976e7623a
include("..\\src\\gdr.jl");

# ╔═╡ 1c91a0d0-461b-11ec-3b8a-b9f787d314ab
md"""# Teoría de líquidos simples
De manera intuitiva el estado líquido se entiende como un punto intermedio entre los estados sólido y gaseoso. Un punto de partida natural es el explorar la relación entre diferentes variables termodinámicas como presión $P$, volumen $V$ y temperatura $T$ a través de una ecuación de estado $f(P, V, T) = 0$. Para el caso de la ecuación de [van der Waals](http://www.sc.ehu.es/sbweb/fisica3/calor/waals/waals.html)

$\left(P + \frac{n^2a}{V^2}\right)(v-nb)-nRT=0$

donde $a$ es un parámetro de atracción entre partículas, $b$ es una medida del volumen excluido, $n$ el número de moles del gas y $R = k_BN_A$ es la constante de los gases ideales.
"""

# ╔═╡ d7c81750-462d-11ec-1611-4974efe612b8
md"Ajustemos un valor para la temperatura"

# ╔═╡ 2aaba4c0-462c-11ec-1e85-197387c11e1a
@bind T html"<input type=range min=0.81 max=1.6 step = 0.01 name = 'T'>"

# ╔═╡ 872b7e8e-462d-11ec-1cf3-edbe21be6097
md"T = $T"

# ╔═╡ 9b30fae0-464c-11ec-1329-69ee8202881e
begin
	# arreglos para salvar los puntos que se van calculando
	binodal_V = []
	binodal_P = []
	espinodal_V = []
	espinodal_P = []
	md""
end

# ╔═╡ fed729e0-4712-11ec-0a9d-558105f8e60b
md"¿Queres ver la misma curva en términos del volumen específico $v=1/V$?"

# ╔═╡ 64326de0-4713-11ec-38ac-c10b0e2f087c
md"""
volumen específico $(@bind vol_esp html"<input type=checkbox >")
"""

# ╔═╡ db1b1d70-462e-11ec-1eba-a966d4e17f37
begin
	# Volumen y Presion
	V = collect(0.4:0.001:5.0)
	P = P_vdW.(V, T)
	# algunos par'amteros
	color = "blue"
	label = "Isoterma T* = "*string(T)
	# funcion de estado
	
	if T == 1.0 
		color = "red" 
		label = "Temperatura crítica T* = 1.0"
		if !(1.0 in binodal_V) append!(binodal_V, 1.0) end
		if !(1.0 in binodal_P) append!(binodal_P, 1.0) end
		if !(1.0 in espinodal_V) append!(espinodal_V, 1.0) end
		if !(1.0 in espinodal_P) append!(espinodal_P, 1.0) end
	end
	rango = vol_esp ? (0, 2.5) : (0, 4)
	X = vol_esp ? ones(length(V))./V : V
	x_label = vol_esp ? "volumen específico" : "Volumen"
	plot(
		X, P,
		xlim = rango,
		ylim = (0, 2),
		xlabel = x_label,
		ylabel = "Presión",
		title = "Ecuación de estado de van der Waals",
		color = color,
		label = label
	)
	# si parace la espinodal	
	if T < 1.0
		P_0 = areas_iguales(V, P)
		index_r = roots_vdW(P, P_0)
		V_maxwell = [V[index_r[1]], V[index_r[3]]]
		P_maxwell = [P[index_r[1]], P[index_r[3]]]
		plot!(vol_esp ? ones(length(V_maxwell))./V_maxwell : V_maxwell, P_maxwell, label = "Áreas iguales")
		if !(V[index_r[1]] in binodal_V) append!(binodal_V, V[index_r[1]]) end
		if !(V[index_r[3]] in binodal_V) append!(binodal_V, V[index_r[3]]) end
		if !(P[index_r[1]] in binodal_P) append!(binodal_P, P[index_r[1]]) end
		if !(P[index_r[3]] in binodal_P) append!(binodal_P, P[index_r[3]]) end
		index_m = max_vdW(P)
		V_m = [V[index_m[1]], V[index_m[2]]]
		P_m = [P[index_m[1]], P[index_m[2]]]
		plot!(vol_esp ? ones(length(V_m))./V_m : V_m, P_m, seriestype = :scatter, label = nothing)
		if !(V[index_m[1]] in espinodal_V) append!(espinodal_V, V[index_m[1]]) end
		if !(P[index_m[1]] in espinodal_P) append!(espinodal_P, P[index_m[1]]) end
		if !(V[index_m[2]] in espinodal_V) append!(espinodal_V, V[index_m[2]]) end
		if !(P[index_m[2]] in espinodal_P) append!(espinodal_P, P[index_m[2]]) end
	else
		plot!()
	end
	plot!(vol_esp ? ones(length(espinodal_V))./espinodal_V : espinodal_V, espinodal_P, seriestype = :scatter, color = "orange", label = "espinodal")
	plot!(vol_esp ? ones(length(binodal_V))./binodal_V : binodal_V, binodal_P, seriestype = :scatter, color = "green", label = "binodal", legend = vol_esp ? :topleft : :topright)
end

# ╔═╡ b7083860-4650-11ec-3f43-c5752e792c11
md"""Ahora podemos indentificar diferentes regiones en el espacio termodinámico $(V, P)$ y estas nos definirán diferentes estados. La ecuación de van del Waals sirve para modelar líqudos simples. La región entre la curva binodal y la isoterma de la temperatura crítica delimita dos regiones: 
* Para $V>1$ la región de vapor, y
* para $V<1$ la región líquida.

Abajo de la curva binodal hay pocas cosas que se pueden decir, por ejemplo enpara regiones entre las curvas binodal y espinodal tenemos sistemas metaestables. La región abajo de la espinodal es conocida como región de inestabilidades termodinámicas.
"""

# ╔═╡ 051aae60-4652-11ec-3297-633499a95261
md"Para la descripción de líquidos nos enfocamos en regiones del espacio termodinámico donde el volumen accesible de nuestro sistema es reducido, o bien, donde la densidad de partículas que componen al mismo es _relativamente alta_."

# ╔═╡ 73651630-4652-11ec-1e64-bb4565453376
md"## Función de distribución par
Conforme el número de partículas por unidad de volumen ρ = N/V aumenta, nos alejamos cada vez más de la descripción ideal de un gas. Ahora tenemos que tener en cuenta diferentes efectos que inicialmente despreciamos. En este punto al interacción entre partículas y como se acomodan unas con respecto a otras empieza a tener un papel fundamental.

En teoría de líquidos se define a la función de distribución par de la siguiente manera

$g(r) = \frac{1}{N^2}\left\langle \sum_{i=1}^N\sum_{j\neq i}\delta(\bf{r}-r_{ij})\right\rangle$

donde $<...>$ indica el promedio sobre el ensable de partículas.
"

# ╔═╡ 93329eb0-4657-11ec-132a-c182ba31c004
md"En términos de la fracción de volumen

$η = \frac{\pi}{6}\rho\sigma^3$

donde $\sigma$ es el diámetro de las partículas que componen al sistema.
"

# ╔═╡ a07114e0-4656-11ec-3214-11a28e0b77a5
@bind η html"<input type=range min=0.01 max=0.61 step = 0.01 name = 'eta'>"

# ╔═╡ 5e718600-4657-11ec-0915-21648db10d21
md"Fracción de volumen η = $η"

# ╔═╡ 0dfe9fe0-4658-11ec-1933-1bf79955f78d
begin
	r = collect(0:0.01:4.0)
	gdr = g_HS.(η, r)
	plot(
		r, gdr,
		xlim = (0, 4),
		ylim = (0, 5.2),
		xlabel = "r/σ",
		#ylabel = "",
		title = "Función de distribución para η = "*string(η),
		color = "blue",
		label = nothing
	)
end

# ╔═╡ 58463582-46f9-11ec-268c-751cbebf3278
md"""Una vez que tenemos acceso a la función de distribución par $g(r)$ de nuestro sistema estamos en posición de calcular diferentes propiedades termodinámicas a través de las relaciones para:

* la energía interna del sistema
$\frac{E}{Nk_BT} = \frac{3}{2} + \frac{\rho}{2k_BT}\int_0^\infty u(r)g(r; \rho, T)4\pi r^2 dr$

* la presión
$\frac{P}{k_BT} = \rho - \frac{\rho^2}{6k_BT}\int_0^\infty r\frac{du}{dr}g(r;\rho, T)4\pi r^2 dr$

* los números de coordinación
$n_1 = 4\pi\int_{r_0}^{r_1}r^2g(r;\rho, T)\rho dr$
$n_2 = 4\pi\int_{r_1}^{r_2}r^2g(r;\rho, T)\rho dr$

entre otras cantidades.
"""

# ╔═╡ 8b280910-4708-11ec-3ada-f1666054526d
md"Para esferas duras estas funciones se escriben"

# ╔═╡ e950a64e-4708-11ec-2cf2-ff816514ff44
"""
`E_HS(η)`
# Argumentos
`η::Real` Fracción de Volumen
Energía de un sistema de esferas duras.
"""
E_HS(η::Real) = 3/2 + 12*η*g_HS(η, 1.0)

# ╔═╡ 2252fd10-4707-11ec-3a95-393bde6a86e7
"""
`P_HS(η)`
# Argumentos
`η::Real` Fracción de volumen
Presión para un sistema de esferas duras
"""
P_HS(η:: Real) = 1 + 4*η*g_HS(η, 1.0)

# ╔═╡ a97c34ce-4709-11ec-326b-77760fe10f5e
"""
`n1_HS(η)`
#Argumentos
`η::Real` Fracción de volumen
Primer número de coordinación para esferas duras
"""
function n1_HS(η::Real)
	r = collect(1.0:0.01:2.0)
	g = g_HS.(η, r)
	r₁ = 1.0
	r₂ = r[findmin(g_HS.(η, r))[2]]
	n1 = 0.0
	for i in 1:length(r)-1
		#if r[i]>r₂ break end
		n1 += 0.5*(g[i+1]*(r[i+1]^2) + g[i]*(r[i]^2))*(r[i+1]-r[i])
	end
	return n1*(24*η)
end

# ╔═╡ c2ab8b2e-470a-11ec-149c-6f45c8dbd7b7
"""
`n2_HS(η)`
#Argumentos
`η::Real` Fracción de volumen
Segundo número de coordinación para esferas duras
"""
function n2_HS(η::Real)
	x₁ = collect(1.0:0.001:2.0)
	x₂ = collect(2.0:0.001:3.0)
	r₁ = x₁[findmin(g_HS.(η, x₁))[2]]
	Aux = x₂[findmax(g_HS.(η, x₂))[2]]
	Aux2 = collect(Aux:0.001:3.0)
	r₂ = Aux2[findmin(g_HS.(η, Aux2))[2]]
	r = collect(r₁:0.001:r₂)
	g = g_HS.(η, r)
	n2 = 0.0
	for i in 1:length(r)-1
		n2 += 0.5*(g[i+1]*(r[i+1]^2) + g[i]*(r[i]^2))*(r[i+1]-r[i])
	end
	return n2*(24*η)
end

# ╔═╡ 7a2a7d20-470b-11ec-28f5-8dff25db2329
begin
	ϕ = collect(0.0:0.01:0.61)
	E_ = E_HS.(ϕ)
	P_ = P_HS.(ϕ)
	plot(
		ϕ, E_,
		xlim = (0, 0.61),
		#ylim = (0, 2),
		xlabel = "η",
		#ylabel = "Presión",
		title = "Relaciones termodinámicas para esferas duras",
		#color = color,
		label = "Energía"
	)
	plot!(
		ϕ,P_,
		label = "Presión"
	)
end

# ╔═╡ 2ad22ec0-470c-11ec-3f12-1734b0f6e46f
begin
	n1 = n1_HS.(ϕ)
	n2 = n2_HS.(ϕ)
	plot(
		ϕ, n1,
		xlim = (0, 0.61),
		#ylim = (0, 2),
		xlabel = "η",
		#ylabel = "Presión",
		title = "Números de coordinación para esferas duras",
		#color = color,
		label = "n₁"
	)
	plot!(
		ϕ, n2,
		label = "n₂"
	)
end

# ╔═╡ 0b472b8e-4659-11ec-1610-c593fcdfa4ea
md"## Factor de estructura estático

A través de esperimento de dispersión de luz tenemos la capacidad de obtener el factor de estructura estático $S(k)$ definido como

$S(k) = 1 + ρ\int d^3r e^{ik\cdot r}g(r)$

"

# ╔═╡ 7d8ed8b0-4659-11ec-1d7d-2dfadaed17fe
#include("src\\StructureFactor.jl")
function ingredients(path::String)
	# this is from the Julia source code (evalfile in base/loading.jl)
	# but with the modification that it returns the module instead of the last object
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

# ╔═╡ 9c1203b2-465a-11ec-0706-e73d81bdd4ff
SCGLE = ingredients("..\\src\\StructureFactor.jl")

# ╔═╡ 3c325cd0-46f8-11ec-137f-1bda155f381b
@bind η_2 html"<input type=range min=0.01 max=0.61 step = 0.01 name = 'eta_2'>"

# ╔═╡ 46d10560-46f8-11ec-38c1-99b4b0d206a7
md"η = $η_2"

# ╔═╡ a78dccf0-46f6-11ec-099c-f94a32f80f01
begin
	G = SCGLE.Grid(0, 10*π, 1000);
	L = SCGLE.Liquid(η_2);
	S = SCGLE.SF(L, G, SCGLE.HS; VerletWeis = true);
	plot(
		G.x, S,
		xlim = (0, 10*π),
		ylim = (0, 3.5),
		xlabel = "kσ",
		#ylabel = "",
		title = "Factor de estructura estático para η = "*string(η),
		color = "blue",
		label = nothing
	)
end

# ╔═╡ 0e31a6a0-4730-11ec-0a21-254eb908769e
md"## SCGLE
Si exploras el código de la línea anterior observarás que la función de arriba proviene de una biblioteca de archivos denominada _SCGLE_. Estas son las siglas de la **Self Consistent Generalized Langevin Equation** y será el foco de atención de la siguiente nota.
"

# ╔═╡ Cell order:
# ╟─1c91a0d0-461b-11ec-3b8a-b9f787d314ab
# ╠═e75fd910-4627-11ec-0dc6-adab90533fd1
# ╠═e1f10af0-463e-11ec-0b4a-4960b479e61d
# ╟─d7c81750-462d-11ec-1611-4974efe612b8
# ╟─2aaba4c0-462c-11ec-1e85-197387c11e1a
# ╟─872b7e8e-462d-11ec-1cf3-edbe21be6097
# ╟─9b30fae0-464c-11ec-1329-69ee8202881e
# ╟─fed729e0-4712-11ec-0a9d-558105f8e60b
# ╟─64326de0-4713-11ec-38ac-c10b0e2f087c
# ╟─db1b1d70-462e-11ec-1eba-a966d4e17f37
# ╟─b7083860-4650-11ec-3f43-c5752e792c11
# ╟─051aae60-4652-11ec-3297-633499a95261
# ╟─73651630-4652-11ec-1e64-bb4565453376
# ╠═dc771940-4655-11ec-22be-11a976e7623a
# ╟─93329eb0-4657-11ec-132a-c182ba31c004
# ╟─a07114e0-4656-11ec-3214-11a28e0b77a5
# ╟─5e718600-4657-11ec-0915-21648db10d21
# ╟─0dfe9fe0-4658-11ec-1933-1bf79955f78d
# ╟─58463582-46f9-11ec-268c-751cbebf3278
# ╟─8b280910-4708-11ec-3ada-f1666054526d
# ╠═e950a64e-4708-11ec-2cf2-ff816514ff44
# ╠═2252fd10-4707-11ec-3a95-393bde6a86e7
# ╠═a97c34ce-4709-11ec-326b-77760fe10f5e
# ╠═c2ab8b2e-470a-11ec-149c-6f45c8dbd7b7
# ╠═7a2a7d20-470b-11ec-28f5-8dff25db2329
# ╟─2ad22ec0-470c-11ec-3f12-1734b0f6e46f
# ╟─0b472b8e-4659-11ec-1610-c593fcdfa4ea
# ╟─7d8ed8b0-4659-11ec-1d7d-2dfadaed17fe
# ╠═9c1203b2-465a-11ec-0706-e73d81bdd4ff
# ╟─3c325cd0-46f8-11ec-137f-1bda155f381b
# ╠═46d10560-46f8-11ec-38c1-99b4b0d206a7
# ╠═a78dccf0-46f6-11ec-099c-f94a32f80f01
# ╟─0e31a6a0-4730-11ec-0a21-254eb908769e
