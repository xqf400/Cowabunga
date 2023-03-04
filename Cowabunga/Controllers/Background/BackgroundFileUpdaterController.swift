//
//  BackgroundFileUpdaterController.swift
//  Cowabunga
//
//  Created by lemin on 1/17/23.
//

// credits to sourcelocation and Evyrest

import Foundation
import SwiftUI
import notify
import SystemConfiguration

struct BackgroundOption: Identifiable {
    var id = UUID()
    var key: String
    var title: String
    var enabled: Bool = true
}

class BackgroundFileUpdaterController: ObservableObject {
    static let shared = BackgroundFileUpdaterController()
    
    public var BackgroundOptions: [BackgroundOption] = [
        .init(key: "Dock", title: NSLocalizedString("Dock", comment: "Run in background option")),
        .init(key: "HomeBar", title: NSLocalizedString("Home Bar", comment: "Run in background option")),
        .init(key: "FolderBG", title: NSLocalizedString("Folder Background", comment: "Run in background option")),
        .init(key: "FolderBlur", title: NSLocalizedString("Folder Blur", comment: "Run in background option")),
        .init(key: "PodBackground", title: NSLocalizedString("Library Pod Backgrounds", comment: "Run in background option")),
        .init(key: "NotifBackground", title: NSLocalizedString("Notification Banner Background", comment: "Run in background option")),
        .init(key: "CCModuleBackground", title: NSLocalizedString("CC Module Background", comment: "Run in background option")),
        .init(key: "Lock", title: NSLocalizedString("Lock", comment: "Run in background option")),
        .init(key: "Audio", title: NSLocalizedString("Audio", comment: "Run in background option")),
        .init(key: "Seconds", title: NSLocalizedString("Seconds", comment: "Run in background option")),
        .init(key: "Date", title: NSLocalizedString("Date", comment: "Run in background option")),
        .init(key: "Weather", title: NSLocalizedString("Weather", comment: "Run in background option"))
    ]
    
    public var time = 120.0
    
    @Published var enabled: Bool = UserDefaults.standard.bool(forKey: "BackgroundApply")
    
    func setup() {
        if self.enabled {
            BackgroundFileUpdaterController.shared.updateFiles()
        }
        Timer.scheduledTimer(withTimeInterval: time, repeats: true) { timer in
            if self.enabled {
                BackgroundFileUpdaterController.shared.updateFiles()
            }
        }
    }
    
    func stop() {
        // lol
    }
    
    func updateFiles() {
        Task {
            let ak: String = "_BGApply"
            
            if UserDefaults.standard.bool(forKey: "TimeIsEnabled") == true {
                setTimeSeconds()
            }
            if UserDefaults.standard.bool(forKey: "DateIsEnabled") == true {
                setCrumbDate()
            }
            if UserDefaults.standard.bool(forKey: "WeatherIsEnabled") == true {
                setCrumbWeather()
            }
            
            // apply the dock
            if UserDefaults.standard.bool(forKey: "Dock\(ak)") {
                if UserDefaults.standard.bool(forKey: "DockHidden") == true {
                    let _ = overwriteFile(typeOfFile: OverwritingFileTypes.springboard, fileIdentifier: "DockHidden", true)
                } else {
                    SpringboardColorManager.applyColor(forType: SpringboardColorManager.SpringboardType.dock)
                }
            }
            // apply the home bar
            if UserDefaults.standard.bool(forKey: "HomeBar\(ak)") {
                if UserDefaults.standard.bool(forKey: "HomeBarHidden") == true {
                    let _ = overwriteFile(typeOfFile: OverwritingFileTypes.springboard, fileIdentifier: "HomeBarHidden", true)
                }
            }
            // apply the folder bg
            if UserDefaults.standard.bool(forKey: "FolderBG\(ak)") {
                if UserDefaults.standard.bool(forKey: "FolderBGHidden") == true {
                    let _ = overwriteFile(typeOfFile: OverwritingFileTypes.springboard, fileIdentifier: "FolderBGHidden", true)
                } else {
                    SpringboardColorManager.applyColor(forType: SpringboardColorManager.SpringboardType.folder)
                }
            }
            // apply the folder blur
            if UserDefaults.standard.bool(forKey: "FolderBlur\(ak)") {
                if UserDefaults.standard.bool(forKey: "FolderBlurDisabled") == true {
                    let _ = overwriteFile(typeOfFile: OverwritingFileTypes.springboard, fileIdentifier: "FolderBlurDisabled", true)
                } else {
                    SpringboardColorManager.applyColor(forType: SpringboardColorManager.SpringboardType.folderBG)
                }
            }
            // apply the app library pods
            if UserDefaults.standard.bool(forKey: "PodBackground\(ak)") {
                if UserDefaults.standard.bool(forKey: "PodBackgroundDisabled") == true {
                    let _ = overwriteFile(typeOfFile: OverwritingFileTypes.springboard, fileIdentifier: "PodBackgroundDisabled", true)
                } else {
                    SpringboardColorManager.applyColor(forType: SpringboardColorManager.SpringboardType.libraryFolder)
                }
            }
            // apply the notif banner
            if UserDefaults.standard.bool(forKey: "NotifBackground\(ak)") {
                if UserDefaults.standard.bool(forKey: "NotifBackgroundDisabled") == true {
                    let _ = overwriteFile(typeOfFile: OverwritingFileTypes.springboard, fileIdentifier: "NotifBackgroundDisabled", true)
                } else {
                    SpringboardColorManager.applyColor(forType: SpringboardColorManager.SpringboardType.notif)
                }
            }
            // apply the transparent modules
            if UserDefaults.standard.bool(forKey: "CCModuleBackground\(ak)") {
                if UserDefaults.standard.bool(forKey: "CCModuleBackgroundDisabled") == true {
                    let _ = overwriteFile(typeOfFile: OverwritingFileTypes.cc, fileIdentifier: "CCModuleBackgroundDisabled", true)
                } else {
                    SpringboardColorManager.applyColor(forType: .module)
                }
            }
            
            // apply lock
            if UserDefaults.standard.bool(forKey: "Lock\(ak)") {
                if UserDefaults.standard.string(forKey: "CurrentLock") ?? "Default" != "Default" {
                    let lockName: String = UserDefaults.standard.string(forKey: "CurrentLock")!
                    print("applying lock")
                    let _ = LockManager.applyLock(lockName: lockName)
                }
            }
            
            // apply custom operations
            do {
                try AdvancedManager.applyOperations(background: true)
            } catch {
                print(error.localizedDescription)
            }
            
            // apply to audios
            if UserDefaults.standard.bool(forKey: "Audio\(ak)") {
                let _ = AudioFiles.applyAllAudio()
            }
            
            // kill screentime agent
            if UserDefaults.standard.bool(forKey: "stakillerenabled") == true {
                killSTA()
            }

        }
    }
}
