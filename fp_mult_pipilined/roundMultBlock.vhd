library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity roundMultBlock is
  port(
    stickyBit_in:       in std_logic;
    lowestBit_in:       in std_logic;
    guardBit_in:        in std_logic;
    unroundSignifC_in:  in std_logic_vector(23 downto 0);
    incExp_out:         out std_logic;                     -- increase exponent by one if carry out after rounding occured
    roundSignifC_out:   out std_logic_vector(23 downto 0)
  );
end roundMultBlock;

architecture behave of roundMultBlock is
  signal roundSignifC: std_logic_vector(24 downto 0);
  signal rnd: std_logic;
  signal mantissa_shift: std_logic;
begin

	
	rnd <= (lowestBit_in and guardBit_in) or (not(lowestBit_in) and stickyBit_in and guardBit_in);
	
  roundSignifC <= std_logic_vector(unsigned('0' & unroundSignifC_in) + 1) when rnd = '1' else ('0' & unroundSignifC_in);
	
	mantissa_shift <= roundSignifC(24);
	incExp_out <= mantissa_shift;
	
	roundSignifC_out <= roundSignifC(24 downto 1) when mantissa_shift = '1'
											else roundSignifC(23 downto 0);
end behave;