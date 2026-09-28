# Save menu navigation recovery

The navigation block from `0x80025C40` through the boundary at `0x80026178` contains twelve complete matching functions totaling 1,336 code bytes. The recovered sources keep each function separate so their code and transitive inputs can be compared independently with the US ROM. These functions own no initialized data or BSS.

`func_80025C40` refreshes a save-level selection. Negative values become `1`; otherwise an invalid level advances by `D_800761F0`. It formats the resolved level name into the existing menu text buffer and submits that buffer to the text system. The declaration for `func_80021B20` comes from `save_game.h`, which also carries the recovered `GameSessionState` and `SceneDefinition` layouts used by the surrounding save and scene code.

`func_80025CD0`, `func_80025CFC`, and `func_80025D28` open the two menu definitions used by this path. `func_80025D54` is an empty callback. `func_80025D5C` clears the 0x64-byte navigation state, and `func_80025D88` marks an actor for removal while clearing the associated activity word.

The preview actor uses the same packed actor fields seen elsewhere in the game: object index at `0x0C`, the signed 16-bit timer/value at `0x0E`, flags at `0x14`, state byte at `0x21`, resource pointer at `0x24`, and callback at `0x44`. `func_80025D9C` and `func_80025E68` alternate that callback while switching animation state. `func_80025EF0` creates the preview actor, applies the resource scale, installs the callback, clears flag `0x20`, and records the preview in the navigation state. `func_80026044` releases that preview.

`func_8002606C` tears down the active menu. It releases the primary text slot, walks the linked child nodes and releases their text slots, optionally removes the preview actor, optionally restores the saved camera position and angles, marks the secondary actor for removal, and clears the active menu pointer.

The menu node has a 48-byte layout, and the navigation state is 100 bytes. Size assertions cover both. The twelve functions preserve the established field offsets as later menu-activation work gives names to previously unknown fields.

The first exact comparisons live under `.local/recovery59-menu`, with preserved snapshots under `.local/recovery61-menu/frozen_exact`. Those older proofs include the header version used for their original compilation. Independent integration comparisons under `.local/recovery61-integration` recompile all twelve sources against the current expanded header.

The comparison runner uses IDO 5.3 with `-O2 -G 0 -non_shared -mips1 -32`, checks each complete procedure and any allocated data, and records current source, transitive-header, compiler, and symbol-layout identities. The larger menu-activation routine at `0x80026178` remains a separate candidate until its complete comparison passes.
