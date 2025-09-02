import UIKit

extension UIBottomBar {
    struct Views {
        
        let barView: UIView
        let backgroundView: UIView
        let floatingView: UIView
         
        init(barView: UIView, backgroundView: UIView, superview: UIView) {

            barView.translatesAutoresizingMaskIntoConstraints = false
            self.barView = barView

            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            self.backgroundView = backgroundView
            
            let floatingView = UIView()
            floatingView.translatesAutoresizingMaskIntoConstraints = false
            self.floatingView = floatingView

            // superview
            superview.addSubview(floatingView)
            floatingView.addSubview(backgroundView)
            floatingView.addSubview(barView)
        }
    }
}
