//
//  DataModel.swift
//  SwiftDataWidget
//
//  Created by Tyler Plesetz on 7/8/24.
//

import SwiftUI
import SwiftData

actor DataModel {
    struct TransactionAuthor {
        static let widget = "widget"
    }
    
    static let shared = DataModel()
    private init() {}
    
    nonisolated lazy var modelContainer: ModelContainer = {
        let modelContainer: ModelContainer
        do {
            modelContainer = try ModelContainer(for: Thing.self)
        } catch {
            fatalError("Failed to create the model container: \(error)")
        }
        return modelContainer
    }()
}

extension DataModel {
    
    struct UserDefaultsKey {
        static let historyToken = "historyToken"
    }
    
    func findUpdatedThingsWithCounts() -> [Thing] {
        let updatedThings = findUpdatedThings()
        return Array(updatedThings)
    }
    
    private func findUpdatedThings() -> Set<Thing> {
        let tokenData = UserDefaults.standard.data(forKey: UserDefaultsKey.historyToken)
        
        var historyToken: DefaultHistoryToken? = nil
        if let tokenData {
            historyToken = try? JSONDecoder().decode(DefaultHistoryToken.self, from: tokenData)
        }
        let transactions = findTransactions(after: historyToken, author: TransactionAuthor.widget)
        let (updatedThings, newToken) = findThings(in: transactions)
        
        if let newToken {
            let newTokenData = try? JSONEncoder().encode(newToken)
            UserDefaults.standard.set(newTokenData, forKey: UserDefaultsKey.historyToken)
        }
        return updatedThings
    }
    
    private func findTransactions(after token: DefaultHistoryToken?, author: String) -> [DefaultHistoryTransaction] {
        
        var historyDescriptor = HistoryDescriptor<DefaultHistoryTransaction>()
        
        if let token {
            historyDescriptor.predicate = #Predicate { transaction in
                (transaction.token > token) && (transaction.author == author)
            }
        }
        
        var transactions: [DefaultHistoryTransaction] = []
        let taskContext = ModelContext(modelContainer)
        do {
            transactions = try taskContext.fetchHistory(historyDescriptor)
        } catch let error {
            print(error)
        }
        
        return transactions
    }
    
    private func findThings(in transactions: [DefaultHistoryTransaction]) -> (Set<Thing>, DefaultHistoryToken?) {
        let taskContext = ModelContext(modelContainer)
        var resultThings: Set<Thing> = []
        
        for transaction in transactions {
            for change in transaction.changes {
                let modelID = change.changedPersistentIdentifier
                let fetchDescriptor = FetchDescriptor<Thing>(predicate: #Predicate { thing in
                    thing.persistentModelID == modelID
                })
                let fetchResults = try? taskContext.fetch(fetchDescriptor)
                guard let matchedThing = fetchResults?.first else {
                    continue
                }
                switch change {
                case .insert(_ as DefaultHistoryInsert<Thing>):
                    resultThings.insert(matchedThing)
                case .update(_ as DefaultHistoryUpdate<Thing>):
                    resultThings.update(with: matchedThing)
                case .delete(_ as DefaultHistoryDelete<Thing>):
                    resultThings.remove(matchedThing)
                default: break
                }
            }
        }
        return (resultThings, transactions.last?.token)
    }
}
