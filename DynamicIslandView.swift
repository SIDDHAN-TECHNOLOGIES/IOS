//
//  DynamicIslandView.swift
//  DynamicIsland-iPhone13
//
//  Created for iPhone 13, 13 Pro, and 13 Pro Max.
//

import SwiftUI

/// Main Dynamic Island View adapted for iPhone 13, 13 Pro, and 13 Pro Max
public struct DynamicIslandView: View {
    @ObservedObject var manager: DynamicIslandManager = .shared
    
    // Geometry & Layout
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @State private var dragOffset: CGSize = .zero
    
    public init(manager: DynamicIslandManager = .shared) {
        self.manager = manager
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let topInset = geometry.safeAreaInsets.top > 0 ? geometry.safeAreaInsets.top : NotchGeometry.topSafeArea
            
            ZStack(alignment: .top) {
                if manager.state != .hidden, let content = manager.content {
                    islandCapsule(content: content, screenWidth: screenWidth, topInset: topInset)
                        .offset(y: dragOffset.height > 0 ? dragOffset.height * 0.4 : dragOffset.height)
                        .gesture(
                            DragGesture(minimumDistance: 10)
                                .onChanged { value in
                                    dragOffset = value.translation
                                }
                                .onEnded { value in
                                    let verticalTranslation = value.translation.height
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                        dragOffset = .zero
                                    }
                                    
                                    if manager.state == .compact {
                                        if verticalTranslation > 30 {
                                            manager.expand()
                                        } else if verticalTranslation < -20 {
                                            manager.dismiss()
                                        }
                                    } else if manager.state == .expanded {
                                        if verticalTranslation < -30 {
                                            manager.collapse()
                                        }
                                    }
                                }
                        )
                        .onTapGesture {
                            manager.toggleExpand()
                        }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    // MARK: - Capsule Container
    @ViewBuilder
    private func islandCapsule(content: DynamicIslandContent, screenWidth: CGFloat, topInset: CGFloat) -> some View {
        let isExpanded = manager.state == .expanded
        let isAttached = manager.attachmentStyle == .attachedToNotch
        
        let targetWidth: CGFloat = isExpanded ?
            NotchGeometry.expandedWidth(for: screenWidth) :
            NotchGeometry.compactWidth(for: screenWidth)
        
        let targetHeight: CGFloat = isExpanded ? expandedHeight(for: content) : 40.0
        let cornerRadius: CGFloat = isExpanded ? 36.0 : 20.0
        
        // Positioning:
        // iPhone 13 notch ends around Y = 34-36 pt. Safe area is 47 pt.
        // Attached style anchors from Y = 0 (or safe area top) hugging the physical notch.
        // Floating style rests at Y = 44-48 pt with a gap.
        let topPadding: CGFloat = isAttached ? (isExpanded ? topInset - 10 : 8) : (topInset + 4)
        
        VStack(spacing: 0) {
            if isExpanded {
                expandedContentView(content: content)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            } else {
                compactContentView(content: content)
                    .transition(.opacity)
            }
        }
        .padding(.horizontal, isExpanded ? 20 : 14)
        .padding(.vertical, isExpanded ? 18 : 6)
        .frame(width: targetWidth, height: targetHeight)
        .background(
            ZStack {
                Color.black
                // Subtle edge glow for visual depth
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 0.8)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .shadow(color: Color.black.opacity(0.45), radius: isExpanded ? 25 : 10, x: 0, y: isExpanded ? 14 : 6)
        .padding(.top, topPadding)
        .animation(.spring(response: 0.44, dampingFraction: 0.74), value: manager.state)
        .animation(.spring(response: 0.44, dampingFraction: 0.74), value: manager.attachmentStyle)
    }
    
    // MARK: - Dynamic Heights for Content
    private func expandedHeight(for content: DynamicIslandContent) -> CGFloat {
        switch content {
        case .music:
            return 190.0
        case .call:
            return 180.0
        case .timer:
            return 170.0
        case .notification:
            return 90.0
        case .battery:
            return 85.0
        }
    }
    
    // MARK: - Compact Content View
    @ViewBuilder
    private func compactContentView(content: DynamicIslandContent) -> some View {
        HStack(spacing: 8) {
            // Leading side of compact island
            switch content {
            case .music(let music):
                HStack(spacing: 6) {
                    Image(systemName: music.systemArtwork)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(music.accentColor)
                    
                    Text(music.title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: 80, alignment: .leading)
                }
                
            case .timer(let timer):
                HStack(spacing: 5) {
                    Image(systemName: "timer")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.orange)
                    Text(timer.formattedRemaining)
                        .font(.system(size: 13, weight: .medium, design: .monospaced))
                        .foregroundColor(.white)
                }
                
            case .call(let call):
                HStack(spacing: 5) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.green)
                    Text(call.callerName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .frame(maxWidth: 80, alignment: .leading)
                }
                
            case .notification(let notif):
                HStack(spacing: 6) {
                    Image(systemName: notif.systemImage)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(notif.tintColor)
                    Text(notif.title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                }
                
            case .battery(let batt):
                HStack(spacing: 6) {
                    Image(systemName: batt.isCharging ? "bolt.fill" : "battery.75")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(batt.isCharging ? .green : .white)
                    Text("\(batt.percentage)%")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            
            Spacer(minLength: 4)
            
            // Trailing side of compact island
            switch content {
            case .music(let music):
                SoundVisualizerCompact(isPlaying: music.isPlaying, accentColor: music.accentColor)
                
            case .timer(let timer):
                Circle()
                    .trim(from: 0, to: CGFloat(timer.remainingSeconds) / CGFloat(max(1, timer.totalSeconds)))
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    .frame(width: 14, height: 14)
                    .rotationEffect(.degrees(-90))
                
            case .call(let call):
                Text(call.duration)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.green)
                
            case .notification:
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                
            case .battery(let batt):
                Image(systemName: batt.isCharging ? "battery.100.bolt" : "battery.100")
                    .font(.system(size: 14))
                    .foregroundColor(batt.isCharging ? .green : .white)
            }
        }
    }
    
    // MARK: - Expanded Content View
    @ViewBuilder
    private func expandedContentView(content: DynamicIslandContent) -> some View {
        switch content {
        case .music(var music):
            MusicExpandedView(music: Binding(
                get: { music },
                set: { updated in
                    music = updated
                    manager.content = .music(updated)
                }
            ))
            
        case .timer(var timer):
            TimerExpandedView(timer: Binding(
                get: { timer },
                set: { updated in
                    timer = updated
                    manager.content = .timer(updated)
                }
            ))
            
        case .call(var call):
            CallExpandedView(call: Binding(
                get: { call },
                set: { updated in
                    call = updated
                    manager.content = .call(updated)
                }
            ))
            
        case .notification(let notif):
            NotificationExpandedView(notification: notif)
            
        case .battery(let batt):
            BatteryExpandedView(battery: batt)
        }
    }
}

// MARK: - Sound Waveform Visualizer
struct SoundVisualizerCompact: View {
    var isPlaying: Bool
    var accentColor: Color = .green
    
    @State private var phase: Double = 0.0
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<4) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(accentColor)
                    .frame(width: 2.5, height: barHeight(for: index))
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                phase = 1.0
            }
        }
    }
    
    private func barHeight(for index: Int) -> CGFloat {
        guard isPlaying else { return 4.0 }
        let heights: [[CGFloat]] = [
            [6, 14, 10, 8],
            [12, 6, 16, 10],
            [8, 12, 6, 14],
            [14, 8, 12, 6]
        ]
        let current = heights[index % 4]
        return CGFloat(phase > 0.5 ? current[1] : current[3])
    }
}

// MARK: - Music Expanded Subview
struct MusicExpandedView: View {
    @Binding var music: DynamicIslandContent.MusicData
    
    var body: some View {
        VStack(spacing: 14) {
            // Top Row: Album Cover + Song Details + Waveform
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(music.accentColor.opacity(0.3))
                        .frame(width: 48, height: 48)
                    Image(systemName: music.systemArtwork)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(music.accentColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(music.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Text(music.artist)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                
                Spacer()
                
                SoundVisualizerCompact(isPlaying: music.isPlaying, accentColor: music.accentColor)
                    .scaleEffect(1.3)
                    .padding(.trailing, 6)
            }
            
            // Middle: Progress Slider
            VStack(spacing: 4) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.18))
                            .frame(height: 5)
                        Capsule()
                            .fill(Color.white)
                            .frame(width: geo.size.width * CGFloat(music.progress), height: 5)
                    }
                }
                .frame(height: 5)
                
                HStack {
                    Text("1:24")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(.gray)
                    Spacer()
                    Text("-2:08")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(.gray)
                }
            }
            
            // Bottom Row: Media Controls
            HStack(spacing: 36) {
                Button(action: {
                    DynamicIslandManager.shared.triggerHaptic(.light)
                }) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                
                Button(action: {
                    music.isPlaying.toggle()
                    DynamicIslandManager.shared.triggerHaptic(.medium)
                }) {
                    Image(systemName: music.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 26))
                        .foregroundColor(.white)
                        .frame(width: 38, height: 38)
                }
                
                Button(action: {
                    DynamicIslandManager.shared.triggerHaptic(.light)
                }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Timer Expanded Subview
struct TimerExpandedView: View {
    @Binding var timer: DynamicIslandContent.TimerData
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(timer.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.orange)
                    Text(timer.formattedRemaining)
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.15), lineWidth: 5)
                        .frame(width: 52, height: 52)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(timer.remainingSeconds) / CGFloat(max(1, timer.totalSeconds)))
                        .stroke(Color.orange, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .frame(width: 52, height: 52)
                        .rotationEffect(.degrees(-90))
                    
                    Image(systemName: timer.isRunning ? "timer" : "pause.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.orange)
                }
            }
            
            HStack(spacing: 16) {
                Button(action: {
                    DynamicIslandManager.shared.dismiss()
                }) {
                    Text("Cancel")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(Color.white.opacity(0.18))
                        .cornerRadius(19)
                }
                
                Button(action: {
                    timer.isRunning.toggle()
                    DynamicIslandManager.shared.triggerHaptic(.medium)
                }) {
                    Text(timer.isRunning ? "Pause" : "Resume")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(Color.orange)
                        .cornerRadius(19)
                }
            }
        }
    }
}

// MARK: - Call Expanded Subview
struct CallExpandedView: View {
    @Binding var call: DynamicIslandContent.CallData
    
    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.35))
                        .frame(width: 44, height: 44)
                    Image(systemName: "person.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(call.callerName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Text("\(call.subtitle) • \(call.duration)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Circle()
                    .fill(Color.green)
                    .frame(width: 10, height: 10)
            }
            
            HStack(spacing: 24) {
                Button(action: {
                    call.isMuted.toggle()
                    DynamicIslandManager.shared.triggerHaptic(.light)
                }) {
                    Image(systemName: call.isMuted ? "mic.slash.fill" : "mic.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .frame(width: 46, height: 46)
                        .background(call.isMuted ? Color.white.opacity(0.4) : Color.white.opacity(0.18))
                        .clipShape(Circle())
                }
                
                Button(action: {
                    call.isSpeakerOn.toggle()
                    DynamicIslandManager.shared.triggerHaptic(.light)
                }) {
                    Image(systemName: call.isSpeakerOn ? "speaker.wave.3.fill" : "speaker.wave.1.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .frame(width: 46, height: 46)
                        .background(call.isSpeakerOn ? Color.white.opacity(0.4) : Color.white.opacity(0.18))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Button(action: {
                    DynamicIslandManager.shared.dismiss()
                }) {
                    Image(systemName: "phone.down.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 48, height: 48)
                        .background(Color.red)
                        .clipShape(Circle())
                }
            }
        }
    }
}

// MARK: - Notification Expanded Subview
struct NotificationExpandedView: View {
    var notification: DynamicIslandContent.NotificationData
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: notification.systemImage)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(notification.tintColor)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(notification.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Text(notification.message)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 18))
        }
    }
}

// MARK: - Battery Expanded Subview
struct BatteryExpandedView: View {
    var battery: DynamicIslandContent.BatteryData
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: battery.isCharging ? "bolt.circle.fill" : "battery.100")
                .font(.system(size: 26, weight: .semibold))
                .foregroundColor(battery.isCharging ? .green : .white)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(battery.isCharging ? "Charging" : "Battery Level")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Text("\(battery.percentage)% charged")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            ProgressView(value: Double(battery.percentage), total: 100.0)
                .progressViewStyle(LinearProgressViewStyle(tint: battery.isCharging ? .green : .white))
                .frame(width: 80)
        }
    }
}

// MARK: - Safe Area Helper Key
private struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
        EdgeInsets(top: NotchGeometry.topSafeArea, leading: 0, bottom: 0, trailing: 0)
    }
}

extension EnvironmentValues {
    var safeAreaInsets: EdgeInsets {
        get { self[SafeAreaInsetsKey.self] }
        set { self[SafeAreaInsetsKey.self] = newValue }
    }
}
