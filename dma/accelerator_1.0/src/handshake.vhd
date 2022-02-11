--EEL 5721 RECONFIGURABLE COMPUTING
--GROUP NUMBER 46
--TEAM MEMBERS
-- PRIYANKA ABHIJIT TAMHANKAR UFID : 40893970
-- MEGHANA KODURU UFID: 

--Entity Description : Register entity to store the values of size and start address passed 
--by userapp to the DRAM till handshake completes sychronization and go_sync = 1 
------------------------------------------------------------------------------------library ieee;
use ieee.std_logic_1164.all;

entity handshake is
      port (
            clk_src   : in  std_logic;
            clk_dest  : in  std_logic; 
            rst       : in  std_logic; 
            go        : in  std_logic; 
            rcv       : out std_logic; 
            ack       : out std_logic 
        );
end handshake;

architecture handshake_arch of handshake is

      type state_type is (S_READY, S_WAIT_FOR_ACK, S_RESET_ACK);
      type state_type2 is (S_READY, S_SEND_ACK, S_RESET_ACK);
      signal state_src   : state_type;
      signal state_dest : state_type2;

      signal send_s, ack_s : std_logic;
      signal  send_sync, sbuff1, sbuff2 : std_logic;  
      signal  ack_sync, abuff1, abuff2 : std_logic; 
  
begin

  -----------------------------------------------------------------------------
  --SOURCE CLOCK DOMAIN
  -- State machine in source domain that sends to dest domain and then waits
  -- for an ack

  process(clk_src, rst)
  begin
    if (rst = '1') then
      state_src <= S_READY;
      send_s   <= '0';
      ack       <= '0';
    elsif (rising_edge(clk_src)) then
        ack    <= '0';
          case state_src is
            when S_READY =>
                  if (go = '1') then
                    send_s        <= '1';
                    state_src <= S_WAIT_FOR_ACK;
                  end if;

            when S_WAIT_FOR_ACK =>
                  if (ack_sync = '1') then
                    send_s <= '0';
                    state_src <= S_RESET_ACK;
                  end if;

            when S_RESET_ACK =>
                  if (ack_sync = '0') then
                    ack    <= '1';
                    state_src <= S_READY;
                  end if;

            when others => null;
          end case;
    end if;
  end process;
  
  -- process for synchronizing in destination domain --send_s
  --delaying once in source domain
 process(clk_src, rst)
        begin
            if (rst = '1') then
                sbuff1 <= '0';
            elsif (rising_edge(clk_src)) then
                sbuff1 <= send_s;
            end if;
 end process;
 --delaying signal ack_s fro m destination domain for two clock cycles in source domain
  process(clk_src, rst)
  begin
	if (rst = '1') then
		abuff2 <= '0';
		ack_sync <= '0';
	elsif (rising_edge(clk_src)) then
		abuff2 <= abuff1;
		ack_sync <= abuff2;
	end if;
  end process;
 


  -----------------------------------------------------------------------------
  --DESTINATION CLOCK DOMAIN
  -- State machine in dest domain that waits for source domain to send signal,
  -- which then gets acknowledged

  process(clk_dest, rst)
  begin
    if (rst = '1') then
      state_dest <= S_READY;
      ack_s      <= '0';
      rcv        <= '0';
    elsif (rising_edge(clk_dest)) then

      rcv <= '0';

          case state_dest is
            when S_READY =>
                  if (send_sync = '1') then
                    rcv        <= '1';
                    state_dest <= S_SEND_ACK;
                  end if;

            when S_SEND_ACK =>
                    ack_s     <= '1';
                    state_dest <= S_RESET_ACK;
                    
            when S_RESET_ACK =>
                  if (send_sync = '0') then
                    ack_s    <= '0';
                    state_dest <= S_READY;
              end if;

            when others => null;
          end case;
    end if;
  end process;

  -- process for synchronizing in source domain --ack_s
  --delaying signal once in destination domain 
 process(clk_dest, rst)
        begin
            if (rst = '1') then
                abuff1 <= '0';
            elsif (rising_edge(clk_dest)) then
                abuff1 <= ack_s;
            end if;
  end process;
  
  -- delaying signal send_s from source doamin for two clock cycles in destination domain
  process(clk_dest, rst)
        begin
            if (rst = '1') then
                sbuff2 <= '0';
                send_sync <= '0';
            elsif (rising_edge(clk_dest)) then
                sbuff2 <= sbuff1;
                send_sync <= sbuff2;
            end if;
  end process;
  

  
  end handshake_arch;