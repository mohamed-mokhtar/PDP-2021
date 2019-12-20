Library IEEE;
USE IEEE.std_logic_1164.all;

entity CBUS is 
port(	
	-- CLOCK FOR WHOLE SYSTEM
	CLK: in std_logic ;
	-- TAKE DATA FROM ONE REGISTER
	SRCen : in std_logic ;
	-- SPECIFIY WHICH REGISTERS NEEDS THE DATA FROM THE BUS
	DSTen : in std_logic ;
	SRCsel : in std_logic_vector (2 downto 0) ;
	DSTsel : in std_logic_vector (2 downto 0) ;
	-- RESET BIT FOR EACH REGISTER
	RESET_R0,RESET_R1,RESET_R2,RESET_R3,RESET_R4,RESET_R5,RESET_R6,RESET_R7  : IN STD_LOGIC ;
	RESET_Y,RESET_TMP,RESET_MDR,RESET_MAR : in std_logic ;
	-- BUS DATA 
	BUSdata : inout std_logic_vector (15 downto 0);
	WR,RD : IN std_logic 
	);
END entity ;

architecture CBUSARCH of CBUS is 
-- Decoder Include
COMPONENT decoder24 is
port (S : in std_logic_vector (2 downto 0) ; 
EN : in std_logic;
F :out std_logic_vector( 5 downto 0 ));
END COMPONENT;

-- Tristate Include
COMPONENT tristate is
generic ( n: integer:=16);
  Port(
  X : IN std_logic_vector(n-1 downto 0);
  F : OUT std_logic_vector(n-1 downto 0);
  EN : in std_logic);
END COMPONENT;

-- Register Include
COMPONENT reg is 
generic (n:integer := 16);
port(	clk : in std_logic ; 
	reset : in std_logic ; 
	enable : in std_logic ; 
	d	: in std_logic_vector(n-1 downto 0);
	q	: out std_logic_vector(n-1 downto 0)
);
END COMPONENT;
-- Ram Include
COMPONENT ram IS
	PORT(
		clk : IN std_logic;
		WRen  : IN std_logic;
		RDen : IN std_logic;
		address : IN  std_logic_vector(7 DOWNTO 0);
		datain  : IN  std_logic_vector(15 DOWNTO 0);
		dataout : OUT std_logic_vector(15 DOWNTO 0));
END COMPONENT ram;

signal SRC_DECODED_SEL : std_logic_vector (5 downto 0);
signal DST_DECODED_SEL : std_logic_vector (5 downto 0);
signal R0_DATA , R1_DATA , R2_DATA , R3_DATA , MDR_DATA , MAR_DATA: std_logic_vector (15 downto 0);
signal R4_DATA , R5_DATA , R6_DATA , R7_DATA , TEMP_DATA : std_logic_vector (15 downto 0);
signal MDR_IN_FROM_RAM : std_logic_vector (15 downto 0);
signal MDR_IN : std_logic_vector (15 downto 0);
signal microAR : std_logic_vector (25 downto 0);

signal MDR_EN : std_logic ;
begin 
SEL_SRC_DEC : decoder24 port map ( SRCsel,SRCen,SRC_DECODED_SEL);
SEL_DST_DEC : decoder24 port map ( DSTsel,DSTen,DST_DECODED_SEL);

R0_TRI : tristate port map(R0_DATA,BUSdata,SRC_DECODED_SEL(0));
R1_TRI : tristate port map(R1_DATA,BUSdata,SRC_DECODED_SEL(1));
R2_TRI : tristate port map(R2_DATA,BUSdata,SRC_DECODED_SEL(2));
R3_TRI : tristate port map(R3_DATA,BUSdata,SRC_DECODED_SEL(3));
R4_TRI : tristate port map(R4_DATA,BUSdata,SRC_DECODED_SEL(0));
R5_TRI : tristate port map(R5_DATA,BUSdata,SRC_DECODED_SEL(1));
R6_TRI : tristate port map(R6_DATA,BUSdata,SRC_DECODED_SEL(2));
R7_TRI : tristate port map(R7_DATA,BUSdata,SRC_DECODED_SEL(3));
RY_TRI : tristate port map(R7_DATA,BUSdata,SRC_DECODED_SEL(3));
TEMP_TRI : tristate port map(TEMP_DATA,BUSdata,SRC_DECODED_SEL(3));

MDR_TRI : tristate port map(MDR_DATA,BUSdata,SRC_DECODED_SEL(4));
MAR_TRI : tristate port map(MAR_DATA,BUSdata,'0');

R0: reg port map(CLK,RESET_R0,DST_DECODED_SEL(0),BUSdata,R0_DATA);
R1: reg port map(CLK,RESET_R1,DST_DECODED_SEL(1),BUSdata,R1_DATA);
R2: reg port map(CLK,RESET_R2,DST_DECODED_SEL(2),BUSdata,R2_DATA);
R3: reg port map(CLK,RESET_R3,DST_DECODED_SEL(3),BUSdata,R3_DATA);
R4: reg port map(CLK,RESET_R4,DST_DECODED_SEL(0),BUSdata,R4_DATA);
R5: reg port map(CLK,RESET_R5,DST_DECODED_SEL(1),BUSdata,R5_DATA);
R6: reg port map(CLK,RESET_R6,DST_DECODED_SEL(2),BUSdata,R6_DATA);
R7: reg port map(CLK,RESET_R7,DST_DECODED_SEL(3),BUSdata,R7_DATA);
RY: reg port map(CLK,RESET_R7,DST_DECODED_SEL(3),BUSdata,R7_DATA);

TEMP: reg port map(CLK,RESET_TMP,DST_DECODED_SEL(3),BUSdata,R3_DATA);

MDR: reg port map(CLK,RESET_MDR,MDR_EN,MDR_IN,MDR_DATA);
MAR: reg port map(CLK,RESET_MAR,DST_DECODED_SEL(5),BUSdata,MAR_DATA);

MDR_IN <= MDR_IN_FROM_RAM WHEN ( RD = '1' and WR = '0' and DST_DECODED_SEL(4) = '0') else  BUSdata When DST_DECODED_SEL(4) = '1';
MDR_EN <= DST_DECODED_SEL(4) or RD ;
RAM0 : RAM port map(CLK,WR,RD,MAR_DATA(7 downto 0),MDR_DATA,MDR_IN_FROM_RAM);



end architecture;
