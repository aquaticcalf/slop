package slop_test

import "core:testing"
import "pkg:slop"

@(test)
test_add :: proc(t: ^testing.T) {
	testing.expect_value(t, slop.add(2, 4), i32(6))
}
