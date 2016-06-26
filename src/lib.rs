// vim: fdm=marker
//{{{ Boilerplate
#![feature(lang_items)]
#![no_std]

#[lang = "eh_personality"]
extern fn eh_personality() {
}

#[lang = "panic_fmt"]
extern fn rust_begin_panic() -> ! {
    loop {}
}
//}}}

#[no_mangle]
// Kernel Main entry point
pub extern fn kmain() -> ! {
    // Port of src/asm/boot.asm:144
    unsafe {
        let vga = 0xb8000 as *mut u64;

        *vga = 0x2f592f412f4b2f4f;
    };
    // This function never returns
    loop { }
}
