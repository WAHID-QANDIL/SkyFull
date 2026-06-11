import SwiftUI

// MARK: - LocationSearchView

struct LocationSearchView: View {
    @ObservedObject var viewModel: WeatherViewModel
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List {

                // ── Live search results ───────────────────────────────
                if !viewModel.searchResults.isEmpty {
                    Section("Search Results") {
                        ForEach(viewModel.searchResults) { result in
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(result.name)
                                        .font(.body)
                                    Text(result.displayName)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Button {
                                    viewModel.addLocation(result, context: context)
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .imageScale(.large)
                                        .foregroundStyle(.blue)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                // ── Saved locations ───────────────────────────────────
                Section {
                    if viewModel.savedLocations.isEmpty {
                        ContentUnavailableView(
                            "No Saved Locations",
                            systemImage: "location.slash",
                            description: Text("Search for a city and tap + to save it.")
                        )
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(viewModel.savedLocations) { loc in
                            NavigationLink {
                                LocationDetailView(location: loc)
                            } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(loc.name)
                                        .font(.body)
                                    Text(loc.country)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete { offsets in
                            for idx in offsets {
                                viewModel.removeLocation(
                                    viewModel.savedLocations[idx],
                                    context: context
                                )
                            }
                        }
                    }
                } header: {
                    Text("Saved Locations")
                }
            }
            .searchable(text: $searchText, prompt: "Search for a city…")
            .onChange(of: searchText) { _, newValue in
                viewModel.search(query: newValue)
            }
            .overlay {
                if viewModel.isSearching {
                    ProgressView("Searching…")
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .navigationTitle("Locations")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
            }
            .onAppear {
                viewModel.refreshSavedLocations(context: context)
            }
        }
    }
}
