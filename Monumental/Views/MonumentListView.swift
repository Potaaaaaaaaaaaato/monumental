import SwiftUI

struct MonumentListView: View {
    let monuments: [Monument]
    let onSelect: (Monument) -> Void
    
    var body: some View {
        List(monuments) { monument in
            Button {
                onSelect(monument)
            } label: {
                MonumentRow(monument: monument)
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
    }
}

struct MonumentRow: View {
    let monument: Monument
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "building.columns.fill")
                .font(.system(size: 24))
                .foregroundStyle(.primary)
                .frame(width: 50, height: 50)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(monument.nom)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text("\(monument.arrondissement)e arrondissement")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}

#Preview {
    MonumentListView(monuments: [.preview]) { _ in }
}
