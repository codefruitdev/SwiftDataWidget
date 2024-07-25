//
//  AppIntent.swift
//  ThingWidget
//
//  Created by Tyler Plesetz on 7/8/24.
//

import AppIntents
import SwiftData
import WidgetKit


struct CountIntent: AppIntent {
    static var title: LocalizedStringResource {
        LocalizedStringResource("Count Intent")
    }
    
    @Parameter(title: "Thing Count")
    var count: Int

    init(count: Int) {
        self.count = count
    }
    
    init() {
    }

    func perform() async throws -> some IntentResult {
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        modelContext.author = DataModel.TransactionAuthor.widget //"widget"
        
        let fetchDescripor = FetchDescriptor(predicate: #Predicate<Thing> {
            ($0.count == count)
        })
        guard let thing = try? modelContext.fetch(fetchDescripor).first
        else {
            return .result()
        }
        do {
            if thing.count < 100 {
                thing.count += 1
                ControlCenter.shared.reloadControls(
                    ofKind: "codefruit.SwiftDataWidget.ThingWidgetControl"
                )
                WidgetCenter.shared.reloadAllTimelines()
            }
            try modelContext.save()
        } catch {
            print("Failed to save model context: \(error)")
        }
        return .result()
    }
}
