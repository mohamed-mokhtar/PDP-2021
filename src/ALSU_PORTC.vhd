LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

entity ALSU_PORTC_ENTITY is 
port(
Y: in std_logic_vector (15 downto 0) ; 
Flags : inout std_logic_vector (15 downto 0) ; 
S: in std_logic_vector(2 downto 0);
F8 : in std_logic;
F : out std_logic_vector(15 downto 0));
end entity ALSU_PORTC_ENTITY;

architecture ALSU_PORTC_ARCH of ALSU_PORTC_ENTITY is 
signal Cout : std_logic;
signal Fbuffer : std_logic_vector(15 downto 0);
begin
    Fbuffer <= ( '0' & Y(15 downto 1) )   When S = "000"  -- shift right
    else ( Y(14 downto 0) & '0')    when  S =  "001"   --shift left
    else ( Y(0) & Y(15 downto 1)  ) when  S =  "010"   -- rotate right
    else (Flags(0)  & Y(15 downto 1) )   when  S =  "011"   -- rotate right with carry --
    else ( Y(14 downto 0) & Y(15) ) when  S =  "100"   -- rotate left 
    else (Y(14 downto 0) & Flags(0) )   when  S =  "101"   -- rotate left with carry --
    else (Y(15) & Y(15 downto 1) )  when  S =  "110" ;  --arithnitic shift right
	
	
	Cout <= Y(0) when  S="011" -- rotate right with carry
	else Y(15) when  S="101"  -- rotate left with carry
	else Flags(0); -- otherwise
	
	Flags(0) <= Cout When F8 = '1' ; -- Effect in IR-OPERATION ONLY
	F <= Fbuffer;
	Flags(2) <= '1' When F8 = '1' and Fbuffer="0000000000000000"
	else '0' when F8='1' ; -- Effect in IR-OPERATION ONLY


end architecture ALSU_PORTC_ARCH;