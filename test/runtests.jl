using OpenQASM, YaoBlocksQASM, Yao
using Test

@testset "YaoBlocksQASM.jl" begin
    qasm = """
        OPENQASM 2.0;
        include "qelib1.inc";
        qreg q[3];
        creg c1[3];
        h q[0];
        CX q[1],q[2];
        cy q[1],q[0];
        cz q[0],q[2];
        x q[0];
        swap q[1],q[2];
        id q[0];
        t q[1];
        rz(0.7) q[2];
        z q[0];
        p(0.7) q[1];
        ry(0.7) q[2];
        y q[0];
        rx(0.7) q[1];
        measure q[0] -> c1[0];
        measure q[1] -> c1[1];
        measure q[2] -> c1[2];    
    """

    ast = OpenQASM.parse(qasm)
    qc = chain(
        3,
        put(1 => H),
        control(2, 3 => X),
        control(2, 1 => Y),
        control(1, 3 => Z),
        put(1 => X),
        swap(2, 3),
        put(1 => I2),
        put(2 => T),
        put(3 => Rz(0.7)),
        put(1 => Z),
        put(2 => shift(0.7)),
        put(3 => Ry(0.7)),
        put(1 => Y),
        put(2 => Rx(0.7)),
        Yao.Measure(3),
    )
    ast1 = convert_to_qasm(qc, 1)

    @test ast.version == ast1.version

    for i = 1:length(ast.prog)
        @test "$(ast.prog[i])" == "$(ast1.prog[i])"
    end
end
