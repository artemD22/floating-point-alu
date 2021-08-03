library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity signifNormBlock is
  port(
    denormSignifC_in: in  std_logic_vector(47 downto 0);
    stickyBit_out:    out std_logic;
    lowestBit_out:    out std_logic;
    guardBit_out:     out std_logic;
    incExp_out:       out std_logic; --increase exponent by one if one right shift after normalization occured
    normSignifC_out:  out std_logic_vector(23 downto 0)
  );
end signifNormBlock;

architecture behave of signifNormBlock is
	signal sticky_bit: std_logic;
	signal guard_bit: std_logic;
	signal lowest_bit: std_logic;
	signal highest_bit: std_logic;
	signal rnd: std_logic;
	
	signal mantissa_shift: std_logic;
	
	signal significand: std_logic_vector(23 downto 0);
	
begin
	
	highest_bit <= denormSignifC_in(47);
	
	significand <= denormSignifC_in(47 downto 24) when highest_bit = '1' else denormSignifC_in(46 downto 23);

	sticky_value: process (denormSignifC_in, highest_bit) is 
		variable sticky_bit_v: std_logic;
	begin
		sticky_bit_v := '0';
    
		for i in 0 to 21 loop
			sticky_bit_v := sticky_bit_v or denormSignifC_in(i);
		end loop;
    
		if (highest_bit = '1') then
			stickyBit_out <= sticky_bit_v or denormSignifC_in(22);
		else
			stickyBit_out <= sticky_bit_v;
		end if;
	end process sticky_value;
	
  guardBit_out <= denormSignifC_in(23) when highest_bit = '1' else denormSignifC_in(22);
	lowestBit_out <= significand(0);
  normSignifC_out <= significand;
  incExp_out <= highest_bit;
end behave;