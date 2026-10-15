import Testing
@testable import CodeCatcher

struct CodeExtractorTests {
    private func code(_ body: String, sender: String = "", keywords: [String] = CodeExtractor.defaultKeywords, rules: [Rule] = []) -> String? {
        CodeExtractor.extract(from: body, sender: sender, keywords: keywords, rules: rules)?.code
    }

    @Test(arguments: [
        // İlk sayıyı almak yanlış olurdu: kart son hanesi, tarih, telefon, sipariş no
        ("1234 ile biten kartınızla 150,00 TL tutarlı işlem için doğrulama kodunuz: 482913", "482913"),
        ("15.10.2026 14:35 tarihli işleminiz için tek kullanımlık şifreniz 739104'tür.", "739104"),
        ("Sayın müşterimiz, giriş şifreniz: 552901. Bilgi için 0850 222 00 00 B002", "552901"),
        ("Kart son 4 hanesi 5678 olan işleminiz için doğrulama kodu 902117", "902117"),
        ("Siparişiniz için doğrulama kodu 482913. Sipariş no: 12345678", "482913"),
        // Büyük İ: Foundation'ın .caseInsensitive karşılaştırması bunları "şifre" ile eşleştirmez
        ("ŞİFRENİZ: 918273 KİMSEYLE PAYLAŞMAYINIZ", "918273"),
        ("TEK KULLANIMLIK ŞİFRE: 918273", "918273"),
        ("TEK KULLANIMLIK SIFRENIZ 918273", "918273"),
        ("DOĞRULAMA KODU: 918273", "918273"),
        // Kod anahtar kelimeden önce, boşluklu biçim, İngilizce
        ("Trendyol: 123456 kodunu kimseyle paylaşma.", "123456"),
        ("Doğrulama kodunuz 123 456", "123456"),
        ("G-123456 is your Google verification code.", "123456"),
        ("Your Apple ID code is: 654321. Don't share it.", "654321"),
    ])
    func picksTheCode(body: String, expected: String) {
        #expect(code(body) == expected)
    }

    // Varsayılan anahtar kelimeler tüm desteklenen dilleri kapsar; Çince, Japonca ve Korece'de rakam harfe bitişiktir.
    @Test(arguments: [
        ("您的验证码是482913，5分钟内有效。", "482913"),
        ("【招商银行】动态码：482913，请勿泄露。", "482913"),
        ("認証コードは482913です。", "482913"),
        ("[Web발신] 인증번호 [482913]를 입력해주세요.", "482913"),
        ("Ваш код подтверждения: 4829. Никому не сообщайте.", "4829"),
        ("Ihr Bestätigungscode lautet 482913.", "482913"),
        ("Tu código de verificación es 482913.", "482913"),
        ("Il tuo codice di verifica è 482913.", "482913"),
        ("Votre code de vérification est 482913.", "482913"),
        ("Twój kod weryfikacyjny to 482913.", "482913"),
        ("رمز التحقق الخاص بك هو 482913", "482913"),
        ("کد تایید شما: 482913", "482913"),
        ("Təsdiq kodunuz: 482913", "482913"),
    ])
    func otherLanguages(body: String, expected: String) {
        #expect(code(body) == expected)
    }

    @Test func letterAdjacentNumbersStayExcluded() {
        #expect(code("Kodunuz TR1234 ve B002") == nil)
    }

    // Gürültü sayısı anahtar kelimeye koddan daha yakın; yalnızca eleme kuralları kurtarır.
    @Test(arguments: [
        ("Şifreniz, 1234 ile biten kartınız için: 482913", "482913"),
        ("Şifre (son 4 hanesi 5678 olan kart): 482913", "482913"),
        ("Doğrulama kodu 15.10.2026 14:35 itibarıyla geçerli: 482913", "482913"),
        ("Kodunuz 10000 TL tutarındaki işlem için: 482913", "482913"),
        ("Kod için 0850 222 00 00 numarasını arayın veya girin: 482913", "482913"),
        ("Doğrulama kodu ve sipariş no 12345678 için onay: 482913", "482913"),
    ])
    func skipsNoiseNextToKeyword(body: String, expected: String) {
        #expect(code(body) == expected)
    }

    @Test(arguments: [
        "Toplantı yarın 1430'da, salon 2.", // anahtar kelime yok
        "Kampanya kodu ile 10000 TL'ye varan indirim!", // tek sayı tutar
        "Onay kodu 4821-9930", // tireli numara: yarısını kopyalamaktansa hiç
        "Doğrulama kodunuz: A7K9P2", // harfli kod varsayılan olarak yakalanmaz
        // Kampanya SMS'lerindeki iptal numaraları
        "Arkadaşını getir koduyla abone ol. Ret için 3340'e RET TURKNET yaz.",
        "Kampanya kodunu yazıp 4040'a SMS atarak katılın.",
        "İndirim kodu: NFYDFWYDRF. SMS RET: OBRET->3340",
    ])
    func findsNothing(body: String) {
        #expect(code(body) == nil)
    }

    @Test func customKeyword() {
        let body = "Giriş için onay numaranız 551234. Kimseyle paylaşmayın."
        #expect(code(body) == nil)
        #expect(code(body, keywords: ["onay"]) == "551234")
    }

    @Test func ruleCapturesAlphanumericCode() {
        let rule = Rule(name: "e-Devlet", sender: "devlet", pattern: #"kodunuz:\s*([A-Z0-9]{6})"#)
        let body = "Doğrulama kodunuz: A7K9P2"
        #expect(CodeExtractor.extract(from: body, sender: "e-Devlet", keywords: [], rules: [rule]) == Extraction(code: "A7K9P2", source: .rule("e-Devlet")))
        #expect(code(body, sender: "BANKA", rules: [rule]) == nil) // gönderen filtresi
    }

    @Test func ruleWinsOverKeywordsAndUsesWholeMatchWithoutGroup() {
        let rule = Rule(name: "ilk sayı", pattern: #"\d{4}"#)
        #expect(code("1234 ile biten kartınız için kodunuz 482913", rules: [rule]) == "1234")
    }

    // Varsayılan GİB kuralı: e-Arşiv şifreleri 6 karakter, harf+rakam ya da yalnızca harf.
    @Test(arguments: [
        ("EARSIV FATURA(INTERAKTIF) ONAYI ICIN SMS SIFRENIZ: 4DAR7Q B001", "4DAR7Q"),
        ("EARSIV FATURA(INTERAKTIF) ONAYI ICIN SMS SIFRENIZ: CDXLPQ B001", "CDXLPQ"),
        ("EARSIV FATURA(INTERAKTIF) ONAYI ICIN SMS SIFRENIZ: 482913 B001", "482913"),
        // Kural dokunmaz; anahtar kelime yolu yakalar ya da hiçbir şey seçilmez.
        ("GIB Dijital Vergi Dairesi dilekçe onaylama işleminiz için onay kodunuz 933780 B001", "933780"),
        ("Değerli Mükellefimiz, 2025 yılı MTV 2. taksitinizi 31.7.2026 tarihine kadar ödeyebilirsiniz. B001", nil),
    ] as [(String, String?)])
    func gibDefaultRule(body: String, expected: String?) {
        #expect(code(body, sender: "GIB", rules: CodeExtractor.defaultRules) == expected)
    }

    @Test func gibRuleIsLabelledAndLimitedToGibSender() {
        let body = "EARSIV FATURA(INTERAKTIF) ONAYI ICIN SMS SIFRENIZ: 4DAR7Q B001"
        #expect(CodeExtractor.extract(from: body, sender: "GIB", keywords: [], rules: CodeExtractor.defaultRules) == Extraction(code: "4DAR7Q", source: .rule("GİB e-Arşiv")))
        #expect(code(body, sender: "BANKA", rules: CodeExtractor.defaultRules) == nil)
    }

    @Test func rulesAreTriedInListOrder() {
        let mine = Rule(name: "benim", sender: "GIB", pattern: #"(B\d{3})"#)
        let body = "SMS SIFRENIZ: 4DAR7Q B001"
        #expect(CodeExtractor.extract(from: body, sender: "GIB", keywords: [], rules: [mine] + CodeExtractor.defaultRules)?.source == .rule("benim"))
        #expect(CodeExtractor.extract(from: body, sender: "GIB", keywords: [], rules: CodeExtractor.defaultRules + [mine])?.source == .rule("GİB e-Arşiv"))
    }

    @Test func deletedGibRuleNoLongerCatchesLetterCodes() {
        #expect(code("EARSIV FATURA(INTERAKTIF) ONAYI ICIN SMS SIFRENIZ: 4DAR7Q B001", sender: "GIB", rules: []) == nil)
    }

    @Test func invalidOrEmptyRulesAreSkipped() {
        let rules = [Rule(name: "bozuk", pattern: "(["), Rule(name: "boş")]
        #expect(code("Şifreniz: 482913", rules: rules) == "482913")
    }

    @Test func foldIsTurkishAwareAndKeepsLength() {
        let text = "ŞİFRE SIFRE İĞDIR Çok"
        let folded = CodeExtractor.fold(text)
        #expect(folded.count == text.count)
        #expect(String(folded) == "sifre sifre igdir cok")
    }
}
