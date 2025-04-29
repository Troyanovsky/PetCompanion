//
//  MovementManager.swift
//  PetCompanion
//
//  Created by Guodong Zhao on 4/28/25.
//

import AppKit

class MovementManager {
    private let configManager = ConfigurationManager.shared
    var currentPosition: CGPoint = .zero
    var direction: Direction = .right
    var isDragging: Bool = false // To override movement logic while dragging

    private var screenRect: CGRect = .zero
    private var speed: CGFloat = 0 // Pixels per second
    private var spriteSize: CGSize = CGSize(width: 64, height: 64)

    init() {
        updateScreenRect()
        spriteSize = configManager.getSpriteSize() ?? CGSize(width: 64, height: 64)
        // Initial position at bottom center (or random)
        currentPosition = CGPoint(x: screenRect.midX - (spriteSize.width / 2), y: screenRect.minY)
    }

    func updateScreenRect() {
        // Use the main screen's visible frame (accounts for Dock and Menu Bar)
        screenRect = NSScreen.main?.visibleFrame ?? .zero
        Logger.debug("Screen Rect Updated: \(screenRect)")
    }

    // Called periodically by PetController's update loop
    func update(deltaTime: TimeInterval, state: PetState) {
        guard !isDragging else { return } // Don't move automatically while dragging

        guard let stateConfig = configManager.getStateConfig(for: state),
              stateConfig.isMovement, // Only move if the state is designated as movement
              let stateSpeed = stateConfig.speed else {
            // Not a movement state or speed not defined, do nothing
            return
        }

        speed = CGFloat(stateSpeed)
        let distance = speed * CGFloat(deltaTime)

        // Calculate next position
        var nextX = currentPosition.x + (direction == .right ? distance : -distance)
        let nextY = screenRect.minY // Keep pet at the bottom

        // Boundary Check
        let rightBoundary = screenRect.maxX - spriteSize.width
        let leftBoundary = screenRect.minX

        if nextX >= rightBoundary {
            nextX = rightBoundary
            direction = .left // Flip direction
            Logger.debug("Hit Right Edge - Flipping Left")
        } else if nextX <= leftBoundary {
            nextX = leftBoundary
            direction = .right // Flip direction
            Logger.debug("Hit Left Edge - Flipping Right")
        }

        currentPosition = CGPoint(x: nextX, y: nextY)
    }

    // Called when mouse drag starts
    func startDrag() {
        isDragging = true
    }

    // Called while mouse is dragged
    func drag(to point: CGPoint, delta: CGSize) {
         guard isDragging else { return }
        // Update position based on mouse delta, not absolute position
        // This feels more natural than jumping to the cursor
        currentPosition = CGPoint(x: currentPosition.x + delta.width,
                                  y: currentPosition.y + delta.height)

         // Optional: Keep within screen bounds during drag, or allow dragging off-screen
         currentPosition.x = max(screenRect.minX, min(currentPosition.x, screenRect.maxX - spriteSize.width))
         currentPosition.y = max(screenRect.minY, min(currentPosition.y, screenRect.maxY - spriteSize.height))
    }

    // Called when mouse drag ends
    func endDrag() {
        isDragging = false
        dropToBottom()
    }

    // Snaps the pet to the bottom of the screen
    func dropToBottom() {
        updateScreenRect() // Ensure screen rect is current
        currentPosition.y = screenRect.minY
        // Keep within horizontal bounds as well
        currentPosition.x = max(screenRect.minX, min(currentPosition.x, screenRect.maxX - spriteSize.width))

        Logger.debug("Dropped to bottom: \(currentPosition)")
    }

    func setInitialPosition() {
        updateScreenRect()
        currentPosition = CGPoint(x: screenRect.midX - (spriteSize.width / 2), y: screenRect.minY)
    }
}
