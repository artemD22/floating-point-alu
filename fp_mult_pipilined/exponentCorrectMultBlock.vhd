library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exponentCorrectMultBlock is
  port(
    incExpNorm_in:    in  std_logic;  --increase exponent by one if one right shift after normalization occured
    incExpRound_in:   in  std_logic;  --increase exponent by one if carry out after rounding occured
    expC_in:          in  std_logic_vector(9 downto 0);
    correctExpC_out:  out std_logic_vector(9 downto 0)
  );
end exponentCorrectMultBlock;

architecture behave of exponentCorrectMultBlock is
  signal updatedExponent  :   std_logic_vector(9 downto 0);
  signal incVector        :   std_logic_vector(9 downto 0);
begin

  incVector   <=  std_logic_vector(to_unsigned(1, 10)) when (incExpNorm_in xor incExpRound_in) = '1' else
                  std_logic_vector(to_unsigned(2, 10)) when (incExpNorm_in and incExpRound_in) = '1' else
                  (others => '0');
  
	updatedExponent <= std_logic_vector(signed(expC_in) + signed(incVector));

              
  correctExpC_out <= updatedExponent;
end behave;