# Controller Pak file helpers

The recovered Pak layer uses controller Pak slot 0 and keeps the active file number in `D_8013DB78`. The open routine accepts a device argument, but its target code does not use it.

## Save file identity

`func_8004C3AC` passes the constants `0x345A` and `0x4E525845` to the Pak file lookup and allocation routines. The target ROM strings used for the file name are `"ROBO 64"`; the extension strings are empty.

Before each lookup, `func_8004C65C` converts the name into the controller Pak character encoding and writes the result to `D_8013DC10`. Its target mapping is:

| Input | Output |
| --- | --- |
| `'A'..'Z'` | input - 0x27 |
| `'0'..'9'` | input - 0x20 |
| space | 0x0F |
| other bytes | unchanged |

The terminating zero is copied too, and the function returns `D_8013DC10`.

## Status and open behavior

`func_8004C378` calls `func_8004F6B4`, prints the returned value with `"InitPak2, GetWindowsDirectory returns %d\n"`, and returns that value. Existing target callers pass arguments to this entry even though it reads none, so `pak_file.h` intentionally leaves its parameter list unspecified.

`func_8004C3AC` increments `D_8008D350` on every call. Once the pre-increment value is at least 2, it sets `D_80075FB8` to 2 for mode `'w'` and 1 for other modes.

The first operation searches Pak 0 for `"ROBO 64"`. When the lookup returns `SDK_PFS_ERR_INVALID`, read mode clears `D_80075FB8` and returns 0. Write mode allocates a 0x1000-byte file, performs the lookup again, and then returns:

| Result | Target path |
| ---: | --- |
| 1 | Lookup did not report invalid, fatal-ID, or device error. |
| 0 | File remained invalid after the write-mode allocation path. |
| -1 | Lookup reported `SDK_PFS_ERR_ID_FATAL` or `SDK_PFS_ERR_DEVICE`. |

The file number returned by the Pak service is stored through `D_8013DB78` and is the value later used by the read and write wrappers.

## Read, write, and close

`func_8004C564` computes `size * count`, clears that many destination bytes, and calls `func_80062DEC` with the read flag. `func_8004C5DC` computes the same byte count and calls `func_80062DEC` with the write flag. Both operate on Pak 0 and the file number in `D_8013DB78`.

Neither wrapper propagates the return value from `func_80062DEC`. Both clear `D_80075FB8` and return the requested byte count. This is target behavior. The save layer's 0x1000-byte read/write length checks therefore see the requested length from these wrappers.

`func_8004C648` ignores its handle argument, clears `D_80075FB8`, and returns 0.

## Matching evidence

Fresh IDO 5.3 `-O2 -G 0 -non_shared -mips1 -32` comparisons in `.local/recovery26-save-pak` match every current Pak helper in this range:

| Function | Range | Bytes |
| --- | --- | ---: |
| `func_8004C378` | 0x8004C378..0x8004C3AC | 52 |
| `func_8004C3AC` | 0x8004C3AC..0x8004C564 | 440 |
| `func_8004C564` | 0x8004C564..0x8004C5DC | 120 |
| `func_8004C5DC` | 0x8004C5DC..0x8004C648 | 108 |
| `func_8004C648` | 0x8004C648..0x8004C65C | 20 |
| `func_8004C65C` | 0x8004C65C..0x8004C6DC | 128 |

The Pak sources contain no owned allocated data section in these comparison reports. They reference the existing shared globals and ROM strings listed above.
