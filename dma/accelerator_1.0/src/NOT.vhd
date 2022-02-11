--EEL 5721 RECONFIGURABLE COMPUTING
--GROUP NUMBER 46
--TEAM MEMBERS
-- PRIYANKA ABHIJIT TAMHANKAR UFID : 40893970
-- MEGHANA KODURU UFID: 

--Entity Description : Register entity to store the values of size and start address passed 
--by userapp to the DRAM till handshake completes sychronization and go_sync = 1 
------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity NOT_GATE is
port(	
        input: in std_logic;
	    output: out std_logic
);
end NOT_GATE;  

architecture NOT_GATE_arch of NOT_GATE is
begin
    output <= not(input);
end NOT_GATE_arch;