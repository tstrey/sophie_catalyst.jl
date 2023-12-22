julia> ex = quote
       @discrete_events begin
           (a == 0) => [a~a+1, b~b-1]
           (b == 1) => [a~a-1, b~b+1]
           end
           end
quote
    #= REPL[4]:2 =#
    #= REPL[4]:2 =# @discrete_events begin
            #= REPL[4]:3 =#
            a == 0 => [a ~ a + 1, b ~ b - 1]
            #= REPL[4]:4 =#
            b == 1 => [a ~ a - 1, b ~ b + 1]
        end
end

julia> ex = MacroTools.striplines(ex)
quote
    @discrete_events begin
            a == 0 => [a ~ a + 1, b ~ b - 1]
            b == 1 => [a ~ a - 1, b ~ b + 1]
        end
end

julia> ex.args
1-element Vector{Any}:
 :(@discrete_events begin
          a == 0 => [a ~ a + 1, b ~ b - 1]
          b == 1 => [a ~ a - 1, b ~ b + 1]
      end)

julia> ex.head
:block

julia> ex.args
1-element Vector{Any}:
 :(@discrete_events begin
          a == 0 => [a ~ a + 1, b ~ b - 1]
          b == 1 => [a ~ a - 1, b ~ b + 1]
      end)

julia> ex.args[1]
:(@discrete_events begin
          a == 0 => [a ~ a + 1, b ~ b - 1]
          b == 1 => [a ~ a - 1, b ~ b + 1]
      end)

julia> ex.args[1].head
:macrocall

julia> ex.args[1].args
3-element Vector{Any}:
 Symbol("@discrete_events")
 nothing
 quote
    a == 0 => [a ~ a + 1, b ~ b - 1]
    b == 1 => [a ~ a - 1, b ~ b + 1]
end

julia> ex.args[1].args[3]
quote
    a == 0 => [a ~ a + 1, b ~ b - 1]
    b == 1 => [a ~ a - 1, b ~ b + 1]
end

julia> ex.args[1].args[3].head
:block

julia> ex.args[1].args[3].args
2-element Vector{Any}:
 :(a == 0 => [a ~ a + 1, b ~ b - 1])
 :(b == 1 => [a ~ a - 1, b ~ b + 1])
