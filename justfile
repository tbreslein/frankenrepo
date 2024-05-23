run *args:
    zig build run {{args}}

test:
    zig test src/main.zig
