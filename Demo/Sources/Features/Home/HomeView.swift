import SwiftUI
import WhatsNewKit

struct HomeView: View {

    // MARK: - Private Properties

    @State private var viewModel: HomeViewModel

    // MARK: - Initializer

    init(viewModel: HomeViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            List {
                Section("Demo status") {
                    LabeledContent("Current version", value: viewModel.currentVersion)
                    Toggle("Allow automatic What's New", isOn: $viewModel.canPresentWhatsNew)
                }

                Section("Actions") {
                    Button("Open What's New manually", action: viewModel.openWhatsNewManually)
                }

                Section("Configured releases") {
                    ForEach(viewModel.releases) { release in
                        ReleaseSummaryRow(release: release)
                    }
                }
            }
            .navigationTitle("WhatsNewKit Demo")
            .task {
                viewModel.registerInitialAccessIfNeeded()
            }
            .whatsNewSheet(
                releases: viewModel.releases,
                canPresent: viewModel.canPresentWhatsNew,
                currentVersion: viewModel.currentVersion,
                onEvent: viewModel.track
            )
            .whatsNewSheet(
                isTriggered: $viewModel.isWhatsNewTriggered,
                releases: viewModel.releases,
                currentVersion: viewModel.currentVersion,
                onEvent: viewModel.track
            )
        }
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel(
        currentVersion: "2.5.1",
        accessStore: DemoAccessStore(defaults: UserDefaults(suiteName: "WhatsNewKitDemo.preview") ?? .standard)
    ))
}
