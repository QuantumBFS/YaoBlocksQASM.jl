using OpenQASM

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

    for each in blocks
        push!(code.args, each)
    end
    return code
end

function toblocks(gate::OpenQASM.Types.Gate)
    name = gate.decl.name.str

    if name == "u1"
        quote
            function ($(Symbol(name)))(lambda)
                U1(lambda)
            end
        end    
    elseif name == "u2"
        quote
            function ($(Symbol(name)))(phi, lambda)
                U2(phi, lambda)
            end
        end
    elseif name == "u3"
        quote
            function ($(Symbol(name)))(theta, phi, lambda)
                U3(theta, phi, lambda)
            end
        end
    elseif name == "cx"
        quote
            function ($(Symbol(name)))(ctrl, target)
                control(ctrl, target=>X)
            end
        end
    elseif name == "id"
        quote
            function ($(Symbol(name)))()
                I2Gate()
            end
        end
    elseif name == "x"
        quote
            function ($(Symbol(name)))()
                XGate()
            end
        end
    elseif name == "y"
        quote
            function ($(Symbol(name)))()
                YGate()
            end
        end
    elseif name == "z"
        quote
            function ($(Symbol(name)))()
                ZGate()
            end
        end
    elseif name == "s"
        quote
            function ($(Symbol(name)))(theta)
                ShiftGate(theta)
            end
        end
    elseif name == "sdg"
        quote
            function ($(Symbol(name)))(theta)
                Daggered(ShiftGate(theta))
            end
        end
    elseif name == "h"
        quote
            function ($(Symbol(name)))()
                HGate()
            end
        end
    elseif name == "t"
        quote
            function ($(Symbol(name)))()
                TGate()
            end
        end
    elseif name == "tdg"
        quote
            function ($(Symbol(name)))()
                Daggered(T)
            end
        end
    elseif name == "rx"
        quote
            function ($(Symbol(name)))(theta)
                Rx(theta)
            end
        end
    elseif name == "ry"
        quote
            function ($(Symbol(name)))(theta)
                Ry(theta)
            end
        end
    elseif name == "rz"
        quote
            function ($(Symbol(name)))(theta)
                Rz(theta)
            end
        end
    elseif name == "cy"
        quote
            function ($(Symbol(name)))(ctrl, target::Pair)
                control(ctrl, target=>Y)
            end
        end
    elseif name == "cz"
        quote
            function ($(Symbol(name)))(ctrl, target::Pair)
                control(ctrl, target=>Z)
            end
        end
    elseif name == "ch"
        quote
            function ($(Symbol(name)))(ctrl, target::Pair)
                control(ctrl, target=>H)
            end
        end
    elseif name == "ccx"
        quote
            function ($(Symbol(name)))(ctrl::Tuple, target)
                control(ctrl, target=>X)
            end
        end
    elseif name == "crz"
        quote
            function ($(Symbol(name)))(ctrl, target, theta)
                control(ctrl, target=>Rz(theta))
            end
        end
    elseif name == "cu1"
        quote
            function ($(Symbol(name)))(ctrl, target, theta)
                control(ctrl, target=>PhaseGate(theta))
            end
        end
    elseif name == "cu3"
        quote
            function ($(Symbol(name)))(ctrl, target, theta, phi, lambda)
                control(ctrl, target=>U3(theta, phi, lambda))
            end
        end
    end
end
