import Foundation
import UIKit

class CameraDirectionsView: UIView {
    override public func layoutSubviews() {
        super.layoutSubviews()

        layer.borderWidth = 5
        layer.borderColor = UIColor.systemBlue.cgColor
    }
}
