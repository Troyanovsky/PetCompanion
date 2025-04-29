//
//  MenuBarController.swift
//  PetCompanion
//
//  Created by Guodong Zhao on 4/28/25.
//

import AppKit

class MenuBarController {
    private var statusItem: NSStatusItem!
    weak var appDelegate: AppDelegate? // To communicate toggle actions

    func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            // Use the asset catalog image
            button.image = NSImage(named: "MenuBarIcon")
            // Ensure it renders correctly in dark/light mode if it's a template image
            // button.image?.isTemplate = true
        }

        setupMenu()
    }

    private func setupMenu() {
        let menu = NSMenu()

        // Toggle Item
        let toggleItem = NSMenuItem(title: "Pet On", action: #selector(togglePet(_:)), keyEquivalent: "")
        toggleItem.target = self
        // Set initial state based on PetController (AppDelegate will manage this)
        toggleItem.state = appDelegate?.isPetActive() ?? false ? .on : .off
        menu.addItem(toggleItem)


        // Open Config Item
        let openConfigItem = NSMenuItem(title: "Edit Behavior (JSON)...", action: #selector(openConfig(_:)), keyEquivalent: "")
        openConfigItem.target = self
        menu.addItem(openConfigItem)

        menu.addItem(NSMenuItem.separator())

        // Quit Item
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    @objc func togglePet(_ sender: NSMenuItem) {
        let shouldBeActive = (sender.state == .off) // If currently off, turn on
        appDelegate?.togglePet(activate: shouldBeActive)
        // Update the menu item state AFTER the action is processed
        sender.state = shouldBeActive ? .on : .off
        sender.title = shouldBeActive ? "Pet On" : "Pet Off" // Update title too
    }

    @objc func openConfig(_ sender: NSMenuItem) {
         appDelegate?.openConfigFile()
    }

    // Called by AppDelegate to update menu item state if toggled elsewhere
    func updateToggleState(isActive: Bool) {
        guard let menu = statusItem.menu, let toggleItem = menu.item(at: 0) else { return }
         toggleItem.state = isActive ? .on : .off
         toggleItem.title = isActive ? "Pet On" : "Pet Off"
    }
}
