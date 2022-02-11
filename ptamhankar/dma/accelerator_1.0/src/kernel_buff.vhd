--EEL 5721 RECONFIGURABLE COMPUTING
--GROUP NUMBER 46
--TEAM MEMBERS
-- PRIYANKA ABHIJIT TAMHANKAR UFID : 40893970
-- MEGHANA KODURU UFID: 64766702

------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.user_pkg.ALL;

use IEEE.NUMERIC_STD.ALL;



entity kernel_buff is
Port (
       rst : in std_logic;
       clk : in std_logic;
       input : in std_logic_vector(15 downto 0);
       Kernel_ld : in std_logic;
       output : out std_logic_vector((16*128)-1 downto 0);
       full : out std_logic
       
     );
end kernel_buff;

architecture Beh of kernel_buff is
signal count : std_logic_vector(15 downto 0);
type reg_array is array(0 to 127) of std_logic_vector(15 downto 0);
signal regs : reg_array;

begin

process(rst, clk)
variable temp : unsigned(15 downto 0);
begin

     if (rst='1') then
            output <= (others=> '0');
            full <= '0';
     
            for i in 0 to 127 loop
                regs(i) <= (others => '0');
            end loop;
            count <= (others => '0');
            
     elsif (rising_edge(clk)) then
            temp := unsigned(count);
                 
            if (Kernel_ld = '1') then
                regs(0) <= input;
                --regs <= shift_left(unsigned(regs),1);
                --regs <= regs(C_MAX_SIGNAL_SIZE + (2*(C_KERNEL_SIZE-1))-1 downto 0) & '0';
                for j in 0 to 126 loop
                    regs(j+1)<=regs(j);
                end loop;
                temp := temp + 1;
            end if;
            
            --if (1) then
            if(temp = to_unsigned(128, 16)) then
                for i in 0 to 127 loop
                    output(((i+1)*16)-1 downto i*16 ) <= regs(i);
                end loop;
            end if;
              --  temp := temp - 1;
            --end if;
            
     count <= std_logic_vector(unsigned(temp));
     
           if (unsigned(count) = 128) then
            full <= '1';
           else
            full <= '0';
           end if;
     
     end if;
end process;

end Beh;
