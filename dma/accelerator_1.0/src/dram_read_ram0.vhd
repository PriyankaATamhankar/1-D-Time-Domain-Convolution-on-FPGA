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
use work.user_pkg.all;
use work.config_pkg.all;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dram_read_ram0 is
 port(       
             dram_clk   : in  std_logic;
             user_clk   : in  std_logic;
             rst        : in  std_logic;
             clear      : in  std_logic;
             go         : in  std_logic;
             rd_en      : in  std_logic;
             stall      : in  std_logic;
             start_addr : in  std_logic_vector(14 downto 0);
             size       : in  std_logic_vector(16 downto 0);
             valid      : out std_logic;
             data       : out std_logic_vector(15 downto 0);
             done       : out std_logic;

             dram_ready    : in  std_logic;
             dram_rd_en    : out std_logic;
             dram_rd_addr  : out std_logic_vector(14 downto 0);
             dram_rd_data  : in  std_logic_vector(31 downto 0);
             dram_rd_valid : in  std_logic;
             dram_rd_flush : out std_logic
             );
end dram_read_ram0;

architecture dram_read_ram0_arch of dram_read_ram0 is
--signals
signal size_reg : std_logic_vector(RAM0_RD_SIZE_RANGE);
signal startaddr_reg : std_logic_vector(RAM0_ADDR_RANGE);
signal go_sync : std_logic ;
signal stall_addrgen : std_logic;
signal done_c : std_logic;
signal empty_fifo : std_logic;
signal n_empty : std_logic;
signal fifo_rst : std_logic;
signal done_add : std_logic;
signal rst_fifo : std_logic;
signal din_fifo : std_logic_vector(31 downto 0);

--components
--address generator
component addr_gen 
         port  (
            clk         : in  std_logic; 
            rst         : in  std_logic; 
            size        : in  std_logic_vector(RAM0_RD_SIZE_RANGE);
            go          : in  std_logic; 
            en          : in std_logic; 
            stall       : in  std_logic; 
            start_addr  : in std_logic_vector(RAM0_ADDR_RANGE); 
            addr        : out std_logic_vector(RAM0_ADDR_RANGE); 
            valid_addr  : out std_logic; 
            done_a      : out std_logic
            ); 
         end component;

--handshake
component handshake 
        port (
        clk_src   : in  std_logic; 
        clk_dest  : in  std_logic; 
        rst       : in  std_logic; 
        go        : in  std_logic;  
        rcv       : out std_logic; 
        ack       : out std_logic 
        );
        end component ;       
         
--counter
component counter 
      port (
            clk  : in  std_logic;
            rst  : in  std_logic;
            go   : in  std_logic;
            en   : in  std_logic;
            valid_data   : in  std_logic;
            size : in std_logic_vector(RAM0_RD_SIZE_RANGE);
            done_count : out std_logic
        );
        end component;
    
--FIFO
component fifo_generator_1
 port (
            rst : IN STD_LOGIC;
            wr_clk : IN STD_LOGIC;
            rd_clk : IN STD_LOGIC;
            din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            wr_en : IN STD_LOGIC;
            rd_en : IN STD_LOGIC;
            dout : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            full : OUT STD_LOGIC;
            empty : OUT STD_LOGIC;
            prog_full : OUT STD_LOGIC;
            wr_rst_busy : OUT STD_LOGIC;
            rd_rst_busy : OUT STD_LOGIC
  );
END component;

-- register
component reg 
generic ( width : positive );
  port (
            clk    : in  std_logic;
            rst    : in  std_logic;
            en   : in  std_logic;
            input  : in  std_logic_vector(width-1 downto 0);
            output : out std_logic_vector(width-1 downto 0));
end component;


--AND gate
component AND_GATE 
port(	
            input1: in std_logic;
            input2: in std_logic;
            output: out std_logic
);
end component;
--NOT Gate
component NOT_GATE 
port(	
            input: in std_logic;
	        output: out std_logic
);
end component;


begin
--reversing input bits for data in of fifo to read last 16 bits
din_fifo <= dram_rd_data(15 downto 0) & dram_rd_data(31 downto 16);


--flush logic
process(go_sync,done_c,size_reg)
begin
            if(go_sync='1' or ((done_c = '1') and (unsigned(size) > 0)) ) then
            dram_rd_flush <= '1';
            else 
            dram_rd_flush <= '0';
           end if;
end process;

--NOT gate for valid of counter
U_NOT_EMPTY : NOT_GATE 
port map ( 
        input => empty_fifo,
	    output => n_empty
);

--AND GATE for reset logic of fifo_generator_1
U_RST_FIFO : AND_GATE 
port map(

        input1 => go,
	    input2 => done_add,
	    output => rst_fifo
 );

U_ADD : addr_gen 
port map(
            clk         => dram_clk, 
            rst         => rst, 
            size        => size_reg,
            go          => go_sync, 
            en          => dram_ready, 
            stall       => stall_addrgen, 
            start_addr  => startaddr_reg,
            addr        => dram_rd_addr,
            valid_addr  => dram_rd_en, 
            done_a => done_add
            ); 
 
U_HS :  handshake 
    port map(
    clk_src   => user_clk,
    clk_dest  => dram_clk,
    rst       => rst,
    go        => go,  
    rcv       => go_sync 
);

U_FIFO : fifo_generator_1
 PORT map(
    rst => rst_fifo,
    wr_clk => dram_clk,
    rd_clk => user_clk,
    din => din_fifo,
    wr_en => dram_rd_valid,
    rd_en => rd_en,
    dout => data,
    empty => empty_fifo,
    prog_full => stall_addrgen
  );
  
U_CNT : counter 
  port map(
        clk  => user_clk,
        rst  => rst,
        go   => go,
        en   => rd_en,
        valid_data  => n_empty,
        size => size_reg,
        done_count => done_c
    );
 
 U_ADRR_REG : reg
  generic map  ( width => C_RAM0_ADDR_WIDTH )
  port map(
    clk    => user_clk,
    rst    => rst,
    en   => go,
    input  => start_addr,
    output => startaddr_reg
 );
 
 U_SIZE_REG : reg
  generic map  ( width => C_RAM0_RD_SIZE_WIDTH )
  port map(
    clk    => user_clk,
    rst    => rst,
    en   => go,
    input  => size,
    output => size_reg
 );
 
--assigning internal signals to DMA signals
valid <= n_empty;
done <= done_c;

end dram_read_ram0_arch;