# Actor pool allocation

`func_800283D4` covers `0x800283D4..0x800286E8`. Its complete 788-byte
procedure matches the supplied USA ROM with IDO 5.3 and the ordinary
game profile. The source is `src/game/actor_pool_allocate.c`. Its five
diagnostics occupy the complete 96-byte span at
`0x8009390C..0x8009396C`, including compiler alignment.

The routine rejects allocation when the live count equals 200. It checks
the resource's confirmed loaded bit, prints the kind name if loading is
needed, and calls the matching resource loader. Kinds zero, nine, four,
and five also print a resource index. Those diagnostics retain the
observed subtraction of the resource address from the table base,
followed by signed division by the respective 104-, 88-, or 92-byte
stride. The reversed subtraction is preserved.

The indexed loop scans all 200 actors for kind eleven, the free marker
also written by the matching pool-reset routine. It selects the first
free record and passes that record and its resource to the matching
object-creation service. If that service returns -1, the allocator
returns null before changing the actor pool or list.

After successful object creation, the allocator clears the complete
124-byte record, links it at the head of the existing actor list, and
increments the live count. It stores the object index, resource, and
kind. Kind five also increments the counter indexed by the resource's
actor kind. It copies the resource halfwords and all three supplied
coordinates, clears the state and offset `0x74`, sets offset `0x34` to
-1, and derives a halfword from `playbackSpeed * 3000 / 96` using signed
division.

The matching scale service receives the resource scale shifted left by
twelve and divided by float 40960. The allocator then submits the
position, begins animation zero with reset enabled, copies the current
time into offset `0x48`, and copies the resource's offset `0x54` word
into the actor's offset `0x5C`. It returns the selected actor.

The selected actor local remains unwritten if no free marker is found.
The target reads that unwritten local at stack offset `0x24` on this
path. Its capacity check tests equality with 200; it does not reject
larger counts or otherwise handle an inconsistent pool. The source
preserves this behavior. All four locals serve the scan, result, or
selected actor; the full 48-byte frame matches without extra formals or
unused padding.

`D_800A4628` now owns the verified 200-entry pool. Its BSS span is
`0x800A4628..0x800AA708`, exactly 24,800 bytes. The existing 124-byte
`GameActor` assertion, allocator scan, complete clear, and matching
pool reset establish the extent. Startup clears the span within the
confirmed BSS range. The adjacent list-head pointer and live count
remain separate storage.

The object-creation declaration now resides in `object.h` and agrees
with its matching definition: two integers followed by draw and model
pointers. The actor and resource casts express the shared byte views.
The text caller retains its historical zero-or-one third argument with
an explicit pointer cast; the helper retains its null draw argument.
Complete comparisons check both callers and every shared-header user.

The [provenance ledger](actor-pool-allocation-provenance.json) records
complete instruction and diagnostic bounds, compiler inputs, linked
bytes, and the BSS symbol. Robotron's instructions and matching callees
establish the behavior. All thirteen requested N64 references, pinned
revisions, and licenses remain credited for local and online use in
[CREDITS.md](../CREDITS.md). Further actor recovery is tracked by
[issue #43](https://github.com/frankischilling/robotron64/issues/43) and
[draft PR #46](https://github.com/frankischilling/robotron64/pull/46).
