# WhatsNewKit

`WhatsNewKit` is a Swift Package for iOS 18.6+ that presents a SwiftUI sheet with app release highlights.

## Usage

```swift
import SwiftUI
import WhatsNewKit

struct HomeView: View {
    private let releases = [
        WhatsNewRelease(
            version: "3",
            title: "Nova experiência de busca",
            media: WhatsNewMedia(
                url: URL(string: "https://example.com/search.png")!,
                kind: .image
            ),
            topics: [
                WhatsNewTopic(
                    title: "Resultados mais rápidos",
                    description: "A busca agora prioriza os itens mais usados."
                )
            ]
        )
    ]

    var body: some View {
        ContentView()
            .whatsNewSheet(releases: releases)
    }
}
```

The first app launch is treated as a baseline and does not present the sheet. Existing users see every release after the last presented version and up to the current app version. For example, if the last presented version was `2` and the current app version is `5`, releases `3`, `4`, and `5` are shown as sheet steps.

Presentation state is stored internally by the package using `UserDefaults`; apps do not need to provide or implement storage.

## Manual Trigger

```swift
@State private var showWhatsNew = false

var body: some View {
    ContentView()
        .toolbar {
            Button("Novidades") {
                showWhatsNew = true
            }
        }
        .whatsNewSheet(
            isTriggered: $showWhatsNew,
            releases: releases
        )
}
```

## Demo App

Open `Demo/WhatsNewKitDemo.xcodeproj` to run an iOS demo app that imports this local package and uses both presentation styles:

- automatic presentation on app launch;
- manual presentation with an "Abrir Whats New manualmente" button.
