library IEEE; 
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity lod_norm is
	port(lod_in: in STD_LOGIC_VECTOR(26 downto 0);
		 lod_num_out: out STD_LOGIC_VECTOR(4 downto 0)
		);
end lod_norm;

architecture behav of lod_norm is
signal num: STD_LOGIC_VECTOR(7 downto 0);
begin
num <= 	X"00" when lod_in(26) =  '1' else
		X"01" when lod_in(25) =  '1' else
		X"02" when lod_in(24) =  '1' else
		X"03" when lod_in(23) =  '1' else
		X"04" when lod_in(22) =  '1' else
		X"05" when lod_in(21) =  '1' else
		X"06" when lod_in(20) =  '1' else
		X"07" when lod_in(19) =  '1' else
		X"08" when lod_in(18) =  '1' else
		X"09" when lod_in(17) =  '1' else
		X"0A" when lod_in(16) =  '1' else
		X"0B" when lod_in(15) =  '1' else
		X"0C" when lod_in(14) =  '1' else
		X"0D" when lod_in(13) =  '1' else
		X"0E" when lod_in(12) =  '1' else
		X"0F" when lod_in(11) =  '1' else
		X"10" when lod_in(10) =  '1' else
		X"11" when lod_in(9) =  '1' else
		X"12" when lod_in(8) =  '1' else
		X"13" when lod_in(7) =  '1' else
		X"14" when lod_in(6) =  '1' else
		X"15" when lod_in(5) =  '1' else
		X"16" when lod_in(4) =  '1' else
		X"17" when lod_in(3) =  '1' else
		X"18" when lod_in(2) =  '1' else
		X"19" when lod_in(1) =  '1' else
		X"1A" when lod_in(0) =  '1' else
		X"00";
		lod_num_out <= num(4 downto 0);
end behav;