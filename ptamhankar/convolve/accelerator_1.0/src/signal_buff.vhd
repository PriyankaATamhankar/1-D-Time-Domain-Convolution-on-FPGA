----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/22/2021 04:11:07 PM
-- Design Name: 
-- Module Name: signal_buff - Beh
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.user_pkg.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity signal_buff is

Port (
       rst : in std_logic;
       clk : in std_logic;
       input : in std_logic_vector(15 downto 0);
       output : out std_logic_vector((16*128)-1 downto 0);
       wr_en : in std_logic;
       rd_en : in std_logic;
       full : out std_logic;
       empty : out std_logic
     );
end signal_buff;

architecture Beh of signal_buff is

signal count : std_logic_vector(15 downto 0);
type reg_array is array(0 to 127) of std_logic_vector(15 downto 0);
signal regs : reg_array;

begin

process(rst, clk)
variable temp : unsigned(15 downto 0);
begin

     if (rst='1') then
            output <= (others => '0');
            full <= '0';
            empty <= '1';
     
            for i in 0 to 127 loop
                regs(i) <= (others => '0');
            end loop;
            count <= (others => '0');
            
     elsif (rising_edge(clk)) then
            temp := unsigned(count);
                 
            if (wr_en = '1') then
                regs(0) <= input;
                --regs <= shift_left(unsigned(regs),1);
                --regs <= regs(C_MAX_SIGNAL_SIZE + (2*(C_KERNEL_SIZE-1))-1 downto 0) & '0';
                for j in 0 to 126 loop
                    regs(j+1)<=regs(j);
                end loop;
                
                temp := temp + 1;
            end if;
            
            if (rd_en = '1') then
            for i in 0 to 127 loop
            output((128-i)*16 - 1 downto (127-i)*16) <= regs(i);
            
            
            end loop;
                temp := temp - 1;
            end if;
            
     count <= std_logic_vector(unsigned(temp));
     
--           if (unsigned(count) = 128 and rd_en = '1' and wr_en = '1') then
--            full <= '0';
--            empty <= '0';
             --end if;
--           

         if (unsigned(count) = 128 and rd_en = '1' and wr_en = '1') then
            full <= '0';
            empty <= '0';
           elsif (unsigned(count) < 128) then
            
            empty <= '1';
           else
            empty <= '0';
           end if;
           if (unsigned(count) = 128 and rd_en = '0') then
            full <= '1';
           else
            full <= '0';
           end if;





     
     end if;
end process;




            






end Beh;
