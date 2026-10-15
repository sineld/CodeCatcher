import AppKit

// Usage: xcrun swift scripts/make-icon.swift [preview.png]
func render(_ px: Int) -> Data {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px, bitsPerSample: 8,
        samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let s = CGFloat(px) / 1024
    let t = NSAffineTransform(); t.scaleX(by: s, yBy: s); t.concat()

    let body = NSBezierPath(roundedRect: NSRect(x: 100, y: 100, width: 824, height: 824), xRadius: 185, yRadius: 185)
    // soft drop shadow
    NSGraphicsContext.saveGraphicsState()
    let sh = NSShadow(); sh.shadowOffset = NSSize(width: 0, height: -14); sh.shadowBlurRadius = 28
    sh.shadowColor = NSColor.black.withAlphaComponent(0.35); sh.set()
    NSColor(red: 0.2, green: 0.2, blue: 0.6, alpha: 1).setFill(); body.fill()
    NSGraphicsContext.restoreGraphicsState()

    // gradient: indigo (top) -> teal (bottom)
    NSGraphicsContext.saveGraphicsState()
    body.addClip()
    NSGradient(colors: [NSColor(red: 0.36, green: 0.30, blue: 0.92, alpha: 1),
                        NSColor(red: 0.10, green: 0.62, blue: 0.78, alpha: 1)])!.draw(in: body.bounds, angle: -90)
    NSGraphicsContext.restoreGraphicsState()

    // white speech bubble + tail
    let bubble = NSBezierPath(roundedRect: NSRect(x: 232, y: 380, width: 560, height: 400), xRadius: 140, yRadius: 140)
    let tail = NSBezierPath()
    tail.move(to: NSPoint(x: 300, y: 450)); tail.line(to: NSPoint(x: 270, y: 280)); tail.line(to: NSPoint(x: 460, y: 410)); tail.close()
    NSColor.white.setFill(); bubble.fill(); tail.fill()

    // 4 OTP dots
    NSColor(red: 0.27, green: 0.26, blue: 0.80, alpha: 1).setFill()
    for i in 0..<4 {
        let cx = 512 + (CGFloat(i) - 1.5) * 118
        NSBezierPath(ovalIn: NSRect(x: cx - 44, y: 580 - 44, width: 88, height: 88)).fill()
    }
    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}

let fm = FileManager.default
let dir = fm.temporaryDirectory.appendingPathComponent("AppIcon-\(getpid()).iconset")
try fm.createDirectory(at: dir, withIntermediateDirectories: true)
defer { try? fm.removeItem(at: dir) }
for base in [16, 32, 128, 256, 512] {
    try render(base).write(to: dir.appendingPathComponent("icon_\(base)x\(base).png"))
    try render(base * 2).write(to: dir.appendingPathComponent("icon_\(base)x\(base)@2x.png"))
}
let p = Process()
p.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
p.arguments = ["-c", "icns", dir.path, "-o", "Resources/AppIcon.icns"]
try p.run(); p.waitUntilExit()
guard p.terminationStatus == 0 else { fatalError("iconutil failed") }
if CommandLine.arguments.count > 1 { try render(1024).write(to: URL(fileURLWithPath: CommandLine.arguments[1])) }
