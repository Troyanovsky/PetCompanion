//
//  StateMachine.swift
//  PetCompanion
//
//  Created by Guodong Zhao on 4/28/25.
//

import Foundation

class StateMachine {
    private(set) var currentState: PetState
    private let configManager = ConfigurationManager.shared
    private var stateTimer: Timer?
    private var currentStateDuration: TimeInterval = 0 // Time spent in current state
    private var targetDuration: TimeInterval = Double.infinity // How long to stay in the current state
    
    // Add property to track visibility
    private(set) var isVisible: Bool = true

    var onStateChanged: ((PetState) -> Void)? // Callback for when state changes
    var onVisibilityChanged: ((Bool) -> Void)? // New callback for visibility changes

    init(initialState: PetState) {
        self.currentState = initialState
    }

    func start() {
        Logger.info("StateMachine: Starting with state \(currentState)")
        
        // Reset to default state if currently Off
        if currentState == .Off {
            let defaultStateString = configManager.getConfig()?.defaultState ?? "StandingIdle"
            let defaultState = PetState(rawValue: defaultStateString) ?? .StandingIdle
            currentState = defaultState
            Logger.info("StateMachine: Resetting from Off to default state: \(defaultState)")
        }
        
        setVisible(true)
        enterState(currentState)
    }

    func stop() {
        Logger.info("StateMachine: Stopping")
        stateTimer?.invalidate()
        stateTimer = nil
        
        // Set to Off state and notify listeners
        currentState = .Off
        setVisible(false)
        onStateChanged?(.Off)
    }
    
    // New method to control visibility
    func setVisible(_ visible: Bool) {
        guard isVisible != visible else { return }
        isVisible = visible
        onVisibilityChanged?(visible)
    }

    private func enterState(_ newState: PetState) {
        Logger.debug("StateMachine: Entering state \(newState)")
        currentState = newState
        stateTimer?.invalidate() // Cancel previous timer if any
        currentStateDuration = 0 // Reset duration counter

        // Special case for Dragging state - it should be the only state with infinite duration
        if newState == .Dragging {
            targetDuration = Double.infinity
            Logger.debug("StateMachine: Dragging state has infinite duration")
            return
        }

        guard let stateConfig = configManager.getStateConfig(for: newState) else {
            Logger.debug("StateMachine: No config for state \(newState), using default duration 1-3s.")
            targetDuration = Double.random(in: 1.0...3.0) // Default random duration
            return
        }

        // Determine target duration for this state
        if let minDur = stateConfig.minDuration, let maxDur = stateConfig.maxDuration {
            targetDuration = Double.random(in: minDur...maxDur)
        } else if let fixedDur = stateConfig.minDuration { // Allow fixed duration if max is missing
             targetDuration = fixedDur
        } else if !stateConfig.loop && newState != .Default { // If it's a non-looping animation (like Sitting), duration is animation length
            let frameCount = stateConfig.frames.count
            targetDuration = frameCount > 0 ? Double(frameCount) / stateConfig.fps : 1.0 // Estimate duration
        }
        else {
            // For any state without duration in JSON, use random 1-3 seconds
            targetDuration = Double.random(in: 1.0...3.0)
        }

         Logger.debug("StateMachine: Target duration for \(newState): \(targetDuration == Double.infinity ? "Infinite" : "\(targetDuration)s")")

        // Start a timer to check for state transition
        // Use a repeating timer that fires frequently to check duration
        stateTimer = Timer.scheduledTimer(timeInterval: 0.5, // Check every half second
                                          target: self,
                                          selector: #selector(updateStateTimer),
                                          userInfo: nil,
                                          repeats: true)
        RunLoop.main.add(stateTimer!, forMode: .common)


        onStateChanged?(newState) // Notify listener (PetController)
    }

    @objc private func updateStateTimer() {
        guard currentState != .Dragging && currentState != .Off else {
            // Don't automatically transition out of Dragging or Off states
            stateTimer?.invalidate() // No need for timer in these states
            return
        }

        currentStateDuration += stateTimer?.timeInterval ?? 0.5 // Add the timer interval

        // Check if it's time to transition
        if currentStateDuration >= targetDuration {
            Logger.debug("StateMachine: Duration \(targetDuration)s reached for \(currentState). Transitioning...")
            decideNextState()
        }
    }

    private func decideNextState() {
        guard let config = configManager.getConfig() else { return }

        // Always go to Default state first if coming from a movement/action? (Your design choice)
        // Let's implement the JSON transition rules
        if let allowedTransitions = config.transitions[currentState.rawValue], !allowedTransitions.isEmpty {
             // If current state has specific transitions defined

             // Special case: If Sitting finished, go directly to SittingIdle
             if currentState == .Sitting, let sittingIdleState = PetState(rawValue: "SittingIdle"), allowedTransitions.contains("SittingIdle") {
                 enterState(sittingIdleState)
                 return
             }

             // Handle transition to Default
             if allowedTransitions.contains("Default") && currentState != .Default {
                 enterState(.Default)
             } else {
                 // Pick a random state from the allowed list (that isn't Default, maybe?)
                 let nextPossible = allowedTransitions.compactMap { PetState(rawValue: $0) }.filter { $0 != .Default }
                 if let nextState = nextPossible.randomElement() {
                    enterState(nextState)
                 } else {
                    // Fallback if only Default was listed or invalid states
                    let defaultStateEnum = PetState(rawValue: config.defaultState) ?? .StandingIdle
                    enterState(defaultStateEnum)
                 }
             }

        } else if currentState == .Default {
            // If we are in Default, choose randomly from its allowed transitions
            if let defaultTransitions = config.transitions["Default"], !defaultTransitions.isEmpty {
                 let nextState = defaultTransitions.compactMap { PetState(rawValue: $0) }.randomElement() ?? 
                    PetState(rawValue: configManager.config?.defaultState ?? "") ?? .StandingIdle // Fallback
                 enterState(nextState)
            } else {
                // Fallback if Default has no transitions defined
                let defaultStateEnum = PetState(rawValue: configManager.config?.defaultState ?? "") ?? .StandingIdle
                enterState(defaultStateEnum)
            }
        }
         else {
            // If no specific transitions, maybe just go back to the default idle state?
            Logger.debug("StateMachine: No specific transition for \(currentState), returning to default idle.")
            let defaultStateEnum = PetState(rawValue: config.defaultState) ?? .StandingIdle
            enterState(defaultStateEnum)
        }
    }

    // External triggers
    func handleDragStart() {
        if currentState != .Dragging {
            enterState(.Dragging)
        }
    }

    func handleDragEnd() {
        if currentState == .Dragging {
             // Decide what state to enter after dragging stops
             // Usually back to an idle state or Default
             enterState(.Default) // Go to default briefly before deciding next action
        }
    }

    func forceState(_ state: PetState) {
         enterState(state)
    }
}
