### A Pluto.jl notebook ###
# v0.19.38

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 0fa5aa82-33f0-4ea1-a82f-235fe66ad23f
import Pkg; Pkg.add("PlutoUI")

# ╔═╡ 2d9c87cd-6beb-4e4c-a5a9-c1b060a2cae4
Pkg.add("RecipesBase")

# ╔═╡ 53f5b032-8ee8-4745-9c50-6cee98545c49
using Distributions

# ╔═╡ 4e827046-8787-11ed-1763-99b10d56f7a6
using PlutoUI, Random; TableOfContents()

# ╔═╡ 59c37c98-9a9a-4bbc-9809-26360ead8e45
using Plots, RecipesBase

# ╔═╡ 347583c6-9ed6-42af-b760-733585dbb7a6
# edit the code below to set your name and UGent username

student = (name = "Arthur Thuy", email = "Arthur.Thuy@UGent.be");

# press the ▶ button in the bottom right of this cell to run your edits
# or use Shift+Enter

# you might need to wait until all other cells in this notebook have completed running. 
# scroll down the page to see what's up

# ╔═╡ efb5380d-ab9d-4e7e-ad2b-d7beb3e28609
@bind shape_type Select(["circles", "rectangles", "triangles"])

# ╔═╡ 2ff01603-4322-4571-b172-20b9952ff4ff
if shape_type == "circles"
	md"Circles are given as a tuple of type `(x, y, R)` with (`x`, `y`) its centre and `R` the radius."
elseif shape_type == "rectangles"
	md"Rectangles are represented as (x, y, w, h) with (`x`, `y`) its centre and (`w`, `h`) the width and height."
elseif shape_type == "triangles"
	md"Triangles are represented as `(x1, y1, x2, y2, x3 y3)`, the three coordinates of the corners."
end

# ╔═╡ 7470865e-87e2-4e40-8cb5-e27b516ce976
md"> **Note:** This exercise is free-form for you to practice your Julia skills. Making a dedicated type with constructor might make things easier, but is not required."

# ╔═╡ 9731ecc2-a3bf-47bc-8385-96147b0ddbd0
md"""
## Assignments ✏️

It took some iterations, but Daisy has provided you with a detailed sowing plan, 

*$(shape_type)*:
"""

# ╔═╡ 4826f7b8-0922-4a2d-abd4-426aa43c293a
md"""
The problem is that daisy does not know how many seeds to buy. However, she is an experienced gardener and only needs to know an estimation of the surface area that needs sowing.

### 1. Area
> Make a function `area` to compute the area of your shape. Find the sum of all your shapes.
> 
> **Extra:** can you directly use `sort!` to sort your shapes by area?

"""

# ╔═╡ 409d0d25-bae3-45ed-9ba1-477fcf928bce
function area(shape)
	return π*shape.R^2
end

# ╔═╡ 3bdf0670-2511-4fd6-be39-8d22c2945d4c
md"""
### 2. Overlap

Crisis! Daisy realises that the shapes she has drawn are overlapping and the previous estimation of the number of seeds is too high. Can you quickly assess the severity of this overestimation by counting the number of overlapping patches?

> Some of the fields might overlap. Can you extend the function `isdisjoint` to check if two of your shapes *don't* overlap? How many of the shapes don't overlap?
> 
> **Optional:** count the number of shapes that lie *completely* in another shape.
"""

# ╔═╡ 5949a413-705d-477b-8091-d517f09095de
function Base.isdisjoint(shape1::NamedTuple, shape2::NamedTuple)
    eucl_distance = sqrt((shape1.x - shape2.x)^2 + (shape1.y - shape2.y)^2)
	return eucl_distance > (shape1.R + shape2.R)
end

# ╔═╡ 2ecb502b-a587-4ecf-9ff6-960811afb7b8
100*99/2

# ╔═╡ 38d8e6af-092b-4d49-859c-7ad21480c4ed


# ╔═╡ d0493b54-1441-4ab5-8642-66623a9406b4


# ╔═╡ faf30153-b607-48d1-8db0-1f47e2e1e62e
md"""
### 4. Total area within bound

> As you have seen in the previous question, some fields overlap. Likewise, part of the shapes might be out bounds of the $[0,100]\times [0,100]$ larger field. Can you compute or estimate the total available area where you don't count overlapping parts multiple times?
> 
> Computing this exactly might be a bit tricky. So Daisy proposes an alternative solution to estimate the area. She suggests randomly throwing a large number (say, 100,000) of seeds in the big field and counting which fraction land in one of the shapes. This fraction is proportional to the part of the land covered by a field.
> 
> To this end, extend the function `in` such that you can check whether a point lies in one of the shapes, i.e. `(x, y) in shape`. You can use the function `count` to estimate the surface.
"""

# ╔═╡ bc31c109-3a11-46b1-bc5a-5872d0cb73bd
n_points = 100_000

# ╔═╡ e1a4741f-415d-4a61-8ff5-a8454607d437
function Base.in(point::NamedTuple, shape::NamedTuple)
# function Base.in(point::Tuple{Float64, Float64}, shape::NamedTuple)
	distance = sqrt((point.x - shape.x)^2 + (point.y - shape.y)^2)
	# println(distance)
	return distance < shape.R
end

# ╔═╡ 8f7fb0c4-ba18-4025-b322-62c2d17aced8
(x=-4., y=3.) in (x=-2, y=1, R=3)

# ╔═╡ a70e9d92-c098-49e1-bb8f-4adfc55a6c98
points = [(x=x, y=y) for (x,y) in zip(rand(Uniform(0, 100), n_points),rand(Uniform(0, 100), n_points))]

# ╔═╡ 95fecfbd-6969-498b-b909-ac945a4e9fbd
# count.(in, points, shapes)

# ╔═╡ 2a772d03-5972-4da5-8da8-adf7626db801
md"## Data generation ⚙️"

# ╔═╡ 57f8656f-7c84-47cc-9da1-62c3e74c7769
begin
	Random.seed!(12)

	n = 100
	Rmax = 10

	circles = [(x=100rand(), y=100rand(), R=Rmax * rand()) for _ in 1:n]
	rectangles = [(x=100rand(), y=100rand(), w=5rand()+5, h=5rand()+5) for _ in 1:n]
	triangles = [100rand(2) |> ((x, y),)->(x1=x+4randn(), y1=y+4randn(), x2=x+4randn(), y2=y+4randn(), x3=x+4randn(), y3=y+4randn()) for _ in 1:n]
end;

# ╔═╡ b7e28115-8901-4972-b37f-9b5869735b50
begin
	hint(text) = Markdown.MD(Markdown.Admonition("hint", "Hint", [text]));
	
	md"""
	# Project 2: Fluky fields 🌱
	
	As a new year's resolution, Daisy would like to [soften her driveway](https://omgeving.vlaanderen.be/nl/vlaanderen-breekt-uit-homepagina) and grow a fantastical front garden. As a founding member of the [anti-lawn movement](https://www.homesandgardens.com/gardens/what-is-the-anti-lawn-movement), Daisy is not a fan of perfectly mown lawns and wants to try something new, *fluky fields*! The idea is so simple yet genius, generate some random geometric shapes and sow accordingly. 
	
	![Dall-E's interpretation of the fluky fields](https://i.imgur.com/IHtBv9e.png)
	
	In this synthesis exercise, you will help Daisy manage her fields. The $n fields are of peculiar shapes: they are all in the shape of $(shape_type)! These little fields are part of a big piece of land that extends from 0 to 100 in both the x- and y-direction.
	
	> **Note:** you can choose the flavour of this exercise by picking the shapes of the fields, `circles` and `rectangles` are pretty easy, while `triangles` will put your geometry skills to the test!
	"""
end

# ╔═╡ 8b19a9e4-5701-4e45-85a6-8e9d3b93563f
md"""
### 3. Plotting

A little over-preparation never hurt anyone. Before committing to this crazy plan, it would be wise to check how the front garden will look in the blooming season.

> Make a plot of your shapes. 

$(hint(md"In the `plots` function set `aspect_ratio=:equal` to equalize the x- and y-ax."))

$(hint(md"If you have defined a type, you make a [plotting recipe](https://docs.juliaplots.org/latest/recipes/)."))
"""

# ╔═╡ d5c9526d-5dff-4fb2-8a2c-e96c0229f474
shapes = shape_type=="circles" ? circles : (shape_type=="rectangles" ? rectangles : triangles);

# ╔═╡ 9c443e96-d40c-4c9d-a0b3-3390e18911df
shapes

# ╔═╡ de71232a-1498-4db1-8fc3-65a84a93551a
first(shapes)

# ╔═╡ 59949c0b-4a6e-4237-9b1d-5a674f4849bd
sum(area.(shapes))

# ╔═╡ 4a507508-0532-4659-94b4-7a04bdd91fe0
isdisjoint(shapes[1], shapes[2])

# ╔═╡ f4405c56-3651-4e72-8e39-18d441296167
isdisjoint(shapes[1], shapes[1])

# ╔═╡ 7266eed1-97a3-46f6-895e-6846f40a0d77
size(shapes)

# ╔═╡ efd7d317-7e25-4780-8034-fa4f2f5835d1
begin
	num_disjoints = 0
	for (i, shape1) in enumerate(shapes)
		overlaps = false
		for (j, shape2) in enumerate(shapes)
			if i == j || j>i
				continue
			end
			if !isdisjoint(shape1, shape2)
				overlaps = true
				break
			end
		end
		if !overlaps
			num_disjoints += 1
		end
	end
	println(num_disjoints)
end

# ╔═╡ a9fb9f67-f002-45ed-b178-fd636b1d9e52
begin
	xs = [shape.x for shape in shapes]
	ys = [shape.y for shape in shapes]
	# areas = [area(shape) for shape in shapes]
	areas = [shape.R for shape in shapes]
	scatter(xs, ys,markersize=areas,legend=false)
end

# ╔═╡ f1bd6583-5a58-434b-aaab-936235eb7e84
begin
	in_bounds = 0
	for point in points
		in_bounds += any(point in shape for shape in shapes)
	end
	print(100 ^2 * in_bounds/n_points)
end

# ╔═╡ 73503bf0-5dc8-4cc5-a636-e6521ef3089e
md"""
## Hints 🧰

These are some functions you might find interesting in your project.
"""

# ╔═╡ 93becd08-699a-471e-a92c-dc134229a0ec
sum(sqrt, [0, 1, 3, 4])

# ╔═╡ 925689a1-1023-48c5-af07-e29b8ecb7b16
sort!([-5, -3, 1, 3, 4], by=abs)

# ╔═╡ f320a277-0b23-4a63-834d-a1f8815610fb
count(>(2), [-1, 1, 3, 8, 9])

# ╔═╡ cef973dd-b6c5-4fe2-932d-eb4f34bb7b7d
filter(x->2≤x<4, [1.2, 3.1, 2.2, 0.7, 4.0, 6.7])

# ╔═╡ d31bf4c8-0e4e-428e-8909-8cd966f1e596
any(isodd, [2, 4, 6, 7])

# ╔═╡ a1cfa733-c30a-4fa6-991c-01cfdae2bd14
all(iseven, [2, 4, 6, 7])

# ╔═╡ Cell order:
# ╠═0fa5aa82-33f0-4ea1-a82f-235fe66ad23f
# ╠═2d9c87cd-6beb-4e4c-a5a9-c1b060a2cae4
# ╠═53f5b032-8ee8-4745-9c50-6cee98545c49
# ╟─4e827046-8787-11ed-1763-99b10d56f7a6
# ╠═347583c6-9ed6-42af-b760-733585dbb7a6
# ╟─b7e28115-8901-4972-b37f-9b5869735b50
# ╠═efb5380d-ab9d-4e7e-ad2b-d7beb3e28609
# ╟─2ff01603-4322-4571-b172-20b9952ff4ff
# ╟─7470865e-87e2-4e40-8cb5-e27b516ce976
# ╟─9731ecc2-a3bf-47bc-8385-96147b0ddbd0
# ╠═9c443e96-d40c-4c9d-a0b3-3390e18911df
# ╠═de71232a-1498-4db1-8fc3-65a84a93551a
# ╟─4826f7b8-0922-4a2d-abd4-426aa43c293a
# ╠═409d0d25-bae3-45ed-9ba1-477fcf928bce
# ╠═59949c0b-4a6e-4237-9b1d-5a674f4849bd
# ╟─3bdf0670-2511-4fd6-be39-8d22c2945d4c
# ╠═5949a413-705d-477b-8091-d517f09095de
# ╠═2ecb502b-a587-4ecf-9ff6-960811afb7b8
# ╠═4a507508-0532-4659-94b4-7a04bdd91fe0
# ╠═f4405c56-3651-4e72-8e39-18d441296167
# ╠═7266eed1-97a3-46f6-895e-6846f40a0d77
# ╠═efd7d317-7e25-4780-8034-fa4f2f5835d1
# ╠═38d8e6af-092b-4d49-859c-7ad21480c4ed
# ╟─8b19a9e4-5701-4e45-85a6-8e9d3b93563f
# ╠═59c37c98-9a9a-4bbc-9809-26360ead8e45
# ╠═a9fb9f67-f002-45ed-b178-fd636b1d9e52
# ╠═d0493b54-1441-4ab5-8642-66623a9406b4
# ╟─faf30153-b607-48d1-8db0-1f47e2e1e62e
# ╠═bc31c109-3a11-46b1-bc5a-5872d0cb73bd
# ╠═e1a4741f-415d-4a61-8ff5-a8454607d437
# ╠═8f7fb0c4-ba18-4025-b322-62c2d17aced8
# ╠═a70e9d92-c098-49e1-bb8f-4adfc55a6c98
# ╠═95fecfbd-6969-498b-b909-ac945a4e9fbd
# ╠═f1bd6583-5a58-434b-aaab-936235eb7e84
# ╟─2a772d03-5972-4da5-8da8-adf7626db801
# ╠═57f8656f-7c84-47cc-9da1-62c3e74c7769
# ╠═d5c9526d-5dff-4fb2-8a2c-e96c0229f474
# ╟─73503bf0-5dc8-4cc5-a636-e6521ef3089e
# ╠═93becd08-699a-471e-a92c-dc134229a0ec
# ╠═925689a1-1023-48c5-af07-e29b8ecb7b16
# ╠═f320a277-0b23-4a63-834d-a1f8815610fb
# ╠═cef973dd-b6c5-4fe2-932d-eb4f34bb7b7d
# ╠═d31bf4c8-0e4e-428e-8909-8cd966f1e596
# ╠═a1cfa733-c30a-4fa6-991c-01cfdae2bd14
