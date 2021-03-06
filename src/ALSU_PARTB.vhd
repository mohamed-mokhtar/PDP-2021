
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

entity ALSU_PORTB_ENTITY is 
port(
Y,B: in std_logic_vector (15 downto 0) ; 
Flags : inout std_logic_vector (15 downto 0) := (OTHERS => '0'); 
S: in std_logic_vector(2 downto 0);
F8 : in std_logic;
F : out std_logic_vector(15 downto 0));
end entity ALSU_PORTB_ENTITY;

architecture ALSU_PORTB_ARCH of ALSU_PORTB_ENTITY is 
signal Fbuffer : std_logic_vector(15 downto 0);
begin


    Fbuffer <= ("0000000000000000")   When S = "000"  -- F = 0
    else (Y)        when  S =  "001"   --F = Y (CMP)
    else (B)        when  S =  "010"   --F = B (MOV)
    else (NOT Y)    when  S =  "011"   --F = !Y
    else (NOT B)    when  S =  "100"   --F = !B
    else (Y AND B)  when  S =  "101"   --F = B AND Y
    else (Y OR B)   when  S =  "110"   --F = B OR Y
    else (Y XNOR B) when  S =  "111" ; --F = B XNOR Y
	
    --carry flag	
    Flags(0) <= '0' when  F8 = '1' and S="000"
    else '1' when  F8 = '1' and (S="011" or S="100") --!Y or !B
    else '1' when  S="001" and F8 = '1' and Y < B    --CMP
    else '0' when  S="001" and F8 = '1' and Y >= B  --CMP
    else Flags(0) when F8 = '0' or S = "010" or S = "101" or S = "110" or S ="111" --F8 = 0 or AND or OR or XNOR
    else '0';	  

    --Zero flag
    F <= Fbuffer;
    Flags(2) <= '1' When F8 = '1' and Fbuffer="0000000000000000" and (S = "000" OR S = "011" OR S = "100" OR S = "101" OR S = "110" OR S = "111")
    else '1' when F8='1' and S = "001" and Y = B 
    else flags(2) when S =  "010" OR F8 = '0'
    else '0'; 

  --Negative flag
    Flags(1) <= Fbuffer(15) when F8 = '1' 
           else Flags(1);

    --Parity flag
    Flags(3) <= not Fbuffer(0) when F8 = '1'
    else Flags(3);

   --Overflow flag
	Flags(5) <= '1'  when F8 = '1' and ( Flags(1) = '0' or Flags(3) = '0') 
	else '0' when F8 = '1'
	else Flags(5);


end architecture ALSU_PORTB_ARCH;