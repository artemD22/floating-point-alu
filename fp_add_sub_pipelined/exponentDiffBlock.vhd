library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity exponentDiffBlock is
  port (
    exponentA_in:     in  std_logic_vector(7 downto 0);
    exponentB_in:     in  std_logic_vector(7 downto 0);
    exponentC_out:    out std_logic_vector(7 downto 0);
    exponentDiff_out: out std_logic_vector(7 downto 0);
    greaterExp_out:   out std_logic
  );
end entity exponentDiffBlock;

architecture behave of exponentDiffBlock is
  signal greatExpCheck: std_logic;
  signal greaterExponent: std_logic_vector(7 downto 0);
  signal smallerExponent: std_logic_vector(7 downto 0);
begin
	
	greatExpCheck <= '1' when (exponentA_in > exponentB_in) else '0';
	
  greaterExponent <= exponentA_in when greatExpCheck = '1' else exponentB_in;
  smallerExponent <= exponentB_in when greatExpCheck = '1' else exponentA_in;
  
	greaterExp_out <= greatExpCheck;
  
	exponentDiff_out  <=  std_logic_vector(unsigned(greaterExponent) - unsigned(smallerExponent));
	
	exponentC_out <= greaterExponent;
  
end architecture behave;