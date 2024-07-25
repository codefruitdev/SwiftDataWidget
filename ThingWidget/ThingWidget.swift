//
//  ThingWidget.swift
//  ThingWidget
//
//  Created by Tyler Plesetz on 7/8/24.
//

import WidgetKit
import SwiftUI
import SwiftData

struct ThingWidget: Widget {
    let kind: String = "ThingWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ThingWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Things")
        .description("Count your Things")
    }
}

struct Provider: TimelineProvider {
    private let modelContainer: ModelContainer
    
    init() {
        do {
            modelContainer = try ModelContainer(for: Thing.self)
        } catch {
            fatalError("Failed to create the model container: \(error)")
        }
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry.placeholderEntry
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        completion(SimpleEntry.placeholderEntry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        var fetchDescriptor = FetchDescriptor(sortBy: [SortDescriptor(\Thing.count, order: .forward)])
        fetchDescriptor.predicate = #Predicate { $0.count >= 0 }
        let modelContext = ModelContext(DataModel.shared.modelContainer)
        
        if let things = try? modelContext.fetch(fetchDescriptor) {
            if let thing = things.first {
                let newEntry = SimpleEntry(date: .now, count: thing.count)
                let timeline = Timeline(entries: [newEntry], policy: .never)
                completion(timeline)
                return
            }
        }
        /**
         Return "No Trips" entry with `.never` policy when there is no upcoming trip.
         The main app triggers a widget update when adding a new trip.
         */
        let newEntry = SimpleEntry(date: .now, count: 1)
        let timeline = Timeline(entries: [newEntry], policy: .never)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let count: Int
    
    static var placeholderEntry: SimpleEntry {
        let now = Date()
        return SimpleEntry(date: now, count: 1)
    }
}

struct ThingWidgetEntryView : View {
    var entry: Provider.Entry
    
    var linearGradient: LinearGradient {
        LinearGradient(colors: [.clear, .primary.opacity(0.3), .clear], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    var body: some View {
        HStack {
            Text("\(entry.count)")
                .font(.system(.title).bold())
                .frame(width: 45, height: 45)
                .contentTransition(.numericText())
                .overlay(
                    RoundedRectangle(cornerRadius: 10).strokeBorder(linearGradient).fill(.secondary.opacity(0.15))
                )
            
            // Plus Button
            Button(intent: CountIntent(count: entry.count)) {
                Image(systemName: "plus")
                    .font(.title.bold())
                    .frame(width: 15, height: 15)
                    .foregroundStyle(Color.accentColor)
            }
            .buttonRepeatBehavior(.enabled)
        }
    }
}

#Preview(as: .systemSmall) {
    ThingWidget()
} timeline: {
    SimpleEntry(date: .now, count: 1)
}
