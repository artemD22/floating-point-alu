library ieee;
use ieee.std_logic_1164.all;

entity exceptCheckBlock is
	port(
		floatNum_in: 	    in std_logic_vector(30 downto 0);
		exceptCode_out:	  out std_logic_vector(1 downto 0)
	);
end exceptCheckBlock;

architecture behave of exceptCheckBlock is
	signal exp_val: std_logic_vector(1 downto 0);
	signal mant_val: std_logic;
begin
	
	--cheking exponent for three cases: 
	--(1) all zeros (exp_val = "00")
	--(2) non zero (exp_val = "01")
	--(3) all ones (exp_val = "11")
	--exp_val = "10" never occurs as it would mean 
	--that bitwise 'and' and bitwise 'or' 
	--return '1' and '0' resp. which is incorrect
	exp_check: process (floatNum_in) is
		variable exponent_temp: std_logic_vector(7 downto 0);
		variable exponent_and: std_logic;
		variable exponent_or: std_logic;
	begin
		exponent_temp := floatNum_in(30 downto 23);
		exponent_and := exponent_temp(0);
		exponent_or := exponent_temp(0);
		for i in 1 to 7 loop
			exponent_and := exponent_and and exponent_temp(i);
			exponent_or := exponent_or or exponent_temp(i);
		end loop;
		exp_val(0) <= exponent_or;
		exp_val(1) <= exponent_and; 
	end process exp_check;
	
	
	
	--checking significand for two cases:
	--(1) all zeros (mant_val = "0")
	--(2) non zero (mant_val = "1")
	mantissa_check: process (floatNum_in) is
		variable mantissa_temp: std_logic_vector(22 downto 0);
		variable mantissa_or: std_logic;
	begin
		mantissa_temp := floatNum_in(22 downto 0);
		mantissa_or := mantissa_temp(0);
		for i in 1 to 22 loop
			mantissa_or := mantissa_or or mantissa_temp(i);
		end loop;
		mant_val <= mantissa_or;
	end process mantissa_check;

	
--    ----------------------------------------------
--	  |       | exp_val | mant_val   | except_code |
--    |---------------------------------------------
--	  |  zero |   00    |     0      |      00     |
--	  |  num  |   01    |     x      |      01     |
--	  |  inf  |   11    |     0      |      10     |
--	  |  nan  |   11    |     1      |      11     |

	
	
	exceptCode_out(1) <= exp_val(1);
	exceptCode_out(0) <= (not exp_val(1) and exp_val(0)) or (exp_val(1) and exp_val(0) and mant_val);
end behave;

