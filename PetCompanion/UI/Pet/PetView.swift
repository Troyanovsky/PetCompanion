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

    // Ensure view isn't opaque
    override var isOpaque: Bool {
        return false
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard let image = currentImage else { return }

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
