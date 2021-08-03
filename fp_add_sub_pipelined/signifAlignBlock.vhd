library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

entity signifAlignBlock is
  port(
    signifA_in:       in  std_logic_vector(22 downto 0); 
    signifB_in:       in  std_logic_vector(22 downto 0);
    signA_in:         in  std_logic;
    signB_in:         in  std_logic;
    greaterExp_in:    in  std_logic;
    exponentDiff_in:  in  std_logic_vector(7 downto 0);
    alignedA_out:     out std_logic_vector(26 downto 0);  --sign bit + 23 significand bits + 3 rounding bits
    alignedB_out:     out std_logic_vector(26 downto 0);  --sign bit + 23 significand bits + 3 rounding bits
    signA_out:        out std_logic;
    signB_out:        out std_logic
  );
end entity signifAlignBlock;

architecture behave of signifAlignBlock is
component shift_block is
	port(
    shift:    in  std_logic_vector(7 downto 0);
    shiftIn:  in  std_logic_vector(23 downto 0);
    shiftOut: out std_logic_vector(50 downto 0));
end component;

  signal alignedNum         : std_logic_vector(23 downto 0); -- extended significand which includes implicit one and three rounding bits
  signal numToShift         : std_logic_vector(23 downto 0); -- extended significand which includes implicit one and three rounding bits
  signal shiftedExtNum      : std_logic_vector(50 downto 0);
  signal stickyBit          : std_logic;
  
begin
  sh_i  :	shift_block
  port map(
    shift     =>  exponentDiff_in,
    shiftIn   =>  numToShift,
    shiftOut  =>  shiftedExtNum
  );


  numToShift(23)      <= '1';         -- adding implicit one
  alignedNum(23)      <= '1';         -- adding implicit one
  
  numToShift(22 downto 0)         <= signifA_in when greaterExp_in = '0' else signifB_in; -- choosing extended significand to shift right (align)
  alignedNum(22 downto 0)         <= signifB_in when greaterExp_in = '0' else signifA_in; -- choosing extended significand to route to output
  

  sticky_value: process (shiftedExtNum) is 
		variable sticky_bit_v: std_logic;
	begin
		sticky_bit_v := shiftedExtNum(0);
		for i in 0 to 24 loop
			sticky_bit_v := sticky_bit_v or shiftedExtNum(i);
		end loop;
		stickyBit <= sticky_bit_v;
	end process sticky_value;
  
  alignedA_out(26 downto 3)   <= shiftedExtNum(50 downto 27);
  alignedA_out(2)             <= shiftedExtNum(26);
  alignedA_out(1)             <= shiftedExtNum(25);
  alignedA_out(0)             <= stickyBit;
  alignedB_out(26 downto 3)   <= alignedNum;
  alignedB_out(2 downto 0)    <= (others => '0');
  
  signA_out <= signA_in when greaterExp_in = '0' else signB_in; -- swapping signs in accordance with significands
  signB_out <= signB_in when greaterExp_in = '0' else signA_in; -- swapping signs in accordance with significands
  
end architecture behave;