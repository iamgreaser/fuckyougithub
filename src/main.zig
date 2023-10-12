// Compile this in!
// Also, this is in violation of the TOTP standard (the key is too small), because it's actually Google Authenticator and they really don't actually give a fuck about actual security!
const key_string = "WQUQKY4YS5UK6UJ5";

// Details from here: https://en.wikipedia.org/wiki/Google_Authenticator

// > During setup, the service provider generates an 80-bit secret key for each user
// > (whereas RFC 4226 §4 requires 128 bits and recommends 160 bits).
// > This is transferred to the Authenticator app as a 16, 26, or 32-character base32 string, or as a QR code.

const std = @import("std");
const log = std.log.scoped(.main);
pub const std_options = struct {
    pub const log_level = .debug;
};

pub fn main() !void {
    log.info("Using key \"{s}\"", .{key_string});
    var rawkey: [@divExact(80, 8)]u8 = undefined;
    {
        var writer_backing = std.io.fixedBufferStream(&rawkey);
        var bw = std.io.bitWriter(.Big, writer_backing.writer());
        for (key_string) |v| {
            try bw.writeBits(b32dectable[v].?, 5);
        }
    }
    //log.info("Decoded key as {any}", .{rawkey});

    // Now generate the code!
    var rawresult: [@divExact(160, 8)]u8 = undefined;
    var ctr: [@divExact(64, 8)]u8 = undefined;
    {
        var writer_backing = std.io.fixedBufferStream(&ctr);
        var t: i64 = @divFloor(std.time.timestamp(), 30);
        try writer_backing.writer().writeIntBig(i64, t);
    }
    std.crypto.auth.hmac.HmacSha1.create(&rawresult, &ctr, &rawkey);
    //log.info("Raw counter: {any}", .{ctr});
    //log.info("Raw result: {any}", .{rawresult});

    // Do the truncation
    var trunc_idx = @as(usize, rawresult[rawresult.len - 1] & 0xF);
    var hotp = std.mem.readInt(u32, (rawresult[trunc_idx..][0..4]), .Big) & 0x7FFFFFFF;
    //log.info("Full result: {d:0>10}", .{hotp});

    // We are done.
    try std.io.getStdOut().writer().print("{d:0>6}\n", .{hotp % 1_000_000});
}

const b32enctable = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
const b32dectable = result: {
    comptime var result: [256]?u5 = undefined;
    for (&result) |*v| v.* = null;
    for (b32enctable, 0..) |s, d| result[s] = @as(u5, @intCast(d));
    break :result result;
};
