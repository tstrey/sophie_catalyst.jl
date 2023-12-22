#discrete_events
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

rn = @reaction_network a begin
    @parameters k_on k_off
    @variables t
    @species A(t) B(t)
    @discrete_events begin
        t == 2.0 => [k_on ~ 0.0]
        t == 0.0 => [k_off ~ 1.0]
    end
    (k_on, k_off), A <--> B
end

@variables t 
@parameters k_on k_off
@species A(t) B(t)

rxs = [(@reaction k_on, A --> B), (@reaction k_off, B --> A)]
discrete_events = (t == switch_time) => [k_on ~ 0.0]

#continuous_events
rn = @reaction_network a begin
    @parameters k
    @variables V(t)
    @species B(t) C(t)
    @continuous_events begin
        a < 0.0 => [a ~ a+1, b ~ b-1]
    end
    k, C --> B
end

function extract_discrete_events(opts)
    events = []
    if haskey(opts, :discrete_events)
        ex = quote 
            $(opts[:discrete_events])
        end
        ex1 = MacroTools.striplines(ex)
        ex2 = (ex1.args[1].args[end].args)
        push!(events, ex2)
    end

    if length(events)==0
        return nothing
    else
        return events
    end
end

# When the user have used the @continuous_events option, extract continuous events
function extract_continuous_events(opts)
    events = Vector{Equation}[]
    if haskey(opts, :continuous_event)
        push!(events, opts[:continuous_events])
    end
    if length(events)==0
        return nothing
    else
        return events
    end
end