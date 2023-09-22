using ModelingToolkit
using Catalyst 
using DifferentialEquations
using Plots
using Optimization
using OptimizationOptimJL
using Optim

@variables t 
@parameters k_on k_off α
@species A(t) B(t)

rxs = [(@reaction α*k_on, A --> B), (@reaction k_off, B --> A)]

switch_time = 2.0
discrete_events = (t == switch_time) => [k_on ~ 0.0]

tspan = (0.0, 4.0)

alpha_list = [0.1,0.2,0.3,0.4] #permittivity
results_list = []

u0 = [:A => 10.0, :B => 0.0]
p_real = [k_on => 100.0, k_off => 10.0, α => 1.0]
@named osys = ReactionSystem(rxs, t, [A, B], [k_on, k_off, α]; discrete_events)
oprob = ODEProblem(osys, u0, tspan, p_real)
sample_times = range(tspan[1]; stop = tspan[2], length = 1001) 

for alpha in alpha_list
    p_real = [k_on => 100.0, k_off => 10.0, α => alpha]
    oprobr = remake(oprob, p=p_real)
    sol_real = solve(oprobr, Tsit5(); tstops = sample_times)

    push!(results_list, sol_real(sample_times))
end


default(; lw = 3, framestyle = :box, size = (800, 400))
p = plot()
plot(p, sample_times, results_list[1][2,:])
plot!(p, sample_times, results_list[2][2,:])
plot!(p, sample_times, results_list[3][2,:])
plot!(p, sample_times, results_list[4][2,:])



#for result in results_list[2:end]
    #plot!(sample_times, result[2, :])
#end

sample_vals = []
for result in results_list
    sample_val = Array(result)
    sample_val .*= (1 .+ .1 * rand(Float64, size(sample_val)) .- .01)
    push!(sample_vals, sample_val)
end

for val in sample_vals
    scatter!(p, sample_times, val[2,:]; color = [:blue :red], legend = nothing)
end
plot(p)

function optimise_p(pinit, tend)
    function loss(p, _)
        newtimes = filter(<=(tend), sample_times)
        solutions = []
        for alpha in alpha_list
            newprob = remake(oprob; tspan = (0.0, tend), p = [k_on => p[1],k_off => p[2],α => alpha])
            sol = Array(solve(newprob, Tsit5(); saveat = newtimes, tstops = switch_time))
            push!(solutions,sol[2,:])
        end
        loss = 0
        for (idx, solution) in enumerate(solutions)
            loss += sum(abs2, p[3]*solution .- sample_vals[idx][2, 1:size(sol,2)])
        end

        return loss
    end

    optf = OptimizationFunction(loss)
    
    optprob = OptimizationProblem(optf, pinit)
    sol = solve(optprob, Optim.NelderMead())

    return sol.u
end

p_estimate = optimise_p([100.0, 10.0, 1.0], 1.5)

alpha = 0.2
newprob = remake(oprob; tspan = (0.0, 4.0), p = [k_on => p_estimate[1], k_off => p_estimate[2], α => alpha])
newsol = solve(newprob, Tsit5(); tstops = switch_time)

#plot(sol_real; legend = nothing, color = [:darkblue :darkred])
scatter!(sample_times, sample_vals; color = [:darkblue :darkred], legend = nothing)

default(; lw = 3, framestyle = :box, size = (800, 400))
#plot the sample noise and also index and add the t timespan
plot!(newsol[2,:]; legend = nothing, color = [:blue :red], linestyle = :dash, tspan= (0.0, 4.0))