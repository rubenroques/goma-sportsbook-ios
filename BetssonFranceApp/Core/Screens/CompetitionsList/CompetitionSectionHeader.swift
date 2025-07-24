import SwiftUI

// MARK: - ViewModel
final class CompetitionSectionHeaderViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var isExpanded: Bool

    // MARK: - Properties
    let id: String
    let name: String
    let country: Country?
    let selectionCount: Int

    var countryCode: String? {
        country?.iso2Code
    }

    // MARK: - Initialization
    init(id: String,
         name: String,
         country: Country?,
         isExpanded: Bool,
         selectionCount: Int)
    {
        self.id = id
        self.name = name
        self.country = country
        self.isExpanded = isExpanded
        self.selectionCount = selectionCount
    }

    // MARK: - Actions
    func toggle() {
        isExpanded.toggle()
    }
}

// MARK: - View
struct CompetitionSectionHeader: View {
    // MARK: - Properties
    @StateObject var viewModel: CompetitionSectionHeaderViewModel
    let onTap: () -> Void

    // MARK: - Body
    var body: some View {
        Button(action: {
            viewModel.toggle()
            onTap()
        }) {
            baseView
        }
        .buttonStyle(PlainButtonStyle())
    }

    // MARK: - Subviews
    private var baseView: some View {
        HStack(spacing: 8) {
            // Country flag
            countryFlagView

            // Title
            Text(viewModel.name)
                .font(.custom("Roboto-Bold", size: 16))
                .foregroundColor(Color(.App.textPrimary))
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Spacer()

            // Selection count
            if viewModel.selectionCount > 0 {
                Text("\(viewModel.selectionCount)")
                    .font(.custom("Roboto-Semibold", size: 12))
                    .foregroundColor(Color(.App.buttonTextPrimary))
                    .frame(width: 24, height: 24)
                    .background(Color(.App.highlightSecondary))
                    .clipShape(Circle())
            }

            // Arrow
            Image(viewModel.isExpanded ? "arrow_up_icon" : "arrow_down_icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 14, height: 14)
                .foregroundColor(Color(.App.textPrimary))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(minHeight: 56)
        .background(Color(.App.backgroundPrimary))
        .clipShape(
            RoundedRectangle(
                cornerRadius: 5,
                style: .continuous
            )
        )
        .padding(.horizontal, 26)
    }

    private var countryFlagView: some View {
        Group {
            if let countryCode = viewModel.countryCode, !countryCode.isEmpty {
                Image(Assets.flagName(withCountryCode: countryCode))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 18, height: 18)
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
                    .frame(width: 18, height: 18)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color(.App.highlightPrimaryContrast), lineWidth: 0.5)
                    )
            }
        }
    }
}

// MARK: - Preview
struct CompetitionSectionHeader_Previews: PreviewProvider {
    static var mockCountry = Country(
        name: "England",
        region: "Europe",
        iso2Code: "GB",
        iso3Code: "GBR",
        numericCode: "826",
        phonePrefix: "44"
    )

    static var previews: some View {
        VStack(spacing: 16) {
            // Expanded with selection
            CompetitionSectionHeader(
                viewModel: CompetitionSectionHeaderViewModel(
                    id: "GB",
                    name: "Premier League",
                    country: mockCountry,
                    isExpanded: true,
                    selectionCount: 3
                ),
                onTap: {}
            )

            // Collapsed without selection
            CompetitionSectionHeader(
                viewModel: CompetitionSectionHeaderViewModel(
                    id: "ES",
                    name: "La Liga",
                    country: Country(
                        name: "Spain",
                        region: "Europe",
                        iso2Code: "ES",
                        iso3Code: "ESP",
                        numericCode: "724",
                        phonePrefix: "34"
                    ),
                    isExpanded: false,
                    selectionCount: 0
                ),
                onTap: {}
            )

            // Long title
            CompetitionSectionHeader(
                viewModel: CompetitionSectionHeaderViewModel(
                    id: "DE",
                    name: "Bundesliga with a very long name that should wrap to two lines",
                    country: Country(
                        name: "Germany",
                        region: "Europe",
                        iso2Code: "DE",
                        iso3Code: "DEU",
                        numericCode: "276",
                        phonePrefix: "49"
                    ),
                    isExpanded: false,
                    selectionCount: 1
                ),
                onTap: {}
            )
        }
        .padding(.vertical)
        .background(Color(.App.backgroundSecondary))
        .previewLayout(.sizeThatFits)

        // Dark mode preview
        CompetitionSectionHeader(
            viewModel: CompetitionSectionHeaderViewModel(
                id: "GB",
                name: "Premier League",
                country: mockCountry,
                isExpanded: true,
                selectionCount: 3
            ),
            onTap: {}
        )
        .padding(.vertical)
        .background(Color(.App.backgroundSecondary))
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.dark)
    }
}
