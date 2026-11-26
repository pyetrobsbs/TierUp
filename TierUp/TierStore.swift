//
//  TierStore.swift
//  TierUp
//
//  O "cérebro" da app: guarda todas as tier lists e tem as funções
//  para as alterar. Os ecrãs só leem daqui e chamam estas funções.
//

import SwiftUI

class TierStore: ObservableObject {

    // @Published: sempre que `listas` muda, os ecrãs que a usam redesenham-se
    @Published var listas: [TierList]

    init() {
        // Por agora começamos com dados de exemplo.
        // (A gravação em UserDefaults fica para o passo 5.)
        listas = TierList.exemplos
    }

    // MARK: - Ajuda interna

    /// Procura a posição (índice) de uma lista no array pelo seu id.
    private func indiceDaLista(_ listaID: UUID) -> Int? {
        listas.firstIndex { $0.id == listaID }
    }

    /// Remove espaços no início e no fim (ex.: "  Naruto " -> "Naruto").
    private func limpar(_ texto: String) -> String {
        texto.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Listas

    func criarLista(tema: String, categoria: Categoria) {
        let temaLimpo = limpar(tema)
        guard !temaLimpo.isEmpty else { return }   // não cria listas sem nome

        listas.append(TierList(tema: temaLimpo, categoria: categoria))
    }

    /// Usado pelo swipe para apagar (.onDelete) na ListasView.
    func apagarListas(em posicoes: IndexSet) {
        listas.remove(atOffsets: posicoes)
    }

    // MARK: - Itens

    func adicionarItem(nome: String, naLista listaID: UUID) {
        let nomeLimpo = limpar(nome)
        guard !nomeLimpo.isEmpty,
              let i = indiceDaLista(listaID) else { return }

        // Um item novo entra sempre em "Por classificar" (tier = nil)
        listas[i].itens.append(ItemTier(nome: nomeLimpo))
    }

    /// Muda um item de tier. `novaTier` nil = volta para "Por classificar".
    func moverItem(_ itemID: UUID, para novaTier: Tier?, naLista listaID: UUID) {
        guard let i = indiceDaLista(listaID),
              let j = listas[i].itens.firstIndex(where: { $0.id == itemID }) else { return }

        listas[i].itens[j].tier = novaTier
    }

    /// Substitui o item antigo pela versão editada (procura pelo mesmo id).
    func editarItem(_ itemEditado: ItemTier, naLista listaID: UUID) {
        guard let i = indiceDaLista(listaID),
              let j = listas[i].itens.firstIndex(where: { $0.id == itemEditado.id }) else { return }

        var item = itemEditado
        item.nome = limpar(item.nome)
        guard !item.nome.isEmpty else { return }   // não deixa ficar sem nome

        listas[i].itens[j] = item
    }

    func apagarItem(_ itemID: UUID, daLista listaID: UUID) {
        guard let i = indiceDaLista(listaID) else { return }

        listas[i].itens.removeAll { $0.id == itemID }
    }
}
