library ieee; 
use ieee.std_logic_1164.all;

entity signifNormPart2Block is
  port(
    signifC_in:           in std_logic_vector(27 downto 0);
    toShiftRight_in:      in std_logic;
    bitsShiftLeft_in:     in std_logic_vector(4 downto 0);
    normSignifC_out:      out std_logic_vector(26 downto 0)
  );
end signifNormPart2Block;

architecture behave of signifNormPart2Block is

  component left_shift_norm is
    port(left_in: in std_logic_vector(26 downto 0);
       shift_norm: in std_logic_vector(4 downto 0);
       left_out: out std_logic_vector(26 downto 0)
       );
  end component;

  signal shiftedLeftSignif  : std_logic_vector(26 downto 0);
  signal shiftedRightSignif : std_logic_vector(26 downto 0);
  
begin

  left_shift_norm_i: left_shift_norm 
  port map(
    left_in     =>  signifC_in(signifC_in'left-1 downto 0), 
    shift_norm  =>  bitsShiftLeft_in, 
    left_out    =>  shiftedLeftSignif
  );

  shiftedRightSignif  <=  signifC_in(signifC_in'left downto 1);
  normSignifC_out     <=  shiftedRightSignif when toShiftRight_in = '1' else
                          shiftedLeftSignif;

end behave;