-- Copyright (C) 2018  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details.

-- PROGRAM		"Quartus Prime"
-- VERSION		"Version 18.0.0 Build 614 04/24/2018 SJ Lite Edition"
-- CREATED		"Sun Jul 01 04:28:55 2018"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY datapath IS 
	PORT
	(
		clk :  IN  STD_LOGIC;
		IorD :  IN  STD_LOGIC;
		RegDst :  IN  STD_LOGIC;
		RegWrite :  IN  STD_LOGIC;
		ALUSrcA :  IN  STD_LOGIC;
		Branch :  IN  STD_LOGIC;
		PCWrite :  IN  STD_LOGIC;
		IRWrite :  IN  STD_LOGIC;
		reset :  IN  STD_LOGIC;
		MemtoReg :  IN  STD_LOGIC;
		ALUControl :  IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
		AluSrcB :  IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
		PCSrc :  IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
		ReadData :  IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		Adr :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
		ALUOut :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
		Funct :  OUT  STD_LOGIC_VECTOR(5 DOWNTO 0);
		Instr :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
		Op :  OUT  STD_LOGIC_VECTOR(5 DOWNTO 0);
		pc :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
		PCJump :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
		RDCLK :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
		RFRD1 :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
		RFRD2 :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
		WriteData :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
		WriteReg :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END datapath;

ARCHITECTURE bdf_type OF datapath IS 

COMPONENT flopenr
GENERIC (width : INTEGER
			);
	PORT(clk : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 en : IN STD_LOGIC;
		 d : IN STD_LOGIC_VECTOR(width-1 DOWNTO 0);
		 q : OUT STD_LOGIC_VECTOR(width-1 DOWNTO 0)
	);
END COMPONENT;

COMPONENT signext
	PORT(a : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 y : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT mux2
GENERIC (width : INTEGER
			);
	PORT(s : IN STD_LOGIC;
		 d0 : IN STD_LOGIC_VECTOR(width-1 DOWNTO 0);
		 d1 : IN STD_LOGIC_VECTOR(width-1 DOWNTO 0);
		 y : OUT STD_LOGIC_VECTOR(width-1 DOWNTO 0)
	);
END COMPONENT;

COMPONENT flopr
GENERIC (width : INTEGER
			);
	PORT(clk : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 d : IN STD_LOGIC_VECTOR(width-1 DOWNTO 0);
		 q : OUT STD_LOGIC_VECTOR(width-1 DOWNTO 0)
	);
END COMPONENT;

COMPONENT regfile
	PORT(clk : IN STD_LOGIC;
		 we3 : IN STD_LOGIC;
		 ra1 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 ra2 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 wa3 : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 wd3 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 rd1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 rd2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT mux4
GENERIC (width : INTEGER
			);
	PORT(d0 : IN STD_LOGIC_VECTOR(width-1 DOWNTO 0);
		 d1 : IN STD_LOGIC_VECTOR(width-1 DOWNTO 0);
		 d2 : IN STD_LOGIC_VECTOR(width-1 DOWNTO 0);
		 d3 : IN STD_LOGIC_VECTOR(width-1 DOWNTO 0);
		 s : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 y : OUT STD_LOGIC_VECTOR(width-1 DOWNTO 0)
	);
END COMPONENT;

COMPONENT sl2
	PORT(a : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 y : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT intvec
GENERIC (int : INTEGER;
			width : INTEGER
			);
	PORT(		 y : OUT STD_LOGIC_VECTOR(width-1 DOWNTO 0)
	);
END COMPONENT;

COMPONENT alu
	PORT(a : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 alucontrol : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		 b : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 zero : OUT STD_LOGIC;
		 result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT jmpmerge
	PORT(instr : IN STD_LOGIC_VECTOR(25 DOWNTO 0);
		 pchi : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 y : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT beqctrl
	PORT(zero : IN STD_LOGIC;
		 branch : IN STD_LOGIC;
		 pcwrite : IN STD_LOGIC;
		 pcen : OUT STD_LOGIC
	);
END COMPONENT;

SIGNAL	ALUOut_ALTERA_SYNTHESIZED :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	ALUResult :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	Instr_ALTERA_SYNTHESIZED :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	pc_ALTERA_SYNTHESIZED :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	PCAdr :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	PCEn :  STD_LOGIC;
SIGNAL	PCJump_ALTERA_SYNTHESIZED :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	pcNxt :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	RDCLK_ALTERA_SYNTHESIZED :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	RFRD_ALTERA_SYNTHESIZED1 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	RFRD_ALTERA_SYNTHESIZED2 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SrcA :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	WD :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	WriteReg_ALTERA_SYNTHESIZED :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	Zero :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_8 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_4 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_6 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_7 :  STD_LOGIC_VECTOR(31 DOWNTO 0);


BEGIN 



b2v_inst : flopenr
GENERIC MAP(width => 32
			)
PORT MAP(clk => clk,
		 reset => reset,
		 en => PCEn,
		 d => pcNxt,
		 q => pc_ALTERA_SYNTHESIZED);


b2v_inst1 : signext
PORT MAP(a => Instr_ALTERA_SYNTHESIZED(15 DOWNTO 0),
		 y => SYNTHESIZED_WIRE_8);


b2v_inst11 : mux2
GENERIC MAP(width => 32
			)
PORT MAP(s => IorD,
		 d0 => pc_ALTERA_SYNTHESIZED,
		 d1 => ALUOut_ALTERA_SYNTHESIZED,
		 y => PCAdr);


b2v_inst12 : flopenr
GENERIC MAP(width => 32
			)
PORT MAP(clk => clk,
		 reset => reset,
		 en => IRWrite,
		 d => ReadData,
		 q => Instr_ALTERA_SYNTHESIZED);


b2v_inst14 : regfile
PORT MAP(clk => clk,
		 we3 => RegWrite,
		 ra1 => Instr_ALTERA_SYNTHESIZED(25 DOWNTO 21),
		 ra2 => Instr_ALTERA_SYNTHESIZED(20 DOWNTO 16),
		 wa3 => SYNTHESIZED_WIRE_0,
		 wd3 => WriteReg_ALTERA_SYNTHESIZED,
		 rd1 => RFRD_ALTERA_SYNTHESIZED1,
		 rd2 => RFRD_ALTERA_SYNTHESIZED2);


b2v_inst15 : mux2
GENERIC MAP(width => 5
			)
PORT MAP(s => RegDst,
		 d0 => Instr_ALTERA_SYNTHESIZED(20 DOWNTO 16),
		 d1 => Instr_ALTERA_SYNTHESIZED(15 DOWNTO 11),
		 y => SYNTHESIZED_WIRE_0);


b2v_inst16 : mux2
GENERIC MAP(width => 32
			)
PORT MAP(s => MemtoReg,
		 d0 => ALUOut_ALTERA_SYNTHESIZED,
		 d1 => RDCLK_ALTERA_SYNTHESIZED,
		 y => WriteReg_ALTERA_SYNTHESIZED);


b2v_inst17 : flopr
GENERIC MAP(width => 32
			)
PORT MAP(clk => clk,
		 reset => reset,
		 d => RFRD_ALTERA_SYNTHESIZED2,
		 q => WD);


b2v_inst18 : flopr
GENERIC MAP(width => 32
			)
PORT MAP(clk => clk,
		 reset => reset,
		 d => RFRD_ALTERA_SYNTHESIZED1,
		 q => SYNTHESIZED_WIRE_1);


b2v_inst19 : mux2
GENERIC MAP(width => 32
			)
PORT MAP(s => ALUSrcA,
		 d0 => pc_ALTERA_SYNTHESIZED,
		 d1 => SYNTHESIZED_WIRE_1,
		 y => SrcA);


b2v_inst2 : mux4
GENERIC MAP(width => 32
			)
PORT MAP(d0 => WD,
		 d1 => SYNTHESIZED_WIRE_2,
		 d2 => SYNTHESIZED_WIRE_8,
		 d3 => SYNTHESIZED_WIRE_4,
		 s => AluSrcB,
		 y => SYNTHESIZED_WIRE_6);


b2v_inst20 : flopr
GENERIC MAP(width => 32
			)
PORT MAP(clk => clk,
		 reset => reset,
		 d => ALUResult,
		 q => ALUOut_ALTERA_SYNTHESIZED);


b2v_inst21 : flopr
GENERIC MAP(width => 32
			)
PORT MAP(clk => clk,
		 reset => reset,
		 d => ReadData,
		 q => RDCLK_ALTERA_SYNTHESIZED);


b2v_inst3 : sl2
PORT MAP(a => SYNTHESIZED_WIRE_8,
		 y => SYNTHESIZED_WIRE_4);


b2v_inst4 : intvec
GENERIC MAP(int => 4,
			width => 32
			)
PORT MAP(		 y => SYNTHESIZED_WIRE_2);


b2v_inst5 : alu
PORT MAP(a => SrcA,
		 alucontrol => ALUControl,
		 b => SYNTHESIZED_WIRE_6,
		 zero => Zero,
		 result => ALUResult);


b2v_inst6 : mux4
GENERIC MAP(width => 32
			)
PORT MAP(d0 => ALUResult,
		 d1 => ALUOut_ALTERA_SYNTHESIZED,
		 d2 => PCJump_ALTERA_SYNTHESIZED,
		 d3 => SYNTHESIZED_WIRE_7,
		 s => PCSrc,
		 y => pcNxt);


b2v_inst7 : jmpmerge
PORT MAP(instr => Instr_ALTERA_SYNTHESIZED(25 DOWNTO 0),
		 pchi => pc_ALTERA_SYNTHESIZED(31 DOWNTO 28),
		 y => PCJump_ALTERA_SYNTHESIZED);


b2v_inst8 : beqctrl
PORT MAP(zero => Zero,
		 branch => Branch,
		 pcwrite => PCWrite,
		 pcen => PCEn);


b2v_inst9 : intvec
GENERIC MAP(int => 0,
			width => 32
			)
PORT MAP(		 y => SYNTHESIZED_WIRE_7);

Adr <= PCAdr;
ALUOut <= ALUOut_ALTERA_SYNTHESIZED;
Funct(5 DOWNTO 0) <= Instr_ALTERA_SYNTHESIZED(5 DOWNTO 0);
Instr <= Instr_ALTERA_SYNTHESIZED;
Op(5 DOWNTO 0) <= Instr_ALTERA_SYNTHESIZED(31 DOWNTO 26);
pc <= pc_ALTERA_SYNTHESIZED;
PCJump <= PCJump_ALTERA_SYNTHESIZED;
RDCLK <= RDCLK_ALTERA_SYNTHESIZED;
RFRD1 <= RFRD_ALTERA_SYNTHESIZED1;
RFRD2 <= RFRD_ALTERA_SYNTHESIZED2;
WriteData <= WD;
WriteReg <= WriteReg_ALTERA_SYNTHESIZED;

END bdf_type;