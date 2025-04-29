//
//  PetView.swift
//  PetCompanion
//
//  Created by Guodong Zhao on 4/28/25.
//

import AppKit

class PetView: NSView {
    var currentImage: NSImage?
    var direction: Direction = .right
    var visibilityState: Bool = true  // Add a custom property for visibility state
    
    // Ensure view isn't opaque
    override var isOpaque: Bool {
        return false
    }
    
    // Replace the custom isHidden property with a more specific name
    var isPetHidden: Bool {
        get {
            return !visibilityState
        }
        set {
            visibilityState = !newValue
            self.isHidden = newValue // Use the standard NSView property
            needsDisplay = true
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Don't draw if hidden
        guard visibilityState, let image = currentImage else { return }
        
        // Clear the background (important for transparency)
        NSColor.clear.set()
        dirtyRect.fill()

        var imageRect = CGRect(origin: .zero, size: image.size)

        // Center the image if the view bounds are larger (they should match ideally)
         if bounds.size.width > image.size.width {
             imageRect.origin.x = (bounds.size.width - image.size.width) / 2
         }
         if bounds.size.height > image.size.height {
             imageRect.origin.y = (bounds.size.height - image.size.height) / 2
         }


        // Handle flipping
        if direction == .left {
            NSGraphicsContext.saveGraphicsState() // Save context state
            // Create a flip transform
            var flipTransform = AffineTransform(translationByX: bounds.width / 2, byY: 0)
            flipTransform.scale(x: -1.0, y: 1.0)
            flipTransform.translate(x: -bounds.width / 2, y: 0)

            (flipTransform as NSAffineTransform).concat() // Apply transform

            image.draw(in: imageRect)

            NSGraphicsContext.restoreGraphicsState() // Restore context state
        } else {
            // Draw normally if facing right
            image.draw(in: imageRect)
        }
    }

    // Required for receiving mouse events if window allows it
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
}
