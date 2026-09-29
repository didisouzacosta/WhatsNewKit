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
                Section {
                    HomeHeader(currentVersion: viewModel.currentVersion)
                }
                .listRowBackground(Color.clear)
                .listSectionSpacing(.compact)

                presentationSection

                previewSection

                releasesSection
            }
            .navigationTitle("Demo")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                viewModel.registerInitialAccessIfNeeded()
            }
            .whatsNewSheet(
                releases: viewModel.releases,
                canPresent: viewModel.canPresentWhatsNew,
                isTriggered: $viewModel.isWhatsNewTriggered,
                currentVersion: viewModel.currentVersion,
                onEvent: viewModel.track
            )
        }
    }

    // MARK: - Private Views

    private var presentationSection: some View {
        Section {
            Toggle(isOn: $viewModel.canPresentWhatsNew) {
                Label("Automatic presentation", systemImage: "wand.and.sparkles")
            }
        } header: {
            Text("Presentation")
        } footer: {
            Text("""
            When on, releases newer than the last one seen appear automatically. \
            A new install never shows the sheet.
            """)
        }
    }

    private var previewSection: some View {
        Section {
            Button(action: viewModel.openWhatsNewManually) {
                Label("Preview all releases", systemImage: "play.rectangle.on.rectangle.fill")
                    .labelStyle(.titleAndIcon)
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
        } footer: {
            Text("Opens every configured release, including upcoming ones, without marking anything as seen.")
        }
    }

    private var releasesSection: some View {
        Section {
            ForEach(viewModel.releaseSummaries) { summary in
                ReleaseSummaryRow(summary: summary)
            }
        } header: {
            Text("Configured releases")
        } footer: {
            Text("Declared in DemoReleaseCatalog, newest first.")
        }
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel(
        currentVersion: "2.5.1",
        accessStore: DemoAccessStore(defaults: UserDefaults(suiteName: "WhatsNewKitDemo.preview") ?? .standard)
    ))
}
