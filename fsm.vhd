library IEEE; use IEEE.STD_LOGIC_1164.all;

entity fsm is -- finite state machine
    port(clk,reset		:in std_logic;
		Opcode			:in std_logic_vector(5 downto 0);
		MemtoReg,RegDst	:out std_logic;
		IorD			:out std_logic;
		ALUSrcB,PCSrc	:out std_logic_vector(1 downto 0);
		AluSrcA,IRWrite	:out std_logic;
		MemWrite,PCWrite:out std_logic;
		Branch,RegWrite	:out std_logic;
		ALUOp			:out std_logic_vector(1 downto 0)
	);
end;
architecture behave of fsm is
	constant S_FECTH		:integer:=0;
	constant S_DECODE		:integer:=1;
	constant S_MEMADR		:integer:=2;
	constant S_MEMREAD		:integer:=3;
	constant S_MEMWRITEBACK	:integer:=4;
	constant S_MEMWRITE		:integer:=5;
	constant S_EXECUTE		:integer:=6;
	constant S_ALUWRITEBACK	:integer:=7;
	constant S_BRANCH		:integer:=8;
	constant S_ADDIEXEC		:integer:=9;
	constant S_ADDIWRITEBACK:integer:=10;
	constant S_JUMP			:integer:=11;
	
	constant OP_RTYPE	:std_logic_vector(5 downto 0):="000000";
	constant OP_LW		:std_logic_vector(5 downto 0):="100011";
	constant OP_SW		:std_logic_vector(5 downto 0):="101011";
	constant OP_BEQ		:std_logic_vector(5 downto 0):="000100";
	constant OP_ADDI	:std_logic_vector(5 downto 0):="001000";
	constant OP_J		:std_logic_vector(5 downto 0):="000010";
	
begin
	process(all) is
	variable stateNow 	:integer:=0;
	begin
		if(reset='1') then
			stateNow:=S_FECTH;
		elsif rising_edge(clk) then
		
			case stateNow is
				when S_FECTH		=>
						IorD<='0';
						AluSrcA<='0';
						ALUSrcB<="01";
						ALUOp<="00";
						PCSrc<="00";
						
						IRWrite<='1';
						PCWrite<='1';
						MemWrite<='0';
						RegWrite<='0';
						Branch<='0';
				when S_DECODE		=>
						AluSrcA<='0';
						ALUSrcB<="11";
						ALUOp<="00";
						
						IRWrite<='0';
						PCWrite<='0';
						MemWrite<='0';
						RegWrite<='0';
						Branch<='0';
				when S_MEMADR		=>
						AluSrcA<='1';
						ALUSrcB<="10";
						ALUOp<="00";
				when S_MEMREAD		=>
						IorD<='1';
				when S_MEMWRITEBACK	=>
						RegDst<='0';
						MemtoReg<='1';
						
						RegWrite<='1';
				when S_MEMWRITE		=>
						IorD<='1';
						
						MemWrite<='1';
				when S_EXECUTE		=>
						AluSrcA<='1';
						ALUSrcB<="00";
						ALUOp<="10";
				when S_ALUWRITEBACK	=>
						RegDst<='1';
						MemtoReg<='0';
						
						RegWrite<='1';
				when S_BRANCH		=>
						AluSrcA<='1';
						ALUSrcB<="00";
						ALUOp<="01";
						PCSrc<="01";
						
						Branch<='1';
				when S_ADDIEXEC		=>
						AluSrcA<='1';
						ALUSrcB<="10";
						ALUOp<="00";
						
				when S_ADDIWRITEBACK=>
						RegDst<='0';
						MemtoReg<='0';
						
						RegWrite<='1';
				when S_JUMP			=>
						PCSrc<="10";
						
						PCWrite<='1';
				when others 		=>
					null;
			end case;
			
			case stateNow is
				when S_FECTH		=>
					stateNow:=S_DECODE;
				when S_DECODE		=>
					case Opcode is
						when OP_LW|OP_SW 	=>
							stateNow:=S_MEMADR;
						when OP_BEQ 		=>
							stateNow:=S_BRANCH;
						when OP_ADDI		=>
							stateNow:=S_ADDIEXEC;
						when OP_J			=>
							stateNow:=S_JUMP;
						when others			=>
							stateNow:=S_EXECUTE;
					end case;
				when S_MEMADR		=>
					if(Opcode=OP_LW)then
						stateNow:=S_MEMREAD;
					elsif(Opcode=OP_SW)then
						stateNow:=S_MEMWRITE;
					end if;
				when S_MEMREAD		=>
					stateNow:=S_MEMWRITEBACK;
				when S_MEMWRITEBACK	=>
					stateNow:=S_FECTH;
				when S_MEMWRITE		=>
					stateNow:=S_FECTH;
				when S_EXECUTE		=>
					stateNow:=S_ALUWRITEBACK;
				when S_ALUWRITEBACK	=>
					stateNow:=S_FECTH;
				when S_BRANCH		=>
					stateNow:=S_FECTH;
				when S_ADDIEXEC		=>
					stateNow:=S_ADDIWRITEBACK;
				when S_ADDIWRITEBACK=>
					stateNow:=S_FECTH;
				when S_JUMP			=>
					stateNow:=S_FECTH;
				when others 		=>
					null;
			end case;
		end if;
--		MemtoReg,RegDst	:out std_logic;
--		IorD,PCSrc		:out std_logic;
--		ALUSrcB			:out std_logic_vector(1 downto 0);
--		AluSrcA,IRWrite	:out std_logic;
--		MemWrite,PCWrite:out std_logic;
--		Branch,RegWrite	:out std_logic;
--		ALUOp			:out std_logic_vector(1 downto 0)
	end process;
end;