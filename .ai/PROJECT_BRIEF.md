# WhatsNewKit — Brief do produto

## Identidade do produto

- Nome: WhatsNewKit.
- Plataforma: pacote Swift (SwiftPM) com UI em SwiftUI para iOS 18.6+ e
  macOS 14+, acompanhado de um app Demo somente iOS.
- Problema que resolve: apps SwiftUI precisam mostrar as novidades de cada
  versão depois de uma atualização sem reimplementar, em cada projeto, o
  controle de versões já vistas, a ordenação semântica e a UI paginada.
- Público principal: desenvolvedores de apps SwiftUI que integram o pacote via
  Swift Package Manager (`https://github.com/didisouzacosta/WhatsNewKit.git`).
- Proposta de valor: API pública pequena (modificadores `whatsNewSheet`
  automático, manual e combinado, modelos de release e um ponto de baseline),
  apresentação automática controlada pelo app hospedeiro e uma sheet paginada
  pronta, localizada e acessível.

## Experiência principal

### Fluxos

- Fluxo de entrada: o integrador declara `[WhatsNewRelease]` (versão, páginas,
  mídia opcional e tópicos) e aplica `.whatsNewSheet(releases:canPresent:)` na
  tela hospedeira. A versão atual vem de `CFBundleShortVersionString`
  (`WhatsNewAppVersion.current`) ou do parâmetro `currentVersion`.
- Fluxo principal (automático): no `onAppear` da tela hospedeira e a cada
  mudança de `canPresent`, `releases` ou `currentVersion`, a política avalia as
  releases. Na primeira avaliação de uma instalação nova (sem versão gravada ou
  com valor ilegível), a versão atual é gravada como baseline e nada é
  apresentado, mesmo com `canPresent == false`. Depois disso, com
  `canPresent == true`, são apresentadas as releases com versão maior que a
  última apresentada e menor ou igual à versão atual, em ordem semântica. O
  usuário avança com Continue/Done ou fecha pelo botão `xmark` ou pelo gesto de
  arrastar; em todos os casos a maior versão exibida é registrada.
- Fluxos alternativos:
  - Manual: `.whatsNewSheet(isTriggered:releases:)` apresenta todas as releases
    declaradas, em ordem semântica, ignorando `canPresent`, versão atual e
    histórico, e não registra nada ao fechar. O binding volta para `false` logo
    após a avaliação, inclusive quando já começa `true`.
  - Combinado: `.whatsNewSheet(releases:canPresent:isTriggered:)` hospeda uma
    única sheet para os dois fluxos.
  - Baseline explícita: `WhatsNewPresentationState.markCurrentVersionAsSeen()`
    (alias de `markCurrentVersionAsBaseline`) grava a versão atual como já vista
    sem abrir a sheet nem emitir eventos; nunca faz a versão gravada regredir.
    Não é necessária na primeira execução.
  - Armazenamento: os modificadores automático e combinado aceitam `defaults` e
    `namespace`, que devem ser os mesmos passados a
    `WhatsNewPresentationState`.
  - Analytics: o callback `onEvent` recebe `opened`, `closed` e `stepProgress`.

### Estados

- Instalação nova: nada é apresentado; a versão atual vira a baseline.
- Sem releases elegíveis ou `canPresent == false`: nada é apresentado e nada é
  registrado; a release continua pendente para uma avaliação futura.
- Apresentação ativa: nenhuma avaliação automática ou disparo manual substitui
  uma sheet já aberta no mesmo modificador; o disparo é descartado.
- Uma única página: indicador de passos oculto e botão Done.
- Várias páginas (várias releases ou várias páginas numa release): indicador de
  passos visível, botão Continue até a última página e Done na última.
- Mídia remota (imagem): placeholder enquanto carrega, duas novas tentativas
  com intervalo de 1 s e cancelamento ao sair da tela; em falha, o placeholder
  permanece.
- Mídia de vídeo: placeholder até `readyToPlay`; reprodução somente com a página
  ativa; pausa ao trocar de página ou desaparecer. Não há estado de erro
  distinto.
- Encerramento: `opened` e `closed` são emitidos no máximo uma vez por sheet.
- Interrupção: fechar a sheet pelo gesto de arrastar conclui a apresentação e
  registra a maior versão exibida, como o botão de fechar. Encerrar o app com a
  sheet aberta não registra nada, e a release volta na próxima avaliação.

## Recursos e limites

- Recursos disponíveis: apresentação automática e manual; paginação por
  release e por página; mídia por imagem (asset, URL, `UIImage` em UIKit) ou
  vídeo por URL; tópicos com SF Symbol ou imagem de bundle; indicador de passos;
  eventos de analytics; strings localizadas em ar, de, en, es, fr, hi, id, it,
  ja, ko, pt-BR, ru, zh-Hans e zh-Hant.
- Recursos premium ou condicionais: botão com `.glassProminent` somente em
  iOS 26+, com fallback `.borderedProminent`; o caso `.uiImage` só existe onde
  UIKit está disponível.
- Limites conhecidos:
  - `SemanticVersion` segue a precedência SemVer: componentes numéricos
    ausentes valem zero (`1.2` == `1.2.0`), sufixo `-` é pré-release e vem
    antes da versão final (`1.0.0-beta.2` < `1.0.0`), sufixo `+` é metadado e
    é ignorado. Versões sem nenhum dígito (por exemplo `next`) são inválidas e
    ignoradas pela política.
  - Usuários que atualizam para a primeira versão do app que adota o pacote são
    tratados como instalação nova, porque não há estado anterior para
    distingui-los.
  - O estado persistido é uma única chave,
    `<namespace>.WhatsNewKit.lastPresentedVersion`, em `UserDefaults.standard`
    por padrão ou no `defaults` informado; o namespace padrão é o bundle
    identifier do app.
  - `WhatsNewTopic` usa `UUID().uuidString` como `id` padrão; recriar tópicos a
    cada render muda a identidade das linhas.
- Recursos planejados, mas ainda não conectados: nenhum identificado no código.

## Dados e persistência

- Modelos: `WhatsNewRelease`, `WhatsNewPage`, `WhatsNewTopic`,
  `WhatsNewTopicIcon`, `WhatsNewMedia` (`ImageSource`), `WhatsNewPresentation`
  e `WhatsNewAnalyticsEvent` (públicos); `WhatsNewPresentationStep`,
  `WhatsNewPresentationTrigger` e `SemanticVersion` (internos).
- Fonte primária dos dados: releases declaradas pelo app integrador em código.
- Armazenamento local: `UserDefaultsWhatsNewStorage`, com namespace padrão igual
  ao bundle identifier do app.
- Sincronização ou serviços externos: nenhum serviço próprio. A mídia remota é
  baixada das URLs fornecidas pelo integrador; imagens usam Kingfisher 8.9.0
  (cache e retry) e vídeo usa AVKit.
- Regras de migração e recuperação: não há migração de esquema. Uma versão
  gravada ilegível é tratada como instalação nova e substituída pela versão
  atual. A versão gravada nunca regride.

## Validação

- Validações concluídas (2026-09-29, Xcode 27.0, Swift 6.4):
  - `swift test`: 58 testes em 11 suítes passando (macOS, Swift Testing).
  - `swift build --build-tests`: sem avisos.
  - `xcodebuild` do Demo para `generic/platform=iOS Simulator`: build sem erros
    nem avisos; o pacote compila para iOS nesse build.
  - `scripts/lint-swift.sh`: 0 violações em 53 arquivos.
  - Simulator (iPhone 16): instalação nova sem sheet e baseline `2.5.1`
    gravada; com versão gravada `2.0.0`, sheet somente com a `2.5.1`; dismiss
    por gesto gravou `2.5.1` e a sheet não voltou ao reabrir; sheet manual com
    as três releases fechada pelo `xmark` sem alterar a versão gravada.
- Validações pendentes: macOS em execução, vídeo e imagens remotas, Dynamic
  Type, VoiceOver e iOS 26+ com Liquid Glass versus fallback em iOS 18.6.
- Condições de hardware, conta ou serviço: reprodução de vídeo e carregamento de
  imagens remotas dependem de rede e das URLs de exemplo do Demo; nenhum
  comportamento foi validado em dispositivo físico.

## Mapa de fontes

- API pública de apresentação:
  `Sources/WhatsNewKit/Features/SheetPresentation/View+WhatsNewSheet.swift`.
- Apresentação automática e manual:
  `WhatsNewPresentationModifier` e `WhatsNewPresentationViewModel` em
  `Features/SheetPresentation/`.
- Regras de elegibilidade e registro:
  `Core/Presentation/WhatsNewPresentationPolicy.swift` e `SemanticVersion.swift`.
- Baseline pública: `Core/Presentation/WhatsNewPresentationState.swift`.
- Persistência: `Core/Persistence/UserDefaultsWhatsNewStorage.swift`.
- Sheet e componentes: `Features/WhatsNewSheet/WhatsNewSheet.swift`,
  `WhatsNewSheetViewModel.swift` e `Features/WhatsNewSheet/Components/`.
- Strings: `Core/Localization/WhatsNewLocalized.swift` e
  `Resources/Localizable.xcstrings`.
- Demo: `Demo/Sources/Features/Home/` (tela e ViewModel) e
  `Demo/Sources/Core/Data/DemoReleaseCatalog.swift`.

## Pendências e decisões

- Decisão (2026-09-29): instalação nova grava a versão atual como baseline sem
  apresentar; o dismiss por gesto registra como o botão de fechar; a
  apresentação manual não registra; a versão gravada nunca regride. Cobertura
  em `WhatsNewPresentationPolicyBaselineTests`,
  `WhatsNewPresentationViewModelTests` e `SemanticVersionTests`.
- Pendência: `WhatsNewVideoView` cria um `AVPlayerItem` em cada `init`, mesmo
  quando o `@State` já existe.
  - Risco: trabalho descartado a cada re-render do pai.
  - Próximo passo: mover a criação do player para um modelo com ciclo de vida
    explícito e medir antes/depois.
- Decisão: a estrutura segue `Core/`, `Features/` e `Resources/` dentro do
  target SwiftPM, e o Demo segue `Sources/App`, `Sources/Core`,
  `Sources/Features` e `Resources` com pastas sincronizadas no Xcode.
