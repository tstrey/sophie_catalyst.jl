julia> using Catalyst
[ Info: Precompiling Catalyst [479239e8-5488-4da2-87a7-35f2df7eef83]

julia> using MacroTools

julia> rn = @reaction_network a begin
           @parameters k
           @variables V(t)
           @species B(t) C(t)
           @discrete_events begin
               a == 0 => [a ~ a+1, b ~ b-1]
               b == 1 => [a ~ a-1, b ~ b+1]
           end
           k, C --> B
       end
option_lines = Expr[:(@parameters k), :(@variables V(t)), :(@species B(t) C(t)), :(@discrete_events begin
          a == 0 => [a ~ a + 1, b ~ b - 1]
          b == 1 => [a ~ a - 1, b ~ b + 1]
      end)]
options = Dict{Symbol, Expr}(:species => :(@species B(t) C(t)), :variables => :(@variables V(t)), :discrete_events => :(@discrete_events begin
          a == 0 => [a ~ a + 1, b ~ b - 1]
          b == 1 => [a ~ a - 1, b ~ b + 1]
      end), :parameters => :(@parameters k))
ERROR: BoundsError: attempt to access 2-element Vector{Any} at index [3]
Stacktrace:
  [1] getindex(A::Vector{Any}, i1::Int64)
    @ Base ./array.jl:924
  [2] extract_discrete_events(opts::Dict{Symbol, Expr})
    @ Catalyst ~/Documents/GitHub/Catalyst.jl/src/reaction_network.jl:525
  [3] make_reaction_system(ex::Expr; name::QuoteNode)
    @ Catalyst ~/Documents/GitHub/Catalyst.jl/src/reaction_network.jl:377
  [4] var"@reaction_network"(__source__::LineNumberNode, __module__::Module, name::Symbol, ex::Expr)
    @ Catalyst ~/Documents/GitHub/Catalyst.jl/src/reaction_network.jl:199
  [5] eval
    @ ./boot.jl:368 [inlined]
  [6] eval
    @ ./Base.jl:65 [inlined]
  [7] repleval(m::Module, code::Expr, #unused#::String)
    @ VSCodeServer ~/.vscode/extensions/julialang.language-julia-1.54.2/scripts/packages/VSCodeServer/src/repl.jl:229
  [8] (::VSCodeServer.var"#110#112"{Module, Expr, REPL.LineEditREPL, REPL.LineEdit.Prompt})()
    @ VSCodeServer ~/.vscode/extensions/julialang.language-julia-1.54.2/scripts/packages/VSCodeServer/src/repl.jl:192
  [9] with_logstate(f::Function, logstate::Any)
    @ Base.CoreLogging ./logging.jl:511
 [10] with_logger
    @ ./logging.jl:623 [inlined]
 [11] (::VSCodeServer.var"#109#111"{Module, Expr, REPL.LineEditREPL, REPL.LineEdit.Prompt})()
    @ VSCodeServer ~/.vscode/extensions/julialang.language-julia-1.54.2/scripts/packages/VSCodeServer/src/repl.jl:193
 [12] #invokelatest#2
    @ ./essentials.jl:729 [inlined]
 [13] invokelatest(::Any)
    @ Base ./essentials.jl:726
 [14] macro expansion
    @ ~/.vscode/extensions/julialang.language-julia-1.54.2/scripts/packages/VSCodeServer/src/eval.jl:34 [inlined]
 [15] (::VSCodeServer.var"#62#63")()
    @ VSCodeServer ./task.jl:484

julia> ex = quote
       @discrete_events begin
           (a == 0) => [a~a+1, b~b-1]
           (b == 1) => [a~a-1, b~b+1]
           end
           end
quote
    #= REPL[4]:2 =#
    #= REPL[4]:2 =# @discrete_events begin
            #= REPL[4]:3 =#
            a == 0 => [a ~ a + 1, b ~ b - 1]
            #= REPL[4]:4 =#
            b == 1 => [a ~ a - 1, b ~ b + 1]
        end
end

julia> ex = MacroTools.striplines(ex)
quote
    @discrete_events begin
            a == 0 => [a ~ a + 1, b ~ b - 1]
            b == 1 => [a ~ a - 1, b ~ b + 1]
        end
end

julia> ex.args
1-element Vector{Any}:
 :(@discrete_events begin
          a == 0 => [a ~ a + 1, b ~ b - 1]
          b == 1 => [a ~ a - 1, b ~ b + 1]
      end)

julia> ex.head
:block

julia> ex.args
1-element Vector{Any}:
 :(@discrete_events begin
          a == 0 => [a ~ a + 1, b ~ b - 1]
          b == 1 => [a ~ a - 1, b ~ b + 1]
      end)

julia> ex.args[1]
:(@discrete_events begin
          a == 0 => [a ~ a + 1, b ~ b - 1]
          b == 1 => [a ~ a - 1, b ~ b + 1]
      end)

julia> ex.args[1].head
:macrocall

julia> ex.args[1].args
3-element Vector{Any}:
 Symbol("@discrete_events")
 nothing
 quote
    a == 0 => [a ~ a + 1, b ~ b - 1]
    b == 1 => [a ~ a - 1, b ~ b + 1]
end

julia> ex.args[1].args[3]
quote
    a == 0 => [a ~ a + 1, b ~ b - 1]
    b == 1 => [a ~ a - 1, b ~ b + 1]
end

julia> ex.args[1].args[3].head
:block

julia> ex.args[1].args[3].args
2-element Vector{Any}:
 :(a == 0 => [a ~ a + 1, b ~ b - 1])
 :(b == 1 => [a ~ a - 1, b ~ b + 1])
