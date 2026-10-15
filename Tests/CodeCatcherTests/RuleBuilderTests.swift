import Testing
@testable import CodeCatcher

struct RuleBuilderTests {
    /// Örnek SMS'te `code` metnini seçip kural üretir.
    private func build(_ body: String, select code: String, sender: String = "", occurrence: Int = 0) -> Rule? {
        var ranges: [Range<String.Index>] = []
        var start = body.startIndex
        while let r = body.range(of: code, range: start..<body.endIndex) { ranges.append(r); start = r.upperBound }
        return RuleBuilder.rule(from: body, selection: ranges[occurrence], sender: sender)
    }

    private func apply(_ rule: Rule, to body: String, sender: String = "") -> String? {
        CodeExtractor.extract(from: body, sender: sender, keywords: [], rules: [rule])?.code
    }

    // Örnekten üretilen kural, aynı kalıptaki başka bir SMS'teki kodu yakalamalı.
    @Test(arguments: [
        ("EARSIV FATURA(INTERAKTIF) ONAYI ICIN SMS SIFRENIZ: 4DAR7Q B001", "4DAR7Q",
         "EARSIV FATURA(INTERAKTIF) ONAYI ICIN SMS SIFRENIZ: ZPQRTT B002", "ZPQRTT"),
        ("Trendyol: 123456 kodunu kimseyle paylaşma.", "123456",
         "Trendyol: 908172 kodunu kimseyle paylaşma.", "908172"),
        ("482913 dogrulama kodu ile islem yapabilirsiniz. B001", "482913",
         "730015 dogrulama kodu ile islem yapabilirsiniz. B002", "730015"),
        ("1234 ile biten kartınız için şifreniz: 482913", "482913",
         "5678 ile biten kartınız için şifreniz: 1029", "1029"),
        ("Doğrulama kodunuz 123 456 olarak gönderilmiştir.", "123 456",
         "Doğrulama kodunuz 908 172 olarak gönderilmiştir.", "908 172"),
        ("Giris Sifreniz: 482913 Referans Kodu: 1XJLLS", "482913",
         "Giris Sifreniz: 551203 Referans Kodu: 9KQWZA", "551203"),
    ])
    func generalizesToSameTemplate(sample: String, code: String, other: String, expected: String) throws {
        let rule = try #require(build(sample, select: code))
        #expect(apply(rule, to: sample) == code)
        #expect(apply(rule, to: other) == expected)
    }

    @Test func picksTheSelectedOccurrenceNotTheFirst() throws {
        let sample = "Giris Sifreniz: 482913 Referans Kodu: 1XJLLS"
        let rule = try #require(build(sample, select: "1XJLLS"))
        #expect(apply(rule, to: "Giris Sifreniz: 551203 Referans Kodu: 9KQWZA") == "9KQWZA")
    }

    @Test func trimsSpacesAndPunctuationAroundSelection() throws {
        let sample = "Doğrulama kodunuz: 482913. Kimseyle paylaşmayın."
        let rule = try #require(build(sample, select: " 482913. "))
        #expect(apply(rule, to: sample) == "482913")
    }

    @Test func keepsSenderAndNamesTheRule() throws {
        let rule = try #require(build("SMS SIFRENIZ: 4DAR7Q B001", select: "4DAR7Q", sender: "GIB"))
        #expect(rule.sender == "GIB")
        #expect(rule.name == "GIB code")
        #expect(apply(rule, to: "SMS SIFRENIZ: ZPQRTT B001", sender: "BANKA") == nil)
    }

    @Test(arguments: ["   ", ". "])
    func rejectsSelectionWithoutCode(selection: String) {
        #expect(build("Kodunuz:   . ", select: selection) == nil)
    }
}
