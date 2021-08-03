library ieee;
use ieee.std_logic_1164.all;

entity resultExceptCheckBlock is
  port(
    exponentC_in:       in  std_logic_vector(9 downto 0);
    signifC_in:         in  std_logic_vector(23 downto 0);
    preExceptCode_in:   in  std_logic_vector(1 downto 0);
    signifC_out:        out std_logic_vector(22 downto 0);
    exponentC_out:      out std_logic_vector(7 downto 0);
    zero:               out std_logic;
    inf:                out std_logic;
    nan:                out std_logic
  );
end resultExceptCheckBlock;

architecture behave of resultExceptCheckBlock is


  signal exp_zero           :   std_logic;
  signal exp_inf            :   std_logic;
  signal ones_exp           :   std_logic;
  signal zeros_exp          :   std_logic;
  signal signif_zero        :   std_logic;
  
  signal preExceptZero      :   std_logic;
  signal preExceptInfinity  :   std_logic;
  signal preExceptNan       :   std_logic; 
  
  signal isInfinity         :   std_logic;
  signal isZero             :   std_logic;
  
  signal zero_i             :   std_logic;
  signal inf_i              :   std_logic;
  signal nan_i              :   std_logic;
  
  signal exceptPriority: std_logic;
  
begin
  signif_zero   <= not signifC_in(signifC_in'left); -- if implicit one equals ot '0' then whole significand is zero

  	exp_check: process (exponentC_in) is
		variable exponent_or  : std_logic;
		variable exponent_and : std_logic;
	begin
		exponent_or   :=  exponentC_in(0);
		exponent_and  :=  exponentC_in(0);
		for i in 1 to 9 loop
			exponent_or   :=  exponent_or or exponentC_in(i);
		end loop;
    for i in 1 to 7 loop
			exponent_and  :=  exponent_and and exponentC_in(i);
		end loop;
		zeros_exp  <= not(exponent_or); 
		ones_exp   <= exponent_and; 
	end process exp_check;
  
  --sign (9th bit) equals to '1', i.e. exponent is negative after correction on previous block
  exp_zero  <= zeros_exp or exponentC_in(exponentC_in'left);    
  
  --8th bit equals to '1', i.e. exponent is positive and carry out occured while correcting exponent on previous block
  exp_inf   <= ones_exp or (not(exponentC_in(exponentC_in'left)) and exponentC_in(exponentC_in'left-1)); 
  
  
  
  isInfinity          <=  exp_inf;
  isZero              <=  exp_zero or signif_zero;
  
  preExceptZero       <=  not preExceptCode_in(1) and not preExceptCode_in(0);
  preExceptInfinity   <=  preExceptCode_in(1) and not preExceptCode_in(0);
  preExceptNan        <=  preExceptCode_in(1) and preExceptCode_in(0);
  
  exceptPriority      <=  preExceptZero or preExceptInfinity or preExceptNan;
  
  zero_i              <=    preExceptZero when exceptPriority = '1' else isZero;
  inf_i               <=    preExceptInfinity when exceptPriority = '1' else isInfinity;
  nan_i               <=    preExceptNan when exceptPriority = '1' else '0';
  
  signifC_out <=  (others => '0') when (zero_i = '1' or inf_i = '1') else
                  "10101010101010101010101" when nan_i = '1' else
                  signifC_in(signifC_in'left-1 downto 0);
               
  exponentC_out   <=  (others => '0') when zero_i = '1' else
                      (others => '1') when inf_i = '1' or nan_i = '1' else
                      exponentC_in(exponentC_in'left-2 downto 0);
                  
  zero        <=  zero_i;
  inf         <=  inf_i;
  nan         <=  nan_i;
end behave;