import Pkg
Pkg.activate(".")
import Pkg; Pkg.add("Catalyst")
using Catalyst

brusselator = @reaction_network begin
    A, ∅ → X
    1, 2X + Y → 3X
    B, X → Y
    1, X → ∅
end
p_real = [:A => 1., :B => 2.]


using OrdinaryDiffEq, Optimization, OptimizationOptimJL, OptimizationOptimisers, Zygote, DifferentialEquations, SciMLSensitivity
#using DiffEqFlux, Flux


osys = convert(ODESystem, brusselator)

u0 = [:X => 1.0, :Y => 1.0]
tspan = (0.0, 30.0)

sample_times = range(tspan[1]; stop = tspan[2], length = 100)
prob = ODEProblem(brusselator, u0, tspan, p_real)
sol_real = solve(prob, Rosenbrock23(); tstops = sample_times)
sample_vals = Array(sol_real(sample_times))
sample_vals .*= (1 .+ .1 * rand(Float64, size(sample_vals)) .- .05)

using Plots
default(; lw = 3, framestyle = :box, size = (800, 400))

plot(sol_real; legend = nothing, color = [:darkblue :darkred])
scatter!(sample_times, sample_vals'; color = [:blue :red], legend = nothing)

Pkg.add("BenchmarkTools")

using BenchmarkTools

function optimise_p(pinit, tend)
    function loss(p, _)
        newtimes = filter(<=(tend), sample_times)
        newprob = remake(prob; tspan = (0.0, tend), p = p)
        sol = Array(solve(newprob, Rosenbrock23(); saveat = newtimes))
        loss = sum(abs2, sol .- sample_vals[:, 1:size(sol,2)])
        return loss, sol
    end

    # optimize for the parameters that minimize the loss
    optf = OptimizationFunction(loss, Optimization.AutoZygote()) 
    
    # changed from AutoZygote() to AutoForwardDiff()
    optprob = OptimizationProblem(optf, pinit)
    sol = solve(optprob, ADAM(0.1); maxiters = 100)

    # return the parameters we found
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

    # optimize for the parameters that minimize the loss
    optf = OptimizationFunction(loss, Optimization.AutoForwardDiff()) 
    
    # changed from AutoZygote() to AutoForwardDiff()
    optprob = OptimizationProblem(optf, pinit)
    sol = solve(optprob, ADAM(0.1); maxiters = 100)

    # return the parameters we found
    return sol.u
end

p_estimate = optimise_p([5.0, 5.0], 10.0)

newprob = remake(prob; tspan = (0., 10.), p = p_estimate)
sol_estimate = solve(newprob, Rosenbrock23())
plot(sol_real; color = [:blue :red], label = ["X real" "Y real"], linealpha = 0.2)

scatter!(sample_times, sample_vals'; color = [:blue :red],
         label = ["Samples of X" "Samples of Y"], alpha = 0.4)
plot!(sol_estimate; color = [:darkblue :darkred], linestyle = :dash,
    label = ["X estimated" "Y estimated"], xlimit = tspan)

p_estimate = optimise_p(p_estimate, 20.)
newprob = remake(prob; tspan = (0., 20.), p = p_estimate)
sol_estimate = solve(newprob, Rosenbrock23())
plot(sol_real; color = [:blue :red], label = ["X real" "Y real"], linealpha = 0.2)
scatter!(sample_times, sample_vals'; color = [:blue :red],
         label = ["Samples of X" "Samples of Y"], alpha = 0.4)
plot!(sol_estimate; color = [:darkblue :darkred], linestyle = :dash,
                    label = ["X estimated" "Y estimated"], xlimit = tspan)

p_estimate = optimise_p(p_estimate, 30.0)

newprob = remake(prob; tspan = (0., 30.0), p = p_estimate)
sol_estimate = solve(newprob, Rosenbrock23())
plot(sol_real; color = [:blue :red], label = ["X real" "Y real"], linealpha = 0.2)
scatter!(sample_times, sample_vals'; color = [:blue :red],
        label = ["Samples of X" "Samples of Y"], alpha = 0.4)
plot!(sol_estimate; color = [:darkblue :darkred], linestyle = :dash,
                    label = ["X estimated" "Y estimated"], xlimit = tspan)

p_estimate


