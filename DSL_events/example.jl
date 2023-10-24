rn = @reaction_network a begin
    @parameters k
    @variables V(t)
    @species B(t) C(t)
    @discrete_events begin
        a == 0 => [a ~ a+1, b ~ b-1]
        b == 1 => [a ~ a-1, b ~ b+1]
    end
    k, C --> B
end