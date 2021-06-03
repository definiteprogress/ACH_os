# ACH_os
Operating System developement

Instruction to run os on bochs ( one time configuration)
1. bochs from home directory of project, then select 2.
2. Configuration file path : ach_os/bochsrc.txt
3. select 6 to simulate os on bochs


To delete the Boot1.bin file and to execute the bochs simulation, follow the shell script execution order 1 upto 3, neglect 4 - additional debug data

1. bash del_script.sh
2. bash build.sh
3. c 
4. if wanna fix breakpoint b <address> , i.e b 0x7C00, and c to continue, s - single instruction