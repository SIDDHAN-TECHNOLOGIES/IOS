//
//  DynamicIslandManager.swift
//  DynamicIsland-iPhone13
//
//  Created for iPhone 13, 13 Pro, and 13 Pro Max.
//

import SwiftUI
import Combine

/// Global manager to post and control Dynamic Island experiences from any view
public final class DynamicIslandManager: ObservableObject {
    public static let shared = DynamicIslandManager()
    
    @Published public var state: DynamicIslandState = .hidden
    @Published public var content: DynamicIslandContent? = nil
    @Published public var attachmentStyle: NotchAttachmentStyle = .attachedToNotch
    
    private var dismissCancellable: AnyCancellable?
    
    public init() {}
    
    // MARK: - API Methods
    
    /// Present a new content card into the Dynamic Island
    public func show(_ content: DynamicIslandContent, style: NotchAttachmentStyle? = nil, autoDismissAfter seconds: TimeInterval? = nil) {
        if let style = style {
            self.attachmentStyle = style
        }
        
        dismissCancellable?.cancel()
        dismissCancellable = nil
        
        withAnimation(.spring(response: 0.42, dampingFraction: 0.72)) {
            self.content = content
            self.state = .compact
        }
        triggerHaptic(.light)
        
        if let seconds = seconds {
            dismissCancellable = Just(())
                .delay(for: .seconds(seconds), scheduler: RunLoop.main)
                .sink { [weak self] _ in
                    self?.dismiss()
                }
        }
    }
    
    /// Expands the Dynamic Island into full interactive mode
    public func expand() {
        guard state != .hidden, content != nil else { return }
        withAnimation(.spring(response: 0.45, dampingFraction: 0.76)) {
            self.state = .expanded
        }
        triggerHaptic(.medium)
    }
    
    /// Collapses the Dynamic Island back into compact pill / notch bar
    public func collapse() {
        guard state != .hidden else { return }
        withAnimation(.spring(response: 0.42, dampingFraction: 0.74)) {
            self.state = .compact
        }
        triggerHaptic(.light)
    }
    
    /// Toggles between compact and expanded states
    public func toggleExpand() {
        if state == .expanded {
            collapse()
        } else if state == .compact {
            expand()
        }
    }
    
    /// Completely dismisses the Dynamic Island back into the notch
    public func dismiss() {
        dismissCancellable?.cancel()
        dismissCancellable = nil
        
        withAnimation(.spring(response: 0.38, dampingFraction: 0.8)) {
            self.state = .hidden
        }
        triggerHaptic(.rigid)
        
        // Clear content slightly after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            if self.state == .hidden {
                self.content = nil
            }
        }
    }
    
    // MARK: - Haptic Feedback
    public func triggerHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
        #endif
    }
}
