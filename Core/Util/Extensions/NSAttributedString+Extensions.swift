
import UIKit

extension NSMutableAttributedString {

    @discardableResult
    public func setAsLink(textToFind:String, color: UIColor = .white, linkURL:String) -> Bool {

        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(.link, value: linkURL, range: foundRange)
            
            self.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], range: foundRange)
            self.addAttributes([NSAttributedString.Key.underlineColor: UIColor.white], range: foundRange)
            
            return true
        }
        return false
    }
    
    @discardableResult
    public func setAsUnderline(textToFind:String) -> Bool {

        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttributes([NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue], range: foundRange)
            self.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], range: foundRange)
            self.addAttributes([NSAttributedString.Key.underlineColor: UIColor.white], range: foundRange)
            
            return true
        }
        return false
    }
    
}
