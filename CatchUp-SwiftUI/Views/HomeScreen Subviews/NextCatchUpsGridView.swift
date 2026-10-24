//
//  NextCatchUpsGridView.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 3/24/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import SwiftUI

struct NextCatchUpsGridView: View {
    let nextCatchUps: [SelectedContact]
    @Binding var selection: SelectedContact?

    /// The narrowest a cell can be and still show a name and time legibly.
    /// It grows with the text size, so large text also drops to one column.
    @ScaledMetric(relativeTo: .headline) private var minimumCellWidth = 160
    @State private var fitsTwoColumns = true

    private nonisolated static let spacing: CGFloat = 10
    private static let twoColumns = [GridItem(.flexible(), spacing: spacing), GridItem(.flexible())]
    private static let oneColumn = [GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: fitsTwoColumns ? Self.twoColumns : Self.oneColumn, spacing: Self.spacing) {
            ForEach(nextCatchUps) { contact in
                NextCatchUpsGridCell(contact: contact, selection: $selection)
            }
        }
        // Use one column when the width can't fit two, such as in a narrow sidebar.
        .onGeometryChange(for: Bool.self) { [twoColumnWidth = minimumCellWidth * 2 + Self.spacing] proxy in
            proxy.size.width >= twoColumnWidth
        } action: { fitsTwoColumns in
            self.fitsTwoColumns = fitsTwoColumns
        }
        .padding(.bottom, 5)
        .padding(.horizontal, 4)
        .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 0))
        .listRowBackground(Color.clear)
    }
}

#Preview {
    List {
        NextCatchUpsGridView(
            nextCatchUps: [.sampleData, .sampleData, .sampleData],
            selection: .constant(nil)
        )
    }
}
