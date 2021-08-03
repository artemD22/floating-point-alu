library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fpu_add_sub_pipelined is
  port(
    clk:              in  std_logic;
    rst_n:            in  std_logic;
    A_in:             in  std_logic_vector(31 downto 0);
    B_in:             in  std_logic_vector(31 downto 0);
    add_sub_in:       in  std_logic;
    signC_out:        out std_logic;                     
    exponentC_out:    out std_logic_vector(9 downto 0);   
    signifC_out:      out std_logic_vector(23 downto 0);
    preExceptCode_out:out std_logic_vector(1 downto 0)
  );
end fpu_add_sub_pipelined;


architecture behave of fpu_add_sub_pipelined is
  attribute altera_attribute : string; 
  attribute altera_attribute of behave : architecture is "-name AUTO_SHIFT_REGISTER_RECOGNITION OFF"; 
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
    floatNum_in: 	    in std_logic_vector(30 downto 0);
		exceptCode_out:	  out std_logic_vector(1 downto 0)
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
    exceptA_in:         in std_logic_vector(1 downto 0);
		exceptB_in:         in std_logic_vector(1 downto 0);
    signA_in:           in std_logic;
    signB_in:           in std_logic;
    add_sub_in:         in std_logic;
		exceptCodeC_out:    out std_logic_vector(1 downto 0)
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


component roundAddSubBlock is
  port(
    roundSignifC_in:      in  std_logic_vector(26 downto 0);  -- significand with implicit one and three additional bits
    roundSignifC_out:     out std_logic_vector(23 downto 0);  -- significand with implicit one
    roundShiftExp_out:    out std_logic     
  );
end component roundAddSubBlock; 


component exponentCorrectAddSubBlock is
  port(
    exponentC_in:         in  std_logic_vector(7 downto 0);
    rightRight_in:        in  std_logic;
    roundShift_in:        in  std_logic;
    bitsShiftLeft_in:     in  std_logic_vector(4 downto 0);
    correctExponent_out:  out std_logic_vector(9 downto 0)
  );
end component exponentCorrectAddSubBlock; 


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


---------------------------------------------------------------------------------
---------------------------PIPELINE STAGE REGISTERS------------------------------
---------------------------------------------------------------------------------

  signal reg1_r             :   std_logic_vector(64 downto 0);
  signal reg2_r             :   std_logic_vector(69 downto 0);
  signal reg3_r             :   std_logic_vector(65 downto 0);
  signal reg4_r             :   std_logic_vector(40 downto 0);
  signal reg5_r             :   std_logic_vector(44 downto 0);
  signal reg6_r             :   std_logic_vector(41 downto 0);
  signal reg7_r             :   std_logic_vector(34 downto 0);
  
---------------------------------------------------------------------------------
----------------INTERNAL SIGNALS FROM COMPONENTS TO REGISTERS--------------------
---------------------------------------------------------------------------------
  
  signal reg2_r_i           :   std_logic_vector(69 downto 0);
  signal reg3_r_i           :   std_logic_vector(65 downto 0);
  signal reg4_r_i           :   std_logic_vector(40 downto 0);
  signal reg5_r_i           :   std_logic_vector(44 downto 0);
  signal reg6_r_i           :   std_logic_vector(41 downto 0);
  signal reg7_r_i           :   std_logic_vector(34 downto 0);

---------------------------------------------------------------------------------
---------------------INTERNAL SIGNALS BETWEEN COMPONENTS-------------------------
---------------------------------------------------------------------------------
  
  signal signifA_i          :   std_logic_vector(26 downto 0);
  signal signifB_i          :   std_logic_vector(26 downto 0);
  signal correctSignA_i     :   std_logic;
  signal correctSignB_i     :   std_logic;
  signal normSignifC_i      :   std_logic_vector(26 downto 0);
  signal roundShiftExp_i    :   std_logic;
  signal correctExponent_i  :   std_logic_vector(9 downto 0);
  
begin

----------------------------------1ST STAGE---------------------------------

  reg2_r_i(69 downto 47)  <=  reg1_r(54 downto 32); --  significand A
  reg2_r_i(46 downto 24)  <=  reg1_r(22 downto 0);  --  significand B
  reg2_r_i(23)            <=  reg1_r(63);           --  sign A
  reg2_r_i(22)            <=  reg1_r(31) xor reg1_r(64);  --  sign B xor add_sub
  
  exponentDiffBlock_i: exponentDiffBlock
  port map(
    exponentA_in          =>  reg1_r(62 downto 55),
    exponentB_in          =>  reg1_r(30 downto 23),
    exponentC_out         =>  reg2_r_i(21 downto 14),
    exponentDiff_out      =>  reg2_r_i(13 downto 6),
    greaterExp_out        =>  reg2_r_i(5)
  );
  
  exceptCheckBlockA_i: exceptCheckBlock
  port map(
    floatNum_in           =>  reg1_r(62 downto 32),
    exceptCode_out        =>  reg2_r_i(4 downto 3)
  );
  
  exceptCheckBlockB_i: exceptCheckBlock
  port map(
    floatNum_in           =>  reg1_r(30 downto 0),
    exceptCode_out        =>  reg2_r_i(2 downto 1)
  );
  
  reg2_r_i(0)             <=  reg1_r(64);           --  add/sub signal 

  
----------------------------------1ST STAGE---------------------------------
  
---------------------------------2ND STAGE---------------------------------
  
  reg3_r_i(9 downto 2)    <=  reg2_r(21 downto 14);   -- exponent C
  
  signifAlignBlock_i: signifAlignBlock
  port map(
    signifA_in            =>  reg2_r(69 downto 47),
    signifB_in            =>  reg2_r(46 downto 24),
    signA_in              =>  reg2_r(23),
    signB_in              =>  reg2_r(22),
    greaterExp_in         =>  reg2_r(5),
    exponentDiff_in       =>  reg2_r(13 downto 6),
    alignedA_out          =>  reg3_r_i(65 downto 39),
    alignedB_out          =>  reg3_r_i(38 downto 12),
    signA_out             =>  reg3_r_i(11),
    signB_out             =>  reg3_r_i(10)
  );
  
  addSubExceptBlock_i: addSubExceptBlock
  port map(
    exceptA_in            =>  reg2_r(4 downto 3),
		exceptB_in            =>  reg2_r(2 downto 1),
    signA_in              =>  reg2_r(23),
    signB_in              =>  reg2_r(22),
    add_sub_in            =>  reg2_r(0),
		exceptCodeC_out       =>  reg3_r_i(1 downto 0)
  );
  
---------------------------------2ND STAGE---------------------------------

----------------------------------3RD STAGE---------------------------------

  reg4_r_i(11)            <=  reg3_r(11); --sign A
  reg4_r_i(10)            <=  reg3_r(10); --sign B
  reg4_r_i(9 downto 2)    <=  reg3_r(9 downto 2);  --exponent C
  reg4_r_i(1 downto 0)    <=  reg3_r(1 downto 0); --except code
  
  
  signCorrectBlock_i: signCorrectBlock
  port map(
    signifA_in            =>  reg3_r(65 downto 39),
    signifB_in            =>  reg3_r(38 downto 12),
    signA_in              =>  reg3_r(11),
    signB_in              =>  reg3_r(10),
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
    signifC_out           =>  reg4_r_i(40 downto 13),
    overflow_out          =>  reg4_r_i(12)
  );
  
----------------------------------3RD STAGE---------------------------------

----------------------------------4TH STAGE---------------------------------

  reg5_r_i(9 downto 2)    <=  reg4_r(9 downto 2); --exponent C
  reg5_r_i(1 downto 0)    <=  reg4_r(1 downto 0);  --except code
  
  signifNormPart1Block_i: signifNormPart1Block
  port map(
    signifC_in            =>  reg4_r(40 downto 13),
    overflow_in           =>  reg4_r(12),
    signA_in              =>  reg4_r(11),
    signB_in              =>  reg4_r(10),
    signifC_out           =>  reg5_r_i(44 downto 17),
    toShiftRight_out      =>  reg5_r_i(16),
    bitsShiftLeft_out     =>  reg5_r_i(15 downto 11),
    resultSign_out        =>  reg5_r_i(10)
  );

----------------------------------4TH STAGE---------------------------------

----------------------------------5TH STAGE---------------------------------

  
  reg6_r_i(16 downto 12)  <=  reg5_r(15 downto 11); -- bits shift left
  reg6_r_i(11)            <=  reg5_r(16);           -- to shift right
  reg6_r_i(10)            <=  reg5_r(10);           -- sign C
  reg6_r_i(9 downto 2)    <=  reg5_r(9 downto 2);   -- exponent C
  reg6_r_i(1 downto 0)    <=  reg5_r(1 downto 0);   -- except code 
  
  signifNormPart2Block_i: signifNormPart2Block 
  port map(
    signifC_in            =>  reg5_r(44 downto 17),
    toShiftRight_in       =>  reg5_r(16),
    bitsShiftLeft_in      =>  reg5_r(15 downto 11),
    normSignifC_out       =>  normSignifC_i
  );
  
  roundBlock_i: roundAddSubBlock
  port map(
    roundSignifC_in       =>  normSignifC_i,
    roundSignifC_out      =>  reg6_r_i(41 downto 18),
    roundShiftExp_out     =>  reg6_r_i(17)
  );
  

  
-------------------------------------5TH STAGE---------------------------------

-------------------------------------6TH STAGE---------------------------------

  exponentCorrectBlock_i: exponentCorrectAddSubBlock
  port map(
    exponentC_in          =>  reg6_r(9 downto 2),
    rightRight_in         =>  reg6_r(11),
    roundShift_in         =>  reg6_r(17),
    bitsShiftLeft_in      =>  reg6_r(16 downto 12),
    correctExponent_out   =>  correctExponent_i
  );

-------------------------------------6TH STAGE---------------------------------


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
  
    signC_out           <=  reg6_r(10);
    exponentC_out       <=  correctExponent_i;
    signifC_out         <=  reg6_r(41 downto 18);
    preExceptCode_out   <= reg6_r(1 downto 0);
end behave;