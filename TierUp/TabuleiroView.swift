//
//  TabuleiroView.swift
//  TierUp
//
//  ECRÃ 2 — O tabuleiro de uma tier list: uma fila por tier (S a D)
//  e a zona "Por classificar". Os cards mudam de fila por
//  drag and drop ou por toque longo (menu).
//

import SwiftUI

struct TabuleiroView: View {
    @EnvironmentObject var store: TierStore

    // Recebemos só o id; a lista "verdadeira" está sempre no store
    let listaID: UUID

    @State private var novoNome = ""
    // Título da fila por cima da qual está um card a ser arrastado
    @State private var filaDestacada: String? = nil

    // Procura a lista atual no store (nil se tiver sido apagada)
    private var lista: TierList? {
        store.listas.first { $0.id == listaID }
    }

    var body: some View {
        Group {
            if let lista = lista {
                tabuleiro(lista)
            } else {
                Text("Esta lista já não existe.")
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle(lista?.tema ?? "")
        .navigationBarTitleDisplayMode(.inline)
        // Tocar num card envia o ItemTier -> abre o ecrã 3
        .navigationDestination(for: ItemTier.self) { item in
            DetalheItemView(listaID: listaID, item: item)
        }
    }

    // MARK: - Conteúdo principal

    private func tabuleiro(_ lista: TierList) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                campoAdicionar

                Text("Toca num card para o editar. Arrasta-o, ou mantém premido, para mudar de tier.")
                    .font(.caption)
                    .foregroundColor(.secondary)

                // Uma fila para cada tier: S, A, B, C, D
                ForEach(Tier.allCases) { tier in
                    fila(titulo: tier.rawValue,
                         cor: tier.cor,
                         tier: tier,
                         itens: lista.itensNaTier(tier))
                }

                Text("Por classificar")
                    .font(.headline)
                    .padding(.top, 8)

                fila(titulo: "?",
                     cor: .gray,
                     tier: nil,
                     itens: lista.itensNaTier(nil))
            }
            .padding()
        }
    }

    // MARK: - Adicionar item

    private var campoAdicionar: some View {
        HStack {
            TextField("Escreve um item novo...", text: $novoNome)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    adicionar()   // carregar em Enter também adiciona
                }

            Button {
                adicionar()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
            }
            .disabled(novoNome.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    private func adicionar() {
        withAnimation {
            store.adicionarItem(nome: novoNome, naLista: listaID)
        }
        novoNome = ""
    }

    // MARK: - Uma fila do tabuleiro

    /// Desenha uma fila: etiqueta colorida à esquerda + cards à direita.
    /// `tier` nil = fila "Por classificar".
    private func fila(titulo: String, cor: Color, tier: Tier?, itens: [ItemTier]) -> some View {
        let destacada = (filaDestacada == titulo)

        return HStack(spacing: 0) {
            // Etiqueta com a letra e o contador de itens
            VStack(spacing: 2) {
                Text(titulo)
                    .font(.title.bold())
                Text("\(itens.count)")
                    .font(.caption.bold())
            }
            .foregroundColor(.black)
            .frame(width: 60, height: 90)
            .background(cor)

            // Cards, com scroll horizontal se forem muitos
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    if itens.isEmpty {
                        Text("Larga aqui")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                    }
                    ForEach(itens) { item in
                        cartao(item)
                    }
                }
                .padding(.horizontal, 8)
                .frame(height: 90)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            // Borda grossa quando um card está a ser arrastado por cima
            RoundedRectangle(cornerRadius: 12)
                .stroke(cor, lineWidth: destacada ? 4 : 0)
        )
        .scaleEffect(destacada ? 1.03 : 1)
        .animation(.easeInOut(duration: 0.15), value: destacada)
        // DROP: esta fila aceita textos (o id do item arrastado)
        .dropDestination(for: String.self) { ids, _ in
            receber(ids, em: tier)
        } isTargeted: { estaPorCima in
            if estaPorCima {
                filaDestacada = titulo
            } else if filaDestacada == titulo {
                filaDestacada = nil
            }
        }
    }

    // MARK: - Um card (com toque, arrastar e menu)

    private func cartao(_ item: ItemTier) -> some View {
        NavigationLink(value: item) {
            CardView(item: item, cor: item.tier?.cor ?? .gray)
        }
        .buttonStyle(.plain)
        // DRAG: o que "viaja" com o dedo é o id do item, em texto
        .draggable(item.id.uuidString)
        // Alternativa ao drag: toque longo -> escolher a tier
        .contextMenu {
            ForEach(Tier.allCases) { tier in
                Button("Mover para \(tier.rawValue)") {
                    mover(item.id, para: tier)
                }
            }
            Button("Por classificar") {
                mover(item.id, para: nil)
            }
            Button(role: .destructive) {
                withAnimation {
                    store.apagarItem(item.id, daLista: listaID)
                }
            } label: {
                Label("Apagar", systemImage: "trash")
            }
        }
    }

    // MARK: - Mover itens

    /// Chamado quando se larga um card numa fila.
    private func receber(_ ids: [String], em tier: Tier?) -> Bool {
        // Converte o texto recebido de volta num UUID
        guard let texto = ids.first,
              let itemID = UUID(uuidString: texto) else { return false }

        mover(itemID, para: tier)
        return true
    }

    private func mover(_ itemID: UUID, para tier: Tier?) {
        withAnimation(.spring()) {
            store.moverItem(itemID, para: tier, naLista: listaID)
        }
        // Pequena vibração para dar feedback
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
}

struct TabuleiroView_Previews: PreviewProvider {
    static let store = TierStore()

    static var previews: some View {
        NavigationStack {
            TabuleiroView(listaID: store.listas.first?.id ?? UUID())
        }
        .environmentObject(store)
    }
}
