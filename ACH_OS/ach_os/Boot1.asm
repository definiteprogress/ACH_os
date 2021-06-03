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
;      4. bochs - to execute the OS on bochs emulator.
;
;NOTE:
;       Execute all the commands from the folder that has this file.
;*****************************************************************************************************
bits 16                  ;Indicates that we are still in 16-bit real mode

org 0x7c00               ;BIOS does 0x19 interrupt from its IVT and loads to sector number 0x7c00
                         ;(i.e 1st instruction will be at 0x7C00)

Start: jmp loader        ;jump over OEM block

;*************************************************;
;	OEM Parameter block
;*************************************************;

; Error Fix 2 - Removing the ugly TIMES directive -------------------------------------

TIMES 0Bh-$+start DB 0  ; The OEM Parameter Block is exactally 3 bytes
						; from where we are loaded at. This fills in those
						; 3 bytes, along with 8 more. Why?


;pbOEM			db "ACH OS   "	        ; This member must be exactally 8 bytes. It is just
										; the name of your OS :) Everything else remains the same.

bpbBytesPerSector:  	DW 512
bpbSectorsPerCluster: 	DB 1
bpbReservedSectors: 	DW 1
bpbNumberOfFATs: 	    DB 2
bpbRootEntries: 	    DW 224
bpbTotalSectors: 	    DW 2880
bpbMedia: 	            DB 0xF0
bpbSectorsPerFAT: 	    DW 9
bpbSectorsPerTrack: 	DW 18
bpbHeadsPerCylinder: 	DW 2
bpbHiddenSectors: 	    DD 0
bpbTotalSectorsBig:     DD 0
bsDriveNumber: 	        DB 0
bsUnused: 	            DB 0
bsExtBootSignature: 	DB 0x29
bsSerialNumber:	        DD 0xa0a1a2a3
bsVolumeLabel: 	        DB "MOS FLOPPY "
bsFileSystem: 	        DB "FAT12   "

;msg	db	"Welcome to ACH Operating System!", 0		; the string to print

;***************************************
;	Prints a string
;	DS=>SI: 0 terminated string
;***************************************

Print:
	lodsb			; load next byte from string from SI to AL
	or      al, al	; al=current character
	jz	PrintDone	; null terminator found? - no,so continue or bail-out
	mov	ah,	0eh	    ; get next character
	int	10h
	jmp	Print		; Repeat until null terminator found
PrintDone:
	ret			    ; we are done, so return

;*************************************************;
;	Bootloader Entry Point
;*************************************************;

loader:

; Error Fix 1 ------------------------------------------
;    xor	ax, ax	; Setup segments to insure they are 0. Remember that
;	mov	ds, ax	; we have ORG 0x7c00. This means all addresses are based
;	mov	es, ax	; from 0x7c00:0. Because the data segments are within the same
				; code segment, null em.

;	mov	si, msg	; our message to print
;	call Print	; call our print function

;	xor	ax, ax	; clear ax
;	int	0x12	; get the amount of KB from the BIOS
                ; Now AX = Amount of KB in system recorded by BIOS

;    cli         ;Clear all intterupts
;    hlt         ;halts the system

.Reset:
	mov		ah, 0					; reset floppy disk function
	mov		dl, 0					; drive 0 is floppy drive
	int		0x13					; call BIOS
	jc		.Reset					; If Carry Flag (CF) is set, there was an error. Try resetting again
 
	mov		ax, 0x1000				; we are going to read sector to into address 0x1000:0
	mov		es, ax
	xor		bx, bx
 
	mov		ah, 0x02				; read floppy sector function
	mov		al, 1					; read 1 sector
	mov		ch, 1					; we are reading the second sector past us, so its still on track 1
	mov		cl, 2					; sector to read (The second sector)
	mov		dh, 0					; head number
	mov		dl, 0					; drive number. Remember Drive 0 is floppy drive.
	int		0x13					; call BIOS - Read the sector
	
 
	jmp		0x1000:0x0				; jump to execute the sector!

times 510 - ($-$$) db 0 ;We have to be 512 bytes. Clear the rest of the bytes with 0.
                        ;in NASM '$' - represents address of current line,
                        ;"$$" - address of first instruction (i.e 0x7C00),so current address - 0x7C00
dw 0xAA55               ;Boot signature

; End of sector 1, beginning of sector 2 ---------------------------------
 
 
org 0x1000							; This sector is loaded at 0x1000:0 by the bootsector
 
cli									; just halt the system
hlt
