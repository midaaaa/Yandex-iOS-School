//
//  PieChart.swift
//  Utilities
//
//  Created by Дмитрий Филимонов on 24.07.2025.
//

import UIKit

public struct Entity {
    public let value: Decimal
    public let label: String
    
    public init(value: Decimal, label: String) {
        self.value = value
        self.label = label
    }
}

public final class PieChartView: UIView {
    public var entities: [Entity] = [] {
        didSet { setNeedsDisplay() }
    }
    
    private let segmentColors: [UIColor] = [
        .systemGreen,
        .systemYellow,
        .systemBlue,
        .systemOrange,
        .systemPurple,
        .systemGray
    ]

    private var isAnimating = false
    private var pendingEntities: [Entity]? = nil

    public func setEntities(_ newEntities: [Entity], animated: Bool) {
        guard animated else {
            self.entities = newEntities
            return
        }
        guard !isAnimating else {
            pendingEntities = newEntities
            return
        }
        isAnimating = true

        let oldSnapshot = self.snapshotView(afterScreenUpdates: false)
        oldSnapshot?.frame = bounds
        if let oldSnapshot = oldSnapshot {
            addSubview(oldSnapshot)
        }

        self.entities = []
        setNeedsDisplay()
        layoutIfNeeded()

        let duration: TimeInterval = 0.7
        if let oldSnapshot = oldSnapshot {
            UIView.animate(withDuration: duration, animations: {
                oldSnapshot.alpha = 0
                oldSnapshot.transform = CGAffineTransform(rotationAngle: .pi)
            }, completion: { [weak self] _ in
                oldSnapshot.removeFromSuperview()
                guard let self = self else { return }
                
                self.entities = newEntities
                self.setNeedsDisplay()
                self.layoutIfNeeded()
                let newSnapshot = self.snapshotView(afterScreenUpdates: true)
                newSnapshot?.frame = self.bounds
                newSnapshot?.alpha = 0
                newSnapshot?.transform = CGAffineTransform(rotationAngle: .pi)
                
                self.entities = []
                self.setNeedsDisplay()
                self.layoutIfNeeded()
                if let newSnapshot = newSnapshot {
                    self.addSubview(newSnapshot)
                    
                    UIView.animate(withDuration: duration, animations: {
                        newSnapshot.alpha = 1
                        newSnapshot.transform = .identity
                    }, completion: { _ in
                        newSnapshot.removeFromSuperview()
                        self.isAnimating = false
                        self.entities = newEntities
                        self.setNeedsDisplay()
                        if let pending = self.pendingEntities {
                            self.pendingEntities = nil
                            self.setEntities(pending, animated: true)
                        }
                    })
                } else {
                    self.isAnimating = false
                    self.entities = newEntities
                    self.setNeedsDisplay()
                }
            })
        } else {
            self.entities = newEntities
            setNeedsDisplay()
            isAnimating = false
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }
    
    public override func draw(_ rect: CGRect) {
        guard !entities.isEmpty else { return }
        guard let context = UIGraphicsGetCurrentContext() else { return }

        let sorted = entities.sorted { $0.value > $1.value }
        let top5 = Array(sorted.prefix(5))
        let others = Array(sorted.dropFirst(5))
        let othersSum = others.reduce(Decimal(0)) { $0 + $1.value }
        var displayEntities = top5
        if othersSum > 0 {
            displayEntities.append(Entity(value: othersSum, label: "Остальные"))
        }

        let total = displayEntities.reduce(Decimal(0)) { $0 + $1.value }
        guard total > 0 else { return }

        let radius = min(rect.width, rect.height) * 0.5
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        let minAngle: CGFloat = .pi / 180  // 1 degree
        let values = displayEntities.map { CGFloat((($0.value as NSDecimalNumber).doubleValue)) }
        let totalValue = values.reduce(0, +)
        let angles = values.map { $0 / totalValue * 2 * .pi }
        var adjustedAngles = angles
        let minAnglesMask = angles.map { $0 < minAngle }
        let minAnglesCount = minAnglesMask.filter { $0 }.count
        let minAnglesSum = CGFloat(minAnglesCount) * minAngle
        let remainingAngle = 2 * .pi - minAnglesSum
        let remainingValue = zip(values, minAnglesMask).filter { !$0.1 }.map { $0.0 }.reduce(0, +)
        for i in 0..<angles.count {
            if minAnglesMask[i] {
                adjustedAngles[i] = minAngle
            } else {
                adjustedAngles[i] = remainingValue > 0 ? (values[i] / remainingValue) * remainingAngle : 0
            }
        }

        var startAngle = -CGFloat.pi / 2
        for (i, _) in displayEntities.enumerated() {
            let angle = adjustedAngles[i]
            context.setFillColor(segmentColors[i % segmentColors.count].cgColor)
            context.move(to: center)
            context.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: startAngle + angle, clockwise: false)
            context.closePath()
            context.fillPath()
            startAngle += angle
        }

        let donutRadius = radius * 0.9
        context.setBlendMode(.clear)
        context.addArc(center: center, radius: donutRadius, startAngle: 0, endAngle: 2 * .pi, clockwise: false)
        context.fillPath()
        context.setBlendMode(.normal)

        let font = UIFont.systemFont(ofSize: 10)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .left
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraph
        ]
        let legendLines = displayEntities.enumerated().map { (i, entity) in
            let percent = Int(round((entity.value as NSDecimalNumber).doubleValue / (total as NSDecimalNumber).doubleValue * 100))
            return (i, "\(percent)% \(entity.label)")
        }

        let dotDiameter: CGFloat = 8
        let dotTextSpacing: CGFloat = 6

        let maxLineWidth = legendLines
            .map { dotDiameter + dotTextSpacing + ($0.1 as NSString).size(withAttributes: attrs).width }
            .max() ?? 0
        let lineHeight = font.lineHeight
        let legendHeight = lineHeight * CGFloat(legendLines.count)
        let legendRect = CGRect(
            x: center.x - maxLineWidth / 2,
            y: center.y - legendHeight / 2,
            width: maxLineWidth,
            height: legendHeight
        )
        let dotYOffset = (lineHeight - dotDiameter) / 2
        for (index, line) in legendLines.enumerated() {
            let y = legendRect.origin.y + CGFloat(index) * lineHeight
            let dotRect = CGRect(
                x: legendRect.origin.x,
                y: y + dotYOffset,
                width: dotDiameter,
                height: dotDiameter
            )
            let color = segmentColors[index % segmentColors.count]
            color.setFill()
            let dotPath = UIBezierPath(ovalIn: dotRect)
            dotPath.fill()
            let textOrigin = CGPoint(x: dotRect.maxX + dotTextSpacing, y: y)
            (line.1 as NSString).draw(at: textOrigin, withAttributes: attrs)
        }
    }
}
