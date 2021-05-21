using OpenQASM.Types
using OpenQASM.RBNF: Token

#todo support custom yao gates to qasm 

"""
    convert_to_qasm(qc, ncreg)

Parses an `AbstractBlock` into code based on the `OpenQASM` spec

- `qc`: A `ChainBlock`(circuit that is to be run).
- `ncreg` (optional) : Number of classical registers
While performing operations like measuring, one can input desired number of classical regs(each size equal to number of qubits). Defaults to 1.  
"""
function convert_to_qasm(qc::AbstractBlock{N}, ncreg::Int = 1) where {N}
    prog = generate_prog(qc, ncreg)
    MainProgram(v"2", prog)
end

"""
    generate_prog(qc)

Parses the YaoIR into a list of `QASM` instructions

- `qc`: A `ChainBlock`(circuit that is to be run).
"""
function generate_prog(qc::AbstractBlock{N}, ncreg::Int) where {N}
    prog = []
    generate_defs(prog, N, ncreg)
    generate_prog!(prog, basicstyle(qc), [0:N-1...], Int[])
    return prog
end

function generate_defs(prog, nq::Int, ncreg::Int)
    qregs = RegDecl(Token{:reserved}("qreg"), Token{:type}("q"), Token{:int}("$nq"))
    cregs = collect(
        RegDecl(Token{:reserved}("creg"), Token{:type}("c$i"), Token{:int}("$nq")) for
        i = 1:ncreg
    )
    push!(prog, Include(Bit("\"qelib1.inc\"")), qregs, cregs...)
end

function generate_prog!(prog, qc_simpl::ChainBlock, locs, controls)
    for block in subblocks(qc_simpl)
        generate_prog!(prog, block, locs, controls)
    end
end

function generate_prog!(prog, blk::PutBlock{N,M}, locs, controls) where {N,M}
    generate_prog!(prog, blk.content, sublocs(blk.locs, locs), controls)
end

function generate_prog!(prog, blk::ControlBlock{N,GT,C}, locs, controls) where {N,GT,C}
    any(==(0), blk.ctrl_config) && error("Inverse Control used in Control gate context")
    generate_prog!(
        prog,
        blk.content,
        sublocs(blk.locs, locs),
        [controls..., sublocs(blk.ctrl_locs, locs)...],
    )
end

function generate_prog!(prog, m::YaoBlocks.Measure{N}, locs, controls) where {N}
    mlocs = sublocs(m.locations isa AllLocs ? [1:N...] : [m.locations...], locs)
    (m.operator isa ComputationalBasis) || error("measuring an operator is not supported")
    (length(controls) == 0) || error("controlled measure is not supported")

    # can be improved
    for i in mlocs
        cargs = Bit("c1", i)
        qargs = Bit("q", i)
        inst = Types.Measure(qargs, cargs)
        push!(prog, inst)
    end
end

for (GT, NAME, MAXC) in [
    (:XGate, "x", 2),
    (:YGate, "y", 2),
    (:ZGate, "z", 2),
    (:I2Gate, "id", 0),
    (:TGate, "t", 0),
    (:SWAPGate, "swap", 0),
]
    @eval function generate_prog!(prog, ::$GT, locs, controls)
        if length(controls) <= $MAXC
            # push!(prog, )
            name = "c"^(length(controls)) * $NAME
            if name != "cx" && name != "swap"
                cargs = [] #empty for now
                qargs =
                    isempty(controls) ? [Bit("q", locs...)] :
                    [Bit("q", controls...), Bit("q", locs...)]
                inst = Instruction(name, cargs, qargs)
            elseif name == "swap"
                cargs = [] #empty for now
                qargs = [Bit("q", i) for i in locs]
                inst = Instruction(name, cargs, qargs)
            else
                inst = CXGate(Bit("q", controls...), Bit("q", locs...))
            end
            push!(prog, inst)
        else
            error("too many control bits!")
        end
    end
end

for (GT, NAME, PARAMS, MAXC) in [
    (:(RotationGate{1,T,XGate} where {T}), "rx", :(b.theta), 0),
    (:(RotationGate{1,T,YGate} where {T}), "ry", :(b.theta), 0),
    (:(RotationGate{1,T,ZGate} where {T}), "rz", :(b.theta), 0),
    (:(ShiftGate), "p", :(b.theta), 1),
    (:(HGate), "h", :(nothing), 0),
]
    @eval function generate_prog!(prog, b::$GT, locs, controls)
        if length(controls) <= $MAXC
            name = "c"^(length(controls)) * $NAME
            if $PARAMS === nothing
                cargs = []
                qargs = [Bit("q", locs...)]
            else
                params = $PARAMS
                cargs = [Token{:float64}("$params")]
                qargs =
                    isempty(controls) ? [Bit("q", locs...)] :
                    [Bit("q", controls...), Bit("q", locs...)]
            end
            push!(prog, Instruction(name, cargs, qargs))
        else
            error("too many control bits! got $controls (length > $($(MAXC)))")
        end
    end
end

sublocs(subs, locs) = [locs[i] for i in subs]

function basicstyle(blk::AbstractBlock)
    YaoBlocks.Optimise.simplify(blk, rules = [YaoBlocks.Optimise.to_basictypes])
end
