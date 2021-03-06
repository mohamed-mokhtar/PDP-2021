Library IEEE;
USE IEEE.std_logic_1164.all;

entity CBUS is 
port(	
	-- CLOCK FOR WHOLE SYSTEM
	CLK: in std_logic ;
	RCLK: in std_logic ;
	-- RESET BIT FOR EACH REGISTER
	RESET_R0,RESET_R1,RESET_R2,RESET_R3,RESET_R4,RESET_R5,RESET_R6,RESET_R7  : IN STD_LOGIC ;
	RESET_Y,RESET_TMP,RESET_MDR,RESET_MAR,RESET_Z : in std_logic ;
	-- BUS DATA 
	BUSdata : inout std_logic_vector (15 downto 0)
	--FLAGREG : inout std_logic_vector (15 downto 0)
	);
END entity ;

architecture CBUSARCH of CBUS is 

-- RAM COMPONENT
COMPONENT RamEnt is
		port(
				Initial :inout std_logic;
				Clk,Wr,Re : in std_logic;
				PC : in std_logic_vector(15 downto 0);
				DataIn: in std_logic_vector(15 downto 0);
				DataOut : out std_logic_vector(15 downto 0)
			);
end COMPONENT;

-- ROM COMPONENT
COMPONENT RomEnt is
    port(
            Clk : in std_logic;
            Address : in std_logic_vector(7 downto 0);
            Output : out std_logic_vector(24 downto 0)
        );
end COMPONENT;

-- PLA COMPONENT
COMPONENT PLA_Entity is     
port(IR: IN std_logic_vector(15 DOWNTO 0);
     F:OUT std_logic_vector(7 DOWNTO 0));
end COMPONENT PLA_Entity;

-- BIT ORING COMPONENT
COMPONENT bit_oring is 
port (
oring_bits :in std_logic_vector(2 downto 0);
address_mod:in std_logic_vector(7 downto 0);
IR: in std_logic_vector(15 downto 0);
PLA_input: in std_logic_vector(7 downto 0);
m_micro_AR : out std_logic_vector(7 downto 0)
);
end COMPONENT;


-- ALU COMPONENT
COMPONENT alsu is
port(Y,B: IN std_logic_vector(15 downto 0);
S:IN std_logic_vector(4 downto 0);
F8 : in std_logic;
Flags :inout std_logic_vector (15 downto 0) := (OTHERS => '0');
F: OUT std_logic_vector(15 downto 0));
end COMPONENT alsu;


-- IR2BUS DECODER COMPONENT
COMPONENT IR_ToBus_Decoder_Entity 
IS
PORT ( IR,Flags: IN STD_LOGIC_VECTOR(15 downto 0);
Offset : OUT STD_LOGIC_VECTOR(15 downto 0));
END COMPONENT IR_ToBus_Decoder_Entity;

-- PALU DECODER COMPONENT
COMPONENT PALU_Decoder_Entity 
IS
PORT ( IR: IN STD_LOGIC_VECTOR(15 downto 0) ;
F5: IN STD_LOGIC_VECTOR(1 downto 0);
OP : OUT STD_LOGIC_VECTOR(4 downto 0));
END COMPONENT PALU_Decoder_Entity;

-- Control Word decoder
COMPONENT CWDecoder is
		port (
		-- INPUT SIGNALS
		CWData : in std_logic_vector (24 downto 0) ; 
		IR : in std_logic_vector (15 downto 0) ; 
		-- F0
		NXTAdd : out std_logic_vector (7 downto 0) ; 
		-- F1
		PCout : out std_logic; 
		MDRout : out std_logic; 
		Zout : out std_logic; 
		TEMPout : out std_logic; 
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
		Yin : out std_logic; 
		TEMPin: out std_logic; 
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
END COMPONENT;

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



signal R0_DATA , R1_DATA , R2_DATA , R3_DATA , MDR_DATA , MAR_DATA: std_logic_vector (15 downto 0);
signal R4_DATA , R5_DATA , R6_DATA  , TEMP_DATA , Y_DATA , Z_DATA , IR_DATA: std_logic_vector (15 downto 0);
signal R7_DATA : std_logic_vector (15 downto 0);
signal Temp66 : std_logic_vector (15 downto 0) ;

signal CONTROL_WORD : std_logic_vector (24 downto 0);
signal PCout,MDRout,Zout,TEMPout,IRaddfield,R0out,R1out,R2out,R3out,R4out,R5out,R6out,R7out : std_logic;
signal PCin,IRin,Zin,R0in,R1in,R2in,R3in,R4in,R5in,R6in,R7in : std_logic;
signal MARin,MDRin,Yin,TEMPin,ADDSIG,INCSIG,DECSIG,IROPR,RDen,WRen,ORdst,ORindst,ORinsrc,ORresult,PLAout : std_logic;

signal ALU_OUTPUT : std_logic_vector ( 15 downto 0);
signal MDR_IN_FROM_RAM : std_logic_vector (15 downto 0);
signal MDR_INdata : std_logic_vector (15 downto 0);
signal microAR : std_logic_vector (24 downto 0);

signal MDR_EN : std_logic ;

signal ALUsel : std_logic_vector (4 downto 0);
signal FLAGS_DATA,ALU_FLAGS : std_logic_vector (15 downto 0):=(others=>'0');
signal OFFSET_BRANCH : std_logic_vector (15 downto 0);

signal PCfin , PCfout,F8 : std_logic ;

signal PLA_OUTdata : std_logic_vector (7 downto 0);
signal uARnew : std_logic_vector (7 downto 0);
signal INITREAD : std_logic;

signal SmallRegSignal1,SmallRegSignal2,SmallRegSignal3 : std_logic;
signal RDfen: std_logic;
begin 

F8 <= '0' when IR_DATA(15 downto 12) = "0010"
else IROPR ;

R0_TRI : tristate port map(R0_DATA,BUSdata,R0out);
R1_TRI : tristate port map(R1_DATA,BUSdata,R1out);
R2_TRI : tristate port map(R2_DATA,BUSdata,R2out);
R3_TRI : tristate port map(R3_DATA,BUSdata,R3out);
R4_TRI : tristate port map(R4_DATA,BUSdata,R4out);
R5_TRI : tristate port map(R5_DATA,BUSdata,R5out);
R6_TRI : tristate port map(R6_DATA,BUSdata,R6out);
R7_TRI : tristate port map(R7_DATA,BUSdata,PCfout);
IROFF_TRI : tristate port map(OFFSET_BRANCH,BUSdata,IRaddfield);



RY_TRI : tristate port map(Y_DATA,BUSdata,'0');
TEMP_TRI : tristate port map(TEMP_DATA,BUSdata,TEMPout);
Z_TRI : tristate port map(Z_DATA,BUSdata,Zout);

IR_TRI : tristate port map(IR_DATA,BUSdata,'0');
MDR_TRI : tristate port map(MDR_DATA,BUSdata,MDRout);
MAR_TRI : tristate port map(MAR_DATA,BUSdata,'0');

R0 : reg port map(RCLK,RESET_R0,R0in,BUSdata,R0_DATA);
R1 : reg port map(RCLK,RESET_R1,R1in,BUSdata,R1_DATA);
R2 : reg port map(RCLK,RESET_R2,R2in,BUSdata,R2_DATA);
R3 : reg port map(RCLK,RESET_R3,R3in,BUSdata,R3_DATA);
R4 : reg port map(RCLK,RESET_R4,R4in,BUSdata,R4_DATA);
R5 : reg port map(RCLK,RESET_R5,R5in,BUSdata,R5_DATA);
R6 : reg port map(RCLK,RESET_R6,R6in,BUSdata,R6_DATA);
R7 : reg port map(RCLK,RESET_R7,PCfin,BUSdata,R7_DATA);
FL : reg port map(RCLK,'0',F8,ALU_FLAGS,FLAGS_DATA);

RY : reg port map(RCLK,RESET_R7,Yin,BUSdata,Y_DATA);
RZ : reg port map(RCLK,RESET_Z,Zin,ALU_OUTPUT,Z_DATA);
TEMP : reg port map(RCLK,RESET_TMP,TEMPin,BUSdata,TEMP_DATA);

IR :  reg port map(RCLK,RESET_TMP,IRin,BUSdata,IR_DATA);
MDR : reg port map(RCLK,RESET_MDR,MDR_EN,MDR_INdata,MDR_DATA);
MAR : reg port map(RCLK,RESET_MAR,MARin,BUSdata,MAR_DATA);
-- EDIT IT - SIGNAL F OUTPUT 
-- to be added signals

-- ALU SECTION
ALUDECODER : PALU_Decoder_Entity port map(IR_DATA,CONTROL_WORD(6 downto 5),ALUsel);
ALU0 : alsu port map(Y_DATA,BUSdata,ALUsel,F8,ALU_FLAGS,ALU_OUTPUT);
IR_FIELD_DECODE : IR_ToBus_Decoder_Entity port map(IR_DATA,FLAGS_DATA,OFFSET_BRANCH);

CW_DECODE : CWDecoder port map(CONTROL_WORD,IR_DATA,PCout=>PCout,MDRout=>MDRout,Zout=>Zout,TEMPout=>TEMPout,IRaddfield=>IRaddfield,R0out=>R0out,R1out=>R1out,R2out=>R2out,R3out=>R3out,R4out=>R4out,R5out=>R5out,R6out=>R6out,R7out=>R7out,PCin=>PCin,IRin=>IRin,Zin=>Zin,R0in=>R0in,R1in=>R1in,R2in=>R2in,R3in=>R3in,R4in=>R4in,R5in=>R5in,R6in=>R6in,R7in=>R7in,MARin=>MARin,MDRin=>MDRin,Yin=>Yin,TEMPin=>TEMPin,ADDSIG=>ADDSIG,INCSIG=>INCSIG,DECSIG=>DECSIG,IROPR=>IROPR,RDen=>RDen,WRen=>WRen,ORdst=>ORdst,ORindst=>ORindst,ORinsrc=>ORinsrc,ORresult=>ORresult,PLAout=>PLAout );
-- to be added signals
PLA0 : PLA_Entity port map(IR_DATA , PLA_OUTdata);
BITORING0 : bit_oring port map(CONTROL_WORD(2 downto 0),CONTROL_WORD(24 downto 17),IR_DATA,PLA_OUTdata,uARnew );

MDR_INdata <= MDR_IN_FROM_RAM WHEN ( RDfen = '1' and WRen = '0' and MDRin = '0' ) else  BUSdata When MDRin = '1';
MDR_EN <= MDRin or RDfen ;
-- signal initREAD = '1' in begin

RAM0 : RamEnt port map(INITREAD,CLK,WRen,RDen,MAR_DATA,MDR_DATA,MDR_IN_FROM_RAM);
CONTROL_STORE : RomEnt port map(CLK,uARnew,CONTROL_WORD);

PCfin <= R7in or PCin;
PCfout <= R7out or PCout;

--SmallReg1:SmallRegEnt port map(Clk , RDen , SmallRegSignal1);
--SmallReg2:SmallRegEnt port map(Clk , SmallRegSignal1 , SmallRegSignal2);
--SmallReg3:SmallRegEnt port map(Clk , SmallRegSignal2 , SmallRegSignal3);
RDfen <= transport RDen after 10 ns;
end architecture;
