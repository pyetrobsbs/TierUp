//
//  DetalheItemView.swift
//  TierUp
//
//  ECRÃ 3 — Editar um item: nome, tier e nota. Também permite apagá-lo.
//

import SwiftUI

struct DetalheItemView: View {
    @EnvironmentObject var store: TierStore
    @Environment(\.dismiss) var dismiss

    let listaID: UUID
    // Cópia do item para editar. Só vai para o store ao tocar em "Guardar".
    @State var item: ItemTier

    @State private var confirmarApagar = false

    var body: some View {
        Form {
            // Pré-visualização do card com a cor da tier escolhida
            Section {
                HStack {
                    Spacer()
                    CardView(item: item, cor: item.tier?.cor ?? .gray)
                        .scaleEffect(1.3)
                        .padding(.vertical, 16)
                    Spacer()
                }
            }
            .listRowBackground(Color.clear)

            Section("Nome") {
                TextField("Nome do item", text: $item.nome)
            }

            Section("Tier") {
                // A seleção é Tier? (opcional), por isso as tags também são Tier?
                Picker("Tier", selection: $item.tier) {
                    Text("Por classificar").tag(Tier?.none)
                    ForEach(Tier.allCases) { tier in
                        Text(tier.rawValue).tag(Tier?.some(tier))
                    }
                }
            }

            Section("Nota") {
                TextEditor(text: $item.nota)
                    .frame(minHeight: 100)
            }

            Section {
                Button(role: .destructive) {
                    confirmarApagar = true
                } label: {
                    Label("Apagar item", systemImage: "trash")
                }
            }
        }
        .navigationTitle("Detalhe")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Guardar") {
                    store.editarItem(item, naLista: listaID)
                    dismiss()   // volta ao tabuleiro
                }
                .disabled(item.nome.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        // Pergunta antes de apagar, para não apagar sem querer
        .confirmationDialog("Apagar este item?",
                            isPresented: $confirmarApagar,
                            titleVisibility: .visible) {
            Button("Apagar", role: .destructive) {
                store.apagarItem(item.id, daLista: listaID)
                dismiss()
            }
        }
    }
}

struct DetalheItemView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DetalheItemView(listaID: UUID(),
                            item: ItemTier(nome: "Naruto", nota: "Clássico", tier: .a))
        }
        .environmentObject(TierStore())
    }
}
