import SwiftUI

struct SettingsView: View {
    @Bindable var model: AppModel

    var body: some View {
        TabView {
            Tab("General", systemImage: "gearshape") { GeneralTab(model: model) }
            Tab("Rules", systemImage: "list.bullet.rectangle") { RulesTab(model: model) }
            Tab("Keywords", systemImage: "textformat") { KeywordsTab(model: model) }
            Tab("Try It", systemImage: "play.circle") { TryTab(model: model) }
        }
        .frame(width: 580, height: 560)
    }
}

// MARK: - Genel

private struct GeneralTab: View {
    @Bindable var model: AppModel
    @State private var language = AppLanguage.chosen ?? AppLanguage.active

    var body: some View {
        Form {
            Section("Status") {
                LabeledContent("Message access") {
                    if model.accessError == nil {
                        Label("Granted", systemImage: "checkmark.circle.fill").foregroundStyle(.green)
                    } else {
                        Label("Full Disk Access required", systemImage: "exclamationmark.triangle.fill").foregroundStyle(.orange)
                    }
                }
                if model.accessError != nil {
                    Text("CodeCatcher needs Full Disk Access to read SMS messages. Turn it on for CodeCatcher in System Settings, then restart the app.")
                        .font(.callout).foregroundStyle(.secondary)
                    Button("Open Full Disk Access Settings") { AppModel.openFullDiskAccessSettings() }
                }
                LabeledContent("Last caught code") {
                    if let code = model.lastCode {
                        HStack {
                            Text(verbatim: code).font(.body.monospaced().bold()).textSelection(.enabled)
                            if let sender = model.lastSender, !sender.isEmpty { Text(verbatim: "· \(sender)").foregroundStyle(.secondary) }
                            Button("Copy") { model.copyLastCode() }
                        }
                    } else {
                        Text("None yet").foregroundStyle(.secondary)
                    }
                }
            }

            Section("Behavior") {
                Toggle("Pause", isOn: $model.isPaused)
                Toggle("Start at login", isOn: Binding(get: { model.launchAtLogin }, set: { model.setLaunchAtLogin($0) }))
            }

            Section("Language") {
                Picker("App language", selection: $language) {
                    ForEach(AppLanguage.all, id: \.code) { Text(verbatim: $0.name).tag($0.code) }
                }
                .onChange(of: language) { AppLanguage.choose(language) }
                if language != AppLanguage.active {
                    HStack {
                        Text("The new language is applied after a restart.").font(.callout).foregroundStyle(.secondary)
                        Spacer()
                        Button("Restart Now") { AppLanguage.relaunch() }
                    }
                }
            }

            Section("How it works") {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Each new SMS is tried in this order:")
                    Text("1. Rules in the Rules tab, including defaults like GİB e-Arşiv")
                    Text("2. Keywords: if a word such as code appears, the nearest number is taken")
                    Text("The code is copied to the clipboard and a notification is shown. Card digits, dates, amounts and phone numbers are never treated as codes.")
                        .padding(.top, 4)
                }
                .font(.callout)
                .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
    }
}

// MARK: - Kurallar

private struct RulesTab: View {
    @Bindable var model: AppModel
    @State private var showingBuilder = false

    var body: some View {
        Form {
            Section {
                Text("If a sender's code is not caught, add a rule for it. No regex needed: paste a sample SMS and select the part to copy.")
                    .font(.callout).foregroundStyle(.secondary)
                Button {
                    showingBuilder = true
                } label: {
                    Label("Create Rule from Sample SMS…", systemImage: "wand.and.stars")
                }
                .buttonStyle(.borderedProminent)
            }

            Section("Your rules") {
                if model.rules.isEmpty {
                    Text("No rules yet.").foregroundStyle(.secondary)
                }
                ForEach(model.rules) { rule in
                    RuleRow(rule: binding(for: rule.id)) { model.rules.removeAll { $0.id == rule.id } }
                }
                Text("Rules are tried from top to bottom; the first match decides the code. Default rules such as GİB e-Arşiv can be edited and deleted too.")
                    .font(.caption).foregroundStyle(.secondary)
                if model.isMissingDefaultRules {
                    Button("Restore Deleted Default Rules") { model.restoreDefaultRules() }
                }
            }
        }
        .formStyle(.grouped)
        .sheet(isPresented: $showingBuilder) {
            RuleBuilderSheet { model.rules.append($0) }
        }
    }

    // Satır silinirken dizin kaymasın diye bağlama id üzerinden.
    private func binding(for id: UUID) -> Binding<Rule> {
        Binding(
            get: { model.rules.first { $0.id == id } ?? Rule() },
            set: { new in
                if let i = model.rules.firstIndex(where: { $0.id == id }) { model.rules[i] = new }
            }
        )
    }
}

private struct RuleRow: View {
    @Binding var rule: Rule
    let onDelete: () -> Void

    var body: some View {
        DisclosureGroup {
            TextField("Rule name", text: $rule.name)
            TextField("Sender", text: $rule.sender, prompt: Text("Leave empty for all senders"))
            TextField("Regex", text: $rule.pattern)
                .font(.body.monospaced())
            if !rule.pattern.isEmpty, (try? NSRegularExpression(pattern: rule.pattern)) == nil {
                Text("Invalid regex: this rule is skipped.").font(.caption).foregroundStyle(.red)
            }
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    if rule.name.isEmpty { Text("Untitled rule") } else { Text(verbatim: rule.name) }
                    Group {
                        if rule.sender.isEmpty { Text("All senders") } else { Text("Sender: \(rule.sender)") }
                    }
                    .font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Button(role: .destructive, action: onDelete) { Image(systemName: "trash") }
                    .buttonStyle(.borderless)
                    .help("Delete rule")
            }
        }
    }
}

/// Örnek SMS'i yapıştır, kodu seç; kural kendiliğinden oluşur.
struct RuleBuilderSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State var sender = ""
    @State var message = ""
    @State private var selection: TextSelection?
    let onSave: (Rule) -> Void

    private var selected: Range<String.Index>? {
        guard case .selection(let range)? = selection?.indices, !range.isEmpty,
              range.upperBound <= message.endIndex else { return nil }
        return range
    }

    private var rule: Rule? {
        selected.flatMap { RuleBuilder.rule(from: message, selection: $0, sender: sender.trimmingCharacters(in: .whitespaces)) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Create a rule from a sample SMS").font(.title3.bold())

            Text("1. Type the sender name, as shown on the SMS, for example GIB.").font(.callout)
            TextField("Sender", text: $sender, prompt: Text("for example GIB"))

            Text("2. Paste the whole SMS below.").font(.callout)
            TextEditor(text: $message, selection: $selection)
                .font(.body)
                .frame(height: 110)
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(.quaternary))

            Text("3. Select the part to copy with the mouse.").font(.callout)
            feedback
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))

            HStack {
                Spacer()
                Button("Cancel", role: .cancel) { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Save Rule") {
                    if let rule { onSave(rule) }
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(rule == nil)
            }
        }
        .padding(20)
        .frame(width: 520)
    }

    @ViewBuilder private var feedback: some View {
        if message.isEmpty {
            Label("Paste the SMS first.", systemImage: "doc.on.clipboard").foregroundStyle(.secondary)
        } else if let selected {
            if let rule {
                VStack(alignment: .leading, spacing: 6) {
                    Label {
                        Text("In messages with the same pattern, this rule copies the code at this position:") + Text(verbatim: " ") + Text(message[selected]).bold().monospaced()
                    } icon: {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                    }
                    if sender.trimmingCharacters(in: .whitespaces).isEmpty {
                        Label("No sender: the rule is tried on every SMS. Add the sender name if you can.", systemImage: "exclamationmark.triangle")
                            .font(.caption).foregroundStyle(.orange)
                    }
                    DisclosureGroup("Generated regex") {
                        Text(verbatim: rule.pattern).font(.caption.monospaced()).textSelection(.enabled)
                    }
                    .font(.caption)
                }
            } else {
                Label("Couldn't build a rule from this selection. Make sure you selected the whole code.", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
            }
        } else {
            Label("Select the code in the text with the mouse.", systemImage: "cursorarrow.and.square.on.square.dashed").foregroundStyle(.secondary)
        }
    }
}

// MARK: - Anahtar kelimeler

private struct KeywordsTab: View {
    @Bindable var model: AppModel
    @State private var newKeyword = ""

    var body: some View {
        Form {
            Section {
                Text("If one of these words appears in an SMS, the nearest 4–8 digit number is taken as the code. Letter case and accents don't matter: ŞİFRE, şifre and sifre are the same.")
                    .font(.callout).foregroundStyle(.secondary)
            }
            Section("Words") {
                ForEach(model.keywords, id: \.self) { keyword in
                    HStack {
                        Text(verbatim: keyword)
                        Spacer()
                        Button(role: .destructive) {
                            model.keywords.removeAll { $0 == keyword }
                        } label: {
                            Image(systemName: "minus.circle")
                        }
                        .buttonStyle(.borderless)
                        .help("Remove word")
                    }
                }
                HStack {
                    TextField("New word", text: $newKeyword, prompt: Text("for example token"))
                        .onSubmit(add)
                    Button("Add", action: add)
                        .disabled(newKeyword.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            Section {
                Button("Restore Defaults") { model.keywords = CodeExtractor.defaultKeywords }
            }
        }
        .formStyle(.grouped)
    }

    private func add() {
        let keyword = newKeyword.trimmingCharacters(in: .whitespaces)
        guard !keyword.isEmpty, !model.keywords.contains(keyword) else { return }
        model.keywords.append(keyword)
        newKeyword = ""
    }
}

// MARK: - Dene

private struct TryTab: View {
    @Bindable var model: AppModel
    @State private var sender = ""
    @State private var message = ""
    @State private var showingBuilder = false

    private var found: Extraction? {
        CodeExtractor.extract(from: message, sender: sender, keywords: model.keywords, rules: model.rules)
    }

    var body: some View {
        Form {
            Section {
                Text("Paste an SMS to see right away which code CodeCatcher would copy. Nothing is copied.")
                    .font(.callout).foregroundStyle(.secondary)
                TextField("Sender", text: $sender, prompt: Text("for example GIB, optional"))
                VStack(alignment: .leading) {
                    Text("SMS text")
                    TextEditor(text: $message)
                        .frame(height: 90)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(.quaternary))
                }
            }
            Section("Result") {
                if message.isEmpty {
                    Text("Waiting for an SMS.").foregroundStyle(.secondary)
                } else if let found {
                    LabeledContent("Code to copy") {
                        Text(verbatim: found.code).font(.title3.monospaced().bold()).textSelection(.enabled)
                    }
                    LabeledContent("Reason", value: found.source.description)
                } else {
                    Label("No code found.", systemImage: "xmark.circle").foregroundStyle(.orange)
                }
                if !message.isEmpty {
                    Button("Create Rule from This SMS…") { showingBuilder = true }
                }
            }
        }
        .formStyle(.grouped)
        .sheet(isPresented: $showingBuilder) {
            RuleBuilderSheet(sender: sender, message: message) { model.rules.append($0) }
        }
    }
}
