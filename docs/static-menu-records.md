# Static confirmation and pause menus

Six C units reconstruct 480 initialized bytes: two 52-byte pages, seven
40-byte labels and nine strings including their original alignment bytes.
This recovery adds no instruction or BSS ownership. The 616-byte activation
procedure at `80026178` remains excluded.

| Definition | Address | Complete bytes |
| --- | --- | ---: |
| Confirmation labels | `800772A0` | 80 |
| Confirmation page | `800772F0` | 52 |
| Pause labels | `80077454` | 200 |
| Pause page | `8007751C` | 52 |
| Confirmation text | `8009347C` | 16 |
| Pause text | `800934F0` | 80 |

The lists run backward through their arrays. Confirmation starts with
"no" and ends with "yes". Pause starts with "continue", followed by
"save game", "quit game", "options" and the disabled password label.
The password text begins with one backslash byte. These definitions retain
the initial selections, text slots, flags, spacing, sounds and callback
addresses, including the null selection pointers and alternate labels.

Static navigation reads a timeout callback at page offset `0x30`. Both
recovered pages initialize it to null. `MenuStaticPage` therefore contains
the existing 48-byte `MenuOptionsPage` initializer view and this additional
word. The dynamically constructed page keeps its existing 48-byte ownership;
this recovery does not establish storage for its following timeout word.

The callback union retains its pointer-selection and integer-cancellation
interfaces. Its unprototyped entry member permits C89 constant initialization
with the actual callback declarations. No function prototype is changed and
the data units do not invoke callbacks. One-element page arrays preserve the
existing address expressions used by matched callers.

Pinned IDO compilation, independent complete data comparisons, spimdisasm
and splat reassembly verify the records, strings, pointer relocations and
section extents. The compiler adds eight trailing alignment bytes to the
pause-label object and twelve to each page object; those bytes are excluded
after checking that they are zero. String alignment bytes inside the declared
owned ranges remain part of the comparison.

`tools/check_static_menu_records.py` executes the existing matching cleanup
and immediate transition procedures with retail and source-built records.
Its 512 cases compare 1,024 executions and detect four data mutations.
It checks linked-list traversal, complete fixture bytes, text-release calls,
preview and actor state, saved camera arguments, stack guards, the stack pointer,
global pointer and saved integer registers.
Text release and camera submission use recorded stubs that clobber caller-saved
integer and floating-point registers. Menu activation, callback invocation,
text rendering and gameplay are outside this execution proof.

[The provenance ledger](static-menu-records-provenance.json) records current
validation and its limits. Whole-ROM
equality still includes extracted fallback code and assets and does not
establish completion of the decompilation. Tools and local reference projects
are credited in [reference study](reference-study.md).
