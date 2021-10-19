//
//  CompetitionFilterHeaderView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 19/10/2021.
//

import UIKit

class CompetitionFilterHeaderView: UITableViewHeaderFooterView {

    private var titleLabel: UILabel = {
        var label  = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var arrowImageView: UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    var viewModel: CompetitionFilterSectionViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

}

protocol CollapsibleTableViewHeaderDelegate {
    func didCollapseSection(section: Int)
    func didExpandSection(section: Int)
}

