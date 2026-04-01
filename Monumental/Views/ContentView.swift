import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MainViewModel()
    @State private var selectedTab = 0
    @State private var selectedMonument: Monument?
    @State private var searchText = ""
    
    private var filteredMonuments: [Monument] {
        if searchText.isEmpty {
            return viewModel.monuments
        }
        return viewModel.monuments.filter { monument in
            monument.nom.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MapView()
                .tabItem {
                    Label("Carte", systemImage: "map.fill")
                }
                .tag(0)
            
            NavigationStack {
                MonumentListView(monuments: filteredMonuments) { monument in
                    selectedMonument = monument
                }
                .navigationTitle("Monuments")
                .searchable(text: $searchText, prompt: "Rechercher un monument")
                .navigationDestination(item: $selectedMonument) { monument in
                    MonumentDetailView(monument: monument)
                }
                .overlay {
                    if filteredMonuments.isEmpty && !searchText.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                    }
                }
            }
            .tabItem {
                Label("Liste", systemImage: "list.bullet")
            }
            .tag(1)
        }
        .tint(.black)
        .onAppear {
            viewModel.requestPermissions()
        }
    }
}

#Preview {
    ContentView()
}
