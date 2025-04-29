//
//  PetWindow.swift
//  PetCompanion
//
//  Created by Guodong Zhao on 4/28/25.
//

import AppKit

class PetWindow: NSWindow {

    var petView: PetView!
    var dragStartLocation: NSPoint? // Track initial mouse down location
    var initialWindowOrigin: NSPoint? // Track window origin at drag start

    // Delegate to handle mouse events in PetController
    weak var dragDelegate: PetWindowDragDelegate?

    init(spriteSize: CGSize) {
        // Calculate initial position (e.g., bottom center)
        let screenRect = NSScreen.main?.visibleFrame ?? .zero
        let initialOrigin = CGPoint(x: screenRect.midX - (spriteSize.width / 2),
                                    y: screenRect.minY) // Place at bottom
        let contentRect = NSRect(origin: initialOrigin, size: spriteSize)

        super.init(contentRect: contentRect,
                   styleMask: .borderless, // No title bar, border, etc.
                   backing: .buffered,
                   defer: false)

        // Window Appearance & Behavior
        self.isOpaque = false                     // Transparent background
        self.backgroundColor = NSColor.clear      // Ensure background is clear
        self.level = .floating                    // Float above most other windows
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary] // Behave correctly with Spaces/Fullscreen
        self.hasShadow = false                    // Optional: remove window shadow
        self.ignoresMouseEvents = false           // IMPORTANT: Start by accepting mouse events
        self.isMovableByWindowBackground = false  // Don't allow dragging by clicking the transparent background

        // Create and set the custom view
        petView = PetView(frame: NSRect(origin: .zero, size: spriteSize))
        self.contentView = petView
    }

    // Allow window to become key to receive mouse events (might not be strictly needed if view handles it)
    override var canBecomeKey: Bool {
        return true // Let it receive mouse events
    }

    override var canBecomeMain: Bool {
         return false // Prevent it from becoming the main window
    }

    // --- Mouse Event Handling ---

    override func mouseDown(with event: NSEvent) {
        // Only start drag if clicking on the non-transparent part (the pet)
        let clickLocationInWindow = event.locationInWindow
        if petView.hitTest(clickLocationInWindow) === petView { // Check if click hit the view itself
            // Convert click location to screen coordinates
            dragStartLocation = self.convertPoint(toScreen: clickLocationInWindow)
             initialWindowOrigin = self.frame.origin
            dragDelegate?.petWindowDidStartDrag(self)
             print("Mouse Down on PetView")
        } else {
            // If clicked on transparent part, pass the event down (or ignore)
             print("Mouse Down on Transparent Area")
            super.mouseDown(with: event)
        }

    }

    override func mouseDragged(with event: NSEvent) {
        guard let startLoc = dragStartLocation, let _ = initialWindowOrigin else {
             // If not dragging the pet, pass event down
             super.mouseDragged(with: event)
             return
        }

        // Convert window location to screen coordinates
        let currentLocationInWindow = event.locationInWindow
        let currentLocationInScreen = self.convertPoint(toScreen: currentLocationInWindow)
        
        let deltaX = currentLocationInScreen.x - startLoc.x
        let deltaY = currentLocationInScreen.y - startLoc.y

        // Inform delegate about the drag delta and let it decide position
        dragDelegate?.petWindowDidDrag(self, delta: CGSize(width: deltaX, height: deltaY))

        // Reset start location for next delta calculation
        dragStartLocation = currentLocationInScreen
        self.initialWindowOrigin = self.frame.origin // Update origin reference as window moves

         // Note: We let the MovementManager calculate the final position via the delegate.
         // We don't set the origin directly here from the raw delta, allowing MovementManager
         // to apply constraints or its own logic.
    }

    override func mouseUp(with event: NSEvent) {
         if dragStartLocation != nil {
             print("Mouse Up - Ending Drag")
             dragStartLocation = nil
             initialWindowOrigin = nil
             dragDelegate?.petWindowDidEndDrag(self)
         } else {
             super.mouseUp(with: event)
         }
    }
}

// Protocol for the window to communicate drag events back to the controller
protocol PetWindowDragDelegate: AnyObject {
    func petWindowDidStartDrag(_ window: PetWindow)
    func petWindowDidDrag(_ window: PetWindow, delta: CGSize)
    func petWindowDidEndDrag(_ window: PetWindow)
}
