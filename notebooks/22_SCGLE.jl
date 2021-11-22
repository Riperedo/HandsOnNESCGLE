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

# ╔═╡ 6bcaf9e0-48a9-11ec-125c-f704ef65a7e8
begin
	using DelimitedFiles
	using Plots
	using PlutoUI
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

# ╔═╡ 0484a100-48a4-11ec-1ef7-db717ddeb9cd
md"# SCGLE Parte 2
Uno de los primeros resultados que podemos obtener es el diagrama de arresto dinámico. Esto lo calculamos a partir del límite asintótico de las ecuaciones de la teoría

$\psi(k) = \lim_{t\to\infty}\frac{F(k,t)}{S(k)} = \frac{\lambda(k)S(k)}{\lambda(k)S(k) + k^2\lambda(k)}$
$\psi_s(k) = \lim_{t\to\infty}F_s(k,t)=\frac{\lambda(k)}{\lambda(k) + k^2\lambda(k)}$
$\frac{1}{\gamma} = \frac{1}{6\pi^2\rho}\int_0^\infty dkk^4\frac{[S(k)-1]^2\lambda^2(k)}{[\lambda(k)S(k) + k^2\gamma][\lambda(k) + k^2\gamma]}$
donde $\gamma$ es la longitud de localización. Esta cantidad está relacionada con el desplazamiento cuadrático medio y nos ayudará a determinar si el sistema que estamos estudiando es un sistema fluido o arrestado

$\gamma=\left\lbrace
\begin{matrix}
\text{valor infinito} &\to & \text{fluido}\\
\text{valor finito} &\to & \text{arrestado}
\end{matrix}
\right.$
"

# ╔═╡ 33e51700-48a8-11ec-0f6b-b71191275f83
begin
	a = readdlm("..\\DAT\\memoria0p1.dat", Float64)
	t, Δr² = a[:, 1], a[:, 6]
	plot(
		t, Δr², 
		xaxis=:log, yaxis=:log,
		xlabel = "t/tB",
		ylabel = "<Δr²(t)>/σ²",
		xrange = (1e-6, 1e6),
		yrange = (1e-6, 1e6),
		label = "η = 0.1"
	)
	a = readdlm("..\\DAT\\memoria0p6.dat", Float64)
	t, Δr² = a[:, 1], a[:, 6]
	plot!(
		t, Δr²,
		label = "η = 0.6",
		legend = :topleft
	)
end

# ╔═╡ 028df060-48c0-11ec-39e0-5dac023b7f42
md"## Diagrama de arresto
Tomando este criterio en cuenta estamos en posición de dibujar un diagrama de aresto dinámico. Consideremos una vez más al sistema de esferas duras. Para ello, importamos la librería de la SCGLE
"

# ╔═╡ 6aafce70-48c0-11ec-007d-af423048282c
SCGLE = ingredients("..\\src\\Dynamics.jl");

# ╔═╡ 461c23a0-48c1-11ec-1940-95cebaad610a
md"Elegimos una fracción de volumen"

# ╔═╡ f9bf3060-48c0-11ec-182d-0d1d13466a91
@bind ϕ html"<input type=range min=0.4 max=0.66 step = 0.001 name = 'phi'>"

# ╔═╡ 11fbb7c0-48c1-11ec-3526-9f786450cd8c
md"Fracción de volumen: $ϕ

llamamos a los objetos tipo Grid y Liquid
"

# ╔═╡ 72322660-48c1-11ec-2e38-4dcc87184908
G = SCGLE.Grid(0, 15*π, 2000);

# ╔═╡ 79309dc0-48c1-11ec-2e75-77bb81157ac9
L = SCGLE.Liquid(ϕ);

# ╔═╡ 8a047a40-48c1-11ec-32ae-9359c3013327
md"Generamos el factor de estructura estático para esferas duras bajo la solución de Percus-Yevick."

# ╔═╡ 9d453810-48c1-11ec-2c4a-03682686f49e
S = SCGLE.SF(L, G, SCGLE.HS; VerletWeis = true);

# ╔═╡ c1ee7140-48c1-11ec-24fd-03abb8326f19
md"""Decimos que el sistema de esferas duras es un sistema _atermico_, debido a que el sistema es independiente de la temperatura del sistema. En este caso el único parámetro de control por el que nos debemos preocupar es la fracción de volumen.

Dentro de la librería de la SCGLE tenemos definida una función para evaluar la longitud de localización y tiene la forma


```julia
Asymptotic(L :: Liquid, G :: Grid, S :: Array{Float64, 1}; flag= false)
```
es una función de los objetos que hemos construido previamente. La keyword `flag` es para desplegar la información del proceso.
"""

# ╔═╡ a81b926e-48c1-11ec-2295-a7df0dcf15e8
with_terminal() do
	println("ϕ = ", ϕ)
	SCGLE.Asymptotic(L, G, S; flag= true)
end

# ╔═╡ e8f86150-48c2-11ec-301e-e37e7b971563
md"### ¿Cuál es el valor de la fracción de volumen para la transición _fluido-glass_?
Revisa que pasa si quitas la aproximación de Verlet-weis.
"

# ╔═╡ 2b68bdf0-48c3-11ec-3ddf-ed6607844f4b
md"## Factor de estructura para un sistema de esferas suaves

Dentro de esta paquetería tenemos escrita una rutina para generar el factor de estrutura estático para un sistema de esferas suaves. Esta utiliza la aproximación de la función _blip_ y la aproximación de Verlet-Weis[[1](https://doi.org/10.1103/PhysRevE.87.052306)]. Para generar esa curva escribimos los parámetros de entrada
"

# ╔═╡ 5bd1dc42-48c5-11ec-0921-ff96cc83980c
ϕ_s = 0.609;

# ╔═╡ f6400270-48c5-11ec-0832-056d1a75bc3a
T_s = 1e-2;

# ╔═╡ 28a31170-48c7-11ec-1587-7b868e2d42a4
md"llamamos a las rutinas de la teoría"

# ╔═╡ 41f04cde-48c4-11ec-1b8a-73141436a2f1
L_s = SCGLE.Liquid(ϕ_s);

# ╔═╡ 3488d570-48c6-11ec-2741-59ec25e3545c
L_s.T = T_s;

# ╔═╡ 5cd9b9e0-48c6-11ec-04c6-2f7217251991
L_s.Soft();

# ╔═╡ 77c69430-48c6-11ec-047f-cb575244c1ac
S_s = SCGLE.SF(L_s, G, SCGLE.HS);

# ╔═╡ ad2e4d20-48c6-11ec-3bd2-57e30ed63212
with_terminal() do
	println("(ϕ, T) = (", ϕ_s, ", ", T_s, ")")
	SCGLE.Asymptotic(L_s, G, S_s; flag= true)
end

# ╔═╡ eb818aee-48c7-11ec-15f4-f5725aa1c314
md""" Comprueba el diagrama de arresto de esferas suaves variando los valores de `ϕ_s` y `T_s`.
"""

# ╔═╡ 23605e60-48c8-11ec-1c6e-8192d9de753d
begin
	b = readdlm("..\\DAT\\diagrama_de_arresto.dat", Float64)
	plot(
		b[:, 1], b[:,2], 
		yaxis=:log,
		xrange = (0.45, 0.7),
		yrange = (1e-6, 1e2),
		xlabel = "ϕ",
		ylabel = "T",
		title= "Diagrama de arresto para esferas suaves",
		legend = nothing
	)
end

# ╔═╡ Cell order:
# ╟─0484a100-48a4-11ec-1ef7-db717ddeb9cd
# ╟─6bcaf9e0-48a9-11ec-125c-f704ef65a7e8
# ╟─33e51700-48a8-11ec-0f6b-b71191275f83
# ╟─028df060-48c0-11ec-39e0-5dac023b7f42
# ╠═6aafce70-48c0-11ec-007d-af423048282c
# ╟─461c23a0-48c1-11ec-1940-95cebaad610a
# ╠═f9bf3060-48c0-11ec-182d-0d1d13466a91
# ╟─11fbb7c0-48c1-11ec-3526-9f786450cd8c
# ╠═72322660-48c1-11ec-2e38-4dcc87184908
# ╠═79309dc0-48c1-11ec-2e75-77bb81157ac9
# ╟─8a047a40-48c1-11ec-32ae-9359c3013327
# ╠═9d453810-48c1-11ec-2c4a-03682686f49e
# ╟─c1ee7140-48c1-11ec-24fd-03abb8326f19
# ╠═a81b926e-48c1-11ec-2295-a7df0dcf15e8
# ╟─e8f86150-48c2-11ec-301e-e37e7b971563
# ╟─2b68bdf0-48c3-11ec-3ddf-ed6607844f4b
# ╠═5bd1dc42-48c5-11ec-0921-ff96cc83980c
# ╠═f6400270-48c5-11ec-0832-056d1a75bc3a
# ╟─28a31170-48c7-11ec-1587-7b868e2d42a4
# ╠═41f04cde-48c4-11ec-1b8a-73141436a2f1
# ╠═3488d570-48c6-11ec-2741-59ec25e3545c
# ╠═5cd9b9e0-48c6-11ec-04c6-2f7217251991
# ╠═77c69430-48c6-11ec-047f-cb575244c1ac
# ╠═ad2e4d20-48c6-11ec-3bd2-57e30ed63212
# ╟─eb818aee-48c7-11ec-15f4-f5725aa1c314
# ╟─23605e60-48c8-11ec-1c6e-8192d9de753d
