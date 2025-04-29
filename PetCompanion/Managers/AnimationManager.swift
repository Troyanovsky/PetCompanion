//
//  AnimationManager.swift
//  PetCompanion
//
//  Created by Guodong Zhao on 4/28/25.
//

import AppKit

class AnimationManager {
    private let configManager = ConfigurationManager.shared
    private var stateSpriteCache: [PetState: [NSImage]] = [:]
    private var currentFrameIndex: Int = 0
    private var frameTimer: Timer?
    private var currentFPS: Double = 1.0
    private var currentSequence: String = "sequential"
    private var targetState: PetState = .Default // Default initial state
    private var currentImages: [NSImage] = []

    init() {
        loadAllSprites()
    }

    func loadAllSprites() {
        guard let config = configManager.getConfig() else {
            Logger.error("AnimationManager: Config not loaded.")
            return
        }

        stateSpriteCache.removeAll() // Clear cache before reloading

        for (stateName, stateConfig) in config.states {
            guard let state = PetState(rawValue: stateName) else {
                Logger.warning("Unknown state '\(stateName)' in config.json")
                continue
            }

            var images: [NSImage] = []
            for frameName in stateConfig.frames {
                // Assumes sprites are directly in the app bundle
                if let image = NSImage(named: frameName) {
                    images.append(image)
                } else {
                    Logger.warning("Could not load sprite '\(frameName)' for state \(stateName)")
                }
            }
            stateSpriteCache[state] = images
        }
        Logger.info("Sprites loaded for states: \(stateSpriteCache.keys)")
        // Set initial state images
        let defaultState = PetState(rawValue: configManager.config?.defaultState ?? "") ?? .StandingIdle
        setTargetState(defaultState)
    }

    func setTargetState(_ state: PetState) {
        guard targetState != state || currentImages.isEmpty else { return } // Avoid redundant setup

        Logger.debug("AnimationManager: Setting state to \(state)")
        targetState = state
        frameTimer?.invalidate() // Stop previous animation timer
        currentFrameIndex = 0

        guard let stateConfig = configManager.getStateConfig(for: state),
              let images = stateSpriteCache[state], !images.isEmpty else {
            Logger.warning("AnimationManager: No config or sprites found for state \(state)")
            currentImages = stateSpriteCache[.Default] ?? [] // Fallback to Default
            if currentImages.isEmpty, let defaultImg = NSImage(named: "default.png") {
                 currentImages = [defaultImg] // Absolute fallback
            }
            setupFrameTimer(fps: 1.0) // Default FPS
            return
        }

        currentImages = images
        currentFPS = stateConfig.fps
        currentSequence = stateConfig.sequence ?? "sequential"
        setupFrameTimer(fps: currentFPS)
    }

    private func setupFrameTimer(fps: Double) {
        guard fps > 0 else {
            frameTimer?.invalidate()
            frameTimer = nil
            return
        }
        let timeInterval = 1.0 / fps
        // Ensure timer runs on the main thread for UI updates
        frameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(advanceFrame), userInfo: nil, repeats: true)
         // Add to main run loop to ensure it fires during UI events (like dragging)
        RunLoop.main.add(frameTimer!, forMode: .common)
    }

    @objc private func advanceFrame() {
        guard !currentImages.isEmpty else { return }

        let loop = configManager.getStateConfig(for: targetState)?.loop ?? false

        if currentSequence == "random" {
            currentFrameIndex = Int.random(in: 0..<currentImages.count)
        } else { // Sequential
            currentFrameIndex += 1
            if currentFrameIndex >= currentImages.count {
                if loop {
                    currentFrameIndex = 0
                } else {
                    currentFrameIndex = currentImages.count - 1 // Stay on last frame
                    frameTimer?.invalidate() // Stop timer if not looping
                }
            }
        }
    }

    func getCurrentFrame() -> NSImage? {
        guard currentFrameIndex >= 0 && currentFrameIndex < currentImages.count else {
            return currentImages.first // Fallback to first frame if index is somehow invalid
        }
        return currentImages[currentFrameIndex]
    }

    func stop() {
        frameTimer?.invalidate()
        frameTimer = nil
    }

    func start() {
        // Restart timer based on current state if stopped
        if frameTimer == nil {
             setTargetState(targetState) // Re-setup timer
        }
    }
}
