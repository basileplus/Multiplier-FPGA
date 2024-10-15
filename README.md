# 4-bit VHDL Multiplier Project

This repository contains the VHDL implementation of a 4-bit multiplier and its components. The project is structured in a hierarchical manner, with the multiplier using a 4-bit full adder, which in turn uses a 1-bit adder.

It decomposes the multiplication operation into 4 additions
```math
A\times B = a_{3} a_{2} a_{1} a_{0} \times b_{3} b_{2} b_{1} b_{0} \Leftrightarrow 
\begin{align} \hline
& & & & & a_{0}b_{3} & a_{0}b_{2} & a_{0}b_{1} & a_{0}b_{0} \\
 & & & + & a_{1}b_{3} &  a_{1}b_{2} & a_{1}b_{1} & a_{1}b_{0} & 0 \\
 & & + &  a_{2}b_{3} & a_{2}b_{2} & a_{2}b_{1} & a_{2}b_{0} & 0 & 0 \\ 
 & + & a_{3}b_{3} & a_{3}b_{2} & a_{3}b_{1} & a_{3}b_{0} & 0 & 0 & 0 \\
& \text{\small carry }\swarrow  &   \downarrow & \downarrow & \downarrow & \downarrow & \downarrow & \downarrow & \downarrow \\
 & p_{7} & p_{6} & p_{5} & p_{4} & p_{3} & p_{2} & p_{1} & p_{0} \\

\end{align}
```


The overall architecture of the multiplier is specified in the following diagram

```mermaid
flowchart TD
    subgraph Entrées
        A[A 4 bits]
        B[B 4 bits]
        Start
        Reset
        Clk
    end

    subgraph "Registres et signaux"
        Areg[Areg 4 bits]
        Breg[Breg 4 bits]
        PP[PP 4 bits]
        Rin[Rin 5 bits]
        Rout[Rout 8 bits]
        cpt[cpt 2 bits]
    end

    subgraph "Machine à états"
        FSM{{"Machine à états
        (Attente, Chargement, 
        Addition, Decalage, raz)"}}
    end

    subgraph "Opérations"
        AND1["AND"]
        FA["FA4bits (Additionneur 4 bits)"]
        Shift["Décalage"]
    end

    subgraph Sorties
        Res[Res 8 bits]
        Done
    end

    A --> Areg
    B --> Breg
    Start --> FSM
    Reset --> FSM
    Clk --> FSM

    Areg -->|"Areg(0)"| AND1
    Breg --> AND1
    AND1 -->|"PP = Areg(0) AND Breg"| PP

    PP --> FA
    Rout -->|"Rout(6 downto 3)"| FA
    FA -->|"S"| Rin
    FA -->|"Cout"| Rin

    FSM -->|"Contrôle"| Areg
    FSM -->|"Contrôle"| Breg
    FSM -->|"Contrôle"| Rout
    FSM -->|"Contrôle"| cpt

    Areg --> Shift
    Rout --> Shift
    Shift -->|"Areg <= Areg(0) & Areg(3 downto 1)"| Areg
    Shift -->|"Rout <= Rout(0) & Rout(7 downto 1)"| Rout

    Rin -->|"Rout(7 downto 3) <= Rin"| Rout
    Rin -->|"Res <= Rin(4 downto 0) & Rout(2 downto 0)"| Res

    FSM --> Done

    style FSM fill:#f9f,stroke:#333,stroke-width:4px
    style FA fill:#bfb,stroke:#333,stroke-width:2px
    style Shift fill:#bbf,stroke:#333,stroke-width:2px
    style AND1 fill:#fbb,stroke:#333,stroke-width:2px

```

## Components

### 1. 4-bit Multiplier

The 4-bit multiplier is the top-level component that performs multiplication of two 4-bit numbers.

```mermaid
stateDiagram-v2
    [*] --> Attente
    Attente --> Chargement : Start = '1'
    Attente --> Attente : Start = '0'
    Chargement --> Addition
    Addition --> Decalage
    Decalage --> Addition : cpt != "10"
    Decalage --> raz : cpt = "10"
    raz --> Attente : Start = '0'
    raz --> raz : Start = '1'
    
    note right of Attente : cpt <= "00"
    note right of Chargement : Areg <= A, Breg <= B, Done <= '0', Rout <= (others => '0')
    note right of Addition : Rout(7 downto 3) <= Rin
    note right of Decalage : Areg <= Areg(0) & Areg(3 downto 1), Rout <= Rout(0) & Rout(7 downto 1), cpt <= cpt + 1
    note right of raz : Done <= '1' Res, <= Rin(4 downto 0) & Rout(2 downto 0)
```

#### Functionality

- Implements the shift-and-add algorithm for multiplication.
- Uses a finite state machine (FSM) to control the multiplication process.
- Utilizes a 4-bit full adder for partial product addition.

#### Implementation Details

- **Data Flow**: 
  - Partial product (PP) calculation using bitwise AND operations.
  - Result assembly from intermediate results.
- **Instantiation**: 
  - Instantiates the 4-bit Full Adder (FA4bits) for adding partial products.
- **Process**: 
  - A single process implements the FSM, controlling the multiplication steps.
  - The FSM has states: Attente (Wait), Chargement (Load), Addition, Decalage (Shift), and raz (Reset).

#### Signals

- Input: A, B (4-bit operands), Start, Reset, Clk
- Output: Res (8-bit result), Done
- Internal: Areg, Breg, PP, Rin, Rout, cpt (counter)

### 2. 4-bit Full Adder (FA4bits)

The 4-bit full adder is used within the multiplier to add partial products.

```mermaid
graph TD
    A0["A(0)"] --> inst1[1-bit Adder inst1]
    B0["B(0)"] --> inst1
    C0["c0"] --> inst1
    inst1 --> S0["S(0)"]
    inst1 --> C1["c1"]
    
    A1["A(1)"] --> inst2[1-bit Adder inst2]
    B1["B(1)"] --> inst2
    C1 --> inst2
    inst2 --> S1["S(1)"]
    inst2 --> C2["c2"]
    
    A2["A(2)"] --> inst3[1-bit Adder inst3]
    B2["B(2)"] --> inst3
    C2 --> inst3
    inst3 --> S2["S(2)"]
    inst3 --> C3["c3"]
    
    A3["A(3)"] --> inst4[1-bit Adder inst4]
    B3["B(3)"] --> inst4
    C3 --> inst4
    inst4 --> S3["S(3)"]
    inst4 --> C4["c4"]
    
    subgraph Inputs
      A0
      B0
      A1
      B1
      A2
      B2
      A3
      B3
      C0
    end
    
    subgraph Outputs
      S0
      S1
      S2
      S3
      C4
    end
```

#### Functionality

- Adds two 4-bit numbers and a carry input.
- Produces a 4-bit sum and a carry output.

#### Implementation Details

- **Instantiation**: 
  - Instantiates four 1-bit adders (TP1) to create the 4-bit adder.

#### Signals

- Input: A, B (4-bit addends), c0 (carry in)
- Output: S (4-bit sum), c4 (carry out)
- Internal: c1, c2, c3 (intermediate carries)

### 3. 1-bit Adder

The 1-bit adder is the basic building block used in the 4-bit full adder.

The equations are

```
s <= a XOR b XOR cin;
cout <= (a AND b) OR (a AND cin) OR (b AND cin);
```

#### Functionality

- Adds two 1-bit inputs and a carry input.
- Produces a 1-bit sum and a carry output.

#### Implementation Details

- **Data Flow**: 
  - Uses concurrent signal assignments to calculate sum and carry.

#### Signals

- Input: a, b (1-bit addends), cin (carry in)
- Output: s (sum), cout (carry out)


