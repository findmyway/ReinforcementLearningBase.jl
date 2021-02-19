# inspired by
# - https://github.com/dalum/InlineExports.jl/blob/master/src/InlineExports.jl
# - https://github.com/QuantumBFS/YaoBase.jl/blob/master/src/utils/interface.jl

using MLStyle

macro api(ex)
    handle(__module__, __source__, ex)
end

function handle(__module__::Module, __source__::LineNumberNode, expr)
    name = extract_name(expr)
    expr = add_missing_body(expr)
    expr_fw = forward_wrapper(expr)
    quote
        export $(esc(name))
        Core.@__doc__ $(esc(expr))
        $(esc(expr_fw)) === nothing || Core.@__doc__ $(esc(expr_fw))
    end
end

function add_missing_body(expr)
    @match expr begin
        Expr(:call, args...) => Expr(
            :function,
            expr,
            :(error("methods not implemented!!!"))
            )
        _ => expr
    end
end

function extract_name(e)
    # dump(e)
    @match e begin
        ::Symbol                        => e
        Expr(:(=), fn, body, _...)      => extract_name(fn)
        Expr(:call, fn, body, _...)     => extract_name(fn)
        Expr(:function, fn, body, _...) => extract_name(fn)
        Expr(:(::), fn, ft, _...)       => extract_name(ft)  # !!! not fn here
        Expr(:struct, _, name, _...)    => extract_name(name)
        Expr(:(<:), sub, super, _...)   => extract_name(sub)
        Expr(:curly, t, ps, _...)       => extract_name(t)
        Expr(:abstract, name, _...)     => extract_name(name)
        Expr(:const, assn, _...)        => extract_name(assn)
        Expr(:where, sig, _...)         => extract_name(sig)
        Expr(expr_type,  _...)          => error("Can't extract name from ",
                                                expr_type, " expression:\n",
                                                "    $e\n")
    end
end

function forward_wrapper(e)
    # dump(e)
    if _has_AbstractEnv(e)
        @match e begin
            Expr(:function, fn, body) => Expr(
                :function,
                _replace(fn),
                _forward(fn)
            )
            Expr(:(=), fn, body) => Expr(
                :function,
                _replace(fn),
                _forward(fn)
            )
        end
    else
        nothing
    end
end

function _has_AbstractEnv(e)
    # dump(e)
    @match e begin
        Expr(:function, fn, body) => _has_AbstractEnv(fn)
        Expr(:(=), fn, body) => _has_AbstractEnv(fn)
        Expr(:where, sig, guard) => _has_AbstractEnv(sig) || _has_AbstractEnv(guard)
        Expr(:call, args...) => any(_has_AbstractEnv.(args))
        Expr(:(::), _, t) => _has_AbstractEnv(t)
        Expr(:(<:), _, t) => _has_AbstractEnv(t)
        Expr(:curly, :Type, t) => _has_AbstractEnv(t)
        Expr(:(<:), :AbstractEnv) => true
        :AbstractEnv => true
        ::Symbol => false
    end
end

function _replace(e)
    # TODO
    e
end

function _forward(e)
    # TODO
    e
end