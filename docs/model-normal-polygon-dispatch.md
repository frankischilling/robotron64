# Model polygon normals and submission

The two routines at `0x8003EE20..0x8003EFC4` and
`0x8003EFC4..0x8003F168` each contain 420 instruction bytes. They walk a
mesh's polygons, set the polygon material through their respective
existing setup service, submit four normal values, and dispatch a
textured triangle or quad. Their only service difference is
`func_80043E80` versus `func_80043EEC`.

Both functions cache all four signed vertex indices before the material
call, then read the four normal indices afterward. They call
`func_80043930` for normal slots 0 through 3 even when the polygon has
three vertices. A vertex count of three selects `func_80044D84`; every
other count selects `func_80044B18`. The normal array uses its existing
eight-byte stride, and positions use their existing twelve-byte stride.

The source retains a field cursor and the indexed polygon pointer used
by the setup call. Both advance by the verified 36-byte polygon stride.
The loop checks the mesh's polygon count again after external calls.
Its guarded do loop skips the entire body for a nonpositive count. The
four cached vertex indices use a 16-byte integer structure; the first
three remain in saved registers, and the fourth occupies the target's
word slot at stack offset `0x44` within a 96-byte frame.

## Complete comparison

IDO 5.3 with `-O2 -G 0 -non_shared -mips1 -32` reproduces the complete
840-byte source unit. The field cursor initialization and following
`do` share a source line because IDO schedules the retained address moves
differently when they are separated. This formatting preserves the same
C operations; it adds no condition, temporary constant, instruction patch,
or assembly. A private source search suggested the line grouping, and
independent full comparison establishes acceptance.

Acceptance checks both linked procedure types, their exact sizes and
placements, all instruction words, current source/header/compiler inputs,
and full ROM equality. These recoveries add two complete C procedures and
840 instruction bytes, with no new initialized data or BSS ownership.
Complete hashes and build inputs are recorded in
[the provenance ledger](model-normal-polygon-dispatch-provenance.json).

A clean archive of `738831b` passes fresh extraction and build, all 137
tooling tests, 790 complete runtime comparisons, both startup units,
eighteen assembly units, and eight data-only units. Linked progress records
1,307 matching C procedures and 219,856 instruction bytes, with 9,547
initialized and 30,353 BSS bytes owned by source. The complete ROM matches
the supplied USA target, SHA-256
`91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.
The publication audit checks all 1,278 public files.

Robotron's target instructions and the recovered mesh, polygon, material,
normal and primitive services establish the behavior. The pinned IDO,
N64 matching workflows, and local source search tool are credited for local
and online use in [CREDITS.md](../CREDITS.md). Further renderer and model
work remains tracked by [issue #41](https://github.com/frankischilling/robotron64/issues/41).
