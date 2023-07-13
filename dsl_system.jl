using Catalyst
using DifferentialEquations
using Plots
using Latexify

rn = @reaction_network begin
    (k_on, k_off), a <--> b
end

osys = convert(ODESystem, rn)
latexify(osys)
