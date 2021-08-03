library ieee;
use ieee.std_logic_1164.all;

entity multExceptBlock is
	port(
    exceptA_in:     in std_logic_vector(1 downto 0);
    exceptB_in:     in std_logic_vector(1 downto 0);
    exceptCode_out: out std_logic_vector(1 downto 0)
	);
end multExceptBlock;

architecture behave of multExceptBlock is
	type exception_type is (nan, inf, zero, num);
	type excetpion_table is array (exception_type, exception_type) of exception_type;

	constant exception_lut: excetpion_table := (
    --  ------------------------------------------------
    --  | nan     inf      zero     num         |      |
    --  ------------------------------------------------
         (nan,    nan,     nan,     nan),     --| nan  |        
         (nan,    inf,     nan,     inf),     --| inf  |       
         (nan,    nan,     zero,    zero),    --| zero |    
         (nan,    inf,     zero,    num)      --| num  | 		
        );

	signal except_a, except_b, except_c: exception_type;

begin
  
	with exceptA_in select
  except_a <=   num 	when "01",
                zero 	when "00",
                inf 	when "10",
                nan 	when others;
	
	with exceptB_in select
  except_b <=   num 	when "01",
                zero 	when "00",
                inf 	when "10",
                nan 	when others;
					
	except_c <= exception_lut(except_a, except_b);
	
	with except_c select
	exceptCode_out  <= 	"01"	when num,
                      "00"	when zero,
                      "10"	when inf,
                      "11"	when others;
end behave;

