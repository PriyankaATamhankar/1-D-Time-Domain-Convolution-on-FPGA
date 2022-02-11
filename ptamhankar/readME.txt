EEL 5721 REconfigurable Computing
Group No. 46

Group Members 
1. Priyanka Abhijit Tamhankar UFID: 40893970
2. Meghana Koduru UFID: 64766702
-----------------------------------------------------------------------------------------------------------
Note to grader:
The complete implementation of combining the modified user_app and DMA inetrface dram_read_ram0 could not be completed.
When trying to combine the two entities vivado threw implementation error because of while combined bitfile was not 
getting generated. However they both are working individually.

Responsibilities
Priyanka Abhijit Tamhankar - DMA interface
Meghana Koduru - Signal buffer, Kernel buffer

The main folder contains two subfolders 
--ptamhankar
--dma 
 -- accelerator_1.0
 -- dram_test.bit --tests dram seperately
--convolve
 -- accelerator_1.0
 -- convolve.bit --tests user_app seperately
-- readME.txt
--REPORT