import Foundation
import UIKit
import Combine

public protocol MainFilterPillViewModelProtocol {
    
    func didTapMainFilterItem()-> QuickLinkType
    
    var mainFilterState: CurrentValueSubject<MainFilterStateType, Never> { get set }
    var mainFilterSubject: CurrentValueSubject<MainFilterItem, Never> { get }
}
