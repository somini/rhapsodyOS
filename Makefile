GRUB_MKRESCUE=grub-mkrescue
NASM=nasm
QEMU=qemu-system-x86_64

default: build build_iso

build: target/kernel.bin
build_iso: target/os.iso

target/multiboot_header.o: src/asm/multiboot_header.asm
	mkdir -p target
	$(NASM) -f elf64 src/asm/multiboot_header.asm -o target/multiboot_header.o

target/boot.o: src/asm/boot.asm
	$(NASM) -f elf64 src/asm/boot.asm -o target/boot.o

target/kernel.bin: target/multiboot_header.o target/boot.o build/linker.ld
	ld -n -o target/kernel.bin -T build/linker.ld target/multiboot_header.o target/boot.o

target/os.iso: target/kernel.bin build/grub.cfg
	mkdir -p target/isofiles/boot/grub
	cp build/grub.cfg target/isofiles/boot/grub
	cp target/kernel.bin target/isofiles/boot/
	$(GRUB_MKRESCUE) -o target/os.iso target/isofiles


run: target/os.iso
	$(QEMU) -cdrom target/os.iso

clean:
	rm -rf target
	cargo clean

.PHONY: default clean run build build_iso
