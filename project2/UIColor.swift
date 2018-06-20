import UIKit

extension UIColor {
  class func rgba(red: Int, green: Int, blue: Int, alpha: CGFloat) -> UIColor{
    return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
  }
  static let joy = UIColor.rgba(red: 100, green: 255, blue: 100, alpha: 0.8)
  static let anger = UIColor.rgba(red: 255, green: 100, blue: 100, alpha: 0.8)
  static let sadness = UIColor.rgba(red: 100, green: 100, blue: 255, alpha: 0.8)
  static let happiness = UIColor.rgba(red: 255, green: 255, blue: 100, alpha: 0.8)
}
