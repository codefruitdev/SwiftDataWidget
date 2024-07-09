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
    static let kind: String = "codefruit.SwiftDataWidget.ThingWidget"

    var body: some ControlWidgetConfiguration {
        AppIntentControlConfiguration(
            kind: Self.kind,
            provider: Provider()
        ) { value in
            ControlWidgetButton(action: CountIntent(count: 1)) {
                Label("Increase", systemImage: "11.circle")
            }
        }
        .displayName("Plus Button")
        .description("Increase Thing Count")
    }
}

extension ThingWidgetControl {
    struct Value {
        var count: Int
    }

    struct Provider: AppIntentControlValueProvider {
        func previewValue(configuration: plusButtonConfiguration) -> Value {
            ThingWidgetControl.Value(count: 1)
        }

        func currentValue(configuration: plusButtonConfiguration) async throws -> Value {
            let count = 1 // Check if the timer is running
            return ThingWidgetControl.Value(count: count)
        }
    }
}

struct plusButtonConfiguration: ControlConfigurationIntent {
    static var title: LocalizedStringResource { "Plus Button Configuration" }

    @Parameter(title: "Plus Button")
    var count: Int?
}
