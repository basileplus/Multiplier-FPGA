library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Multiplieur is
    Port ( A : in  STD_LOGIC_VECTOR (3 downto 0);
           B : in  STD_LOGIC_VECTOR (3 downto 0);
           Res : out  STD_LOGIC_VECTOR (7 downto 0);
           Start : in  STD_LOGIC;
			  reset : in  STD_LOGIC;
			  clk : in  STD_LOGIC;
           Done : out  STD_LOGIC);
end Multiplieur;

architecture Behavioral of Multiplieur is

signal PP : STD_LOGIC_VECTOR (3 downto 0);
signal Rin : STD_LOGIC_VECTOR (4 downto 0);
signal Rout : STD_LOGIC_VECTOR (7 downto 0);
signal Areg : STD_LOGIC_VECTOR (3 downto 0);
signal Breg : STD_LOGIC_VECTOR (3 downto 0);

type state_type is (Attente,Chargement,Addition,Decalage,raz);
signal Etat : state_type ;

signal cpt : std_logic_vector(1 downto 0);

	COMPONENT FA4bits
	PORT(
		A : IN std_logic_vector(3 downto 0);
		B : IN std_logic_vector(3 downto 0);
		Cin : IN std_logic;          
		S : OUT std_logic_vector(3 downto 0);
		Cout : OUT std_logic
		);
	END COMPONENT;

begin

PP <= (Areg(0) and Breg(3)) & (Areg(0) and Breg(2)) & (Areg(0) and Breg(1)) & (Areg(0) and Breg(0)); -- Calcul du produit partiel
Inst_FA4bits: FA4bits PORT MAP(A => PP,B => Rout(6 downto 3),S => Rin(3 downto 0),Cout => Rin(4),Cin => '0'	); -- Instanciation de l'additionneur


machinedetat : process(clk,reset)
begin
	if reset='1' then
	cpt<="00";
	Etat <=Attente;
	else
	
	if rising_edge(clk) then
	case Etat is
		when Attente => 
			cpt<="00";
			if start = '1' then
				Etat <= Chargement;
			else
				Etat <= Attente;
			end if;
		when Chargement =>
			Areg <= A;
			Breg <= B;
			Done <= '0';
			Rout <= (others => '0');
			Etat <= Addition;
		when Addition =>
			Rout(7 downto 3) <= Rin; -- R�cup�ration du r�sultat de l'addition
			Etat <= Decalage;			
		when Decalage =>
			Areg <= Areg(0) & Areg(3 downto 1); -- D�calage d'un bit vers la droite de Areg
			Rout <= Rout(0) & Rout(7 downto 1); -- D�calage d'un bit vers la droite de Rout
			if cpt = "10" then
				cpt<="00";
				Etat <= raz;
			else
				cpt<= std_logic_vector(unsigned(cpt)+1);
				Etat <= Addition;
			end if;
		when raz =>
			Done <= '1';
			Res<=Rin(4 downto 0) & Rout(2 downto 0); -- R�cup�ration du r�sultat : Cout & P43 & P42 & P41 & P40 & P30 & P20 & P10
			if start = '0' then
				Etat <= Attente;
			else
				Etat <= raz;
			end if;
	end case;
	end if;
	end if;
end process;

end Behavioral;
