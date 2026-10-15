import Foundation

/// Kullanıcı tanımlı kural: gönderen filtresi (boş = hepsi) ve regex; 1. yakalama grubu kod sayılır.
struct Rule: Codable, Identifiable, Hashable {
    var id = UUID()
    var name = ""
    var sender = ""
    var pattern = ""
}

struct Extraction: Equatable {
    enum Source: Equatable {
        case rule(String)
        case keyword(String)
    }

    let code: String
    let source: Source
}

enum CodeExtractor {
    /// SMS'in dili arayüz dilinden bağımsız olabilir; bu yüzden tüm desteklenen dillerin sözcükleri tek listede.
    static let defaultKeywords = [
        "kod", "şifre", "parola", "doğrulama", "otp", "code", "password", "passcode", // tr, en, de, fr, nl, pl, ku, az
        "código", "codice", "şifrə", // es, pt, it, az
        "код", "пароль", // ru, uk
        "رمز", "کد", // ar, fa
        "验证码", "动态码", "コード", "인증", // zh, ja, ko
    ]

    /// Kodun bitişiğinde olamayacak karakterler: harf ve rakam. Çince, Japonca ve Korece boşluksuz yazıldığından
    /// bu yazı sistemlerinin harfleri sınır sayılır ("验证码是123456").
    static let wordCharacter = #"[[\p{L}\p{N}]--[\p{Han}\p{Hiragana}\p{Katakana}\p{Hangul}]]"#

    /// İlk açılışta kullanıcının kurallarına bir kez eklenir; sonra düzenlenebilir ve silinebilir.
    /// Sabit id: silinen geri gelmez, düzenlenen geri yüklemede kopyalanmaz.
    static let defaultRules = [
        // "EARSIV FATURA(INTERAKTIF) ONAYI ICIN SMS SIFRENIZ: 4DAR7Q B001": 6 karakter, harfli olabilir
        Rule(id: UUID(uuidString: "6A1F0C2E-5B7D-4E3A-9C1B-2D8E4F6A0B11")!,
             name: "GİB e-Arşiv", sender: "GIB", pattern: #"SIFRENIZ:\s*([A-Z0-9]{4,8})\b"#),
    ]

    private static let turkish = Locale(identifier: "tr_TR")
    private static let candidates = try! NSRegularExpression(pattern: "(?<!\(wordCharacter))(\\d{3} \\d{3}|\\d{4,8})(?!\(wordCharacter))")

    /// Önce kurallar listedeki sırayla, sonra anahtar kelimeye en yakın sayı.
    static func extract(from body: String, sender: String, keywords: [String], rules: [Rule]) -> Extraction? {
        applyRules(rules, body: body, sender: sender) ?? nearestToKeyword(in: body, keywords: keywords)
    }

    /// Her karakteri tek karaktere indirir (ŞİFRE → sifre, SIFRE → sifre); dizinler orijinal metinle hizalı kalır.
    static func fold(_ text: String) -> [Character] {
        text.map { c in
            let f = String(c).lowercased(with: turkish)
                .folding(options: .diacriticInsensitive, locale: nil)
                .replacingOccurrences(of: "ı", with: "i")
            return f.count == 1 ? Character(f) : c
        }
    }

    private static func applyRules(_ rules: [Rule], body: String, sender: String) -> Extraction? {
        let foldedSender = String(fold(sender))
        let whole = NSRange(body.startIndex..., in: body)
        for rule in rules where !rule.pattern.isEmpty {
            if !rule.sender.isEmpty, !foldedSender.contains(String(fold(rule.sender))) { continue }
            guard let regex = try? NSRegularExpression(pattern: rule.pattern, options: .caseInsensitive),
                  let match = regex.firstMatch(in: body, range: whole) else { continue }
            let group = match.numberOfRanges > 1 && match.range(at: 1).location != NSNotFound ? match.range(at: 1) : match.range
            guard let range = Range(group, in: body) else { continue }
            return Extraction(code: String(body[range]), source: .rule(rule.name))
        }
        return nil
    }

    private static func nearestToKeyword(in body: String, keywords: [String]) -> Extraction? {
        let chars = Array(body)
        let folded = fold(body)
        let hits = keywords.flatMap { keyword in occurrences(of: fold(keyword), in: folded).map { (keyword, $0) } }
        guard !hits.isEmpty else { return nil }

        var best: (score: Int, code: String, keyword: String)?
        for match in candidates.matches(in: body, range: NSRange(body.startIndex..., in: body)) {
            guard let r = Range(match.range, in: body) else { continue }
            let span = body.distance(from: body.startIndex, to: r.lowerBound)..<body.distance(from: body.startIndex, to: r.upperBound)
            if isNoise(span, chars: chars, folded: folded) { continue }
            for (keyword, k) in hits {
                // Mesafe ×2; eşitlikte anahtar kelimeden sonra gelen sayı kazanır.
                let score = span.lowerBound >= k.upperBound ? (span.lowerBound - k.upperBound) * 2
                    : k.lowerBound >= span.upperBound ? (k.lowerBound - span.upperBound) * 2 + 1 : 0
                if best == nil || score < best!.score {
                    best = (score, String(body[r]).filter { !$0.isWhitespace }, keyword)
                }
            }
        }
        return best.map { Extraction(code: $0.code, source: .keyword($0.keyword)) }
    }

    /// Kod olamayacak sayılar: tarih/saat/tutar parçaları, telefon grupları, kart son haneleri, sipariş numaraları.
    private static func isNoise(_ span: Range<Int>, chars: [Character], folded: [Character]) -> Bool {
        func at(_ i: Int) -> Character? { chars.indices.contains(i) ? chars[i] : nil }
        let s = span.lowerBound, e = span.upperBound
        // 15.10.2026, 14:35, 1.250,00, 4821-9930
        if let p = at(s - 1), ".,:/-".contains(p), at(s - 2)?.isNumber == true { return true }
        if let n = at(e), ".,:/-".contains(n), at(e + 1)?.isNumber == true { return true }
        // 0850 222 00 00, IBAN grupları
        if at(s - 1) == " ", at(s - 2)?.isNumber == true { return true }
        if at(e) == " ", at(e + 1)?.isNumber == true { return true }
        let before = String(folded[max(0, s - 16)..<s])
        let after = String(folded[e..<min(folded.count, e + 16)])
        // "OBRET->3340", "3340'e RET yaz": kampanya iptal numaraları
        if before.range(of: #"([₺$€>]|\bno|\bhanesi|\bhaneli)\s*[:.]?\s*$"#, options: .regularExpression) != nil { return true }
        if after.range(of: #"^(\s*(tl\b|₺|try\b|usd\b|eur\b|ile biten|ile baslayan)|['’]y?[ae]\b)"#, options: .regularExpression) != nil { return true }
        return false
    }

    private static func occurrences(of needle: [Character], in haystack: [Character]) -> [Range<Int>] {
        guard !needle.isEmpty, needle.count <= haystack.count else { return [] }
        return (0...(haystack.count - needle.count))
            .filter { haystack[$0..<($0 + needle.count)].elementsEqual(needle) }
            .map { $0..<($0 + needle.count) }
    }
}
