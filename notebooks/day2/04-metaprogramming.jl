### A Pluto.jl notebook ###
# v0.19.38

using Markdown
using InteractiveUtils

# ╔═╡ 6bae75f9-dfc1-4c7c-a811-7dc51139d828
import Pkg; Pkg.add("PlutoUI")

# ╔═╡ 42e620aa-5f4c-11eb-2ebf-85814cf720e7
using PlutoUI; TableOfContents()

# ╔═╡ 122cffca-5fdc-11eb-3555-b39b818f1116
let 
	using JuMP
	using GLPK
end

# ╔═╡ 24806108-5fdc-11eb-2f19-bb09f836f893
using Sockets

# ╔═╡ 4621c212-5fc7-11eb-2c9d-ad577506420e
using Plots

# ╔═╡ b2c1cef8-5fe5-11eb-20c7-134432196893
using Distributed

# ╔═╡ 31c1e25e-5e53-11eb-2467-9153d30962d5
md"""
# Metaprogramming

The strongest legacy of [Lisp](https://en.wikipedia.org/wiki/Lisp_(programming_language)) in the Julia language is its metaprogramming  support. Like Lisp, Julia represents its own code as a data structure of the language itself. 

Since code is represented by objects that can be created and manipulated from within the language, it is possible for a program to transform and generate its own code. This allows sophisticated code generation without extra build steps, and also allows true Lisp-style macros operating at the level of abstract syntax trees.


Because all data types and code in Julia are represented by Julia data structures, powerful reflection capabilities are available to explore the internals of a program and its types just like any other data.

First, we will talk about how to represent a program (aka the building blocks), then how to manipulate Julia code from Julia with macros. Finally, we end with examples of code generation and some interesting macros
"""

# ╔═╡ 4ab33c0e-5e53-11eb-2e63-2dd6f06de3ba
md"""
## Program representation

Every Julia program starts its life as a string:
"""

# ╔═╡ e76d8f04-5e53-11eb-26df-db496622642d
prog = "1 + 1"

# ╔═╡ f361d734-5e53-11eb-3957-61bd0a370b5a
md"""
**What happens next?**

The next step is to parse each string into an object called an expression, represented by the Julia type `Expr`. 

Parsing means taking the input (in this case, a string) and building a data structure – often some kind of parse tree, [abstract syntax tree](https://en.wikipedia.org/wiki/Abstract_syntax_tree) or other hierarchical structure, giving a structural representation of the input while checking for correct syntax. 
"""

# ╔═╡ 15aaa5b6-5e54-11eb-067f-9dcd096940b6
ex1 = Meta.parse(prog)

# ╔═╡ 34b6a71e-5e54-11eb-0324-4bffbe85c813
typeof(ex1)

# ╔═╡ 22770a30-5e54-11eb-28db-1359ab1f402f
md"""
`Expr` objects contain two parts:

  1. a `Symbol` identifying the kind of expression (e.g. a call, for loop, conditional statement, etc.). A symbol is an [interned string](https://en.wikipedia.org/wiki/String_interning) identifier (string interning is a method of storing only one copy of each distinct string value, which must be immutable).

"""

# ╔═╡ 41f9633c-5e54-11eb-323b-e9703c674b0f
ex1.head

# ╔═╡ 48104478-5e54-11eb-2f23-c98c4ccbb763
md"""
  2. the expression arguments, which may be symbols, other expressions, or literal values:
"""

# ╔═╡ 538e2054-5e54-11eb-2b9c-451637e1d8ee
ex1.args

# ╔═╡ 6e3beaf8-5e54-11eb-154b-95f5887efcb0
md"""
Expressions may also be constructed directly in [prefix notation](https://en.wikipedia.org/wiki/Polish_notation) (= Polish notation, a mathematical notation in which operators precede their operands, i.e. `+ 1 1` instead of `1 + 1` with infix notation):
"""

# ╔═╡ 7de376a8-5e54-11eb-0356-9b74225b671e
ex2 = Expr(:call, :+, 1, 1)

# ╔═╡ 825b45a6-5e54-11eb-27e6-f3cca8a2f67e
md"""
The two expressions constructed above – by parsing and by direct construction – are equivalent:
"""

# ╔═╡ 8b23cac8-5e54-11eb-2424-5972ea3d2e21
ex1 == ex2

# ╔═╡ 8ecd49ba-5e54-11eb-24b6-a328043b7a07
md"""
**The key point here is that Julia code is internally represented as a data structure that is accessible
from the language itself.**

The `dump` function provides an indented and annotated display of `Expr` objects:
"""

# ╔═╡ 985a57f2-5e54-11eb-1f2f-bf23014c6171
dump(ex2)

# ╔═╡ d66ea502-5e54-11eb-2694-4766a05aed38
md"""
### Symbols

The `:` character has two syntactic purposes in Julia. The first form creates a [`Symbol`](https://docs.julialang.org/en/v1/base/base/#Core.Symbol),
an [interned string](https://en.wikipedia.org/wiki/String_interning) used as one building-block
of expressions:
"""

# ╔═╡ db1e9936-5e54-11eb-376f-8ddea65d976c
s = :foo

# ╔═╡ e4f50fda-5e54-11eb-2210-6b8eb531d898
typeof(s)

# ╔═╡ ea891b6e-5e54-11eb-24c9-357a8a65d1c0
md"""
The `Symbol` constructor takes any number of arguments and creates a new symbol by concatenating
their string representations together:
"""


# ╔═╡ efe79c46-5e54-11eb-23c9-3107ea94e5b9
:foo == Symbol("foo")

# ╔═╡ f5fac50e-5e54-11eb-2ff9-cf7e30a4a8ad
Symbol("func", 10)

# ╔═╡ fe35b31e-5e54-11eb-258e-29913f1e8723
Symbol(:var, '_', "sym")

# ╔═╡ 0464f1be-5e55-11eb-34df-ef1217012663
md"""Note that to use `:` syntax, the symbol's name must be a valid identifier.
Otherwise, the `Symbol(str)` constructor must be used.

In the context of an expression, symbols are used to indicate access to variables; when an expression
is evaluated, a symbol is replaced with the value bound to that symbol in the appropriate **scope**.
"""

# ╔═╡ abfc3392-5e5a-11eb-149d-ad3dd2755524
md"""
### Quoting

The second syntactic purpose of the `:` character is to create expression objects without using
the explicit `Expr` constructor. This is referred to as *quoting*. The `:` character, followed
by paired parentheses around a single statement of Julia code, produces an `Expr` object based
on the enclosed code. Here is an example of the short form used to quote an arithmetic expression:
"""

# ╔═╡ 917a579c-5e5a-11eb-3fe6-cb0dcad5e4e6
ex = :(a + b * c + 1)

# ╔═╡ 82d3220a-5e5a-11eb-3c49-d5e7afb1af2a
typeof(ex)

# ╔═╡ 67954702-5e5a-11eb-1ab1-e9a285ee208d
ex.args

# ╔═╡ 66c113d0-5e5d-11eb-0aab-b3fa7f98eae5
md"""
### Evaluating expressions

Given an expression object, one can cause Julia to evaluate (execute) it at global scope using `eval`
"""

# ╔═╡ 6fc2fb9c-5e5d-11eb-0f21-6524555a9c42
:(1 + 2)

# ╔═╡ 6dab1d58-5e5d-11eb-3381-a1796f8d14c5
eval(:(1 + 2))

# ╔═╡ b833d8ba-5e5d-11eb-3311-899efb15c1b0
md"""
## Macros

Now that we have an understanding of the basic concepts of code representation in Julia, we can introduce the core concept of this notebook: macros. 

Macros provide a method to include generated code in the final body of a program. A macro maps
a tuple of arguments to a returned *expression*, and the resulting expression is compiled directly
rather than requiring a runtime `eval` call. Macro arguments may include expressions,
literal values, and symbols. 

In the following examples, we will show that macros allow us to
1. modify code before it runs
2. elegantly add new features or syntax
3. process strings at compile time instead of runtime

### Basics

Here is an extraordinarily simple macro:
"""

# ╔═╡ 169c6aa2-5e5e-11eb-1d84-e7e3b4641e10
macro sayhello()
	return :( println("Hello, world!") )
end

# ╔═╡ c40cebe6-5e5e-11eb-1f7f-37134b7a449f
md"""
Macros have a dedicated character in Julia's syntax: the `@` (at-sign), followed by the unique
name declared in a `macro NAME ... end` block. In this example, the compiler will replace all
instances of `@sayhello` with:
"""

# ╔═╡ f5ab41f4-5e5f-11eb-02f7-efcb3e05e616
:( println("Hello, world!") )

# ╔═╡ 0001a53a-5e60-11eb-18df-d7e9e7dcf43f
md"""
When `@sayhello` is entered in the REPL, the expression executes immediately, thus we only see the evaluation result:
"""

# ╔═╡ 1707320e-5e60-11eb-3f33-798c81663488
md"""Now, consider a slightly more complex macro:"""

# ╔═╡ 1fdf9600-5e60-11eb-30d3-b167811ae47f
macro sayhello(name)
	return :( println("Hello, ", $name) )
end

# ╔═╡ ae1525ea-5e5e-11eb-3906-593143776559
@sayhello

# ╔═╡ bda7fd66-5e5e-11eb-1e06-eb67a0178e14
@sayhello

# ╔═╡ 2dcacdfc-5e60-11eb-3d04-9f2ffb46d0fe
md"""
This macro takes one argument: `name`. When `@sayhello` is encountered, the quoted expression is *expanded* to interpolate the value of the argument into the final expression:
"""

# ╔═╡ 36fc5076-5e60-11eb-04be-bd9f542b1ff3
@sayhello("Mr. Bond")

# ╔═╡ 0c787198-61a0-11eb-1e30-fbcb5a624076
@sayhello "Mr. Bond"

# ╔═╡ 4a732eb8-5e60-11eb-197b-0729d0f1be15
md"""
We can view the quoted return expression using the function `macroexpand` or the macro `@macroexpand` (**important note:**
this is an extremely useful tool for debugging macros).
We can see that the `"Mr. Bond"` literal has been interpolated into the expression."""

# ╔═╡ 536addec-5e61-11eb-1a9d-d7f2c190d6c2
@macroexpand @sayhello("Mr. Bond")

# ╔═╡ 855412b2-5e61-11eb-3aba-bb862489414e
md"""

### Hold on: why macros?

Macros are necessary because they execute when code is parsed, therefore, macros allow the programmer
to generate and include fragments of customized code *before* the full program is run. To illustrate
the difference, consider the following example.
"""

# ╔═╡ cabb3cdc-5e62-11eb-2479-bb8337c05292
macro twostep(arg)
	println("I execute at parse time. The argument is: ", arg)
	str1 = "I execute at runtime. "
	str2 = "The argument is: "
	message = str1 * str2
	return :(println($message, $arg))
end

# ╔═╡ f33f0cfe-5f52-11eb-30e0-93c4b899aaa7
md"""Note that the computation of `message` is compiled away if we expand the macro!"""

# ╔═╡ 01feeca0-5e63-11eb-11a0-1b66a92127d1
ex_twostep = @macroexpand @twostep :(1, 2, 3)

# ╔═╡ f1969888-5e65-11eb-18a3-879d2f87b447
dump(ex_twostep)

# ╔═╡ da275ff1-b3d9-4a91-b03a-914878555418
md"If you need another example, check out the code below that is generated using the `@elapsed` macro: a functionality that lets you time an expression by injecting `time_ns()` before and after the expression.
"

# ╔═╡ 876ea56f-d426-4908-a832-96ccbd83d950
@macroexpand @elapsed sleep(1)

# ╔═╡ 0613f620-5e66-11eb-08d9-01dd3a403321
md"""
### Macro invocation

Macros are invoked with the following general syntax:

```julia
@name expr1 expr2 ... # only spaces!
@name(expr1, expr2, ...) # no space, with commas!
```

"""

# ╔═╡ a1e86478-5e66-11eb-2ef9-6d460e707013
md"""
### Building an advanced macro

Here is a simplified definition of Julia's `@assert` macro, which checks if an expression is true:

(`... ? ... : ...` is the ternary if-else operator seen in `01-basics.jl` )
"""

# ╔═╡ e61381aa-5e66-11eb-3347-5d26b61e6c17
macro assert(ex)
	return :( $ex ? nothing : throw(AssertionError($(string(ex)))) )
end

# ╔═╡ a43490de-5e67-11eb-253e-f7455ade3ffe
md"""This macro can be used like this:"""

# ╔═╡ c79ad04c-5e67-11eb-1fd9-bf7ff40f0862
md"""
In place of the written syntax, the macro call is expanded at parse time to its returned result. This is equivalent to writing:"""

# ╔═╡ f34e9020-5e67-11eb-1987-e3e6a0969705
1 == 1.0 ? nothing : throw(AssertionError("1 == 1.0"))

# ╔═╡ f81955fe-5e67-11eb-11b9-5f9fd0096a09
1 == 0 ? nothing : throw(AssertionError("1 == 0"))

# ╔═╡ fb772ef4-5e67-11eb-218e-330ba087bcc8
md"""
That is, in the first call, the expression `:(1 == 1.0)` is spliced into the test condition slot,
while the value of `string(:(1 == 1.0))` is spliced into the assertion message slot. The entire
expression, thus constructed, is placed into the syntax tree where the `@assert` macro call occurs.
Then at execution time, if the test expression evaluates to true, then `nothing` is returned,
whereas if the test is false, an error is raised indicating the asserted expression that was false.

**Notice that it would not be possible to write this as a function since only the value of the condition is available and it would be impossible to display the expression that computed it in the error message.**

The actual definition of `@assert` in Julia Base is more complicated. It allows the
user to optionally specify their own error message, instead of just printing the failed expression.
Just like in functions with a variable number of arguments, this is specified with an ellipsis
following the last argument:
"""

# ╔═╡ 2df2baa8-5e68-11eb-2f28-9968b7ecbcd5
macro assert(ex, msgs...)
	msg_body = isempty(msgs) ? ex : msgs[1]
	msg = string(msg_body)
	return :($ex ? nothing : throw(AssertionError($msg)))
end

# ╔═╡ b0dfd0dc-5e67-11eb-19cf-5970a2e80bfa
@assert 1 == 1.0

# ╔═╡ c42d2d6a-5e67-11eb-1564-2dcb0e91fb19
@assert 1 == 0

# ╔═╡ 376fe8e4-5e68-11eb-1d7d-c9b1945b133f
md"""
Now `@assert` has two modes of operation depending upon the number of arguments it receives!
If there is only one argument, the tuple of expressions captured by `msgs` will be empty and it
will behave the same as the simpler definition above with only one argument. But now if the user specifies a second argument,
it is printed in the message body instead of the failing expression. You can inspect the result
of a macro expansion with `@macroexpand`.
"""

# ╔═╡ 4750ce04-5e68-11eb-237e-3fed9eb1f4c5
@macroexpand @assert a == b

# ╔═╡ 4dce26dc-5e68-11eb-1ff7-8974f93e3cb8
@macroexpand @assert a==b "a should equal b!"

# ╔═╡ 43a19ace-5e6b-11eb-005b-b7d2d9a46878
md"""
### Macros and dispatch

Macros, just like Julia functions, are generic. This means they can also have multiple method definitions, thanks to multiple dispatch:
"""

# ╔═╡ 508167c4-5e6b-11eb-2587-b967b79cf74c
macro m end

# ╔═╡ 59f86d98-5e6b-11eb-3259-7312501b70bf
macro m(args...)
	"$(length(args)) arguments"
end

# ╔═╡ 5edf55e2-5e6b-11eb-383e-5965ae694c4c
macro m(x,y)
   	"Two arguments"
end

# ╔═╡ 3dc3aa10-5e6c-11eb-3338-7777b8cb97a5
md"""
However one should keep in mind, that macro dispatch is based on the types of AST
that are handed to the macro, not the types that the AST evaluates to at runtime:"""

# ╔═╡ 34565ba8-5e6c-11eb-2a27-2ff13394bcc8
macro m(::Int)
	"An Integer"
end

# ╔═╡ 65c94e9c-5e6b-11eb-38a8-4d60c692222b
@m "asdl"

# ╔═╡ 42fc5284-5e6c-11eb-0edb-9555a320ec55
@m 1 2

# ╔═╡ dc168cf8-484f-4054-a6d2-55703e99fda2
@m 1 2 3

# ╔═╡ 02e4bf64-5e6d-11eb-36b5-fb57c87bff81
@m 3

# ╔═╡ 07f8cc34-5e6d-11eb-36e4-b56b2b92a2e2
x = 2

# ╔═╡ 0bbfce80-5e6d-11eb-07f6-b71086357384
@m x

# ╔═╡ 0e00bff6-5e6d-11eb-342d-bfded7ef8a96
md"""
## Code Generation

When a significant amount of repetitive boilerplate code is required, it is common to generate
it programmatically to avoid redundancy. In most languages, this requires an extra build step,
and a separate program to generate the repetitive code. In Julia, expression interpolation and `eval` allow such code generation to take place in the normal course of program execution.
For example, consider the following custom type
"""

# ╔═╡ 36805374-5e6d-11eb-205c-0524096bdf27
struct MyNumber
    x::Float64
end

# ╔═╡ 4056c9bc-5e6d-11eb-377e-238ef8633c74
md"""for which we want to add a number of methods to. We can do this programmatically in the following loop:"""

# ╔═╡ 49807d8c-5e6d-11eb-0170-f1419837d958
for op = (:sin, :cos, :tan, :log, :exp, :log)
    @eval Base.$op(a::MyNumber) = MyNumber($op(a.x))
end

# ╔═╡ 4ef3f280-5e6d-11eb-2020-b7cd9e6b9c03
md"""and we can now use those functions with our custom type:"""

# ╔═╡ 53f36f36-5e6d-11eb-3f06-6de0eff4d173
y = MyNumber(π)

# ╔═╡ 3428d7b8-5e6d-11eb-32bc-af1df0579e60
sin(y)

# ╔═╡ 18e3753a-5f55-11eb-0a11-47ca6abe9186
md"This will not work since we only have defined `log` and not `log10`."

# ╔═╡ 2f4fe6ce-5e6c-11eb-1744-2f9534c8b6ba
log10(y)

# ╔═╡ cae2546a-5e6b-11eb-3fc2-69f9a15107cf
md"""In this manner, Julia acts as its own preprocessor, and allows code generation from inside the language."""

# ╔═╡ efc1357a-61a0-11eb-20f5-a15338080e4c
md"### Example: domain-specific languages"

# ╔═╡ 4d9de330-5f55-11eb-0d89-eb81e6c9ffab
md"
Code generation can for instance be used to simplify the creation of a mathematical optimisation problem. In this case, we will use the `JuMP` package.
`JuMP` ('Julia for Mathematical Programming') is an open-source modeling language that is embedded in Julia. It allows users to formulate various classes of optimization problems (linear, mixed-integer, quadratic, conic quadratic, semidefinite, and nonlinear) with easy-to-read code. `JuMP` also makes advanced optimization techniques easily accessible from a high-level language. 

As a dummy example, let us consider the following linear programming problem:

``\max_{x,y}\,\,x + 2y``

``\text{s.t.}``

``x + y \leq 1``

``0\leq x, y \leq 1``

Which can be transcribed into a `JuMP` model as:
"

# ╔═╡ 92458f54-5f57-11eb-179f-c749ce06f7e2
let
	model = Model(GLPK.Optimizer)
	@variable(model, 0 <= x <= 1)
	@variable(model, 0 <= y <= 1)
	@constraint(model, x + y <= 1)
	@objective(model, Max, x + 2y)
	optimize!(model)
	value(x), value(y), objective_value(model)
end


# ╔═╡ d1222dcc-5f57-11eb-2c87-77a16ea8e65d
md"
Without the macros, the code would be more difficult to read. As an example, check the `macroexpansion` of `@constraint` to see the bunch of code that is generated behind the scenes:
"

# ╔═╡ 0b1f3542-5f58-11eb-1610-75df3e2a4a76
let
	model = Model(GLPK.Optimizer)
	@macroexpand @constraint(model, x + y <= 1)
end

# ╔═╡ 2e2601b6-5e94-11eb-3613-eb5fee19b6b7
md"
## Overview of some interesting macros
"

# ╔═╡ d889f68e-4d15-4bab-92f6-c42bac58e60a
md"""
The first example of a custom macro can be found in every notebook in this course! It is the markdown string literal, which allows the usage of Markdown markup language to prettify these lectures!

```julia
md"I am a Markdown string with glorious **formatting capabilities**."
```
I am a Markdown string with glorious *formatting* **capabilities**.

```julia
macro md_str(p)
	...
end
```
"""

# ╔═╡ fe4095e9-0c35-4459-98b0-30ba91fc90b4
md"""
The regular expression macro is just the following:
```julia
macro r_str(p)
    Regex(p)
end
```
That's all. This macro says that the literal contents of the string literal `r"^\s*(?:#|$)"` should
be passed to the `@r_str` macro and the result of that expansion should be placed in the syntax
tree where the string literal occurs. In other words, the expression `r"^\s*(?:#|$)"` is equivalent
to placing the following object directly into the syntax tree:

"""

# ╔═╡ ce8b16fa-7644-4c64-ad3c-cbf667b4811b
Regex("^\\s*(?:#|\$)")

# ╔═╡ f20221ca-82d1-4973-9f68-e46638c929f7
md"Not only is the string literal form shorter and far more convenient, but it is also more efficient:
since the regular expression is compiled, which takes time, and the `Regex` object is actually created *when the code is compiled*, the compilation occurs only once, rather than every time the code is executed.
"

# ╔═╡ 311a4666-5fc5-11eb-2cc0-ef66e5be96e3
md"check if an expression is true"

# ╔═╡ 4622422a-5fc5-11eb-20f2-9bfe466f8f30
@assert true == true

# ╔═╡ 5ba5d6b6-5fc5-11eb-256b-73a954a5db68
md"Integers and floating point numbers with arbitrary precision. This macro exists because promoting a floating point number to a `BigFloat` will keep the approximation error of `Float64`."

# ╔═╡ a47ab60e-5fc5-11eb-368a-d76fc6ee640d
big"0.1"

# ╔═╡ a99546c2-5fc5-11eb-0902-71cb283543c8
@big_str "0.1"

# ╔═╡ af2c7d4e-5fc5-11eb-30d4-a367d2c0db23
big(0.1)

# ╔═╡ 4a335466-5fc6-11eb-2273-312fd3928616
md"There exists a lot more unique string literals than we have shown here, such as html strings, ip address literals, etc."

# ╔═╡ 17f771dc-5fc6-11eb-3b83-ed51f87194e0
html"""<!-- HTML generated using hilite.me --><div style="background: #ffffff; overflow:auto;width:auto;border:solid gray;border-width:.1em .1em .1em .8em;padding:.2em .6em;"><table><tr><td><pre style="margin: 0; line-height: 125%">1</pre></td><td><pre style="margin: 0; line-height: 125%">println(<span style="color: #a31515">&quot;hello world!&quot;</span>)
</pre></td></tr></table></div>
"""

# ╔═╡ 92836b48-5fc6-11eb-19b6-1d7a5c310052
println("There is nothing like ", ip"127.0.0.1")

# ╔═╡ f26e65a8-5fc6-11eb-3cd7-3f40c12a6abb
md"Find out what function is exactly used in multiple dipatch."

# ╔═╡ 154e2392-5fc7-11eb-250b-e726ab7710e7
@which sin(2.2)

# ╔═╡ 2cfa3952-5fc7-11eb-2e79-95f86aafbf2c
@which sin(2)

# ╔═╡ 4aece42a-5fc7-11eb-291f-99120483339f
md"
There exist some handy macros to analyse execution time and memory allocation.

```julia
using BenchmarkTools
@btime sin(2)
@benchmark sin(2)
@elapsed sin(2)
```
"

# ╔═╡ 295e0028-5fd6-11eb-39e4-b392de1c0de2
md"""
When developing modules, scripts or julia packages, you can use the `@info`, `@warn`, `@error` and `@debug` as logging macros. They are mostly useful in packages, not in notebooks like this.

An example usage would be a warning thrown by an optimisation algorithm to tell you that e.g. the predefined accuracy or tolerance was not reached.

Note, to make `@debug` you need to set an environment variable to mark that you are in debug mode: 
```julia
ENV["JULIA_DEBUG"] = "all"
```
"""

# ╔═╡ 4a9d85ba-5fc7-11eb-1b6e-59ef2259dd24
PlutoUI.with_terminal() do
	@info "Information comes here"
	@error "Error has been found at this exact location"
	@warn "Same. but for a warning"
	@debug "Debugging info, not printed by default"
end

# ╔═╡ 34829ada-5fdc-11eb-263a-cf60a9650556
md"Plot recipes are a nifty thing to make plots for your custom data type:"

# ╔═╡ 5c33798c-5fda-11eb-186f-79450fb59e3b
struct TemperatureMeas
	t1
	t2
	t3
	TemperatureMeas(t1, t2, t3) = new(t1, t2, t3)
end

# ╔═╡ 1ca80d42-5fdb-11eb-153f-9ddb25a4fb6b
@recipe function f(tempmeas::TemperatureMeas)
    xguide --> "time (seconds)"
    yguide --> "temperature (Celsius)"
    [tempmeas.t1, tempmeas.t2, tempmeas.t3] # return the arguments (input data) for the next recipe
end

# ╔═╡ 1a793992-5fdb-11eb-3b38-05544f268a65
plot(TemperatureMeas(Plots.fakedata(50), -Plots.fakedata(50), Plots.fakedata(50).^2))

# ╔═╡ d418dca4-5fe5-11eb-3f1a-a31e5dc5f7e9
md"
Using the `Distributed` module, one can easily transform certain types of code to run distributed (i.e. on multiple cores). Below is an example of how you can transform a for-loop into its distributed version.
"

# ╔═╡ f1b70998-5fdb-11eb-292b-0776f1b03816
@sync @distributed for i ∈ 1:5
	println(i)
end

# ╔═╡ 7fb1899d-7ed2-44ad-a76b-79ab401ba9f3
md"
With `@time` or `@elapsed` you can check the execution time of an expression. Note that `@time` returns the result of the expression, whereas `@elapsed` returns the execution time in seconds
"

# ╔═╡ 0b4f0a03-8556-4009-9c3f-89c3628c006f
@time 1:100_000_000 |> sum

# ╔═╡ 867805fe-bc86-4b81-9237-2a056076d138
@elapsed 1:100_000_000 |> sum

# ╔═╡ Cell order:
# ╠═6bae75f9-dfc1-4c7c-a811-7dc51139d828
# ╠═42e620aa-5f4c-11eb-2ebf-85814cf720e7
# ╟─31c1e25e-5e53-11eb-2467-9153d30962d5
# ╟─4ab33c0e-5e53-11eb-2e63-2dd6f06de3ba
# ╠═e76d8f04-5e53-11eb-26df-db496622642d
# ╟─f361d734-5e53-11eb-3957-61bd0a370b5a
# ╠═15aaa5b6-5e54-11eb-067f-9dcd096940b6
# ╠═34b6a71e-5e54-11eb-0324-4bffbe85c813
# ╟─22770a30-5e54-11eb-28db-1359ab1f402f
# ╠═41f9633c-5e54-11eb-323b-e9703c674b0f
# ╟─48104478-5e54-11eb-2f23-c98c4ccbb763
# ╠═538e2054-5e54-11eb-2b9c-451637e1d8ee
# ╟─6e3beaf8-5e54-11eb-154b-95f5887efcb0
# ╠═7de376a8-5e54-11eb-0356-9b74225b671e
# ╟─825b45a6-5e54-11eb-27e6-f3cca8a2f67e
# ╟─8b23cac8-5e54-11eb-2424-5972ea3d2e21
# ╟─8ecd49ba-5e54-11eb-24b6-a328043b7a07
# ╠═985a57f2-5e54-11eb-1f2f-bf23014c6171
# ╟─d66ea502-5e54-11eb-2694-4766a05aed38
# ╠═db1e9936-5e54-11eb-376f-8ddea65d976c
# ╠═e4f50fda-5e54-11eb-2210-6b8eb531d898
# ╟─ea891b6e-5e54-11eb-24c9-357a8a65d1c0
# ╠═efe79c46-5e54-11eb-23c9-3107ea94e5b9
# ╠═f5fac50e-5e54-11eb-2ff9-cf7e30a4a8ad
# ╠═fe35b31e-5e54-11eb-258e-29913f1e8723
# ╟─0464f1be-5e55-11eb-34df-ef1217012663
# ╟─abfc3392-5e5a-11eb-149d-ad3dd2755524
# ╠═917a579c-5e5a-11eb-3fe6-cb0dcad5e4e6
# ╠═82d3220a-5e5a-11eb-3c49-d5e7afb1af2a
# ╠═67954702-5e5a-11eb-1ab1-e9a285ee208d
# ╟─66c113d0-5e5d-11eb-0aab-b3fa7f98eae5
# ╠═6fc2fb9c-5e5d-11eb-0f21-6524555a9c42
# ╠═6dab1d58-5e5d-11eb-3381-a1796f8d14c5
# ╟─b833d8ba-5e5d-11eb-3311-899efb15c1b0
# ╠═169c6aa2-5e5e-11eb-1d84-e7e3b4641e10
# ╠═ae1525ea-5e5e-11eb-3906-593143776559
# ╟─c40cebe6-5e5e-11eb-1f7f-37134b7a449f
# ╠═f5ab41f4-5e5f-11eb-02f7-efcb3e05e616
# ╟─0001a53a-5e60-11eb-18df-d7e9e7dcf43f
# ╠═bda7fd66-5e5e-11eb-1e06-eb67a0178e14
# ╟─1707320e-5e60-11eb-3f33-798c81663488
# ╠═1fdf9600-5e60-11eb-30d3-b167811ae47f
# ╟─2dcacdfc-5e60-11eb-3d04-9f2ffb46d0fe
# ╠═36fc5076-5e60-11eb-04be-bd9f542b1ff3
# ╠═0c787198-61a0-11eb-1e30-fbcb5a624076
# ╟─4a732eb8-5e60-11eb-197b-0729d0f1be15
# ╠═536addec-5e61-11eb-1a9d-d7f2c190d6c2
# ╟─855412b2-5e61-11eb-3aba-bb862489414e
# ╠═cabb3cdc-5e62-11eb-2479-bb8337c05292
# ╟─f33f0cfe-5f52-11eb-30e0-93c4b899aaa7
# ╠═01feeca0-5e63-11eb-11a0-1b66a92127d1
# ╠═f1969888-5e65-11eb-18a3-879d2f87b447
# ╟─da275ff1-b3d9-4a91-b03a-914878555418
# ╠═876ea56f-d426-4908-a832-96ccbd83d950
# ╟─0613f620-5e66-11eb-08d9-01dd3a403321
# ╟─a1e86478-5e66-11eb-2ef9-6d460e707013
# ╠═e61381aa-5e66-11eb-3347-5d26b61e6c17
# ╟─a43490de-5e67-11eb-253e-f7455ade3ffe
# ╠═b0dfd0dc-5e67-11eb-19cf-5970a2e80bfa
# ╠═c42d2d6a-5e67-11eb-1564-2dcb0e91fb19
# ╟─c79ad04c-5e67-11eb-1fd9-bf7ff40f0862
# ╠═f34e9020-5e67-11eb-1987-e3e6a0969705
# ╠═f81955fe-5e67-11eb-11b9-5f9fd0096a09
# ╟─fb772ef4-5e67-11eb-218e-330ba087bcc8
# ╠═2df2baa8-5e68-11eb-2f28-9968b7ecbcd5
# ╟─376fe8e4-5e68-11eb-1d7d-c9b1945b133f
# ╠═4750ce04-5e68-11eb-237e-3fed9eb1f4c5
# ╠═4dce26dc-5e68-11eb-1ff7-8974f93e3cb8
# ╟─43a19ace-5e6b-11eb-005b-b7d2d9a46878
# ╠═508167c4-5e6b-11eb-2587-b967b79cf74c
# ╠═59f86d98-5e6b-11eb-3259-7312501b70bf
# ╠═5edf55e2-5e6b-11eb-383e-5965ae694c4c
# ╠═65c94e9c-5e6b-11eb-38a8-4d60c692222b
# ╠═42fc5284-5e6c-11eb-0edb-9555a320ec55
# ╠═dc168cf8-484f-4054-a6d2-55703e99fda2
# ╟─3dc3aa10-5e6c-11eb-3338-7777b8cb97a5
# ╠═34565ba8-5e6c-11eb-2a27-2ff13394bcc8
# ╠═02e4bf64-5e6d-11eb-36b5-fb57c87bff81
# ╠═07f8cc34-5e6d-11eb-36e4-b56b2b92a2e2
# ╠═0bbfce80-5e6d-11eb-07f6-b71086357384
# ╟─0e00bff6-5e6d-11eb-342d-bfded7ef8a96
# ╠═36805374-5e6d-11eb-205c-0524096bdf27
# ╟─4056c9bc-5e6d-11eb-377e-238ef8633c74
# ╠═49807d8c-5e6d-11eb-0170-f1419837d958
# ╟─4ef3f280-5e6d-11eb-2020-b7cd9e6b9c03
# ╠═53f36f36-5e6d-11eb-3f06-6de0eff4d173
# ╠═3428d7b8-5e6d-11eb-32bc-af1df0579e60
# ╟─18e3753a-5f55-11eb-0a11-47ca6abe9186
# ╠═2f4fe6ce-5e6c-11eb-1744-2f9534c8b6ba
# ╟─cae2546a-5e6b-11eb-3fc2-69f9a15107cf
# ╟─efc1357a-61a0-11eb-20f5-a15338080e4c
# ╟─4d9de330-5f55-11eb-0d89-eb81e6c9ffab
# ╠═122cffca-5fdc-11eb-3555-b39b818f1116
# ╠═92458f54-5f57-11eb-179f-c749ce06f7e2
# ╟─d1222dcc-5f57-11eb-2c87-77a16ea8e65d
# ╠═0b1f3542-5f58-11eb-1610-75df3e2a4a76
# ╟─2e2601b6-5e94-11eb-3613-eb5fee19b6b7
# ╟─d889f68e-4d15-4bab-92f6-c42bac58e60a
# ╟─fe4095e9-0c35-4459-98b0-30ba91fc90b4
# ╠═ce8b16fa-7644-4c64-ad3c-cbf667b4811b
# ╟─f20221ca-82d1-4973-9f68-e46638c929f7
# ╟─311a4666-5fc5-11eb-2cc0-ef66e5be96e3
# ╠═4622422a-5fc5-11eb-20f2-9bfe466f8f30
# ╟─5ba5d6b6-5fc5-11eb-256b-73a954a5db68
# ╠═a47ab60e-5fc5-11eb-368a-d76fc6ee640d
# ╠═a99546c2-5fc5-11eb-0902-71cb283543c8
# ╠═af2c7d4e-5fc5-11eb-30d4-a367d2c0db23
# ╟─4a335466-5fc6-11eb-2273-312fd3928616
# ╟─17f771dc-5fc6-11eb-3b83-ed51f87194e0
# ╠═24806108-5fdc-11eb-2f19-bb09f836f893
# ╠═92836b48-5fc6-11eb-19b6-1d7a5c310052
# ╟─f26e65a8-5fc6-11eb-3cd7-3f40c12a6abb
# ╠═154e2392-5fc7-11eb-250b-e726ab7710e7
# ╠═2cfa3952-5fc7-11eb-2e79-95f86aafbf2c
# ╟─4aece42a-5fc7-11eb-291f-99120483339f
# ╟─295e0028-5fd6-11eb-39e4-b392de1c0de2
# ╠═4a9d85ba-5fc7-11eb-1b6e-59ef2259dd24
# ╟─34829ada-5fdc-11eb-263a-cf60a9650556
# ╠═4621c212-5fc7-11eb-2c9d-ad577506420e
# ╠═5c33798c-5fda-11eb-186f-79450fb59e3b
# ╠═1ca80d42-5fdb-11eb-153f-9ddb25a4fb6b
# ╠═1a793992-5fdb-11eb-3b38-05544f268a65
# ╟─d418dca4-5fe5-11eb-3f1a-a31e5dc5f7e9
# ╠═b2c1cef8-5fe5-11eb-20c7-134432196893
# ╠═f1b70998-5fdb-11eb-292b-0776f1b03816
# ╟─7fb1899d-7ed2-44ad-a76b-79ab401ba9f3
# ╠═0b4f0a03-8556-4009-9c3f-89c3628c006f
# ╠═867805fe-bc86-4b81-9237-2a056076d138
