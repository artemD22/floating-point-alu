library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exponentAdderBlock is
  port(
    expA_in:  in  std_logic_vector(7 downto 0);
    expB_in:  in  std_logic_vector(7 downto 0);
    expC_out: out std_logic_vector(9 downto 0)
  );
end exponentAdderBlock;

architecture behave of exponentAdderBlock is
begin
  expC_out <= std_logic_vector(unsigned("00" & expA_in) + unsigned("00" & expB_in) - 127);
end behave;
