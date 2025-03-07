# PreviewsHelper Usage Guide

This document provides comprehensive guidance on using the helper files in the `Core/PreviewsHelper` directory to create SwiftUI previews for UIKit components in the Sportsbook iOS app.

## Table of Contents

1. [Overview](#overview)
2. [PreviewUIViewController](#previewuiviewcontroller)
3. [PreviewUIView](#previewuiview)
4. [PreviewTableViewController](#previewtableviewcontroller)
5. [PreviewCollectionViewController](#previewcollectionviewcontroller)
6. [PreviewModelsHelper](#previewmodelshelper)
7. [Best Practices](#best-practices)

## Overview

The `PreviewsHelper` directory contains utilities designed to streamline the process of creating SwiftUI previews for UIKit components. These tools enable developers to:

- Preview UIViewController instances directly in the Xcode canvas
- Preview UIView instances seamlessly in SwiftUI
- Generate consistent mock data for preview purposes
- Display UITableViewCells in various states within a structured preview
- Display UICollectionViewCells in customizable layouts

## PreviewUIViewController

`PreviewUIViewController` is a generic wrapper that conforms to `UIViewControllerRepresentable`, allowing you to preview any UIViewController subclass in the SwiftUI canvas.

### Usage

```swift
import SwiftUI

@available(iOS 17.0, *)
#Preview("ViewController Name") {
    PreviewUIViewController {
        // Create and configure your view controller here
        let viewController = YourViewController()
        // Additional setup...
        return viewController
    }
}
```

### Real-World Example

The following example shows how to preview a movie details screen:

```swift
// Define a movie model
struct Movie {
    let title: String
    let posterName: String
    let rating: Double
    let synopsis: String
}

// Create a view controller to display movie details
class MovieDetailViewController: UIViewController {
    private let movie: Movie

    // UI elements
    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private let ratingLabel = UILabel()
    private let synopsisLabel = UILabel()

    init(movie: Movie) {
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // View lifecycle and UI setup...
}

// Preview the movie details view controller
@available(iOS 17.0, *)
#Preview("Movie Details Example") {
    PreviewUIViewController {
        MovieDetailViewController(
            movie: Movie(
                title: "Inception",
                posterName: "film.fill",
                rating: 9.8,
                synopsis: "A skilled thief is given a chance at redemption if he can successfully perform inception."
            )
        )
    }
}
```

## PreviewUIView

`PreviewUIView` allows you to preview any UIView subclass in the SwiftUI canvas, making it easy to develop and test custom views in isolation.

### Usage

```swift
import SwiftUI

@available(iOS 17.0, *)
#Preview("View Name") {
    PreviewUIView {
        // Create and configure your view here
        let view = YourCustomView()
        // Additional setup...
        return view
    }
    .frame(width: 300, height: 200)
    .previewLayout(.sizeThatFits)
}
```

### Real-World Example

The following example shows how to preview a retro game scoreboard:

```swift
// Define a game score model
struct GameScore {
    let gameTitle: String
    let score: Int
    let highScore: Int
}

// Create a custom view for displaying game scores
class RetroScoreboardView: UIView {
    private let gameTitleLabel = UILabel()
    private let scoreLabel = UILabel()
    private let highScoreLabel = UILabel()
    private let startButton = UIButton()

    private let gameScore: GameScore

    init(gameScore: GameScore) {
        self.gameScore = gameScore
        super.init(frame: .zero)
        setupUI()
        configure()
    }

    // View setup and configuration...
}

// Preview a single scoreboard
@available(iOS 17.0, *)
#Preview("Retro Scoreboard") {
    PreviewUIView {
        RetroScoreboardView(
            gameScore: GameScore(
                gameTitle: "SPACE INVADERS",
                score: 1450,
                highScore: 6780
            )
        )
    }
}

// Preview multiple scoreboards in a single view
@available(iOS 17.0, *)
#Preview("Multiple Scoreboards") {
    VStack {
        PreviewUIView {
            RetroScoreboardView(
                gameScore: GameScore(gameTitle: "PAC-MAN", score: 2200, highScore: 9840)
            )
        }
        PreviewUIView {
            RetroScoreboardView(
                gameScore: GameScore(gameTitle: "TETRIS", score: 410, highScore: 7800)
            )
        }
        PreviewUIView {
            RetroScoreboardView(
                gameScore: GameScore(gameTitle: "DONKEY KONG", score: 800, highScore: 5500)
            )
        }
    }
}
```

## PreviewTableViewController

`PreviewTableViewController` is a generic UITableViewController that allows you to preview UITableViewCell subclasses in multiple states within a structured table view.

### Implementation Steps

1. Define an enum conforming to `PreviewStateRepresentable` with different cell states
2. Create a `PreviewTableViewController` with your cell type and state enum as generic parameters
3. Configure cells for each state in the `configurator` closure

### Real-World Example

The following example shows how to preview a table view with space mission cells:

```swift
// Define a state enum for space missions
struct SpaceMissionState: PreviewStateRepresentable {
    let title: String
    let subtitle: String
    let missionPatchName: String

    var title: String { title }
    var subtitle: String? { subtitle }
    var cellHeight: CGFloat? { 80 }
}

// Create a cell for displaying space missions
class SpaceMissionCell: UITableViewCell {
    private let missionPatchView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    // Cell setup and configuration...

    func configure(with state: SpaceMissionState) {
        titleLabel.text = state.title
        subtitleLabel.text = state.subtitle
        missionPatchView.image = UIImage(systemName: state.missionPatchName)
    }
}

// Preview the table with multiple mission cells
@available(iOS 17.0, *)
#Preview("Space Missions Table") {
    PreviewUIViewController {
        PreviewTableViewController(
            states: [
                SpaceMissionState(title: "Apollo 11", subtitle: "First moon landing, 1969", missionPatchName: "moon.fill"),
                SpaceMissionState(title: "Voyager 1", subtitle: "Farthest human-made object", missionPatchName: "arrow.up.right.circle.fill"),
                SpaceMissionState(title: "Hubble Telescope", subtitle: "Exploring deep space", missionPatchName: "sparkles"),
                SpaceMissionState(title: "Mars Rover Perseverance", subtitle: "Searching for life on Mars", missionPatchName: "ant.fill"),
                SpaceMissionState(title: "James Webb Telescope", subtitle: "Next-gen space telescope", missionPatchName: "star.fill")
            ],
            cellClass: SpaceMissionCell.self,
            defaultCellHeight: 80
        ) { cell, state, _ in
            cell.configure(with: state)
        }
    }
}
```

## PreviewCollectionViewController

`PreviewCollectionViewController` is a generic UICollectionViewController that allows you to preview UICollectionViewCell subclasses in multiple states with customizable layouts.

### Implementation Steps

1. Define an enum conforming to `PreviewStateRepresentable` with different cell states
2. Create a `PreviewCollectionViewController` with your cell type and state enum as generic parameters
3. Configure cells for each state in the `configurator` closure

### Real-World Example

The following example shows how to preview a collection view with candy items:

```swift
// Define a state enum for candy items
struct CandyState: PreviewStateRepresentable {
    let title: String
    let subtitle: String
    let imageName: String

    var title: String { title }
    var subtitle: String? { subtitle }
}

// Create a cell for displaying candy items
class CandyCollectionViewCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    // Cell setup and configuration...

    func configure(with state: CandyState) {
        titleLabel.text = state.title
        subtitleLabel.text = state.subtitle
        imageView.image = UIImage(systemName: state.imageName)
    }
}

// Preview the collection with multiple candy cells
@available(iOS 17.0, *)
#Preview("Candy Collection") {
    PreviewUIViewController {
        PreviewCollectionViewController(
            states: [
                CandyState(title: "Lollipop", subtitle: "Sweet and colorful", imageName: "star.fill"),
                CandyState(title: "Chocolate Bar", subtitle: "Rich and delicious", imageName: "square.fill"),
                CandyState(title: "Gummy Bears", subtitle: "Chewy and fruity", imageName: "circle.fill"),
                CandyState(title: "Caramel Toffee", subtitle: "Soft and buttery", imageName: "heart.fill"),
                CandyState(title: "Peppermint", subtitle: "Minty and fresh", imageName: "bolt.fill")
            ],
            cellClass: CandyCollectionViewCell.self,
            defaultCellSize: CGSize(width: 120, height: 160),
            interItemSpacing: 15,
            scrollDirection: .horizontal
        ) { cell, state, _ in
            cell.configure(with: state)
        }
    }
}
```

## PreviewModelsHelper

`PreviewModelsHelper` provides factory methods to create mock data models for preview purposes. Using these consistent mock models ensures that previews remain stable and realistic.

### Available Mock Data Categories

The helper includes factory methods for creating various types of mock data:

- Participants (teams/players)
- Betting offers
- Outcomes
- Markets
- Venues/Locations
- Sports (Football, Basketball, Tennis, etc.)
- Matches (Standard, Live, Completed)
- Competitions
- Countries
- User Profiles
- Wallets
- Promotional Content

### Usage Example

```swift
import SwiftUI

struct MatchCardPreview: PreviewProvider {
    static var previews: some View {
        VStack {
            // Create a standard football match preview
            let standardMatch = PreviewModelsHelper.createFootballMatch()
            MatchCard(match: standardMatch)

            // Create a live match preview
            let liveMatch = PreviewModelsHelper.createLiveFootballMatch()
            MatchCard(match: liveMatch)

            // Create a completed match preview
            let completedMatch = PreviewModelsHelper.createCompletedFootballMatch()
            MatchCard(match: completedMatch)
        }
    }
}
```

## Best Practices

### 1. Use Appropriate Helper for the Component Type

- For view controllers: `PreviewUIViewController`
- For table view cells: `PreviewTableViewController`
- For collection view cells: `PreviewCollectionViewController`
- For custom views: `PreviewUIView`

### 2. Consistent Mock Data

Always use `PreviewModelsHelper` for mock data to ensure consistency across previews.

### 3. Multiple Preview States

Show components in various states to verify their appearance in different scenarios:
- Empty/loading states
- Populated states
- Error states
- Dark/light mode

### 4. Proper Sizing

Set appropriate frame sizes for your previews to ensure they represent how the component will look in the real app.

```swift
.frame(width: 300, height: 180)
.previewLayout(.sizeThatFits)
```

### 5. Descriptive Names

Use descriptive names for preview macros to easily identify what's being previewed:

```swift
#Preview("TeamCard - Standard")
#Preview("TeamCard - Highlighted")
```

### 6. iOS Version Compatibility

Remember to mark previews with `@available(iOS 17.0, *)` when using the new #Preview macro syntax to ensure backward compatibility.

### 7. Combine Multiple Preview Methods

You can combine helpers for comprehensive previews:

```swift
@available(iOS 17.0, *)
#Preview("Complex Component") {
    PreviewUIViewController {
        let viewController = UIViewController()
        let customView = YourCustomView()
        customView.configure(with: PreviewModelsHelper.createFootballMatch())
        viewController.view.addSubview(customView)
        // Set up constraints...
        return viewController
    }
}
```

## Common Issues and Solutions

### Preview Not Updating

If a preview isn't updating after changes:
- Try using "Refresh Preview" button in Xcode
- Ensure all constraints are properly set
- Check for runtime errors in the preview

### Preview Shows Empty Content

If your preview shows empty content:
- Verify that mock data is being created correctly
- Check if the view's frame size is appropriate
- Ensure all required properties are set