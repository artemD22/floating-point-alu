library ieee;
use ieee.std_logic_1164.all;

entity addSubExceptBlock is
	port(
    exceptA_in:         in std_logic_vector(1 downto 0);
		exceptB_in:         in std_logic_vector(1 downto 0);
    signA_in:           in std_logic;
    signB_in:           in std_logic;
    add_sub_in:         in std_logic;
		exceptCodeC_out:    out std_logic_vector(1 downto 0)
	);
end addSubExceptBlock;


architecture behave of addSubExceptBlock is

  component add_pre_exception is
    port(
      exceptCodeA_in:   in std_logic_vector(1 downto 0);
      exceptCodeB_in:   in std_logic_vector(1 downto 0);
      signA_in:         in std_logic;
      signB_in:         in std_logic;
      exceptCodeC_out:  out std_logic_vector(1 downto 0)
    );
  end component add_pre_exception;
  
  component sub_pre_exception is
    port(
      exceptCodeA_in:   in std_logic_vector(1 downto 0);
      exceptCodeB_in:   in std_logic_vector(1 downto 0);
      signA_in:         in std_logic;
      signB_in:         in std_logic;
      exceptCodeC_out:  out std_logic_vector(1 downto 0)
    );
  end component sub_pre_exception;
  
  signal exceptCodeAdd  :   std_logic_vector(1 downto 0);
  signal exceptCodeSub  :   std_logic_vector(1 downto 0);
  
begin
  add_pre_exception_i: add_pre_exception
  port map
  (
    exceptCodeA_in  =>  exceptA_in,
    exceptCodeB_in  =>  exceptB_in,
    signA_in        =>  signA_in,
    signB_in        =>  signA_in,
    exceptCodeC_out =>  exceptCodeAdd
  );
  
  sub_pre_exception_i: sub_pre_exception
  port map
  (
    exceptCodeA_in  =>  exceptA_in,
    exceptCodeB_in  =>  exceptB_in,
    signA_in        =>  signA_in,
    signB_in        =>  signB_in,
    exceptCodeC_out =>  exceptCodeSub
  );
  
  exceptCodeC_out   <=  exceptCodeAdd when add_sub_in = '1' else
                        exceptCodeSub;
  
end behave;