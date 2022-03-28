
import UIKit

class LoadingCustomView: UIView {
    private let circle = UIBezierPath()
    
    struct Properties {
        static let circleLineWidth: CGFloat = 2
        static let circleLineColor = UIColor.systemGray4
        static let rotationDuration = 0.5
    }
    
    override func draw(_ rect: CGRect) {
        drawView()
        animateView()
    }
    
    private func drawView() {
        let center = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        let radius = CGFloat(center.x <= center.y ? center.x : center.y)
        circle.addArc(withCenter: center, radius: radius - Properties.circleLineWidth, startAngle: 0, endAngle: CGFloat.pi * 1.5, clockwise: true)
        circle.lineWidth = Properties.circleLineWidth
        Properties.circleLineColor.setStroke()
        circle.stroke()
    }
    
    private func animateView() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.repeatCount = .infinity
        rotation.fromValue = 0
        rotation.toValue = CGFloat.pi * 2
        rotation.duration = Properties.rotationDuration
        rotation.isRemovedOnCompletion = false
        self.layer.add(rotation, forKey: "customRotation")
    }
    
    func animationStop() {
        layer.speed = 0.0
    }
    
    func animationResume() {
        layer.speed = 1.0
    }
}
