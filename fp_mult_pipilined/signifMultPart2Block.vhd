library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity signifMultPart2Block is
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
end signifMultPart2Block;

architecture behave of signifMultPart2Block is
	
	component comp4_2 is
	generic (NUM_WIDTH : integer);
	port(
		a, b, c, d: in std_logic_vector(NUM_WIDTH-1 downto 0);
		sum : out std_logic_vector(NUM_WIDTH downto 0);
		carry: out std_logic_vector(NUM_WIDTH-1 downto 0)
	);
	end component comp4_2;

  
	signal sum2_1: std_logic_vector(38 downto 0);
	signal carry2_1: std_logic_vector(37 downto 0); 
	signal sum3_1: std_logic_vector(45 downto 0);
	signal carry3_1: std_logic_vector(44 downto 0); 
	
begin

level2_1: comp4_2
generic map(38)
port map(
	a(37 downto 30) => "00000000", a(29 downto 0) => sum1_in(30 downto 1),
	b(37 downto 30) => "00000000", b(29 downto 0) => carry1_in,
	c(37 downto 7) => sum2_in, c(6 downto 5) => partProd4_in, c(4 downto 0) => "00000",
	d(37 downto 8) => carry2_in, d(7 downto 0) => "00000000",
	sum => sum2_1,
	carry => carry2_1
);

level3_1: comp4_2
generic map(45)
port map(
	a(44 downto 38) => "0000000", a(37 downto 0) => sum2_1(38 downto 1),
	b(44 downto 38) => "0000000", b(37 downto 0) => carry2_1,
	c(44 downto 14) => sum3_in, c(13 downto 12) => partProd8_in, c(11 downto 0) => "000000000000",
	d(44 downto 15) => carry3_in, d(14 downto 0) => "000000000000000",
	sum => sum3_1,
	carry => carry3_1
);


signifC_out(47 downto 5) <= std_logic_vector(unsigned(sum3_1(43 downto 1)) + unsigned(carry3_1(42 downto 0)));
signifC_out(4 downto 0) <= sum3_1(0) & sum2_1(0) & sum1_in(0) & partProd0_in;
end behave;