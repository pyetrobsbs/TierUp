//
//  ListasView.swift
//  TierUp
//
//  ECRÃ 1 — Mostra todas as tier lists. Permite criar (botão +),
//  apagar (swipe) e abrir uma lista (toque).
//

import SwiftUI

struct ListasView: View {
    // O store vem do TierUpApp através do .environmentObject
    @EnvironmentObject var store: TierStore

    // Controla se a janela "Nova tier list" está aberta
    @State private var mostrarNovaLista = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.listas) { lista in
                    // Ao tocar, "empurra" o id da lista para a navegação
                    NavigationLink(value: lista.id) {
                        LinhaLista(lista: lista)
                    }
                }
                .onDelete { posicoes in
                    store.apagarListas(em: posicoes)
                }
            }
            .overlay {
                // Mensagem quando não há listas
                if store.listas.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "list.star")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        Text("Ainda não tens tier lists.\nToca em + para criar a primeira!")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("TierUp")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        mostrarNovaLista = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            // Quando um NavigationLink envia um UUID, abre o tabuleiro dessa lista
            .navigationDestination(for: UUID.self) { listaID in
                TabuleiroView(listaID: listaID)
            }
            .sheet(isPresented: $mostrarNovaLista) {
                NovaListaView()
                    .environmentObject(store)
            }
        }
    }
}

// MARK: - Uma linha da lista

/// Aspeto de cada tier list no ecrã 1 (ícone + tema + contagem).
struct LinhaLista: View {
    let lista: TierList

    var body: some View {
        let total = lista.itens.count
        let classificados = total - lista.itensNaTier(nil).count

        HStack(spacing: 12) {
            Image(systemName: lista.categoria.icone)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(lista.tema)
                    .font(.headline)
                Text("\(lista.categoria.nome) · \(classificados) de \(total) classificados")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Janela para criar uma lista nova

/// Aparece por baixo (sheet) quando se toca no "+".
struct NovaListaView: View {
    @EnvironmentObject var store: TierStore
    // dismiss() fecha esta janela
    @Environment(\.dismiss) var dismiss

    @State private var tema = ""
    @State private var categoria: Categoria = .anime

    var body: some View {
        NavigationStack {
            Form {
                Section("Tema") {
                    TextField("Ex.: Melhores filmes da Pixar", text: $tema)
                }

                Section("Categoria") {
                    Picker("Categoria", selection: $categoria) {
                        ForEach(Categoria.allCases) { cat in
                            Label(cat.nome, systemImage: cat.icone)
                                .tag(cat)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
            }
            .navigationTitle("Nova tier list")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Criar") {
                        store.criarLista(tema: tema, categoria: categoria)
                        dismiss()
                    }
                    // Só deixa criar se o tema não estiver vazio
                    .disabled(tema.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

// MARK: - Preview (canvas do Xcode)

struct ListasView_Previews: PreviewProvider {
    static var previews: some View {
        ListasView()
            .environmentObject(TierStore())
    }
}
