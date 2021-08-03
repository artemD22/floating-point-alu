library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity signifNormPart1Block is
  port(
    signifC_in:           in  std_logic_vector(27 downto 0);  --27 bit sum and sign bit
    overflow_in:          in  std_logic;
    signA_in:             in std_logic;
    signB_in:             in std_logic;
    signifC_out:          out std_logic_vector(27 downto 0);  
    toShiftRight_out:     out std_logic;
    bitsShiftLeft_out:    out std_logic_vector(4 downto 0);
    resultSign_out:       out std_logic
  );
end signifNormPart1Block;

architecture behave of signifNormPart1Block is

  component lod_norm is
    port(
      lod_in:       in std_logic_vector(26 downto 0);
      lod_num_out:  out std_logic_vector(4 downto 0)
    );
  end component lod_norm;

  signal toInvert       :   std_logic;
  signal toShiftRight   :   std_logic;
  signal invertedNum    :   std_logic_vector(27 downto 0);
  signal signifC        :   std_logic_vector(27 downto 0);
  signal shiftedNum     :   std_logic_vector(26 downto 0);

  begin
  
  lod_norm_i: lod_norm 
  port map(
    -- detecting leading one in number with sign equals to '0', otherwise number has carry in sign bit 
    -- and needs to be shifted right
    -- (signifC'left-1 downto 0) means to omit sign bit
    lod_in      =>  signifC(signifC'left-1 downto 0),
    lod_num_out =>  bitsShiftLeft_out
  );
  
  --invert when result sign equal to '1' but no overflow occured, i.e. result is negative
  toInvert      <= signifC_in(signifC_in'left) and not(overflow_in); 
  invertedNum   <= std_logic_vector(unsigned(not(signifC_in)) + 1);
  signifC       <= invertedNum when toInvert = '1' else signifC_in;
  signifC_out   <=  signifC;
  
  -- shift right when sign bit equals to '1' and overflow occured, i.e. two positive numbers produced carry in sign bit
  -- (situation with two negative numbers never occurs because two negative numbers are represetnted as positive ones; see "signCorrectBlock")
  -- if inverted number has leftmost bit equals to '1', then also shift right
  -- e.g. -8 = 1000(two's complement) and 8 = 1000 have same leftmost bit
  
  toShiftRight      <= overflow_in or (signifC(signifC'left) and toInvert); 
  toShiftRight_out  <= toShiftRight;
 
  resultSign_out    <=  toInvert or (signA_in and signB_in);
end behave;
