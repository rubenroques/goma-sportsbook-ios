//
//  OddsVariationTableViewCell.swift
//  BetssonCameroonApp
//
//  Created by André Lascas on 14/08/2025.
//

import UIKit
import GomaUI

class OddsVariationTableViewCell: UITableViewCell {
    
    // MARK: - UI Components
    private lazy var oddsAcceptanceView: OddsAcceptanceView = {
        let view = OddsAcceptanceView(viewModel: MockOddsAcceptanceViewModel.acceptedMock())
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Properties
    private var currentViewModel: OddsAcceptanceViewModelProtocol?
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupSubviews() {
        contentView.addSubview(oddsAcceptanceView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            oddsAcceptanceView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            oddsAcceptanceView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            oddsAcceptanceView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            oddsAcceptanceView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Configuration
    func configure(with viewModel: OddsAcceptanceViewModelProtocol) {
        self.currentViewModel = viewModel
        oddsAcceptanceView.viewModel = viewModel
    }
    
    // MARK: - Cell Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        currentViewModel = nil
        // Don't remove the view, just update the view model reference
    }
} 
