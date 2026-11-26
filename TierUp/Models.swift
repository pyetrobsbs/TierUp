//
//  Models.swift
//  TierUp
//
//  Os "moldes" dos dados da app: o que é uma tier, uma categoria,
//  um item e uma tier list. Aqui não há ecrãs, só dados.
//

import SwiftUI

// MARK: - Tier

/// As cinco tiers possíveis. O rawValue ("S", "A"...) é o texto mostrado
/// e também o que fica gravado no JSON.
enum Tier: String, CaseIterable, Identifiable, Codable, Hashable {
    case s = "S"
    case a = "A"
    case b = "B"
    case c = "C"
    case d = "D"

    // Identifiable: o próprio texto serve de identificador único
    var id: String { rawValue }

    // Cor clássica de cada tier
    var cor: Color {
        switch self {
        case .s: return .red
        case .a: return .orange
        case .b: return .yellow
        case .c: return .green
        case .d: return .blue
        }
    }
}

// MARK: - Categoria

/// O tema geral de uma tier list, com um ícone SF Symbol.
enum Categoria: String, CaseIterable, Identifiable, Codable, Hashable {
    case anime
    case jogos
    case filmes
    case outro

    var id: String { rawValue }

    // Nome bonito para mostrar no ecrã
    var nome: String {
        switch self {
        case .anime: return "Anime"
        case .jogos: return "Jogos"
        case .filmes: return "Filmes"
        case .outro: return "Outro"
        }
    }

    // Nome do ícone SF Symbol (usado com Image(systemName:))
    var icone: String {
        switch self {
        case .anime: return "sparkles"
        case .jogos: return "gamecontroller.fill"
        case .filmes: return "film.fill"
        case .outro: return "square.grid.2x2.fill"
        }
    }
}

// MARK: - ItemTier

/// Um item dentro de uma tier list (ex.: "Naruto").
struct ItemTier: Identifiable, Codable, Hashable {
    var id = UUID()
    var nome: String
    var nota: String = ""
    // nil = ainda está na zona "Por classificar"
    var tier: Tier? = nil
}

// MARK: - TierList

/// Uma tier list completa: um tema, uma categoria e os seus itens.
struct TierList: Identifiable, Codable, Hashable {
    var id = UUID()
    var tema: String
    var categoria: Categoria
    var itens: [ItemTier] = []

    /// Devolve só os itens de uma tier (ou os "por classificar" se tier for nil).
    func itensNaTier(_ tier: Tier?) -> [ItemTier] {
        itens.filter { $0.tier == tier }
    }
}

// MARK: - Dados de exemplo

extension TierList {
    /// Listas de exemplo para a app não começar vazia (e para os previews).
    static let exemplos: [TierList] = [
        TierList(
            tema: "Animes favoritos",
            categoria: .anime,
            itens: [
                ItemTier(nome: "Naruto", tier: .a),
                ItemTier(nome: "One Piece", tier: .s),
                ItemTier(nome: "Attack on Titan", tier: .s),
                ItemTier(nome: "Death Note", tier: .b),
                ItemTier(nome: "Bleach")
            ]
        ),
        TierList(
            tema: "Jogos de 2024",
            categoria: .jogos,
            itens: [
                ItemTier(nome: "Balatro", tier: .s),
                ItemTier(nome: "Astro Bot", tier: .a),
                ItemTier(nome: "Helldivers 2")
            ]
        )
    ]
}
