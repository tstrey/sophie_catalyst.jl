function transform(ex)
    lhs = ex.args[2]
    rhs = ex.args[3]
    equation_expr = (Num[lhs] => Equation[rhs])
end

if expr.head == :call && length(expr.args) == 3 && expr.args[2] == :(==)
    symbol = expr.args[1]
    value = expr.args[3]
return Num(symbol, value)


Equation[ex.args[3].args[2].args[2] ~ ex.args[3].args[2].args[3]]

