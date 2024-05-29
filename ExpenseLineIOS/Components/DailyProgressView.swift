//
//  DailyProgressView.swift
//  ExpenseLineIOS
//
//  Created by Anton Abyshev on 29.05.24.
//

import SwiftUI

struct DailyProgressView: View {
    
    var spendings: [[DaySpendings]]
    
    init(spendings: [DaySpendings]) {
        self.spendings = spendings.chunked(into: 11)
    }
    
    var body: some View {
        GeometryReader { proxy in
            VStack(alignment: .leading, spacing: 2) {
                ForEach(0..<spendings.count, id: \.self) { row in
                    HStack(spacing: 2) {
                        ForEach(0..<spendings[row].count, id: \.self) { column in
                            DayView(progress: progress(day: spendings[row][column]), width: ((proxy.size.width - 2 * 10) / 11))
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func DayView(progress: Double, width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 3, style: .circular)
            .foregroundColor(color(progress))
            .frame(width: width, height: 20)
    }
    
    private func color(_ progress: Double) -> Color {
        if progress > 1 {
            return .red.opacity(0.8)
        }
        
        return .green.opacity(progress)
    }
    
    private func progress(day: DaySpendings) -> Double {
        if day.value == 0 || day.limit == 0 {
            return 0
        }
        
        let progress = day.value / day.limit
        return Double(truncating: progress as NSDecimalNumber)
    }
 
}

#Preview {
    VStack {
        DailyProgressView(
            spendings: [
                DaySpendings(id: 1, date: Date(), value: 1, limit: 20),
                DaySpendings(id: 2, date: Date(), value: 5, limit: 20),
                DaySpendings(id: 3, date: Date(), value: 20, limit: 20),
                DaySpendings(id: 4, date: Date(), value: 25, limit: 20),
                DaySpendings(id: 5, date: Date(), value: 7, limit: 20),
                DaySpendings(id: 6, date: Date(), value: 15, limit: 20),
                DaySpendings(id: 7, date: Date(), value: 18, limit: 20),
                DaySpendings(id: 8, date: Date(), value: 17, limit: 20),
                DaySpendings(id: 9, date: Date(), value: 5, limit: 20),
                DaySpendings(id: 10, date: Date(), value: 7, limit: 20),
                DaySpendings(id: 11, date: Date(), value: 3, limit: 20),
                DaySpendings(id: 12, date: Date(), value: 6, limit: 20),
                DaySpendings(id: 13, date: Date(), value: 9, limit: 20),
                DaySpendings(id: 14, date: Date(), value: 15, limit: 20),
                DaySpendings(id: 15, date: Date(), value: 12, limit: 20),
                DaySpendings(id: 16, date: Date(), value: 14, limit: 20),
                DaySpendings(id: 17, date: Date(), value: 15, limit: 20),
                DaySpendings(id: 18, date: Date(), value: 16, limit: 20),
                DaySpendings(id: 19, date: Date(), value: 2, limit: 20),
                DaySpendings(id: 20, date: Date(), value: 6, limit: 20),
                DaySpendings(id: 21, date: Date(), value: 8, limit: 20),
                DaySpendings(id: 22, date: Date(), value: 12, limit: 20),
                DaySpendings(id: 23, date: Date(), value: 18, limit: 20),
                DaySpendings(id: 24, date: Date(), value: 17, limit: 20),
                DaySpendings(id: 25, date: Date(), value: 16, limit: 20),
                DaySpendings(id: 26, date: Date(), value: 19, limit: 20),
                DaySpendings(id: 27, date: Date(), value: 20, limit: 20),
                DaySpendings(id: 28, date: Date(), value: 25, limit: 20),
                DaySpendings(id: 29, date: Date(), value: 21, limit: 20),
                DaySpendings(id: 30, date: Date(), value: 3, limit: 20),
                DaySpendings(id: 31, date: Date(), value: 7, limit: 20)
            ]
        )
        .padding()
    }
}
