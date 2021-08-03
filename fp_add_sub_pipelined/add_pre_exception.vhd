library ieee;
use ieee.std_logic_1164.all;

entity add_pre_exception is
	port(
		exceptCodeA_in:   in std_logic_vector(1 downto 0);
		exceptCodeB_in:   in std_logic_vector(1 downto 0);
    signA_in:         in std_logic;
    signB_in:         in std_logic;
		exceptCodeC_out:  out std_logic_vector(1 downto 0)
	);
end add_pre_exception;

architecture behave of add_pre_exception is
	type exception_type is (nan, p_inf, n_inf, p_zero, n_zero, num);
	type excetpion_table is array (exception_type, exception_type) of exception_type;
	
	constant exception_lut: excetpion_table := (
    --  --------------------------------------------------------------------
    --  | nan     p_inf     n_inf    p_zero    n_zero   num       |        |
    --  --------------------------------------------------------------------
         (nan,    nan,      nan,     nan,      nan,     nan),   --| nan    |      
         (nan,    p_inf,    nan,     p_inf,    p_inf,   p_inf), --| p_inf  |      
         (nan,    nan,      n_inf,   n_inf,    n_inf,   n_inf), --| n_inf  |       
         (nan,    p_inf,    n_inf,   p_zero,   p_zero,  num),   --| p_zero |   
         (nan,    p_inf,    n_inf,   p_zero,   n_zero,  num),   --| n_zero |    
         (nan,    p_inf,    n_inf,   num,      num,     num)    --| num    |  
        );
		  
	signal except_a, except_b, except_c: exception_type;
	
  signal except_code_a: std_logic_vector(2 downto 0);
  signal except_code_b: std_logic_vector(2 downto 0);

begin
  except_code_a <= signA_in & exceptCodeA_in;
  except_code_b <= signB_in & exceptCodeB_in;
  
	with except_code_a select
	except_a <= num 		when "001",
              num 		when "101",
              p_zero 	when "000",
              n_zero 	when "100",
              p_inf 	when "010",
              n_inf 	when "110",
              nan 		when others;
	
	with except_code_b select			
	except_b <= num 		when "001",
              num 		when "101",
              p_zero 	when "000",
              n_zero 	when "100",
              p_inf 	when "010",
              n_inf 	when "110",
              nan 		when others;
					
	except_c <= exception_lut(except_a, except_b);
	
	with except_c select
	exceptCodeC_out <= 	"01"	when num,
                      "00"	when p_zero,
                      "00"	when n_zero,
                      "10"	when p_inf,
                      "10"	when n_inf,
                      "11"	when nan;
	
end behave;

