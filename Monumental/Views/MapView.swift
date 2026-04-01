import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var showingDetail = false
    @State private var showingSearch = false
    @State private var searchText = ""

    private var filteredMonuments: [Monument] {
        let query = searchText.normalizedForSearch
        if query.isEmpty {
            return viewModel.monuments
        }
        return viewModel.monuments.filter { monument in
            monument.nom.normalizedForSearch.contains(query)
                || monument.localizedName.normalizedForSearch.contains(query)
        }
    }

    var body: some View {
        Map(
            coordinateRegion: $viewModel.region,
            showsUserLocation: true,
            annotationItems: viewModel.annotations + viewModel.stationAnnotations.map { AnnotationWrapper.station($0) }
        ) { wrapper in
            MapAnnotation(coordinate: wrapper.coordinate) {
                switch wrapper {
                case .monument(let annotation):
                    MonumentMarker(annotation: annotation) {
                        viewModel.selectMonument(annotation.monument)
                        showingDetail = true
                    }
                case .station(let station):
                    StationMarker(station: station)
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .overlay(alignment: .topTrailing) {
            HStack(spacing: 12) {
                Button {
                    showingSearch = true
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .medium))
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .accessibilityLabel("map.action.search.accessibility_label")

                Button {
                    viewModel.showAllMonuments()
                } label: {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 18, weight: .medium))
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .accessibilityLabel("map.action.show_all.accessibility_label")
            }
            .padding()
        }
        .sheet(isPresented: $showingSearch) {
            NavigationStack {
                MonumentListView(monuments: filteredMonuments) { monument in
                    showingSearch = false
                    searchText = ""
                    viewModel.selectMonument(monument)
                    DispatchQueue.main.async {
                        showingDetail = true
                    }
                }
                .navigationTitle("map.search.navigation.title")
                .searchable(text: $searchText, prompt: "search.monument.prompt")
                .overlay {
                    if filteredMonuments.isEmpty && !searchText.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("common.close") {
                            showingSearch = false
                            searchText = ""
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingDetail) {
            if let monument = viewModel.selectedMonument {
                MonumentDetailView(monument: monument)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
    }
}

enum AnnotationWrapper: Identifiable {
    case monument(MonumentAnnotation)
    case station(StationAnnotation)

    var id: UUID {
        switch self {
        case .monument(let annotation): return annotation.id
        case .station(let station): return station.id
        }
    }

    var coordinate: CLLocationCoordinate2D {
        switch self {
        case .monument(let annotation): return annotation.coordinate
        case .station(let station): return station.coordinate
        }
    }
}

extension Array where Element == MonumentAnnotation {
    static func + (lhs: [MonumentAnnotation], rhs: [AnnotationWrapper]) -> [AnnotationWrapper] {
        lhs.map { AnnotationWrapper.monument($0) } + rhs
    }
}

struct MonumentMarker: View {
    let annotation: MonumentAnnotation
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(.black)
                    .clipShape(Circle())

                Image(systemName: "triangle.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(.black)
                    .rotationEffect(.degrees(180))
                    .offset(y: -3)
            }
        }
    }
}

struct StationMarker: View {
    let station: StationAnnotation

    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 2) {
                ForEach(station.lignes.prefix(3), id: \.self) { ligne in
                    Text(ligne)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 20, height: 20)
                        .background(colorForLine(ligne))
                        .clipShape(Circle())
                }
            }

            Text(station.station)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.primary)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }

    private func colorForLine(_ ligne: String) -> Color {
        switch station.type {
        case .metro:
            return TransportColors.metro(ligne)
        case .rer:
            return TransportColors.rer(ligne)
        case .tramway:
            return .red
        }
    }
}

#Preview {
    MapView()
}
