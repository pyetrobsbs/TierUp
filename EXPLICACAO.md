# TierUp — Explicação do código (para estudar)

## A ideia geral em 30 segundos

```
TierUpApp  ──cria──▶  TierStore (os dados, @Published listas)
    │                        ▲
    └──abre──▶ ListasView ───┤  (Ecrã 1: todas as listas)
                  │ toque    │
                  ▼          │
             TabuleiroView ──┤  (Ecrã 2: filas S–D + "Por classificar")
                  │ toque    │
                  ▼          │
             DetalheItemView ┘  (Ecrã 3: editar/apagar um item)
```

- **Models.swift** diz *como são* os dados.
- **TierStore.swift** *guarda* os dados e tem as funções para os mudar.
- **As views** só *mostram* os dados e *chamam* funções do store.
  Nenhuma view altera os dados diretamente → o código fica organizado
  (isto é parecido com o padrão **MVVM**: Model – View – ViewModel).

---

## Passo 1 — `Models.swift` (os dados)

| Tipo | O que é | Porquê assim |
|---|---|---|
| `enum Tier` | S, A, B, C, D, cada uma com `cor` | Um `enum` só permite valores válidos; não há tier "Z" por engano |
| `enum Categoria` | anime, jogos, filmes, outro, com `nome` e `icone` | Igual: lista fechada de opções |
| `struct ItemTier` | `id`, `nome`, `nota`, `tier: Tier?` | `tier` é **opcional**: `nil` = "Por classificar" |
| `struct TierList` | `id`, `tema`, `categoria`, `itens` | Tem `itensNaTier(_:)` que filtra os itens de uma tier |

Protocolos (o que vem depois dos `:`):
- `Identifiable` → tem `id`; o `ForEach` e a `List` precisam disso para distinguir os elementos.
- `Codable` → pode virar JSON (para gravar).
- `Hashable` → pode ser usado como valor no `NavigationLink(value:)`.
- `CaseIterable` (nos enums) → dá `Tier.allCases`, usado para desenhar as 5 filas.

## Passo 1 — `TierStore.swift` (o "cérebro")

- `class TierStore: ObservableObject` → é uma **classe** porque todos os ecrãs
  partilham o **mesmo** objeto (uma struct seria copiada).
- `@Published var listas` → quando muda, o SwiftUI redesenha os ecrãs sozinho.
- Funções: `criarLista`, `apagarListas`, `adicionarItem`, `moverItem`, `editarItem`, `apagarItem`.
- Encontram as coisas pelo **`id`** (com `firstIndex`), não pela posição, porque a posição
  no ecrã muda mas o `id` nunca muda.
- `guard ... else { return }` → "se isto não se verificar, sai já". Evita nomes vazios
  e ids que não existem.

## Passo 2 — `TierUpApp.swift` + `ListasView.swift` (Ecrã 1)

- `TierUpApp`: `@StateObject private var store = TierStore()` cria o store uma única vez.
  `.environmentObject(store)` disponibiliza-o a todos os ecrãs.
- `ListasView`:
  - `@EnvironmentObject var store` → recebe o store.
  - `NavigationStack` → permite navegar entre ecrãs (iOS 16).
  - `NavigationLink(value: lista.id)` + `.navigationDestination(for: UUID.self)` →
    ao tocar, envia o id; o destino abre o `TabuleiroView` com esse id.
  - `.onDelete` → swipe para apagar.
  - Botão `+` muda `mostrarNovaLista = true` → `.sheet` abre a `NovaListaView`.
  - `.overlay` mostra uma mensagem quando não há listas.
- `NovaListaView` (dentro do mesmo ficheiro): `Form` com `TextField` e `Picker`.
  `@Environment(\.dismiss)` fecha a janela.

## Passo 3 — `TabuleiroView.swift` (Ecrã 2) + `CardView.swift`

- Recebe só o `listaID` e procura a lista no store sempre que desenha
  (assim vê sempre os dados mais recentes).
- `ForEach(Tier.allCases)` desenha uma fila por tier; no fim, a fila "Por classificar".
- Cada fila: etiqueta colorida com a letra + **contador** (`itens.count`) e um
  `ScrollView(.horizontal)` com os cards.
- **Drag and drop**:
  - `.draggable(item.id.uuidString)` → o card "leva" o seu id em texto.
  - `.dropDestination(for: String.self)` na fila → recebe o texto, converte em `UUID`
    e chama `store.moverItem(...)`.
  - `isTargeted` → diz se há um card por cima; a fila fica com borda e cresce um pouco.
  - Porquê enviar só o id em texto? Porque `String` já sabe ser arrastado
    (`Transferable`) — não é preciso configurar mais nada.
- **Alternativa por menu**: `.contextMenu` (toque longo) com "Mover para S/A/B/C/D",
  "Por classificar" e "Apagar".
- **Tocar num card**: `NavigationLink(value: item)` → abre o Ecrã 3.
- `CardView`: só desenho — nome, ícone se tiver nota, borda com a cor da tier.
  É um componente reutilizado no tabuleiro e no detalhe.

## Passo 4 — `DetalheItemView.swift` (Ecrã 3)

- `@State var item` → é uma **cópia** do item. As alterações só vão para o store
  quando se toca em **Guardar** (`store.editarItem`). Se voltar atrás, nada muda.
- `TextField` (nome), `Picker` (tier), `TextEditor` (nota).
- O `Picker` usa `Tier?`, por isso as tags são `Tier?.none` e `Tier?.some(tier)`.
- Apagar pede confirmação com `.confirmationDialog`.

## Passo 5 — Gravação (`TierStore.swift`)

- `didSet { gravar() }` no `listas` → **cada** alteração grava automaticamente.
- `gravar()`: `JSONEncoder().encode(listas)` → `UserDefaults.standard.set(...)`.
- `carregar()`: lê do `UserDefaults` e faz `JSONDecoder().decode(...)`.
- No `init`: `carregar() ?? TierList.exemplos` → se não há nada gravado, usa os exemplos.
  (`??` = "se for nil, usa isto").
- `try?` → se a conversão falhar, dá `nil` em vez de rebentar a app.

## Passo 6 — Polimento

- Cores clássicas por tier, contador por fila.
- `withAnimation` ao adicionar, mover e apagar.
- Fila destacada (borda + `scaleEffect`) durante o arrasto.
- Vibração (`UIImpactFeedbackGenerator`) ao mudar de tier.

---

## Possíveis perguntas do professor (e respostas)

**1. Qual a diferença entre `struct` e `class`? Porque usaste cada uma?**
Struct é copiada quando é passada (tipo de valor); class é partilhada (tipo de
referência). Os modelos são structs (simples e seguros); o `TierStore` é class
para todos os ecrãs usarem o mesmo.

**2. O que faz `@Published`?**
Avisa o SwiftUI quando a variável muda, para redesenhar os ecrãs que a usam.

**3. Diferença entre `@State`, `@StateObject` e `@EnvironmentObject`?**
`@State`: valor simples que pertence a uma view (ex.: texto de um campo).
`@StateObject`: cria e mantém vivo um objeto `ObservableObject` (no `TierUpApp`).
`@EnvironmentObject`: recebe um objeto que foi partilhado mais acima.

**4. Como funciona a navegação?**
`NavigationStack` + `NavigationLink(value:)` + `.navigationDestination(for:)`.
O link envia um valor (UUID ou ItemTier); o destino certo é escolhido pelo tipo do valor.

**5. Como funciona o drag and drop?**
O card usa `.draggable` com o seu id em texto; a fila usa `.dropDestination` para
receber esse texto, converte-o em UUID e pede ao store para mudar a tier do item.

**6. Porque `tier` é opcional (`Tier?`)?**
Para representar "ainda não classificado" sem inventar uma tier falsa.

**7. Como são gravados os dados?**
Convertidos em JSON (`Codable` + `JSONEncoder`) e guardados no `UserDefaults`
sempre que mudam (`didSet`). No arranque são lidos com `JSONDecoder`.

**8. O que é `guard`?**
Uma verificação que, se falhar, sai da função logo. Evita `if`s encadeados.

**9. O que é `Identifiable` e porque o `ForEach` precisa?**
Dá um `id` único a cada elemento, para o SwiftUI saber qual mudou/foi movido/apagado.

**10. O que acontece se o tema estiver vazio?**
O botão "Criar" fica desativado (`.disabled`) e o store também recusa (`guard`).

### Alterações que te podem pedir na hora (e onde mexer)

| Pedido | Onde |
|---|---|
| Adicionar uma tier "F" | `Models.swift`: `case f = "F"` e uma cor no `switch` |
| Mudar a cor de uma tier | `Models.swift`, `var cor` |
| Nova categoria (ex.: "Música") | `Models.swift`: novo `case` em `Categoria` + `nome` + `icone` |
| Mudar o tamanho dos cards | `CardView.swift`: `.frame(width:height:)` |
| Ordenar itens por nome dentro da tier | `Models.swift`, `itensNaTier`: `.filter {...}.sorted { $0.nome < $1.nome }` |
| Mostrar o total de itens no título | `TabuleiroView.swift`, `.navigationTitle` |
| Apagar os dados gravados para testar | apagar a app do simulador (ou mudar `chave`) |
