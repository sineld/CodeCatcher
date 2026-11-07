import AppKit

// Usage: xcrun swift scripts/make-dmg-background.swift
// Draws Resources/dmg-background.png: 1320×880 px at 144 dpi, shown as a 660×440 pt DMG window.
// Layout must match scripts/release.sh: app icon at (180, 220), Applications at (480, 220).
let width = 1320, height = 880
let ink = NSColor(red: 0.10, green: 0.10, blue: 0.22, alpha: 1)
let accent = NSColor(red: 0.36, green: 0.30, blue: 0.92, alpha: 1)
let gray = NSColor(white: 0.42, alpha: 1)

let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: width, pixelsHigh: height, bitsPerSample: 8,
    samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
let cg = NSGraphicsContext(bitmapImageRep: rep)!.cgContext
// top-left origin, like Finder's icon positions
cg.translateBy(x: 0, y: CGFloat(height))
cg.scaleBy(x: 1, y: -1)
NSGraphicsContext.current = NSGraphicsContext(cgContext: cg, flipped: true)

NSGradient(starting: NSColor(red: 0.94, green: 0.93, blue: 1.0, alpha: 1), ending: .white)!
    .draw(in: NSRect(x: 0, y: 0, width: width, height: height), angle: 90)

func text(_ string: String, size: CGFloat, weight: NSFont.Weight, color: NSColor) -> NSAttributedString {
    NSAttributedString(string: string, attributes: [.font: NSFont.systemFont(ofSize: size, weight: weight), .foregroundColor: color])
}
func drawCentered(_ string: NSAttributedString, y: CGFloat) {
    string.draw(at: NSPoint(x: (CGFloat(width) - string.size().width) / 2, y: y))
}

// header: icon + name, then tagline
// largest representation only: NSImage may blend in the 16 px one, whose corners aren't transparent
let icon = NSImage(contentsOfFile: "Resources/AppIcon.icns")!.representations.max { $0.pixelsWide < $1.pixelsWide }!
let title = text("CodeCatcher", size: 64, weight: .semibold, color: ink)
let iconSize: CGFloat = 112, gap: CGFloat = 22
let headerX = (CGFloat(width) - iconSize - gap - title.size().width) / 2
icon.draw(in: NSRect(x: headerX, y: 48, width: iconSize, height: iconSize),
          from: .zero, operation: .sourceOver, fraction: 1, respectFlipped: true, hints: nil)
title.draw(at: NSPoint(x: headerX + iconSize + gap, y: 104 - title.size().height / 2))
drawCentered(text("Catches SMS verification codes and copies them", size: 30, weight: .regular, color: gray), y: 172)

// dotted arrow between the two icons (window y = 220 pt → 440 px)
accent.setFill()
for x in stride(from: 540, through: 730, by: 30) {
    NSBezierPath(ovalIn: NSRect(x: CGFloat(x) - 7, y: 433, width: 14, height: 14)).fill()
}
let chevron = NSBezierPath()
chevron.move(to: NSPoint(x: 752, y: 412)); chevron.line(to: NSPoint(x: 780, y: 440)); chevron.line(to: NSPoint(x: 752, y: 468))
chevron.lineWidth = 12; chevron.lineCapStyle = .round; chevron.lineJoinStyle = .round
accent.setStroke(); chevron.stroke()

// instructions: English, then Turkish
let line1 = NSMutableAttributedString(attributedString: text("Drag the icon onto the ", size: 34, weight: .medium, color: ink))
line1.append(text("Applications", size: 34, weight: .semibold, color: accent))
line1.append(text(" folder.", size: 34, weight: .medium, color: ink))
drawCentered(line1, y: 736)
drawCentered(text("Simgeyi sürükleyip Uygulamalar klasörünün üzerine bırakın.", size: 28, weight: .regular, color: gray), y: 794)

NSGraphicsContext.current = nil
rep.size = NSSize(width: width / 2, height: height / 2) // 144 dpi → Finder shows it at 660×440 pt
try rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "Resources/dmg-background.png"))
