--********************************************************************************************************************--
--! 
--! sign correction is done in order to simplify addition
--! if two numbers have same sign then addition is done as they were positive numbers: 
--! ((+a)+(+b))= (a+b) // ((-a)+(-b))=-(a+b)
--! otherwise negative number is resprents as two's complement
--!
--********************************************************************************************************************--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity signCorrectBlock is
   port (
    signifA_in:         in std_logic_vector(26 downto 0); --sign bit + 23 significand bits + 3 rounding bits
    signifB_in:         in std_logic_vector(26 downto 0); --sign bit + 23 significand bits + 3 rounding bits
    signA_in:           in std_logic;
    signB_in:           in std_logic;
    correctSignA_out:   out std_logic;
    correctSignB_out:   out std_logic;
    signifA_out:        out std_logic_vector(26 downto 0);
    signifB_out:        out std_logic_vector(26 downto 0)
   );
end entity signCorrectBlock;

architecture behave of signCorrectBlock is

  signal whichIsNegative  : std_logic;
  signal isSameSign       : std_logic;
  signal numToComplement  : std_logic_vector(26 downto 0);
  signal twosComplement   : std_logic_vector(26 downto 0);
  
begin

  whichIsNegative <= signA_in and not signB_in;   --if '1' then A is negative and B is positive, 
                                                  --if '0' then B is negative and A is positive, 
                                                  
  isSameSign      <= signA_in xnor signB_in;      --if '1' then two numbers have same sings, '0' otherwise
  
  numToComplement <= signifA_in when whichIsNegative = '1' else signifB_in;
  
  twosComplement  <= std_logic_vector(unsigned(not(numToComplement)) + 1);
  
  signifA_out     <=  twosComplement when (whichIsNegative = '1' and isSameSign = '0') else signifA_in;
  signifB_out     <=  twosComplement when (whichIsNegative = '0' and isSameSign = '0') else signifB_in;
  
  correctSignA_out      <= whichIsNegative and not isSameSign;
  correctSignB_out      <= not whichIsNegative and not isSameSign;
  
end architecture behave;