
extension EveryMatrix {
    
    struct BettingOptionsCalculateSelection: Codable {
        let bettingOfferId: String
        let priceValue: Double
        
        init(bettingOfferId: String, priceValue: Double) {
            self.bettingOfferId = bettingOfferId
            self.priceValue = priceValue
        }
    }
    
}
