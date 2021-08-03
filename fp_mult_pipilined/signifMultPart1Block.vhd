library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity signifMultPart1Block is
  port(
    signifA_in:     in  std_logic_vector(22 downto 0);
    signifB_in:     in  std_logic_vector(22 downto 0);
    sum1_out:       out std_logic_vector(30 downto 0);
    sum2_out:       out std_logic_vector(30 downto 0);
    sum3_out:       out std_logic_vector(30 downto 0);
    carry1_out:     out std_logic_vector(29 downto 0);
    carry2_out:     out std_logic_vector(29 downto 0);
    carry3_out:     out std_logic_vector(29 downto 0);
    partProd0_out:  out std_logic_vector(1 downto 0); --two last bits of partial products 0, 4, 8 resp.
    partProd4_out:  out std_logic_vector(1 downto 0); --these partProd`s are not added (CSA-tree structure)
    partProd8_out:  out std_logic_vector(1 downto 0) --two bits because multiplication is done in radix-4
  );
end signifMultPart1Block;

architecture behave of signifMultPart1Block is
	
	component comp4_2 is
	generic (NUM_WIDTH : integer);
	port(
		a, b, c, d: in std_logic_vector(NUM_WIDTH-1 downto 0);
		sum : out std_logic_vector(NUM_WIDTH downto 0);
		carry: out std_logic_vector(NUM_WIDTH-1 downto 0)
	);
	end component comp4_2;
	
	constant DATA_WIDTH: integer := 24;
	constant DATA_WIDTH_PART_PROD: integer:= DATA_WIDTH+2;
	constant NUM_OF_PART_PROD: integer:= DATA_WIDTH/2;
	type part_prod_type is array (NUM_OF_PART_PROD-1 downto 0) of std_logic_vector(DATA_WIDTH_PART_PROD-1 downto 0);
	signal partial_products: part_prod_type;
	signal extendedSignifA: std_logic_vector(23 downto 0); -- implicit '1' and significand
	signal extendedSignifB: std_logic_vector(23 downto 0); -- implicit '1' and significand
begin

  extendedSignifA <= '1' & signifA_in;
  extendedSignifb <= '1' & signifB_in;
  
	part_prod: process (extendedSignifA, extendedSignifB) is
	variable multiplicand_1, multiplicand_2, multiplicand_3, multiplicand_4: std_logic_vector(DATA_WIDTH_PART_PROD-1 downto 0);
	begin
		multiplicand_1 := "00" & extendedSignifA;
		multiplicand_2 := '0' & (extendedSignifA & '0');
		multiplicand_3 := std_logic_vector(unsigned(multiplicand_1) + unsigned(multiplicand_2));
		
		for i in 0 to NUM_OF_PART_PROD-1 loop
				if 	(extendedSignifB(i*2+1) = '0' and extendedSignifB(i*2) = '0') then
					partial_products(i) <= (others => '0');
				elsif (extendedSignifB(i*2+1) = '0' and extendedSignifB(i*2) = '1') then
					partial_products(i) <= multiplicand_1;
				elsif	(extendedSignifB(i*2+1) = '1' and extendedSignifB(i*2) = '0') then
					partial_products(i) <= multiplicand_2;
				else
					partial_products(i) <= multiplicand_3;
				end if;
		end loop;
	end process part_prod;

	
level1_1: comp4_2
generic map(30)
port map(
	a(29 downto 24) => "000000", a(23 downto 0) => partial_products(0)(25 downto 2),
	b(29 downto 26) => "0000", b(25 downto 0) => partial_products(1),
	c(29 downto 28) => "00", c(27 downto 2) => partial_products(2), c(1 downto 0) => "00",
	d(29 downto 4) => partial_products(3), d(3 downto 0) => "0000",
	sum => sum1_out,
	carry => carry1_out
);
	

level1_2: comp4_2
generic map(30)
port map(
	a(29 downto 24) => "000000", a(23 downto 0) => partial_products(4)(25 downto 2),
	b(29 downto 26) => "0000", b(25 downto 0) => partial_products(5),
	c(29 downto 28) => "00", c(27 downto 2) => partial_products(6), c(1 downto 0) => "00",
	d(29 downto 4) => partial_products(7), d(3 downto 0) => "0000",
	sum => sum2_out,
	carry => carry2_out
);


level1_3: comp4_2
generic map(30)
port map(
	a(29 downto 24) => "000000", a(23 downto 0) => partial_products(8)(25 downto 2),
	b(29 downto 26) => "0000", b(25 downto 0) => partial_products(9),
	c(29 downto 28) => "00", c(27 downto 2) => partial_products(10), c(1 downto 0) => "00",
	d(29 downto 4) => partial_products(11), d(3 downto 0) => "0000",
	sum => sum3_out,
	carry => carry3_out
);

  partProd0_out <= partial_products(0)(1 downto 0);
  partProd4_out <= partial_products(4)(1 downto 0);
  partProd8_out <= partial_products(8)(1 downto 0);
end behave;