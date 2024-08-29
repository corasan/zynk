//
//  Badge.swift
//  Zynk
//
//  Created by Henry on 8/29/24.
//

import SwiftUI

enum BadgeType {
    case development
    case `internal`
    case store
}

struct Badge: View {
    var text: String
    var icon: String
    var badgeType: BadgeType
    var badgeColor: Color {
        switch badgeType {
        case .development:
            return Color.orange
        case .internal:
            return Color.purple
        case .store:
            return Color.blue
        }
    }
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: icon)
                .font(.footnote)
            Text(text)
                .font(.caption2)
                .padding(.leading, 4)
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(badgeColor.opacity(0.2))
        .clipShape(Capsule())
    }
}

#Preview {
    Badge(text: "development", icon: "bell", badgeType: .development)
}
