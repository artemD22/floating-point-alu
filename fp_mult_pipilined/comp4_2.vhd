library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comp4_2 is
	generic (NUM_WIDTH : integer);
	port(
		a, b, c, d: in std_logic_vector(NUM_WIDTH-1 downto 0);
		sum : out std_logic_vector(NUM_WIDTH downto 0);
		carry: out std_logic_vector(NUM_WIDTH-1 downto 0)
	);
end comp4_2;

architecture behave of comp4_2 is
	signal sum1, carry1: std_logic_vector(NUM_WIDTH-1 downto 0);
begin

first_level:	process (a, b, c, d) is
					begin
						for i in 0 to NUM_WIDTH-1 loop
							sum1(i) <= a(i) xor b(i) xor c(i);
							carry1(i) <= (a(i) and b(i)) or (a(i) and c(i)) or (b(i) and c(i));
						end loop;
					end process first_level;

second_level: 	process (d, sum1, carry1)
					begin
						sum(0) <= d(0) xor sum1(0);
						carry(0) <= (d(0) and sum1(0));
						for i in 1 to NUM_WIDTH-1 loop
							sum(i) <= d(i) xor sum1(i) xor carry1(i-1);
							carry(i) <= (d(i) and sum1(i)) or (d(i) and carry1(i-1)) or (sum1(i) and carry1(i-1));
						end loop;
						sum(NUM_WIDTH) <= carry1(NUM_WIDTH-1);
					end process second_level;
					

end behave;