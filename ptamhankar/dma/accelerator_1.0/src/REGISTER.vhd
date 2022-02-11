--EEL 5721 RECONFIGURABLE COMPUTING
--GROUP NUMBER 46
--TEAM MEMBERS
-- PRIYANKA ABHIJIT TAMHANKAR UFID : 40893970
-- MEGHANA KODURU UFID: 64766702
------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity reg is
generic ( width : positive );
  port (
    clk    : in  std_logic;
    rst    : in  std_logic;
    en   : in  std_logic;
    input  : in  std_logic_vector(width-1 downto 0);
    output : out std_logic_vector(width-1 downto 0));
end reg;

architecture reg_arch of reg is
begin
  process(clk, rst)
  begin
    if (rst = '1') then
    output   <= (others => '0');
    elsif (rising_edge(clk)) then
           if (en = '1') then
        output <= input;
      end if;
    end if;
  end process;
end reg_arch;
