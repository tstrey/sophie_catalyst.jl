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


#just continuous_events
rn = @reaction_network rxs begin
    @variables t
    @parameters k
    @species A(t) B(t)
    @continuous_events begin
        (A < 2.0) => [B ~ 3.5]
        (A > 2.0) => [B ~ 1.0]
    end

    k, A --> B
end

#just discrete_events
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

#both
rn = @reaction_network rxs begin
    @variables t
    @parameters k
    @species A(t) B(t)
    @discrete_events begin
        (t == switch_time) => [B ~ 0.0]
    end
    @continuous_events begin
        (A < switch_time) => [B ~ 3.5]
    end
    
    k, A --> B
end



