library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fp_mult_pipelined is
  port
  (
    clk:              in std_logic;
    rst_n:            in std_logic;
    A_in:             in  std_logic_vector(31 downto 0);
    B_in:             in  std_logic_vector(31 downto 0);
    signC_out:        out std_logic;                     
    exponentC_out:    out std_logic_vector(9 downto 0);   
    signifC_out:      out std_logic_vector(23 downto 0);
    preExceptCode_out:out std_logic_vector(1 downto 0)
  );
end fp_mult_pipelined;


architecture structure of fp_mult_pipelined is

---------------------------------------------------------------------------------
----------------------------------COMPONENTS-------------------------------------
---------------------------------------------------------------------------------

component signifMultPart1Block is
  port(
    signifA_in:     in  std_logic_vector(22 downto 0);
    signifB_in:     in  std_logic_vector(22 downto 0);
    sum1_out:       out std_logic_vector(30 downto 0);
    sum2_out:       out std_logic_vector(30 downto 0);
    sum3_out:       out std_logic_vector(30 downto 0);
    carry1_out:     out std_logic_vector(29 downto 0);
    carry2_out:     out std_logic_vector(29 downto 0);
    carry3_out:     out std_logic_vector(29 downto 0);
    partProd0_out:  out std_logic_vector(1 downto 0);
    partProd4_out:  out std_logic_vector(1 downto 0);
    partProd8_out:  out std_logic_vector(1 downto 0)
  );
end component signifMultPart1Block;

component signifMultPart2Block is
  port(
    sum1_in:      in  std_logic_vector(30 downto 0);
    sum2_in:      in  std_logic_vector(30 downto 0);
    sum3_in:      in  std_logic_vector(30 downto 0);
    carry1_in:    in  std_logic_vector(29 downto 0);
    carry2_in:    in  std_logic_vector(29 downto 0);
    carry3_in:    in  std_logic_vector(29 downto 0);
    partProd0_in: in  std_logic_vector(1 downto 0);
    partProd4_in: in  std_logic_vector(1 downto 0);
    partProd8_in: in  std_logic_vector(1 downto 0);
    signifC_out:  out std_logic_vector(47 downto 0)
  );
end component signifMultPart2Block;

component signBlock is
  port(
    signA_in:  in  std_logic;
    signB_in:  in  std_logic;
    signC_out: out std_logic
  );
end component signBlock;

component multExceptBlock is
  port(
    exceptA_in:     in std_logic_vector(1 downto 0);
    exceptB_in:     in std_logic_vector(1 downto 0);
    exceptCode_out: out std_logic_vector(1 downto 0)
  );
end component multExceptBlock;

component exponentAdderBlock is
  port(
    expA_in:  in  std_logic_vector(7 downto 0);
    expB_in:  in  std_logic_vector(7 downto 0);
    expC_out: out std_logic_vector(9 downto 0)
  );
end component exponentAdderBlock;

component exceptCheckBlock is
  port(
    floatNum_in: 	    in std_logic_vector(30 downto 0);
		exceptCode_out:	  out std_logic_vector(1 downto 0)
  );
end component exceptCheckBlock;

component signifNormBlock is
  port(
    denormSignifC_in: in  std_logic_vector(47 downto 0);
    stickyBit_out:    out std_logic;
    lowestBit_out:    out std_logic;
    guardBit_out:     out std_logic;
    incExp_out:       out std_logic; 
    normSignifC_out:  out std_logic_vector(23 downto 0)
  );
end component signifNormBlock;

component roundMultBlock is
  port(
    stickyBit_in:       in std_logic;
    lowestBit_in:       in std_logic;
    guardBit_in:        in std_logic;
    unroundSignifC_in:  in std_logic_vector(23 downto 0);
    incExp_out:         out std_logic;                     
    roundSignifC_out:   out std_logic_vector(23 downto 0)
  );
end component roundMultBlock;

component exponentCorrectMultBlock is
  port(
    incExpNorm_in:    in  std_logic;  
    incExpRound_in:   in  std_logic;  
    expC_in:          in  std_logic_vector(9 downto 0);
    correctExpC_out:  out std_logic_vector(9 downto 0)
  );
end component exponentCorrectMultBlock; 


---------------------------------------------------------------------------------
----------------------REGISTERS FOR PIPE STAGES----------------------------------
---------------------------------------------------------------------------------

  signal reg1_r: std_logic_vector(63 downto 0);
  signal reg2_r: std_logic_vector(203 downto 0);
  signal reg3_r: std_logic_vector(60 downto 0);
  signal reg4_r: std_logic_vector(38 downto 0);
  
  
---------------------------------------------------------------------------------
---------------INTERNAL SIGNALS FROM COMPONENT OUTPUTS TO REGISTERS--------------
---------------------------------------------------------------------------------

  signal reg2_r_i: std_logic_vector(203 downto 0);
  signal reg3_r_i: std_logic_vector(60 downto 0);
  signal reg4_r_i: std_logic_vector(38 downto 0);
  
  
---------------------------------------------------------------------------------
----------------------INTERNAL SIGNALS BETWEEN COMPONENTS------------------------
---------------------------------------------------------------------------------
  signal guardBit_i:        std_logic;
  signal lowestBit_i:       std_logic;
  signal stickyBit_i:       std_logic;
  signal incExpNorm_i:      std_logic;
  signal incExpRound_i:     std_logic;
  signal unroundedSignif_i: std_logic_vector(23 downto 0);
  signal correctExponent_i: std_logic_vector(9 downto 0);

begin

----------------------------------1ST STAGE---------------------------------

  signifMultPart1Block_i: signifMultPart1Block
  port map(
    signifA_in    => reg1_r(54 downto 32),
    signifB_in    => reg1_r(22 downto 0),
    sum1_out      => reg2_r_i(203 downto 173),
    sum2_out      => reg2_r_i(172 downto 142),
    sum3_out      => reg2_r_i(141 downto 111),
    carry1_out    => reg2_r_i(110 downto 81),
    carry2_out    => reg2_r_i(80 downto 51),
    carry3_out    => reg2_r_i(50 downto 21),
    partProd0_out => reg2_r_i(20 downto 19),
    partProd4_out => reg2_r_i(18 downto 17),
    partProd8_out => reg2_r_i(16 downto 15)
  );
  
  exponentAdderBlock_i: exponentAdderBlock
  port map(
    expA_in     => reg1_r(62 downto 55),
    expB_in     => reg1_r(30 downto 23),
    expC_out    => reg2_r_i(14 downto 5)
  );
  
  signBlock_i: signBlock
  port map(
    signA_in      => reg1_r(63),
    signB_in      => reg1_r(31),
    signC_out     => reg2_r_i(4)
  );
  
  exceptCheckBlockA_i: exceptCheckBlock
  port map(
    floatNum_in     => reg1_r(62 downto 32),
    exceptCode_out  => reg2_r_i(3 downto 2)
  );
  
  exceptCheckBlockB_i: exceptCheckBlock
  port map(
    floatNum_in     => reg1_r(30 downto 0),
    exceptCode_out  => reg2_r_i(1 downto 0)
  );

----------------------------------1ST STAGE---------------------------------

----------------------------------2ND STAGE---------------------------------


  signifMultPart2Block_i: signifMultPart2Block
  port map(
    sum1_in       => reg2_r(203 downto 173),
    sum2_in       => reg2_r(172 downto 142),
    sum3_in       => reg2_r(141 downto 111),
    carry1_in     => reg2_r(110 downto 81),
    carry2_in     => reg2_r(80 downto 51),
    carry3_in     => reg2_r(50 downto 21),
    partProd0_in  => reg2_r(20 downto 19),
    partProd4_in  => reg2_r(18 downto 17),
    partProd8_in  => reg2_r(16 downto 15),
    signifC_out   => reg3_r_i(60 downto 13)
  );
  
  multExceptBlock_i: multExceptBlock
  port map(
    exceptA_in      => reg2_r(3 downto 2),
    exceptB_in      => reg2_r(1 downto 0),
    exceptCode_out  => reg3_r_i(12 downto 11)
  );
  
  reg3_r_i(10 downto 1) <= reg2_r(14 downto 5);
  reg3_r_i(0)           <= reg2_r(4);
  
----------------------------------2ND STAGE---------------------------------

----------------------------------3RD STAGE---------------------------------
  
  signifNormBlock_i: signifNormBlock
  port map(
    denormSignifC_in  => reg3_r(60 downto 13),
    stickyBit_out     => stickyBit_i,
    lowestBit_out     => lowestBit_i,
    guardBit_out      => guardBit_i,
    incExp_out        => reg4_r_i(38),
    normSignifC_out   => unroundedSignif_i
  );

  roundBlock_i: roundMultBlock
  port map(
    stickyBit_in      => stickyBit_i,
    lowestBit_in      => lowestBit_i,
    guardBit_in       => guardBit_i,
    unroundSignifC_in => unroundedSignif_i,
    incExp_out        => reg4_r_i(13),
    roundSignifC_out  => reg4_r_i(37 downto 14)
  );
  
  
  reg4_r_i(12 downto 3)   <= reg3_r(10 downto 1);
  reg4_r_i(2 downto 1)    <= reg3_r(12 downto 11);
  reg4_r_i(0)             <= reg3_r(0);
  
----------------------------------3RD STAGE---------------------------------

----------------------------------4TH STAGE--------------------------------- 
  exponentCorrectBlock_i: exponentCorrectMultBlock
  port map(
    incExpNorm_in   =>  reg4_r(38),
    incExpRound_in  =>  reg4_r(13),
    expC_in         =>  reg4_r(12 downto 3),
    correctExpC_out =>  correctExponent_i
  );
----------------------------------4TH STAGE---------------------------------   
  
  registers_update: process(clk, rst_n) is
  begin
    if (rst_n = '0') then
      reg1_r <= (others => '0');
      reg2_r <= (others => '0');
      reg3_r <= (others => '0');
      reg4_r <= (others => '0');
    elsif (rising_edge(clk)) then
      reg1_r(63 downto 32) <= A_in;
      reg1_r(31 downto 0) <= B_in;
      reg2_r <= reg2_r_i;
      reg3_r <= reg3_r_i;
      reg4_r <= reg4_r_i;
    end if;
  end process registers_update;
  
    signC_out         <= reg4_r(0);
    exponentC_out     <= correctExponent_i;
    signifC_out       <= reg4_r(37 downto 14);
    preExceptCode_out <= reg4_r(2 downto 1);
end structure;
