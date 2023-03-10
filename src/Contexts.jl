"""
Created in February, 2023 by
[chifi - an open source software dynasty.](https://github.com/orgs/ChifiSource)
by team
[toolips](https://github.com/orgs/ChifiSource/teams/toolips)
This software is MIT-licensed.
### Contexts
Contexts is a link between `Toolips` and image layering data, with functional
mutation -- similar to the case with `ToolipsSession`, using a `Modifier` in the
form of a `Context` to mutate different attributes and store such layers.
"""
module Contexts
import Base: getindex, setindex!
using Toolips
using ToolipsSVG
using Random
import Base: show, display

"""
### abstract type AbstractContext <: Toolips.Modifier
AbstractContexts are `Modifiers` that can be used to draw inside of a given frame.
These contexts can be drawn on using the `draw!` method and keep track of
different elements inside of the Context.
##### Consistencies
- window::Component{<Any}
- uuid::String
- layers::Dict{String, UnitRange{Int64}}
- dim::Pair{Int64, Int64}
- margin::Pair{Int64, Int64}
"""
abstract type AbstractContext <: Toolips.Modifier end

"""
### Context <: AbstractContext
- windoww::Component{:svg}
- uuid::String
- layers::Dict{String,  UnitRange{Int64}}
- dim::Int64{Int64, Int64}
- margin::Pair{Int64, Int64}

The `Context` can be used with the `draw!` method in order to create and
draw SVG layers -- as well as store them and mutate them. When indexed with
a `String`, this will yield the layer of that name. When indexed with a
`UnitRange{Int64}`, it will yield the layers in that range. See the
`context` method for more information on easy ways to create these.
##### example
```
using Contexts

con = Context()
line!(con, [5, 1, 2], [7, 34, 5], "stroke" => "red", "stroke-width" => "10")
display(con)
```
------------------
##### constructors
- Context(::Component{:svg}, margin::Pair{Int64, Int64})
- Context(width::Int64 = 1280, height::Int64 = 720, margin::Pair{Int64, Int64} = 0 => 0)
    """
mutable struct Context <: AbstractContext
    window::Component{:svg}
    uuid::String
    layers::Dict{String, UnitRange{Int64}}
    dim::Pair{Int64, Int64}
    margin::Pair{Int64, Int64}
    Context(wind::Component{:svg}, margin::Pair{Int64, Int64}) = begin
        new(wind, randstring(), Dict{String, UnitRange{Int64}}(), wind[:width] => wind[:height],
            margin)::Context
    end
    Context(width::Int64 = 1280, height::Int64 = 720,
        margin::Pair{Int64, Int64} = 0 => 0) = begin
        window::Component{:svg} = svg("window", width = width,
        height = height)
        Context(window, margin)::Context
    end
end

"""
**Contexts**
### show(io::IO, con::AbstractContext) -> _
------------------
Shows the context's window (as HTML).
#### example
```

```
"""
function show(io::IO, con::AbstractContext)
    display(MIME"text/html"(), con.window)
end

"""
**Contexts**
### show(io::Base.TTY, con::AbstractContext) -> _
------------------
Shows the context as text.
#### example
```

```
"""
function show(io::Base.TTY, con::AbstractContext)
    println("Context ($(con.dim[1]) x $(con.dim[2]))")
end

getindex(con::Context, r::UnitRange{Int64}) = begin
    con.layers[findall(x -> x[2] == r, con)]
end

getindex(con::Context, str::String) = con.layers[str]

layers(con::Context) = layers

elements(con::Context) = con.window[:children]

function draw!(c::AbstractContext, comps::Vector{<:Servable}, id::String = randstring())
    current_len::Int64 = length(c.window[:children])
    comp_len::Int64 = length(comps)
    c.window[:children] = Vector{Servable}(vcat(c.window[:children], comps))
    push!(c.layers, id => current_len + 1:current_len + comp_len)
end

mutable struct Group <: AbstractContext
    window::Component{:g}
    uuid::String
    layers::Dict{String, UnitRange{Int64}}
    dim::Pair{Int64, Int64}
    margin::Pair{Int64, Int64}
    Group(name::String = randstring(), width::Int64 = 1280, height::Int64 = 720,
        margin::Pair{Int64, Int64} = 0 => 0) = begin
        window::Component{:g} = g("$name", width = width, height = height)
        new(window, name, Dict{String, UnitRange{Int64}}(), width => height, margin)
    end
end

function group!(f::Function, c::Context, name::String, w::Int64 = c.dim[1],
    h::Int64 = c.dim[2], margin::Pair{Int64, Int64} = c.margin)
    gr = Group(name, w, h, margin)
    f(gr)
    draw!(c, [gr.window], name)
end

function line!(con::AbstractContext, first::Pair{<:Number, <:Number},
    second::Pair{<:Number, <:Number}, styles::Pair{String, <:Any} ...)
    if length(styles) == 0
        styles = ("fill" => "none", "stroke" => "black", "stroke-width" => "4")
    end
    ln = ToolipsSVG.line(randstring(), x1 = first[1], y1 = first[2],
    x2 = second[1], y2 = second[2])
    style!(ln, styles ...)
    draw!(con, [ln])
end

export group!, line!, Context, layers, elements, AbstractContext, Group
end # - module
