//
//  ThingWidgetControl.swift
//  ThingWidget
//
//  Created by Tyler Plesetz on 7/8/24.
//

import AppIntents
import SwiftUI
import WidgetKit
import SwiftData

struct ThingWidgetControl: ControlWidget {
    static let kind: String = "codefruit.SwiftDataWidget.ThingWidgetControl"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: Self.kind
        ) {
            ControlWidgetButton(action: CountIntent(count: CountProvider().currentValue())) {
                Label("\(CountProvider().currentValue()) Things", systemImage: "chevron.up")
            }
        }
        .displayName("Plus Button")
        .description("Increase Thing Count")
    }
}

struct CountProvider: ControlValueProvider {
    
    var previewValue: Int { 0 }
    
    private let modelContainer: ModelContainer
    
    init() {
        do {
            modelContainer = try ModelContainer(for: Thing.self)
        } catch {
            fatalError("Failed to create the model container: \(error)")
        }
    }
    
    func currentValue() -> Int {
        var fetchDescriptor = FetchDescriptor(sortBy: [SortDescriptor(\Thing.count, order: .forward)])
        fetchDescriptor.predicate = #Predicate { $0.count >= 0 }
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        
        if let things = try? modelContext.fetch(fetchDescriptor) {
            if let thing = things.first {
                let value = Thing(name: thing.name, count: thing.count)
                WidgetCenter.shared.reloadAllTimelines()
                return value.count
            }
        }
        return 0
    }
}
