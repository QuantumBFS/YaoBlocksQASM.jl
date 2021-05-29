macro qasm_str(s::String)
    s = Meta.parse("\"\"\"\n$s\"\"\"")
    s isa String && return esc(qasm_str_m(__module__, __source__, s))
end

function qasm_str_m(m::Module, lino::LineNumberNode, src::String)
    ast = OpenQASM.parse(src)
    return toblocks(m, lino, ast)
end

function toblocks(m::Module, lino::LineNumberNode, ast::MainProgram)
    code = Expr(:block)
    blocks = []
    for stmt in ast.prog
        if stmt isa Types.Gate
            push!(blocks, toblocks(stmt))
        end
    end
    return code
end

function toblocks(gate::OpenQASM.Types.Gate)
    name = stmt.decl.name.str

    if name == "u1"
        U1(params...)
    # elseif name == "u2"
    #     if isapprox(params, [0, π])
    #         H
    #     else
    #         U2(params...)
    #     end
    elseif name == "u3"
        quote
            function toblocks(stmt.decl::OpenQASM.Types.GateDecl)
                # put(locs, Some block)
            end
        end
    #     if isapprox(params[2], -π / 2) && isapprox(params[3], π / 2)
    #         Rx(params[1])
    #     elseif params[2] == 0 && params[3] == 0
    #         Ry(params[1])
    #     else
    #         U3(params...)
    #     end
    # elseif name == "id"
    #     I2
    # elseif name == "x"
    #     X
    # elseif name == "y"
    #     Y
    # elseif name == "z"
    #     Z
    # elseif name == "t"
    #     T
    # elseif name == "swap"
    #     SWAP
    # else
    #     error("gate type `$name` not defined!")
    end
end
