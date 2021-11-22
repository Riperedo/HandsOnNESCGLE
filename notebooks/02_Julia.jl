### A Pluto.jl notebook ###
# v0.12.10

using Markdown
using InteractiveUtils

# ╔═╡ ef97835e-441c-11ec-0b03-2f63789175d6
md"# 0.2 _Continuación_ Julia para principiantes

Continuaremos con la mención de elementos básicos de programación en la sintaxis de **Julia**.

## Operadores lógicos

Las [operaciones lógicas básicas](https://docs.julialang.org/en/v1/manual/missing/#Logical-operators) para un par de variables tipo `Bool`
"


# ╔═╡ 1ddf8150-441d-11ec-0ce5-99031225fb03
Alice = true

# ╔═╡ 27eda9b0-441d-11ec-0a3c-cb5d29c4f580
Bob = false

# ╔═╡ 2ee67bbe-441d-11ec-3c90-457bc6892069
md"""están definidas como

operador | sintaxis
:------------ | :-------------:
and | &
or | \|
xor | ⊻
nor | !

Y para nuestras variables iniciales:"""

# ╔═╡ 3aed66e0-441d-11ec-3496-79f4d52956b1
Alice & Bob # and

# ╔═╡ 3e964aa0-441d-11ec-0d4d-33b48bb6dce0
Alice | Bob # or

# ╔═╡ 41bb3150-441d-11ec-1905-ad0ec94411f3
Alice ⊻ Bob # xor \xor<tab>

# ╔═╡ 450ea210-441d-11ec-0960-3bae154c6b66
!Alice # not

# ╔═╡ 495ec250-441d-11ec-357b-5b8d05c6fb6a
Alice == Bob # equal

# ╔═╡ 4c6a0680-441d-11ec-227c-f3a159f322dc
Alice != Bob # not equal

# ╔═╡ 52d2a680-441d-11ec-3f11-d5a095b85975
md"intenta reemplazar las variables `true` y `false` por `1` y `0` y observa lo que pasa.

Adicionalmente podemos incluir operadores de comparación de valores, es decir, el _mayor que_ `>` o el _menor que_ `<`.
"


# ╔═╡ 56fa5730-441d-11ec-29d2-af10202ee5c7
md"## Control de flujo

Este tipo de condicionales y operadores lógicos nos permiten utilizar el operador ternario `?` y su sintaxis la observamos en la función de _Heaviside_
"

# ╔═╡ 5bf20210-441d-11ec-2e29-ad782fcda0a9
"""
`Heaviside(x::Real)`

# Argumentos
`x::Real` Variable real, puede ser tipo `Integer`, `Float64`, `Real` entre otros.

Si el argumento es menor que `0` regresa 0, en otro caso regresa `1`.
"""
Heaviside(x) = x < 0 ? 0 : 1

# ╔═╡ 602cc590-441d-11ec-02db-b39a7def298a
x = collect(0:0.1:1)

# ╔═╡ 637eafb0-441d-11ec-1a1f-43df66828746
Heaviside.(x .- 0.5)

# ╔═╡ 69cce9e0-441d-11ec-2181-811628200f50
md"Otra forma de definir esta misma función es con la sentencia `if` ... `else`"

# ╔═╡ 7307bcb0-441d-11ec-0771-e7fb204fc8ff
"""
Funcion ejemplo para la sentencia `if` ... `else`
"""
function Heaviside_if_else(x)
	if x < 0
		return 0
	else
		return 1
	end
end

# ╔═╡ 7b445960-441d-11ec-3b79-9f53db8efdb2
Heaviside_if_else.(x .- 0.5)

# ╔═╡ 806f9760-441d-11ec-2330-bf02b6dae3e2
md"## Ciclos

Para ejemplificar la sistaxis de los ciclos `for` y `while` evaluemos el producto interno de un par de arreglos.
"

# ╔═╡ 841546d0-441d-11ec-39d0-97f7343566eb
n = 10

# ╔═╡ 87a3ebd0-441d-11ec-09d5-810023f47077
A = rand(n)

# ╔═╡ 8a8539d0-441d-11ec-0176-31514b7c2ba4
B = rand(n)

# ╔═╡ 918b2b40-441d-11ec-0fa7-17d7d4fa5550
md"La forma más económica de calcular el producto interno es hacer simplemente"

# ╔═╡ 9820ceb2-441d-11ec-2369-6dff6cb7c9f9
"""
`dot(a, b)`

# Argumentos:
`a::Vector` arreglo con valores numéricos
`b::Vector` arreglo con valores numéricos
"""
dot(a,b) = a'b

# ╔═╡ a43d1690-441d-11ec-2702-1bb08fe9bff0
md"con tal de ilustrar escribimos para el ciclo `for`"

# ╔═╡ 9ea9ef00-441d-11ec-32b7-d3027e0b61b6
"""
`dot_for(a, b)`

# Argumentos:
`a::Vector` arreglo con valores numéricos
`b::Vector` arreglo con valores numéricos

Calcula el producto interno de `a` con `b` utilizando el ciclo `for`.
"""
function dot_for(a, b)
	@assert length(a) == length(b) "Los vectores deben ser de la misma longitud"
	n = length(a)
	producto = 0
	for i in 1:n
		producto += a[i]*b[i]
	end
	return producto
end

# ╔═╡ ae777f10-441d-11ec-0057-dd21b9c79ff7
md"el macro `@assert` nos permite tener un control sobre los parámetros que entran a la función. Finalmente para el ciclo `while`"

# ╔═╡ b853c200-441d-11ec-010b-5f23c6d20be0
"""
`dot_while(a, b)`

# Argumentos:
`a::Vector` arreglo con valores numéricos
`b::Vector` arreglo con valores numéricos

Calcula el producto interno de `a` con `b` utilizando el ciclo `while`. Si estás utilizando Windows no modifiques esta función.
"""
function dot_while(a, b)
	@assert length(a) == length(b) "Los vectores deben ser de la misma longitud"
	n = length(a)
	i = 1
	producto = 0
	while i < n + 1
		producto += a[i]*b[i]
		i += 1
	end
	return producto
end


# ╔═╡ ca2fe6c0-441d-11ec-05ca-13a6fa03a77e
md"Evaluamos cada función"

# ╔═╡ cd405b10-441d-11ec-3f5c-03e6d2135fac
dot(A, B)

# ╔═╡ 125d0870-441d-11ec-06c1-85727cbd06bf
dot_for(A, B)

# ╔═╡ d438df00-441d-11ec-3a97-c3eaeea9d02e
dot_while(A, B)

# ╔═╡ 438ecfb0-44a8-11ec-10d8-c161aaa00651
md"## El comando `break`
Cualquiera de estos ciclos se pueden interrumpir si añadimos alguna condición de paro. Para esto necesitamos la palabra reservada `break`. Un ejemplo de esto sería"

# ╔═╡ 943eb770-44aa-11ec-3a51-fd1f9e192ad6
x

# ╔═╡ 2c322b90-44a9-11ec-2aec-4b25f02deb77
begin
	respuesta = x[1]
	for x_i in x
		#if x_i > 0.4 break end
		global respuesta = x_i
	end
end

# ╔═╡ 6f1b61ae-44a9-11ec-20ad-db75e7ecc676
md"y el 'ultimo valor de la variable `respuesta` = $respuesta.

Intenta borrar la palabra reservada `global` y observa lo que pasa.
"

# ╔═╡ 1f015480-44ab-11ec-06d4-4588c8d2ee45
md"Para el uso de esta libreta en _Pluto.jl_ es necesario incluir el entorno `begin` ... `end` para agregar secciones de código. Sin embargo, esto no es necesario cuando trabajas utilizando _scripts_."

# ╔═╡ Cell order:
# ╟─ef97835e-441c-11ec-0b03-2f63789175d6
# ╠═1ddf8150-441d-11ec-0ce5-99031225fb03
# ╠═27eda9b0-441d-11ec-0a3c-cb5d29c4f580
# ╟─2ee67bbe-441d-11ec-3c90-457bc6892069
# ╠═3aed66e0-441d-11ec-3496-79f4d52956b1
# ╠═3e964aa0-441d-11ec-0d4d-33b48bb6dce0
# ╠═41bb3150-441d-11ec-1905-ad0ec94411f3
# ╠═450ea210-441d-11ec-0960-3bae154c6b66
# ╠═495ec250-441d-11ec-357b-5b8d05c6fb6a
# ╠═4c6a0680-441d-11ec-227c-f3a159f322dc
# ╟─52d2a680-441d-11ec-3f11-d5a095b85975
# ╟─56fa5730-441d-11ec-29d2-af10202ee5c7
# ╠═5bf20210-441d-11ec-2e29-ad782fcda0a9
# ╠═602cc590-441d-11ec-02db-b39a7def298a
# ╠═637eafb0-441d-11ec-1a1f-43df66828746
# ╟─69cce9e0-441d-11ec-2181-811628200f50
# ╠═7307bcb0-441d-11ec-0771-e7fb204fc8ff
# ╠═7b445960-441d-11ec-3b79-9f53db8efdb2
# ╟─806f9760-441d-11ec-2330-bf02b6dae3e2
# ╠═841546d0-441d-11ec-39d0-97f7343566eb
# ╠═87a3ebd0-441d-11ec-09d5-810023f47077
# ╠═8a8539d0-441d-11ec-0176-31514b7c2ba4
# ╟─918b2b40-441d-11ec-0fa7-17d7d4fa5550
# ╠═9820ceb2-441d-11ec-2369-6dff6cb7c9f9
# ╟─a43d1690-441d-11ec-2702-1bb08fe9bff0
# ╠═9ea9ef00-441d-11ec-32b7-d3027e0b61b6
# ╟─ae777f10-441d-11ec-0057-dd21b9c79ff7
# ╠═b853c200-441d-11ec-010b-5f23c6d20be0
# ╟─ca2fe6c0-441d-11ec-05ca-13a6fa03a77e
# ╠═cd405b10-441d-11ec-3f5c-03e6d2135fac
# ╠═125d0870-441d-11ec-06c1-85727cbd06bf
# ╠═d438df00-441d-11ec-3a97-c3eaeea9d02e
# ╟─438ecfb0-44a8-11ec-10d8-c161aaa00651
# ╠═943eb770-44aa-11ec-3a51-fd1f9e192ad6
# ╠═2c322b90-44a9-11ec-2aec-4b25f02deb77
# ╟─6f1b61ae-44a9-11ec-20ad-db75e7ecc676
# ╟─1f015480-44ab-11ec-06d4-4588c8d2ee45
