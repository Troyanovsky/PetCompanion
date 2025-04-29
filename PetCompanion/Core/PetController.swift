//
//  PetController.swift
//  PetCompanion
//
//  Created by Guodong Zhao on 4/28/25.
//

import AppKit

class PetController: PetWindowDragDelegate {
    private let configManager = ConfigurationManager.shared
    private let animationManager: AnimationManager
    private let movementManager: MovementManager
    private let stateMachine: StateMachine

    private var petWindow: PetWindow?
    private var updateTimer: Timer?
    private var lastUpdateTime: TimeInterval = 0

    private(set) var isRunning: Bool = false

    init() {
        // Initialize managers (ensure config is loaded beforehand, maybe in AppDelegate)
        self.animationManager = AnimationManager()
        self.movementManager = MovementManager()

        // Determine initial state from config
        let initialRawState = configManager.getConfig()?.defaultState ?? "StandingIdle"
        let initialState = PetState(rawValue: initialRawState) ?? .StandingIdle
        self.stateMachine = StateMachine(initialState: initialState)

        // Set up callback for state changes
        self.stateMachine.onStateChanged = { [weak self] newState in
            self?.handleStateChange(newState)
        }
    }

    func start() {
        guard !isRunning else { return }
        print("PetController: Starting...")

        guard let spriteSize = configManager.getSpriteSize() else {
             print("PetController Error: Cannot start without sprite size from config.")
             return
        }

        // Ensure managers are ready (sprites loaded, screen rect updated)
        animationManager.loadAllSprites() // Reload sprites in case config changed
        movementManager.updateScreenRect()
        movementManager.setInitialPosition() // Reset position

        // Create the pet window
        petWindow = PetWindow(spriteSize: spriteSize)
        petWindow?.dragDelegate = self // Set self as delegate for drag events
        petWindow?.setFrameOrigin(movementManager.currentPosition) // Set initial position
        petWindow?.makeKeyAndOrderFront(nil) // Show the window

        // Start the state machine
        stateMachine.start() // This will trigger the initial state setup

        // Start the main update loop
        lastUpdateTime = ProcessInfo.processInfo.systemUptime
        updateTimer = Timer.scheduledTimer(timeInterval: 1.0 / 60.0, // Aim for 60 FPS updates
                                           target: self,
                                           selector: #selector(update),
                                           userInfo: nil,
                                           repeats: true)
        RunLoop.main.add(updateTimer!, forMode: .common) // Ensure timer runs during UI events

        isRunning = true
    }

    func stop() {
        guard isRunning else { return }
        print("PetController: Stopping...")

        updateTimer?.invalidate()
        updateTimer = nil

        stateMachine.stop()
        animationManager.stop() // Stop animation timers

        petWindow?.close() // Close the window
        petWindow = nil

        isRunning = false
    }

    @objc private func update() {
        guard isRunning else { return }

        let currentTime = ProcessInfo.processInfo.systemUptime
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Only update if not paused or in a non-updating state
        guard stateMachine.currentState != .Off else { return }


        // 1. Update Movement (only if not dragging)
        // State machine dictates if movement should occur based on current state
        if !movementManager.isDragging {
             movementManager.update(deltaTime: deltaTime, state: stateMachine.currentState)
        }
        // If dragging, MovementManager position is updated via drag delegate methods

        // 2. Update Animation (AnimationManager handles its own timing internally)
        // We just need to ensure it has the correct target state (done via stateMachine callback)

        // 3. Get Updated Data
        let currentFrame = animationManager.getCurrentFrame()
        let currentPosition = movementManager.currentPosition
        let currentDirection = movementManager.direction

        // 4. Update UI (Window and View) - MUST be on main thread
        DispatchQueue.main.async { [weak self] in
             guard let self = self, self.isRunning, let window = self.petWindow else { return }

             // Update window position
             window.setFrameOrigin(currentPosition)

             // Update view content
             window.petView.currentImage = currentFrame
             window.petView.direction = currentDirection
             window.petView.needsDisplay = true // Tell the view to redraw
        }
    }

    private func handleStateChange(_ newState: PetState) {
         print("PetController: State changed to \(newState)")
        // Inform Animation Manager about the new state immediately
        animationManager.setTargetState(newState)

        // Movement manager doesn't need explicit notification here,
        // its update loop checks the current state provided by the state machine.
    }

    // MARK: - PetWindowDragDelegate Methods

    func petWindowDidStartDrag(_ window: PetWindow) {
        print("PetController: Drag Started")
        movementManager.startDrag() // Notify movement manager
        stateMachine.handleDragStart() // Notify state machine
    }

    func petWindowDidDrag(_ window: PetWindow, delta: CGSize) {
         // Pass delta to movement manager
         movementManager.drag(to: .zero, delta: delta) // 'to' point isn't strictly needed if using delta

        // Force an immediate UI update during drag for responsiveness
        let currentPosition = movementManager.currentPosition
        DispatchQueue.main.async {
             window.setFrameOrigin(currentPosition)
        }
    }

    func petWindowDidEndDrag(_ window: PetWindow) {
        print("PetController: Drag Ended")
        movementManager.endDrag()     // This includes the dropToBottom logic
        stateMachine.handleDragEnd()  // Let state machine decide next state

        // Update UI after drop
        let finalPosition = movementManager.currentPosition
         DispatchQueue.main.async {
             window.setFrameOrigin(finalPosition)
         }
    }
}
