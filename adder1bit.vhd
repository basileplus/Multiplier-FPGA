library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TP1 is
  Port ( a : in std_logic;
        b : in std_logic;
        cin : in std_logic; 
        s : out std_logic;
        cout : out std_logic);
end TP1;

architecture Structural of TP1 is
-- signaux intermediaires
begin
s <= a XOR b XOR cin;
cout <= (a AND b) OR (a AND cin) OR (b AND cin);
end Structural;
