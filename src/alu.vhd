library ieee ;
    use ieee.std_logic_1164.all ;
    use ieee.numeric_std.all ;
	use ieee.std_logic_unsigned.all;

entity alu is
    port(a, b: in STD_LOGIC_VECTOR(31 downto 0);
        alucontrol: in STD_LOGIC_VECTOR(2 downto 0);
        result: buffer STD_LOGIC_VECTOR(31 downto 0);
        zero: out STD_LOGIC);
end alu ; 

architecture arch of alu is
 	function bool_to_slv(X : boolean)
            return STD_LOGIC_VECTOR  is
		begin
		  if X then
				return (x"00000001");
		  else
				return (x"00000000");
		  end if;
		end bool_to_slv;
begin
	with alucontrol select
        result <= a + b when "010",
				  a - b when "110",
        	a and b when "000",
        	a or b when "001",
				  a xor b when "011",
          bool_to_slv(a < b)  when "111" ,
				  a when others;
	zero<= '1' when result =x"00000000"	 else '0';
end architecture ;