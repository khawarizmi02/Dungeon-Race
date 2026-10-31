package main

import "core:bufio"
import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

@(private = "file")
stdin_reader: bufio.Reader

terminal_init :: proc() {
	bufio.reader_init(&stdin_reader, os.to_stream(os.stdin))
}

clear_screen :: proc() {
	fmt.print("\x1b[2J\x1b[H")
}

// End of input (Ctrl+D) quits the game.
read_line :: proc(prompt: string) -> string {
	fmt.print(prompt)
	s, err := bufio.reader_read_string(&stdin_reader, '\n', context.temp_allocator)
	if err != nil && len(s) == 0 {
		fmt.println()
		os.exit(0)
	}
	return strings.trim_space(s)
}

// Keeps asking until the player types a whole number.
read_int :: proc(prompt: string) -> int {
	for {
		if v, ok := strconv.parse_int(read_line(prompt)); ok do return v
		fmt.println("Please enter a number.")
	}
}

pause :: proc() {
	read_line("Press Enter to continue...")
}
