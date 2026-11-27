# alancnet/obs-studio: experimental branches

This fork carries a few **experimental** local changes on top of OBS Studio
32.2.2 (commit ba2f32b). They are not official OBS releases and are not
endorsed by the OBS Project. Tested only on an Elgato 4K60 Pro MK.2 capture card, KDE Plasma on Wayland and an NVIDIA RTX 3080. Other hardware is untested.

| Branch | What it is |
|---|---|
| `wayland-projector-fix` | One commit: keeps `WA_PaintOnScreen` for projectors on Wayland, so opening a projector no longer kills OBS under KWin + NVIDIA explicit sync. Known regression: no title bar on compositors without server-side decorations (GNOME). |
| `hdr-v4l2` | One commit: the V4L2 source accepts P010 and tags SMPTE 2084 (PQ) devices as Rec. 2100 PQ, so HDR10 capture cards can feed an HDR recording. |
| `culvert-default` | `wayland-projector-fix` plus `culvert/`: a build script with Arch's obs-studio options, launcher and desktop file, and a README. |
| `culvert-combined` | `culvert-default` merged with `hdr-v4l2`: one build with both changes. See `culvert/README.md`. |

HDR capture from the 4K60 Pro MK.2 also needs the experimental driver branch
`hdr-10bit` in [alancnet/sc0710](https://github.com/alancnet/sc0710).
