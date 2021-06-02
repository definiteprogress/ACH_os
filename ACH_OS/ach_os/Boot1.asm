;*****************************************************************************************************
;      Boot1.asm
;                 - A Simple Bootloader
;      Operating System Development along with bootloader
;
;Summary of actions:
;      1. Laptop power switch ON, that triggers signal to the motherboard.
;      2. Motherboard gives control to powersupply, which inturn calls the routine "POST" to 
;         check if all i/o devices gets sufficient power.POST long jumps to 0xFFFF00 where
;         BIOS is located.
;      3. BIOS checks input/ouputs devices,sets up Interrupt Vector Table(IVT) and executes
;         interrupt 0x19, which is a interrupt to find boot sector ( or in plain text finds the
;         bootable device or disk with the help of the magic Boot signature 0xAA55 in byte 511 and 512)
;      4. if in byte 511 - 0xAA, 512 - 0x55, INT 0x19 will load and execute the bootloader.
;
;General Information:
;      1. Boot sector size - 512 bytes
;      2. Reason i took nasm - its creates flat binary
;      3. With respect to hardware software is written here.
;
;Assembly finding from this program:
;       db - data byte(8bytes), dw - data word(16 bytes), dd - data double word (32 bytes)
;
;Command to build:
;      1. nasm -f bin Boot1.asm -o Boot1.bin
;        -f option tells what type of output to generate, in this case its binary (-f bin)
;
;      2. mkfs.vfat -C ~/Monster/OS_Project/virtual_device_creation_try/floppy.img 1024
;         output - mkfs.fat 4.1 (2017-01-24) and creates floppy.img file
;	  information : Block size = 1024(1 =1KB) = 1MB
;      3. dd if=Boot1.bin of=~/Monster/OS_Project/virtual_device_creation_try/floppy.img bs=512 count=1
;	  output - 1+0 records in
;         output - 1+0 records out
;	  output - 512 bytes copied, 0.00044935 s, 1.1 MB/s
;
;*****************************************************************************************************

org 0x7c00               ;BIOS does 0x19 interrupt from its IVT and loads to sector number 0x7c00
                         ;(i.e 1st instruction will be at 0x7C00)
bits 16                  ;Indicates that we are still in 16-bit real mode

Start:
        cli              ;Clear all intterupts
        hlt              ;halts the system

times 510 - ($-$$) db 0  ;We have to be 512 bytes. Clear the rest of the bytes with 0.
                         ;in NASM '$' - represents address of current line,
                         ;"$$" - address of first instruction (i.e 0x7C00),so current address - 0x7C00
dw 0xAA55                ;Boot signature
