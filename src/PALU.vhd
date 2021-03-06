
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PALU_Entity is     
port(Y,B,FlagsIn: IN std_logic_vector(15 DOWNTO 0);
     Sel:IN std_logic_vector(4 downto 0);
     F8:in std_logic;
     F,FlagsOut:OUT std_logic_vector(15 DOWNTO 0));
end entity PALU_Entity;


architecture PALU_arch of PALU_Entity is 

--componenets
---------------------------------------------------------------
--PALU_PortA component
-----------------------------------------------
COMPONENT PALU_PortA_Entity IS
port(Y,B,FlagsIn: IN std_logic_vector(15 DOWNTO 0);
     Sel:IN std_logic_vector(2 downto 0);
     Carry,F8:in std_logic;
     F,FlagsOut:OUT std_logic_vector(15 DOWNTO 0));
END COMPONENT ;
----------------------------------------------


--PALU_PortB component
----------------------------------------------------
COMPONENT PALU_PortB_Entity IS
port(Y,B,FlagsIn: IN std_logic_vector(15 DOWNTO 0);
     Sel:IN std_logic_vector(2 downto 0);
     Carry,F8:in std_logic;
     F,FlagsOut:OUT std_logic_vector(15 DOWNTO 0));
END COMPONENT;
---------------------------------------------------

--PALU_PortC component
------------------------------------------------
COMPONENT PALU_PortC_Entity IS
port(Y,FlagsIn: IN std_logic_vector(15 DOWNTO 0);
     Sel:IN std_logic_vector(2 downto 0);
     Carry,F8:in std_logic;
     F,FlagsOut:OUT std_logic_vector(15 DOWNTO 0));
END COMPONENT;
------------------------------------------------
--mux component
--------------------------------------------
component mux_entity IS
PORT ( s1,s0 :IN STD_LOGIC ;
IN0,IN1,IN2,IN3 : IN std_logic_vector(15 downto 0);
F : OUT std_logic_vector(15 downto 0));
END COMPONENT;
---------------------------------------------
---------------------------------------------------------------

--signals
SIGNAL OUTA,OUTB,OUTC ,FlagsOutA,FlagsOutB,FlagsOutC: std_logic_vector (15 downto 0);


--begin arch
begin 
u0: PALU_PortA_Entity PORT MAP (Y(15 downto 0),B(15 downto 0),FlagsIn(15 downto 0),Sel(2 downto 0),FlagsIn(0),F8,OUTA(15 downto 0),FlagsOutA(15 downto 0));
u1: PALU_PortB_Entity PORT MAP (Y(15 downto 0),B(15 downto 0),FlagsIn(15 downto 0),Sel(2 downto 0),FlagsIn(0),F8,OUTB(15 downto 0),FlagsOutB(15 downto 0));
u2: PALU_PortC_Entity PORT MAP (Y(15 downto 0),FlagsIn(15 downto 0),Sel(2 downto 0),FlagsIn(0),F8,OUTC(15 downto 0),FlagsOutC(15 downto 0));

mx1:Mux_Entity PORT MAP (Sel(4),Sel(3),OUTA,OUTB,OUTC,OUTC,F);
mx2:Mux_Entity PORT MAP (Sel(4),Sel(3),FlagsOutA,FlagsOutB,FlagsOutC,FlagsOutC,FlagsOut);
--Flagsout<=Temp;

end PALU_arch;