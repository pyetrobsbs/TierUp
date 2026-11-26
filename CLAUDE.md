# CLAUDE.md — Projeto TierUp (trabalho académico de iOS)

## O que é este projeto
App iOS em SwiftUI para um trabalho da faculdade. Permite criar tier lists sobre qualquer tema
(animes, jogos, filmes...), adicionar itens escrevendo o seu nome e classificá-los por
drag and drop entre as tiers S, A, B, C e D.

Requisitos do enunciado:
- No máximo 3 ecrãs (views), com navegação entre eles.
- Critérios de avaliação: a app funcionar; fazer o que foi proposto; estrutura do código e
  qualidade dos algoritmos; abrangência da matéria; "wow factor"; perguntas individuais
  sobre o código e alterações à app feitas na hora.

## Sou iniciante em Swift — regras de ensino (IMPORTANTE)
- Nunca tinha programado em Swift. Vou ter perguntas individuais e exame, por isso preciso
  de PERCEBER o código, não apenas tê-lo.
- Depois de cada alteração, explica em português, de forma simples, o que fizeste e porquê.
- Comentários no código em português, curtos, nos pontos importantes (não em todas as linhas).
- Código simples e legível antes de código "esperto". Nada de padrões avançados
  (generics complexos, protocolos próprios, Combine, async/await) sem necessidade.
- Faz uma coisa de cada vez. Não escrevas a app inteira de uma vez.
- Quando houver duas formas de fazer algo, escolhe a mais fácil de explicar.

## Ambiente — restrições técnicas (OBRIGATÓRIO)
- O código é escrito em Linux (CachyOS). Aqui NÃO é possível compilar SwiftUI.
- É compilado num MacBook Air 2017 com macOS Monterey 12 e **Xcode 14.2**.
- Portanto: **Swift 5.7, deployment target iOS 16.0**.
- PROIBIDO (não existe no Xcode 14.2 / iOS 16):
  - `@Observable`, `@Bindable`, macro `#Preview`, SwiftData, `@Model`
  - qualquer API marcada como iOS 17+ (ex.: `onChange(of:) { old, new in }` com 2 parâmetros,
    `ContentUnavailableView`, `.scrollTargetBehavior`, `sensoryFeedback`)
- USAR em vez disso:
  - `ObservableObject` + `@Published` + `@StateObject` / `@EnvironmentObject`
  - previews com `struct X_Previews: PreviewProvider`
  - `onChange(of:) { novoValor in }` (1 parâmetro)
- Disponível no iOS 16 e pode ser usado: `NavigationStack`, `NavigationLink(value:)`,
  `.navigationDestination`, `.draggable`, `.dropDestination`, `Transferable`, `Codable`.
- Como não posso compilar aqui, revê o código com cuidado antes de terminar
  (chavetas, tipos, imports `SwiftUI`).

## Ficheiros do projeto (NÃO criar outros .swift)
O Xcode 14.2 não deteta ficheiros novos criados fora dele. Os ficheiros abaixo já foram
criados vazios no Xcode; trabalha só dentro deles. Se for mesmo preciso um ficheiro novo,
avisa-me para eu o criar no Xcode. Nunca edites o `.xcodeproj` / `project.pbxproj`.

| Ficheiro | Conteúdo |
|---|---|
| `TierUpApp.swift` | Ponto de entrada (`@main`); cria o `TierStore` e injeta-o |
| `Models.swift` | `enum Tier` (S, A, B, C, D + cor), `enum Categoria` (anime, jogos, filmes, outro + ícone SF Symbol), `struct ItemTier`, `struct TierList` — todos `Identifiable`, `Codable`, `Hashable` |
| `TierStore.swift` | `class TierStore: ObservableObject` com `@Published var listas`; funções para criar/apagar listas, adicionar/mover/editar/apagar itens; gravação em JSON no `UserDefaults` |
| `ListasView.swift` | **Ecrã 1** — lista das tier lists, botão "+" (sheet para escrever o tema e escolher categoria), apagar com swipe, `NavigationStack` |
| `TabuleiroView.swift` | **Ecrã 2** — filas S–D coloridas + zona "Por classificar"; `TextField` para adicionar item; drag and drop entre filas; alternativa por menu (toque longo → escolher tier) |
| `CardView.swift` | Componente visual de um card (não é um ecrã) |
| `DetalheItemView.swift` | **Ecrã 3** — editar nome, nota, mudar tier por `Picker`, apagar item |
| `ContentView.swift` | Pode ser apagado do uso; o `TierUpApp` abre `ListasView` |

## Design / "wow factor" (sem complicar)
- Cada tier com a sua cor clássica (S vermelho, A laranja, B amarelo, C verde, D azul).
- Animações simples com `withAnimation` ao mover cards.
- Contador de itens por tier.
- Fora de âmbito (não fazer sem eu pedir): imagens da galeria, internet/APIs, login,
  bases de dados, notificações.

## Fluxo de trabalho
1. Tu alteras os ficheiros aqui (Linux).
2. Eu faço `git add . && git commit -m "..." && git push`.
3. No Mac: `git pull` e ⌘R no Xcode.
4. Se der erro de compilação, colo-te a mensagem e corriges.
Não faças `git push` sozinho; diz-me quando estiver pronto para eu testar.

## Ordem de construção sugerida
1. `Models.swift` + `TierStore.swift` (com dados de exemplo) → explicar.
2. `ListasView` + navegação → testar no Mac.
3. `TabuleiroView` + `CardView`, primeiro com mover por menu, depois drag and drop → testar.
4. `DetalheItemView` → testar.
5. Gravação com `UserDefaults` → testar.
6. Polimento visual e animações.
7. No fim: resumo de cada ficheiro e lista de possíveis perguntas do professor com respostas.
