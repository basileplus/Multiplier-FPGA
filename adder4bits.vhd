library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FA4bits is

Port ( A : in std_logic_vector(3 downto 0);

        B : in std_logic_vector(3 downto 0);
        
        c0 : in std_logic;
        
        S : out std_logic_vector(3 downto 0);
        
        c4 : out std_logic);
end FA4bits;

architecture Structural of FA4bits is

component TP1
    port (
    a : in std_logic;
    b : in std_logic;
    cin : in std_logic;
    s : out std_logic;
    cout : out std_logic);
end component;

signal c1, c2, c3 : std_logic;
begin

inst1 : TP1 port map (a => A(0), b=> B(0), cin=>c0, s=>S(0), cout=>c1);
inst2 : TP1 port map (a => A(1), b=> B(1), cin=>c1, s=>S(1), cout=>c2);
inst3 : TP1 port map (a => A(2), b=> B(2), cin=>c2, s=>S(2), cout=>c3);
inst4 : TP1 port map (a => A(3), b=> B(3), cin=>c3, s=>S(3), cout=>c4);


end Structural;
