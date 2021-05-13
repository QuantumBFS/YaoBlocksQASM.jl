```@meta
CurrentModule = YaoBlocksQASM
```

# YaoBlocksQASM

Documentation for [YaoBlocksQASM](https://github.com/Sov-trotter/YaoBlocksQASM.jl).

## Usage

1) Create a circuit

```julia
using Yao, YaoBlocksQobj
qc = chain(3, put(1=>X), put(2=>Y) ,put(3=>Z), 
                put(2=>T), swap(1,2), put(3=>Ry(0.7)), 
                control(2, 1=>Y), control(3, 2=>Z))
```

2) Convert it to OpenQASM compatible program

```julia
ast = yaotoqasm(qc, 1)
```

## API References
```@autodocs
Modules = [YaoBlocksQASM]
```
