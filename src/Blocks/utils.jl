@connector function RealInput(;
        name, nin = 1, u_start = nothing, guess = nin > 1 ? zeros(nin) : 0.0)
    nin > 1 && @warn "For inputs greater than one, use `RealInputArray`."
    if u_start !== nothing
        Base.depwarn(
            "The keyword argument `u_start` is deprecated. Use `guess` instead.", :u_start)
        guess = u_start
    end
    if nin == 1
        @variables u(t) [
            input = true,
            description = "Inner variable in RealInput $name"
        ]
    else
        @variables u(t)[1:nin] [
            input = true,
            description = "Inner variable in RealInput $name"
        ]
    end
    ODESystem(Equation[], t, [u], []; name = name, guesses = [u => guess])
end
@doc """
    RealInput(;name, guess)

Connector with one input signal of type Real.

# Parameters:
- `guess=0`: Guess value for `u`.

# States:
- `u`: Value of the connector which is a scalar.
""" RealInput

@connector function RealInputArray(; name, nin, u_start = nothing, guess = zeros(nin))
    if u_start !== nothing
        Base.depwarn(
            "The keyword argument `u_start` is deprecated. Use `guess` instead.", :u_start)
        guess = u_start
    end
    @variables u(t)[1:nin] [
        input = true,
        description = "Inner variable in RealInputArray $name"
    ]
    ODESystem(Equation[], t, [u], []; name = name, guesses = [u => guess])
end
@doc """
    RealInputArray(;name, nin, guess)

Connector with an array of input signals of type Real.

# Parameters:
- `nin`: Number of inputs.
- `guess=zeros(nin)`: Guess value for `u`.

# States:
- `u`: Value of the connector which is an array.
""" RealInputArray

@connector function RealOutput(;
        name, nout = 1, u_start = nothing, guess = nout > 1 ? zeros(nout) : 0.0)
    nout > 1 && @warn "For outputs greater than one, use `RealOutputArray`."
    if u_start !== nothing
        Base.depwarn(
            "The keyword argument `u_start` is deprecated. Use `guess` instead.", :u_start)
        guess = u_start
    end
    if nout == 1
        @variables u(t) [
            output = true,
            description = "Inner variable in RealOutput $name"
        ]
    else
        @variables u(t)[1:nout] [
            output = true,
            description = "Inner variable in RealOutput $name"
        ]
    end
    ODESystem(Equation[], t, [u], []; name = name, guesses = [u => guess])
end
@doc """
    RealOutput(;name, guess)

Connector with one output signal of type Real.

# Parameters:
- `guess=0`: Guess value for `u`.

# States:
- `u`: Value of the connector which is a scalar.
""" RealOutput

@connector function RealOutputArray(; name, nout, u_start = nothing, guess = zeros(nout))
    if u_start !== nothing
        Base.depwarn(
            "The keyword argument `u_start` is deprecated. Use `guess` instead.", :u_start)
        guess = u_start
    end
    @variables u(t)[1:nout] [
        output = true,
        description = "Inner variable in RealOutputArray $name"
    ]
    ODESystem(Equation[], t, [u], []; name = name, guesses = [u => guess])
end
@doc """
    RealOutputArray(;name, nout, guess)

Connector with an array of output signals of type Real.

# Parameters:
- `nout`: Number of outputs.
- `guess=zeros(nout)`: Guess value for `u`.

# States:
- `u`: Value of the connector which is an array.
""" RealOutputArray

"""
    SISO(;name, u_start = 0.0, y_start = 0.0)

Single input single output (SISO) continuous system block.

# Parameters:

  - `u_start`: Initial value for the input
  - `y_start`: Initial value for the output
"""
@component function SISO(; name, u_start = 0.0, y_start = 0.0)
    pars = @parameters begin
        u_start = u_start
        y_start = y_start
    end
    vars = @variables begin
        u(t), [guess = u_start, description = "Input of SISO system"]
        y(t), [guess = y_start, description = "Output of SISO system"]
    end
    @components begin
        input = RealInput(guess = u_start)
        output = RealOutput(guess = y_start)
    end
    @equations begin
        u ~ input.u
        y ~ output.u
    return ODESystem(eqs, t, vars, pars; name = name, systems = [input, output])
end

"""
    MIMO(; name, nin = 1, nout = 1, u_start = zeros(nin), y_start = zeros(nout))

Base class for a multiple input multiple output (MIMO) continuous system block.

# Parameters:

  - `nin`: Input dimension
  - `nout`: Output dimension
  - `u_start`: Initial value for the input
  - `y_start`: Initial value for the output
"""
@component function MIMO(; name, nin = 1, nout = 1, u_start = zeros(nin),
        y_start = zeros(nout))
    @named input = RealInput(nin = nin, u_start = u_start)
    @named output = RealOutput(nout = nout, u_start = y_start)
    @variables begin
        u(t)[1:nin], [guess = u_start, description = "Input of MIMO system $name"]
        y(t)[1:nout], [guess = y_start, description = "Output of MIMO system $name"]
    end
    eqs = [
        [u[i] ~ input.u[i] for i in 1:nin]...,
        [y[i] ~ output.u[i] for i in 1:nout]...
    ]
    return ODESystem(eqs, t, vcat(u..., y...), []; name = name, systems = [input, output])
end
