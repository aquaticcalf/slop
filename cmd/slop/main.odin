package main

import "core:fmt"
import "pkg:slop"
import "pkg:jax"

main :: proc() {
	fmt.printf("2 + 4 = %d\n", slop.add(2, 4))
	fmt.printf("%s\n", jax.version())
}
