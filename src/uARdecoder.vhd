Library IEEE;
USE IEEE.std_logic_1164.all;
entity uARDecoder is
port (
-- INPUT SIGNALS
uAR_Data : in std_logic_vector (25 downto 0) ; 
IR : in std_logic_vector (15 downto 0) ; 
-- F0
NXTAdd : out std_logic_vector (7 downto 0) ; 
-- F1
PCout : out std_logic; 
MDRout : out std_logic; 
Zout : out std_logic; 
RTEMP : out std_logic; 
IRaddfield : out std_logic; 
-- RSRC , RDST out
R0out,R1out,R2out,R3out,R4out,R5out,R6out,R7out : out std_logic; 
-- F2
PCin : out std_logic; 
IRin : out std_logic; 
Zin : out std_logic; 
R0in,R1in,R2in,R3in,R4in,R5in,R6in,R7in : out std_logic; 
-- F3
MARin : out std_logic; 
MDRin : out std_logic; 
-- F4
RYin : out std_logic; 
RTMPin: out std_logic; 
-- F5
ADDSIG :  out std_logic; 
INCSIG :  out std_logic; 
DECSIG :  out std_logic; 
-- ALU IS WORKING THE INSTRUCTION
IROPR :  out std_logic; 
-- F6
RDen :  out std_logic; 
WRen :  out std_logic; 

-- F7
ORdst :  out std_logic; 
ORindst :  out std_logic; 
ORinsrc :  out std_logic; 
ORresult :  out std_logic; 
PLAout :  out std_logic

);
end entity;

architecture uARDecoderArch of uARDecoder is
begin
-- F0
NXTAdd <= uAR_Data(25 downto 18);

-- F1
PCout <= '1' when uAR_Data(17 downto 15) = "001" else '0' ;
MDRout <= '1' when uAR_Data(17 downto 15) = "010" else '0' ;
Zout <= '1' when uAR_Data(17 downto 15) = "011" else '0' ;
R0out <= '1' when ( ( uAR_Data(17 downto 15) = "100" and IR(8 downto 6) = "000" ) or ( uAR_Data(17 downto 15) = "101" and IR(2 downto 0) = "000" ) ) else '0' ;
R1out <= '1' when ( ( uAR_Data(17 downto 15) = "100" and IR(8 downto 6) = "001" ) or ( uAR_Data(17 downto 15) = "101" and IR(2 downto 0) = "001" ) ) else '0' ;
R2out <= '1' when ( ( uAR_Data(17 downto 15) = "100" and IR(8 downto 6) = "010" ) or ( uAR_Data(17 downto 15) = "101" and IR(2 downto 0) = "010" ) ) else '0' ;
R3out <= '1' when ( ( uAR_Data(17 downto 15) = "100" and IR(8 downto 6) = "011" ) or ( uAR_Data(17 downto 15) = "101" and IR(2 downto 0) = "011" ) ) else '0' ;
R4out <= '1' when ( ( uAR_Data(17 downto 15) = "100" and IR(8 downto 6) = "100" ) or ( uAR_Data(17 downto 15) = "101" and IR(2 downto 0) = "100" ) ) else '0' ;
R5out <= '1' when ( ( uAR_Data(17 downto 15) = "100" and IR(8 downto 6) = "101" ) or ( uAR_Data(17 downto 15) = "101" and IR(2 downto 0) = "101" ) ) else '0' ;
R6out <= '1' when ( ( uAR_Data(17 downto 15) = "100" and IR(8 downto 6) = "110" ) or ( uAR_Data(17 downto 15) = "101" and IR(2 downto 0) = "110" ) ) else '0' ;
R7out <= '1' when ( ( uAR_Data(17 downto 15) = "100" and IR(8 downto 6) = "111" ) or ( uAR_Data(17 downto 15) = "101" and IR(2 downto 0) = "111" ) ) else '0' ;
IRaddfield <= '1' when uAR_Data(17 downto 15) = "111" else '0' ;
RTEMP <= '1' when uAR_Data(17 downto 15) = "110" else '0' ;

-- F2
PCin  <= '1' when uAR_Data(14 downto 12) = "001" else '0' ;
IRin  <= '1' when uAR_Data(14 downto 12) = "010" else '0' ;
Zin   <= '1' when uAR_Data(14 downto 12) = "011" else '0' ;
R0in <= '1' when ( ( uAR_Data(14 downto 12) = "100" and IR(8 downto 6) = "000" ) or ( uAR_Data(17 downto 15) = "101" and IR(2 downto 0) = "000" ) ) else '0' ;
R1in <= '1' when ( ( uAR_Data(14 downto 12) = "100" and IR(8 downto 6) = "001" ) or ( uAR_Data(17 downto 15) = "101" and IR(2 downto 0) = "001" ) ) else '0' ;
R2in <= '1' when ( ( uAR_Data(14 downto 12) = "100" and IR(8 downto 6) = "010" ) or ( uAR_Data(17 downto 15) = "101" and IR(2 downto 0) = "010" ) ) else '0' ;
R3in <= '1' when ( ( uAR_Data(14 downto 12) = "100" and IR(8 downto 6) = "011" ) or ( uAR_Data(17 downto 15) = "101" and IR(2 downto 0) = "011" ) ) else '0' ;
R4in <= '1' when ( ( uAR_Data(14 downto 12) = "100" and IR(8 downto 6) = "100" ) or ( uAR_Data(17 downto 15) = "101" and IR(2 downto 0) = "100" ) ) else '0' ;
R5in <= '1' when ( ( uAR_Data(14 downto 12) = "100" and IR(8 downto 6) = "101" ) or ( uAR_Data(17 downto 15) = "101" and IR(2 downto 0) = "101" ) ) else '0' ;
R6in <= '1' when ( ( uAR_Data(14 downto 12) = "100" and IR(8 downto 6) = "110" ) or ( uAR_Data(17 downto 15) = "101" and IR(2 downto 0) = "110" ) ) else '0' ;
R7in <= '1' when ( ( uAR_Data(14 downto 12) = "100" and IR(8 downto 6) = "111" ) or ( uAR_Data(17 downto 15) = "101" and IR(2 downto 0) = "111" ) ) else '0' ;

-- F3
MARin  <= '1' when uAR_Data(11 downto 10) = "01" else '0' ;
MDRin <= '1' when uAR_Data(11 downto 10) = "10" else '0' ;
-- F4
RYin  <= '1' when uAR_Data(9 downto 8) = "01" else '0' ;
RTMPin <= '1' when uAR_Data(9 downto 8) = "10" else '0' ;
-- F5
ADDSIG <= '1' when uAR_Data(7 downto 6) = "00" else '0' ;
INCSIG <= '1' when uAR_Data(7 downto 6) = "01" else '0' ;
DECSIG <= '1' when uAR_Data(7 downto 6) = "10" else '0' ;
-- ALU IS WORKING THE INSTRUCTION
IROPR <= '1' when uAR_Data(7 downto 6) = "11" else '0' ;
-- F6
RDen <= '1' when uAR_Data(5 downto 4) = "01" else '0' ;
WRen <= '1' when uAR_Data(5 downto 4) = "10" else '0' ;

-- F7
ORdst <= '1' when uAR_Data(3 downto 1) = "001" else '0' ;
ORindst <= '1' when uAR_Data(3 downto 1) = "010" else '0' ;
ORinsrc <= '1' when uAR_Data(3 downto 1) = "011" else '0' ;
ORresult <= '1' when uAR_Data(3 downto 1) = "100" else '0' ;
PLAout <= '1' when uAR_Data(3 downto 1) = "101" else '0' ;

end architecture;