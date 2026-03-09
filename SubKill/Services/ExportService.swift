import Foundation

enum ExportService {
    static func generateCSV(from subscriptions: [Subscription]) -> String {
        var csv = "Name,Status,Price,Currency,Billing Cycle,Monthly Cost,Yearly Cost,Category,Start Date,Next Renewal,Cancelled Date,Notes\n"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        for sub in subscriptions.sorted(by: { $0.name < $1.name }) {
            let status = sub.isActive ? "Active" : "Cancelled"
            let price = NSDecimalNumber(decimal: sub.price).doubleValue
            let monthly = NSDecimalNumber(decimal: sub.monthlyPrice).doubleValue
            let yearly = NSDecimalNumber(decimal: sub.yearlyPrice).doubleValue
            let cancelDate = sub.cancelledDate.map { dateFormatter.string(from: $0) } ?? ""
            let notes = sub.notes.replacingOccurrences(of: ",", with: ";").replacingOccurrences(of: "\n", with: " ")

            csv += "\"\(sub.name)\",\(status),\(String(format: "%.2f", price)),\(sub.currency.rawValue),\(sub.billingCycle.rawValue),\(String(format: "%.2f", monthly)),\(String(format: "%.2f", yearly)),\(sub.category.rawValue),\(dateFormatter.string(from: sub.startDate)),\(dateFormatter.string(from: sub.nextRenewalDate)),\(cancelDate),\"\(notes)\"\n"
        }

        return csv
    }

    static func saveCSVToTempFile(_ csv: String) -> URL? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let fileName = "SubKill-Export-\(dateFormatter.string(from: .now)).csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try csv.write(to: tempURL, atomically: true, encoding: .utf8)
            return tempURL
        } catch {
            return nil
        }
    }
}
