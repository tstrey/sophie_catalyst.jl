using ModelingToolkit
using Catalyst
using DifferentialEquations
using Plots
using Optimization
using Zygote
using SciMLSensitivity
using OptimizationOptimisers
using OptimizationOptimJL
using Optim

switch_time = 2.0 

@variables t 
@parameters k_on k_off
@species A(t) B(t)

rxs = [(@reaction k_on, A --> B), (@reaction k_off, B --> A)]
discrete_events = (t == switch_time) => [k_on ~ 0.0]

u0 = [:A => 10.0, :B => 0.0]
tspan = (0.0, 4.0)
p_real = [k_on => 100.0, k_off => 10.0]
@named osys = ReactionSystem(rxs, t, [A, B], [k_on, k_off]; discrete_events)

sample_times = range(tspan[1]; stop = tspan[2], length = 101) 
oprob = ODEProblem(osys, u0, tspan, p_real)
sol_real = solve(oprob, Tsit5(); tstops = sample_times)
sample_vals = Array(sol_real(sample_times))
sample_vals .*= (1 .+ .1 * rand(Float64, size(sample_vals)) .- .05)

default(; lw = 3, framestyle = :box, size = (800, 400))
plot(sol_real; legend = nothing, color = [:darkblue :darkred])
scatter!(sample_times, sample_vals'; color = [:blue :red], legend = nothing)

function optimise_p(pinit, tend)
    function loss(p, _)
        newtimes = filter(<=(tend), sample_times)
        newprob = remake(oprob; tspan = (0.0, tend), p = p)
        sol = Array(solve(newprob, Tsit5(); saveat = newtimes))
        loss = sum(abs2, sol .- sample_vals[:, 1:size(sol,2)])
        return loss, sol
    end

    #optf = OptimizationFunction(loss, Optimization.AutoZygote()) #not necessary for gradient free optimizatoin
    
    #optprob = OptimizationProblem(optf, pinit)
    sol = solve(optprob, Optim.NelderMead(0.1); maxiters = 100) # instead of Adam use neldermead

    return sol.u
end

p_estimate = optimise_p([100.0, 10.0], 2.0)

newprob = remake(oprob; tspan = (2.0, 5.0), p = p_estimate)
newsol = solve(newprob, Tsit5(); tstops = switch_time)

plot(sol_real; legend = nothing, color = [:darkblue :darkred])
scatter!(sample_times, sample_vals'; color = [:blue :red], legend = nothing)

plot!(newsol; legend = nothing, color = [:darkblue :darkred])