# Controller motor worker

`func_8004F06C` is a complete 268-byte routine at ROM `0x4FC6C`. It waits on `D_80141210`, acquires controller access through `func_8004F000`, reads the signed operation halfword and port word from the eight-byte command, and releases access through `func_8004F040` after handling the command.

Operation one calls the SDK motor-start entry `func_80063858` on the selected 104-byte `SdkPfs` record. A zero result sets that port's `D_80143408` word to one. Operation zero calls motor stop at `func_800636F0`; a zero result clears the word. Other operation values still release access. The target performs no port bounds check, and the source preserves that behavior.

The operation and port are captured before calling either SDK entry. Declaring the signed operation separately preserves the target's local layout: the message pointer occupies stack offset `0x48` in an `0x50`-byte frame.

The worker compiles in `controller_access.c` after the three existing access helpers. Its original start is four bytes beyond an eight-byte boundary. IDO aligns the unreachable epilogue relative to the containing object; compiling the worker alone loses one alignment word before that epilogue. Compiling all four complete routines together reproduces the entire 456-byte target span with zero differing words. No assembly padding is inserted into source.

This recovery adds one matching C procedure and 268 instruction bytes. It claims no new initialized data or BSS; the existing confirmed queue, command, and Pak record layouts remain shared. Independent runtime comparison verifies all four procedures using the IDO 5.3 game profile, and linked progress requires every complete procedure extent and the whole ROM to match.

The motor and message interfaces were checked against the pinned local libreultra, GoldenEye, and Super Mario 64 references credited in [CREDITS.md](../CREDITS.md). Robotron's instructions establish the command protocol and access sequence. The adjacent duty update remains a nonmatching local candidate and is excluded from progress.
