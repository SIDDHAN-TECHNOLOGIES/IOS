//
//  DynamicIslandModel.swift
//  DynamicIsland-iPhone13
//
//  Created for iPhone 13, 13 Pro, and 13 Pro Max.
//

import SwiftUI

/// The display state of the Dynamic Island
public enum DynamicIslandState: Equatable {
    case hidden
    case compact
    case expanded
}

/// The attachment style relative to the physical iPhone 13 notch
public enum NotchAttachmentStyle {
    /// Seamlessly hugs and extends from the bottom of the iPhone 13 notch ("Peninsula" style)
    case attachedToNotch
    /// Floats just beneath the notch with rounded edges like the native island ("Floating" style)
    case floatingUnderNotch
}

/// Supported payload types for dynamic island experiences
public enum DynamicIslandContent: Equatable {
    case music(MusicData)
    case timer(TimerData)
    case call(CallData)
    case notification(NotificationData)
    case battery(BatteryData)
    
    public struct MusicData: Equatable {
        public var title: String
        public var artist: String
        public var systemArtwork: String
        public var isPlaying: Bool
        public var progress: Double // 0.0 ... 1.0
        public var accentColor: Color
        
        public init(
            title: String = "Starboy",
            artist: String = "The Weeknd",
            systemArtwork: String = "music.note",
            isPlaying: Bool = true,
            progress: Double = 0.42,
            accentColor: Color = .green
        ) {
            self.title = title
            self.artist = artist
            self.systemArtwork = systemArtwork
            self.isPlaying = isPlaying
            self.progress = progress
            self.accentColor = accentColor
        }
    }
    
    public struct TimerData: Equatable {
        public var title: String
        public var remainingSeconds: Int
        public var totalSeconds: Int
        public var isRunning: Bool
        
        public init(
            title: String = "Tea Timer",
            remainingSeconds: Int = 184,
            totalSeconds: Int = 300,
            isRunning: Bool = true
        ) {
            self.title = title
            self.remainingSeconds = remainingSeconds
            self.totalSeconds = totalSeconds
            self.isRunning = isRunning
        }
        
        public var formattedRemaining: String {
            let m = remainingSeconds / 60
            let s = remainingSeconds % 60
            return String(format: "%02d:%02d", m, s)
        }
    }
    
    public struct CallData: Equatable {
        public var callerName: String
        public var subtitle: String
        public var duration: String
        public var isMuted: Bool
        public var isSpeakerOn: Bool
        
        public init(
            callerName: String = "Sarah Connor",
            subtitle: String = "Mobile",
            duration: String = "03:42",
            isMuted: Bool = false,
            isSpeakerOn: Bool = false
        ) {
            self.callerName = callerName
            self.subtitle = subtitle
            self.duration = duration
            self.isMuted = isMuted
            self.isSpeakerOn = isSpeakerOn
        }
    }
    
    public struct NotificationData: Equatable {
        public var title: String
        public var message: String
        public var systemImage: String
        public var tintColor: Color
        
        public init(
            title: String = "AirPods Pro",
            message: String = "Connected • 98%",
            systemImage: String = "airpodspro",
            tintColor: Color = .white
        ) {
            self.title = title
            self.message = message
            self.systemImage = systemImage
            self.tintColor = tintColor
        }
    }
    
    public struct BatteryData: Equatable {
        public var percentage: Int
        public var isCharging: Bool
        
        public init(percentage: Int = 85, isCharging: Bool = true) {
            self.percentage = percentage
            self.isCharging = isCharging
        }
    }
}
