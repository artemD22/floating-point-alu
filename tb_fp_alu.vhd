library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;


entity tb_fp_alu is
end entity tb_fp_alu;

architecture testbench of tb_fp_alu is
component fp_alu is
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
end component fp_alu;

  signal clk:               std_logic := '1';
  signal clk_alu:           std_logic := '0';
  signal rst_n:             std_logic := '0';
  signal A_in:              std_logic_vector(31 downto 0);
  signal B_in:              std_logic_vector(31 downto 0);
  signal op_code:           std_logic_vector(1 downto 0) := "10";
  signal C_out:             std_logic_vector(31 downto 0);
  signal zero:              std_logic;
  signal inf:               std_logic;
  signal nan:               std_logic;
  
  file inputData:           text open read_mode is "inputData.txt";
  file resultData:          text open write_mode is "generatedDataBinary.txt";
begin
  DUT: fp_alu
  port map(clk, rst_n, A_in, B_in, op_code, C_out, zero, inf, nan);
  
  clock_gen: process is
  begin
    clk <= not clk;
    wait for 20 ns;
  end process clock_gen;
  
  rst_n <= '1' after 40 ns;
  
  num_test: process(clk, rst_n) is
  
    variable readOperandRow   : line;
    variable writeOperandRow  : line;
    variable firstOperand     : bit_vector(31 downto 0);
    variable secondOperand    : bit_vector(31 downto 0);
    variable result           : std_logic_vector(31 downto 0);
    variable resultToWrite    : bit_vector(31 downto 0);
    variable space            : character;
    variable clockCounter     : integer := 0;
    variable inputDataLength  : integer := 0;
    variable operation        : integer := 0;
  begin
  
    if(rst_n = '0') then
      clockCounter := 0;
      inputDataLength := 0;
    elsif (falling_edge(clk)) then
      clockCounter := clockCounter + 1;
      if (not endfile(inputData)) then
        readline(inputData, readOperandRow);
        read(readOperandRow, firstOperand);
        read(readOperandRow, space);
        read(readOperandRow, secondOperand);

      end if;
      
      case op_code is -- number of pipeline stages in every operation + one additional cycle for data load
        when "00" => operation := 8;
        when "01" => operation := 8;
        when "10" => operation := 6;
        when others => operation := 6;
      end case;
      
      -- "clockCounter >= operation" - waiting for first result to come through pipeline
      -- "inputDataLength < 100000" - writing 100000 results to file
      if(clockCounter >= operation and inputDataLength < 100000) then
        result := C_out;
        resultToWrite := to_bitVector(result);
        write(writeOperandRow, resultToWrite);
        writeline(resultData, writeOperandRow);
        inputDataLength := inputDataLength + 1;
      end if;
      
      A_in <= to_stdLogicVector(firstOperand);
      B_in <= to_stdLogicVector(secondOperand);
      
    end if;
  end process num_test;
end testbench;
