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

# ╔═╡ 5899b739-14c5-4627-8be2-d1d94bc23add
import Pkg; Pkg.add("PlutoUI")

# ╔═╡ 79271c7b-a15c-4e12-ae89-d107604c218d
using PlutoUI; TableOfContents()

# ╔═╡ e9576706-600e-11eb-1e10-e3bac02a254e
# edit the code below to set your name and UGent username

student = (name = "Arthur Thuy", email = "Arthur.Thuy@UGent.be");

# press the ▶ button in the bottom right of this cell to run your edits
# or use Shift+Enter

# you might need to wait until all other cells in this notebook have completed running. 
# scroll down the page to see what's up

# ╔═╡ 4ec271b0-4e73-11eb-2660-6b8bd637d7ee
md"""
# Abstract and primitive types

All Julia objects, both those already defined as well as those you might invent yourself, have a type. The type system is the secret *sauce*, allowing Julia to be fast because code can be specialised for a particular combination of types. It is also supremely useful in conjunction with *multiple dispatch*, in which functions work differently depending on which types you feed into them. This notebook will show the basics of the type system. We will only consider abstract and primitive types here, leaving composite types for the next notebook. Don't worry if you do not yet understand what this means, you will discover it soon enough.
"""

# ╔═╡ a1f2d06e-4e73-11eb-3afd-1353def71700
md"""
## Checking the type

The type of objects can be assessed using the function `typeof`. For collections, `eltype` gives the types of individual elements. Try the following examples. Note that types are always capitalised!
"""

# ╔═╡ c0bfdf9e-4e73-11eb-3962-0b3c5d5424d7
a = 42; s = "mice"; n = 0.9; A = [1 2; 3 4];

# ╔═╡ bd994d64-600e-11eb-1ab3-ed6317b7c211
md"""
> **Task: Check the types of the following expressions**"

```julia
typeof(a)

typeof(s)

typeof(n)

typeof(A)

```
"""

# ╔═╡ b844d568-4e73-11eb-3de9-4158b0bdca12
typeof(a)

# ╔═╡ c662744a-4e73-11eb-1bfc-6daaf7282285
typeof(s)

# ╔═╡ cae803e2-4e73-11eb-13e0-23abccf86bac
typeof(n)

# ╔═╡ cc606026-4e73-11eb-3576-5d301a771a5a
typeof(A)

# ╔═╡ d3803112-4e73-11eb-2018-f72ffb7f6ec6
md"These are all *concrete types*. Julia types are part of a hierarchical type system, forming a single, fully connected type graph. The concrete types are the leaves of this tree, whereas the inner nodes are *abstract types*. As hinted by the name, these are abstract and cannot be instantiated. They, however, help with conceptually ordering the type system."

# ╔═╡ e8fe2832-4e78-11eb-3fd6-a3f1f0c0892a
md"What is the type of `pi`?"

# ╔═╡ f533012c-4e78-11eb-0f45-3b47f088c9c6
typeofpi = typeof(π)

# ╔═╡ f69d89ba-4e73-11eb-3ab9-9179ea7e3217
md"Concrete types (should) have a well-defined memory layout, for example `Float64` is  encoded using 64 bits while `Float32` is encoded using 32 bits and hence some computations can be executed quicker but less precise by the former. Abstract types on the other hand mainly encode a semantic meaning, any `Real` should behave as a real number (e.g., addition, division are defined)."

# ╔═╡ de3de7fc-4e73-11eb-2ff6-1560481f7ee5
md"We can find the supertype (ancestor) of a concrete or abstract type using the function `supertype`."

# ╔═╡ 0598b350-b906-4792-a42f-54ba3eed9577
md"""
> **Task: Check the supertype of the following concrete and abstract types**

```julia
supertype(Int8)

supertype(Float64)

supertype(AbstractFloat)

supertype(Real)

supertype(Number)

supertype(Any)
```
"""

# ╔═╡ e1c8cf4a-4e73-11eb-27be-d702064a0182
supertype(Int8)

# ╔═╡ e56a46c6-4e73-11eb-1748-1b6fe5ab0376
supertype(Float64)

# ╔═╡ e89adcaa-4e73-11eb-1ed8-e9c89ca633f6
supertype(AbstractFloat)

# ╔═╡ ec2ab2be-4e73-11eb-1a22-010439761432
supertype(Real)

# ╔═╡ efa205b4-4e73-11eb-1647-e9dcab5f7b7a
supertype(Number)

# ╔═╡ f3b5a778-4e73-11eb-1d3c-11ae19713eca
supertype(Any)

# ╔═╡ a0cecb24-4e74-11eb-3634-cd8dd628e9ec
md"See how all the numbers are hierarchically represented? Note that any type is always a subtype of `Any`. We can check if an object is (sub)type using the function `isa` or use the `<:` operator."

# ╔═╡ c232463e-233b-449a-befd-306c7d7100d5
md"""
> **Task: Predict the outcome of the following statements**

```julia
Float64 <: AbstractFloat

Float16 <: AbstractFloat

AbstractFloat <: Number

Int <: Number

Int <: AbstractFloat

Integer isa Int

```

If you are confused by the last statement, read the next section.
"""

# ╔═╡ b31fe65a-4e74-11eb-0414-35f2be687c7f
Float64 <: AbstractFloat

# ╔═╡ c2ac0c48-4e74-11eb-10b0-91ad620fefcd
Float16 <: AbstractFloat

# ╔═╡ c5208cce-4e74-11eb-0615-135b510a9e8d
AbstractFloat <: Number

# ╔═╡ c817296a-4e74-11eb-0994-972871114f02
Int <: Number

# ╔═╡ cb066442-4e74-11eb-35e7-ed38d4bd8bbf
Int <: AbstractFloat

# ╔═╡ ce3d5380-4e74-11eb-3d9d-5f34cbbae118
Integer isa Int
# Int isa Integer # ???

# ╔═╡ 9982a6ba-1804-4cb6-9b89-82de11c85595


# ╔═╡ 66343826-6012-11eb-109c-17c7a582cbc8


# ╔═╡ 34ca6158-4e75-11eb-3d51-330952c9b3dd
md"We can check the entire subtree of a type using the function `subtypetree`"

# ╔═╡ 3d1db2de-6549-11eb-2649-2d96659813f6
md"It does not need to be complicated, though."

# ╔═╡ 46eaafee-6549-11eb-2e36-c9e566d3f3ba
function subtypetreesimple(roottype, level=1)
	level == 1 && println(roottype)
	for s in subtypes(roottype)
			println(" "^((level-1)*4) * string(s))
			subtypetreesimple(s, level + 1)
	end
end

# ╔═╡ 6cbd4874-6549-11eb-296e-af4a43d53223
subtypetreesimple(Real)

# ╔═╡ 4a01487c-4e78-11eb-1302-d9c6ec4ed6ab
md"""

## Converting types

Changing a variable `x` into a different type `T` can be done using the function `convert(T, x)`.
"""

# ╔═╡ 66292626-4e78-11eb-331b-0563b2110605
convert(Float64, 42)

# ╔═╡ 704b2ebe-4e78-11eb-1583-d10e0aeb2b8d
Float64(42)  # for most types this works as well

# ╔═╡ c3c40df2-4e78-11eb-3d4a-5fdfdf173da3
Int8(42)

# ╔═╡ cd32e96c-4e78-11eb-0b48-5767421c7875
Float32(π)

# ╔═╡ 40a761c2-5b24-11eb-09a8-a5cd0bc4ab95
md"We have seen that you can add any type of float with any type of integer (ditto for vectors and arrays with different types but how does this work? Julia uses *promotion* to cast two inputs in the more general type. For example, compare adding a `Float64` with an `Int`."

# ╔═╡ 99228eee-5b24-11eb-385e-7507ca20ae0e
promote(7.9, 79)

# ╔═╡ 03133d24-6621-11eb-03d3-bb8970ab19f7
promote_type(Float64, Int)  # find common type, order does not matter

# ╔═╡ ba39991a-5b24-11eb-260b-439bcde4c153
md"You see that `Float64` is the more general type, so both inputs are cast as floats and further processed by the function. That is why the their sum is a float: `7.9 + 79 = 86.9`. 

Of course, this also works with more complex composite types, such as matrices:
"

# ╔═╡ 35e53434-5b25-11eb-10b7-e993e9477c8c
[1 2; 3 4] + [0.0 1.0; 2.0 3.0]

# ╔═╡ 92dc7a4e-5b25-11eb-1518-8182216f24ec
[0, 1.0, 2, 3]  # cast into a vector of floats

# ╔═╡ aa26b46c-4e78-11eb-24d8-7fdce7c94fff
md"""
When designing new types, one also often has to implement custom `convert` methods since it is not always clear how to convert different types.

When reading files, it is often useful to interpret parts of the strings as different datatypes such as numbers. This can be done using the function `parse` that works similarly to `convert`.
"""

# ╔═╡ 815b0436-4e78-11eb-13d4-0dc6531e34f2
parse(Int, "42")

# ╔═╡ 570c85bc-4e79-11eb-0249-891cf205d623
parse(Float64, "0.999")

# ╔═╡ b3da4c4b-3603-489a-b1ad-3c4a17ef9a98
md"""
**Question: string parsing**

Below are a bunch of numbers in a text string. Can you compute their sum `(Float64)`?

Hints:
- `rstrip` is a handy function.
- `split` is a handy function.
- Maybe we can use a pipe `|>`?
"""

# ╔═╡ 6756d6ac-4e79-11eb-21ab-4776195c9d3b
bunchofnumbers = "1.728002758512114, 0.45540258865644284, 1.4067738604851092, 1.6549474922755167, -0.5281073122489854, 2.219250973007533, 0.8195027302254512, 1.8833469318073521, 0.7429034224663096, -0.8127686064960085, -0.14337850083375886, -1.477193046160141, 0.024525761924498457, 0.16097115910472956, -0.39278880092280993, 1.3988081686729814, -1.3316370350161346, 0.2791510437718087, 1.9834455917052212, -0.8616791621501649
"

# ╔═╡ e6f31ad8-4e79-11eb-11f4-2936cb039f8d
sumofbunchofnumbers = split(bunchofnumbers, ", ") |> x -> strip.(x, ['\n']) |> x -> parse.(Float64, x)

# ╔═╡ 03766a5c-4e75-11eb-12ad-cb2e9468e0d2
md"""
## Methods and dispatch

When a function is run for the first time with a particular combination of input types, it gets compiled by the LLVM compiler. Such a specific function is referred to as a `method`. Every time a function is run with a new combination of types of arguments, a suitable method is compiled. This is noticeable when measuring the running time.
"""

# ╔═╡ 63166056-6014-11eb-09c4-e5a44d37095f
md"""
		Run the following examples in the terminal using `@time`.
		
		```julia
		@time mynewfun(1)  # returns an integer

		@time mynewfun(1.0)  # returns a Float64

		@time mynewfun(A)

		```
		"""

# ╔═╡ 2dff8c88-4e75-11eb-050b-7152e82ac10d
mynewfun(x) = x^2 .+ x

# ╔═╡ 7c2b6dc0-4e76-11eb-1d78-553df82d9100
@time mynewfun(1)

# ╔═╡ d2a4a32c-5b02-11eb-3839-8108c4965931
@time mynewfun(1.0)

# ╔═╡ 32d64b6e-4e75-11eb-0a2a-27214f217f70
@time mynewfun(A)

# ╔═╡ 861ba4c6-4e76-11eb-3d2b-bfabbd143df2
md"The known methods can be found using the function `methods`. For example, look how many methods are defined for sum:"

# ╔═╡ 8d5f7d8e-4e76-11eb-28ba-bdec03a3e150
methods(sum)

# ╔═╡ b4fac50a-6015-11eb-16d4-594858d78b3e


# ╔═╡ 9ed7cb5a-6014-11eb-0ae8-eba8d77867a2
md"""
		
		check how many methods there are associated with the humble multiplication operator `*`. Just for your info, you might want to print this one to the terminal.
		"""

# ╔═╡ b18d0532-4e76-11eb-2e8a-2bee580533cc


# ╔═╡ b3d15950-6015-11eb-1909-c127822a4a83


# ╔═╡ cd2eaafc-4e76-11eb-245a-e9898d3d57a4
md"The arguments a function can take can be restricted using the `::`-operator. Here, if we limit a function as `f(x::T)`, this means that `x` can be any type `<: T`. "

# ╔═╡ 002fdec6-6015-11eb-0e89-c7d020826cf9
md"""
		
		Can you explain the reasoning behind the following code? How does it process numbers? What does it do with strings?"
			
		```julia
		methods(twice)
		twice(10) # Int	
		twice(10.0)  # Float64, also a Number but not an Int	
		twice("A griffin! ")  # strings mean something else		
		
		```
		
		
		"""

# ╔═╡ db1bb4c8-4e76-11eb-2756-3f6ce778acc0
begin
	twice(x::Number) = 2x;
	twice(x::AbstractString) = x * x;
end

# ╔═╡ ff755bf8-4e76-11eb-205f-d52529ae50ed
methods(twice)

# ╔═╡ 03932e5e-4e77-11eb-3769-635cc33c3c4d
twice(10)

# ╔═╡ 0b4f99ea-4e77-11eb-29fc-632788d179a3
twice(10.0)

# ╔═╡ 2a0b220a-4e77-11eb-1da7-2978422c11f4
twice("A griffin! ")

# ╔═╡ bf91e40a-4e77-11eb-14f1-754b1ce5130e
md"> Julia will always select the method with the most specific type signature.
So, if we would define a function `twice(x::Float64)`, it would be chosen to process `Float64` inputs, even though these are also `Number`s."

# ╔═╡ e1a88a70-4e76-11eb-2486-e1d2f4211792
begin
	f(x, y) = "No life forms present";
	f(x::T, y::T) where {T} = x * y;  # short for {T <: Any} TODO: ?????
	f(x::Integer, y::Real) = 2x + y;
	f(x::Int, y::Int) = 2x + 2y;
	f(x::Integer, y::Float64) = x + 2y;
	f(x::Float64, y::Real) = x - y;
	f(x::Float64, y::Float64) = 2x - y;
end

# ╔═╡ 622b8382-6015-11eb-17fb-3352c73a0d10
md"""
		
		Predict the outcome of the following statements.
			
		```julia
		f(1, 2.0)

		f(1.0, 2)

		f(Int8(1), Int8(2))

		f(1.0, 2.0)

		f("one", 2)

		f("one", "two")

		f(1, Float32(2.0))

		f(1, 2)

		f([1 1; 1 1], [2.0 2.0; 2.0 2.0])

		f([1 1; 1 1], [2 2; 2 2])	

		```
		
		
		"""

# ╔═╡ 76fe9fc4-4e77-11eb-3bc7-2dfbdff8dfc8
f(1, 2.0)

# ╔═╡ 7aa14c94-4e77-11eb-25c7-fb0103267b06
f(1.0, 2)

# ╔═╡ 7f3a5336-4e77-11eb-2ad6-3d889dc75ac0
f(Int8(1), Int8(2))

# ╔═╡ 822c01d4-4e77-11eb-1409-fbaf83c950b6
f(1.0, 2.0)

# ╔═╡ 85f186a6-4e77-11eb-19ca-5db29615ba97
f("one", 2)

# ╔═╡ 891c820e-4e77-11eb-1ebf-b3065e0d4211
f("one", "two")

# ╔═╡ 8d0d39c4-4e77-11eb-034d-07dc33ab6e9a
f(1, Float32(2.0))

# ╔═╡ 901efaee-4e77-11eb-02d9-b5fe1f0931d5
f(1, 2)

# ╔═╡ 938d8b1e-4e77-11eb-03d3-9b88c7cab3c1
f([1 1; 1 1], [2.0 2.0; 2.0 2.0])

# ╔═╡ 96f6fef2-4e77-11eb-2ec4-399472d86a60
f([1 1; 1 1], [2 2; 2 2])	

# ╔═╡ 812cfe48-4e7a-11eb-32e6-c918bbe3e602
md"""

## Extending the type system

Being aware of the type system is a first step but the fun is in extending it and creating your own types. 

### Abstract types

Abstract types are defined using the following simple syntax:

```
abstract type «name» end
abstract type «name» <: «supertype» end
```

### Primitive types

*Primitive types* exist of simple bits. Examples are `Float64` and `Int16`. You can declare your own types, though this is likely not something many often do in practice. For example, there is a specific binary encoding possible for nucleotides to make bioinformatics [computations more efficient](https://medium.com/analytics-vidhya/bioinformatics-2-bit-encoding-for-dna-sequences-9b93636e90e2).

### Composite types
*Composite types* (records, structs, or objects) are more exciting. They are often containers for several objects set to behave in a certain way. We will study them in depth in the next notebook.
"""

# ╔═╡ 178a5f96-6016-11eb-0314-010203c5fedf
md"It takes some time to fully grasp the potential of julia's type system, especially if you have experience in object-oriented programming. In the following examples we will try to show you the uniqueness and power of this paradigm."

# ╔═╡ 4df6c0c0-4e7c-11eb-1d43-0d9bbf4896a7
md"""
## Case study 1: Mohs scale


![](https://i.imgur.com/WtyJ2Uq.png)
[source ](http://www.911metallurgist.com/blog/wp-content/uploads/2015/08/Mohs-Hardness-Test-Kit-and-Scale.jpg)
"""

# ╔═╡ d668a692-6017-11eb-2f28-e9b00762b92d
md"The Mohs scale of mineral hardness is a qualitative ordinal scale characterizing scratch resistance of various minerals through the ability of harder material to scratch softer material. [wikipedia](https://en.wikipedia.org/wiki/Mohs_scale_of_mineral_hardness)"

# ╔═╡ fb1d0b9a-6017-11eb-0ba1-67e204f150fd
md"First we define the abstract type tree structure,"

# ╔═╡ b487a776-4e7e-11eb-291b-e900e6e1a2f6
begin
	abstract type Mohs end
	
	
	abstract type Diamond <: Mohs end
	abstract type Corundum <: Mohs end
	abstract type Topaz <: Mohs end
	abstract type Quartz <: Mohs end
	abstract type Orthoclase <: Mohs end
	abstract type Apatite <: Mohs end
	abstract type Fluorite <: Mohs end
	abstract type Calcite <: Mohs end
	abstract type Gypsum <: Mohs end
	abstract type Talc <: Mohs end
end

# ╔═╡ 0884f752-6018-11eb-2eb3-d1cd317dceb3
md"You can see, it is a pretty flat hierarchy"

# ╔═╡ 443ecf72-6018-11eb-1a7a-e75e9596e4bd
md"Next, let us define a function `mohs_scale` that dispatches on the different abstract types (minerals) and returns a hardness value"

# ╔═╡ 1aea83a8-4e7f-11eb-2d06-c3e550c4e1b9
begin
	mohs_scale(::Type{Diamond}) = 10
	mohs_scale(::Type{Corundum}) = 9
	mohs_scale(::Type{Topaz}) = 8
	mohs_scale(::Type{Quartz}) = 7
	mohs_scale(::Type{Orthoclase}) = 6
	mohs_scale(::Type{Apatite}) = 5
	mohs_scale(::Type{Fluorite}) = 4
	mohs_scale(::Type{Calcite}) = 3
	mohs_scale(::Type{Gypsum}) = 2
	mohs_scale(::Type{Talc}) = 1
end

# ╔═╡ 70390e06-6018-11eb-3bd8-97ff84985261
begin
	💎 = Diamond
	🔶 = Topaz
end;

# ╔═╡ 9b4cad6e-6018-11eb-0e41-2fea9c9219ed
supertype(💎)

# ╔═╡ ab1c59c4-6018-11eb-1147-8d441c25aa0b
mohs_scale(💎)

# ╔═╡ e36b2aa8-6018-11eb-0582-997ba8b7eae7
mohs_scale(🔶)

# ╔═╡ b5339e22-6018-11eb-38b6-352602a85cdd
md"Will 💎 scratch 🔶?"

# ╔═╡ 02e57e74-6019-11eb-3e35-1d2b4d61b283
md"To make this more user-friendly, one can add a method to the `<`-operator or the `isless`-function to work directly on `mohs_scale`."

# ╔═╡ 6e429164-4e7f-11eb-1829-0582f1417815
Base.isless(m1::Type{<:Mohs}, m2::Type{<:Mohs}) = mohs_scale(m1) < mohs_scale(m2)

# ╔═╡ 972154f6-6536-11eb-08a8-e3fc98623177
function subtypetree(roottype, level=1, last=false)
	level == 1 && println(split(string(roottype),".")[end])
	for (index, s) in enumerate(subtypes(roottype))
	
		if index < length(subtypes(roottype))
			println(join(fill("│  ", level-1-1*last))* 
				join(fill("   ", 1*last)) * "├──" * split(string(s),".")[end])

			subtypetree(s, level + 1, false)
		else
			println(join(fill("│  ", level-1-1*last))* 
				join(fill("   ", 1*last)) * "└──" * split(string(s),".")[end])
			subtypetree(s, level + 1, true)
		end

	end
end

# ╔═╡ e50c3f36-653c-11eb-0eb4-cf44af78e44c
subtypetree(Real)

# ╔═╡ 24588124-6018-11eb-24d1-f9c7759f4c8f
subtypetree(Mohs)  

# ╔═╡ fc0f2e92-6018-11eb-0b45-49fdec301609
mohs_scale(💎) > mohs_scale(🔶)

# ╔═╡ ad6e9d8e-4e7f-11eb-1e33-efcee699f2a0
isless(Diamond, Corundum)

# ╔═╡ 9d1c94ba-4e7f-11eb-060e-d1bc9683af92
Calcite < Fluorite < Corundum

# ╔═╡ 8dc6a6ce-6019-11eb-1cd5-d1c1c118f4ee
md"`>` is defined using the `isless` function, so this just works,"

# ╔═╡ 73f66dc6-6019-11eb-06b8-7db54f428e12
💎 > 🔶

# ╔═╡ ee370b50-4e7f-11eb-1ce0-d1bdb3e41ae2
rocks = [Gypsum, Orthoclase, Quartz, Corundum, Fluorite, Gypsum, Talc]

# ╔═╡ 1117c600-4e80-11eb-3231-4383d700f760
md"Even cooler, `sort` and `sort!` are also internally defined using the `isless` function, so these just work out of the box:"

# ╔═╡ 07a19574-4e80-11eb-38fa-8d3463dfd700
sort(rocks)

# ╔═╡ af5bdeb4-6019-11eb-2265-a9b81e01d9c0


# ╔═╡ 84a0f49c-4e7c-11eb-14f2-452e57f2e414
md"""
## Case study 2: rock-paper-scissors

![Fire, water, grass!](https://upload.wikimedia.org/wikipedia/commons/thumb/6/67/Rock-paper-scissors.svg/1200px-Rock-paper-scissors.svg.png)

We can easily implement the rock-paper-scissors rules using types.
"""

# ╔═╡ 99c4f3c8-4e7c-11eb-3d4a-33ba8d495eb2
begin
	abstract type Hand end
	
	
	abstract type Rock <: Hand end
	abstract type Paper <: Hand end
	abstract type Scissors <: Hand end
end

# ╔═╡ cba6d4cc-5b03-11eb-265d-3f08117b0e8d
md"Now we implement a function to play one hand against an opponent's hand."

# ╔═╡ d913cd92-4e7c-11eb-11e1-3d7539af7fed
begin
	play(h1::Type{Paper}, h2::Type{Rock}) = 1
	play(h1::Type{Rock}, h2::Type{Scissors}) = 1
	play(h1::Type{Scissors}, h2::Type{Paper}) = 1
	
	# this captures both when same inputs are given and
	# when the first person looses
	play(h1::Type{<:Hand}, h2::Type{<:Hand}) = h1 == h2 ? 0 : -1
end

# ╔═╡ 4f107d88-4e7d-11eb-3e49-f54ecf5163da
play(Rock, Rock)

# ╔═╡ 8331c8b0-4e7d-11eb-0690-8bbae3ed086a
play(Rock, Scissors)

# ╔═╡ 88a95ec0-4e7d-11eb-0a33-77ef82874f45
play(Scissors, Rock)

# ╔═╡ 925e2f40-4e7d-11eb-0bd2-f91913c5a23e
play(Scissors, Paper)

# ╔═╡ 629e7829-d214-4406-a082-aa1f82cb539c
md"""
> **Optional question: rock, paper, scissors, lizard, Spock**

Can you extend the previous code so that it works with lizard an Spock? 
		
![](https://i.imgur.com/jbmAYKI.png)

adapted from: [source](https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fwordpress.morningside.edu%2Fcdl001%2Ffiles%2F2010%2F09%2FRockPaperScissorsLizardSpock.jpg&f=1&nofb=1)
"""

# ╔═╡ 269b934c-601b-11eb-00ad-5fec0e2c37e1


# ╔═╡ ce5d564a-f2f3-4b1e-aa70-85253b2ccf38
md"""## Answers:
If you would like to take a look at the answers, you can do so by checking the box of the question you would like to see. The function will be shown just below the question you want to look at.

| Question | Show solution |
|-----|:---------:|
| Question string parsing | $(@bind answ_q1 CheckBox()) |
| Question Rock,Paper,Spock | $(@bind answ_q2 CheckBox()) |

"""

# ╔═╡ 9a33c306-653c-11eb-3373-01e90d12b246
if answ_q1 == true
	md"""
	```Julia
	sumofbunchofnumbers(bunchofnumbers) = parse.(Float64, split(rstrip(bunchofnumbers), ", ")) |> sum
	```
	"""
end

# ╔═╡ 3cf6dffd-d91e-465a-94bb-0ffe6b5152aa
if answ_q2 == true
	md"""
	```Julia
	abstract type Lizard <: Hand end
	abstract type Spock <: Hand end
	
	play(h1::Type{Paper}, h2::Type{Spock}) = 1
	play(h1::Type{Rock}, h2::Type{Lizard}) = 1
	play(h1::Type{Lizard}, h2::Type{Paper}) = 1
	play(h1::Type{Lizard}, h2::Type{Spock}) = 1
	play(h1::Type{Spock}, h2::Type{Scissors}) = 1
	play(h1::Type{Spock}, h2::Type{Rock}) = 1
	play(h1::Type{Scissors}, h2::Type{Lizard}) = 1
	```
	"""
end

# ╔═╡ Cell order:
# ╟─79271c7b-a15c-4e12-ae89-d107604c218d
# ╠═5899b739-14c5-4627-8be2-d1d94bc23add
# ╠═e9576706-600e-11eb-1e10-e3bac02a254e
# ╟─4ec271b0-4e73-11eb-2660-6b8bd637d7ee
# ╟─a1f2d06e-4e73-11eb-3afd-1353def71700
# ╠═c0bfdf9e-4e73-11eb-3962-0b3c5d5424d7
# ╟─bd994d64-600e-11eb-1ab3-ed6317b7c211
# ╠═b844d568-4e73-11eb-3de9-4158b0bdca12
# ╠═c662744a-4e73-11eb-1bfc-6daaf7282285
# ╠═cae803e2-4e73-11eb-13e0-23abccf86bac
# ╠═cc606026-4e73-11eb-3576-5d301a771a5a
# ╟─d3803112-4e73-11eb-2018-f72ffb7f6ec6
# ╟─e8fe2832-4e78-11eb-3fd6-a3f1f0c0892a
# ╠═f533012c-4e78-11eb-0f45-3b47f088c9c6
# ╟─f69d89ba-4e73-11eb-3ab9-9179ea7e3217
# ╟─de3de7fc-4e73-11eb-2ff6-1560481f7ee5
# ╟─0598b350-b906-4792-a42f-54ba3eed9577
# ╠═e1c8cf4a-4e73-11eb-27be-d702064a0182
# ╠═e56a46c6-4e73-11eb-1748-1b6fe5ab0376
# ╠═e89adcaa-4e73-11eb-1ed8-e9c89ca633f6
# ╠═ec2ab2be-4e73-11eb-1a22-010439761432
# ╠═efa205b4-4e73-11eb-1647-e9dcab5f7b7a
# ╠═f3b5a778-4e73-11eb-1d3c-11ae19713eca
# ╟─a0cecb24-4e74-11eb-3634-cd8dd628e9ec
# ╟─c232463e-233b-449a-befd-306c7d7100d5
# ╠═b31fe65a-4e74-11eb-0414-35f2be687c7f
# ╠═c2ac0c48-4e74-11eb-10b0-91ad620fefcd
# ╠═c5208cce-4e74-11eb-0615-135b510a9e8d
# ╠═c817296a-4e74-11eb-0994-972871114f02
# ╠═cb066442-4e74-11eb-35e7-ed38d4bd8bbf
# ╠═ce3d5380-4e74-11eb-3d9d-5f34cbbae118
# ╠═9982a6ba-1804-4cb6-9b89-82de11c85595
# ╟─66343826-6012-11eb-109c-17c7a582cbc8
# ╟─34ca6158-4e75-11eb-3d51-330952c9b3dd
# ╠═972154f6-6536-11eb-08a8-e3fc98623177
# ╠═e50c3f36-653c-11eb-0eb4-cf44af78e44c
# ╟─3d1db2de-6549-11eb-2649-2d96659813f6
# ╠═46eaafee-6549-11eb-2e36-c9e566d3f3ba
# ╠═6cbd4874-6549-11eb-296e-af4a43d53223
# ╟─4a01487c-4e78-11eb-1302-d9c6ec4ed6ab
# ╠═66292626-4e78-11eb-331b-0563b2110605
# ╠═704b2ebe-4e78-11eb-1583-d10e0aeb2b8d
# ╠═c3c40df2-4e78-11eb-3d4a-5fdfdf173da3
# ╠═cd32e96c-4e78-11eb-0b48-5767421c7875
# ╟─40a761c2-5b24-11eb-09a8-a5cd0bc4ab95
# ╠═99228eee-5b24-11eb-385e-7507ca20ae0e
# ╠═03133d24-6621-11eb-03d3-bb8970ab19f7
# ╟─ba39991a-5b24-11eb-260b-439bcde4c153
# ╠═35e53434-5b25-11eb-10b7-e993e9477c8c
# ╠═92dc7a4e-5b25-11eb-1518-8182216f24ec
# ╟─aa26b46c-4e78-11eb-24d8-7fdce7c94fff
# ╠═815b0436-4e78-11eb-13d4-0dc6531e34f2
# ╠═570c85bc-4e79-11eb-0249-891cf205d623
# ╟─b3da4c4b-3603-489a-b1ad-3c4a17ef9a98
# ╠═6756d6ac-4e79-11eb-21ab-4776195c9d3b
# ╠═e6f31ad8-4e79-11eb-11f4-2936cb039f8d
# ╟─9a33c306-653c-11eb-3373-01e90d12b246
# ╟─03766a5c-4e75-11eb-12ad-cb2e9468e0d2
# ╟─63166056-6014-11eb-09c4-e5a44d37095f
# ╠═2dff8c88-4e75-11eb-050b-7152e82ac10d
# ╠═7c2b6dc0-4e76-11eb-1d78-553df82d9100
# ╠═d2a4a32c-5b02-11eb-3839-8108c4965931
# ╠═32d64b6e-4e75-11eb-0a2a-27214f217f70
# ╟─861ba4c6-4e76-11eb-3d2b-bfabbd143df2
# ╠═8d5f7d8e-4e76-11eb-28ba-bdec03a3e150
# ╟─b4fac50a-6015-11eb-16d4-594858d78b3e
# ╟─9ed7cb5a-6014-11eb-0ae8-eba8d77867a2
# ╠═b18d0532-4e76-11eb-2e8a-2bee580533cc
# ╟─b3d15950-6015-11eb-1909-c127822a4a83
# ╟─cd2eaafc-4e76-11eb-245a-e9898d3d57a4
# ╟─002fdec6-6015-11eb-0e89-c7d020826cf9
# ╠═db1bb4c8-4e76-11eb-2756-3f6ce778acc0
# ╠═ff755bf8-4e76-11eb-205f-d52529ae50ed
# ╠═03932e5e-4e77-11eb-3769-635cc33c3c4d
# ╠═0b4f99ea-4e77-11eb-29fc-632788d179a3
# ╠═2a0b220a-4e77-11eb-1da7-2978422c11f4
# ╟─bf91e40a-4e77-11eb-14f1-754b1ce5130e
# ╠═e1a88a70-4e76-11eb-2486-e1d2f4211792
# ╟─622b8382-6015-11eb-17fb-3352c73a0d10
# ╠═76fe9fc4-4e77-11eb-3bc7-2dfbdff8dfc8
# ╠═7aa14c94-4e77-11eb-25c7-fb0103267b06
# ╠═7f3a5336-4e77-11eb-2ad6-3d889dc75ac0
# ╠═822c01d4-4e77-11eb-1409-fbaf83c950b6
# ╠═85f186a6-4e77-11eb-19ca-5db29615ba97
# ╠═891c820e-4e77-11eb-1ebf-b3065e0d4211
# ╠═8d0d39c4-4e77-11eb-034d-07dc33ab6e9a
# ╠═901efaee-4e77-11eb-02d9-b5fe1f0931d5
# ╠═938d8b1e-4e77-11eb-03d3-9b88c7cab3c1
# ╠═96f6fef2-4e77-11eb-2ec4-399472d86a60
# ╟─812cfe48-4e7a-11eb-32e6-c918bbe3e602
# ╟─178a5f96-6016-11eb-0314-010203c5fedf
# ╟─4df6c0c0-4e7c-11eb-1d43-0d9bbf4896a7
# ╟─d668a692-6017-11eb-2f28-e9b00762b92d
# ╟─fb1d0b9a-6017-11eb-0ba1-67e204f150fd
# ╠═b487a776-4e7e-11eb-291b-e900e6e1a2f6
# ╟─0884f752-6018-11eb-2eb3-d1cd317dceb3
# ╠═24588124-6018-11eb-24d1-f9c7759f4c8f
# ╟─443ecf72-6018-11eb-1a7a-e75e9596e4bd
# ╠═1aea83a8-4e7f-11eb-2d06-c3e550c4e1b9
# ╠═70390e06-6018-11eb-3bd8-97ff84985261
# ╠═9b4cad6e-6018-11eb-0e41-2fea9c9219ed
# ╠═ab1c59c4-6018-11eb-1147-8d441c25aa0b
# ╠═e36b2aa8-6018-11eb-0582-997ba8b7eae7
# ╟─b5339e22-6018-11eb-38b6-352602a85cdd
# ╠═fc0f2e92-6018-11eb-0b45-49fdec301609
# ╟─02e57e74-6019-11eb-3e35-1d2b4d61b283
# ╠═6e429164-4e7f-11eb-1829-0582f1417815
# ╠═ad6e9d8e-4e7f-11eb-1e33-efcee699f2a0
# ╠═9d1c94ba-4e7f-11eb-060e-d1bc9683af92
# ╟─8dc6a6ce-6019-11eb-1cd5-d1c1c118f4ee
# ╠═73f66dc6-6019-11eb-06b8-7db54f428e12
# ╠═ee370b50-4e7f-11eb-1ce0-d1bdb3e41ae2
# ╟─1117c600-4e80-11eb-3231-4383d700f760
# ╠═07a19574-4e80-11eb-38fa-8d3463dfd700
# ╟─af5bdeb4-6019-11eb-2265-a9b81e01d9c0
# ╟─84a0f49c-4e7c-11eb-14f2-452e57f2e414
# ╠═99c4f3c8-4e7c-11eb-3d4a-33ba8d495eb2
# ╟─cba6d4cc-5b03-11eb-265d-3f08117b0e8d
# ╠═d913cd92-4e7c-11eb-11e1-3d7539af7fed
# ╠═4f107d88-4e7d-11eb-3e49-f54ecf5163da
# ╠═8331c8b0-4e7d-11eb-0690-8bbae3ed086a
# ╠═88a95ec0-4e7d-11eb-0a33-77ef82874f45
# ╠═925e2f40-4e7d-11eb-0bd2-f91913c5a23e
# ╟─629e7829-d214-4406-a082-aa1f82cb539c
# ╠═269b934c-601b-11eb-00ad-5fec0e2c37e1
# ╟─3cf6dffd-d91e-465a-94bb-0ffe6b5152aa
# ╟─ce5d564a-f2f3-4b1e-aa70-85253b2ccf38
