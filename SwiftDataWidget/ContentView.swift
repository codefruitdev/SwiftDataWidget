//
//  ContentView.swift
//  SwiftDataWidget
//
//  Created by Tyler Plesetz on 7/8/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var things: [Thing]
    
    var body: some View {
        
        var linearGradient: LinearGradient {
            LinearGradient(colors: [.clear, .primary.opacity(0.3), .clear], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
        
        NavigationStack {
            VStack {
                ForEach(things) { thing in
                    HStack {
                        // Minus Button
                        Button(action: {
                            withAnimation {
                                if thing.count >= 1 {
                                    thing.count -= 1
                                }
                            }
                        }, label: {
                            Image(systemName: "minus")
                                .font(.title.bold())
                                .frame(width: 35, height: 35)
                                .foregroundStyle(Color.pink)
                        })
                        .buttonRepeatBehavior(.enabled)
                        
                        Text("\(thing.count)")
                            .font(.system(.title).bold())
                            .frame(width: 45, height: 45)
                            .contentTransition(.numericText())
                            .overlay(
                                RoundedRectangle(cornerRadius: 10).strokeBorder(linearGradient).fill(.secondary.opacity(0.15))
                            )
                        
                        // Plus Button
                        Button(action: {
                            withAnimation {
                                if thing.count < 50 {
                                    thing.count += 1
                                }
                            }
                        }, label: {
                            Image(systemName: "plus")
                                .font(.title.bold())
                                .frame(width: 35, height: 35)
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
                    
                }
            }
        }
    }
    
    private func NewThing(_ thing: Thing) {
        modelContext.insert(thing)
    }
}



#Preview {
    ContentView()
}
