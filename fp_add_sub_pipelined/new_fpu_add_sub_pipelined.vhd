library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity new_fpu_add_sub_pipelined is
  port(
    clk:              in  std_logic;
    rst_n:            in  std_logic;
    A_in:             in  std_logic_vector(31 downto 0);
    B_in:             in  std_logic_vector(31 downto 0);
    add_sub_in:       in  std_logic;
    signC:            out std_logic;
    exponentC_out:    out std_logic_vector(7 downto 0);
    signifC_out:      out std_logic_vector(22 downto 0);
    exceptC_out:      out std_logic_vector(2 downto 0)
  );
end new_fpu_add_sub_pipelined;


architecture behave of new_fpu_add_sub_pipelined is
---------------------------------------------------------------------------------
-----------------------------------COMPONENTS------------------------------------
---------------------------------------------------------------------------------
component exponentDiffBlock is
  port (
    exponentA_in:     in  std_logic_vector(7 downto 0);
    exponentB_in:     in  std_logic_vector(7 downto 0);
    exponentC_out:    out std_logic_vector(7 downto 0);
    exponentDiff_out: out std_logic_vector(7 downto 0);
    greaterExp_out:   out std_logic
  );
end component exponentDiffBlock;


component exceptCheckBlock is
  port(
    floatNum_in:    in std_logic_vector(31 downto 0);
    exceptCode_out: out std_logic_vector(2 downto 0)
  );
end component exceptCheckBlock;


component signifAlignBlock is
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
end component signifAlignBlock;


component addSubExceptBlock is
	port(
    exceptA_in:         in std_logic_vector(2 downto 0);
		exceptB_in:         in std_logic_vector(2 downto 0);
    add_sub_in:         in std_logic;
		exceptCodeC_out:    out std_logic_vector(2 downto 0)
	);
end component addSubExceptBlock;


component signCorrectBlock is
   port (
    signifA_in:         in std_logic_vector(26 downto 0); --sign bit + 23 significand bits + 3 rounding bits
    signifB_in:         in std_logic_vector(26 downto 0); --sign bit + 23 significand bits + 3 rounding bits
    signA_in:           in std_logic;
    signB_in:           in std_logic;
    correctSignA_out:   out std_logic;
    correctSignB_out:   out std_logic;
    signifA_out:        out std_logic_vector(26 downto 0);
    signifB_out:        out std_logic_vector(26 downto 0)
   );
end component signCorrectBlock;


component adderBlock is
	port(
    signifA_in:   in  std_logic_vector(26 downto 0);  --one bit for implicit one, 23 significand bits and 3 bits for rounding
    signifB_in:   in  std_logic_vector(26 downto 0);  --one bit for implicit one, 23 significand bits and 3 bits for rounding
    signA_in:     in  std_logic;
    signB_in:     in  std_logic;
    signifC_out:  out std_logic_vector(27 downto 0);  --result with sign bit
    overflow_out: out std_logic
  );
end component adderBlock;


component signifNormPart1Block is
  port(
    signifC_in:           in  std_logic_vector(27 downto 0);  --27 bit sum and sign bit
    overflow_in:          in  std_logic;
    signA_in:             in std_logic;
    signB_in:             in std_logic;
    signifC_out:          out std_logic_vector(27 downto 0);  
    toShiftRight_out:     out std_logic;
    bitsShiftLeft_out:    out std_logic_vector(4 downto 0);
    resultSign_out:       out std_logic
  );
end component signifNormPart1Block;


component signifNormPart2Block is
  port(
    signifC_in:           in std_logic_vector(27 downto 0);
    toShiftRight_in:      in std_logic;
    bitsShiftLeft_in:     in std_logic_vector(4 downto 0);
    normSignifC_out:      out std_logic_vector(26 downto 0)
  );
end component signifNormPart2Block;


component roundBlock is
  port(
    roundSignifC_in:      in  std_logic_vector(26 downto 0);  -- significand with implicit one and three additional bits
    roundSignifC_out:     out std_logic_vector(22 downto 0);  -- significand without implicit one
    roundShiftExp_out:    out std_logic     
  );
end component roundBlock; 



component exponentCorrectBlock is
  port(
    exponentC_in:         in  std_logic_vector(7 downto 0);
    rightRight_in:        in  std_logic;
    roundShift_in:        in  std_logic;
    bitsShiftLeft_in:     in  std_logic_vector(4 downto 0);
    correctExponent_out:  out std_logic_vector(7 downto 0)
  );
end component exponentCorrectBlock; 


---------------------------------------------------------------------------------
---------------------------PIPELINE STAGE REGISTERS------------------------------
---------------------------------------------------------------------------------

  signal reg1_r           :   std_logic_vector(64 downto 0);
  signal reg2_r           :   std_logic_vector(71 downto 0);
  signal reg3_r           :   std_logic_vector(66 downto 0);
  signal reg4_r           :   std_logic_vector(41 downto 0);
  signal reg5_r           :   std_logic_vector(44 downto 0);
  signal reg6_r           :   std_logic_vector(34 downto 0);
  
---------------------------------------------------------------------------------
----------------INTERNAL SIGNALS FROM COMPONENTS TO REGISTERS--------------------
---------------------------------------------------------------------------------
  
  signal reg2_r_i            :   std_logic_vector(71 downto 0);
  signal reg3_r_i            :   std_logic_vector(66 downto 0);
  signal reg4_r_i            :   std_logic_vector(41 downto 0);
  signal reg5_r_i            :   std_logic_vector(44 downto 0);
  signal reg6_r_i            :   std_logic_vector(34 downto 0);

---------------------------------------------------------------------------------
---------------------INTERNAL SIGNALS BETWEEN COMPONENTS-------------------------
---------------------------------------------------------------------------------
  
  signal signifA_i        :   std_logic_vector(26 downto 0);
  signal signifB_i        :   std_logic_vector(26 downto 0);
  signal correctSignA_i   :   std_logic;
  signal correctSignB_i   :   std_logic;
  signal normSignifC_i    :   std_logic_vector(26 downto 0);
  signal roundShiftExp_i  :   std_logic;
  
  signal signifNormC_i    :   std_logic_vector(27 downto 0);
  signal bitsShiftLeft_i  :   std_logic_vector(4 downto 0);
  signal toShiftRight_i   :   std_logic;
  
begin

  reg2_r_i(71 downto 49)  <=  reg1_r(54 downto 32); --  significand A
  reg2_r_i(48 downto 26)  <=  reg1_r(22 downto 0);  --  significand B
  reg2_r_i(25)            <=  reg1_r(63);           --  sign A
  reg2_r_i(24)            <=  reg1_r(31);           --  sign B
  reg2_r_i(0)             <=  reg1_r(64);           --  add/sub signal 
  
  exponentDiffBlock_i: exponentDiffBlock
  port map(
    exponentA_in          =>  reg1_r(62 downto 55),
    exponentB_in          =>  reg1_r(30 downto 23),
    exponentC_out         =>  reg2_r_i(23 downto 16),
    exponentDiff_out      =>  reg2_r_i(15 downto 8),
    greaterExp_out        =>  reg2_r_i(7)
  );
  
  exceptCheckBlockA_i: exceptCheckBlock
  port map(
    floatNum_in           =>  reg1_r(63 downto 32),
    exceptCode_out        =>  reg2_r_i(6 downto 4)
  );
  
  exceptCheckBlockB_i: exceptCheckBlock
  port map(
    floatNum_in           =>  reg1_r(31 downto 0),
    exceptCode_out        =>  reg2_r_i(3 downto 1)
  );
  
  reg3_r_i(10 downto 3)   <=  reg2_r(23 downto 16);   -- exponent C
  
  signifAlignBlock_i: signifAlignBlock
  port map(
    signifA_in            =>  reg2_r(71 downto 49),
    signifB_in            =>  reg2_r(48 downto 26),
    signA_in              =>  reg2_r(25),
    signB_in              =>  reg2_r(24),
    greaterExp_in         =>  reg2_r(7),
    exponentDiff_in       =>  reg2_r(15 downto 8),
    alignedA_out          =>  reg3_r_i(66 downto 40),
    alignedB_out          =>  reg3_r_i(39 downto 13),
    signA_out             =>  reg3_r_i(12),
    signB_out             =>  reg3_r_i(11)
  );
  
  addSubExceptBlock_i: addSubExceptBlock
  port map(
    exceptA_in            =>  reg2_r(6 downto 4),
		exceptB_in            =>  reg2_r(3 downto 1),
    add_sub_in            =>  reg2_r(0),
		exceptCodeC_out       =>  reg3_r_i(2 downto 0)
  );
  
  
  reg4_r_i(12)            <=  reg3_r(12); --sign A
  reg4_r_i(11)            <=  reg3_r(11); --sign B
  reg4_r_i(10 downto 3)   <=  reg3_r(10 downto 3);  --exponent C
  reg4_r_i(2 downto 0)    <=  reg3_r(2 downto 0); --except code
  
  signCorrectBlock_i: signCorrectBlock
  port map(
    signifA_in            =>  reg3_r(66 downto 40),
    signifB_in            =>  reg3_r(39 downto 13),
    signA_in              =>  reg3_r(12),
    signB_in              =>  reg3_r(11),
    correctSignA_out      =>  correctSignA_i,
    correctSignB_out      =>  correctSignB_i,
    signifA_out           =>  signifA_i,
    signifB_out           =>  signifB_i
  );
  
  adderBlock_i: adderBlock
  port map(
    signifA_in            =>  signifA_i,
    signifB_in            =>  signifB_i,
    signA_in              =>  correctSignA_i,
    signB_in              =>  correctSignB_i,
    signifC_out           =>  reg4_r_i(41 downto 14),
    overflow_out          =>  reg4_r_i(13)
  );

  reg5_r_i(17 downto 13)  <= bitsShiftLeft_i;
  reg5_r_i(12)            <= toShiftRight_i;
  reg5_r_i(10 downto 3)   <= reg4_r(10 downto 3);
  reg5_r_i(2 downto 0)    <=  reg4_r(2 downto 0);
  
  signifNormPart1Block_i: signifNormPart1Block
  port map(
    signifC_in            =>  reg4_r(41 downto 14),
    overflow_in           =>  reg4_r(13),
    signA_in              =>  reg4_r(12),
    signB_in              =>  reg4_r(11),
    signifC_out           =>  signifNormC_i,
    toShiftRight_out      =>  toShiftRight_i,
    bitsShiftLeft_out     =>  bitsShiftLeft_i,
    resultSign_out        =>  reg5_r_i(11)
  );
  
  signifNormPart2Block_i: signifNormPart2Block 
  port map(
    signifC_in            =>  signifNormC_i,
    toShiftRight_in       =>  toShiftRight_i,
    bitsShiftLeft_in      =>  bitsShiftLeft_i,
    normSignifC_out       =>  reg5_r_i(44 downto 18)
  );
  
  reg6_r_i(34)            <=  reg5_r(11);
  reg6_r_i(2 downto 0)    <=  reg5_r(2 downto 0);

  roundBlock_i: roundBlock
  port map(
    roundSignifC_in       =>  reg5_r(44 downto 18),
    roundSignifC_out      =>  reg6_r_i(25 downto 3),
    roundShiftExp_out     =>  roundShiftExp_i
  );
  
  exponentCorrectBlock_i: exponentCorrectBlock
  port map(
    exponentC_in          =>  reg5_r(10 downto 3),
    rightRight_in         =>  reg5_r(12),
    roundShift_in         =>  roundShiftExp_i,
    bitsShiftLeft_in      =>  reg5_r(17 downto 13),
    correctExponent_out   =>  reg6_r_i(33 downto 26)
  );



  pipeline: process(clk, rst_n) is
  begin
    if (rst_n = '0') then
      reg1_r  <= (others  =>  '0');
      reg2_r  <= (others  =>  '0');
      reg3_r  <= (others  =>  '0');
      reg4_r  <= (others  =>  '0');
      reg5_r  <= (others  =>  '0');
      reg6_r  <= (others  =>  '0');
    
    elsif(rising_edge(clk)) then
      reg1_r(64)            <=  add_sub_in;
      reg1_r(63 downto 32)  <=  A_in;
      reg1_r(31 downto 0)   <=  B_in;
      reg2_r                <=  reg2_r_i;
      reg3_r                <=  reg3_r_i;
      reg4_r                <=  reg4_r_i;
      reg5_r                <=  reg5_r_i;
      reg6_r                <=  reg6_r_i;
    end if;
  end process pipeline;
  
    signC           <=  reg6_r(34);
    exponentC_out   <=  reg6_r(33 downto 26);
    signifC_out     <=  reg6_r(25 downto 3);
    exceptC_out     <=  reg6_r(2 downto 0);
end behave;