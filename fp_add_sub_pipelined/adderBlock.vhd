library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adderBlock is
	port(
    signifA_in:   in  std_logic_vector(26 downto 0);  --one bit for implicit one, 23 significand bits and 3 bits for rounding
    signifB_in:   in  std_logic_vector(26 downto 0);  --one bit for implicit one, 23 significand bits and 3 bits for rounding
    signA_in:     in  std_logic;
    signB_in:     in  std_logic;
    signifC_out:  out std_logic_vector(27 downto 0);  --result with sign bit
    overflow_out: out std_logic
  );
end adderBlock;

architecture behave of adderBlock is
  signal signifSum  : std_logic_vector(27 downto 0);
begin

  signifSum     <= std_logic_vector(unsigned(signA_in & signifA_in) + unsigned(signB_in & signifB_in));
  signifC_out   <= signifSum;
  overflow_out  <= not(signA_in) and not(signB_in) and signifSum(signifSum'high);
  
end behave;