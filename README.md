# LibWally Swift (Kodelab Fork)

LibWally is a portable C library for Bitcoin-related operations, maintained by Blockstream. It provides low-level functionality for working with keys, addresses, transactions, PSBTs, scripts, and more — forming the foundation for secure wallet software.

This repository contains the source for **LibWally-Swift**, a Swift wrapper that exposes core `libwally-core` functionality to Swift-based applications.

## This Fork

This fork is maintained by **Kodelab** to support the ATM Connect iOS app ([view repo](https://github.com/kodelabio/atm-connect-ios)). It includes custom changes tailored to our needs.

We vendor the full source of `libwally-core` and manually manage framework builds. **Xcode should not be used to build `libwally-core` directly** - unlike how the upstream does it — we instead generate a prebuilt `.xcframework` via shell scripts and include that in the app manually.

---

## Build & Install 

These instructions are for development and integration into `atm-connect-ios`.

### 1. Install Dependencies

```sh
brew install gnu-sed automake libtool
```

### 2. Clone the Repo

```
git clone https://github.com/kodelabio/kodelab-libwally-swift.git --recurse-submodules
cd kodelab-libwally-swift
```

### 3. Build the Framework

Use chmod to make the build script executable, and then run it:

```
chmod +x build-libwally-swift.sh
./build-libwally-swift.sh
```

This will output an `xcframework` bundle to:

```
build/LibWally.xcframework
```

### 4. Add to Xcode Project

In the `atm-connect-ios` Xcode project:

- Locate the `Frameworks` group in the project navigator (note: this is a logical group, not a real folder on disk).
- Delete the existing `LibWally.xcframework` from the `Frameworks` group.
- Drag the new `LibWally.xcframework` from the `build/` folder into the `Frameworks` group in Xcode.

### 5. Final Setup

For each target that needs access to `LibWally`:

- Select the project in the navigator, then select the target directly
- Go to the **"General"** tab
- Scroll to **"Frameworks, Libraries, and Embedded Content"**
- Ensure `LibWally.xcframework` is listed and set to **Embed & Sign**


---

## Notes

Complete this full process each time there are changes to LibWally. 
Do not rely on xcode to build for you.

---

## Upstream Sync

We maintain a `vendor` branch to track upstream changes from [`libwally-core`](https://github.com/Sjors/libwally-swift). Our `main` and `dev` branches contain internal Kodelab modifications and Swift integration logic.

Use Git tags to mark upstream syncs. For now, `vendor-upstream-v0.0.9` is the initial base version. 

Internal tags look normal, eg: `1.0.0`, `v1.0.0`, etc.

---
