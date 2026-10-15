import Foundation

/// Örnek bir SMS ve içinde seçilen koddan, regex bilmeden kural üretir.
enum RuleBuilder {
    /// Kodun önündeki (yoksa arkasındaki) sabit kelimeleri çapa yapar, kodun yerine karakter yapısına uyan bir desen koyar.
    /// Üretilen kural örnekte tam olarak seçilen kodu yakalamıyorsa nil döner.
    static func rule(from body: String, selection: Range<String.Index>, sender: String) -> Rule? {
        guard let code = trimmed(selection, in: body) else { return nil }
        let name = sender.isEmpty ? String(localized: "Rule from sample") : String(localized: "\(sender) code")
        let capture = capturePattern(for: body[code])
        let before = code.lowerBound > body.startIndex ? body[body.index(before: code.lowerBound)] : nil
        let after = code.upperBound < body.endIndex ? body[code.upperBound] : nil
        let tail = after.map(isAlnum) == true ? "" : "(?!\(CodeExtractor.wordCharacter))"
        let head = before.map(isAlnum) == true ? "" : "(?<!\(CodeExtractor.wordCharacter))"

        // En az iki kelimelik çapa: tek kelime ("is", "kod") başka SMS'lerde de geçer.
        var candidates: [String] = []
        let (leftSep, leftWords) = anchor(body[..<code.lowerBound], reversed: true)
        for n in stride(from: min(2, leftWords.count), through: min(4, leftWords.count), by: 1) where n > 0 {
            candidates.append(join(leftWords.suffix(n)) + flexible(leftSep) + capture + tail)
        }
        let (rightSep, rightWords) = anchor(body[code.upperBound...], reversed: false)
        for n in stride(from: min(2, rightWords.count), through: min(4, rightWords.count), by: 1) where n > 0 {
            candidates.append(head + capture + flexible(rightSep) + join(rightWords.prefix(n)))
        }
        candidates.append(head + capture + tail)

        for pattern in candidates {
            let rule = Rule(name: name, sender: sender, pattern: pattern)
            let found = CodeExtractor.extract(from: body, sender: sender, keywords: [], rules: [rule])
            if found == Extraction(code: String(body[code]), source: .rule(name)) { return rule }
        }
        return nil
    }

    private static func isAlnum(_ c: Character) -> Bool { c.isLetter || c.isNumber }

    /// Seçimin başındaki ve sonundaki boşluk ve noktalama atılır ("482913." → "482913").
    private static func trimmed(_ r: Range<String.Index>, in body: String) -> Range<String.Index>? {
        guard let first = body[r].firstIndex(where: isAlnum), let last = body[r].lastIndex(where: isAlnum) else { return nil }
        return first..<body.index(after: last)
    }

    /// "4DAR7Q" → ([A-Z0-9]{4,8}), "482913" → (\d{4,8}); ayraçlı kodlar ("123 456") yapısıyla birebir.
    private static func capturePattern(for code: Substring) -> String {
        if code.allSatisfy({ $0.isASCII && isAlnum($0) }) {
            let n = code.count
            return "(\(code.allSatisfy(\.isNumber) ? #"\d"# : "[A-Z0-9]"){\(max(1, n - 2)),\(n + 2)})"
        }
        var runs: [(token: String, count: Int)] = []
        for c in code {
            let token = c.isNumber ? #"\d"# : c.isLetter ? #"\p{L}"# : NSRegularExpression.escapedPattern(for: String(c))
            if runs.last?.token == token { runs[runs.count - 1].count += 1 } else { runs.append((token, 1)) }
        }
        return "(" + runs.map { $0.count > 1 ? "\($0.token){\($0.count)}" : $0.token }.joined() + ")"
    }

    /// Koda bitişik ayraç (": ") ve koda en yakın, rakam içermeyen kelimeler; metindeki sırasıyla.
    private static func anchor(_ text: Substring, reversed: Bool) -> (separator: Substring, words: [Substring]) {
        if reversed {
            let end = text.lastIndex(where: isAlnum).map { text.index(after: $0) } ?? text.startIndex
            let words = text[..<end].split(whereSeparator: \.isWhitespace)
            return (text[end...], Array(words.reversed().prefix { !$0.contains(where: \.isNumber) }.reversed()))
        }
        let start = text.firstIndex(where: isAlnum) ?? text.endIndex
        let words = text[start...].split(whereSeparator: \.isWhitespace)
        return (text[..<start], Array(words.prefix { !$0.contains(where: \.isNumber) }))
    }

    private static func join(_ words: some Collection<Substring>) -> String {
        words.map { NSRegularExpression.escapedPattern(for: String($0)) }.joined(separator: #"\s+"#)
    }

    private static func flexible(_ separator: Substring) -> String {
        let visible = separator.filter { !$0.isWhitespace }
        if visible.isEmpty { return separator.isEmpty ? "" : #"\s+"# }
        return #"\s*"# + NSRegularExpression.escapedPattern(for: String(visible)) + #"\s*"#
    }
}
