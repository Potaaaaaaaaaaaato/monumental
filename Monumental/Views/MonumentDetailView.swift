import SwiftUI

struct MonumentDetailView: View {
    @StateObject private var viewModel: MonumentDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(monument: Monument) {
        _viewModel = StateObject(wrappedValue: MonumentDetailViewModel(monument: monument))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                Divider()
                descriptionSection
                Divider()
                historicalContext
                Divider()
                detailsSection
                if viewModel.monument.transports != nil {
                    Divider()
                    transportsSection
                }
                directionsButton
            }
            .padding()
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.monument.localizedName)
                .font(.title)
                .fontWeight(.bold)
            
            Text(viewModel.formattedCategories)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            if let distance = viewModel.distance {
                Label(distance, systemImage: "location.fill")
                    .font(.subheadline)
                    .foregroundStyle(.blue)
            }
        }
    }
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("detail.section.description")
                .font(.headline)
            
            Text(viewModel.monument.description)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
    
    private var historicalContext: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("detail.section.historical_context")
                .font(.headline)
            
            Text(viewModel.monument.contexteHistorique)
                .font(.body)
                .foregroundStyle(.secondary)
        }
    }
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("detail.section.information")
                .font(.headline)
            
            DetailRow(icon: "calendar", label: String(localized: "detail.info.construction"), value: viewModel.monument.dateConstruction)
            DetailRow(icon: "person.fill", label: String(localized: "detail.info.architect"), value: viewModel.monument.architecte)
            DetailRow(
                icon: "mappin.circle.fill",
                label: String(localized: "detail.info.arrondissement"),
                value: LocalizationFormatter.arrondissement(viewModel.monument.arrondissement)
            )
        }
    }
    
    private var transportsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("detail.section.transport")
                .font(.headline)
            
            if let transports = viewModel.monument.transports {
                if let metro = transports.metro, !metro.isEmpty {
                    TransportTypeView(
                        icon: "tram.fill",
                        title: String(localized: "transport.metro"),
                        color: .blue,
                        lines: metro,
                        transportType: .metro
                    )
                }
                
                if let rer = transports.rer, !rer.isEmpty {
                    TransportTypeView(
                        icon: "train.side.front.car",
                        title: String(localized: "transport.rer"),
                        color: .purple,
                        lines: rer,
                        transportType: .rer
                    )
                }
                
                if let bus = transports.bus, !bus.isEmpty {
                    TransportSimpleView(
                        icon: "bus.fill",
                        title: String(localized: "transport.bus"),
                        color: .green,
                        lines: bus
                    )
                }
                
                if let tramway = transports.tramway, !tramway.isEmpty {
                    TransportTypeView(
                        icon: "tram",
                        title: String(localized: "transport.tramway"),
                        color: .red,
                        lines: tramway,
                        transportType: .other
                    )
                }
                
                if let noctilien = transports.noctilien, !noctilien.isEmpty {
                    TransportSimpleView(
                        icon: "moon.fill",
                        title: String(localized: "transport.noctilien"),
                        color: .indigo,
                        lines: noctilien
                    )
                }
            }
        }
    }
    
    private var directionsButton: some View {
        Button {
            viewModel.openInMaps()
        } label: {
            Label("detail.action.directions.apple_maps", systemImage: "map.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.black)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.top)
    }
}

struct TransportTypeView: View {
    let icon: String
    let title: String
    let color: Color
    let lines: [TransportLine]
    let transportType: TransportType
    
    enum TransportType {
        case metro
        case rer
        case other
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(color)
            
            ForEach(lines, id: \.station) { line in
                HStack {
                    Text(line.station)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    HStack(spacing: 4) {
                        ForEach(line.lignes, id: \.self) { ligne in
                            Text(ligne)
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .frame(width: 26, height: 26)
                                .background(lineColor(for: ligne))
                                .clipShape(Circle())
                        }
                    }
                }
            }
        }
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func lineColor(for ligne: String) -> Color {
        switch transportType {
        case .metro:
            return TransportColors.metro(ligne)
        case .rer:
            return TransportColors.rer(ligne)
        case .other:
            return color
        }
    }
}

struct TransportSimpleView: View {
    let icon: String
    let title: String
    let color: Color
    let lines: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(color)
            
            FlowLayout(spacing: 6) {
                ForEach(lines, id: \.self) { line in
                    Text(line)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(color)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY), proposal: .init(frame.size))
        }
    }
    
    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        let maxWidth = proposal.width ?? .infinity
        var frames: [CGRect] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        
        return (CGSize(width: maxWidth, height: y + rowHeight), frames)
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundStyle(.secondary)
            
            Text(label)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}

#Preview {
    MonumentDetailView(monument: .preview)
}
