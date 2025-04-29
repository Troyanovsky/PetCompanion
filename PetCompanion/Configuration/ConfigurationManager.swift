//
//  ConfigurationManager.swift
//  PetCompanion
//
//  Created by Guodong Zhao on 4/28/25.
//

import Foundation

class ConfigurationManager {
    static let shared = ConfigurationManager() // Singleton

    private(set) var config: PetConfig?
    private(set) var configUrl: URL?

    private init() {
        loadConfig()
    }

    func getBundledConfigUrl() -> URL? {
         Bundle.main.url(forResource: "config", withExtension: "json")
    }

    // --- Loading Logic ---
    func loadConfig(from url: URL? = nil) {
        guard let urlToLoad = url ?? getBundledConfigUrl() else {
            Logger.error("config.json not found in bundle.")
            // Implement fallback or error handling
            return
        }

        self.configUrl = urlToLoad // Store the URL used
        Logger.info("Loading configuration from \(urlToLoad.path)")

        do {
            let data = try Data(contentsOf: urlToLoad)
            let decoder = JSONDecoder()
            config = try decoder.decode(PetConfig.self, from: data)
            Logger.info("Configuration loaded successfully from \(urlToLoad.path)")
        } catch {
            Logger.error("Error loading or parsing config.json: \(error)")
            // Implement more robust error handling
            config = nil
        }
    }

    // --- Accessors ---
    func getConfig() -> PetConfig? {
        return config
    }

    func getStateConfig(for stateName: String) -> StateConfig? {
        return config?.states[stateName]
    }

     func getStateConfig(for state: PetState) -> StateConfig? {
        return config?.states[state.rawValue]
    }

    func getSpriteSize() -> CGSize? {
        guard let size = config?.spriteSize else { return nil }
        return CGSize(width: size.width, height: size.height)
    }

    // --- User Editable Config (Advanced) ---
    // You might copy the bundled config to Application Support on first launch
    // and load from there subsequently. This allows users to edit it.
    func getUserConfigUrl() -> URL? {
        guard let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        // Use your app's bundle ID for uniqueness
        let appDir = appSupport.appendingPathComponent(Bundle.main.bundleIdentifier ?? "DesktopPet")
        let configUrl = appDir.appendingPathComponent("config.json")

        // Create directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: appDir.path) {
            do {
                try FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true, attributes: nil)
                // Copy bundled config here on first launch if needed
                if let bundledUrl = getBundledConfigUrl(), !FileManager.default.fileExists(atPath: configUrl.path) {
                   try FileManager.default.copyItem(at: bundledUrl, to: configUrl)
                    Logger.info("Copied initial config to Application Support.")
                }
            } catch {
                Logger.error("Error creating Application Support directory: \(error)")
                return nil
            }
        }
        return configUrl
    }

    // Call this from AppDelegate or MenuBarController to load user's config if available
    func loadUserConfig() {
        if let userUrl = getUserConfigUrl(), FileManager.default.fileExists(atPath: userUrl.path) {
             loadConfig(from: userUrl)
        } else {
            // Fallback to bundled if user config doesn't exist
            loadConfig(from: getBundledConfigUrl())
        }
    }
}
