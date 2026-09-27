# Graphics evidence

The normalized ROM contains two readable microcode identification strings:

| ROM offset | Identifier | Version |
| --- | --- | --- |
| `0x96E80` | `RSP Gfx ucode F3DEX` | `1.21` |
| `0x97680` | `RSP Gfx ucode F3DLP.Rej` | `1.21` |

Both strings credit Yoshitaka Yasumoto and Nintendo. These are confirmed embedded identifiers. Runtime selection, associated instruction/data boundaries, task setup, and renderer architecture have not been traced. String presence alone does not establish which microcode each scene uses.

The matching [startup](startup.md) and [scheduler](scheduler.md) blocks now establish VI mode selection, retrace/SP/DP notification queues, and three dispatcher entry points. Their creation does not yet establish the complete task-submission protocol or scene-specific microcode choice; those dispatcher bodies remain fallback.
