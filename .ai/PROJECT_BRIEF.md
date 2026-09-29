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
- Proposta de valor: API pública pequena (dois modificadores `whatsNewSheet`,
  modelos de release e um ponto de baseline), apresentação automática
  controlada pelo app hospedeiro e uma sheet paginada pronta, localizada e
  acessível.

## Experiência principal

### Fluxos

- Fluxo de entrada: o integrador declara `[WhatsNewRelease]` (versão, páginas,
  mídia opcional e tópicos) e aplica `.whatsNewSheet(releases:canPresent:)` na
  tela hospedeira. A versão atual vem de `CFBundleShortVersionString`
  (`WhatsNewAppVersion.current`) ou do parâmetro `currentVersion`.
- Fluxo principal (automático): no `onAppear` da tela hospedeira e a cada
  mudança de `canPresent`, a política seleciona as releases com versão maior
  que a última apresentada e menor ou igual à versão atual, em ordem
  semântica. Com `canPresent == true` e ao menos uma release pendente, a sheet
  é apresentada. O usuário avança com Continue/Done ou fecha pelo botão `xmark`;
  em ambos os casos a maior versão exibida é registrada como a última
  apresentada.
- Fluxos alternativos:
  - Manual: `.whatsNewSheet(isTriggered:releases:)` apresenta todas as releases
    declaradas, em ordem semântica, ignorando `canPresent`, versão atual e
    histórico; o binding volta para `false` logo após a avaliação.
  - Baseline de novo usuário: `WhatsNewPresentationState.markCurrentVersionAsSeen()`
    (alias de `markCurrentVersionAsBaseline`) grava a versão atual como já vista
    sem abrir a sheet nem emitir eventos.
  - Analytics: o callback `onEvent` recebe `opened`, `closed` e `stepProgress`.

### Estados

- Sem releases elegíveis ou `canPresent == false`: nada é apresentado e nada é
  registrado; a release continua pendente para uma avaliação futura.
- Apresentação ativa: uma avaliação automática não substitui uma sheet já
  aberta; um disparo manual substitui a apresentação ativa do mesmo modificador.
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
- Interrupção: fechar a sheet pelo gesto de arrastar não chama o fluxo de
  conclusão, portanto nada é registrado e as releases continuam pendentes (ver
  Pendências).

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
  - `SemanticVersion` compara somente componentes numéricos; qualquer caractere
    não numérico é separador (`1.0.0-beta` equivale a `1.0.0`, e
    `1.0.0-beta.2` equivale a `1.0.0.2`, que é maior que `1.0.0`).
  - O estado persistido é uma única chave em `UserDefaults.standard`,
    `<bundleIdentifier>.WhatsNewKit.lastPresentedVersion`, sem API pública para
    trocar o armazenamento.
  - `WhatsNewTopic` usa `UUID().uuidString` como `id` padrão; recriar tópicos a
    cada render muda a identidade das linhas.
  - A apresentação manual registra a maior versão exibida ao concluir, mesmo
    que seja maior que a versão atual do app.
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
  gravada em formato não numérico vira componentes vazios e se comporta como
  `0`.

## Validação

- Validações concluídas (2026-09-29, Xcode 27.0, Swift 6.4):
  - `swift test`: 39 testes em 9 suítes passando (macOS, Swift Testing).
  - `swift build`: sem avisos.
  - `xcodebuild` do Demo para `generic/platform=iOS Simulator`: build sem erros
    nem avisos; o pacote compila para iOS nesse build.
  - `scripts/lint-swift.sh`: 0 violações em 52 arquivos.
- Validações pendentes: execução interativa no Simulator (apresentação,
  paginação, vídeo, dismiss por gesto), macOS em execução, Dynamic Type,
  VoiceOver e iOS 26+ com Liquid Glass versus fallback em iOS 18.6.
- Condições de hardware, conta ou serviço: reprodução de vídeo e carregamento de
  imagens remotas dependem de rede e das URLs de exemplo do Demo; nenhum
  comportamento foi validado em dispositivo físico.

## Mapa de fontes

- API pública de apresentação:
  `Sources/WhatsNewKit/Features/SheetPresentation/View+WhatsNewSheet.swift`.
- Apresentação automática e manual:
  `WhatsNewAutoPresentationModifier`, `WhatsNewTriggeredPresentationModifier` e
  `WhatsNewPresentationViewModel` em `Features/SheetPresentation/`.
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

- Pendência: dismiss por gesto não registra a apresentação, e a sheet pode
  reaparecer na próxima avaliação automática.
  - Decisão: comportamento preservado; mudá-lo altera o contrato público.
  - Risco: usuário vê de novo releases que já fechou.
  - Próximo passo: decidir se o dismiss interativo deve registrar ou ser
    desabilitado, com teste do ViewModel antes da mudança.
- Pendência: a apresentação manual registra versões futuras ao concluir.
  - Decisão: comportamento preservado.
  - Risco: uma release futura vista manualmente não aparece automaticamente
    quando o app chegar a essa versão.
  - Próximo passo: confirmar a regra de produto e cobri-la com teste.
- Pendência: `WhatsNewVideoView` cria um `AVPlayerItem` em cada `init`, mesmo
  quando o `@State` já existe.
  - Risco: trabalho descartado a cada re-render do pai.
  - Próximo passo: mover a criação do player para um modelo com ciclo de vida
    explícito e medir antes/depois.
- Decisão: a estrutura segue `Core/`, `Features/` e `Resources/` dentro do
  target SwiftPM, e o Demo segue `Sources/App`, `Sources/Core`,
  `Sources/Features` e `Resources` com pastas sincronizadas no Xcode.
