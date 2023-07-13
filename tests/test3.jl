using ModelingToolkit
using Catalyst
using DifferentialEquations
using Plots

@variables t A(t) B(t)
@parameters k_on switch_time k_off

rxs = [(@reaction k_on, A(t) --> B(t)), (@reaction k_off, B(t) --> A(t))]
discrete_events = (t == switch_time) => [k_on ~ 0.0]

u0 = [A(t) => 10.0, B(t) => 0.0]
tspan = (0.0, 20.0)
p = [k_on => 100.0, switch_time => 5.0, k_off => 10.0]
@named osys = ReactionSystem(rxs, t, [A, B], [k_on, k_off, switch_time]; discrete_events)

oprob = ODEProblem(osys, u0, tspan, p)
sol = solve(oprob, Tsit5(); tstops = 10.0)

plot(sol)