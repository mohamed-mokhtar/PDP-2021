Library IEEE;
USE IEEE.std_logic_1164.all;

entity xbus is 
port(	CLK: in std_logic ;
	SRCen : in std_logic ;
	DSTen : in std_logic ;
	SRCsel : in std_logic_vector (2 downto 0) ;
	DSTsel : in std_logic_vector (2 downto 0) ;
	RESET_R0 : in std_logic ;
	RESET_R1 : in std_logic ;
	RESET_R2 : in std_logic ;
	RESET_R3 : in std_logic ;
	RESET_MDR : in std_logic ;
	RESET_MAR : in std_logic ;
	BUSdata : inout std_logic_vector (15 downto 0);
	WR,RD : IN std_logic 
	);
END entity ;

architecture busarch of xbus is 
-- Decoder COMPONENT
COMPONENT decoder24 is
port (S : in std_logic_vector (2 downto 0) ; 
EN : in std_logic;
F :out std_logic_vector( 5 downto 0 ));
END COMPONENT;

-- Tristate COMPONENT
COMPONENT tristate is
generic ( n: integer:=16);
  Port(
  X : IN std_logic_vector(n-1 downto 0);
  F : OUT std_logic_vector(n-1 downto 0);
  EN : in std_logic);
END COMPONENT;

-- Register COMPONENT
COMPONENT reg is 
generic (n:integer := 16);
port(	clk : in std_logic ; 
	reset : in std_logic ; 
	enable : in std_logic ; 
	d	: in std_logic_vector(n-1 downto 0);
	q	: out std_logic_vector(n-1 downto 0)
);
END COMPONENT;
-- Ram COMPONENT
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
signal R0_DATA , R1_DATA , R2_DATA , R3_DATA , MDR_DATA ,MAR_DATA: std_logic_vector (15 downto 0);
signal MDR_IN_FROM_RAM : std_logic_vector (15 downto 0);
signal MDR_IN : std_logic_vector (15 downto 0);
signal MDR_EN : std_logic ;
begin 
SEL_SRC_DEC : decoder24 port map ( SRCsel,SRCen,SRC_DECODED_SEL);
SEL_DST_DEC : decoder24 port map ( DSTsel,DSTen,DST_DECODED_SEL);

R0_TRI : tristate port map(R0_DATA,BUSdata,SRC_DECODED_SEL(0));
R1_TRI : tristate port map(R1_DATA,BUSdata,SRC_DECODED_SEL(1));
R2_TRI : tristate port map(R2_DATA,BUSdata,SRC_DECODED_SEL(2));
R3_TRI : tristate port map(R3_DATA,BUSdata,SRC_DECODED_SEL(3));
MDR_TRI : tristate port map(MDR_DATA,BUSdata,SRC_DECODED_SEL(4));
MAR_TRI : tristate port map(MAR_DATA,BUSdata,'0');

R0: reg port map(CLK,RESET_R0,DST_DECODED_SEL(0),BUSdata,R0_DATA);
R1: reg port map(CLK,RESET_R1,DST_DECODED_SEL(1),BUSdata,R1_DATA);
R2: reg port map(CLK,RESET_R2,DST_DECODED_SEL(2),BUSdata,R2_DATA);
R3: reg port map(CLK,RESET_R3,DST_DECODED_SEL(3),BUSdata,R3_DATA);


MDR: reg port map(CLK,RESET_MDR,MDR_EN,MDR_IN,MDR_DATA);
MAR: reg port map(CLK,RESET_MAR,DST_DECODED_SEL(5),BUSdata,MAR_DATA);

MDR_IN <= MDR_IN_FROM_RAM WHEN ( RD = '1' and WR = '0' and DST_DECODED_SEL(4) = '0') else  BUSdata When DST_DECODED_SEL(4) = '1';
MDR_EN <= DST_DECODED_SEL(4) or RD ;
RAM0 : RAM port map(CLK,WR,RD,MAR_DATA(7 downto 0),MDR_DATA,MDR_IN_FROM_RAM);



end architecture;
