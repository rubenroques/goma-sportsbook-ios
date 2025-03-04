import SwiftUI

// MARK: - ViewModel
final class CompetitionFilterCellViewModel2: ObservableObject {
    // MARK: - Published Properties
    @Published var isSelected: Bool

    // MARK: - Properties
    let id: String
    let locationId: String
    let title: String
    let isLastCell: Bool
    let country: Country?
    let mode: CompetitionFilterCellMode

    var countryCode: String? {
        country?.iso2Code
    }

    // MARK: - Initialization
    init(competition: Competition,
         locationId: String,
         isSelected: Bool,
         isLastCell: Bool,
         country: Country?,
         mode: CompetitionFilterCellMode)
    {
        self.id = competition.id
        self.title = competition.name
        self.locationId = locationId
        self.isSelected = isSelected
        self.isLastCell = isLastCell
        self.country = country
        self.mode = mode
    }

    // MARK: - Actions
    func toggle() {
        isSelected.toggle()
    }
}

// MARK: - View
@available(iOS 15.0, *)
struct CompetitionFilterCell: View {
    // MARK: - Properties
    @StateObject var viewModel: CompetitionFilterCellViewModel2
    let onToggle: (String, String) -> Void
    let onNavigate: (String) -> Void

    // MARK: - Body
    var body: some View {
        Button(action: handleTap) {
            HStack(spacing: 0) {
                // Base container
                HStack(spacing: 9) {
                    // Country flag
                    countryFlagView

                    // Title
                    Text(viewModel.title)
                        .font(.custom("Roboto-Bold", size: 14))
                        .foregroundColor(Color(.App.textPrimary))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    Spacer(minLength: 8)

                    // Right icon (checkbox or navigation arrow)
                    rightIconView
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(Color(.App.backgroundPrimary))
            }
            .padding(.horizontal, 26)
        }
        .buttonStyle(PlainButtonStyle())
        .background(separatorView)
        .clipShape(cellShape)
    }

    // MARK: - Subviews
    private var countryFlagView: some View {
        Group {
            if let countryCode = viewModel.countryCode, !countryCode.isEmpty {
                Image(Assets.flagName(withCountryCode: countryCode))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 16, height: 16)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color(.App.highlightPrimaryContrast), lineWidth: 0.5)
                    )
            }
            else {
                Image("country_flag_240")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 16, height: 16)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color(.App.highlightPrimaryContrast), lineWidth: 0.5)
                    )
            }
        }
    }

    private var rightIconView: some View {
        Group {
            switch viewModel.mode {
            case .toggle:
                Image(viewModel.isSelected ? "checkbox_selected_icon" : "checkbox_unselected_icon")
                    .frame(width: 19, height: 19)
            case .navigate:
                Image("nav_arrow_right_icon")
                    .frame(width: 19, height: 19)
            }
        }
    }

    private var separatorView: some View {
        VStack(spacing: 0) {
            Color.clear
            if !viewModel.isLastCell {
                Color(.App.separatorLine)
                    .frame(height: 1)
                    .padding(.horizontal, 16)
            }
        }
    }

    private var cellShape: some Shape {
        RoundedRectangle(
            cornerRadius: viewModel.isLastCell ? 5 : 0,
            style: .continuous
        )
    }

    // MARK: - Actions
    private func handleTap() {
        switch viewModel.mode {
        case .toggle:
            viewModel.toggle()
            onToggle(viewModel.id, viewModel.locationId)
        case .navigate:
            onNavigate(viewModel.id)
        }
    }
}

// MARK: - Preview
@available(iOS 15.0, *)
struct CompetitionFilterCell_Previews: PreviewProvider {
    static var mockCompetition: Competition {
        Competition(
            id: "pl-1",
            name: "Premier League",
            matches: [],
            sport: Sport(
                id: "football",
                name: "Football",
                alphaId: "FB",
                numericId: "1",
                showEventCategory: true,
                liveEventsCount: 0
            ),
            numberOutrightMarkets: 0
        )
    }

    static var mockCountry: Country {
        Country(
            name: "England",
            region: "Europe",
            iso2Code: "GB",
            iso3Code: "GBR",
            numericCode: "826",
            phonePrefix: "44"
        )
    }

    static var previews: some View {
        VStack(spacing: 0) {
            CompetitionFilterCell(
                viewModel: CompetitionFilterCellViewModel2(
                    competition: mockCompetition,
                    locationId: "GB",
                    isSelected: true,
                    isLastCell: false,
                    country: mockCountry,
                    mode: .toggle
                ),
                onToggle: { _, _ in },
                onNavigate: { _ in }
            )

            CompetitionFilterCell(
                viewModel: CompetitionFilterCellViewModel2(
                    competition: Competition(
                        id: "la-1",
                        name: "La Liga",
                        matches: [],
                        sport: mockCompetition.sport,
                        numberOutrightMarkets: 0
                    ),
                    locationId: "ES",
                    isSelected: false,
                    isLastCell: false,
                    country: Country(
                        name: "Spain",
                        region: "Europe",
                        iso2Code: "ES",
                        iso3Code: "ESP",
                        numericCode: "724",
                        phonePrefix: "34"
                    ),
                    mode: .toggle
                ),
                onToggle: { _, _ in },
                onNavigate: { _ in }
            )

            CompetitionFilterCell(
                viewModel: CompetitionFilterCellViewModel2(
                    competition: Competition(
                        id: "bun-1",
                        name: "Bundesliga with a very long name that should wrap to two lines",
                        matches: [],
                        sport: mockCompetition.sport,
                        numberOutrightMarkets: 0
                    ),
                    locationId: "DE",
                    isSelected: false,
                    isLastCell: true,
                    country: Country(
                        name: "Germany",
                        region: "Europe",
                        iso2Code: "DE",
                        iso3Code: "DEU",
                        numericCode: "276",
                        phonePrefix: "49"
                    ),
                    mode: .navigate
                ),
                onToggle: { _, _ in },
                onNavigate: { _ in }
            )
        }
        .previewLayout(.sizeThatFits)
        .padding(.vertical)
        .background(Color(.App.backgroundSecondary))

        // Dark mode preview
        CompetitionFilterCell(
            viewModel: CompetitionFilterCellViewModel2(
                competition: mockCompetition,
                locationId: "GB",
                isSelected: true,
                isLastCell: false,
                country: mockCountry,
                mode: .navigate
            ),
            onToggle: { _, _ in },
            onNavigate: { _ in }
        )
        .previewLayout(.sizeThatFits)
        .padding(.vertical)
        .background(Color(.App.backgroundSecondary))
        .preferredColorScheme(.dark)
    }
}
