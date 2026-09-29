# Guia de arquitetura e desenvolvimento de WhatsNewKit

## Escopo e fontes de verdade

WhatsNewKit é um produto de biblioteca SwiftUI distribuída via Swift Package
Manager, para apresentar as novidades de cada versão de um app iOS/macOS.

As fontes deste checkout são, nesta ordem:

- AGENTS.md — regras de engenharia, coordenação e validação.
- PROJECT_BRIEF.md — produto, fluxos, estados e pendências.
- README.md — requisitos públicos e comandos.
- Código e configuração existentes — comportamento efetivamente conectado.

Não trate um tipo, string, pacote ou serviço sem callsite de produção como uma
feature disponível. Não faça migrações de nomes, pastas ou arquitetura sem
escopo explícito.

A API pública (`whatsNewSheet`, `WhatsNewSheet`, modelos, `WhatsNewAppVersion`
e `WhatsNewPresentationState`) é um contrato com apps de terceiros: qualquer
mudança de assinatura, semântica ou chave de `UserDefaults` exige decisão
explícita e nota no README.

## Baseline efetiva

- Plataforma e versão mínima: iOS 18.6 e macOS 14 (`Package.swift`); Demo iOS
  18.6, iPhone e iPad.
- Projeto/workspace: `Package.swift` na raiz; app de exemplo em
  `Demo/WhatsNewKitDemo.xcodeproj`, que referencia o pacote local (`..`).
- Schemes ou targets: produto `WhatsNewKit`; targets `WhatsNewKit` e
  `WhatsNewKitTests`; scheme `WhatsNewKitDemo`.
- Linguagem e versão: `swift-tools-version: 6.0`, Swift 6 language mode no
  pacote (padrão das tools 6.0) e `SWIFT_VERSION = 6.0` no Demo. Sem
  `defaultIsolation`, `SWIFT_DEFAULT_ACTOR_ISOLATION`,
  `SWIFT_STRICT_CONCURRENCY` explícito ou upcoming features; o isolamento é
  declarado tipo a tipo. Toolchain validado: Xcode 27.0, Swift 6.4. O CI de
  lint usa Xcode 26.6.
- Dependências permitidas: Kingfisher 8.9.0+ (imagens remotas), já aprovada e
  usada somente em `WhatsNewMediaView`. Novas dependências exigem aprovação
  explícita.
- Requisitos de hardware: nenhum além do Simulator; vídeo e imagens remotas
  exigem rede.

## Coordenação dos subagentes

Use os papéis definidos no `AGENTS.md` e detalhados no
`.ai/CODEX_ORCHESTRATOR.md`:

- Planejamento: `sol` (papel conceitual Manager), somente leitura.
- Implementação e correções: `luna` (papel conceitual Developer).
- Revisão: `sol` (papel conceitual Manager), somente leitura.

O ciclo é Manager planeja → Developer implementa e valida → Manager revisa →
Developer corrige → Manager revisa novamente até resolver todos os apontamentos.
Os IDs técnicos vêm do campo `name` dos TOML compartilhados. Confira os valores
de modelo e esforço que o runtime expõe contra esses TOML; bloqueie se forem
divergentes e declare a limitação quando a ferramenta não expuser esses dados.

## Arquitetura

O target SwiftPM adapta a estrutura do `SWIFT_REFERENCE.md` a uma biblioteca:
não há `App/`, porque a composição acontece no app integrador.

```text
Sources/WhatsNewKit/
├── Core/
│   ├── Localization/   WhatsNewLocalized (strings do bundle .module)
│   ├── Models/         modelos públicos e WhatsNewPresentationStep
│   ├── Persistence/    WhatsNewStorage e UserDefaultsWhatsNewStorage
│   ├── Platform/       WhatsNewAppVersion
│   └── Presentation/   política, SemanticVersion, trigger e baseline pública
├── Features/
│   ├── SheetPresentation/  modificadores públicos + WhatsNewPresentationViewModel
│   └── WhatsNewSheet/      WhatsNewSheet, WhatsNewSheetViewModel, layout,
│                           fixtures de preview e Components/
└── Resources/          Localizable.xcstrings
Tests/WhatsNewKitTests/
├── Core/               Models, Persistence, Presentation
├── Features/           SheetPresentation, WhatsNewSheet
└── Support/            dublês compartilhados (InMemoryWhatsNewStorage)
Demo/
├── Sources/App/        WhatsNewKitDemoApp (composição do HomeViewModel)
├── Sources/Core/       Data (DemoReleaseCatalog), Persistence (DemoAccessStore)
├── Sources/Features/   Home (HomeView, HomeViewModel, Components)
└── Resources/          AppIcon.icon
```

- Entrada e composição: os modificadores em
  `Features/SheetPresentation/View+WhatsNewSheet.swift`. Cada modificador cria
  seu `WhatsNewPresentationViewModel` com `UserDefaultsWhatsNewStorage` padrão;
  testes injetam `WhatsNewStorage`. No Demo, `WhatsNewKitDemoApp` compõe o
  `HomeViewModel`.
- Domínio: `WhatsNewPresentationPolicy` (funções puras sobre releases, versão e
  storage) e `SemanticVersion`.
- Features: `WhatsNewSheet` (View pública) + `WhatsNewSheetViewModel` (passo
  selecionado, indicador, eventos). Componentes puramente visuais recebem
  valores prontos e closures, sem ViewModel próprio.
- Infraestrutura: `UserDefaultsWhatsNewStorage`; Kingfisher para imagens
  remotas; AVKit para vídeo.
- Componentes compartilhados: `Features/WhatsNewSheet/Components/`
  (pager, footer, página, mídia, vídeo, tópicos, indicador, estilo de botão).
- Testes: Swift Testing, espelhando `Core/` e `Features/`.

## Estado, concorrência e efeitos

- Fonte de verdade de cada estado:
  - apresentação ativa: `WhatsNewPresentationViewModel.activePresentation`
    (um por modificador), ligado a `.sheet(item:)`;
  - passo selecionado e eventos já emitidos: `WhatsNewSheetViewModel`;
  - última versão apresentada: `UserDefaults` via `WhatsNewStorage`;
  - estado do player: `@State` local de `WhatsNewVideoView`.
- Isolamento de atores e tarefas: ViewModels são `@MainActor @Observable`,
  mantidos em `@State` pela View dona. Modelos públicos são value types
  `Sendable` sem `@unchecked`. `WhatsNewStorage` não é `Sendable` e só é usado
  no ator principal pelos ViewModels. Não há `Task` não estruturada.
- Cancelamento e invalidação de resultados obsoletos: download de imagem
  cancelado ao desaparecer (`cancelOnDisappear`); vídeo pausado ao desaparecer
  ou ao deixar de ser a página ativa; `opened`/`closed` protegidos contra
  emissão duplicada.
- Limites de memória e trabalho pendente: cache do Kingfisher com política
  padrão; `WhatsNewVideoView` cria um `AVPlayerItem` por `init` (pendência no
  brief).
- Permissões, rede, arquivos e outros efeitos: sem permissões. Rede apenas para
  URLs de mídia do integrador. Escrita somente da chave de última versão.

## Regras de implementação

- Injete serviços e protocolos nas fronteiras de comportamento.
- Use dublês nos testes e nas previews.
- Preserve cancelamento, isolamento e tratamento de erros.
- Não adicione dependências sem aprovação explícita.
- Mantenha segredos fora do repositório.
- Preserve alterações locais não relacionadas.
- Regras de elegibilidade ficam em `WhatsNewPresentationPolicy`; os ViewModels
  só as orquestram. Toda mudança nessas regras começa por um teste em
  `Tests/WhatsNewKitTests/Core/Presentation/` ou nos testes dos ViewModels.
- Strings visíveis passam por `WhatsNewLocalized` e são adicionadas ao
  `Localizable.xcstrings` em todos os idiomas existentes.
- Modelos, constantes de layout e fixtures ficam em arquivos próprios, fora dos
  arquivos que declaram `View`.
- Exceção declarada ao padrão MVVM do `swiftui-view-refactor`: o
  `SWIFT_REFERENCE.md` prevalece; componentes com estado ou regras usam
  ViewModel, componentes puramente visuais não.

## Estilo e formatação Swift

- Convenção geral: [Google Swift Style Guide](https://google.github.io/swift/),
  com a exceção declarada de 4 espaços e 120 colunas, aplicada a todo código Swift, incluindo testes.
- Cadeias de modificadores SwiftUI: cada modificador em sua própria linha,
  conforme os exemplos da Apple em
  [Configuring Views](https://developer.apple.com/documentation/swiftui/configuring-views).
- `MARK:` obrigatório e espaçamento entre blocos conforme `SWIFT_REFERENCE.md`.
- Bootstrap/update sincronizam `.swiftlint.yml`, `.swiftformat`, `scripts/lint-swift.sh` e `scripts/fix-swift-spacing.pl` com manifesto e proteção de conflitos.
- Baseline desta base: SwiftLint 0.63.2 e SwiftFormat 0.63.0; confirme a instalação no consumidor e no CI.
- `scripts/lint-swift.sh` é o gate executável local/CI, verifica versões e cobre somente fontes, testes e `Package.swift` nos caminhos do consumidor. Conecte esse comando ao job obrigatório de CI do projeto.
- Bootstrap/update também sincronizam `.github/workflows/swift-lint.yml`; o workflow da base fica em arquivo separado porque esta base não contém Swift.
- Formate desde a criação: `scripts/lint-swift.sh --fix`; rascunhe MARKs ausentes com `scripts/lint-swift.sh --add-marks` e revise os nomes.
- Ferramentas: `brew install swiftlint swiftformat` ou `scripts/install-swift-tools.sh` (versões fixas, usado no CI/Xcode Cloud).
- Fase de build do Xcode (target sem sandbox de scripts): `scripts/lint-swift.sh --format-only`.
- Cobertura neste projeto: `Sources/`, `Tests/`, `Package.swift` e
  `Demo/Sources/` (52 arquivos em 2026-09-29). O Demo só é coberto porque seu
  código fica em `Demo/Sources`; não mova código Swift para fora dessa pasta.
- O Demo não tem fase de build de lint (`ENABLE_USER_SCRIPT_SANDBOXING = YES`);
  o gate roda pela linha de comando e pelo workflow `.github/workflows/swift-lint.yml`.
- Exceções locais justificadas: nenhuma supressão de SwiftLint. O SwiftFormat
  indenta os modificadores após `#endif` em `WhatsNewSheet.swift`; esse é o
  layout canônico da ferramenta e não deve ser corrigido à mão.
- `WhatsNewSheetSourceTests` lê o código-fonte como texto e depende dos caminhos
  `Features/WhatsNewSheet/WhatsNewSheet.swift` e
  `Features/WhatsNewSheet/Components/WhatsNewReleasePage.swift`; atualize-o ao
  mover esses arquivos.

## Previews SwiftUI

- Toda `View` criada deve ter `#Preview` para cada estado de apresentação
  suportado, incluindo os estados de carregamento, vazio, erro e sucesso quando
  fizerem parte do contrato da tela.
- Use `@Previewable` em cada propriedade dinâmica local necessária para
  configurar esses estados dentro do corpo de `#Preview`. Esse macro só é
  válido nesse corpo e não substitui a declaração dos previews para cada estado.
- Injete dados e dependências determinísticos; não conecte previews a serviços
  reais, rede, autenticação ou arquivos mutáveis do usuário.
- Convenção confirmada com a documentação da Apple:
  [Previewable](<https://developer.apple.com/documentation/swiftui/previewable()>).
- Fixtures do pacote: `Features/WhatsNewSheet/WhatsNewPreviewFixtures.swift`
  (`#if DEBUG`, IDs estáveis, sem mídia remota). No Demo, a preview da Home usa
  um `UserDefaults` de suíte própria.
- Exceções: `WhatsNewMediaView` e `WhatsNewVideoView` não têm preview porque o
  conteúdo real depende de URL remota ou asset do app integrador; seus estados
  de placeholder são cobertos pela preview de `WhatsNewMediaPlaceholder`.

## Testes e validação

Registre comandos e resultados reais. Separe compilação e Simulator de
validação em dispositivo físico e de serviços externos.

- Testes unitários: `swift test` — 39 testes em 9 suítes passando em
  2026-09-29 (macOS, Xcode 27.0, Swift 6.4).
- Testes de integração: não há; `WhatsNewPresentationStatePublicAPITests` usa
  uma suíte `UserDefaults` descartável.
- Build: `swift build` (macOS, sem avisos) e
  `xcodebuild -project Demo/WhatsNewKitDemo.xcodeproj -scheme WhatsNewKitDemo -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build`
  (sem erros nem avisos; compila o pacote para iOS).
- Simulator: não executado interativamente.
- Dispositivo físico: não validado.
- Serviços live: não se aplica; mídia remota do Demo não foi validada.
- Validações ainda não executadas: fluxos no Simulator (automático, manual,
  dismiss por gesto, vídeo), macOS em execução, VoiceOver, Dynamic Type e
  Liquid Glass em iOS 26+ versus fallback.

## Entrega

- Checklist de aceitação: `swift test` verde; `scripts/lint-swift.sh` sem
  violações; build do Demo para iOS Simulator sem avisos; API pública
  inalterada ou documentada no README; brief atualizado quando fluxos, estados
  ou pendências mudarem.
- Arquivos de documentação a atualizar: `README.md` (API e exemplos),
  `.ai/PROJECT_BRIEF.md` (comportamento e pendências) e este guia (estrutura,
  comandos e validações).
- Artefatos temporários a limpar: DerivedData passado por `-derivedDataPath`
  em diretório temporário da tarefa; `.build/` do SwiftPM é cache incremental
  compartilhado e deve ser preservado.
- Estado de commit esperado: commits separados para configuração da base,
  reorganização/formatação mecânica e mudanças de comportamento.
- Riscos conhecidos: ver Pendências no brief (dismiss por gesto, registro de
  versões futuras no fluxo manual, criação de `AVPlayerItem` por `init`).
