//
//  ViewController.swift
//  FlipperView
//
//  Created by Ruben Roques on 09/06/2022.
//

import UIKit

class FlipNumberView: UIView {
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 0
        return stackView
    }()
        
    private lazy var textLabel: UILabel = {
        var textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.text = "-.--"
        return textLabel
    }()
    
    private let margin = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    
    private var previousValue: Double = 0.0
    private var previousNumberAsIntsArray: [Int] = []
    
    private var stripsDictionary = [Int: FlipNumberStripView]()
    init() {
        super.init(frame: .zero)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        self.addSubview(self.stackView)
        NSLayoutConstraint.activate([
            self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.margin.left),
            self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -self.margin.right),
            self.stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: self.margin.top),
            self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -self.margin.bottom),
        ])
        
        for i in 0...8 {
            let flipNumberStripView = FlipNumberStripView()
            NSLayoutConstraint.activate([
                flipNumberStripView.widthAnchor.constraint(equalToConstant: 11)
            ])
            
            stripsDictionary[i] = flipNumberStripView
            self.stackView.insertArrangedSubview(flipNumberStripView, at: 0)
            
            flipNumberStripView.isHidden = true
            flipNumberStripView.alpha = 0.0
        }
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "."
        label.font = AppFont.with(type: .bold, size: 15)
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalToConstant: 6)
        ])
        
        self.stackView.insertArrangedSubview(label, at: self.stackView.arrangedSubviews.count-2)
        
    }
    
    func setNumber(_ value: Double, animated: Bool) {
        
        if self.previousValue == value {
            return 
        }
        
        print("FlipperViewV will set new:[\(value)] from: [\(self.previousValue)]")
        
        let number = NSNumber(value: value)
        let numberString = Self.numberFormatter.string(from: number) ?? ""
        
        let numberAsInts = numberString.map(String.init).map(Int.init).compactMap({ $0 }).reversed()
        let numberAsIntsArray: [Int] = Array(numberAsInts)
        
        let biggestDigitDifference = self.biggestDigitDifference(between: self.previousNumberAsIntsArray, new: numberAsIntsArray)
        
        print("FlipperViewV \(self.previousNumberAsIntsArray) \(numberAsIntsArray), diff: \(biggestDigitDifference) ")
        
        let slideUp = self.previousValue < value
        
        UIView.animate(withDuration: FlipNumberStripView.slideAnimationDuration) {
            switch numberAsIntsArray.count {
            case 0...3:
                self.stackView.transform = .identity
            case 4:
                self.stackView.transform = CGAffineTransform.init(scaleX: 0.9, y: 0.9)
            case 5:
                self.stackView.transform = CGAffineTransform.init(scaleX: 0.78, y: 0.78)
            case 6:
                self.stackView.transform = CGAffineTransform.init(scaleX: 0.6, y: 0.6)
            case 7:
                self.stackView.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
            case 8:
                self.stackView.transform = CGAffineTransform.init(scaleX: 0.4, y: 0.4)
            default:
                self.stackView.transform = CGAffineTransform.init(scaleX: 0.1, y: 0.1)
            }
        }
        
        for (key, stripView) in self.stripsDictionary {
            
            var reversedMultiplier = biggestDigitDifference - 1 - key
            if reversedMultiplier < 0 {
                reversedMultiplier = 0
            }
            
            if let number = numberAsIntsArray[safe: key] {
                
                print("FlipperViewV flipping \(number) atIndex:\(key) multiplier:\(reversedMultiplier)")
                
                stripView.scrollToNumber(number, animated: animated, multiplier: reversedMultiplier, slideUp: slideUp)
                
                if stripView.isHidden {
                    UIView.animate(withDuration: FlipNumberStripView.slideAnimationDuration) {
                        stripView.alpha = 1.0
                        stripView.isHidden = false
                        self.setNeedsLayout()
                        self.layoutIfNeeded()
                    }
                }
            }
            else {
                stripView.scrollToNumber(0, animated: animated, multiplier: reversedMultiplier, slideUp: slideUp)
                
                if !stripView.isHidden {
                    UIView.animate(withDuration: FlipNumberStripView.slideAnimationDuration) {
                        stripView.alpha = 0.0
                        stripView.isHidden = true
                        self.setNeedsLayout()
                        self.layoutIfNeeded()
                    }
                }
            }
        }
        
        self.previousNumberAsIntsArray = numberAsIntsArray
        self.previousValue = value
        
        print("FlipperViewV ------------------------------------------------------- ")
    }

    private func biggestDigitDifference(between old: [Int], new: [Int]) -> Int {
        if old.count != new.count {
            return max(old.count, new.count)
        }
        else {
            var biggestDigitDifference = 0
            for (index, (old, new)) in zip(old, new).enumerated() {
                if old != new {
                    biggestDigitDifference = index+1
                }
            }
            return biggestDigitDifference
        }
    }
    
    static var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.decimalSeparator = "."
        numberFormatter.groupingSeparator = ""
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumFractionDigits = 2
        return numberFormatter
    }()
}

class FlipNumberStripView: UIView, UITableViewDelegate, UITableViewDataSource {
        
    private lazy var tableView: UITableView = {
        var tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let infiniteSize = 1000
    private let values = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    private var currentPosition: Int = 0
    
    static let slideAnimationDuration: CGFloat = 1.2
    
    init() {
        super.init(frame: .zero)
        self.commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        self.backgroundColor = .clear
        self.translatesAutoresizingMaskIntoConstraints = false
        self.clipsToBounds = false
        
        self.tableView.register(FlipNumberStripCellView.self, forCellReuseIdentifier: "FlipNumberStripCellView")
        
        self.tableView.clipsToBounds = false
        
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.scrollsToTop = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.allowsSelection = false
        self.tableView.isUserInteractionEnabled = false
        self.tableView.backgroundColor = .clear
        
        self.tableView.setValue(Self.slideAnimationDuration, forKeyPath: "contentOffsetAnimationDuration")
                
        self.addSubview(self.tableView)
        
        NSLayoutConstraint.activate([
            self.leadingAnchor.constraint(equalTo: self.tableView.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: self.tableView.trailingAnchor),
            self.topAnchor.constraint(equalTo: self.tableView.topAnchor),
            self.bottomAnchor.constraint(equalTo: self.tableView.bottomAnchor)
        ])
        
        
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        
        self.tableView.scrollToRow(at: IndexPath(row: infiniteSize/2, section: 0),
                                   at: .middle,
                                   animated: false)
        
    }

//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        if self.currentPosition == 0 {
//            self.tableView.scrollToRow(at: IndexPath(row: infiniteSize/2, section: 0),
//                                       at: .middle,
//                                       animated: false)
//            self.currentPosition = Int(infiniteSize/2)
//        }
//        else {
//            self.tableView.scrollToRow(at: IndexPath(row: self.currentPosition, section: 0),
//                                       at: .middle,
//                                       animated: false)
//        }
//    }
    
    func scrollToNumber(_ newNumber: Int, animated: Bool, multiplier: Int, slideUp: Bool) {
        guard
            let centerRow = self.tableView.indexPathsForVisibleRows?.first?.row
        else {
            return
        }

        let numberShowing = values[centerRow % values.count]
        
        print("FlipperViewStrip currentNumber:\(numberShowing) newNumber:\(newNumber) [\(slideUp)]")
        
        // let topDifference = number - numberShowing
        // let bottomDifference = number - numberShowing
        
        // let difference = numberShowing - newNumber
        
        let newIndex: Int
        if slideUp {
            var difference = (newNumber+10) - numberShowing
            if newNumber >= numberShowing {
                difference = newNumber - numberShowing
            }
            else {
                difference = (newNumber+10) - numberShowing
            }
            print("FlipperViewStrip \(difference) = abs(\(numberShowing) - \(newNumber)) ")
            newIndex = (centerRow + difference) + (multiplier * 10)
        }
        else {
            var difference = newNumber - numberShowing
            
            if numberShowing >= newNumber {
                difference = numberShowing - newNumber
            }
            else {
                difference = (numberShowing+10) - newNumber
            }
            print("FlipperViewStrip \(difference) = abs(\(numberShowing) - \(newNumber)) ")
            newIndex = (centerRow - difference) - (multiplier * 10)
        }
        
        
        
        print("FlipperViewStrip currentRow:\(centerRow) newRow: \(newIndex) ")
        
//        self.tableView.contentOffset = CGPoint(x: 0, y: 10)
        
        self.currentPosition = newIndex
        
        if newIndex >= 0 {
        self.tableView.scrollToRow(at: IndexPath(row: newIndex, section: 0),
                                   at: .middle,
                                   animated: animated)
        }
        
        print("FlipperViewStrip ----------------")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infiniteSize
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let itemToShow = values[indexPath.row % values.count]
        
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "FlipNumberStripCellView",
                                                       for: indexPath) as? FlipNumberStripCellView
        else {
            fatalError()
        }
        cell.setup(withNumber: "\(itemToShow)")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.frame.size.height
    }
    
}

class FlipNumberStripCellView: UITableViewCell {
    
    private lazy var numberLabel: UILabel = {
        var numberLabel = UILabel()
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        numberLabel.textAlignment = .center
        return numberLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.setupSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Cell clear for reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        self.numberLabel.text = nil
    }
    
    func setupSubviews() {
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        
        self.contentView.addSubview(self.numberLabel)
        
        NSLayoutConstraint.activate([
            self.contentView.centerXAnchor.constraint(equalTo: self.numberLabel.centerXAnchor),
            self.numberLabel.widthAnchor.constraint(equalToConstant: 15),
            
            self.contentView.topAnchor.constraint(equalTo: self.numberLabel.topAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.numberLabel.bottomAnchor)
        ])
    }
    
    func setup(withNumber number: String) {
        self.numberLabel.text = number
    }
    
}
