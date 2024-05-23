run *args:
    zig build run {{args}}

release *args:
    zig build --release=fast run {{args}}

test:
    zig test src/main.zig
