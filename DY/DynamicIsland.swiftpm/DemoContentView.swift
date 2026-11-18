//
//  DemoContentView.swift
//  DynamicIsland-iPhone13
//
//  Created for iPhone 13, 13 Pro, and 13 Pro Max.
//

import SwiftUI

/// Interactive Demo App demonstrating the Dynamic Island component on iPhone 13, 13 Pro, and 13 Pro Max
public struct DemoContentView: View {
    @StateObject private var islandManager = DynamicIslandManager.shared
    
    // Demo Controls
    @State private var showPhysicalNotchSimulation: Bool = true
    @State private var selectedDeviceIndex: Int = 0
    
    let devices = [
        ("iPhone 13 / 13 Pro", 390.0, 844.0),
        ("iPhone 13 Pro Max", 428.0, 926.0)
    ]
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .top) {
            // Background wallpaper
            LinearGradient(
                colors: [Color(red: 0.10, green: 0.12, blue: 0.22), Color(red: 0.05, green: 0.06, blue: 0.12)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Scrollable Content
            ScrollView {
                VStack(spacing: 24) {
                    // Header spacing for top notch area
                    Spacer().frame(height: 100)
                    
                    headerSection
                    
                    deviceAndStyleSection
                    
                    triggerButtonsSection
                    
                    stateControlSection
                    
                    Spacer().frame(height: 50)
                }
                .padding(.horizontal, 20)
            }
            
            // Physical iPhone 13 Notch Simulation (helps visualize real screen on Mac / Simulator)
            if showPhysicalNotchSimulation {
                PhysicalNotchOverlay()
                    .allowsHitTesting(false)
            }
            
            // Dynamic Island Overlay
            DynamicIslandView(manager: islandManager)
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Dynamic Island")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Tailored for iPhone 13 • 13 Pro • 13 Pro Max")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
        }
    }
    
    private var deviceAndStyleSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("NOTCH ADAPTATION")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
                .tracking(1.0)
            
            VStack(spacing: 12) {
                // Style Picker
                HStack {
                    Text("Island Position:")
                        .foregroundColor(.white)
                        .font(.system(size: 14))
                    Spacer()
                    Picker("Attachment", selection: $islandManager.attachmentStyle) {
                        Text("Hugs Notch").tag(NotchAttachmentStyle.attachedToNotch)
                        Text("Floats Under").tag(NotchAttachmentStyle.floatingUnderNotch)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 190)
                }
                
                Divider().background(Color.white.opacity(0.1))
                
                // Toggle Notch Preview Overlay
                Toggle(isOn: $showPhysicalNotchSimulation) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Show iPhone 13 Notch Outline")
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                        Text("Renders the exact 161pt notch for previewing")
                            .foregroundColor(.gray)
                            .font(.system(size: 11))
                    }
                }
                .tint(.blue)
            }
            .padding(16)
            .background(Color.white.opacity(0.06))
            .cornerRadius(16)
        }
    }
    
    private var triggerButtonsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("TEST EXPERIENCES")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
                .tracking(1.0)
            
            VStack(spacing: 10) {
                // Music Trigger
                triggerRow(
                    icon: "music.note",
                    color: .green,
                    title: "Now Playing (Music)",
                    subtitle: "Waveforms, controls & scrubber"
                ) {
                    islandManager.show(.music(
                        DynamicIslandContent.MusicData(
                            title: "Blinding Lights",
                            artist: "The Weeknd",
                            systemArtwork: "music.note.list",
                            isPlaying: true,
                            progress: 0.55,
                            accentColor: .green
                        )
                    ))
                }
                
                // Timer Trigger
                triggerRow(
                    icon: "timer",
                    color: .orange,
                    title: "Active Timer",
                    subtitle: "Countdown ring with pause/cancel"
                ) {
                    islandManager.show(.timer(
                        DynamicIslandContent.TimerData(
                            title: "Espresso Shot",
                            remainingSeconds: 28,
                            totalSeconds: 35,
                            isRunning: true
                        )
                    ))
                }
                
                // Phone Call Trigger
                triggerRow(
                    icon: "phone.fill",
                    color: .green,
                    title: "Phone Call",
                    subtitle: "Mute, speaker & end call controls"
                ) {
                    islandManager.show(.call(
                        DynamicIslandContent.CallData(
                            callerName: "Tony Stark",
                            subtitle: "Avengers HQ",
                            duration: "02:14"
                        )
                    ))
                }
                
                // AirPods Trigger
                triggerRow(
                    icon: "airpodspro",
                    color: .cyan,
                    title: "AirPods Connected",
                    subtitle: "Auto-dismisses in 3 seconds"
                ) {
                    islandManager.show(
                        .notification(
                            DynamicIslandContent.NotificationData(
                                title: "AirPods Pro",
                                message: "Connected • 94%",
                                systemImage: "airpodspro",
                                tintColor: .cyan
                            )
                        ),
                        autoDismissAfter: 3.5
                    )
                }
                
                // Battery Charging Trigger
                triggerRow(
                    icon: "bolt.fill",
                    color: .yellow,
                    title: "MagSafe Charging",
                    subtitle: "Charging status animation"
                ) {
                    islandManager.show(
                        .battery(
                            DynamicIslandContent.BatteryData(
                                percentage: 88,
                                isCharging: true
                            )
                        ),
                        autoDismissAfter: 3.0
                    )
                }
            }
        }
    }
    
    private var stateControlSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("MANUAL CONTROLS")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
                .tracking(1.0)
            
            HStack(spacing: 12) {
                Button(action: {
                    islandManager.expand()
                }) {
                    Label("Expand", systemImage: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    islandManager.collapse()
                }) {
                    Label("Compact", systemImage: "arrow.down.right.and.arrow.up.left")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(12)
                }
                
                Button(action: {
                    islandManager.dismiss()
                }) {
                    Label("Dismiss", systemImage: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(12)
                }
            }
        }
    }
    
    private func triggerRow(icon: String, color: Color, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.gray.opacity(0.6))
            }
            .padding(12)
            .background(Color.white.opacity(0.06))
            .cornerRadius(14)
        }
    }
}

// MARK: - iPhone 13 Physical Notch Simulation
public struct PhysicalNotchOverlay: View {
    public init() {}
    
    public var body: some View {
        GeometryReader { _ in
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    // iPhone 13 Notch: 161 pt wide x 34 pt deep, with rounded bottom corners
                    ZStack(alignment: .bottom) {
                        iPhone13NotchShape()
                            .fill(Color.black)
                            .frame(width: NotchGeometry.standardNotchWidth, height: NotchGeometry.standardNotchHeight)
                        
                        // Speaker ear-piece grille simulation
                        Capsule()
                            .fill(Color(white: 0.2))
                            .frame(width: 46, height: 3.5)
                            .padding(.bottom, 22)
                        
                        // Front camera lens simulation
                        Circle()
                            .fill(Color(white: 0.15))
                            .frame(width: 10, height: 10)
                            .padding(.leading, 70)
                            .padding(.bottom, 12)
                    }
                    Spacer()
                }
                Spacer()
            }
            .edgesIgnoringSafeArea(.top)
        }
    }
}

/// Custom shape matching the iPhone 13 / 13 Pro notch contour
public struct iPhone13NotchShape: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let cornerRadius: CGFloat = 16
        
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: rect.height - cornerRadius))
        path.addQuadCurve(
            to: CGPoint(x: cornerRadius, y: rect.height),
            control: CGPoint(x: 0, y: rect.height)
        )
        path.addLine(to: CGPoint(x: rect.width - cornerRadius, y: rect.height))
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: rect.height - cornerRadius),
            control: CGPoint(x: rect.width, y: rect.height)
        )
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.closeSubpath()
        return path
    }
}

// MARK: - View Modifier for Easy Integration in Any App
public struct DynamicIslandModifier: ViewModifier {
    @ObservedObject var manager: DynamicIslandManager
    
    public func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            DynamicIslandView(manager: manager)
        }
    }
}

public extension View {
    /// Embeds the Dynamic Island at the top of any view
    func withDynamicIsland(manager: DynamicIslandManager = .shared) -> some View {
        self.modifier(DynamicIslandModifier(manager: manager))
    }
}
