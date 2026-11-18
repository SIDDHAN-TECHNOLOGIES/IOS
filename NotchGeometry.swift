//
//  NotchGeometry.swift
//  DynamicIsland-iPhone13
//
//  Created for iPhone 13, 13 Pro, and 13 Pro Max.
//

import SwiftUI

/// Device and notch geometry metrics specifically calibrated for the iPhone 13 lineup.
public struct NotchGeometry {
    
    /// iPhone 13 lineup display specifications:
    /// - iPhone 13 / 13 Pro: 390 x 844 points (notch width: ~161 pt, depth: ~34 pt)
    /// - iPhone 13 Pro Max: 428 x 926 points (notch width: ~161 pt, depth: ~34 pt)
    /// - iPhone 13 mini: 375 x 812 points (notch width: ~154 pt, depth: ~34 pt)
    public static let standardNotchWidth: CGFloat = 161.0
    public static let standardNotchHeight: CGFloat = 34.0
    public static let standardNotchCornerRadius: CGFloat = 18.0
    
    /// Top safe area inset for iPhone 13 / 13 Pro / 13 Pro Max (typically 47 pt)
    public static let topSafeArea: CGFloat = 47.0
    
    /// Returns the recommended compact Dynamic Island width for the current screen width.
    public static func compactWidth(for screenWidth: CGFloat) -> CGFloat {
        // Fits right below or framing the 161pt notch nicely
        return min(screenWidth - 32, 220)
    }
    
    /// Returns the recommended expanded Dynamic Island width for the current screen width.
    public static func expandedWidth(for screenWidth: CGFloat) -> CGFloat {
        return screenWidth - 32
    }
}
