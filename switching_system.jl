using Optimization
using Zygote
using DifferentialEquations
using Catalyst
using SciMLSensitivity
using Plots

@variables t k_on(t)=10.0
@species A(t) = 10.0 B(t) = 0.0
@parameters k_off

#try without DSL => rxs = [(@reaction $v, 0 --> A), @reaction 1.0, A --> 0]
rn = @reaction_network begin
    ($k_on, k_off), A <--> B
end

eqs = convert(ODESystem, rn)
tspan = (0.0, 20.0)
p = [k_on => 10.0, k_off => 10.0]

u0 = [A => 10.0, B => 0.0, k_on => 10.0]
discrete_events = [B/A ~ 0.95] => [k_on ~ 0.0]

@named rs = ReactionSystem([rn],t; discrete_events)
osys = convert(ODESystem, rs)
oprob = ODEProblem(rn, u0, tspan, p)

sol = solve(oprob, Tsit5())
sample_times = range(tspan[1]; stop = tspan[2], length = 100)
sample_vals = Array(sol_real(sample_times))
sample_vals .*= (1 .+ .1 * rand(Float64, size(sample_vals)) .- .05)

default(; lw = 3, framestyle = :box, size = (800, 400))
plot(sol)

plot(sol_real; legend = nothing, color = [:darkblue :darkred])
scatter!(sample_times, sample_vals'; color = [:blue :red], legend = nothing)

function optimise_p(pinit, tend)
    function loss(p, _)
        newtimes = filter(<=(tend), sample_times)
        newprob = remake(prob; tspan = (0.0, tend), p = p)
        sol = Array(solve(newprob, Rosenbrock23(); saveat = newtimes))
        loss = sum(abs2, sol .- sample_vals[:, 1:size(sol,2)])
        return loss, sol
    end

    optf = OptimizationFunction(loss, Optimization.AutoZygote()) 
    
    optprob = OptimizationProblem(optf, pinit)
    sol = solve(optprob, ADAM(0.1); maxiters = 100)

    return sol.u
end

p_estimate = optimise_p([5.0, 5.0], 10.0)

function optimise_p(pinit, tend)
    function loss(p, _)
        newtimes = filter(<=(tend), sample_times)
        newprob = remake(prob; tspan = (0.0, tend), p = p)
        sol = Array(solve(newprob, Rosenbrock23(); saveat = newtimes))
        loss = sum(abs2, sol .- sample_vals[:, 1:size(sol,2)])
        return loss, sol
    end

    optf = OptimizationFunction(loss, Optimization.AutoZygote()) 
    
    optprob = OptimizationProblem(optf, pinit)
    sol = solve(optprob, ADAM(0.1); maxiters = 100)

    return sol.u
end

p_estimate = optimise_p([5.0, 5.0], 10.0)