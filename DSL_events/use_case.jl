using Catalyst

switch_time = 2.0

rn = @reaction_network rxs begin
    @variables t
    @parameters k
    @species A(t) B(t)
    
    k, A --> B

    @discrete_events begin
        (t == switch_time) => [B ~ 0.0]
    end
    @continuous_events begin
        (A < switch_time) => [B ~ 3.5]
    end
end

rn = @reaction_network rxs begin
    @variables t
    @parameters k
    @species A(t) B(t)
    
    k, A --> B
end

@discrete_events begin
    (t == switch_time) => [B ~ 0.0]
end
@continuous_events begin
    (A < switch_time) => [B ~ 3.5]
end


