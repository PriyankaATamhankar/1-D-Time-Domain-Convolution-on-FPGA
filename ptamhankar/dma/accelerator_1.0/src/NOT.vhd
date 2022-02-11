--EEL 5721 RECONFIGURABLE COMPUTING
--GROUP NUMBER 46
--TEAM MEMBERS
-- PRIYANKA ABHIJIT TAMHANKAR UFID : 40893970
-- MEGHANA KODURU UFID: 64766702

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