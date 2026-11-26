//
//  TierStore.swift
//  TierUp
//
//  O "cérebro" da app: guarda todas as tier lists e tem as funções
//  para as alterar. Os ecrãs só leem daqui e chamam estas funções.
//

import SwiftUI

class TierStore: ObservableObject {

    // @Published: sempre que `listas` muda, os ecrãs que a usam redesenham-se.
    // didSet: depois de cada alteração, grava tudo automaticamente.
    @Published var listas: [TierList] {
        didSet {
            gravar()
        }
    }

    // Nome da "gaveta" do UserDefaults onde guardamos os dados
    private static let chave = "tierListas"

    init() {
        // Tenta ler o que ficou gravado; se não houver nada, usa os exemplos.
        // (Atribuir aqui no init NÃO chama o didSet.)
        listas = TierStore.carregar() ?? TierList.exemplos
    }

    // MARK: - Gravação (JSON no UserDefaults)

    /// Converte as listas em JSON e guarda no UserDefaults.
    private func gravar() {
        // try? = se der erro, devolve nil em vez de rebentar a app
        if let dados = try? JSONEncoder().encode(listas) {
            UserDefaults.standard.set(dados, forKey: TierStore.chave)
        }
    }

    /// Lê o JSON do UserDefaults e converte de volta em [TierList].
    private static func carregar() -> [TierList]? {
        guard let dados = UserDefaults.standard.data(forKey: chave) else { return nil }
        return try? JSONDecoder().decode([TierList].self, from: dados)
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
