//
//  AppDelegate.swift
//  PetCompanion
//
//  Created by Guodong Zhao on 4/28/25.
//

import Cocoa

@main // Use @main attribute for the entry point
class AppDelegate: NSObject, NSApplicationDelegate {

    private var menuBarController: MenuBarController!
    private var petController: PetController? // Hold the PetController instance

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Initialize configuration first
        // Attempt to load user config, fallback to bundled
        ConfigurationManager.shared.loadUserConfig()

        // Initialize Menu Bar
        menuBarController = MenuBarController()
        menuBarController.appDelegate = self // Link back for actions
        menuBarController.setupStatusItem()

        // Create the pet controller if it doesn't exist
        if petController == nil {
            petController = PetController()
        }
        
        // Start the pet automatically on launch (or based on a saved preference)
        togglePet(activate: true) // Start active
        menuBarController.updateToggleState(isActive: isPetActive())
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Clean up resources if needed
        petController?.stop()
    }

     // Allows app to run without a main window showing initially
     func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
         return false // Don't reopen or create a window on dock icon click
     }


    // MARK: - Actions from MenuBarController

    func togglePet(activate: Bool) {
        if activate {
            if petController == nil {
                Logger.info("AppDelegate: Creating and starting PetController")
                petController = PetController()
            }
            
            Logger.info("AppDelegate: Starting PetController")
            petController?.start()
        } else {
            Logger.info("AppDelegate: Stopping PetController")
            // Ensure we update the menu state BEFORE stopping the controller
            menuBarController.updateToggleState(isActive: false)
            petController?.stop()
        }
    }

    func isPetActive() -> Bool {
        return petController?.isRunning ?? false
    }

     func openConfigFile() {
        // Try to open the user-editable config first
        if let userConfigUrl = ConfigurationManager.shared.getUserConfigUrl(),
           FileManager.default.fileExists(atPath: userConfigUrl.path) {
            Logger.info("Opening user config: \(userConfigUrl.path)")
            NSWorkspace.shared.open(userConfigUrl)
        } else if let bundledConfigUrl = ConfigurationManager.shared.getBundledConfigUrl() {
            // If user config doesn't exist, maybe open the bundled one (read-only)
            // Or show an alert saying where the user one *would* be.
            Logger.info("Opening bundled config (read-only): \(bundledConfigUrl.path)")
            // NSWorkspace.shared.open(bundledConfigUrl) // Might confuse users
            // Better: Show an alert explaining where to find/create the editable one
             let alert = NSAlert()
             alert.messageText = "Editable Configuration"
             alert.informativeText = "To edit the pet's behavior, create or modify 'config.json' inside:\n~/Library/Application Support/\(Bundle.main.bundleIdentifier ?? "DesktopPet")/"
             alert.addButton(withTitle: "OK")
             alert.addButton(withTitle: "Reveal Folder") // Button to open Application Support
             let response = alert.runModal()

             if response == .alertSecondButtonReturn {
                 if let appSupportDir = ConfigurationManager.shared.getUserConfigUrl()?.deletingLastPathComponent() {
                     NSWorkspace.shared.open(appSupportDir)
                 }
             }

        } else {
            Logger.error("Cannot find any config file to open.")
             let alert = NSAlert()
             alert.messageText = "Error"
             alert.informativeText = "Could not locate the configuration file."
             alert.runModal()
        }
    }
}
