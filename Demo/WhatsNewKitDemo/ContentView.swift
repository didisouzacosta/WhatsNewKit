import SwiftUI
import WhatsNewKit

struct ContentView: View {
    @State private var showWhatsNew = false

    private let releases = DemoReleaseCatalog.releases

    var body: some View {
        NavigationStack {
            List {
                Section("Estado do demo") {
                    LabeledContent("Versão atual", value: WhatsNewAppVersion.current)
                }

                Section("Ações") {
                    Button("Abrir Whats New manualmente") {
                        showWhatsNew = true
                    }
                }

                Section("Releases configuradas") {
                    ForEach(releases) { release in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(release.title)
                                .font(.headline)
                            Text("Versão \(release.version)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("WhatsNewKit Demo")
            .whatsNewSheet(releases: releases)
            .whatsNewSheet(
                isTriggered: $showWhatsNew,
                releases: releases
            )
        }
    }
}

enum DemoReleaseCatalog {
    static let releases = [
        WhatsNewRelease(
            version: "1.1.0",
            title: "Melhorias de onboarding",
            topics: [
                WhatsNewTopic(
                    title: "Fluxo mais curto",
                    description: "As etapas iniciais foram reorganizadas para usuários recorrentes chegarem mais rápido ao conteúdo principal.",
                    icon: .systemImage("arrow.forward.circle.fill")
                ),
                WhatsNewTopic(
                    title: "Preferências preservadas",
                    description: "A tela respeita as escolhas salvas anteriormente no app.",
                    icon: .systemImage("checkmark.seal.fill")
                ),
                WhatsNewTopic(
                    title: "Fluxo mais curto",
                    description: "As etapas iniciais foram reorganizadas para usuários recorrentes chegarem mais rápido ao conteúdo principal.",
                    icon: .systemImage("arrow.forward.circle.fill")
                ),
                WhatsNewTopic(
                    title: "Preferências preservadas",
                    description: "A tela respeita as escolhas salvas anteriormente no app.",
                    icon: .systemImage("checkmark.seal.fill")
                ),
                WhatsNewTopic(
                    title: "Preferências preservadas",
                    description: "A tela respeita as escolhas salvas anteriormente no app.",
                    icon: .systemImage("checkmark.seal.fill")
                ),
                WhatsNewTopic(
                    title: "Fluxo mais curto",
                    description: "As etapas iniciais foram reorganizadas para usuários recorrentes chegarem mais rápido ao conteúdo principal.",
                    icon: .systemImage("arrow.forward.circle.fill")
                ),
                WhatsNewTopic(
                    title: "Preferências preservadas",
                    description: "A tela respeita as escolhas salvas anteriormente no app.",
                    icon: .systemImage("checkmark.seal.fill")
                )
            ]
        ),
        WhatsNewRelease(
            version: "2.0.0",
            title: "Nova central de atividades",
            media: WhatsNewMedia(
                url: URL(string: "https://picsum.photos/seed/whatsnew-activity/1200/675")!,
                kind: .image
            ),
            topics: [
                WhatsNewTopic(
                    title: "Histórico unificado",
                    description: "Eventos importantes agora aparecem em uma única lista cronológica.",
                    icon: .systemImage("clock.arrow.circlepath")
                ),
                WhatsNewTopic(
                    title: "Filtros por contexto",
                    description: "Use filtros rápidos para encontrar mudanças por área do produto.",
                    icon: .systemImage("line.3.horizontal.decrease.circle.fill")
                )
            ]
        ),
        WhatsNewRelease(
            version: "2.5.1",
            title: "Correções e mídia no sheet",
            media: WhatsNewMedia(
                url: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!,
                kind: .video
            ),
            topics: [
                WhatsNewTopic(
                    title: "Suporte a vídeo",
                    description: "Cada versão pode apresentar uma URL de imagem ou vídeo.",
                    icon: .systemImage("play.rectangle.fill")
                ),
                WhatsNewTopic(
                    title: "Comparação semântica",
                    description: "Versões como 1.1.0, 1.0.0 e 2.5.1 são ordenadas numericamente.",
                    icon: .systemImage("number.circle.fill")
                )
            ]
        )
    ]
}

#Preview {
    ContentView()
}
