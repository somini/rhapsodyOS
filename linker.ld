ENTRY(start)

SECTIONS {
	/* Skip the first 1MB */
	/* Convention, there's memory mapped stuff before that */
	. = 1M;

	.boot :
	{
		/* Multiboot Header at the beggining */
		*(.multiboot_header)
	}

	.text :
	{
		*(.text)
	}
}
