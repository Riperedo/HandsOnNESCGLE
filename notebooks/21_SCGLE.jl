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

# ╔═╡ 2ec4e880-47d7-11ec-35d9-57ead925c116
using PlutoUI

# ╔═╡ d6181600-48a1-11ec-2fe0-4309cbb1c243
using Plots

# ╔═╡ c2d87250-4730-11ec-1b11-513d37e39f0b
md"""# SCGLE Parte 1

En 1827, el botánico escocés Robert Brown se dispuso a analizar al microscópio una muestra de [granos de polen sumergidos en agua](https://sciweb.nybg.org/science2/pdfs/dws/Brownian.pdf). Observó que sus partículas, amiloplastos y esferosomas, se estremecían en el líquido, como sometidas al bombardeo constante de unos proyectiles invisibles. Los impactos las hacían rotar y perderse en trayectorias zigzagueantes. Brown no podía observar con su microscopio de 300 aumentos las moléculas de agua, las cuales chocan de modo aleatorio, millones de veces, contra los objetos diminutos que se sumergen en ella y los zarandean, comunicándoles su agitación térmica. Este fenómeno es conocido como _Movimiento Browniano_. Un experimento similar se observa en el siguiente [video de  Koshu Endo](https://www.youtube.com/watch?v=R5t-oA796to).
"""

# ╔═╡ bd9997f0-47c2-11ec-35ae-d7c8a7c3e666
md"""
La teoría Generalizada de Langevin autoconsistente (SCGLE por sus siglas en inglés) es un marco de trabajo que parte de la teoría de fluctuaciones de Onsager-Machlup[[1](https://doi.org/10.1103/PhysRev.91.1505)] y describe la evolución dinámica de un sistema coloidal en equilibrio[[2](https://doi.org/10.1103/PhysRevE.64.066114)] y recientemente para sistemas atómicos [[3](https://iopscience.iop.org/article/10.1209/0295-5075/99/46001)]. De acuerdo con la SCGLE, para una partícula coloidal elegida arbitrariamente, la cual deniminamos la _partícula trazadora_, la ecuación de movimiento está dada por la ecuación generalizada de Langevin

$m_T\frac{dV_T}{dt} = -\zeta_0\cdot V_T(t) + f(t) - \int_0^tdt'\Delta\zeta(t-t')\cdot V_T(t') + F(t)$

los primeros dos términos del lado derecho componen a la versión ordinaria de la _ecuación de Langevin_, los cuales decriben la interacción de la trazadora con el líquido portador y los últimos dos términos describen una fricción y fuerza estocástica efectiva debido a la interacción de la trazadora con las demás partículas coloidales.
"""

# ╔═╡ 1155e8b0-473e-11ec-0bb1-bb56da356ec4
md"""El término de fricción efectiva o término de memoria $\Delta\zeta(t)$ depende funcionalmente de la evolución dinámica de las funciones de dispersión intermedias

$F_s(k, \tau) = \frac{1}{N}\sum_{i=1}^n\left<\exp[-ik\cdot (r_i(t+\tau)-r_i(\tau))]\right>$

$F(k, \tau) = \frac{1}{N}\sum_{i=1}^n\sum_{j=i}^n\left<\exp[-ik\cdot (r_i(t+\tau)-r_j(\tau))]\right>$

Por lo que la SCGLE se constituye de la solución simultanea del siguiente sistema ecuaciones

$\tilde{F}_s(k, z) =\frac{1}{z + \frac{k^3D_0}{1+\lambda(k)\tilde{\Delta\zeta}(z)}}$

$\tilde{F}(k, z) =\frac{S(k)}{z + \frac{k^3D_0S^{-1}(k)}{1+\lambda(k)\tilde{\Delta\zeta}(z)}}$

$Δ\zeta (\tau) = \frac{D_0}{24\pi^3 \rho}\int d^3k k^2\left[\frac{S(k)-1}{S(k)}\right]^2F(k, \tau)F_s(k, \tau)$

donde $\tilde{F}(z)$  es la transformada de Laplace de $F(\tau)$ y $\lambda(k)$ es una _función de interpolación_ definida como

$\lambda(k) = 1/[1+(k/k_c)^2]$

y $k_c$ es un parámetro ajustable, para el caso de esferas duras $k_c= 1.302\times 2\pi$. 
"""

# ╔═╡ 48eb6df2-47c9-11ec-1b02-8d4aed012c4e
md""" El funcionamiento más básico de la teoría es el siguiente:
* Ingresamos una colección de parámetros termodinámicos como la densidad de partículas $\rho$ y/o la temperatura $T$,
* con esto obtenemos un factor de estructura estático $S(k)$,
* resolvemos las ecuaciones de la SCGLE,
* en consecuencia obtenemos la dependencia funcional de la fricción $\Delta\zeta$ y las funciones de dispersión intermedias $F$ y $F_s$ como función del tiempo de correlación, y
* finalmente, calculamos propiedades de transporte como la movilidad $b$, la viscosidad $η$ o el tiempo de relajación $\tau_\alpha$.

```
 Input					Output       Propiedades
 (ρ, T)                             de transporte 
    ↓                   ┌             
┌------┐   ┌-------┐    | Δζ(t)     -> b
| S(k) | → | SCGLE | → -| F(k, t)   -> η
└------┘   └-------┘    | Fₛ(k, t)  -> τα
                        └
```
"""

# ╔═╡ 9e362ad0-47dc-11ec-0138-974a28736e87
md"""## La presente librería
Primero cargamos la librería. Si estás trabajando con _scrpts_ simplemente añade la linea

```julia
include("src\\Dynamics.jl");
```

siempre y cuando el script se ecuentre en la misma dirección que la carpeta "src". Para la libreta _Pluto_ hacemos

"""

# ╔═╡ ffc2caa0-488c-11ec-34d3-2174ffab6064
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

# ╔═╡ bbd236a2-488c-11ec-220b-c7ae21308423
SCGLE = ingredients("..\\src\\Dynamics.jl");

# ╔═╡ 2dc0ee50-488d-11ec-1d0c-258948858d38
md"Con esto generamos un objeto llamado `SCGLE` cuyos atributos discutiremos en la siguiente subsección con ayuda de la _PlutoUI_"

# ╔═╡ 6b4efcd0-488d-11ec-34eb-1da64622d028
md"Esta es una terminal idéntica a la Julia. Juega con el código de la siguiente linea."

# ╔═╡ 6bfa0f50-47dc-11ec-2c18-2104ca6f204b
with_terminal() do
	println("¡Hola Mundo!")
end

# ╔═╡ b7ed8cf0-488d-11ec-21c4-9599a0c813db
md"""## El objeto `Liquid`
Creamos un objeto que maneja los parámetros termodinámicos del sistema. El constructor es
```julia
L = SCGLE.Liquid()
L.setDistribution([ρ₁, ρ₂, ..., ρₙ], [σ₁, σ₂, ..., σₙ])
```
donde `[ρ₁, ρ₂, ..., ρₙ]` es una distribución de densidades y `[σ₁, σ₂, ..., σₙ]` una distribución de diámetros. Para esta libreta sólo necesitaremso precisar los siguientes atributos:
* `L.ρ` la densidad total del sistema,
* `L.ϕ` la fracción de volumen,
* `L.T` la temperatura,
* `L.soft` indica si el sistema es de esferas suaves. Para modificar este parámetro escribimos `L.Soft()`.
"""

# ╔═╡ fa376e70-4890-11ec-16d5-e13810bf87a5
md"""Para sistemas monodispersos hemos creado un par de funciones que regresan el objeto Liquid y estas son
```julia
Liquid(ϕ::Real)
Liquid(ϕ::Real, σ::Real)
```
donde `ϕ` es la fracción de volumen del sistema y `σ` el diámetro de las esferas.
"""

# ╔═╡ fd308600-4897-11ec-22cd-1dc686ee3c57
md"""## El objeto `Grid`
Se incluye un objeto para manejar el dominio de las funciones involucradas en los cálculos. Construimos el objeto 
```julia
G = SCGLE.Grid(xₘᵢₙ, xₘₐₓ, n)
```
donde `xₘᵢₙ` y `xₘₐₓ` son los valores extremos del grid y `n` número de puntos del grid. Algunos de los atributos de este objeto son:
* `G.x` Objeto tipo `Array` con el grid,
* `G.n` Número de puntos del grid.

Juega un poco con la siguiente línea
"""

# ╔═╡ 54772d2e-489b-11ec-24bc-77d5fe818491
with_terminal() do
	x₀ = 0.0
	x₁ = 1.0
	n = 10
	G = SCGLE.Grid(x₀, x₁, n)
	#println(G.x)
	println(G.n)
end

# ╔═╡ 1f667870-489c-11ec-05af-c79df7c80508
md"""## Factor de estructura estático
Una vez establecidas las configuraciones iniciales llamamos a la función `SF` para graficar al factor de estructra estático
```julia
SF(L, G, P; VerletWeis = false)
```
donde `L` es un objeto Líquid, `G` un objeto tipo Grid y `P` un objeto tipo Potential el cual no discutiremos a detalle. La _keyword_ `VerletWeis` indica si utilizaremos la corrección de Verlet-Weis[[4](https://doi.org/10.1103/PhysRevA.5.939)]. Para el caso de esferas duras escribimos `P = HS` y la función regresa la solución de Percus-Yevick para esfera dura[[5](https://doi.org/10.1103/PhysRev.110.1)] que resumimos a continuación

$S(k) = \frac{1}{1 - \rho \tilde{c}(k)}$

donde $\tilde{c}(k)$ es la transformada de Fourier de

$c(r) = \left\lbrace
\begin{matrix}
\alpha(\phi) + \beta(\phi)r + \gamma(\phi) & r\leq\sigma\\
0 & r>\sigma
\end{matrix}
\right.$

con $\phi = \pi\rho\sigma^3/6$ y

$\begin{matrix}
\alpha(\phi) &=& -\frac{(1+2\phi)^2}{(1-\phi)^4}\\
\beta(\phi) &=& 6\phi\frac{(1+0.5\phi)^2}{(1-\phi)^4}\\
\gamma(\phi) &=& 0.5\phi\alpha(\phi)
\end{matrix}$

"""

# ╔═╡ 50762fa0-48a1-11ec-3ca6-edab1bca1721
md"Graficamos utilizando los objetos defidos lineas arriba."

# ╔═╡ 1fe44c3e-48a2-11ec-3444-3bfb0739a21b
@bind ϕ html"<input type=range min=0.01 max=0.61 step = 0.01 name = 'phi'>"

# ╔═╡ 34c7bd90-48a2-11ec-03b1-0169338ed89a
md"Fracción de volumen: $ϕ"

# ╔═╡ e9965200-48a1-11ec-2743-59e84c9e6e26
begin
	G = SCGLE.Grid(0, 20*π, 10000);
	L = SCGLE.Liquid(ϕ);
	S = SCGLE.SF(L, G, SCGLE.HS; VerletWeis = true);
	plot(
		G.x, S,
		xlim = (0, 6*π),
		ylim = (0, 3.5),
		xlabel = "kσ",
		#ylabel = "",
		title = "Factor de estructura estático para ϕ = "*string(L.ϕ[1]),
		color = "blue",
		label = nothing
	)
end

# ╔═╡ 37acfdd0-488f-11ec-2964-f3504a00bdb8
with_terminal() do
	L = SCGLE.Liquid()
	#L.setDistribution([0.1, 0.2, 0.3], [1.0, 0.5, 0.2])
	#L = SCGLE.Liquid(0.4, 1.0)
	#L.T = 10.0
	#L.Soft()
	L.Info()
end

# ╔═╡ Cell order:
# ╟─c2d87250-4730-11ec-1b11-513d37e39f0b
# ╟─bd9997f0-47c2-11ec-35ae-d7c8a7c3e666
# ╟─1155e8b0-473e-11ec-0bb1-bb56da356ec4
# ╟─48eb6df2-47c9-11ec-1b02-8d4aed012c4e
# ╟─9e362ad0-47dc-11ec-0138-974a28736e87
# ╠═ffc2caa0-488c-11ec-34d3-2174ffab6064
# ╠═bbd236a2-488c-11ec-220b-c7ae21308423
# ╟─2dc0ee50-488d-11ec-1d0c-258948858d38
# ╠═2ec4e880-47d7-11ec-35d9-57ead925c116
# ╟─6b4efcd0-488d-11ec-34eb-1da64622d028
# ╠═6bfa0f50-47dc-11ec-2c18-2104ca6f204b
# ╟─b7ed8cf0-488d-11ec-21c4-9599a0c813db
# ╟─fa376e70-4890-11ec-16d5-e13810bf87a5
# ╠═37acfdd0-488f-11ec-2964-f3504a00bdb8
# ╟─fd308600-4897-11ec-22cd-1dc686ee3c57
# ╠═54772d2e-489b-11ec-24bc-77d5fe818491
# ╟─1f667870-489c-11ec-05af-c79df7c80508
# ╟─50762fa0-48a1-11ec-3ca6-edab1bca1721
# ╠═d6181600-48a1-11ec-2fe0-4309cbb1c243
# ╠═1fe44c3e-48a2-11ec-3444-3bfb0739a21b
# ╟─34c7bd90-48a2-11ec-03b1-0169338ed89a
# ╠═e9965200-48a1-11ec-2743-59e84c9e6e26
