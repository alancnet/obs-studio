# culvert combined OBS (Wayland projector fix + HDR V4L2 capture)

Alan's OBS build for culvert: OBS 32.2.2 plus two local changes, so one
build covers both:

- The Wayland projector fix: commit "frontend: Keep WA_PaintOnScreen for
  projectors on Wayland" (branch `wayland-projector-fix`), which stops
  projectors from crashing OBS on native Wayland (KWin + NVIDIA explicit
  sync).
- HDR capture in the V4L2 source: commit "linux-v4l2: Add P010 and honor the
  device's PQ transfer" (branch `hdr-v4l2`). The source offers P010 and tags
  SMPTE 2084 devices as Rec. 2100 PQ.

This branch (`culvert-combined`) is `culvert-default` (the projector fix plus
this folder) merged with `hdr-v4l2`. Not for upstream.

- Source: `~/work/obs-projector/src` (git worktree of `~/work/obs-hdr/src`).
- Install: `~/work/obs-projector/default/install`. Same options and plugins as
  Arch's obs-studio 32.2.2-1 (websocket, browser on the system `cef`
  package, scripting, NVENC, PipeWire, V4L2, PulseAudio, JACK, VST, WebRTC,
  FDK AAC, QSV, DeckLink), plus the HDR V4L2 patch.
- Config: the normal `~/.config/obs-studio` (not portable).
- Started by `~/.local/bin/obs` (plain `obs` from any shell) and by
  `~/.local/share/applications/com.obsproject.Studio.desktop` (the menu).
  Copies of both are in this folder.
- The Arch obs-studio package stays installed as the fallback (`/usr/bin/obs`).

Revert to the Arch OBS (close OBS first):

    rm ~/.local/bin/obs ~/.local/share/applications/com.obsproject.Studio.desktop

Rebuild:

    culvert/configure.sh
    PATH=$HOME/work/hdr-10bit/venv/bin:$HOME/work/obs-projector/default/deps/venv/bin:$PATH \
      sh -c 'cmake --build build-default && cmake --install build-default'

`configure.sh` applies Arch's two obs-browser patches (`patches/`) and the
`/usr/lib/cef` rpath to the obs-browser submodule, uncommitted, as the
PKGBUILD does. Build deps not installed system-wide come from
`~/work/obs-projector/default/deps`: swig (pip venv), asio 1.30.2 and
websocketpp 0.8.2 headers.

HDR recording with the Elgato 4K60 Pro MK.2:

- Needs the sc0710 driver with the P010 format (branch `hdr-10bit` of
  alancnet/sc0710). With the stock driver the V4L2 source works as before.
- In the V4L2 source pick the `P010` video format. In Settings > Advanced set
  Color Format P010, Color Space Rec. 2100 (PQ), and record with a 10-bit
  encoder (for example NVENC HEVC, profile main10).
- Only one capture format can be open on the card at a time, so don't run
  two OBS instances on it.

Known issues:

- Browser source: the first time CEF starts with a fresh profile, Chromium
  shows an "Additional Terms of Service" window. Closing or cancelling it
  makes CEF fail ("CEF failed to initialize. Exit code: 28") and browser
  sources stay blank. The Arch build does the same with the system CEF 151.
  Left unfixed. Clicking Accept should get past it (not tested).
- Projectors have no title bar or borders on compositors without
  server-side decorations, such as GNOME (OBS issue #6283). KWin is fine.
- Untested: switching between fullscreen and windowed on GNOME, moving a
  projector between monitors, unplugging a monitor while a fullscreen
  projector is open, real compositor fractional scaling.
