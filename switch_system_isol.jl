using DifferentialEquations
using Catalyst
using Plots

@parameters k_on k_off switch_time 
@variables t
D = Differential(t)
eq1 = [D(A) ~ B - A]
eq2 = [D(B) ~ k_on * A - k_off * B]
rxs = [(@reaction k_on, A --> B), (@reaction k_off, B --> A)]
discrete_events = [t == switch_time] => [k_on ~ 0.0]

u0 = [A => 10.0, B => 0.0]
tspan = (0.0, 10.0)
p = [k_on => 10.0, k_off => 10.0, switch_time => 2.0]
@named rs = ReactionSystem([eq1, eq2, rxs], t, [A, B], [k_on, switch_time, k_off]; discrete_events)
oprob = ODEProblem(rs, u0, tspan, p)
sol = solve(oprob, Tsit5(); tstops = 10.0)

plot(sol)
