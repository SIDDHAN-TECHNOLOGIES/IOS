# Dynamic Island for iPhone 13, 13 Pro & 13 Pro Max

A SwiftUI component that brings Apple's Dynamic Island experience to the **iPhone 13, iPhone 13 Pro, and iPhone 13 Pro Max**.

---

## 📱 Hardware & Geometry Calibration

The iPhone 13 series has a 20% narrower physical notch compared to earlier iPhones:
- **Notch Width**: `161 pt`
- **Notch Depth**: `34 pt`
- **Top Safe Area**: `47 pt`
- **Screen Sizes**:
  - iPhone 13 & 13 Pro: `390 x 844 pt`
  - iPhone 13 Pro Max: `428 x 926 pt`

This component is calibrated to align with these dimensions using two distinct attachment modes:

| Mode | Visual Behavior | Best Used For |
|---|---|---|
| **Attached ("Peninsula")** | Seamlessly connects with the bottom contour of the physical notch. Looks built into the bezel. | Immersive in-app music, calls, and continuous monitoring. |
| **Floating** | Floats as a classic black pill centered directly beneath the notch line. | System-style alerts, transient notifications, and timers. |

---

## 🚀 Features

- **Fluid Spring Animations**: Realistic `.spring(response:dampingFraction:)` physics mimicking iOS Dynamic Island morphing.
- **Interactive Gestures**:
  - **Tap**: Toggle between compact pill and expanded card.
  - **Swipe Down**: Expand into full interactive view.
  - **Swipe Up**: Collapse or dismiss back into the notch.
- **Built-in Experiences**:
  - 🎵 **Music Player**: Animated audio visualizer bars, title, artist, scrubber progress, and playback controls.
  - ⏱️ **Timer**: Countdown timer with circular progress ring and pause/resume/cancel buttons.
  - 📞 **Phone Call**: Contact info, call duration, mute, speaker, and end-call actions.
  - 🎧 **Alerts / Notifications**: AirPods connection banner with auto-dismissal.
  - ⚡ **Charging / Battery**: Battery status and charging glyph.
- **Physical Notch Simulation**: Includes an optional overlay rendering the exact iPhone 13 notch shape to test directly in Xcode Simulator or Canvas on Mac.

---

## 🛠️ Quick Integration

### 1. Attach to your Root View
In your root SwiftUI view (e.g., `ContentView` or `WindowGroup`), add the `.withDynamicIsland()` modifier:

```swift
import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .withDynamicIsland() // <--- Adds Dynamic Island to the top
        }
    }
}
```

### 2. Trigger from Anywhere in Your App

#### 🎵 Music Player
```swift
DynamicIslandManager.shared.show(.music(
    DynamicIslandContent.MusicData(
        title: "Blinding Lights",
        artist: "The Weeknd",
        systemArtwork: "music.note",
        isPlaying: true,
        progress: 0.65,
        accentColor: .green
    )
))
```

#### ⏱️ Active Countdown Timer
```swift
DynamicIslandManager.shared.show(.timer(
    DynamicIslandContent.TimerData(
        title: "Brewing Coffee",
        remainingSeconds: 45,
        totalSeconds: 60,
        isRunning: true
    )
))
```

#### 📞 Phone Call
```swift
DynamicIslandManager.shared.show(.call(
    DynamicIslandContent.CallData(
        callerName: "Tony Stark",
        subtitle: "Mobile",
        duration: "01:24"
    )
))
```

#### 🎧 Transient Notification (Auto-Dismiss)
```swift
DynamicIslandManager.shared.show(
    .notification(
        DynamicIslandContent.NotificationData(
            title: "AirPods Pro",
            message: "Connected • 95%",
            systemImage: "airpodspro",
            tintColor: .cyan
        )
    ),
    autoDismissAfter: 3.0 // Auto-dismisses after 3 seconds
)
```

---

## ⚙️ Customization

### Switch Attachment Mode
```swift
// Hugs the physical notch:
DynamicIslandManager.shared.attachmentStyle = .attachedToNotch

// Floats just beneath the notch:
DynamicIslandManager.shared.attachmentStyle = .floatingUnderNotch
```

### Programmatic State Control
```swift
DynamicIslandManager.shared.expand()   // Expands island
DynamicIslandManager.shared.collapse() // Collapses to compact
DynamicIslandManager.shared.dismiss()  // Slides back into notch
```

---

## 📂 Project Structure

```
d:\Love Boi\MY\DY/
├── NotchGeometry.swift        # Calibrated dimensions for iPhone 13, 13 Pro & 13 Pro Max
├── DynamicIslandModel.swift       # State, attachment modes & content payloads
├── DynamicIslandManager.swift     # Observable manager for posting & controlling states
├── DynamicIslandView.swift        # Core animated SwiftUI component with spring transitions
├── DemoContentView.swift          # Complete interactive preview & notch simulation
├── DynamicIslandApp.swift         # Runnable SwiftUI App entry point
└── Package.swift                  # Swift Package Manager manifest
```

---

## 💡 Notes for iPhone 13 Hardware
- **Physical Notch vs Dynamic Island Cutout**: The iPhone 13 series has a top-bezel notch rather than the floating pill cutout found on iPhone 14 Pro/15/16. In iOS system SpringBoard, Apple restricts native Dynamic Island APIs (`ActivityKit`) to hardware pill devices.
- This component adapts the UI within your app so users on iPhone 13, 13 Pro, and 13 Pro Max get the full fluid Dynamic Island experience without needing jailbreaks or system tweaks.
