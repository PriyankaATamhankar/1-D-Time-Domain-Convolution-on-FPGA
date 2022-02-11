--EEL 5721 RECONFIGURABLE COMPUTING
--GROUP NUMBER 46
--TEAM MEMBERS
-- PRIYANKA ABHIJIT TAMHANKAR UFID : 40893970
-- MEGHANA KODURU UFID: 64766702

------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity AND_GATE is
port(	input1: in std_logic;
	    input2: in std_logic;
	    output: out std_logic
);
end AND_GATE;  

--------------------------------------------------
architecture AND_GATE_arch of AND_GATE is
begin

    output<= input1 and input2;

end AND_GATE_arch;

--------------------------------------------------