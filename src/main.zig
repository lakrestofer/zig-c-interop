const std = @import("std");

const c = @cImport({
    @cInclude("stdio.h");
    @cInclude("cxmath.h");
});

pub fn main() !void {
    _ = c.printf("Hello\n");
    _ = c.printf("%d\n", c.cxadd(12, 34));
    c.sayHi();
}
