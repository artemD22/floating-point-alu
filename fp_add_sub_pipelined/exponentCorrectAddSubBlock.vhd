library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exponentCorrectAddSubBlock is
  port(
    exponentC_in:         in  std_logic_vector(7 downto 0);
    rightRight_in:        in  std_logic;
    roundShift_in:        in  std_logic;
    bitsShiftLeft_in:     in  std_logic_vector(4 downto 0);
    correctExponent_out:  out std_logic_vector(9 downto 0)
  );
end exponentCorrectAddSubBlock; 

architecture behave of exponentCorrectAddSubBlock is
  -- one additinal bit for storing sign
  signal exponentNorm: std_logic_vector(9 downto 0);
  signal exponentRound: std_logic_vector(9 downto 0);
begin
  -- add 1 to exponent if significand was shifted right
  -- substract bitsShiftLeft_in if significand was shifted left
  exponentNorm  <=  std_logic_vector(unsigned("00" & exponentC_in) + 1) when rightRight_in = '1' else
                    std_logic_vector(unsigned("00" & exponentC_in) - unsigned("00000" & bitsShiftLeft_in));
  
  exponentRound <=  std_logic_vector(unsigned(exponentNorm) + 1) when roundShift_in = '1' else
                    exponentNorm;

  correctExponent_out <= exponentRound;
end behave;   