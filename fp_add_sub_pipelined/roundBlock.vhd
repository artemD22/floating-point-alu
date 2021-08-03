library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity roundAddSubBlock is
  port(
    roundSignifC_in:      in  std_logic_vector(26 downto 0);  -- significand with implicit one and three additional bits
    roundSignifC_out:     out std_logic_vector(23 downto 0);  -- significand with implicit one
    roundShiftExp_out:    out std_logic     
  );
end roundAddSubBlock; 

architecture behave of roundAddSubBlock is
  signal roundSignif  :   std_logic_vector(23 downto 0);
  signal rnd          :   std_logic;
  signal isZero       :   std_logic;
  signal highestBit   :   std_logic;
  signal lowestBit    :   std_logic;
  signal guardBit     :   std_logic;
  signal roundBit     :   std_logic;
  signal stickyBit    :   std_logic;
  signal roundShift   :   std_logic;
  
  signal rndVector    :   std_logic_vector(23 downto 0); 
begin

  highestBit  <=  roundSignifC_in(roundSignifC_in'left);
  lowestBit   <=  roundSignifC_in(3);
  guardBit    <=  roundSignifC_in(2);
  roundBit    <=  roundSignifC_in(1);
  stickyBit   <=  roundSignifC_in(0);
  rnd         <=  guardBit and (lowestBit or roundBit or stickyBit);
  
  rndVector(23 downto 1)    <=  (others => '0');
  rndVector(0)              <=  rnd;
  
  -- round means adding one to lowest bit of significand
  roundSignif     <=  std_logic_vector(unsigned(roundSignifC_in(roundSignifC_in'left downto 3)) + unsigned(rndVector));
  
  
  -- if leftmost bit equals to '0', then carry out occured after rounding
  -- roundSignC_in leftmost bit always equals '1' (except if there is zero significand)
  roundShift        <=  not(roundSignif(roundSignif'left)) and highestBit;
  roundShiftExp_out <=  roundShift;
  
  roundSignifC_out  <=  '1' & roundSignif(roundSignif'left downto 1) when roundShift = '1' else
                        roundSignif(roundSignif'left downto 0);
  
end behave;