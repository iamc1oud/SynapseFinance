import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), netWorth: "$0.00", lastUpdated: "Tap to refresh")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), netWorth: "$0.00", lastUpdated: "Tap to refresh")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let userDefaults = UserDefaults(suiteName: "group.com.example.synapseFinance")
        let netWorthFormatted = userDefaults?.string(forKey: "net_worth_formatted") ?? "$0.00"
        let lastUpdatedString = userDefaults?.string(forKey: "last_updated")
        
        var lastUpdatedText = "Tap to refresh"
        if let lastUpdatedString = lastUpdatedString,
           let lastUpdatedDate = ISO8601DateFormatter().date(from: lastUpdatedString) {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd, HH:mm"
            lastUpdatedText = "Updated: \(formatter.string(from: lastUpdatedDate))"
        }
        
        let currentDate = Date()
        let entry = SimpleEntry(
            date: currentDate,
            netWorth: netWorthFormatted,
            lastUpdated: lastUpdatedText
        )

        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let netWorth: String
    let lastUpdated: String
}

struct SynapseFinanceWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "creditcard.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 16))
                
                Text("Synapse Finance")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Net Worth")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                Text(entry.netWorth)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            HStack {
                Spacer()
                Text(entry.lastUpdated)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .widgetURL(URL(string: "synapseFinance://refresh"))
    }
}

@main
struct SynapseFinanceWidget: Widget {
    let kind: String = "SynapseFinanceWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SynapseFinanceWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Net Worth")
        .description("View your total net worth at a glance")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}