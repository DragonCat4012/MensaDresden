//
//  MensaDresdenApp.swift
//  MensaDresdenWatch WatchKit Extension
//
//  Created by Lars Westermann on 21.04.22.
//  Copyright © 2022 Kilian Koeltzsch. All rights reserved.
//

import SwiftUI

@main
struct MensaDresdenApp: App {
    private var settings: Settings
    private var locationManager: LocationManager
    private var api: API

    init() {
        self.settings = Settings()

        if CommandLine.arguments.contains("--uitesting") {
            self.settings.resetAll()
        }

        // Prefill settings from environment (for testing and screenshots)
        if let preFavorited = ProcessInfo.processInfo.environment["favoriteCanteens"] {
            let canteens = preFavorited.split(separator: ",").map(String.init)
            self.settings.favoriteCanteens = canteens
        }

        if let autoloadUsername = ProcessInfo.processInfo.environment["autoloadUsername"] {
            self.settings.autoloadCardnumber = autoloadUsername
        }
        if let autoloadPassword = ProcessInfo.processInfo.environment["autoloadPassword"] {
            self.settings.autoloadPassword = autoloadPassword
        }

        if let currentBalanceStr = ProcessInfo.processInfo.environment["emeal.currentbalance"] {
            let currentBalance = Double(currentBalanceStr) ?? 0.0
            UserDefaults.standard.set(currentBalance, forKey: "emeal.currentbalance")
        }
        if let lastTransactionStr = ProcessInfo.processInfo.environment["emeal.lasttransaction"] {
            let lastTransaction = Double(lastTransactionStr) ?? 0.0
            UserDefaults.standard.set(lastTransaction, forKey: "emeal.lasttransaction")
        }
        if let lastScanStr = ProcessInfo.processInfo.environment["emeal.lastscan"] {
            let lastScan = Double(lastScanStr).flatMap { Date(timeIntervalSince1970: $0) } ?? Date()
            UserDefaults.standard.set(lastScan, forKey: "emeal.lastscan")
        }

        if settings.canteenSorting == Settings.CanteenSorting.distance.rawValue {
            LocationManager.shared.start()
        }
        
        self.locationManager = LocationManager.shared
        self.api = API()

        Analytics.setup()

        Analytics.send(.currentSettings, with: [
            "settingsFavoritedCanteensCount": String(self.settings.favoriteCanteens.count),
            "settingsHasAutoloadCredentials": String(self.settings.autoloadCardnumber != nil),
            "settingsCanteenSortingMode": self.settings.canteenSorting,
            "settingsUserDiet": self.settings.userDiet,
            "settingsPriceType": self.settings.priceType,
            "settingsHasChangedIngredientList": String(UserDefaults.standard.object(forKey: "ingredientBlacklist") != nil),
            "settingsHasChangedAllergenList": String(UserDefaults.standard.object(forKey: "allergenBlacklist") != nil)
        ])
    }
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(settings)
                .environmentObject(locationManager)
                .environmentObject(api)
        }
    }
}
