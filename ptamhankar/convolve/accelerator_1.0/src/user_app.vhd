-- Greg Stitt
-- University of Florida

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.config_pkg.all;
use work.user_pkg.all;

entity user_app is
    port (
        clks   : in  std_logic_vector(NUM_CLKS_RANGE);
        rst    : in  std_logic;
        sw_rst : out std_logic;

        -- memory-map interface
        mmap_wr_en   : in  std_logic;
        mmap_wr_addr : in  std_logic_vector(MMAP_ADDR_RANGE);
        mmap_wr_data : in  std_logic_vector(MMAP_DATA_RANGE);
        mmap_rd_en   : in  std_logic;
        mmap_rd_addr : in  std_logic_vector(MMAP_ADDR_RANGE);
        mmap_rd_data : out std_logic_vector(MMAP_DATA_RANGE);

        -- DMA interface for RAM 0
        -- read interface
        ram0_rd_rd_en : out std_logic;
        ram0_rd_clear : out std_logic;
        ram0_rd_go    : out std_logic;
        ram0_rd_valid : in  std_logic;
        ram0_rd_data  : in  std_logic_vector(RAM0_RD_DATA_RANGE);
        ram0_rd_addr  : out std_logic_vector(RAM0_ADDR_RANGE);
        ram0_rd_size  : out std_logic_vector(RAM0_RD_SIZE_RANGE);
        ram0_rd_done  : in  std_logic;
        -- write interface
        ram0_wr_ready : in  std_logic;
        ram0_wr_clear : out std_logic;
        ram0_wr_go    : out std_logic;
        ram0_wr_valid : out std_logic;
        ram0_wr_data  : out std_logic_vector(RAM0_WR_DATA_RANGE);
        ram0_wr_addr  : out std_logic_vector(RAM0_ADDR_RANGE);
        ram0_wr_size  : out std_logic_vector(RAM0_WR_SIZE_RANGE);
        ram0_wr_done  : in  std_logic;

        -- DMA interface for RAM 1
        -- read interface
        ram1_rd_rd_en : out std_logic;
        ram1_rd_clear : out std_logic;
        ram1_rd_go    : out std_logic;
        ram1_rd_valid : in  std_logic;
        ram1_rd_data  : in  std_logic_vector(RAM1_RD_DATA_RANGE);
        ram1_rd_addr  : out std_logic_vector(RAM1_ADDR_RANGE);
        ram1_rd_size  : out std_logic_vector(RAM1_RD_SIZE_RANGE);
        ram1_rd_done  : in  std_logic;
        -- write interface
        ram1_wr_ready : in  std_logic;
        ram1_wr_clear : out std_logic;
        ram1_wr_go    : out std_logic;
        ram1_wr_valid : out std_logic;
        ram1_wr_data  : out std_logic_vector(RAM1_WR_DATA_RANGE);
        ram1_wr_addr  : out std_logic_vector(RAM1_ADDR_RANGE);
        ram1_wr_size  : out std_logic_vector(RAM1_WR_SIZE_RANGE);
        ram1_wr_done  : in  std_logic
        );
end user_app;

architecture default of user_app is

    signal go        : std_logic;
    signal sw_rst_s  : std_logic;
    signal rst_s     : std_logic;
    signal size      : std_logic_vector(RAM0_RD_SIZE_RANGE);
--    signal ram0_rd_addr : std_logic_vector(RAM0_ADDR_RANGE);
--    signal ram1_wr_addr : std_logic_vector(RAM1_ADDR_RANGE);
    signal done      : std_logic;
	signal Kernel_Output	:std_logic_vector((16*128)-1 downto 0);
	
	signal Signal_Output	:std_logic_vector((16*128)-1 downto 0);
	signal Signal_Empty, Signal_Full, MultAddTree_En	:std_logic;
	signal Datapath_Out		: std_logic_vector(38 downto 0);
	signal kernal_data     : std_logic_vector((16)-1 downto 0);
	signal kernel_ld, kernel_loaded       : std_logic;
	signal Signal_rd_en, MultAddTree_Valin_In    : std_logic;
	signal ram0_rd_en_signal: std_logic;
	signal Datapath_Valid_Out: std_logic;

begin

    U_MMAP : entity work.memory_map
        port map (
            clk     => clks(C_CLK_USER),
            rst     => rst,
            wr_en   => mmap_wr_en,
            wr_addr => mmap_wr_addr,
            wr_data => mmap_wr_data,
            rd_en   => mmap_rd_en,
            rd_addr => mmap_rd_addr,
            rd_data => mmap_rd_data,

            -- dma interface for accessing DRAM from software
            ram0_wr_ready => ram0_wr_ready,
            ram0_wr_clear => ram0_wr_clear,
            ram0_wr_go    => ram0_wr_go,
            ram0_wr_valid => ram0_wr_valid,
            ram0_wr_data  => ram0_wr_data,
            ram0_wr_addr  => ram0_wr_addr,
            ram0_wr_size  => ram0_wr_size,
            ram0_wr_done  => ram0_wr_done,

            ram1_rd_rd_en => ram1_rd_rd_en,
            ram1_rd_clear => ram1_rd_clear,
            ram1_rd_go    => ram1_rd_go,
            ram1_rd_valid => ram1_rd_valid,
            ram1_rd_data  => ram1_rd_data,
            ram1_rd_addr  => ram1_rd_addr,
            ram1_rd_size  => ram1_rd_size,
            ram1_rd_done  => ram1_rd_done,

            -- circuit interface from software
    
        go            => go,
        sw_rst        => sw_rst_s,
        signal_size   => size,
        kernel_data   => kernal_data,
        kernel_load   => kernel_ld,
        kernel_loaded => kernel_loaded,
        done          => done
        
        
            );

    rst_s  <= rst or sw_rst_s;
    sw_rst <= sw_rst_s;

    U_CTRL : entity work.ctrl
        port map (
            clk           => clks(C_CLK_USER),
            rst           => rst_s,
            go            => go,
            mem_in_go     => ram0_rd_go,
            mem_out_go    => ram1_wr_go,
            mem_in_clear  => ram0_rd_clear,
            mem_out_clear => ram1_wr_clear,
            mem_out_done  => ram1_wr_done,
            done          => done);

--    --ram0_rd_rd_en <= ram0_rd_valid and ram1_wr_ready;
--    ram0_rd_rd_en <= kernel_loaded and (not Signal_Empty);
 --   ram0_rd_size  <= size;
----    ram0_rd_addr  <= ram0_rd_addr;
 --   ram1_wr_size  <= size;
----    ram1_wr_addr  <= ram1_rd_addr;
 --   ram1_wr_data  <= ram0_rd_data;
 --   ram1_wr_valid <= ram0_rd_valid and ram1_wr_ready;
    
    ram0_rd_en_signal <= ram0_rd_valid and (not Signal_Full) ;
    ram0_rd_rd_en <= ram0_rd_en_signal;
    ram0_rd_size  <= std_logic_vector(2*(128 -1)+unsigned(size));
    ram0_rd_addr  <= (others => '0');
    ram1_wr_size  <= std_logic_vector((128-1)+unsigned(size));
    ram1_wr_addr  <= (others => '0');
    
	
	
	U_KERNEL: entity work.kernel_buff
	port map(
		rst  	=> rst_s,
		clk     => clks(C_CLK_USER),
		input   => kernal_data,
		Kernel_ld => kernel_ld,
		output  => Kernel_Output,
		full    => kernel_loaded
		
	);
	
	Signal_rd_en <= (not Signal_Empty) and ram1_wr_ready and kernel_loaded;
	
	U_SIGNAL: entity work.signal_buff
	port map(
			rst 		=> rst_s,
	        clk         => clks(C_CLK_USER),
	        input       => ram0_rd_data,
	        output      => Signal_Output,
	        wr_en       => ram0_rd_en_signal,
	        rd_en       => Signal_rd_en,
	        full        => Signal_Full,
	        empty       => Signal_Empty
			);
	MultAddTree_En <= ram1_wr_ready;		
	U_DATAPATH: entity work.mult_add_tree
	generic map(
		num_inputs  	 => 128,
		input1_width     => 16,
		input2_width     => 16
		)
	port map(
		clk     => clks(C_CLK_USER),
	    rst     => rst_s,
	    en      => MultAddTree_En,
	    valid_in => MultAddTree_Valin_In,
	    valid_out => Datapath_Valid_Out,
	    input1  => Signal_Output,
	    input2  => Kernel_Output,
	    output  => Datapath_Out 	
	);
	
		MultAddTree_Valin_In <= Signal_rd_en;
		ram1_wr_valid <= Datapath_Valid_Out and ram1_wr_ready;
		
process(Datapath_Out)
begin
    if(Datapath_Out(38 downto 16)=std_logic_vector(to_unsigned(0,23))) then
        ram1_wr_data <=Datapath_Out(15 downto 0);
    else
        ram1_wr_data <= (others =>'1');
    end if;

end process;

end default;
