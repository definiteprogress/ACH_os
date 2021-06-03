$LTDL_LIBRARY_PATH =  ../virtual_device_creation_try/bochs/plugins
$BXSHARE = ../virtual_device_creation_try/bochs/bochs
nasm -f bin Boot1.asm -o Boot1.bin
mkfs.vfat -C ../virtual_device_creation_try/Virtual_Floppy_Drive/floppy.img 2048
dd if=Boot1.bin of=../virtual_device_creation_try/Virtual_Floppy_Drive/floppy.img bs=512 count=10
bochs