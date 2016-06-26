GRUB_MKRESCUE=grub-mkrescue
NASM=nasm
QEMU=qemu-system-x86_64
O_files = target/multiboot_header.o target/boot.o
# Rust-related variables
RS_target = x86_64-unknown-rhapsodyos-gnu
RS_target_description = $(RS_target).json
RS_target_description_path = build/$(RS_target_description)
RS_libcore_rlib_path = build/libcore/target/$(RS_target)/release/
RS_libcore_rlib = $(RS_libcore_rlib_path)/libcore.rlib
RS_libkernel = target/$(RS_target)/release/librhapsodyos.a

default: build build_iso cargo

build: target/kernel.bin
	@echo '»»Built the Kernel'
build_iso: target/os.iso
	@echo '»»Built the ISO'
cargo: $(RS_libkernel)
	@echo '»»Built the Rust source'

target/multiboot_header.o: src/asm/multiboot_header.asm
	mkdir -p target
	$(NASM) -f elf64 src/asm/multiboot_header.asm -o target/multiboot_header.o

target/boot.o: src/asm/boot.asm
	$(NASM) -f elf64 src/asm/boot.asm -o target/boot.o

target/kernel.bin: $(O_files) build/linker.ld $(RS_libkernel)
	ld -n -o target/kernel.bin -T build/linker.ld $(O_files) $(RS_libkernel)

target/os.iso: target/kernel.bin build/grub.cfg
	mkdir -p target/isofiles/boot/grub
	cp build/grub.cfg target/isofiles/boot/grub
	cp target/kernel.bin target/isofiles/boot/
	$(GRUB_MKRESCUE) -o target/os.iso target/isofiles

# Rust related builds, just invoking Cargo
build/libcore: build/libcore/.git
	git submodule sync
	git submodule update --init

build/libcore/target/$(RS_target)/libcore.rlib: build/libcore
	@cp $(RS_target_description_path) build/libcore/$(RS_target_description)
	cd build/libcore && cargo build --release --features disable_float --target=$(RS_target_description)
	@$(RM) build/libcore/$(RS_target_description)

$(RS_libkernel): build/libcore/target/$(RS_target)/libcore.rlib
	@cp $(RS_target_description_path) $(RS_target_description)
	RUSTFLAGS="-L $(RS_libcore_rlib_path)" cargo build --release --target=$(RS_target_description)
	@$(RM) $(RS_target_description)

run: target/os.iso
	$(QEMU) -cdrom target/os.iso

clean:
	cargo clean
	cd build/libcore && cargo clean
	rm -rf target
	$(RM) $(RS_target_description) build/libcore/$(RS_target_description)

.PHONY: default clean run build build_iso cargo
