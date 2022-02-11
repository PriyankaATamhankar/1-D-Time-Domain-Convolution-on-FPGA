--EEL 5721 RECONFIGURABLE COMPUTING
--GROUP NUMBER 46
--TEAM MEMBERS
-- PRIYANKA ABHIJIT TAMHANKAR UFID : 40893970
-- MEGHANA KODURU UFID: 64766702

------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use ieee.std_logic_unsigned.all;
use work.config_pkg.all;
use work.user_pkg.all;

entity counter is
      port( clk  : in  std_logic;
            rst  : in  std_logic;
            go   : in  std_logic;
            en   : in  std_logic;
            valid_data   : in  std_logic;
            size : in std_logic_vector(RAM0_RD_SIZE_RANGE);
            done_count : out std_logic);
end counter;

architecture counter_arch of counter is

      type STATE_TYPE is (S_GO, S_COUNT, S_DONE);
      signal state, next_state : STATE_TYPE;
      signal   count, next_count : unsigned(RAM0_RD_SIZE_RANGE);
  
    begin

      process (clk, rst)
          begin
                if (rst = '1') then
                  count <= (others=> '0');
                  state <= S_GO;
                elsif (rising_edge(clk)) then
                  state <= next_state;
                  count <= next_count;
                end if;
      end process;
  
      process(go, state, count,en, valid_data ,size)
      begin
      
         next_count <=count;
         next_state <= state;
         done_count <='1';
        
        case state is
            when S_GO =>
                done_count <= '0';
                next_count <= (others => '0');
            
                    if( unsigned(size) =0) then 
                        done_count<='1';
                    end if;
                    
                    if (go = '0') then
                          next_state <= S_GO;
                        else
                        done_count <='0';
                        next_state <= S_COUNT;
                    end if;                    
          
            when S_COUNT =>
                done_count <= '0';
                    if(next_count = unsigned(size)) then 
                        next_count <= (others=> '0');
                        next_state <= S_DONE;
                    elsif(en='1' and valid_data='1') then
                        next_count <= next_count + 1;
                    end if;
          
            when S_DONE =>
            
                next_count <= (others=> '0');
                done_count <= '1';
                next_state <= S_GO; 
                
            when others => null;
            
        end case;

      end process;
end counter_arch;
