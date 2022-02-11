--EEL 5721 RECONFIGURABLE COMPUTING
--GROUP NUMBER 46
--TEAM MEMBERS
-- PRIYANKA ABHIJIT TAMHANKAR UFID : 40893970
-- MEGHANA KODURU UFID: 

--Entity Description : Register entity to store the values of size and start address passed 
--by userapp to the DRAM till handshake completes sychronization and go_sync = 1 
------------------------------------------------------------------------------------library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.user_pkg.all;
use work.config_pkg.all;

entity addr_gen is
  port (
            clk         : in  std_logic; 
            rst         : in  std_logic; 
            size        : in  std_logic_vector(RAM0_RD_SIZE_RANGE);
            go          : in std_logic;
            en          : in std_logic; 
            stall       : in  std_logic; 
            start_addr  : in std_logic_vector(RAM0_ADDR_RANGE); 
            addr        : out std_logic_vector(RAM0_ADDR_RANGE); 
            valid_addr  : out std_logic; 
            done_a      : out std_logic);
    
end addr_gen;

architecture addr_gen_bhv of addr_gen is

      type state_type is (S_INIT, S_GENERATE_ADDRESS);
      signal state, next_state : state_type;
      signal addr_s, next_addr_s     : std_logic_vector(RAM0_ADDR_RANGE);

begin  

  process (clk, rst)
  begin
    if (rst = '1') then
          addr_s   <= start_addr;
          state    <= S_INIT;
 
    elsif (rising_edge(clk)) then
      addr_s   <= next_addr_s;
      state    <= next_state;
    
    end if;
  end process;

  process(addr_s, size,start_addr,en, state, go, stall)
  begin
    
    --next_count <= count;
    next_state    <= state;
    next_addr_s   <= addr_s;
    done_a          <= '1';
    --valid_addr <='0';

    case state is
    
        when S_INIT =>
             done_a          <= '0';
             valid_addr       <= '0';
             next_addr_s <= start_addr;
      
                if (go = '0') then
                    next_state <= S_INIT;
                else    
                    done_a          <= '0';
                    next_state    <= S_GENERATE_ADDRESS;
                end if;
        
        when S_GENERATE_ADDRESS =>
            valid_addr <= '1';
            done_a  <= '0';

                if (unsigned(addr_s) = (unsigned(size)/2 + unsigned(start_addr))) then
                      done_a        <= '1';
                      next_state  <= S_INIT;
                elsif(stall = '0' and en = '1') then
                      next_addr_s<=std_logic_vector(unsigned(addr_s)+1);
                elsif(stall = '1') then
                      valid_addr <= '0';
                end if;
                
        when others => null;
    end case;
    
  end process;
  
    addr <= addr_s(RAM0_ADDR_RANGE);

end addr_gen_bhv;



