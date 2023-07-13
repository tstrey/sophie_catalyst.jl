#using Optimization
#using Zygote
using DifferentialEquations
using Catalyst
#using SciMLSensitivity
using Plots

@parameters k_on k_off switch_time 
@variables t
#@species A(t) = 10.0 B(t) = 0.0
    D = Differential(t)
    eq1 = [D(A) ~ k_off * B - k_on * A]
    eq2 = [D(B) ~ k_on * A - k_off * B]
    #rxs = [(@reaction k_on, A --> B), (@reaction k_off, B --> A)]
    
    discrete_events = [t == switch_time] => [k_on ~ 0.0]
    
    u0 = [A => 10.0, B => 0.0]
    tspan = (0.0, 10.0)
    p = [k_on => 10.0, k_off => 10.0, switch_time => 2.0]
    @named rs = ReactionSystem([eq1, eq2], t, [A, B], [k_on, switch_time, k_off]; discrete_events)
    #osys = convert(ODESystem, rs)
    oprob = ODEProblem(rs, u0, tspan, p)
sol = solve(oprob, Tsit5(); tstops = 10.0)

plot(sol)

discrete_events = [t == switch_time] => [k_on ~ 0.0]
p = [k_on => 10.0, switch_time => 5.0, k_off => 10.0]

@named rs = ReactionSystem([rn],t; discrete_events) #pass in species and parameters
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