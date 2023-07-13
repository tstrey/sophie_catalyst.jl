using Catalyst
using DifferentialEquations

@variables t V(t)=1.0
    D = Differential(t)
    eqs = [D(V) ~ V]
    discrete_events = [1.0 => [V ~ 1.0]]
    rxs = [(@reaction $V, 0 --> A), (@reaction 1.0, A --> 0)]
    @named rs = ReactionSystem([rxs, eqs], t; discrete_events)
    osys = convert(ODESystem, rs)
    oprob = ODEProblem(rs, ModelingToolkit.missing_variable_defaults(rs), (0.0, 20.0))
sol = solve(oprob, Tsit5())