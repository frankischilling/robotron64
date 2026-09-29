# Legacy save menu proof ledger

The six source units recovered at `0x80025688..0x80025C40` compile with IDO 5.3 using `-O2 -G 0 -non_shared -mips1 -32`. Their linked comparison reports use the current symbol layout and the US ROM. Each report records `matches: true`, zero differing words, and no owned-data errors.

| Source | Source SHA-256 | Linked report | Report SHA-256 |
| --- | --- | --- | --- |
| `src/game/save_menu_legacy_reset.c` | `7f3c793b5feac81db494b655566e183ada1721356073b97ec5c362a78e81443f` | `.local/linked-probes/probes/save_menu_legacy_reset-5.3-O2-mips1/report.json` | `351ab0b3a754ab26d49843398df30d98e196cc525783a8010e819337b3ddafd2` |
| `src/game/save_menu_legacy_heap.c` | `6e649daa2c2a18d1cfec4c76cef9f67034f3238a7ce315754c3942863fc82a38` | `.local/linked-probes/probes/save_menu_legacy_heap-5.3-O2-mips1/report.json` | `897978d79559d54387a9973e35004d14791d9d4184801ed8aa517649b1ed7fcc` |
| `src/game/save_menu_legacy_pages.c` | `9dde0ff7ae25b35b04c8860a484a6e068d81622390740fcbd7e4994a04e0c85f` | `.local/linked-probes/probes/save_menu_legacy_pages-5.3-O2-mips1/report.json` | `c3ea43f68204daccbf904e1378d7ded6f7ccf7afdb399bd9516b8141b294898d` |
| `src/game/save_menu_legacy_pak_status.c` | `3e8fd8e8ebdcc6be3bca82678344ebffc11927088471542b7eb9554e977eb706` | `.local/linked-probes/probes/save_menu_legacy_pak_status-5.3-O2-mips1/report.json` | `c68819876241d4c0d79c3ec12bcb9ae6a803d8e5c2155a454d759349f559eebf` |
| `src/game/save_menu_legacy_exit.c` | `a38dc863047247b1b4efcc0b4f0d4e2db0b007496e12c908e136816c2d8cf45b` | `.local/linked-probes/probes/save_menu_legacy_exit-5.3-O2-mips1/report.json` | `de7c2442e9d8db8a5619c009b0145a7041173c3759f5d955773af9be6eb7600f` |
| `src/game/save_menu_legacy_pages_tail.c` | `fcb8098a3f7116baa5fbe40b56508a3611048ad3006f4e5b74534790fa199366` | `.local/linked-probes/probes/save_menu_legacy_pages_tail-5.3-O2-mips1/report.json` | `15368d55d264b0f20436e1b2176b4957940e424c5c79b6db1f5601639f3e6d8b` |

The integrated ROM verification matched all 8,388,608 bytes with SHA-256 `91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.

## Earlier save/menu helpers

| Source | Source SHA-256 | Linked report | Report SHA-256 |
| --- | --- | --- | --- |
| `src/game/save_level_lookup.c` | `039b626cca496b07a9ab2039fa89a5a6c3ec3509d82494bded97a93022942de8` | `.local/linked-probes/probes/save_level_lookup-5.3-O2-mips1/report.json` | `23d431a49591510ba4905f01184e7ee401d3148c37c3c79da6b174d17c02f2b9` |
| `src/game/save_menu_conditional_copy.c` | `da753efa6429ccc9851c8759563c06000c4915b8933c95e9b851136598b2a222` | `.local/linked-probes/probes/save_menu_conditional_copy-5.3-O2-mips1/report.json` | `6b9f11b2f77bbd0a16e5d38054a39742283c29a3fba910774b425ba60a44b25a` |
| `src/game/save_menu_flag_setter.c` | `9aaecf3fd560fdb2dde8a7cecc91f835af56d16e77bfad01f00c73da62799ee3` | `.local/linked-probes/probes/save_menu_flag_setter-5.3-O2-mips1/report.json` | `efa34348d952cf113a7309bcf3edc8dae600b38f1350e2e122b39cdf57eed3f5` |
| `src/game/save_menu_state_reset.c` | `6a55af0be752f36ccaa3c437392e505e9419480be6e84f8520375c7a72927628` | `.local/linked-probes/probes/save_menu_state_reset-5.3-O2-mips1/report.json` | `495f01bf757b63c1a0b4235251b3c2ffa28d8e0859d4ab95a48d2adad4b6004f` |

The filtered canonical `runtime-comparison` report for these four blocks is `build/runtime-comparison/helpers-report.json` with SHA-256 `4253ac655dc188f31639e3c072e6829861ba713cab41b934b268e4d5638763ca`. It records four matches and zero differing words across 120/120 target bytes.
