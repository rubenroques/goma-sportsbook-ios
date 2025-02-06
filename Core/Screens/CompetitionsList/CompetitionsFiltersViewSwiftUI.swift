import SwiftUI
import Combine
import OrderedCollections

struct CompetitionsFiltersView2: View {
    // MARK: - Environment
    @SwiftUI.Environment(\.dismiss) private var dismiss

    // MARK: - State
    @StateObject private var viewModel: CompetitionsFiltersView2Model

    // MARK: - Properties
    private var applyFiltersAction: (([String]) -> Void)?
    private var tapHeaderViewAction: (() -> Void)?
    private var didTapCompetitionNavigationAction: ((String) -> Void)?

    init(viewModel: CompetitionsFiltersView2Model = CompetitionsFiltersView2Model(),
         applyFiltersAction: (([String]) -> Void)? = nil,
         tapHeaderViewAction: (() -> Void)? = nil,
         didTapCompetitionNavigationAction: ((String) -> Void)? = nil)
    {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.applyFiltersAction = applyFiltersAction
        self.tapHeaderViewAction = tapHeaderViewAction
        self.didTapCompetitionNavigationAction = didTapCompetitionNavigationAction
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            headerView
            searchBarView
            competitionsList
        }
        .background(Color.clear)
    }

    // MARK: - Views
    private var headerView: some View {
        ZStack {
            headerBackground

            VStack {
                smallTitleLabel
                    .opacity(viewModel.state == .line ? 1 : 0)

                HStack {
                    clearButton
                    Spacer()
                    titleLabel
                    Spacer()
                    closeButton
                }
                .opacity(viewModel.state == .opened ? 1 : 0)
            }
            .padding(.horizontal)
        }
        .frame(height: 54)
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.height > 50 {
                        applyFiltersAction?(Array(viewModel.selectedIds))
                    }
                }
        )
        .onTapGesture {
            tapHeaderViewAction?()
        }
    }

    private var headerBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(viewModel.state == .opened ? Color(.App.backgroundSecondary) : Color(.App.highlightSecondary))
    }

    private var titleLabel: some View {
        Text(viewModel.titleText)
            .font(.custom("Roboto-Bold", size: 16))
            .foregroundColor(viewModel.state == .opened ? Color(.App.textPrimary) : Color(.App.buttonTextPrimary))
    }

    private var smallTitleLabel: some View {
        Text(viewModel.titleText)
            .font(.custom("Roboto-Bold", size: 8))
            .foregroundColor(viewModel.state == .opened ? Color(.App.textPrimary) : Color(.App.buttonTextPrimary))
    }

    private var clearButton: some View {
        Button(action: viewModel.clearSelection) {
            Text(localized("clear_all"))
                .font(.custom("Roboto-Bold", size: 13))
                .foregroundColor(Color(.App.highlightPrimary))
        }
        .disabled(!viewModel.hasSelection)
    }

    private var closeButton: some View {
        Button(action: { applyFiltersAction?(Array(viewModel.selectedIds)) }) {
            Text(viewModel.closeButtonTitle)
                .font(.custom("Roboto-Bold", size: 13))
                .foregroundColor(Color(.App.highlightPrimary))
        }
    }

    private var searchBarView: some View {
        ZStack {
            Color(.App.backgroundSecondary)

            TextField(localized("search_field_competitions"), text: $viewModel.searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .padding(.vertical, 8)
        }
        .frame(height: 70)
    }

    private var competitionsList: some View {
        List {
            ForEach(viewModel.filteredCompetitions) { section in
                Section(header:
                    CompetitionSectionHeader(
                        viewModel: CompetitionSectionHeaderViewModel(
                            id: section.id,
                            name: section.name,
                            country: section.country,
                            isExpanded: viewModel.isExpanded(section.id),
                            selectionCount: viewModel.selectionCount(for: section.id)
                        ),
                        onTap: { viewModel.toggleSection(section.id) }
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                ) {
                    if viewModel.isExpanded(section.id) {
                        ForEach(section.cells) { competition in
                            CompetitionFilterCell(
                                viewModel: CompetitionFilterCellViewModel2(
                                    competition: competition.competition,
                                    locationId: section.id,
                                    isSelected: viewModel.isSelected(competition.id),
                                    isLastCell: section.cells.last?.id == competition.id,
                                    country: section.country,
                                    mode: .toggle
                                ),
                                onToggle: { competitionId, sectionId in
                                    viewModel.toggleSelection(competitionId, in: sectionId)
                                },
                                onNavigate: { competitionId in
                                    didTapCompetitionNavigationAction?(competitionId)
                                }
                            )
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                        }
                    }
                }
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(GroupedListStyle())
    }
}


// MARK: - Size State
enum SizeState {
    case opened
    case bar
    case line
}

// MARK: - ViewModel
final class CompetitionsFiltersView2Model: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var viewState: ViewState = .idle(.opened)
    @Published var selectedIds: Set<String> = []
    @Published var competitions: [CompetitionFilterSectionViewModel] = []
    @Published var expandedSections: Set<String> = []
    @Published private var competitionSelectedIds: [String: Set<String>] = [:]
    @Published var searchText: String = ""

    // MARK: - Private Properties
    private var initialSelectedIds: Set<String> = []

    // MARK: - Computed Properties
    var state: SizeState {
        switch viewState {
        case .idle(let sizeState), .loading(let sizeState), .error(_, let sizeState):
            return sizeState
        }
    }

    var hasSelection: Bool {
        !selectedIds.isEmpty
    }

    var titleText: String {
        if selectedIds.isEmpty {
            return localized("choose_competitions")
        } else {
            return "\(localized("choose_competitions")) (\(selectedIds.count))"
        }
    }

    var closeButtonTitle: String {
        selectedIds == initialSelectedIds ? localized("close") : localized("apply")
    }

    // MARK: - Initialization
    init(initialState: SizeState = .opened) {
        self.viewState = .idle(initialState)
    }

    // MARK: - Public Methods
    func updateState(_ newState: SizeState) {
        switch viewState {
        case .idle:
            viewState = .idle(newState)
        case .loading:
            viewState = .loading(newState)
        case .error(let error, _):
            viewState = .error(error, newState)
        }
    }

    func setError(_ error: Error) {
        viewState = .error(error, state)
    }

    func setLoading() {
        viewState = .loading(state)
    }

    func setIdle() {
        viewState = .idle(state)
    }

    var filteredCompetitions: [CompetitionFilterSectionViewModel] {
        guard !searchText.isEmpty else { return competitions }

        return competitions.compactMap { section in
            let filteredCells = section.cells.filter { competition in
                competition.name.localizedCaseInsensitiveContains(searchText)
            }
            guard !filteredCells.isEmpty else { return nil }
            return CompetitionFilterSectionViewModel(
                id: section.id,
                name: section.name,
                cells: filteredCells,
                country: section.country
            )
        }
    }

    func isExpanded(_ sectionId: String) -> Bool {
        expandedSections.contains(sectionId)
    }

    func selectionCount(for sectionId: String) -> Int {
        competitionSelectedIds[sectionId]?.count ?? 0
    }

    func isSelected(_ competitionId: String) -> Bool {
        selectedIds.contains(competitionId)
    }

    func toggleSection(_ sectionId: String) {
        if expandedSections.contains(sectionId) {
            expandedSections.remove(sectionId)
        }
        else {
            expandedSections.insert(sectionId)
        }
    }

    func toggleSelection(_ competitionId: String, in sectionId: String) {
        if selectedIds.contains(competitionId) {
            selectedIds.remove(competitionId)
            competitionSelectedIds[sectionId]?.remove(competitionId)
        }
        else {
            selectedIds.insert(competitionId)
            if competitionSelectedIds[sectionId] == nil {
                competitionSelectedIds[sectionId] = []
            }
            competitionSelectedIds[sectionId]?.insert(competitionId)
        }
    }

    func clearSelection() {
        selectedIds.removeAll()
        competitionSelectedIds.removeAll()
    }
}

// MARK: - ViewState
extension CompetitionsFiltersView2Model {
    enum ViewState {
        case idle(SizeState)
        case loading(SizeState)
        case error(Error, SizeState)

        var isLoading: Bool {
            if case .loading = self {
                return true
            }
            return false
        }

        var error: Error? {
            if case .error(let error, _) = self {
                return error
            }
            return nil
        }
    }
}

// MARK: - Preview
struct CompetitionsFiltersView2_Previews: PreviewProvider {
    static var mockViewModel: CompetitionsFiltersView2Model {
        let viewModel = CompetitionsFiltersView2Model(initialState: .opened)

        // Create mock sport
        let football = Sport(
            id: "football",
            name: "Football",
            alphaId: "FB",
            numericId: "1",
            showEventCategory: true,
            liveEventsCount: 10,
            outrightEventsCount: 5,
            eventsCount: 15
        )

        // Create mock competitions
        let premierLeagueCompetitions = [
            Competition(id: "pl-1", name: "Premier League", matches: [], sport: football, numberOutrightMarkets: 0),
            Competition(id: "pl-2", name: "FA Cup", matches: [], sport: football, numberOutrightMarkets: 0),
            Competition(id: "pl-3", name: "EFL Championship", matches: [], sport: football, numberOutrightMarkets: 0)
        ]

        let laLigaCompetitions = [
            Competition(id: "la-1", name: "La Liga", matches: [], sport: football, numberOutrightMarkets: 0),
            Competition(id: "la-2", name: "Copa del Rey", matches: [], sport: football, numberOutrightMarkets: 0),
            Competition(id: "la-3", name: "Segunda División", matches: [], sport: football, numberOutrightMarkets: 0)
        ]

        let bundesligaCompetitions = [
            Competition(id: "bun-1", name: "Bundesliga", matches: [], sport: football, numberOutrightMarkets: 0),
            Competition(id: "bun-2", name: "DFB-Pokal", matches: [], sport: football, numberOutrightMarkets: 0)
        ]

        // Create competition groups
        let englandCountry = Country(name: "England", region: "Europe", iso2Code: "GB", iso3Code: "GBR", numericCode: "826", phonePrefix: "44")
        let spainCountry = Country(name: "Spain", region: "Europe", iso2Code: "ES", iso3Code: "ESP", numericCode: "724", phonePrefix: "34")
        let germanyCountry = Country(name: "Germany", region: "Europe", iso2Code: "DE", iso3Code: "DEU", numericCode: "276", phonePrefix: "49")

        let groups = [
            CompetitionGroup(
                id: "premier-league",
                name: "England",
                aggregationType: .region,
                competitions: premierLeagueCompetitions,
                country: englandCountry
            ),
            CompetitionGroup(
                id: "la-liga",
                name: "Spain",
                aggregationType: .region,
                competitions: laLigaCompetitions,
                country: spainCountry
            ),
            CompetitionGroup(
                id: "bundesliga",
                name: "Germany",
                aggregationType: .region,
                competitions: bundesligaCompetitions,
                country: germanyCountry
            )
        ]

        // Convert to view models
        viewModel.competitions = groups.map { group in
            CompetitionFilterSectionViewModel(index: 0, competitionGroup: group)
        }

        // Expand some sections by default
        viewModel.expandedSections.insert("premier-league")
        viewModel.expandedSections.insert("la-liga")

        // Select some competitions
        viewModel.toggleSelection("pl-1", in: "premier-league")
        viewModel.toggleSelection("la-1", in: "la-liga")

        return viewModel
    }

    static var previews: some View {
        Group {
            CompetitionsFiltersView2(
                viewModel: mockViewModel,
                applyFiltersAction: { _ in },
                didTapCompetitionNavigationAction: { _ in }
            )
            .previewDisplayName("Opened State")

            CompetitionsFiltersView2(
                viewModel: {
                    let vm = mockViewModel
                    vm.updateState(.bar)
                    return vm
                }(),
                applyFiltersAction: { _ in },
                didTapCompetitionNavigationAction: { _ in }
            )
            .previewDisplayName("Bar State")

            CompetitionsFiltersView2(
                viewModel: {
                    let vm = mockViewModel
                    vm.updateState(.line)
                    return vm
                }(),
                applyFiltersAction: { _ in },
                didTapCompetitionNavigationAction: { _ in }
            )
            .previewDisplayName("Line State")
        }
    }
}

// MARK: - Helpers
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                               byRoundingCorners: corners,
                               cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
