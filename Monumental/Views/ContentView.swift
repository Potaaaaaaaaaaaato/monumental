import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MainViewModel()
    @State private var selectedTab = 0
    @State private var selectedMonument: Monument?
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
        TabView(selection: $selectedTab) {
            MapView()
                .tabItem {
                    Label("tab.map.title", systemImage: "map.fill")
                }
                .tag(0)
            
            NavigationStack {
                MonumentListView(monuments: filteredMonuments) { monument in
                    selectedMonument = monument
                }
                .navigationTitle("list.navigation.title")
                .searchable(text: $searchText, prompt: "search.monument.prompt")
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
                Label("tab.list.title", systemImage: "list.bullet")
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
