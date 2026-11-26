//
//  CardView.swift
//  TierUp
//
//  Componente visual de UM card (não é um ecrã).
//  É usado no tabuleiro e no ecrã de detalhe.
//

import SwiftUI

struct CardView: View {
    let item: ItemTier
    // Cor da borda: a cor da tier (cinzento se ainda não tem tier)
    var cor: Color = .gray

    var body: some View {
        VStack(spacing: 4) {
            Text(item.nome)
                .font(.subheadline.weight(.semibold))
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .minimumScaleFactor(0.7)   // encolhe o texto se for comprido

            // Pequeno ícone se o item tiver uma nota escrita
            if !item.nota.isEmpty {
                Image(systemName: "note.text")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(6)
        .frame(width: 80, height: 70)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(cor, lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            CardView(item: ItemTier(nome: "One Piece", tier: .s), cor: .red)
            CardView(item: ItemTier(nome: "Bleach", nota: "Bom final"))
        }
        .padding()
    }
}
