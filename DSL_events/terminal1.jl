julia> using Catalyst
[ Info: Precompiling Catalyst [479239e8-5488-4da2-87a7-35f2df7eef83]

julia> using MacroTools

julia> @expand rn = @reaction_network a begin
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
:(rn = begin
          #= /Users/lmp/Documents/GitHub/Catalyst.jl/src/reaction_network.jl:430 =#
          begin
              #= /Users/lmp/Documents/GitHub/Catalyst.jl/src/reaction_network.jl:354 =#
              buffalo = begin
                      seal = (ModelingToolkit.toparam)((Symbolics.wrap)((SymbolicUtils.setmetadata)((Sym){Real}(:k), Symbolics.VariableSource, (:parameters, :k))))
                      [seal]
                  end
              #= /Users/lmp/Documents/GitHub/Catalyst.jl/src/reaction_network.jl:355 =#
              rook = Catalyst.reduce(Catalyst.vcat, (Catalyst.Symbolics).scalarize(buffalo))
          end
          #= /Users/lmp/Documents/GitHub/Catalyst.jl/src/reaction_network.jl:431 =#
          begin
              swan = (identity)((Symbolics.wrap)((SymbolicUtils.setmetadata)((Sym){Real}(:t), Symbolics.VariableSource, (:variables, :t))))
              [swan]
          end
          #= /Users/lmp/Documents/GitHub/Catalyst.jl/src/reaction_network.jl:432 =#
          begin
              #= /Users/lmp/Documents/GitHub/Catalyst.jl/src/reaction_network.jl:354 =#
              pheasant = begin
                      pelican = (identity)((Symbolics.wrap)((SymbolicUtils.setmetadata)(((Sym){(SymbolicUtils.FnType){Catalyst.NTuple{1, Catalyst.Any}, Real}}(:V))((Symbolics.value)(swan)), Symbolics.VariableSource, (:variables, :V))))
                      [pelican]
                  end
              #= /Users/lmp/Documents/GitHub/Catalyst.jl/src/reaction_network.jl:355 =#
              owl = Catalyst.reduce(Catalyst.vcat, (Catalyst.Symbolics).scalarize(pheasant))
          end
          #= /Users/lmp/Documents/GitHub/Catalyst.jl/src/reaction_network.jl:433 =#
          begin
              #= /Users/lmp/Documents/GitHub/Catalyst.jl/src/reaction_network.jl:354 =#
              komodo = begin
                      mole = (identity)((Symbolics.wrap)((SymbolicUtils.setmetadata)(((Sym){(SymbolicUtils.FnType){Catalyst.NTuple{1, Catalyst.Any}, Real}}(:B))((Symbolics.value)(swan)), Symbolics.VariableSource, (:variables, :B))))
                      goat = (identity)((Symbolics.wrap)((SymbolicUtils.setmetadata)(((Sym){(SymbolicUtils.FnType){Catalyst.NTuple{1, Catalyst.Any}, Real}}(:C))((Symbolics.value)(swan)), Symbolics.VariableSource, (:variables, :C))))
                      mole = (Catalyst.ModelingToolkit).wrap(Catalyst.setmetadata((Catalyst.ModelingToolkit).value(mole), (Catalyst.Catalyst).VariableSpecies, true))
                      goat = (Catalyst.ModelingToolkit).wrap(Catalyst.setmetadata((Catalyst.ModelingToolkit).value(goat), (Catalyst.Catalyst).VariableSpecies, true))
                      begin
                          #= /Users/lmp/Documents/GitHub/Catalyst.jl/src/reaction_network.jl:147 =#
                          Catalyst.all(!((Catalyst.Catalyst).isconstant) ∘ (Catalyst.ModelingToolkit).value, [mole, goat]) || Catalyst.throw(Catalyst.ArgumentError("isconstantspecies metadata can only be used with parameters."))
                      end
                      [mole, goat]
                  end
              #= /Users/lmp/Documents/GitHub/Catalyst.jl/src/reaction_network.jl:355 =#
              lion = Catalyst.reduce(Catalyst.vcat, (Catalyst.Symbolics).scalarize(komodo))
          end
          #= /Users/lmp/Documents/GitHub/Catalyst.jl/src/reaction_network.jl:435 =#
          (Catalyst.Catalyst).make_ReactionSystem_internal((Catalyst.Catalyst).CatalystEqType[Catalyst.Reaction(seal, [goat], [mole], [1], [1], only_use_rate = false)], swan, Catalyst.union(lion, owl), rook; name = :a, spatial_ivs = nothing, discrete_events = Expr[:(@discrete_events begin
          a == 0 => [a ~ a + 1, b ~ b - 1]
          b == 1 => [a ~ a - 1, b ~ b + 1]
      end)], continuous_events = nothing)
      end)

julia> @expand @discrete_events begin
               a == 0 => [a ~ a+1, b ~ b-1]
               b == 1 => [a ~ a-1, b ~ b+1]
           end
ERROR: UndefVarError: @discrete_events not defined

julia> switch_time = 2.0
2.0

julia> @variables t
1-element Vector{Num}:
 t

julia> @parameters k_on k_off α
3-element Vector{Num}:
 k_on
  k_off
    α

julia> @species A(t) B(t)
2-element Vector{Num}:
 A(t)
 B(t)

julia> rxs = [(@reaction k_on, A --> B), (@reaction k_off, B --> A)]
2-element VectorWARNING: both Symbolics and ModelingToolkit export "infimum"; uses of it in module Catalyst must be qualified
#WARNING: both Symbolics and ModelingToolkit export "supremum"; uses of it in module Catalyst must be qualified
{Reaction{Any, Int64}}:
 k_on, A --> B
 k_off, B --> A

julia> discrete_events = (t == switch_time) => [k_on ~ 0.0]
t == 2.0 => Equation[k_on ~ 0.0]

julia> u0 = [:A => 10.0, :B => 0.0]
2-element Vector{Pair{Symbol, Float64}}:
 :A => 10.0
 :B => 0.0

julia> tspan = (0.0, 4.0)
(0.0, 4.0)

julia> p_real = [k_on => 100.0, k_off => 10.0]
2-element Vector{Pair{Num, Float64}}:
  k_on => 100.0
 k_off => 10.0

julia> @named osys = ReactionSystem(rxs, t, [A, B], [k_on, k_off]; discrete_events)
Model osys
States (2):
  A(t)
  B(t)
Parameters (2):
  k_on
  k_off

julia> @expand @named osys = ReactionSystem(rxs, t, [A,B], [k_on, k_off]; discrete_events)
:(osys = begin
          #= /Users/lmp/.julia/packages/ModelingToolkit/BsHty/src/systems/abstractsystem.jl:998 =#
          buffalo = ReactionSystem isa DataType && ReactionSystem <: ModelingToolkit.AbstractSystem
          #= /Users/lmp/.julia/packages/ModelingToolkit/BsHty/src/systems/abstractsystem.jl:999 =#
          ReactionSystem(rxs, t, [A, B], [k_on, k_off]; name = :osys, discrete_events = if buffalo
                      discrete_events
                  else
                      (ModelingToolkit.default_to_parentscope)(discrete_events)
                  end)
      end)

julia> discrete_events
t == 2.0 => Equation[k_on ~ 0.0]

julia> @expand discrete_events
:discrete_events

julia> @expand discrete_events = (t == switch_time) => [k_on ~ 0.0]
:(discrete_events = t == switch_time => [k_on ~ 0.0])

julia> 