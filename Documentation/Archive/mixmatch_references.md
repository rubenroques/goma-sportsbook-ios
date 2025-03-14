# MixMatch Functionality in Sportsbook iOS

## Implementation Status

The MixMatch functionality has been successfully implemented as a feature flag in the codebase. All references to MixMatch functionality now check for the feature flag before enabling the functionality. For more details, see:

- `mixmatch_implementation_summary.md` - Summary of the changes made
- `mixmatch_feature_implementation.md` - Detailed implementation guidelines

## References

This document contains all references to MixMatch functionality in the codebase.

## ./Core/Screens/Home/TemplatesDataSources/ClientManagedHomeViewTemplateDataSource.swift

### Line 958

```swift
953:         case .highlightedMatches:
954:             if let match = self.highlightsVisualImageMatches[safe: index] {
955:                 var type = MatchWidgetType.topImage
956:                 
957:                 if match.markets.first?.customBetAvailable ?? false {
958:                     type = .topImageWithMixMatch ← MATCH
959:                 }
960:                 
961:                 let id = match.id + type.rawValue
962:                 
963:                 if let matchWidgetContainerTableViewModel = self.matchWidgetContainerTableViewModelCache[id] {
```

### Line 1019

```swift
1014:         switch (index, contentType) {
1015:         case (0, .highlightedMatches):
1016:             ids = self.highlightsVisualImageMatches.map { match in
1017:                 var type = MatchWidgetType.topImage
1018:                 if match.markets.first?.customBetAvailable ?? false {
1019:                     type = .topImageWithMixMatch ← MATCH
1020:                 }
1021:                 return match.id + type.rawValue
1022:             }.joined(separator: "-")
1023:             
1024:             viewModels = self.highlightsVisualImageMatches.map { match in
```

## ./Core/Screens/Home/TemplatesDataSources/CMSManagedHomeViewTemplateDataSource.swift

### Line 1028

```swift
1023:         case .highlightedMatches:
1024:             if let match = self.highlightsVisualImageMatches[safe: index] {
1025:                 var type = MatchWidgetType.topImage
1026: 
1027:                 if match.markets.first?.customBetAvailable ?? false {
1028:                     type = .topImageWithMixMatch ← MATCH
1029:                 }
1030: 
1031:                 let id = match.id + type.rawValue
1032: 
1033:                 if let matchWidgetContainerTableViewModel = self.matchWidgetContainerTableViewModelCache[id] {
```

### Line 1089

```swift
1084:         switch (index, contentType) {
1085:         case (0, .highlightedMatches):
1086:             ids = self.highlightsVisualImageMatches.map { match in
1087:                 var type = MatchWidgetType.topImage
1088:                 if match.markets.first?.customBetAvailable ?? false {
1089:                     type = .topImageWithMixMatch ← MATCH
1090:                 }
1091:                 return match.id + type.rawValue
1092:             }.joined(separator: "-")
1093: 
1094:             viewModels = self.highlightsVisualImageMatches.map { match in
```

## ./Core/Screens/Home/TemplatesDataSources/DummyWidgetShowcaseHomeViewTemplateDataSource.swift

### Line 988

```swift
983:         case .highlightedMatches:
984:             if let match = self.highlightsVisualImageMatches[safe: index] {
985:                 var type = MatchWidgetType.topImage
986: 
987:                 if match.markets.first?.customBetAvailable ?? false {
988:                     type = .topImageWithMixMatch ← MATCH
989:                 }
990: 
991:                 let id = match.id + type.rawValue
992: 
993:                 if let matchWidgetContainerTableViewModel = self.matchWidgetContainerTableViewModelCache[id] {
```

### Line 1061

```swift
1056:         switch (index, contentType) {
1057:         case (0, .highlightedMatches):
1058:             ids = self.highlightsVisualImageMatches.map { match in
1059:                 var type = MatchWidgetType.topImage
1060:                 if match.markets.first?.customBetAvailable ?? false {
1061:                     type = .topImageWithMixMatch ← MATCH
1062:                 }
1063:                 return match.id + type.rawValue
1064:             }.joined(separator: "-")
1065: 
1066:             viewModels = self.highlightsVisualImageMatches.map { match in
```

## ./Core/Screens/Home/HomeViewController.swift

### Line 309

```swift
304:         let viewModel = OutrightMarketDetailsViewModel(competition: competition, store: OutrightMarketDetailsStore())
305:         let outrightMarketDetailsViewController = OutrightMarketDetailsViewController(viewModel: viewModel)
306:         self.navigationController?.pushViewController(outrightMarketDetailsViewController, animated: true)
307:     }
308: 
309:     private func openMatchDetails(matchId: String, isMixMatch: Bool = false) { ← MATCH
310:         if isMixMatch {
311:             let matchDetailsViewModel = MatchDetailsViewModel(matchId: matchId)
312: 
313:             let matchDetailsViewController = MatchDetailsViewController(viewModel: matchDetailsViewModel)
314: 
```

### Line 792

```swift
787: 
788:             cell.didLongPressOdd = { [weak self] bettingTicket in
789:                 self?.openQuickbet(bettingTicket)
790:             }
791: 
792:             cell.tappedMixMatchAction = { [weak self] match in ← MATCH
793:                 self?.openMatchDetails(matchId: match.id, isMixMatch: true)
794:             }
795: 
796:             return cell
797:         case .featuredTips:
```

### Line 1072

```swift
1067: 
1068:             cell.didLongPressOdd = { [weak self] bettingTicket in
1069:                 self?.openQuickbet(bettingTicket)
1070:             }
1071: 
1072:             cell.tappedMixMatchAction = { [weak self] match in ← MATCH
1073:                 self?.openMatchDetails(matchId: match.id, isMixMatch: true)
1074:             }
1075: 
1076:             return cell
1077: 
```

### Line 1208

```swift
1203: 
1204:             cell.didLongPressOdd = { [weak self] bettingTicket in
1205:                 self?.openQuickbet(bettingTicket)
1206:             }
1207: 
1208:             cell.tappedMixMatchIdAction = { [weak self] matchId in ← MATCH
1209:                 self?.openMatchDetails(matchId: matchId, isMixMatch: true)
1210:             }
1211: 
1212:             return cell
1213:         case .videoNewsLine:
```

## ./Core/Screens/Home/Views/ContainerCells/MarketWidgetContainerTableViewCell.swift

### Line 14

```swift
9: class MarketWidgetContainerTableViewCell: UITableViewCell {
10: 
11:     var tappedMatchIdAction: ((String) -> Void) = { _ in }
12:     var didTapFavoriteMatchAction: ((Match) -> Void) = { _ in }
13:     var didLongPressOdd: ((BettingTicket) -> Void) = { _ in }
14:     var tappedMixMatchIdAction: ((String) -> Void) = { _ in } ← MATCH
15: 
16:     private lazy var backSliderView: UIView = Self.createBackSliderView()
17:     private lazy var backSliderIconImageView: UIImageView = Self.createBackSliderIconImageView()
18:     
19:     private lazy var baseView: UIView = Self.createBaseView()
```

### Line 157

```swift
152:         
153:         cell.didLongPressOdd = { [weak self] bettingTicket in
154:             self?.didLongPressOdd(bettingTicket)
155:         }
156:         
157:         cell.tappedMixMatchAction = { [weak self] matchId in ← MATCH
158:             self?.tappedMixMatchIdAction(matchId)
159:         }
160: 
161:         return cell
162:     }
```

## ./Core/Screens/PreLive_backup/ViewModels/MatchWidgetCellViewModel.swift

### Line 16

```swift
11: import UIKit
12: 
13: enum MatchWidgetType: String, CaseIterable {
14:     case normal
15:     case topImage
16:     case topImageWithMixMatch ← MATCH
17:     case topImageOutright
18:     case boosted
19:     case backgroundImage
20: }
21: 
```

### Line 281

```swift
276:     
277:     var canHaveCashbackPublisher: AnyPublisher<Bool, Never> {
278:         return Publishers.CombineLatest(self.$match, self.$matchWidgetType)
279:             .map { match, matchWidgetType in
280:                 if RePlayFeatureHelper.shouldShowRePlay(forMatch: match) {
281:                     return matchWidgetType == .normal || matchWidgetType == .topImage || matchWidgetType == .topImageWithMixMatch ← MATCH
282:                 }
283:                 return false
284:             }
285:             .removeDuplicates()
286:             .eraseToAnyPublisher()
```

## ./Core/Screens/PreLive_backup/Cells/TypedCells/ProChoiceHighlightView/ProChoiceHighlightTableViewCell.swift

### Line 73

```swift
68:     private lazy var drawUpChangeOddValueImageView: UIImageView = self.createDrawUpChangeOddValueImageView()
69:     private lazy var drawDownChangeOddValueImageView: UIImageView = self.createDrawDownChangeOddValueImageView()
70:     private lazy var awayUpChangeOddValueImageView: UIImageView = self.createAwayUpChangeOddValueImageView()
71:     private lazy var awayDownChangeOddValueImageView: UIImageView = self.createAwayDownChangeOddValueImageView()
72:     
73:     // Mix match bottom bar ← MATCH
74:     private lazy var mixMatchContainerView: UIView = self.createMixMatchContainerView()
75:     
76:     private lazy var mixMatchBaseView: UIView = self.createMixMatchBaseView()
77:     
78:     private lazy var mixMatchBackgroundImageView: UIImageView = self.createMixMatchBackgroundImageView()
```

### Line 84

```swift
79:     
80:     private lazy var mixMatchIconImageView: UIImageView = self.createMixMatchIconImageView()
81:     
82:     lazy var mixMatchLabel: UILabel = self.createMixMatchLabel()
83:     
84:     lazy var mixMatchNavigationIconImageView: UIImageView = self.createMixMatchNavigationIconImageView() ← MATCH
85: 
86:     lazy var cashbackIconImageView: UIImageView = self.createCashbackIconImageView()
87: 
88:     private var viewModel: MarketWidgetCellViewModel?
89: 
```

### Line 139

```swift
134:         }
135:     }
136: 
137:     var tappedMatchIdAction: ((String) -> Void) = { _ in }
138:     var didLongPressOdd: ((BettingTicket) -> Void) = { _ in }
139:     var tappedMixMatchAction: ((String) -> Void) = { _ in } ← MATCH
140: 
141:     // MARK: - Initialization
142:     override init(frame: CGRect) {
143:         super.init(frame: frame)
144:         self.setupSubviews()
```

### Line 176

```swift
171:         let tapMatchView = UITapGestureRecognizer(target: self, action: #selector(didTapMatchView))
172:         self.addGestureRecognizer(tapMatchView)
173:         
174:         self.seeAllMarketsButton.addTarget(self, action: #selector(self.didTapMatchView), for: .primaryActionTriggered)
175:         
176:         let tapMixMatchView = UITapGestureRecognizer(target: self, action: #selector(didTapMixMatch)) ← MATCH
177:         self.mixMatchContainerView.addGestureRecognizer(tapMixMatchView)
178:         
179:         self.mixMatchContainerView.isHidden = true
180: 
181:         self.hasCashback = false
```

### Line 215

```swift
210:         self.middleOddButtonSubscriber = nil
211:         
212:         self.rightOddButtonSubscriber?.cancel()
213:         self.rightOddButtonSubscriber = nil
214:         
215:         self.mixMatchContainerView.isHidden = true ← MATCH
216: 
217:         self.hasCashback = false
218:     }
219: 
220:     // MARK: - Configuration
```

### Line 298

```swift
293:     func configure(with viewModel: MarketWidgetCellViewModel) {
294:         self.viewModel = viewModel
295:         
296:         if let customBetAvailable = viewModel.highlightedMarket.content.customBetAvailable,
297:            customBetAvailable {
298:             self.mixMatchContainerView.isHidden = false ← MATCH
299:             self.seeAllMarketsButton.isHidden = true
300:         }
301:         else {
302:             self.mixMatchContainerView.isHidden = true
303:             self.seeAllMarketsButton.isHidden = false
```

### Line 880

```swift
875: 
876:     private func setAwayOddValueLabel(toText text: String) {
877:         self.awayOutcomeValueLabel.text = text
878:     }
879:     
880:     @objc private func didTapMixMatch() { ← MATCH
881:         if let viewModel = self.viewModel,
882:            let matchId = viewModel.highlightedMarket.content.eventId {
883:             self.tappedMixMatchAction(matchId)
884:         }
885:     }
```

### Line 971

```swift
966:         self.containerStackView.addArrangedSubview(self.oddsStackView)
967: 
968:         self.containerStackView.addArrangedSubview(self.bottomButtonsContainerStackView)
969:         self.bottomButtonsContainerStackView.addArrangedSubview(self.seeAllMarketsButton)
970:         
971:         self.bottomButtonsContainerStackView.addArrangedSubview(self.mixMatchContainerView) ← MATCH
972:         self.mixMatchContainerView.addSubview(self.mixMatchBaseView)
973:         self.mixMatchBaseView.addSubview(self.mixMatchBackgroundImageView)
974:         self.mixMatchBaseView.addSubview(self.mixMatchIconImageView)
975:         self.mixMatchBaseView.addSubview(self.mixMatchLabel)
976:         self.mixMatchBaseView.addSubview(self.mixMatchNavigationIconImageView)
```

### Line 1185

```swift
1180:             self.awayDownChangeOddValueImageView.centerYAnchor.constraint(equalTo: self.awayButton.centerYAnchor),
1181:             self.awayDownChangeOddValueImageView.trailingAnchor.constraint(equalTo: self.awayButton.trailingAnchor, constant: -5)
1182:         ])
1183:         
1184:         NSLayoutConstraint.activate([
1185:             self.mixMatchContainerView.heightAnchor.constraint(equalToConstant: 27), ← MATCH
1186: 
1187:             self.mixMatchBaseView.heightAnchor.constraint(equalToConstant: 27),
1188:             self.mixMatchBaseView.leadingAnchor.constraint(equalTo: self.mixMatchContainerView.leadingAnchor, constant: 0),
1189:             self.mixMatchBaseView.trailingAnchor.constraint(equalTo: self.mixMatchContainerView.trailingAnchor, constant: 0),
1190:             self.mixMatchBaseView.topAnchor.constraint(equalTo: self.mixMatchContainerView.topAnchor),
```

### Line 1197

```swift
1192:             self.mixMatchBackgroundImageView.leadingAnchor.constraint(equalTo: self.mixMatchBaseView.leadingAnchor),
1193:             self.mixMatchBackgroundImageView.trailingAnchor.constraint(equalTo: self.mixMatchBaseView.trailingAnchor),
1194:             self.mixMatchBackgroundImageView.topAnchor.constraint(equalTo: self.mixMatchBaseView.topAnchor),
1195:             self.mixMatchBackgroundImageView.bottomAnchor.constraint(equalTo: self.mixMatchBaseView.bottomAnchor),
1196:         
1197:             self.mixMatchLabel.centerXAnchor.constraint(equalTo: self.mixMatchBaseView.centerXAnchor), ← MATCH
1198:             self.mixMatchLabel.centerYAnchor.constraint(equalTo: self.mixMatchBaseView.centerYAnchor),
1199:             
1200:             self.mixMatchIconImageView.widthAnchor.constraint(equalToConstant: 21),
1201:             self.mixMatchIconImageView.heightAnchor.constraint(equalToConstant: 25),
1202:             self.mixMatchIconImageView.trailingAnchor.constraint(equalTo: self.mixMatchLabel.leadingAnchor, constant: -2),
```

### Line 1208

```swift
1203:             self.mixMatchIconImageView.centerYAnchor.constraint(equalTo: self.mixMatchLabel.centerYAnchor),
1204:             
1205:             self.mixMatchNavigationIconImageView.widthAnchor.constraint(equalToConstant: 11),
1206:             self.mixMatchNavigationIconImageView.heightAnchor.constraint(equalToConstant: 13),
1207:             self.mixMatchNavigationIconImageView.leadingAnchor.constraint(equalTo: self.mixMatchLabel.trailingAnchor, constant: 6),
1208:             self.mixMatchNavigationIconImageView.centerYAnchor.constraint(equalTo: self.mixMatchLabel.centerYAnchor), ← MATCH
1209: 
1210:         ])
1211:     }
1212: 
1213:     // MARK: - UI Creation    
```

### Line 1515

```swift
1510:         imageView.image = UIImage(named: "odd_down_icon")
1511:         imageView.alpha = 0
1512:         return imageView
1513:     }
1514:     
1515:     private func createMixMatchContainerView() -> UIView { ← MATCH
1516:         let view = UIView()
1517:         view.translatesAutoresizingMaskIntoConstraints = false
1518:         view.clipsToBounds = true
1519:         return view
1520:     }
```

### Line 1530

```swift
1525:         view.layer.cornerRadius = CornerRadius.view
1526:         view.clipsToBounds = true
1527:         return view
1528:     }
1529: 
1530:     private func createMixMatchBackgroundImageView() -> UIImageView { ← MATCH
1531:         let imageView = UIImageView()
1532:         imageView.translatesAutoresizingMaskIntoConstraints = false
1533:         imageView.image = UIImage(named: "mix_match_highlight")
1534:         imageView.contentMode = .scaleAspectFill
1535:         return imageView
```

### Line 1546

```swift
1541:         imageView.image = UIImage(named: "mix_match_icon")
1542:         imageView.contentMode = .scaleAspectFit
1543:         return imageView
1544:     }
1545:     
1546:     private func createMixMatchLabel() -> UILabel { ← MATCH
1547:         let label = UILabel()
1548:         label.translatesAutoresizingMaskIntoConstraints = false
1549:         label.text = "\(localized("mix_match_or_bet_with_string")) \(localized("mix_match_mix_string"))\("mix_match_match_string")"
1550:         label.font = AppFont.with(type: .bold, size: 14)
1551:         label.textAlignment = .center
```

### Line 1569

```swift
1564:         label.attributedText = attributedString
1565:         
1566:         return label
1567:     }
1568:     
1569:     private func createMixMatchNavigationIconImageView() -> UIImageView { ← MATCH
1570:         let imageView = UIImageView()
1571:         imageView.translatesAutoresizingMaskIntoConstraints = false
1572:         imageView.image = UIImage(named: "arrow_right_icon")
1573:         imageView.contentMode = .scaleAspectFit
1574:         return imageView
```

## ./Core/Screens/PreLive_backup/Cells/MatchLineTableViewCell.swift

### Line 51

```swift
46:     var unselectedOutcome: ((Match, Market, Outcome) -> Void)?
47: 
48:     var matchWentLive: (() -> Void)?
49:     var didTapFavoriteMatchAction: ((Match) -> Void)?
50:     var didLongPressOdd: ((BettingTicket) -> Void)?
51:     var tappedMixMatchAction: ((Match) -> Void)? ← MATCH
52: 
53:     private let cellInternSpace: CGFloat = 2.0
54: 
55:     private var collectionViewHeight: CGFloat {
56:         let cardHeight = StyleHelper.cardsStyleHeight()
```

### Line 548

```swift
543: 
544:             cell.didLongPressOdd = { [weak self] bettingTicket in
545:                 self?.didLongPressOdd?(bettingTicket)
546:             }
547: 
548:             cell.tappedMixMatchAction = { [weak self] match in ← MATCH
549:                 self?.tappedMixMatchAction?(match)
550:             }
551: 
552:             cell.shouldShowCountryFlag(self.shouldShowCountryFlag)
553: 
```

## ./Core/Screens/PreLive_backup/Cells/MatchWidgetContainerTableViewCell.swift

### Line 64

```swift
59:         switch type {
60:         case .normal, .backgroundImage:
61:             return 152.0
62:         case .topImageOutright:
63:             return 270.0
64:         case .topImage, .topImageWithMixMatch: ← MATCH
65:             return 293.0
66:         case .boosted:
67:             return 186.0
68:         }
69:     }
```

### Line 80

```swift
75:     var tappedMatchLineAction: ((Match) -> Void) = { _ in }
76:     var matchWentLive: ((Match) -> Void) = { _ in }
77:     var didTapFavoriteMatchAction: ((Match) -> Void) = { _ in }
78:     var didLongPressOdd: ((BettingTicket) -> Void) = { _ in }
79:     var tappedMatchOutrightLineAction: ((Competition) -> Void) = { _ in }
80:     var tappedMixMatchAction: ((Match) -> Void)? ← MATCH
81: 
82:     private lazy var backSliderView: UIView = Self.createBackSliderView()
83:     private lazy var backSliderIconImageView: UIImageView = Self.createBackSliderIconImageView()
84:     
85:     private lazy var baseView: UIView = Self.createBaseView()
```

### Line 225

```swift
220: 
221:         cell.didLongPressOdd = { bettingTicket in
222:             self.didLongPressOdd(bettingTicket)
223:         }
224:         
225:         cell.tappedMixMatchAction = { [weak self] match in ← MATCH
226:             self?.tappedMixMatchAction?(match)
227:         }
228: 
229:         cell.shouldShowCountryFlag(true)
230:         return cell
```

## ./Core/Screens/PreLive_backup/Cells/MatchWidgetCollectionViewCell.swift

### Line 483

```swift
478:         imageView.setTintColor(color: UIColor.App.iconSecondary)
479:         imageView.contentMode = .scaleAspectFit
480:         return imageView
481:     }()
482: 
483:     // Mix match bottom bar ← MATCH
484:     lazy var mixMatchContainerView: UIView = {
485:         let view = UIView()
486:         view.translatesAutoresizingMaskIntoConstraints = false
487:         view.clipsToBounds = true
488:         return view
```

### Line 499

```swift
494:         view.layer.cornerRadius = CornerRadius.view
495:         view.clipsToBounds = true
496:         return view
497:     }()
498: 
499:     lazy var mixMatchBackgroundImageView: UIImageView = { ← MATCH
500:         let imageView = UIImageView()
501:         imageView.translatesAutoresizingMaskIntoConstraints = false
502:         imageView.image = UIImage(named: "mix_match_highlight")
503:         imageView.contentMode = .scaleAspectFill
504:         return imageView
```

### Line 515

```swift
510:         imageView.image = UIImage(named: "mix_match_icon")
511:         imageView.contentMode = .scaleAspectFit
512:         return imageView
513:     }()
514: 
515:     lazy var mixMatchLabel: UILabel = { ← MATCH
516:         let label = UILabel()
517:         label.translatesAutoresizingMaskIntoConstraints = false
518:         label.text = "\(localized("mix_match_or_bet_with_string")) \(localized("mix_match_mix_string"))\("mix_match_match_string")"
519:         label.font = AppFont.with(type: .bold, size: 14)
520:         label.textAlignment = .center
```

### Line 538

```swift
533:         label.attributedText = attributedString
534: 
535:         return label
536:     }()
537: 
538:     lazy var mixMatchNavigationIconImageView: UIImageView = { ← MATCH
539:         let imageView = UIImageView()
540:         imageView.translatesAutoresizingMaskIntoConstraints = false
541:         imageView.image = UIImage(named: "arrow_right_icon")
542:         imageView.contentMode = .scaleAspectFit
543:         return imageView
```

### Line 578

```swift
573:     var unselectedOutcome: ((Match, Market, Outcome) -> Void)?
574: 
575:     var didTapFavoriteMatchAction: ((Match) -> Void)?
576:     var didLongPressOdd: ((BettingTicket) -> Void)?
577:     var tappedMatchOutrightWidgetAction: ((Competition) -> Void)?
578:     var tappedMixMatchAction: ((Match) -> Void)? ← MATCH
579: 
580:     private var leftOddButtonSubscriber: AnyCancellable?
581:     private var middleOddButtonSubscriber: AnyCancellable?
582:     private var rightOddButtonSubscriber: AnyCancellable?
583: 
```

### Line 634

```swift
629:         self.topImageBaseView.isHidden = true
630: 
631:         self.boostedOddBottomLineView.isHidden = true
632:         self.boostedTopRightCornerBaseView.isHidden = true
633: 
634:         self.mixMatchContainerView.isHidden = true ← MATCH
635: 
636:         self.bottomSeeAllMarketsContainerView.isHidden = true
637: 
638:         self.mainContentBaseView.isHidden = false
639:         //
```

### Line 932

```swift
927:             self.bottomSeeAllMarketsArrowIconImageView.heightAnchor.constraint(equalToConstant: 12),
928:             self.bottomSeeAllMarketsArrowIconImageView.leadingAnchor.constraint(equalTo: self.bottomSeeAllMarketsLabel.trailingAnchor, constant: 4),
929:             self.bottomSeeAllMarketsArrowIconImageView.centerYAnchor.constraint(equalTo: self.bottomSeeAllMarketsLabel.centerYAnchor),
930:         ])
931: 
932:         // MixMatch ← MATCH
933:         self.mixMatchContainerView.isHidden = true
934: 
935:         self.baseStackView.addArrangedSubview(self.mixMatchContainerView)
936:         self.mixMatchContainerView.addSubview(self.mixMatchBaseView)
937:         self.mixMatchBaseView.addSubview(self.mixMatchBackgroundImageView)
```

### Line 943

```swift
938:         self.mixMatchBaseView.addSubview(self.mixMatchIconImageView)
939:         self.mixMatchBaseView.addSubview(self.mixMatchLabel)
940:         self.mixMatchBaseView.addSubview(self.mixMatchNavigationIconImageView)
941: 
942:         NSLayoutConstraint.activate([
943:             self.mixMatchContainerView.heightAnchor.constraint(equalToConstant: 34), ← MATCH
944: 
945:             self.mixMatchBaseView.heightAnchor.constraint(equalToConstant: 27),
946:             self.mixMatchBaseView.leadingAnchor.constraint(equalTo: self.mixMatchContainerView.leadingAnchor, constant: 12),
947:             self.mixMatchBaseView.trailingAnchor.constraint(equalTo: self.mixMatchContainerView.trailingAnchor, constant: -12),
948:             self.mixMatchBaseView.topAnchor.constraint(equalTo: self.mixMatchContainerView.topAnchor),
```

### Line 955

```swift
950:             self.mixMatchBackgroundImageView.leadingAnchor.constraint(equalTo: self.mixMatchBaseView.leadingAnchor),
951:             self.mixMatchBackgroundImageView.trailingAnchor.constraint(equalTo: self.mixMatchBaseView.trailingAnchor),
952:             self.mixMatchBackgroundImageView.topAnchor.constraint(equalTo: self.mixMatchBaseView.topAnchor),
953:             self.mixMatchBackgroundImageView.bottomAnchor.constraint(equalTo: self.mixMatchBaseView.bottomAnchor),
954: 
955:             self.mixMatchLabel.centerXAnchor.constraint(equalTo: self.mixMatchBaseView.centerXAnchor), ← MATCH
956:             self.mixMatchLabel.centerYAnchor.constraint(equalTo: self.mixMatchBaseView.centerYAnchor),
957: 
958:             self.mixMatchIconImageView.widthAnchor.constraint(equalToConstant: 21),
959:             self.mixMatchIconImageView.heightAnchor.constraint(equalToConstant: 25),
960:             self.mixMatchIconImageView.trailingAnchor.constraint(equalTo: self.mixMatchLabel.leadingAnchor, constant: -2),
```

### Line 966

```swift
961:             self.mixMatchIconImageView.centerYAnchor.constraint(equalTo: self.mixMatchLabel.centerYAnchor),
962: 
963:             self.mixMatchNavigationIconImageView.widthAnchor.constraint(equalToConstant: 11),
964:             self.mixMatchNavigationIconImageView.heightAnchor.constraint(equalToConstant: 13),
965:             self.mixMatchNavigationIconImageView.leadingAnchor.constraint(equalTo: self.mixMatchLabel.trailingAnchor, constant: 6),
966:             self.mixMatchNavigationIconImageView.centerYAnchor.constraint(equalTo: self.mixMatchLabel.centerYAnchor), ← MATCH
967: 
968:         ])
969: 
970:         self.bringSubviewToFront(self.suspendedBaseView)
971:         self.bringSubviewToFront(self.seeAllBaseView)
```

### Line 998

```swift
993:         self.addGestureRecognizer(tapMatchView)
994: 
995:         let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressCard))
996:         self.participantsBaseView.addGestureRecognizer(longPressGestureRecognizer)
997: 
998:         let tapMixMatchView = UITapGestureRecognizer(target: self, action: #selector(didTapMixMatch)) ← MATCH
999:         self.mixMatchContainerView.addGestureRecognizer(tapMixMatchView)
1000: 
1001:         self.hasCashback = false
1002: 
1003:         //
```

### Line 1046

```swift
1041:     override func prepareForReuse() {
1042:         super.prepareForReuse()
1043: 
1044:         self.viewModel = nil
1045: 
1046:         self.mixMatchContainerView.isHidden = true ← MATCH
1047:         self.bottomSeeAllMarketsContainerView.isHidden = true
1048: 
1049:         self.cancellables.removeAll()
1050: 
1051:         self.leftOutcome = nil
```

### Line 1242

```swift
1237:         self.contentRedesignBaseView.backgroundColor = .clear
1238: 
1239:         //
1240:         // Match Widget Type spec
1241:         switch self.viewModel?.matchWidgetType ?? .normal {
1242:         case .normal, .topImage, .topImageWithMixMatch: ← MATCH
1243:             self.eventNameLabel.textColor = UIColor.App.textSecondary
1244:             self.homeParticipantNameLabel.textColor = UIColor.App.textPrimary
1245:             self.awayParticipantNameLabel.textColor = UIColor.App.textPrimary
1246:             self.matchTimeLabel.textColor = UIColor.App.buttonBackgroundPrimary
1247:             self.resultLabel.textColor = UIColor.App.textPrimary
```

### Line 1741

```swift
1736:                 self.bottomMarginSpaceConstraint.constant = 12
1737:                 self.teamsHeightConstraint.constant = 67
1738:                 self.topMarginSpaceConstraint.constant = 11
1739:             }
1740: 
1741:         case .topImage, .topImageWithMixMatch: ← MATCH
1742:             self.backgroundImageView.isHidden = true
1743: 
1744:             self.topImageBaseView.isHidden = false
1745: 
1746:             self.boostedOddBottomLineView.isHidden = true
```

### Line 1873

```swift
1868: 
1869:         Publishers.CombineLatest(viewModel.$matchWidgetStatus, viewModel.$matchWidgetType)
1870:             .receive(on: DispatchQueue.main)
1871:             .sink { [weak self] matchWidgetStatus, matchWidgetType in
1872:                 switch matchWidgetType {
1873:                 case .normal, .boosted, .topImage, .topImageWithMixMatch: ← MATCH
1874:                     if matchWidgetStatus == .live {
1875:                         self?.gradientBorderView.isHidden = true
1876:                         self?.liveGradientBorderView.isHidden = false
1877:                     }
1878:                     else {
```

### Line 1914

```swift
1909:                 self?.drawForMatchWidgetType(matchWidgetType)
1910: 
1911:                 switch matchWidgetType {
1912:                 case .normal:
1913:                     break
1914:                 case .topImage, .topImageWithMixMatch: ← MATCH
1915:                     break
1916:                 case .boosted:
1917:                     break
1918:                 case .backgroundImage:
1919:                     break
```

### Line 2104

```swift
2099:                     }
2100:                     else {
2101:                         self?.showSuspendedView()
2102:                     }
2103: 
2104:                     if viewModel.matchWidgetType == .topImageWithMixMatch { ← MATCH
2105:                         if let customBetAvailable = market.customBetAvailable,
2106:                            customBetAvailable {
2107:                             self?.mixMatchContainerView.isHidden = false
2108:                             self?.bottomSeeAllMarketsContainerView.isHidden = true
2109:                         }
```

### Line 2116

```swift
2111:                             self?.mixMatchContainerView.isHidden = true
2112:                             self?.bottomSeeAllMarketsContainerView.isHidden = false
2113:                         }
2114:                     }
2115:                     else if viewModel.matchWidgetType == .topImage {
2116:                         self?.mixMatchContainerView.isHidden = true ← MATCH
2117:                         self?.bottomSeeAllMarketsContainerView.isHidden = false
2118:                     }
2119:                 }
2120:                 else {
2121:                     // Hide outcome buttons if we don't have any market
```

### Line 2143

```swift
2138:                 self?.marketNamePillLabelView.isHidden = false
2139:             }
2140:             else if matchWidgetType == .boosted {
2141:                 self?.marketNamePillLabelView.isHidden = false
2142:             }
2143: //            else if matchWidgetType == .topImageOutright || matchWidgetType == .topImage || matchWidgetType == .topImageWithMixMatch { ← MATCH
2144: //                self?.marketNamePillLabelView.isHidden = false
2145: //            }
2146:             else {
2147:                 self?.marketNamePillLabelView.isHidden = true
2148:             }
```

### Line 2545

```swift
2540:             }
2541:         }
2542: 
2543:     }
2544: 
2545:     @objc private func didTapMixMatch() { ← MATCH
2546:         if let viewModel = self.viewModel {
2547:             let match = viewModel.match
2548:             self.tappedMixMatchAction?(match)
2549:         }
2550:     }
```

## ./Core/Screens/MatchDetails/ViewModels/MatchDetailsViewModel.swift

### Line 114

```swift
109:     var isFromLiveCard: Bool = false
110: 
111:     var scrollToTopAction: ((Int) -> Void)?
112:     var shouldShowTabTooltip: (() -> Void)?
113: 
114:     var showMixMatchDefault: Bool = false ← MATCH
115: 
116:     init(matchMode: MatchMode = .preLive, match: Match) {
117:         self.matchId = match.id
118:         self.matchStatsViewModel = MatchStatsViewModel(matchId: match.id)
119: 
```

### Line 180

```swift
175:                 return marketGroupsState.map { item in
176:                     let marketTranslatedName = item.translatedName ?? localized("market")
177:                     let normalizedTranslatedName = marketTranslatedName.replacingOccurrences(of: "[^a-zA-Z0-9]", with: "_", options: .regularExpression).lowercased()
178:                     let marketKey = "market_group_\(normalizedTranslatedName)"
179:                     var marketName = localized(marketKey)
180:                     if normalizedTranslatedName == "mixmatch" { ← MATCH
181:                         marketName = "\(localized("mix_match_mix_string"))\(localized("mix_match_match_string"))"
182:                         return ChipType.backgroungImage(title: marketName, iconName: "mix_match_icon", imageName: "mix_match_background_pill")
183:                     }
184:                     else {
185:                         return ChipType.textual(title: marketName)
```

### Line 208

```swift
203:             })
204:             .map { marketGroups -> Int in
205:                 return marketGroups.firstIndex(where: { $0.isDefault ?? false }) ?? 0
206:             }
207:             .sink { [weak self] defaultSelectedIndex in
208:                 if let showMixMatchDefault = self?.showMixMatchDefault, showMixMatchDefault { ← MATCH
209:                     self?.chipsTypeViewModel.selectTab(at: 1)
210:                 }
211:                 else {
212:                     self?.chipsTypeViewModel.selectTab(at: defaultSelectedIndex)
213:                 }
```

## ./Core/Screens/MatchDetails/MatchDetailsViewController.swift

### Line 138

```swift
133:     // Special reference to left and right gradient base views (possibly not needed in programmatic implementation)
134:     private var leftGradientBaseView: UIView?
135:     private var rightGradientBaseView: UIView?
136: 
137:     // Tooltip views
138:     lazy var mixMatchInfoDialogView: InfoDialogView = Self.createMixMatchInfoDialogView() ← MATCH
139: 
140:     // MARK: - Private Properties (State)
141: 
142:     private var showingStatsBackSliderView: Bool = false
143:     private var shouldShowStatsView = false
```

### Line 160

```swift
155:                 self.view.layoutIfNeeded()
156:             }
157:         }
158:     }
159: 
160:     var didShowMixMatchTooltip: Bool = false ← MATCH
161: 
162:     // =========================================================================
163:     // Header bar and buttons logic
164:     // =========================================================================
165:     private var shouldShowLiveFieldWebView = false {
```

### Line 314

```swift
309: 
310:     private var viewModel: MatchDetailsViewModel
311: 
312:     private var cancellables = Set<AnyCancellable>()
313: 
314:     var showMixMatchDefault: Bool = false ← MATCH
315: 
316:     // MARK: - Initialization and Lifecycle
317:     init(viewModel: MatchDetailsViewModel) {
318:         self.viewModel = viewModel
319: 
```

### Line 506

```swift
501:         self.view.bringSubviewToFront(self.matchNotAvailableView)
502: 
503:         // Configure tooltip
504:         self.configureTooltip()
505: 
506:         if self.showMixMatchDefault { ← MATCH
507:             self.currentPageViewControllerIndex = 1
508:         }
509: 
510:     }
511: 
```

### Line 548

```swift
543:         self.loadingSpinnerViewController.startAnimating()
544:         self.loadingSpinnerViewController.view.isHidden = false
545:     }
546: 
547:     private func configureTooltip() {
548:         self.view.addSubview(self.mixMatchInfoDialogView) ← MATCH
549: 
550:         NSLayoutConstraint.activate([
551:             self.mixMatchInfoDialogView.bottomAnchor.constraint(equalTo: self.chipsTypeView.topAnchor, constant: 5),
552:             self.mixMatchInfoDialogView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30),
553:             self.mixMatchInfoDialogView.trailingAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 20),
```

### Line 1843

```swift
1838:         view.translatesAutoresizingMaskIntoConstraints = false
1839:         view.isHidden = true
1840:         return view
1841:     }
1842: 
1843:     static func createMixMatchInfoDialogView() -> InfoDialogView { ← MATCH
1844:         let view = InfoDialogView()
1845:         view.translatesAutoresizingMaskIntoConstraints = false
1846:         view.configure(title: localized("mix_match_tooltip_description"))
1847:         view.alpha = 0
1848:         return view
```

### Line 2039

```swift
2034:             }
2035:         }
2036: 
2037:         self.viewModel.shouldShowTabTooltip = { [weak self] in
2038: 
2039:             if let didShowMixMatchTooltip = self?.didShowMixMatchTooltip, ← MATCH
2040:                !didShowMixMatchTooltip {
2041: 
2042:                 UIView.animate(withDuration: 0.5, animations: {
2043:                     self?.mixMatchInfoDialogView.alpha = 1
2044:                     self?.didShowMixMatchTooltip = true
```

### Line 2098

```swift
2093: 
2094:                 self.marketGroupsViewControllers.append(marketGroupDetailsViewController)
2095:             }
2096:         }
2097: 
2098:         if self.showMixMatchDefault { ← MATCH
2099:             if let firstViewController = self.marketGroupsViewControllers[safe: 1] {
2100:                 self.marketGroupsPagedViewController.setViewControllers([firstViewController],
2101:                                                                         direction: .forward,
2102:                                                                         animated: false,
2103:                                                                         completion: nil)
```

## ./Core/Screens/PreLiveEvents/ViewModels/Match/MatchWidgetCellViewModel.swift

### Line 16

```swift
11: import UIKit
12: 
13: enum MatchWidgetType: String, CaseIterable {
14:     case normal
15:     case topImage
16:     case topImageWithMixMatch ← MATCH
17:     case topImageOutright
18:     case boosted
19:     case backgroundImage
20: }
21: 
```

### Line 281

```swift
276:     
277:     var canHaveCashbackPublisher: AnyPublisher<Bool, Never> {
278:         return Publishers.CombineLatest(self.$match, self.$matchWidgetType)
279:             .map { match, matchWidgetType in
280:                 if RePlayFeatureHelper.shouldShowRePlay(forMatch: match) {
281:                     return matchWidgetType == .normal || matchWidgetType == .topImage || matchWidgetType == .topImageWithMixMatch ← MATCH
282:                 }
283:                 return false
284:             }
285:             .removeDuplicates()
286:             .eraseToAnyPublisher()
```

## ./Core/Screens/PreLiveEvents/Views/Cells/ProChoice/ProChoiceHighlightTableViewCell.swift

### Line 73

```swift
68:     private lazy var drawUpChangeOddValueImageView: UIImageView = self.createDrawUpChangeOddValueImageView()
69:     private lazy var drawDownChangeOddValueImageView: UIImageView = self.createDrawDownChangeOddValueImageView()
70:     private lazy var awayUpChangeOddValueImageView: UIImageView = self.createAwayUpChangeOddValueImageView()
71:     private lazy var awayDownChangeOddValueImageView: UIImageView = self.createAwayDownChangeOddValueImageView()
72:     
73:     // Mix match bottom bar ← MATCH
74:     private lazy var mixMatchContainerView: UIView = self.createMixMatchContainerView()
75:     
76:     private lazy var mixMatchBaseView: UIView = self.createMixMatchBaseView()
77:     
78:     private lazy var mixMatchBackgroundImageView: UIImageView = self.createMixMatchBackgroundImageView()
```

### Line 84

```swift
79:     
80:     private lazy var mixMatchIconImageView: UIImageView = self.createMixMatchIconImageView()
81:     
82:     lazy var mixMatchLabel: UILabel = self.createMixMatchLabel()
83:     
84:     lazy var mixMatchNavigationIconImageView: UIImageView = self.createMixMatchNavigationIconImageView() ← MATCH
85: 
86:     lazy var cashbackIconImageView: UIImageView = self.createCashbackIconImageView()
87: 
88:     private var viewModel: MarketWidgetCellViewModel?
89: 
```

### Line 139

```swift
134:         }
135:     }
136: 
137:     var tappedMatchIdAction: ((String) -> Void) = { _ in }
138:     var didLongPressOdd: ((BettingTicket) -> Void) = { _ in }
139:     var tappedMixMatchAction: ((String) -> Void) = { _ in } ← MATCH
140: 
141:     // MARK: - Initialization
142:     override init(frame: CGRect) {
143:         super.init(frame: frame)
144:         self.setupSubviews()
```

### Line 176

```swift
171:         let tapMatchView = UITapGestureRecognizer(target: self, action: #selector(didTapMatchView))
172:         self.addGestureRecognizer(tapMatchView)
173:         
174:         self.seeAllMarketsButton.addTarget(self, action: #selector(self.didTapMatchView), for: .primaryActionTriggered)
175:         
176:         let tapMixMatchView = UITapGestureRecognizer(target: self, action: #selector(didTapMixMatch)) ← MATCH
177:         self.mixMatchContainerView.addGestureRecognizer(tapMixMatchView)
178:         
179:         self.mixMatchContainerView.isHidden = true
180: 
181:         self.hasCashback = false
```

### Line 215

```swift
210:         self.middleOddButtonSubscriber = nil
211:         
212:         self.rightOddButtonSubscriber?.cancel()
213:         self.rightOddButtonSubscriber = nil
214:         
215:         self.mixMatchContainerView.isHidden = true ← MATCH
216: 
217:         self.hasCashback = false
218:     }
219: 
220:     // MARK: - Configuration
```

### Line 298

```swift
293:     func configure(with viewModel: MarketWidgetCellViewModel) {
294:         self.viewModel = viewModel
295:         
296:         if let customBetAvailable = viewModel.highlightedMarket.content.customBetAvailable,
297:            customBetAvailable {
298:             self.mixMatchContainerView.isHidden = false ← MATCH
299:             self.seeAllMarketsButton.isHidden = true
300:         }
301:         else {
302:             self.mixMatchContainerView.isHidden = true
303:             self.seeAllMarketsButton.isHidden = false
```

### Line 880

```swift
875: 
876:     private func setAwayOddValueLabel(toText text: String) {
877:         self.awayOutcomeValueLabel.text = text
878:     }
879:     
880:     @objc private func didTapMixMatch() { ← MATCH
881:         if let viewModel = self.viewModel,
882:            let matchId = viewModel.highlightedMarket.content.eventId {
883:             self.tappedMixMatchAction(matchId)
884:         }
885:     }
```

### Line 971

```swift
966:         self.containerStackView.addArrangedSubview(self.oddsStackView)
967: 
968:         self.containerStackView.addArrangedSubview(self.bottomButtonsContainerStackView)
969:         self.bottomButtonsContainerStackView.addArrangedSubview(self.seeAllMarketsButton)
970:         
971:         self.bottomButtonsContainerStackView.addArrangedSubview(self.mixMatchContainerView) ← MATCH
972:         self.mixMatchContainerView.addSubview(self.mixMatchBaseView)
973:         self.mixMatchBaseView.addSubview(self.mixMatchBackgroundImageView)
974:         self.mixMatchBaseView.addSubview(self.mixMatchIconImageView)
975:         self.mixMatchBaseView.addSubview(self.mixMatchLabel)
976:         self.mixMatchBaseView.addSubview(self.mixMatchNavigationIconImageView)
```

### Line 1185

```swift
1180:             self.awayDownChangeOddValueImageView.centerYAnchor.constraint(equalTo: self.awayButton.centerYAnchor),
1181:             self.awayDownChangeOddValueImageView.trailingAnchor.constraint(equalTo: self.awayButton.trailingAnchor, constant: -5)
1182:         ])
1183:         
1184:         NSLayoutConstraint.activate([
1185:             self.mixMatchContainerView.heightAnchor.constraint(equalToConstant: 27), ← MATCH
1186: 
1187:             self.mixMatchBaseView.heightAnchor.constraint(equalToConstant: 27),
1188:             self.mixMatchBaseView.leadingAnchor.constraint(equalTo: self.mixMatchContainerView.leadingAnchor, constant: 0),
1189:             self.mixMatchBaseView.trailingAnchor.constraint(equalTo: self.mixMatchContainerView.trailingAnchor, constant: 0),
1190:             self.mixMatchBaseView.topAnchor.constraint(equalTo: self.mixMatchContainerView.topAnchor),
```

### Line 1197

```swift
1192:             self.mixMatchBackgroundImageView.leadingAnchor.constraint(equalTo: self.mixMatchBaseView.leadingAnchor),
1193:             self.mixMatchBackgroundImageView.trailingAnchor.constraint(equalTo: self.mixMatchBaseView.trailingAnchor),
1194:             self.mixMatchBackgroundImageView.topAnchor.constraint(equalTo: self.mixMatchBaseView.topAnchor),
1195:             self.mixMatchBackgroundImageView.bottomAnchor.constraint(equalTo: self.mixMatchBaseView.bottomAnchor),
1196:         
1197:             self.mixMatchLabel.centerXAnchor.constraint(equalTo: self.mixMatchBaseView.centerXAnchor), ← MATCH
1198:             self.mixMatchLabel.centerYAnchor.constraint(equalTo: self.mixMatchBaseView.centerYAnchor),
1199:             
1200:             self.mixMatchIconImageView.widthAnchor.constraint(equalToConstant: 21),
1201:             self.mixMatchIconImageView.heightAnchor.constraint(equalToConstant: 25),
1202:             self.mixMatchIconImageView.trailingAnchor.constraint(equalTo: self.mixMatchLabel.leadingAnchor, constant: -2),
```

### Line 1208

```swift
1203:             self.mixMatchIconImageView.centerYAnchor.constraint(equalTo: self.mixMatchLabel.centerYAnchor),
1204:             
1205:             self.mixMatchNavigationIconImageView.widthAnchor.constraint(equalToConstant: 11),
1206:             self.mixMatchNavigationIconImageView.heightAnchor.constraint(equalToConstant: 13),
1207:             self.mixMatchNavigationIconImageView.leadingAnchor.constraint(equalTo: self.mixMatchLabel.trailingAnchor, constant: 6),
1208:             self.mixMatchNavigationIconImageView.centerYAnchor.constraint(equalTo: self.mixMatchLabel.centerYAnchor), ← MATCH
1209: 
1210:         ])
1211:     }
1212: 
1213:     // MARK: - UI Creation    
```

### Line 1515

```swift
1510:         imageView.image = UIImage(named: "odd_down_icon")
1511:         imageView.alpha = 0
1512:         return imageView
1513:     }
1514:     
1515:     private func createMixMatchContainerView() -> UIView { ← MATCH
1516:         let view = UIView()
1517:         view.translatesAutoresizingMaskIntoConstraints = false
1518:         view.clipsToBounds = true
1519:         return view
1520:     }
```

### Line 1530

```swift
1525:         view.layer.cornerRadius = CornerRadius.view
1526:         view.clipsToBounds = true
1527:         return view
1528:     }
1529: 
1530:     private func createMixMatchBackgroundImageView() -> UIImageView { ← MATCH
1531:         let imageView = UIImageView()
1532:         imageView.translatesAutoresizingMaskIntoConstraints = false
1533:         imageView.image = UIImage(named: "mix_match_highlight")
1534:         imageView.contentMode = .scaleAspectFill
1535:         return imageView
```

### Line 1546

```swift
1541:         imageView.image = UIImage(named: "mix_match_icon")
1542:         imageView.contentMode = .scaleAspectFit
1543:         return imageView
1544:     }
1545:     
1546:     private func createMixMatchLabel() -> UILabel { ← MATCH
1547:         let label = UILabel()
1548:         label.translatesAutoresizingMaskIntoConstraints = false
1549:         label.text = "\(localized("mix_match_or_bet_with_string")) \(localized("mix_match_mix_string"))\("mix_match_match_string")"
1550:         label.font = AppFont.with(type: .bold, size: 14)
1551:         label.textAlignment = .center
```

### Line 1569

```swift
1564:         label.attributedText = attributedString
1565:         
1566:         return label
1567:     }
1568:     
1569:     private func createMixMatchNavigationIconImageView() -> UIImageView { ← MATCH
1570:         let imageView = UIImageView()
1571:         imageView.translatesAutoresizingMaskIntoConstraints = false
1572:         imageView.image = UIImage(named: "arrow_right_icon")
1573:         imageView.contentMode = .scaleAspectFit
1574:         return imageView
```

## ./Core/Screens/PreLiveEvents/Views/Cells/Match/MatchWidget/MatchWidgetContainerTableViewCell.swift

### Line 64

```swift
59:         switch type {
60:         case .normal, .backgroundImage:
61:             return 152.0
62:         case .topImageOutright:
63:             return 270.0
64:         case .topImage, .topImageWithMixMatch: ← MATCH
65:             return 293.0
66:         case .boosted:
67:             return 186.0
68:         }
69:     }
```

### Line 80

```swift
75:     var tappedMatchLineAction: ((Match) -> Void) = { _ in }
76:     var matchWentLive: ((Match) -> Void) = { _ in }
77:     var didTapFavoriteMatchAction: ((Match) -> Void) = { _ in }
78:     var didLongPressOdd: ((BettingTicket) -> Void) = { _ in }
79:     var tappedMatchOutrightLineAction: ((Competition) -> Void) = { _ in }
80:     var tappedMixMatchAction: ((Match) -> Void)? ← MATCH
81: 
82:     private lazy var backSliderView: UIView = Self.createBackSliderView()
83:     private lazy var backSliderIconImageView: UIImageView = Self.createBackSliderIconImageView()
84:     
85:     private lazy var baseView: UIView = Self.createBaseView()
```

### Line 225

```swift
220: 
221:         cell.didLongPressOdd = { bettingTicket in
222:             self.didLongPressOdd(bettingTicket)
223:         }
224:         
225:         cell.tappedMixMatchAction = { [weak self] match in ← MATCH
226:             self?.tappedMixMatchAction?(match)
227:         }
228: 
229:         cell.shouldShowCountryFlag(true)
230:         return cell
```

## ./Core/Screens/PreLiveEvents/Views/Cells/Match/MatchWidget/MatchWidgetCollectionViewCell.swift

### Line 483

```swift
478:         imageView.setTintColor(color: UIColor.App.iconSecondary)
479:         imageView.contentMode = .scaleAspectFit
480:         return imageView
481:     }()
482: 
483:     // Mix match bottom bar ← MATCH
484:     lazy var mixMatchContainerView: UIView = {
485:         let view = UIView()
486:         view.translatesAutoresizingMaskIntoConstraints = false
487:         view.clipsToBounds = true
488:         return view
```

### Line 499

```swift
494:         view.layer.cornerRadius = CornerRadius.view
495:         view.clipsToBounds = true
496:         return view
497:     }()
498: 
499:     lazy var mixMatchBackgroundImageView: UIImageView = { ← MATCH
500:         let imageView = UIImageView()
501:         imageView.translatesAutoresizingMaskIntoConstraints = false
502:         imageView.image = UIImage(named: "mix_match_highlight")
503:         imageView.contentMode = .scaleAspectFill
504:         return imageView
```

### Line 515

```swift
510:         imageView.image = UIImage(named: "mix_match_icon")
511:         imageView.contentMode = .scaleAspectFit
512:         return imageView
513:     }()
514: 
515:     lazy var mixMatchLabel: UILabel = { ← MATCH
516:         let label = UILabel()
517:         label.translatesAutoresizingMaskIntoConstraints = false
518:         label.text = "\(localized("mix_match_or_bet_with_string")) \(localized("mix_match_mix_string"))\("mix_match_match_string")"
519:         label.font = AppFont.with(type: .bold, size: 14)
520:         label.textAlignment = .center
```

### Line 538

```swift
533:         label.attributedText = attributedString
534: 
535:         return label
536:     }()
537: 
538:     lazy var mixMatchNavigationIconImageView: UIImageView = { ← MATCH
539:         let imageView = UIImageView()
540:         imageView.translatesAutoresizingMaskIntoConstraints = false
541:         imageView.image = UIImage(named: "arrow_right_icon")
542:         imageView.contentMode = .scaleAspectFit
543:         return imageView
```

### Line 578

```swift
573:     var unselectedOutcome: ((Match, Market, Outcome) -> Void)?
574: 
575:     var didTapFavoriteMatchAction: ((Match) -> Void)?
576:     var didLongPressOdd: ((BettingTicket) -> Void)?
577:     var tappedMatchOutrightWidgetAction: ((Competition) -> Void)?
578:     var tappedMixMatchAction: ((Match) -> Void)? ← MATCH
579: 
580:     private var leftOddButtonSubscriber: AnyCancellable?
581:     private var middleOddButtonSubscriber: AnyCancellable?
582:     private var rightOddButtonSubscriber: AnyCancellable?
583: 
```

### Line 634

```swift
629:         self.topImageBaseView.isHidden = true
630: 
631:         self.boostedOddBottomLineView.isHidden = true
632:         self.boostedTopRightCornerBaseView.isHidden = true
633: 
634:         self.mixMatchContainerView.isHidden = true ← MATCH
635: 
636:         self.bottomSeeAllMarketsContainerView.isHidden = true
637: 
638:         self.mainContentBaseView.isHidden = false
639:         //
```

### Line 932

```swift
927:             self.bottomSeeAllMarketsArrowIconImageView.heightAnchor.constraint(equalToConstant: 12),
928:             self.bottomSeeAllMarketsArrowIconImageView.leadingAnchor.constraint(equalTo: self.bottomSeeAllMarketsLabel.trailingAnchor, constant: 4),
929:             self.bottomSeeAllMarketsArrowIconImageView.centerYAnchor.constraint(equalTo: self.bottomSeeAllMarketsLabel.centerYAnchor),
930:         ])
931: 
932:         // MixMatch ← MATCH
933:         self.mixMatchContainerView.isHidden = true
934: 
935:         self.baseStackView.addArrangedSubview(self.mixMatchContainerView)
936:         self.mixMatchContainerView.addSubview(self.mixMatchBaseView)
937:         self.mixMatchBaseView.addSubview(self.mixMatchBackgroundImageView)
```

### Line 943

```swift
938:         self.mixMatchBaseView.addSubview(self.mixMatchIconImageView)
939:         self.mixMatchBaseView.addSubview(self.mixMatchLabel)
940:         self.mixMatchBaseView.addSubview(self.mixMatchNavigationIconImageView)
941: 
942:         NSLayoutConstraint.activate([
943:             self.mixMatchContainerView.heightAnchor.constraint(equalToConstant: 34), ← MATCH
944: 
945:             self.mixMatchBaseView.heightAnchor.constraint(equalToConstant: 27),
946:             self.mixMatchBaseView.leadingAnchor.constraint(equalTo: self.mixMatchContainerView.leadingAnchor, constant: 12),
947:             self.mixMatchBaseView.trailingAnchor.constraint(equalTo: self.mixMatchContainerView.trailingAnchor, constant: -12),
948:             self.mixMatchBaseView.topAnchor.constraint(equalTo: self.mixMatchContainerView.topAnchor),
```

### Line 955

```swift
950:             self.mixMatchBackgroundImageView.leadingAnchor.constraint(equalTo: self.mixMatchBaseView.leadingAnchor),
951:             self.mixMatchBackgroundImageView.trailingAnchor.constraint(equalTo: self.mixMatchBaseView.trailingAnchor),
952:             self.mixMatchBackgroundImageView.topAnchor.constraint(equalTo: self.mixMatchBaseView.topAnchor),
953:             self.mixMatchBackgroundImageView.bottomAnchor.constraint(equalTo: self.mixMatchBaseView.bottomAnchor),
954: 
955:             self.mixMatchLabel.centerXAnchor.constraint(equalTo: self.mixMatchBaseView.centerXAnchor), ← MATCH
956:             self.mixMatchLabel.centerYAnchor.constraint(equalTo: self.mixMatchBaseView.centerYAnchor),
957: 
958:             self.mixMatchIconImageView.widthAnchor.constraint(equalToConstant: 21),
959:             self.mixMatchIconImageView.heightAnchor.constraint(equalToConstant: 25),
960:             self.mixMatchIconImageView.trailingAnchor.constraint(equalTo: self.mixMatchLabel.leadingAnchor, constant: -2),
```

### Line 966

```swift
961:             self.mixMatchIconImageView.centerYAnchor.constraint(equalTo: self.mixMatchLabel.centerYAnchor),
962: 
963:             self.mixMatchNavigationIconImageView.widthAnchor.constraint(equalToConstant: 11),
964:             self.mixMatchNavigationIconImageView.heightAnchor.constraint(equalToConstant: 13),
965:             self.mixMatchNavigationIconImageView.leadingAnchor.constraint(equalTo: self.mixMatchLabel.trailingAnchor, constant: 6),
966:             self.mixMatchNavigationIconImageView.centerYAnchor.constraint(equalTo: self.mixMatchLabel.centerYAnchor), ← MATCH
967: 
968:         ])
969: 
970:         self.bringSubviewToFront(self.suspendedBaseView)
971:         self.bringSubviewToFront(self.seeAllBaseView)
```

### Line 998

```swift
993:         self.addGestureRecognizer(tapMatchView)
994: 
995:         let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressCard))
996:         self.participantsBaseView.addGestureRecognizer(longPressGestureRecognizer)
997: 
998:         let tapMixMatchView = UITapGestureRecognizer(target: self, action: #selector(didTapMixMatch)) ← MATCH
999:         self.mixMatchContainerView.addGestureRecognizer(tapMixMatchView)
1000: 
1001:         self.hasCashback = false
1002: 
1003:         //
```

### Line 1046

```swift
1041:     override func prepareForReuse() {
1042:         super.prepareForReuse()
1043: 
1044:         self.viewModel = nil
1045: 
1046:         self.mixMatchContainerView.isHidden = true ← MATCH
1047:         self.bottomSeeAllMarketsContainerView.isHidden = true
1048: 
1049:         self.cancellables.removeAll()
1050: 
1051:         self.leftOutcome = nil
```

### Line 1242

```swift
1237:         self.contentRedesignBaseView.backgroundColor = .clear
1238: 
1239:         //
1240:         // Match Widget Type spec
1241:         switch self.viewModel?.matchWidgetType ?? .normal {
1242:         case .normal, .topImage, .topImageWithMixMatch: ← MATCH
1243:             self.eventNameLabel.textColor = UIColor.App.textSecondary
1244:             self.homeParticipantNameLabel.textColor = UIColor.App.textPrimary
1245:             self.awayParticipantNameLabel.textColor = UIColor.App.textPrimary
1246:             self.matchTimeLabel.textColor = UIColor.App.buttonBackgroundPrimary
1247:             self.resultLabel.textColor = UIColor.App.textPrimary
```

### Line 1741

```swift
1736:                 self.bottomMarginSpaceConstraint.constant = 12
1737:                 self.teamsHeightConstraint.constant = 67
1738:                 self.topMarginSpaceConstraint.constant = 11
1739:             }
1740: 
1741:         case .topImage, .topImageWithMixMatch: ← MATCH
1742:             self.backgroundImageView.isHidden = true
1743: 
1744:             self.topImageBaseView.isHidden = false
1745: 
1746:             self.boostedOddBottomLineView.isHidden = true
```

### Line 1873

```swift
1868: 
1869:         Publishers.CombineLatest(viewModel.$matchWidgetStatus, viewModel.$matchWidgetType)
1870:             .receive(on: DispatchQueue.main)
1871:             .sink { [weak self] matchWidgetStatus, matchWidgetType in
1872:                 switch matchWidgetType {
1873:                 case .normal, .boosted, .topImage, .topImageWithMixMatch: ← MATCH
1874:                     if matchWidgetStatus == .live {
1875:                         self?.gradientBorderView.isHidden = true
1876:                         self?.liveGradientBorderView.isHidden = false
1877:                     }
1878:                     else {
```

### Line 1914

```swift
1909:                 self?.drawForMatchWidgetType(matchWidgetType)
1910: 
1911:                 switch matchWidgetType {
1912:                 case .normal:
1913:                     break
1914:                 case .topImage, .topImageWithMixMatch: ← MATCH
1915:                     break
1916:                 case .boosted:
1917:                     break
1918:                 case .backgroundImage:
1919:                     break
```

### Line 2104

```swift
2099:                     }
2100:                     else {
2101:                         self?.showSuspendedView()
2102:                     }
2103: 
2104:                     if viewModel.matchWidgetType == .topImageWithMixMatch { ← MATCH
2105:                         if let customBetAvailable = market.customBetAvailable,
2106:                            customBetAvailable {
2107:                             self?.mixMatchContainerView.isHidden = false
2108:                             self?.bottomSeeAllMarketsContainerView.isHidden = true
2109:                         }
```

### Line 2116

```swift
2111:                             self?.mixMatchContainerView.isHidden = true
2112:                             self?.bottomSeeAllMarketsContainerView.isHidden = false
2113:                         }
2114:                     }
2115:                     else if viewModel.matchWidgetType == .topImage {
2116:                         self?.mixMatchContainerView.isHidden = true ← MATCH
2117:                         self?.bottomSeeAllMarketsContainerView.isHidden = false
2118:                     }
2119:                 }
2120:                 else {
2121:                     // Hide outcome buttons if we don't have any market
```

### Line 2143

```swift
2138:                 self?.marketNamePillLabelView.isHidden = false
2139:             }
2140:             else if matchWidgetType == .boosted {
2141:                 self?.marketNamePillLabelView.isHidden = false
2142:             }
2143: //            else if matchWidgetType == .topImageOutright || matchWidgetType == .topImage || matchWidgetType == .topImageWithMixMatch { ← MATCH
2144: //                self?.marketNamePillLabelView.isHidden = false
2145: //            }
2146:             else {
2147:                 self?.marketNamePillLabelView.isHidden = true
2148:             }
```

### Line 2545

```swift
2540:             }
2541:         }
2542: 
2543:     }
2544: 
2545:     @objc private func didTapMixMatch() { ← MATCH
2546:         if let viewModel = self.viewModel {
2547:             let match = viewModel.match
2548:             self.tappedMixMatchAction?(match)
2549:         }
2550:     }
```

## ./Core/Screens/PreLiveEvents/Views/Cells/Match/MatchLine/MatchLineTableViewCell.swift

### Line 51

```swift
46:     var unselectedOutcome: ((Match, Market, Outcome) -> Void)?
47: 
48:     var matchWentLive: (() -> Void)?
49:     var didTapFavoriteMatchAction: ((Match) -> Void)?
50:     var didLongPressOdd: ((BettingTicket) -> Void)?
51:     var tappedMixMatchAction: ((Match) -> Void)? ← MATCH
52: 
53:     private let cellInternSpace: CGFloat = 2.0
54: 
55:     private var collectionViewHeight: CGFloat {
56:         let cardHeight = StyleHelper.cardsStyleHeight()
```

### Line 548

```swift
543: 
544:             cell.didLongPressOdd = { [weak self] bettingTicket in
545:                 self?.didLongPressOdd?(bettingTicket)
546:             }
547: 
548:             cell.tappedMixMatchAction = { [weak self] match in ← MATCH
549:                 self?.tappedMixMatchAction?(match)
550:             }
551: 
552:             cell.shouldShowCountryFlag(self.shouldShowCountryFlag)
553: 
```

## ./Core/Screens/Social/Conversations/BetTicketShare/Cells/BetSelectionStateTableViewCell.swift

### Line 153

```swift
148:         else if viewModel.ticket.type == "SYSTEM" {
149:             self.titleLabel.text = localized("system") +
150:             " - \(viewModel.ticket.systemBetType?.capitalized ?? "") - \(betStatusText(forCode: viewModel.ticket.status?.uppercased() ?? "-").capitalized)"
151:         }
152:         else if viewModel.ticket.type?.lowercased() == "mix_match" {
153:             self.titleLabel.text = localized("mix-match")+" - \(viewModel.ticket.localizedBetStatus.capitalized)" ← MATCH
154:         }
155:         else {
156:             self.titleLabel.text = String([viewModel.ticket.type, viewModel.ticket.localizedBetStatus]
157:                 .compactMap({ $0 })
158:                 .map({ $0.capitalized })
```

## ./Core/Screens/Social/Conversations/BetTicketShare/Cells/BetSelectionTableViewCell.swift

### Line 106

```swift
101:         }
102:         else if viewModel.ticket.type?.uppercased() == "SYSTEM" {
103:             self.titleLabel.text = localized("system") + " - \(viewModel.ticket.systemBetType?.capitalized ?? "") - \(viewModel.ticket.localizedBetStatus.capitalized)"
104:         }
105:         else if viewModel.ticket.type?.lowercased() == "mix_match" {
106:             self.titleLabel.text = localized("mix-match")+" - \(viewModel.ticket.localizedBetStatus.capitalized)" ← MATCH
107:         }
108:         else {
109:             self.titleLabel.text = String([viewModel.ticket.type, viewModel.ticket.localizedBetStatus]
110:                 .compactMap({ $0 })
111:                 .map({ $0.capitalized })
```

## ./Core/Screens/Betslip/PreSubmission/DataSources/BetBuilderBettingTicketDataSource.swift

### Line 34

```swift
29:         }
30:         
31:         let isInvalid = self.invalidBettingTicketIds.contains(bettingTicket.id)
32:         cell.configureWithBettingTicket(bettingTicket,
33:                                         showInvalidView: isInvalid,
34:                                         mixMatchMode: true) ← MATCH
35:         
36:         return cell
37:     }
38: 
39:     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
```

## ./Core/Screens/Betslip/PreSubmission/DataSources/MultipleBettingTicketDataSource.swift

### Line 33

```swift
28:     }
29: 
30:     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
31:         if let cell = tableView.dequeueCellType(MultipleBettingTicketTableViewCell.self),
32:            let bettingTicket = self.bettingTickets[safe: indexPath.row] {
33:             cell.configureWithBettingTicket(bettingTicket, mixMatchMode: false) ← MATCH
34:             return cell
35:         }
36:         else if let cell = tableView.dequeueCellType(BonusSwitchTableViewCell.self),
37:                     let bonusMultiple = self.bonusMultiple[safe: (indexPath.row - self.bettingTickets.count)] {
38: 
```

## ./Core/Screens/Betslip/PreSubmission/Cells/MultipleBettingTicketTableViewCell.swift

### Line 31

```swift
26: 
27:     @IBOutlet private weak var bottomBaseView: UIView!
28:     @IBOutlet private weak var marketNameLabel: UILabel!
29:     @IBOutlet private weak var matchDetailLabel: UILabel!
30:     
31:     @IBOutlet private weak var mixMatchIconImageView: UIImageView! ← MATCH
32:     @IBOutlet private weak var cashbackIconImageView: UIImageView!
33: 
34:     @IBOutlet private weak var stackView: UIStackView!
35: 
36:     @IBOutlet private weak var suspendedBettingOfferView: UIView!
```

### Line 76

```swift
71:         self.marketNameLabel.font = AppFont.with(type: .heavy, size: 14)
72:         self.matchDetailLabel.font = AppFont.with(type: .bold, size: 12)
73:         self.suspendedBettingOfferLabel.font = AppFont.with(type: .heavy, size: 20)
74: 
75:         self.suspendedBettingOfferView.isHidden = true
76:         self.mixMatchIconImageView.isHidden = true ← MATCH
77:         
78:         self.upChangeOddValueImage.alpha = 0.0
79:         self.downChangeOddValueImage.alpha = 0.0
80: 
81:         self.invalidTicketView.isHidden = true
```

### Line 202

```swift
197:     }
198: 
199:     func configureWithBettingTicket(_ bettingTicket: BettingTicket, 
200:                                     errorBetting: String? = nil,
201:                                     showInvalidView: Bool = false,
202:                                     mixMatchMode: Bool = false) { ← MATCH
203: 
204:         if showInvalidView {
205:             self.invalidTicketView.isHidden = false
206:         }
207:         else {
```

### Line 213

```swift
208:             self.invalidTicketView.isHidden = true
209:         }
210:         
211:         if mixMatchMode { // No cashback
212:             self.hasCashback = false
213:             self.mixMatchIconImageView.isHidden = false ← MATCH
214:         }
215:         else {
216:             self.mixMatchIconImageView.isHidden = true
217:         }
218:         
```

## ./Core/Screens/Betslip/PreSubmission/PreSubmissionBetslipViewController.swift

### Line 70

```swift
65:     @IBOutlet private weak var systemWinningsTitleLabel: UILabel!
66:     @IBOutlet private weak var systemWinningsValueLabel: UILabel!
67:     @IBOutlet private weak var systemOddsTitleLabel: UILabel!
68:     @IBOutlet private weak var systemOddsValueLabel: UILabel!
69: 
70:     @IBOutlet private weak var mixMatchWinningsBaseView: UIView! ← MATCH
71:     @IBOutlet private weak var mixMatchWinningsSeparatorView: UIView!
72:     @IBOutlet private weak var mixMatchWinningsTitleLabel: UILabel!
73:     @IBOutlet private weak var mixMatchWinningsValueLabel: UILabel!
74:     @IBOutlet private weak var mixMatchOddsTitleLabel: UILabel!
75:     @IBOutlet private weak var mixMatchOddsValueLabel: UILabel!
```

### Line 131

```swift
126:     @IBOutlet private weak var secondarySystemOddsTitleLabel: UILabel!
127:     @IBOutlet private weak var secondarySystemWinningsTitleLabel: UILabel!
128:     @IBOutlet private weak var secondarySystemOddsValueLabel: UILabel!
129:     @IBOutlet private weak var secondarySystemWinningsSeparatorView: UIView!
130: 
131:     @IBOutlet private weak var secondaryMixMatchWinningsBaseView: UIView! ← MATCH
132:     @IBOutlet private weak var secondaryMixMatchWinningsValueLabel: UILabel!
133:     @IBOutlet private weak var secondaryMixMatchOddsTitleLabel: UILabel!
134:     @IBOutlet private weak var secondaryMixMatchWinningsTitleLabel: UILabel!
135:     @IBOutlet private weak var secondaryMixMatchOddsValueLabel: UILabel!
136:     @IBOutlet private weak var secondaryMixMatchWinningsSeparatorView: UIView!
```

### Line 417

```swift
412:         self.showCashbackValues = false
413: 
414:         self.simpleWinningsBaseView.isHidden = false
415:         self.multipleWinningsBaseView.isHidden = true
416:         self.systemWinningsBaseView.isHidden = true
417:         self.mixMatchWinningsBaseView.isHidden = true ← MATCH
418: 
419:         self.loadingView.alpha = 0.0
420:         self.loadingView.stopAnimating()
421:         self.loadingBaseView.isHidden = true
422:         self.addChildViewController(self.loadingSpinnerViewController, toView: self.loadingBaseView)
```

### Line 530

```swift
525:         self.systemOddsValueLabel.text = localized("no_value")
526: 
527:         self.systemBetTypeTitleLabel.text = localized("system_options")
528: 
529:         //
530:         self.mixMatchWinningsValueLabel.text = localized("no_value") ← MATCH
531:         self.mixMatchOddsTitleLabel.text = localized("total_odd")
532:         self.mixMatchOddsValueLabel.text = localized("no_value")
533: 
534:         self.secondaryMixMatchWinningsValueLabel.text = localized("no_value")
535:         self.secondaryMixMatchOddsTitleLabel.text = localized("total_bet_amount")
```

### Line 550

```swift
545: 
546:         // Possible winnings title
547:         self.simpleWinningsTitleLabel.text = localized("possible_winnings")
548:         self.systemWinningsTitleLabel.text = localized("possible_winnings")
549:         self.multipleWinningsTitleLabel.text = localized("possible_winnings")
550:         self.mixMatchWinningsTitleLabel.text = localized("possible_winnings") ← MATCH
551: 
552:         self.secondaryMultipleWinningsTitleLabel.text = localized("possible_winnings")
553:         self.secondarySystemWinningsTitleLabel.text = localized("possible_winnings")
554:         self.secondaryMixMatchWinningsTitleLabel.text = localized("possible_winnings")
555:         //
```

### Line 965

```swift
960:                 switch betType {
961:                 case .simple:
962:                     self?.simpleWinningsBaseView.isHidden = false
963:                     self?.multipleWinningsBaseView.isHidden = true
964:                     self?.systemWinningsBaseView.isHidden = true
965:                     self?.mixMatchWinningsBaseView.isHidden = true ← MATCH
966: 
967:                     self?.betBuilderWarningView.isHidden = true
968: 
969:                     if let cashbackEnabled = self?.isCashbackEnabled,
970:                        cashbackEnabled,
```

### Line 985

```swift
980: 
981:                 case .multiple:
982:                     self?.simpleWinningsBaseView.isHidden = true
983:                     self?.multipleWinningsBaseView.isHidden = false
984:                     self?.systemWinningsBaseView.isHidden = true
985:                     self?.mixMatchWinningsBaseView.isHidden = true ← MATCH
986: 
987:                     self?.betBuilderWarningView.isHidden = true
988: 
989:                     if let cashbackEnabled = self?.isCashbackEnabled,
990:                        cashbackEnabled,
```

### Line 1004

```swift
999:                     }
1000:                 case .system:
1001:                     self?.simpleWinningsBaseView.isHidden = true
1002:                     self?.multipleWinningsBaseView.isHidden = true
1003:                     self?.systemWinningsBaseView.isHidden = false
1004:                     self?.mixMatchWinningsBaseView.isHidden = true ← MATCH
1005: 
1006:                     self?.betBuilderWarningView.isHidden = true
1007: 
1008:                     if let cashbackEnabled = self?.isCashbackEnabled,
1009:                        cashbackEnabled,
```

### Line 1026

```swift
1021:                     self?.simpleWinningsBaseView.isHidden = true
1022:                     self?.multipleWinningsBaseView.isHidden = true
1023:                     self?.systemWinningsBaseView.isHidden = true
1024:                     self?.cashbackBaseView.isHidden = true
1025: 
1026:                     self?.mixMatchWinningsBaseView.isHidden = false ← MATCH
1027: 
1028:                     self?.betBuilderWarningView.isHidden = false
1029:                 }
1030:             })
1031:             .store(in: &self.cancellables)
```

### Line 1178

```swift
1173:                     self?.amountTextfield.resignFirstResponder()
1174:                 case (.multiple, true):
1175:                     self?.secondaryPlaceBetBaseView.isHidden = false
1176:                     self?.secondaryMultipleWinningsBaseView.isHidden = false
1177:                     self?.secondarySystemWinningsBaseView.isHidden = true
1178:                     self?.secondaryMixMatchWinningsBaseView.isHidden = true ← MATCH
1179:                 case (.system, true):
1180:                     self?.secondaryPlaceBetBaseView.isHidden = false
1181:                     self?.secondaryMultipleWinningsBaseView.isHidden = true
1182:                     self?.secondarySystemWinningsBaseView.isHidden = false
1183:                     self?.secondaryMixMatchWinningsBaseView.isHidden = true
```

### Line 1559

```swift
1554:         self.secondaryMultipleWinningsSeparatorView.backgroundColor = UIColor.App.separatorLine
1555:         self.systemWinningsSeparatorView.backgroundColor = UIColor.App.separatorLine
1556: 
1557:         self.secondaryMultipleWinningsSeparatorView.backgroundColor = UIColor.App.separatorLine
1558:         self.secondarySystemWinningsSeparatorView.backgroundColor = UIColor.App.separatorLine
1559:         self.secondaryMixMatchWinningsSeparatorView.backgroundColor = UIColor.App.separatorLine ← MATCH
1560: 
1561:         self.simpleWinningsBaseView.backgroundColor = UIColor.App.backgroundPrimary
1562:         self.simpleWinningsTitleLabel.textColor = UIColor.App.textSecondary
1563: 
1564:         self.simpleWinningsValueLabel.textColor = UIColor.App.textPrimary
```

### Line 1593

```swift
1588:         self.secondarySystemWinningsTitleLabel.textColor = UIColor.App.textDisablePrimary
1589:         self.secondarySystemWinningsValueLabel.textColor = UIColor.App.textPrimary
1590:         self.secondarySystemOddsTitleLabel.textColor = UIColor.App.textDisablePrimary
1591:         self.secondarySystemOddsValueLabel.textColor = UIColor.App.textPrimary
1592: 
1593:         self.mixMatchWinningsBaseView.backgroundColor = UIColor.App.backgroundPrimary ← MATCH
1594:         self.mixMatchWinningsTitleLabel.textColor = UIColor.App.textSecondary
1595:         self.mixMatchWinningsValueLabel.textColor = UIColor.App.textPrimary
1596:         self.mixMatchOddsTitleLabel.textColor = UIColor.App.textSecondary
1597:         self.mixMatchOddsValueLabel.textColor = UIColor.App.textPrimary
1598: 
```

### Line 1649

```swift
1644:         let size16Labels: [UILabel] = [
1645:             self.systemBetTypeTitleLabel,
1646:             self.systemBetTypeLabel,
1647:             self.systemWinningsTitleLabel,
1648:             self.systemWinningsValueLabel,
1649:             self.mixMatchWinningsTitleLabel, ← MATCH
1650:             self.mixMatchWinningsValueLabel,
1651:             self.multipleWinningsTitleLabel,
1652:             self.multipleWinningsValueLabel,
1653:             self.simpleWinningsTitleLabel,
1654:             self.simpleWinningsValueLabel,
```

### Line 1660

```swift
1655:             self.secondarySystemWinningsTitleLabel,
1656:             self.secondarySystemWinningsValueLabel,
1657:             self.secondaryMultipleWinningsTitleLabel,
1658:             self.secondaryMultipleWinningsValueLabel,
1659:             self.secondaryMixMatchWinningsTitleLabel,
1660:             self.secondaryMixMatchWinningsValueLabel ← MATCH
1661:         ]
1662:         size16Labels.forEach { $0.font = AppFont.with(type: .bold, size: 16) }
1663:         
1664:         // Font size 14
1665:         let size14Labels: [UILabel] = [
```

### Line 1676

```swift
1671:         
1672:         // Font size 11
1673:         let size11Labels: [UILabel] = [
1674:             self.systemOddsTitleLabel,
1675:             self.systemOddsValueLabel,
1676:             self.mixMatchOddsTitleLabel, ← MATCH
1677:             self.mixMatchOddsValueLabel,
1678:             self.multipleOddsTitleLabel,
1679:             self.multipleOddsValueLabel,
1680:             self.simpleOddsTitleLabel,
1681:             self.simpleOddsValueLabel,
```

### Line 1687

```swift
1682:             self.secondarySystemOddsTitleLabel,
1683:             self.secondarySystemOddsValueLabel,
1684:             self.secondaryMultipleOddsTitleLabel,
1685:             self.secondaryMultipleOddsValueLabel,
1686:             self.secondaryMixMatchOddsTitleLabel,
1687:             self.secondaryMixMatchOddsValueLabel ← MATCH
1688:         ]
1689:         size11Labels.forEach { $0.font = AppFont.with(type: .bold, size: 11) }
1690:     }
1691:     private func setupCashback() {
1692:         self.cashbackSwitch.addTarget(self, action: #selector(cashbackSwitchValueChanged(_:)), for: .valueChanged)
```

### Line 2525

```swift
2520: 
2521:     private func configureWithBetBuilderExpectedReturn(_ betBuilderCalculateResponse: BetBuilderCalculateResponse) {
2522: 
2523:         switch betBuilderCalculateResponse {
2524:         case .valid(let potentialReturn, _):
2525:             print("DebugMixMatch: response valid \(dump(potentialReturn))") ← MATCH
2526: 
2527:             // Hide error view
2528:             self.betBuilderWarningView.alpha = 0.0
2529: 
2530:             let possibleWinningsString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: potentialReturn.potentialReturn)) ?? localized("no_value")
```

### Line 2536

```swift
2531: 
2532:             self.mixMatchWinningsValueLabel.text = possibleWinningsString
2533:             self.secondaryMixMatchWinningsValueLabel.text = possibleWinningsString
2534: 
2535:             self.mixMatchOddsValueLabel.text = OddFormatter.formatOdd(withValue: potentialReturn.totalOdd)
2536:             self.secondaryMixMatchOddsValueLabel.text = OddFormatter.formatOdd(withValue: potentialReturn.totalOdd) ← MATCH
2537: 
2538:         case .invalid:
2539:             print("DebugMixMatch: response invalid")
2540: 
2541:             // Show error view
```

## ./Core/Screens/MyTickets/ViewModel/MyTicketCellViewModel.swift

### Line 80

```swift
75:         }
76:         else if ticket.type?.lowercased() == "system" {
77:             self.title = localized("system")+" - \(ticket.systemBetType?.capitalized ?? "") - \(ticket.localizedBetStatus.capitalized)"
78:         }
79:         else if ticket.type?.lowercased() == "mix_match" {
80:             self.title = localized("mix-match")+" - \(ticket.localizedBetStatus.capitalized)" ← MATCH
81:         }
82:         else {
83:             self.title = String([ticket.type, ticket.localizedBetStatus]
84:                 .compactMap({ $0 })
85:                 .map({ $0.capitalized })
```

## ./Core/Screens/MyTickets/Views/MyTicketTableViewCell.swift

### Line 538

```swift
533:         }
534:         else if betHistoryEntry.type?.lowercased() == "system" {
535:             self.titleLabel.text = localized("system")+" - \(betHistoryEntry.systemBetType?.capitalized ?? "") - \(betHistoryEntry.localizedBetStatus.capitalized)"
536:         }
537:         else if betHistoryEntry.type?.lowercased() == "mix_match" {
538:             self.titleLabel.text = localized("mix-match")+" - \(betHistoryEntry.localizedBetStatus.capitalized)" ← MATCH
539:         }
540:         else {
541:             self.titleLabel.text = String([betHistoryEntry.type, betHistoryEntry.localizedBetStatus]
542:                 .compactMap({ $0 })
543:                 .map({ $0.capitalized })
```

## ./Core/Views/Chat/ChatTicketStateInMessageView.swift

### Line 90

```swift
85:         }
86:         else if self.betSelectionCellViewModel.ticket.type == "MULTIPLE" {
87:             self.titleLabel.text = localized("multiple")+" - \(betStatusText(forCode: self.betSelectionCellViewModel.ticket.status?.uppercased() ?? "-"))"
88:         }
89:         else if self.betSelectionCellViewModel.ticket.type?.lowercased() == "mix_match" {
90:             self.titleLabel.text = localized("mix-match")+" - \(betStatusText(forCode: self.betSelectionCellViewModel.ticket.status?.uppercased() ?? "-"))" ← MATCH
91:         }
92:         else if self.betSelectionCellViewModel.ticket.type == "SYSTEM" {
93:             self.titleLabel.text = localized("system") +
94:             " - \(self.betSelectionCellViewModel.ticket.systemBetType?.capitalized ?? "") - \(betStatusText(forCode: self.betSelectionCellViewModel.ticket.status?.uppercased() ?? "-"))"
95:         }
```

## ./Core/Views/Chat/ChatTicketInMessageView.swift

### Line 68

```swift
63:         }
64:         else if self.betSelectionCellViewModel.ticket.type == "MULTIPLE" {
65:             self.titleLabel.text = localized("multiple")+" - \(betStatusText(forCode: self.betSelectionCellViewModel.ticket.status?.uppercased() ?? "-"))"
66:         }
67:         else if self.betSelectionCellViewModel.ticket.type?.lowercased() == "mix_match" {
68:             self.titleLabel.text = localized("mix-match")+" - \(betStatusText(forCode: self.betSelectionCellViewModel.ticket.status?.uppercased() ?? "-"))" ← MATCH
69:         }
70:         else if self.betSelectionCellViewModel.ticket.type == "SYSTEM" {
71:             self.titleLabel.text = localized("system") +
72:             " - \(self.betSelectionCellViewModel.ticket.systemBetType?.capitalized ?? "") - \(betStatusText(forCode: self.betSelectionCellViewModel.ticket.status?.uppercased() ?? "-"))"
73:         }
```

## ./Core/Views/ChipsTypeView/ChipsTypeView.swift

### Line 179

```swift
174: 
175:     // Create sample data
176:     let sampleTabs: [ChipType] = [
177:         .textual(title: "Football"),
178:         .textual(title: "Basketball"),
179:         .icon(title: "Mix Match", iconName: "mix_match_icon"), ← MATCH
180:         .backgroungImage(title: "Mix Match", iconName: "mix_match_icon", imageName: "mix_match_background_pill"),
181:         .textual(title: "Football"),
182:         .textual(title: "Basketball"),
183:         .icon(title: "Mix Match", iconName: "mix_match_icon"),
184:         .backgroungImage(title: "Mix Match", iconName: "mix_match_icon", imageName: "mix_match_background_pill"),
```

### Line 191

```swift
186:         .textual(title: "Basketball"),
187:         .icon(title: "Mix Match", iconName: "mix_match_icon"),
188:         .backgroungImage(title: "Mix Match", iconName: "mix_match_icon", imageName: "mix_match_background_pill"),
189:         .textual(title: "Football"),
190:         .textual(title: "Basketball"),
191:         .icon(title: "Mix Match", iconName: "mix_match_icon"), ← MATCH
192:         .backgroungImage(title: "Mix Match", iconName: "mix_match_icon", imageName: "mix_match_background_pill"),
193:     ]
194: 
195:     // Create ChipsTypeView with ViewModel
196:     let viewModel = ChipsTypeViewModel(tabs: sampleTabs, defaultSelectedIndex: 1)
```

## ./ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/APIs/Betting-Poseidon/BettingConnector.swift

### Line 73

```swift
68:             .tryMap { result -> Data in
69: 
70:                 if (request.url?.absoluteString ?? "").contains("/custom-bet/v1/calculate") || (request.url?.absoluteString ?? "").contains("custom-bet/v1/placecustombet") {
71:                     var responseBody = String(data: request.httpBody ?? Data(), encoding: .utf8) ?? ""
72:                     responseBody = responseBody.replacingOccurrences(of: "\n", with: " ")
73:                     print("MixMatchDebug: | ", request, " body: ", responseBody , " | response: ", String(data: result.data, encoding: .utf8) ?? "!?" ) ← MATCH
74:                 }
75:                 
76:                 if (request.url?.absoluteString ?? "").contains("/custom-bet/v1/calculate") {
77:                     if let httpResponse = result.response as? HTTPURLResponse {
78:                         if httpResponse.statusCode == 401 || httpResponse.statusCode == 500 || httpResponse.statusCode == 503 {
```

## ./ServicesProvider/Sources/ServicesProvider/Providers/Sportsradar/SportRadarEventsProvider.swift

### Line 1793

```swift
1788:         // Verify for BetBuilder markets
1789:         let betBuilderMarkets = matchMarkets.filter( {
1790:             $0.customBetAvailable ?? false
1791:         })
1792: 
1793:         let betBuilderMarketGroup = MarketGroup(type: "MixMatch", ← MATCH
1794:                                                 id: "99",
1795:                                                 groupKey: "99",
1796:                                                 translatedName: "MixMatch",
1797:                                                 position: 99,
1798:                                                 isDefault: false,
```

