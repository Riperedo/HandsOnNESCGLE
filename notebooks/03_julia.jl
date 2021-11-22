### A Pluto.jl notebook ###
# v0.12.10

using Markdown
using InteractiveUtils

# ╔═╡ 73b486f0-44ab-11ec-3dab-b759c24f4bc8
md"# 0.3 _Continuación_ Julia para principiantes (ya no tanto)

Desde _c++_ inicia un paradigma de programación llamado la _programación orientada a objetos_. Paradigma que adoptan de manera familiar [lenguajes de alto nivel](https://es.wikipedia.org/wiki/Lenguaje_de_alto_nivel) como [_Python_](https://www.python.org/) o [_Javascript_](https://www.javascript.com/). Julia tiene su propia sintaxis para la definición de objetos y en esta libreta describiremos algunos ejemplos.
"

# ╔═╡ 80adf2f0-44ac-11ec-368c-39f7469798b6
md"## Objetos en Julia

Por definición, un [objeto](https://es.wikipedia.org/wiki/Objeto_(programaci%C3%B3n)) consta de un estado y un comportamiento. Los estados se escriben en términos de _atributos_ y el comportamiento en términos de _métodos_.

julia trabaja de forma especial con los objetos. Como primer caso comencemos definiendo un objeto sencillo, para esto utilizamos el constructor `struct`
"

# ╔═╡ 07db5b50-44ad-11ec-1797-9b35690eeefd
begin
	"""
	Clase `Perro`
	# Atributos
	`nombre :: Any`
	# Métodos
	por definir
	"""
	mutable struct Perro
		nombre #:: String # 1
		#edad :: Integer # 2
		#tiene_pulgas :: Bool # 3
	end
	# Valores por defecto
	Perro() = Perro("Callejero")
	#Perro(String) = Perro(String, 0) # 2
	#Perro(String, Integer) = Perro(String, Integer, true) # 3
end

# ╔═╡ 2786b2a0-44ae-11ec-22ea-07200f53fbe8
md"Elige un nombre para tu mascota"

# ╔═╡ 3256f27e-44ae-11ec-24d2-199093a31b73
nombre = "El pulgas"

# ╔═╡ 438942b0-44ae-11ec-2c1e-dd59b3b6926c
md"Construimos el objeto haciendo simplemente"

# ╔═╡ 6d829c70-44ad-11ec-2b18-a1b6b67114c2
mascota = Perro(nombre)

# ╔═╡ 9bdb6340-44ad-11ec-354d-0d948b9c4651
md"Ahora nuestra mascota tiene nombre. Ceemos algún amigo para $nombre."

# ╔═╡ 486f1dd0-44af-11ec-0f64-7bc41804823e
amigo = Perro("Solovino")

# ╔═╡ abc0fd40-44af-11ec-21ac-6bdf812e5db9
md"Ahora podemos tener una colección de diferentes objetos"

# ╔═╡ 5f032550-44af-11ec-0d8d-01bbef3ab950
squad = [mascota, amigo, Perro()]

# ╔═╡ 00f0dcf0-44b4-11ec-2520-533167a449d3
md"y accedemos a los nombres haciendo"

# ╔═╡ 111fedf0-44b4-11ec-3fcb-6b2ce0fea7d5
"""
función para imprimir nombres en la terminal
"""
function lista_de_nombres()
	for i in 1:length(squad)
		println(squad[i].nombre)
	end
end

# ╔═╡ b0b16d70-44b5-11ec-337a-0b005cdf12a4
lista_de_nombres()

# ╔═╡ 380e0e0e-44b4-11ec-32bc-b9a46905cf95
md"¿Dónde están los nombres? 

busca en la terminal donde invocaste el entorno Pluto.jl

A este nivel el objeto `perro` no es diferente a una forma adicional de guardar estructuras de datos. Podemos tener control sobre el tipo de datos, por ejemplo, podemos llamar a un nuevo perro con un número
"

# ╔═╡ 72285290-44b4-11ec-06d0-b9dcebeb8037
p_pi = Perro(π) 
#p_pi = Perro("3.14159...") # 1

# ╔═╡ 298d9010-44b7-11ec-0cc9-ede5e90d90e3
md"Para colocar una restricción remueve el símbolo `#` de la linea con terminación `# 1` de la definición de la clase perro. Estas construcciones aplican tambien para la definición de funciones y suelen ser de utilidad cuando hay procesos delicados."

# ╔═╡ 4a8f5a32-44b9-11ec-180b-b5dffcc22f53
md"¿Qué edad tienen nuestra mascota?

Estas estructuras de datos pueden tener más de un atributo. Remueve el `#` de las líneas con terminación `# 2`. Después de eso hacemos simplemente
"

# ╔═╡ a9a3de10-44b9-11ec-16bb-c70bb8ad1011
mascota.edad = 5

# ╔═╡ 1075bc80-44ba-11ec-2dc9-79d7660f262f
md"El error que es posible que observes es debido a que las estructuras de datos presentadas son estáticas y una vez definidas no podemos hacer mucho por cambiarlas. Dependiendo de tu problema te convendrá trabajar un este tipo de arreglo o con estructuras con la capacidad de mutar. Agrega la palabra reservada `mutable` antes de `structure` para arreglar este problema.
"

# ╔═╡ 5d242b22-44ba-11ec-0d2b-b747b20bfeb5
md"Una vez que tu objeto tiene la capacidad de cambiar puedes rejuvenecer a tu mascota cada vez que quieras."

# ╔═╡ 735b1e80-44ba-11ec-27d7-bdfb8379a32f
mascota.edad

# ╔═╡ 7aa2379e-44ba-11ec-30d1-193449f91f68
mascota.edad = 3

# ╔═╡ 80017dee-44ba-11ec-0d19-578adccfc0bd
mascota.edad

# ╔═╡ d29022b0-44ba-11ec-3a57-792de71d6cdf
md"""Por lo pronto nuestra mascota simplemente _es_, es decir, no hace nada. Podemos crear funciones específicas para cada objeto que creemos. Simplemente declaramos la constricción `p :: Perro` dentro de la misma. Quita el símbolo `#` de la definición del objeto `Perro` con la terminación `# 3` para completar la tarea.

Como puedes observar cara vez que necesites hacer una extensión a tu objeto simplemente añade un nuevo atributo y una valor por defecto. 

```julia
mutable struct Objeto
	Atributo1::Any
	Atributo2::Any
	Nuevo_Atributo::Any
end
Objeto(Any, Any) = Objeto(Any, Any, Valor_por_defecto)
```
Definamos una acción
"""

# ╔═╡ d39d93b0-44bd-11ec-3a47-57eb594ddbda
"""
`acción(p)`
# Argumentos
`p::Perro` función del objeto `perro`

Función para que nuestra mascota indique si tiene pulgas.
"""
function acción(p :: Perro)
	if p.tiene_pulgas
		println(p.nombre, ": guau!")
	else
		println(p.nombre, ": *mueve la colita*")
	end
end

# ╔═╡ e4fdaaa0-44bd-11ec-121a-29b72bf1026c
md"Declaremos alguna función para quitar las pulgas del perro."

# ╔═╡ 3bd1eea0-458a-11ec-0afe-77aa368c3df6
"""
`bañar(p)`
# Argumentos
`p::Perro` funci'on del objeto `perro`
"""
function bañar(p::Perro)
	if p.tiene_pulgas
		p.tiene_pulgas = false
	end
end

# ╔═╡ 957ad020-458a-11ec-3ffe-efac99d8147f
acción(mascota)

# ╔═╡ 9e8432b0-458a-11ec-1ad0-4329e18043f6
bañar(mascota);

# ╔═╡ ab993270-458a-11ec-1de8-af59100c599d
acción(mascota)

# ╔═╡ df2cc79e-458a-11ec-0102-f3ab4f1742eb
md"### Reto: ¡baña al squad!
añade un par de miembros al `squad` y dales un buen baño.
"

# ╔═╡ Cell order:
# ╟─73b486f0-44ab-11ec-3dab-b759c24f4bc8
# ╟─80adf2f0-44ac-11ec-368c-39f7469798b6
# ╠═07db5b50-44ad-11ec-1797-9b35690eeefd
# ╟─2786b2a0-44ae-11ec-22ea-07200f53fbe8
# ╠═3256f27e-44ae-11ec-24d2-199093a31b73
# ╟─438942b0-44ae-11ec-2c1e-dd59b3b6926c
# ╠═6d829c70-44ad-11ec-2b18-a1b6b67114c2
# ╟─9bdb6340-44ad-11ec-354d-0d948b9c4651
# ╠═486f1dd0-44af-11ec-0f64-7bc41804823e
# ╟─abc0fd40-44af-11ec-21ac-6bdf812e5db9
# ╠═5f032550-44af-11ec-0d8d-01bbef3ab950
# ╟─00f0dcf0-44b4-11ec-2520-533167a449d3
# ╠═111fedf0-44b4-11ec-3fcb-6b2ce0fea7d5
# ╠═b0b16d70-44b5-11ec-337a-0b005cdf12a4
# ╟─380e0e0e-44b4-11ec-32bc-b9a46905cf95
# ╠═72285290-44b4-11ec-06d0-b9dcebeb8037
# ╟─298d9010-44b7-11ec-0cc9-ede5e90d90e3
# ╟─4a8f5a32-44b9-11ec-180b-b5dffcc22f53
# ╠═a9a3de10-44b9-11ec-16bb-c70bb8ad1011
# ╟─1075bc80-44ba-11ec-2dc9-79d7660f262f
# ╟─5d242b22-44ba-11ec-0d2b-b747b20bfeb5
# ╠═735b1e80-44ba-11ec-27d7-bdfb8379a32f
# ╠═7aa2379e-44ba-11ec-30d1-193449f91f68
# ╠═80017dee-44ba-11ec-0d19-578adccfc0bd
# ╟─d29022b0-44ba-11ec-3a57-792de71d6cdf
# ╠═d39d93b0-44bd-11ec-3a47-57eb594ddbda
# ╟─e4fdaaa0-44bd-11ec-121a-29b72bf1026c
# ╠═3bd1eea0-458a-11ec-0afe-77aa368c3df6
# ╠═957ad020-458a-11ec-3ffe-efac99d8147f
# ╠═9e8432b0-458a-11ec-1ad0-4329e18043f6
# ╠═ab993270-458a-11ec-1de8-af59100c599d
# ╟─df2cc79e-458a-11ec-0102-f3ab4f1742eb
