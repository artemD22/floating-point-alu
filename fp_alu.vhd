library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fp_alu is
  port (
    clk:                in std_logic;
    rst_n:              in std_logic;
    A_in:               in std_logic_vector(31 downto 0);
    B_in:               in std_logic_vector(31 downto 0);
    op_code:            in std_logic_vector(1 downto 0);
    C_out:              out std_logic_vector(31 downto 0);
    zero:               out std_logic;
    inf:                out std_logic;
    nan:                out std_logic
  );
end entity fp_alu;

architecture structural of fp_alu is

component fp_mult_pipelined is
  port
  (
    clk:                in std_logic;
    rst_n:              in std_logic;
    A_in:               in  std_logic_vector(31 downto 0);
    B_in:               in  std_logic_vector(31 downto 0);
    signC_out:          out std_logic;                     
    exponentC_out:      out std_logic_vector(9 downto 0);   
    signifC_out:        out std_logic_vector(23 downto 0);
    preExceptCode_out:  out std_logic_vector(1 downto 0)
  );
end component fp_mult_pipelined;

component fpu_add_sub_pipelined is
  port(
    clk:                in  std_logic;
    rst_n:              in  std_logic;
    A_in:               in  std_logic_vector(31 downto 0);
    B_in:               in  std_logic_vector(31 downto 0);
    add_sub_in:         in  std_logic;
    signC_out:          out std_logic;                     
    exponentC_out:      out std_logic_vector(9 downto 0);   
    signifC_out:        out std_logic_vector(23 downto 0);
    preExceptCode_out:  out std_logic_vector(1 downto 0)
  );
end component fpu_add_sub_pipelined;

component resultExceptCheckBlock is
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
end component resultExceptCheckBlock;
  
  signal multOutput:      std_logic_vector(36 downto 0);
  signal addSubOutput:    std_logic_vector(36 downto 0);
  signal selectedResult:  std_logic_vector(36 downto 0);
  signal result:          std_logic_vector(34 downto 0);
  signal result_r:        std_logic_vector(34 downto 0);
  
begin
  fp_mult_pipelined_i: fp_mult_pipelined
  port map(
    clk                 =>  clk,
    rst_n               =>  rst_n,
    A_in                =>  A_in,
    B_in                =>  B_in,
    signC_out           =>  multOutput(36),
    exponentC_out       =>  multOutput(35 downto 26),
    signifC_out         =>  multOutput(25 downto 2),
    preExceptCode_out   =>  multOutput(1 downto 0)
  );
  
  fpu_add_sub_pipelined_i: fpu_add_sub_pipelined
  port map(
    clk                 =>  clk,
    rst_n               =>  rst_n,
    A_in                =>  A_in,
    B_in                =>  B_in,
    add_sub_in          =>  op_code(0),
    signC_out           =>  addSubOutput(36),
    exponentC_out       =>  addSubOutput(35 downto 26),
    signifC_out         =>  addSubOutput(25 downto 2),
    preExceptCode_out   =>  addSubOutput(1 downto 0)
  );
  
  
  selectedResult        <=  multOutput when op_code = "10" else addSubOutput;
  
  resultExceptCheckBlock_i: resultExceptCheckBlock
  port map(
    exponentC_in        =>  selectedResult(35 downto 26),
    signifC_in          =>  selectedResult(25 downto 2),
    preExceptCode_in    =>  selectedResult(1 downto 0),
    signifC_out         =>  result(25 downto 3),
    exponentC_out       =>  result(33 downto 26),
    zero                =>  result(2),
    inf                 =>  result(1),
    nan                 =>  result(0)
  );
  
  result(34)            <=  selectedResult(36);
  
  process (clk, rst_n) is
  begin
    if (rst_n = '0') then
      result_r  <= (others => '0');
    elsif (rising_edge(clk)) then
      result_r  <= result;
    end if;
  end process;
  
  C_out   <= result_r(34 downto 3);
  zero    <= result_r(2);
  inf     <= result_r(1);
  nan     <= result_r(0);
  
end architecture structural;