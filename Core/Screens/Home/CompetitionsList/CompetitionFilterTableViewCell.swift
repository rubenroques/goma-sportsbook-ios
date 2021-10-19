//
//  CompetitionFilterTableViewCell.swift
//  Sportsbook
//
//  Created by Ruben Roques on 19/10/2021.
//

import UIKit
import Combine

class CompetitionFilterRowViewModel {

    var name: String = ""
    var isSelected: Bool = false

    func toggleSelection() {
        self.isSelected.toggle()
    }

}

class CompetitionFilterTableViewCell: UITableViewCell {

    private var titleLabel: UILabel = {
        var label  = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var selectedImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private var cancellables: Set<AnyCancellable> = []
    var viewModel: CompetitionFilterRowViewModel? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.titleLabel.text = ""
        self.selectedImageView
    }

    func bindViewModel(viewModel: CompetitionFilterRowViewModel) {
        self.viewModel
    }

}
