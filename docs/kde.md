# KDE Plasma 6 on OnePlus Pad 3 (erhai)

This document provides a comprehensive guide to running and building **Ubuntu with KDE Plasma 6** on the OnePlus Pad 3 (`erhai`), including the independent rootfs build process, custom tablet plasmoids, system CLI, virtual keyboard optimizations, and hardware tweaks.

---

## 1. Dual Desktop Environments & Independent Builders

The repository supports building both **Ubuntu GNOME** and **KDE Plasma 6** rootfs images independently:

| Desktop Environment | Builder Script | Output Rootfs Image | Display Manager | Session Compositor |
| :--- | :--- | :--- | :--- | :--- |
| **Ubuntu GNOME** | `sudo ./build-root.sh resolute` | `rootfs-resolute.img` | GDM3 | GNOME Shell (Wayland) |
| **KDE Plasma 6** | `sudo ./build-root-kde.sh resolute` | `rootfs-resolute-kde.img` | SDDM | KWin (Wayland) |

*(Pass `stonking` instead of `resolute` to target Ubuntu 26.10 instead of 26.04 LTS).*

### Building KDE Plasma 6 RootFS

To build the KDE Plasma 6 image:
```bash
# Ubuntu 26.04 LTS (recommended)
sudo ./build-root-kde.sh resolute

# Ubuntu 26.10
sudo ./build-root-kde.sh stonking

# Optional: pre-configure a default user account
sudo PRESET_USER=1 ./build-root-kde.sh resolute
```

The script layers the KDE-specific configurations located in [`main/root-setup/overlay-kde/`](file:///home/zen/oneplus-erhai-ubuntu/main/root-setup/overlay-kde) on top of the root filesystem without modifying any upstream GNOME packages or scripts.

---

## 2. Desktop & Compositor Integrations

### SDDM Tablet Session (`10-tablet.conf`)
Located at `/etc/sddm.conf.d/10-tablet.conf`:
* Configures SDDM to run a pure Wayland greeter using `kwin_wayland`.
* Enables the on-screen keyboard at login (`InputMethod=qtvirtualkeyboard`).
* Sets an enlarged touch-friendly cursor size (36px).
* Auto-login support for the primary user.

### KWin Wayland (`kwinrc`)
* Touchscreen gesture navigation enabled for app switching and overview.
* Automatic orientation detection via device sensors.
* Tablet mode transitions: auto-detects touch interactions and maximizes window control targets.

---

## 3. Native Touch-Optimized Plasma Applets (Plasmoids)

KDE Plasma 6 on Erhai includes custom applets specifically written for the tablet's hardware:

### 1. Erhai Controls (`org.erhai.plasma.controls`)
A quick-settings control center tile and popup panel:
* **Thermal Profiles**: Instant switching between 4 hardware thermal limits:
  * **Performance**: ~103°C ceiling for maximum sustained GPU/CPU clocks.
  * **Balanced**: ~90°C ceiling (default).
  * **Cool**: ~80°C ceiling.
  * **Cold**: ~70°C ceiling for quiet and low skin temperatures.
* **Bypass Charging**: Directly power the tablet from the charger without routing current through the battery cells, preserving battery health and reducing thermals during heavy workloads or gaming.
* **Flashlight / Torch**: Brightness slider (0–100% mapped safely up to the 80% controller ceiling) and instant on/off toggle.
* **Quick Toggles**: Auto-brightness, auto-rotation, and virtual keyboard visibility.

### 2. Power & Battery Applet (`org.kde.plasma.battery`)
* Identifies fast-charging protocols:
  * **OnePlus SuperVOOC** (Southchip SC8547A charge pump).
  * **USB-PD PPS** (PMIH0108).
* Real-time pack voltage, current, and wattage readouts.
* Configurable hardware **Battery Charge Limits** (55%, 60%, 80%, 85%, 100%) to preserve battery longevity.

### 3. Brightness & Night Light (`org.kde.plasma.brightness`)
* Screen backlight adjustment slider.
* Night Light color temperature controls (warm hue schedule).
* Dark Mode theme toggle.

### 4. Flashlight Widget (`org.erhai.plasma.torch`)
* Dedicated panel icon to toggle the rear camera LED torch via sysfs.

### 5. Input Method Switcher (`org.kde.plasma.manage-inputmethod`)
* System tray widget for fast switching or toggling the virtual keyboard.

### 6. Keyboard Custom Toggle (`org.kde.plasma.keyboard.custom.toggle`)
* One-click panel toggle to summon or dismiss `plasma-keyboard-custom`.

---

## 4. Tablet Management CLI (`erhai-ctl`)

The system ships with `/usr/local/bin/erhai-ctl`, a C/shell utility for inspecting and controlling tablet functions:

| Command | Arguments | Description |
| :--- | :--- | :--- |
| `erhai-ctl status` | — | Prints a human-readable overview of battery, thermal, display, and charging status |
| `erhai-ctl json` | — | Ultra-fast (~2ms) machine-readable JSON summary for scripts and plasmoids |
| `erhai-ctl thermal` | `[performance\|balanced\|cool\|cold]` | Read or set active thermal throttling profile |
| `erhai-ctl bypass` | `[on\|off\|toggle]` | Read or toggle battery bypass charging |
| `erhai-ctl torch` | `[0..100\|on\|off\|toggle]` | Read or adjust rear camera LED torch |
| `erhai-ctl display` | `[mirror\|extend\|internal]` | Rapid multi-monitor display layout via `kscreen-doctor` |
| `erhai-ctl vk` | `[toggle\|show\|hide\|status]` | Summon or hide the on-screen keyboard |
| `erhai-ctl tabletmode` | `[on\|off\|toggle\|status]` | Query or force KWin touch tablet mode |

---

## 5. Virtual Keyboard (`plasma-keyboard-custom`)

Located at `/usr/bin/plasma-keyboard-custom`:
* **Caps Lock Toggle**: Properly updates `shiftHandler.capsLockActive` across all QML layouts and binds to `latched: InputContext.capsLockActive` for active visual accent highlight.
* **Latching Modifiers**: Supports single-tap latching and locking for `Alt`, `Ctrl`, and `Meta` with visual indicators powered by the `Modifiers` singleton.
* **Global Shortcuts via uinput**: Rule `/etc/udev/rules.d/99-uinput.rules` grants group `input` read/write access to `/dev/uinput`, enabling key combinations like `Alt+Tab`, `Alt+F4`, and `Super+D` to be injected directly into KWin.
* **Dual Layouts**:
  * **Landscape**: 18-column TKL layout with dedicated arrows, function keys, and editing block.
  * **Portrait**: 13-column touch layout (`PlasmaBreezeCustom/style.qml`) featuring square keys and adaptive vertical padding.
* **Swipe Typing**: Embedded FUTO swipe prediction engine with combined dictionary data (`en.combined`, `ru.combined`).
* **Maliit Fallback**: Shipped patched `Keyboard_en.qml` layout for Maliit with working CapsLock latching.

---

## 6. Power Management & Display Blanking

* **PowerDevil Idle Timeouts**:
  * Display turns off after **5 minutes** on battery (**10 minutes** on AC).
  * System suspends (`s2idle`) after **10 minutes** on battery (**15 minutes** on AC).
  * Lock on suspend is enabled by default; screen dimming is disabled.
* **Suspend-to-Idle (`s2idle`)**:
  * Systemd configured via `/etc/systemd/sleep.conf.d/erhai-s2idle.conf` and `/etc/tmpfiles.d/erhai-mem-sleep.conf` to enforce hardware `s2idle` sleep.
* **Clean Screen Blanking (`erhai-panel-power.sh`)**:
  * `/usr/local/sbin/erhai-panel-power.sh` coordinates screen blanking and unblanking via `kscreen-doctor --dpms` and FreeDesktop ScreenSaver D-Bus interfaces without crashing compositor threads.
* **Pogo Keyboard OSK Gatekeeper (`erhai-pogo-osk.py`)**:
  * Runs as a systemd service (`erhai-pogo-osk.service`).
  * Automatically disables the virtual keyboard when the physical magnetic keyboard is attached and re-enables it when detached.

---

## 7. Audio & Camera Hardware Fixes

* **Stereo Speaker Array**: All 6 discrete AW88261 audio amplifiers tuned for full output range.
* **Volume Slider Freeze Fix (`51-erhai-sound-ucm.conf`)**:
  * In `/etc/wireplumber/wireplumber.conf.d/51-erhai-sound-ucm.conf`, the unclocked DisplayPort audio playback node (`alsa_output.platform-sound.playback.1.0`) is set to `node.disabled = true`.
  * Prevents WirePlumber from hanging when moving the KDE Plasma volume slider when no external DP monitor is attached.
* **Dual Camera V4L2 Loopback**:
  * `v4l2loopback` kernel module loaded automatically with 2 virtual video devices.
  * `v4l2-relayd` services bridge libcamera streams to standard V4L2 device nodes:
    * **Front Camera**: SmartSens `sc820cs` -> `/dev/video20` ("Tablet Front Camera")
    * **Rear Camera**: SmartSens `sc1300cs` / `sc1320cs` -> `/dev/video21` ("Tablet Back Camera")
  * Enables front and rear cameras in WebRTC apps, Discord, Chromium, and OBS.
  * Shipped libcamera Software ISP tuning profiles in `/usr/share/libcamera/ipa/simple/`.
* **Hardware Video Acceleration**:
  * Prioritizes Qualcomm Iris VA-API hardware decoders (AV1, HEVC, VP9, H.264) via `/usr/lib/environment.d/60-erhai-video.conf`.

---

## 8. Storage & System Tweaks

* **Android Partition Hiding (`80-udisks2-hide-android.rules`)**:
  * Marks all internal Android UFS partitions (`boot_a`, `vendor_a`, `system_a`, `userdata`, etc.) with `UDISKS_IGNORE=1`.
  * Keeps Dolphin, file dialogs, and desktop mounts clean by only exposing Linux volumes.
* **Hardware Telemetry Permissions (`erhai-debugfs.conf`)**:
  * Configures `/sys/kernel/debug` permissions to `0755` via tmpfiles, allowing desktop plasmoids and `erhai-ctl` to read battery current, charging rates, and SoC thermals without requiring `sudo`.
