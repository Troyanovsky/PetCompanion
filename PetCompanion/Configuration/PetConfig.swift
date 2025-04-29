//
//  PetConfig.swift
//  PetCompanion
//
//  Created by Guodong Zhao on 4/28/25.
//

import Foundation
import AppKit // For CGSize

// --- Data Structures for Codable ---
struct PetConfig: Codable {
    let spriteSize: FrameSize
    let defaultState: String // Name of the initial state
    let states: [String: StateConfig]
    let transitions: [String: [String]] // Maps state name to possible next states
}

struct FrameSize: Codable {
    let width: Int
    let height: Int
}

struct StateConfig: Codable {
    let frames: [String]
    let sequence: String? // "random" or "sequential" (default)
    let loop: Bool
    let fps: Double
    let minDuration: Double? // Optional: For idle/movement states
    let maxDuration: Double? // Optional: For idle/movement states
    let speed: Double?      // Optional: For movement states (pixels/sec)
    let isMovement: Bool    // Indicates if this state involves pet movement
}

// --- Enums ---
enum PetState: String, CaseIterable, Decodable {
    case Default
    case StandingIdle
    case Sitting
    case SittingIdle
    case Walking
    case Running
    case Sleeping
    // Add future states here
    case Dragging // Special state not in JSON
    case Off      // Special state for toggled off
}

enum Direction {
    case left, right
}
