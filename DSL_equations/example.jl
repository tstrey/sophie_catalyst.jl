rn = reaction_
@parameters λ = 1.0
@variables t V(t) = 1.0
D = Differential(t)
eq = D(V) ~ λ * V
rx1 = @reaction $V, 0 --> P
rx2 = @reaction 1.0, P --> 0

D = Differential(t)

rn = @reaction_network a begin
    @parameters λ = 1.0
    @variables t V(t) = 1.0
    @equations begin
        eq = D(V) ~ λ * V
    end
    ($V, 1.0), 0 <--> P
end