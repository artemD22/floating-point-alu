LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all; 

entity left_shift_norm is
	port(left_in: in STD_LOGIC_VECTOR(26 downto 0);
		 shift_norm: in STD_LOGIC_VECTOR(4 downto 0);
		 left_out: out STD_LOGIC_VECTOR(26 downto 0)
		 );
end left_shift_norm;

architecture behave of left_shift_norm is
begin
	process (shift_norm, left_in)
	variable temp1: STD_LOGIC_VECTOR (26 downto 0);
	variable temp2: STD_LOGIC_VECTOR (26 downto 0);
	variable temp3: STD_LOGIC_VECTOR (26 downto 0);
	variable temp4: STD_LOGIC_VECTOR (26 downto 0);
	begin

		if (shift_norm(0)='0') then
		temp1 := left_in;
		else
		temp1(0) := '0';
		for i in 1 to left_in'high loop
		temp1(i) := left_in(i-1);
		end loop;
		end if;

		---- 2nd shifter -----
		if (shift_norm(1)='0') then
		temp2 := temp1;
		else
		for i in 0 to 1 loop
		temp2(i) := '0';
		end loop;
		for i in 2 to left_in'high loop
		temp2(i) := temp1(i-2);
		end loop;
		end if;

		---- 3rd shifter -----
		if (shift_norm(2)='0') then
		temp3 := temp2;
		else
		for i in 0 to 3 loop
		temp3(i) := '0';
		end loop;
		for i in 4 to left_in'high loop
		temp3(i) := temp2(i-4);
		end loop;
		end if;

		---- 4th shifter -----
		if (shift_norm(3)='0') then
		temp4 := temp3;
		else
		for i in 0 to 7 loop
		temp4(i) := '0';
		end loop;
		for i in 8 to left_in'high loop
		temp4(i) := temp3(i-8);
		end loop;
		end if;

		---- 5th shifter -----
		if (shift_norm(4)='0') then
		left_out <= temp4;
		else
		for i in 0 to 15 loop
		left_out(i) <= '0';
		end loop;
		for i in 16 to left_in'high loop
		left_out(i) <= temp4(i-16);
		end loop;
		end if;
	end process;
end behave;