//
//  ContentView.swift
//  SwiftDataWidget
//
//  Created by Tyler Plesetz on 7/8/24.
//

import SwiftUI
import SwiftData
import WidgetKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var things: [Thing]
    @Environment(\.scenePhase) private var phase
    @State private var updatedThings: [PersistentIdentifier] = []
    
    var body: some View {
        NavigationStack {
            VStack {
                ForEach(things) { thing in
                    HStack {
                        Text("\(thing.count)")
                            .font(.system(.title).bold())
                            .contentTransition(.numericText())
                        
                        // Plus Button
                        Button(action: {
                            withAnimation {
                                if thing.count < 50 {
                                    thing.count += 1
                                    WidgetCenter.shared.reloadAllTimelines()
                                }
                            }
                        }, label: {
                            Image(systemName: "plus.circle.fill")
                                .symbolRenderingMode(.hierarchical)
                                .font(.title.bold())
                                .foregroundStyle(Color.accentColor)
                        })
                        .buttonRepeatBehavior(.enabled)
                    }
                }
            }
            .navigationTitle("Things")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        let newThing = Thing(name: "thing1", count: 1)
                        NewThing(newThing)
                    } label: {
                        Image(systemName: "plus")
                    }
                    .disabled(things.count >= 1)
                    
                }
            }
            .onChange(of: phase) {
                WidgetCenter.shared.reloadAllTimelines()
            }
            .onChange(of: phase) { _, newValue in
                Task {
                    if newValue == .active {
                        let updatedThings = await DataModel.shared.findUpdatedThingsWithCounts()
                        for (index, thing) in things.enumerated() {
                            if let updatedThing = updatedThings.first(where: { $0.persistentModelID == thing.persistentModelID }) {
                                UpdateThing(things[index], updatedThing)
                                print("yes")
                            } else {
                                print("no")
                            }
                        }
                        WidgetCenter.shared.reloadAllTimelines()
                    } else {
                        // Persist the unread trip names for the next launch session.
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }
            }
        }
    }
    
    private func NewThing(_ thing: Thing) {
        modelContext.insert(thing)
    }
    
    private func UpdateThing(_ thing: Thing, _ newThing: Thing) {
        thing.count = newThing.count
    }
}



#Preview(traits: .sampleData) {
    ContentView()
}
