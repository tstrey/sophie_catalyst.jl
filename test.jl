# testing event handling on modeling toolkit
using ModelingToolkit
using Catalyst
using DifferentialEquations
using Plots

@parameters M tinject α
@variables t N(t)
Dₜ = Differential(t)
eqs = [Dₜ(N) ~ α - N]

# at time tinject we inject M cells
injection = (t == tinject) => [N ~ N + M]

u0 = [N => 0.0]
tspan = (0.0, 20.0)
p = [α => 100.0, tinject => 10.0, M => 50]
@named osys = ODESystem(eqs, t, [N], [α, M, tinject]; discrete_events = injection)
oprob = ODEProblem(osys, u0, tspan, p)
sol = solve(oprob, Tsit5(); tstops = 10.0)
plot(sol)