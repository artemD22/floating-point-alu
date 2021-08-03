library ieee;
use ieee.std_logic_1164.all;

entity signBlock is
  port(
    signA_in:  in  std_logic;
    signB_in:  in  std_logic;
    signC_out: out std_logic
  );
end signBlock;

architecture behave of signBlock is
begin
  signC_out <= signA_in xor signB_in;
end behave;