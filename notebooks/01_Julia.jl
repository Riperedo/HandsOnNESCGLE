### A Pluto.jl notebook ###
# v0.12.10

using Markdown
using InteractiveUtils

# ╔═╡ b5ee0eb0-4343-11ec-3ac6-f7fcac21d8d3
md"# 0.1 Julia para principiantes
En esta breve libreta trataremos de decribir el funcionamiento básico del lenuaje de programación *Julia*.
## ¿Un lenguaje de programación más?
Julia es un lenguaje de programación dinámico de alto nivel, creado por investigadores informáticos del Massachusetts Institute of Technology (MIT), y distribuido bajo la licencia del MIT para software libre. Julia se usa para cálculos en múltiples ámbitos como la física, biología, ingeniería, matemáticas y finanzas, entre otros [[1](https://hedero.webs.upv.es/julia-basico/)].

Julia es [[2](https://github.com/dpsanders/hands_on_julia)]:
* Código abierto,
* gratis,
* MIT licence \(admite uso comercial\),[[3](https://es.wikipedia.org/wiki/Licencia_MIT)]
* un lenguaje de alto nivel fácil de aprender,
* un lenguaje dinámico [[4](https://en.wikipedia.org/wiki/Dynamic_programming_language)],
* hecho con [JIT](https://en.wikipedia.org/wiki/Just-in-time_compilation) \(Just-In-Time\)
*Para mayor información acerca de este lenguaje de programación visite [Julia.org](https://julialang.org/)*
"

# ╔═╡ 9a1e66c0-4349-11ec-1821-870fecf939e9
md"## Manos a la obra
Estamos interesados en desarrollar cómputo científico, por lo que es necesario hacer un repaso de las diferentes operaciones numéricas que necesitamos para este curso.
### Operaciones numéricas
Empecemos con las operaciones algebráicas elementales y juguemos con algunas variables numéricas.

Para un conjunto de variables
"

# ╔═╡ d6e5b7f0-434b-11ec-041d-f5833e21401c
a = 1

# ╔═╡ 174e60e0-4350-11ec-097c-a3b5b6842a78
b = 2

# ╔═╡ 1b45b2be-4350-11ec-388e-6584c961a80c
c = 3.0

# ╔═╡ 94cb1d60-4404-11ec-3789-0dd7870236a6
md"Modifica los valores de a = $a, b = $b, y c = $c y observa lo que pasa con el resultado siguiente. De mismo modo juega con este conjunto de variables en la siguiente celda, prueba con ```a*b^c```, ```a/b-c``` o ```a%b - c```."

# ╔═╡ 1fe133e0-4350-11ec-1078-471f0a799f60
a+b+c

# ╔═╡ 8286e800-4404-11ec-1a5f-6d756e5df2aa
md"Algunas funciones de utilidad son aquellas que nos permiten llamar arreglos de números. La forma más simple de hacer esto es"

# ╔═╡ 63ca99b0-4405-11ec-13b3-2d4da6944fd1
alpha = [a, b, c]

# ╔═╡ 7a5a0d50-4405-11ec-3df5-1d1be7a2402a
md"Otro método es con la función ```collect```"

# ╔═╡ cbf0b620-4408-11ec-0d80-0b6c236ba1e0
α = collect(a:b)

# ╔═╡ f3b252e0-4408-11ec-39f3-65b367bcb7ae
β = collect(a:(b-a)/10:b)

# ╔═╡ 1edb5d90-4409-11ec-27bb-7f773f2d3ca6
md"Julia puede manejar caracteres especiales dentro de sus variables, como es el caso  de los símbolos α o β. Para acceder a ellos simplemente escribe ```\alpha<Tab>``` o ```\beta<Tab>``` y _voilà_. Otro par de funciones útiles serán ```zeros``` o ```ones```."

# ╔═╡ f71fe5e0-4409-11ec-16ea-d5184a89c033
γ₀ = zeros(Int(c))

# ╔═╡ 0b17beb2-440a-11ec-25ba-9fedfa8ea677
γ₁ = ones(Int(c))

# ╔═╡ 86eb1dc0-440a-11ec-3bc2-4d4b8a58aceb
md"Dentro de la sintaxis de Julia podemos añadir subíndices y superíndices simplemente escribiendo ```x\_0<Tab>``` o ```x\^0<Tab>```. Julia reconoce a ```x_0``` y a ```x₀``` como variables diferentes. Para los más perspicaces, podemos haces _casting_ de variables a enteros utilizando la función ```Int``` o a flotantes con ```Float64```."

# ╔═╡ 08269cc0-440b-11ec-1421-efd5bfdc349e
Float64(Int(a))

# ╔═╡ 9630f550-440c-11ec-04e9-854f7bf8ae77
md"Para acceder a cualquier elemento de estos arreglos utilizamos paréntesis cuadrados `[ ]`. Julia tiene la peculiaridad de que inicia la indexación de sus arreglos con el índice `1` a diferencia de muchos de los lenguajes de programación."

# ╔═╡ e229f6a0-440c-11ec-0366-2dc1b32a3df9
alpha[1]

# ╔═╡ ebb8b5d0-440c-11ec-0307-613c02aabef8
alpha[length(alpha)]

# ╔═╡ 0e0c6640-440d-11ec-288c-93a561b9d9cd
alpha[end]

# ╔═╡ 6d919ea0-434f-11ec-222a-2f639d3e13fe
md"### Funciones

Existen un par de opciones para definir funciones, la primera de ellas es _inline_ y la sintaxis es la siguiente"

# ╔═╡ d8d57d30-434f-11ec-3c91-4b8fbf1a3ef3
"""
`f(x)`

#Argumentos
- `x::Any`: único argumento
Eleva al cuadrado el valor de x
"""
f(x) = x^2

# ╔═╡ 61021c20-440b-11ec-3328-8331cc87a2b3
md"La sección entre comillas ```\"\"\"...\"\"\"``` es opcional pero siempre es una buena práctica documentar tu código. Agregar una breve desdripción de qué hace cada función nunca hace daño y ayuda a que tus compañeros de trabajo entiendan más rápido tu código. Además de que es una buena práctica. Dentro del entorno _Pluto.jl_ las descripciones se pueden ver en tiempo real mientras trabajas, para esto abre la pestaña **📚 Live docs** que se encuentra en la esquina inferior derecha. Puedes ajustar el tamaño del texto con las teclas ```Ctrl + Scroll``` y regresar a la configración por defecto presionando las teclas ```Ctrl + 0```.

Para tener acceso de forma manual a esa información simple mente añadimo el macro ```@doc``` antes de la función."

# ╔═╡ 28440b52-4352-11ec-1e90-2773edd1ec18
@doc f

# ╔═╡ 5f676272-440c-11ec-1fdf-abff0051d136
md"Llamamos a la función como en cualquier lenguaje de programación, simplemente utilizamos paréntesis redondos `()` inmediatamente después de la función"

# ╔═╡ 07ee5940-440c-11ec-2f6f-291d6dd3ca75
f(a)

# ╔═╡ 481daa10-440d-11ec-280c-838d9c2d88bf
md"Otra forma de definir una función es"

# ╔═╡ e2e50520-434f-11ec-0797-f3fbddbbcb94
"""
`suma(a, b)`

Realiza la suma de a más b
# Argumentos
- `a::Any`: primer término.
- `b::Any`: segundo término.
"""
function suma(a, b)
	# algún procedimiento sofisticado
	return a+b
end

# ╔═╡ 05d8ed30-4350-11ec-205e-05d140f94f17
suma(a, b)

# ╔═╡ f7b59962-440d-11ec-1ce5-9d956f12adf3
md"El símbolo `#` sirve para incluir comentarios dentro del código.

Para trabajar con arreglos como los definidos previamente utilizamos técnicas de [_broadcasting_](https://julia.guide/broadcasting), su implementación es relativamente sencilla
"

# ╔═╡ fd137c00-4350-11ec-3741-d3e2aa628ab3
beta  = f.(alpha)

# ╔═╡ ae30fe00-440e-11ec-1a2c-efa9de867e5f
suma.(alpha, beta)

# ╔═╡ 0a85c5a0-440f-11ec-0630-f9031fd79d61
alpha .+ beta

# ╔═╡ ad3e9240-440f-11ec-1a79-bf756173c36e
md"Estas son lagunas características básicas pero suficientes para el resto de este taller."

# ╔═╡ Cell order:
# ╟─b5ee0eb0-4343-11ec-3ac6-f7fcac21d8d3
# ╟─9a1e66c0-4349-11ec-1821-870fecf939e9
# ╠═d6e5b7f0-434b-11ec-041d-f5833e21401c
# ╠═174e60e0-4350-11ec-097c-a3b5b6842a78
# ╠═1b45b2be-4350-11ec-388e-6584c961a80c
# ╟─94cb1d60-4404-11ec-3789-0dd7870236a6
# ╠═1fe133e0-4350-11ec-1078-471f0a799f60
# ╟─8286e800-4404-11ec-1a5f-6d756e5df2aa
# ╠═63ca99b0-4405-11ec-13b3-2d4da6944fd1
# ╟─7a5a0d50-4405-11ec-3df5-1d1be7a2402a
# ╠═cbf0b620-4408-11ec-0d80-0b6c236ba1e0
# ╠═f3b252e0-4408-11ec-39f3-65b367bcb7ae
# ╟─1edb5d90-4409-11ec-27bb-7f773f2d3ca6
# ╠═f71fe5e0-4409-11ec-16ea-d5184a89c033
# ╠═0b17beb2-440a-11ec-25ba-9fedfa8ea677
# ╟─86eb1dc0-440a-11ec-3bc2-4d4b8a58aceb
# ╠═08269cc0-440b-11ec-1421-efd5bfdc349e
# ╟─9630f550-440c-11ec-04e9-854f7bf8ae77
# ╠═e229f6a0-440c-11ec-0366-2dc1b32a3df9
# ╠═ebb8b5d0-440c-11ec-0307-613c02aabef8
# ╠═0e0c6640-440d-11ec-288c-93a561b9d9cd
# ╟─6d919ea0-434f-11ec-222a-2f639d3e13fe
# ╠═d8d57d30-434f-11ec-3c91-4b8fbf1a3ef3
# ╟─61021c20-440b-11ec-3328-8331cc87a2b3
# ╠═28440b52-4352-11ec-1e90-2773edd1ec18
# ╟─5f676272-440c-11ec-1fdf-abff0051d136
# ╠═07ee5940-440c-11ec-2f6f-291d6dd3ca75
# ╟─481daa10-440d-11ec-280c-838d9c2d88bf
# ╠═e2e50520-434f-11ec-0797-f3fbddbbcb94
# ╠═05d8ed30-4350-11ec-205e-05d140f94f17
# ╟─f7b59962-440d-11ec-1ce5-9d956f12adf3
# ╠═fd137c00-4350-11ec-3741-d3e2aa628ab3
# ╠═ae30fe00-440e-11ec-1a2c-efa9de867e5f
# ╠═0a85c5a0-440f-11ec-0630-f9031fd79d61
# ╟─ad3e9240-440f-11ec-1a79-bf756173c36e
