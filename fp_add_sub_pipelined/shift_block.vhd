LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all; 

entity shift_block is
	port(shift: in STD_LOGIC_VECTOR(7 downto 0);
		 shiftIn: in STD_LOGIC_VECTOR(23 downto 0);
		 shiftOut: out STD_LOGIC_VECTOR(50 downto 0));
end shift_block;

architecture behave of shift_block is
signal shift_temp: STD_LOGIC_VECTOR (50 downto 0);
signal shift_zero: std_logic;
begin
shift_zero <= '1' when shift > std_logic_vector(to_unsigned(28, 8)) else '0';

shift_temp(50 downto 27) <= shiftIn;
shift_temp(26 downto 0) <= (others => '0');

	process (shift, shift_temp, shiftIn, shift_zero)
	variable temp1: STD_LOGIC_VECTOR (50 downto 0);
	variable temp2: STD_LOGIC_VECTOR (50 downto 0);
	variable temp3: STD_LOGIC_VECTOR (50 downto 0);
	variable temp4: STD_LOGIC_VECTOR (50 downto 0);
	variable temp5: STD_LOGIC_VECTOR (50 downto 0);
	variable temp6: STD_LOGIC_VECTOR (50 downto 0);
	begin
		if (shift(0)='0') then
		temp1 := shift_temp;
		else
		temp1(50) := '0';
		for i in shift_temp'high downto 1 loop
		temp1(i-1) := shift_temp(i);
		end loop;
		end if;

		---- 2nd shifter -----
		if (shift(1)='0') then
		temp2 := temp1;
		else
		for i in 0 to 1 loop
		temp2(50-i) := '0';
		end loop;
		for i in shift_temp'high downto 2 loop
		temp2(i-2) := temp1(i);
		end loop;
		end if;

		---- 3rd shifter -----
		if (shift(2)='0') then
		temp3 := temp2;
		else
		for i in 0 to 3 loop
		temp3(50-i) := '0';
		end loop;
		for i in shift_temp'high downto 4 loop
		temp3(i-4) := temp2(i);
		end loop;
		end if;

		---- 4th shifter -----
		if (shift(3)='0') then
		temp4 := temp3;
		else
		for i in 0 to 7 loop
		temp4(50-i) := '0';
		end loop;
		for i in shift_temp'high downto 8 loop
		temp4(i-8) := temp3(i);
		end loop;
		end if;

		---- 5th shifter -----
		if (shift(4)='0') then
		temp5 := temp4;
		else
		for i in 0 to 15 loop
		temp5(50-i) := '0';
		end loop;
		for i in shift_temp'high downto 16 loop
		temp5(i-16) := temp4(i);
		end loop;
		end if;
		
		if (shift_zero = '1') then
    shiftOut(50 downto 24) <= (others => '0');
    shiftOut(23 downto 0) <= shiftIn;
		else
		shiftOut(50 downto 0) <= temp5;
		end if;

	end process;
end behave;