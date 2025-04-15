// GENERATED FILE - DO NOT EDIT MANUALLY
// Generated from Figma design tokens
// To update this file, modify the Python generation script and re-run it

import UIKit

struct ThemeColors: Codable {
    // Background colors
    let backgroundPrimary: String
    let backgroundSecondary: String
    let backgroundTertiary: String
    let backgroundBorder: String
    let backgroundCards: String
    let backgroundHeader: String
    let backgroundOdds: String
    let backgroundDisabledOdds: String
    let backgroundDrop: String
    let backgroundDarker: String
    let backgroundGradient1: String
    let backgroundGradient2: String
    let backgroundHeaderGradient1: String
    let backgroundHeaderGradient2: String
    
    // Text colors
    let textPrimary: String
    let textHeadlinePrimary: String
    let textDisablePrimary: String
    let textSecondary: String
    let textHeroCard: String
    let textSecondaryHeroCard: String
    
    // Input colors
    let inputBackground: String
    let inputBorderActive: String
    let inputBorderDisabled: String
    let inputBackgroundSecondary: String
    let inputTextTitle: String
    let inputText: String
    let inputError: String
    let inputTextDisable: String
    
    // Icon colors
    let iconPrimary: String
    let iconSecondary: String
    let iconSportsHeroCard: String
    
    // Pill colors
    let pillBackground: String
    let pillNavigation: String
    let pillSettings: String
    
    // Button colors
    let buttonTextPrimary: String
    let buttonBackgroundPrimary: String
    let buttonActiveHoverPrimary: String
    let buttonDisablePrimary: String
    let buttonTextDisablePrimary: String
    let buttonTextSecondary: String
    let buttonTextTertiary: String
    let buttonTextDisableTertiary: String
    let buttonBackgroundSecondary: String
    let buttonActiveHoverSecondary: String
    let buttonBackgroundTertiary: String
    let buttonActiveHoverTertiary: String
    let buttonBorderTertiary: String
    let buttonBorderDisableTertiary: String
    
    // Highlight colors
    let highlightPrimary: String
    let highlightSecondary: String
    let highlightPrimaryContrast: String
    let highlightSecondaryContrast: String
    let highlightTertiary: String
    
    // Alert colors
    let alertError: String
    let alertSuccess: String
    let alertWarning: String
    
    // Separator colors
    let separatorLine: String
    let separatorLineHighlightPrimary: String
    let separatorLineHighlightSecondary: String
    let separatorLineSecondary: String
    
    // Ticket colors
    let myTicketsLost: String
    let myTicketsLostFaded: String
    let myTicketsWon: String
    let myTicketsWonFaded: String
    let myTicketsOther: String
    
    // Stats colors
    let statsHome: String
    let statsAway: String
    
    // Scroll color
    let scroll: String
    
    // Border colors
    let borderDrop: String
    
    // Bubbles color
    let bubblesPrimary: String
    
    // Gradient colors
    let headerGradient1: String
    let headerGradient2: String
    let headerGradient3: String
    let cardBorderLineGradient1: String
    let cardBorderLineGradient2: String
    let cardBorderLineGradient3: String
    let liveBorderGradient1: String
    let liveBorderGradient2: String
    let liveBorderGradient3: String
    let messageGradient1: String
    let messageGradient2: String
    
    // Navigation colors
    let navBanner: String
    let navBannerActive: String
    
    // Game header color
    let gameHeader: String
    
    // Background odds hero card
    let backgroundOddsHeroCard: String
    
}

// 
extension ThemeColors {
    
    // Default light theme values
    static let defaultLight = ThemeColors(
        backgroundPrimary: "#FFFFFF",
        backgroundSecondary: "#F5F5F5",
        backgroundTertiary: "#EEEEEE",
        backgroundBorder: "#E0E0E0",
        backgroundCards: "#FFFFFF",
        backgroundHeader: "#FFFFFF",
        backgroundOdds: "#F5F5F5",
        backgroundDisabledOdds: "#DDDDDD",
        backgroundDrop: "#F5F5F5",
        backgroundDarker: "#E5E5E5",
        backgroundGradient1: "#FFFFFF",
        backgroundGradient2: "#F5F5F5",
        backgroundHeaderGradient1: "#FFFFFF",
        backgroundHeaderGradient2: "#F5F5F5",
        
        textPrimary: "#333333",
        textHeadlinePrimary: "#222222",
        textDisablePrimary: "#999999",
        textSecondary: "#666666",
        textHeroCard: "#333333",
        textSecondaryHeroCard: "#666666",
        
        inputBackground: "#FFFFFF",
        inputBorderActive: "#007AFF",
        inputBorderDisabled: "#CCCCCC",
        inputBackgroundSecondary: "#F5F5F5",
        inputTextTitle: "#333333",
        inputText: "#333333",
        inputError: "#FF3B30",
        inputTextDisable: "#999999",
        
        iconPrimary: "#333333",
        iconSecondary: "#666666",
        iconSportsHeroCard: "#333333",
        
        pillBackground: "#F5F5F5",
        pillNavigation: "#E5E5E5",
        pillSettings: "#DDDDDD",
        
        buttonTextPrimary: "#FFFFFF",
        buttonBackgroundPrimary: "#007AFF",
        buttonActiveHoverPrimary: "#0062CC",
        buttonDisablePrimary: "#B3D9FF",
        buttonTextDisablePrimary: "#FFFFFF",
        buttonTextSecondary: "#007AFF",
        buttonTextTertiary: "#333333",
        buttonTextDisableTertiary: "#999999",
        buttonBackgroundSecondary: "#E5E5E5",
        buttonActiveHoverSecondary: "#D1D1D6",
        buttonBackgroundTertiary: "#FFFFFF",
        buttonActiveHoverTertiary: "#F2F2F7",
        buttonBorderTertiary: "#C7C7CC",
        buttonBorderDisableTertiary: "#E5E5EA",
        
        highlightPrimary: "#007AFF",
        highlightSecondary: "#5AC8FA",
        highlightPrimaryContrast: "#FFFFFF",
        highlightSecondaryContrast: "#FFFFFF",
        highlightTertiary: "#4CD964",
        
        alertError: "#FF3B30",
        alertSuccess: "#34C759",
        alertWarning: "#FFCC00",
        
        separatorLine: "#C6C6C8",
        separatorLineHighlightPrimary: "#007AFF",
        separatorLineHighlightSecondary: "#5AC8FA",
        separatorLineSecondary: "#E5E5EA",
        
        myTicketsLost: "#FF3B30",
        myTicketsLostFaded: "#FFCCCB",
        myTicketsWon: "#34C759",
        myTicketsWonFaded: "#CCFFDD",
        myTicketsOther: "#FFCC00",
        
        statsHome: "#007AFF",
        statsAway: "#5856D6",
        
        scroll: "#C7C7CC",
        
        borderDrop: "#E5E5EA",
        
        bubblesPrimary: "#007AFF",
        
        headerGradient1: "#007AFF",
        headerGradient2: "#5AC8FA",
        headerGradient3: "#64D2FF",
        cardBorderLineGradient1: "#E5E5EA",
        cardBorderLineGradient2: "#C7C7CC",
        cardBorderLineGradient3: "#E5E5EA",
        liveBorderGradient1: "#FF3B30",
        liveBorderGradient2: "#FF9500",
        liveBorderGradient3: "#FF3B30",
        messageGradient1: "#007AFF",
        messageGradient2: "#5AC8FA",
        
        navBanner: "#F2F2F7",
        navBannerActive: "#DDDDDD",
        
        gameHeader: "#F5F5F5",
        
        backgroundOddsHeroCard: "#F5F5F5"
    )
    
    // Default dark theme values
    static let defaultDark = ThemeColors(
        backgroundPrimary: "#121212",
        backgroundSecondary: "#1F1F1F",
        backgroundTertiary: "#2C2C2C",
        backgroundBorder: "#3D3D3D",
        backgroundCards: "#1F1F1F",
        backgroundHeader: "#121212",
        backgroundOdds: "#2C2C2C",
        backgroundDisabledOdds: "#3D3D3D",
        backgroundDrop: "#2C2C2C",
        backgroundDarker: "#000000",
        backgroundGradient1: "#121212",
        backgroundGradient2: "#1F1F1F",
        backgroundHeaderGradient1: "#121212",
        backgroundHeaderGradient2: "#1F1F1F",
        
        textPrimary: "#FFFFFF",
        textHeadlinePrimary: "#F2F2F7",
        textDisablePrimary: "#8E8E93",
        textSecondary: "#AEAEB2",
        textHeroCard: "#FFFFFF",
        textSecondaryHeroCard: "#AEAEB2",
        
        inputBackground: "#1F1F1F",
        inputBorderActive: "#0A84FF",
        inputBorderDisabled: "#636366",
        inputBackgroundSecondary: "#2C2C2C",
        inputTextTitle: "#F2F2F7",
        inputText: "#FFFFFF",
        inputError: "#FF453A",
        inputTextDisable: "#8E8E93",
        
        iconPrimary: "#FFFFFF",
        iconSecondary: "#AEAEB2",
        iconSportsHeroCard: "#FFFFFF",
        
        pillBackground: "#2C2C2C",
        pillNavigation: "#3D3D3D",
        pillSettings: "#636366",
        
        buttonTextPrimary: "#FFFFFF",
        buttonBackgroundPrimary: "#0A84FF",
        buttonActiveHoverPrimary: "#0071E3",
        buttonDisablePrimary: "#064484",
        buttonTextDisablePrimary: "#8E8E93",
        buttonTextSecondary: "#0A84FF",
        buttonTextTertiary: "#FFFFFF",
        buttonTextDisableTertiary: "#8E8E93",
        buttonBackgroundSecondary: "#3D3D3D",
        buttonActiveHoverSecondary: "#636366",
        buttonBackgroundTertiary: "#1F1F1F",
        buttonActiveHoverTertiary: "#2C2C2C",
        buttonBorderTertiary: "#636366",
        buttonBorderDisableTertiary: "#3D3D3D",
        
        highlightPrimary: "#0A84FF",
        highlightSecondary: "#64D2FF",
        highlightPrimaryContrast: "#FFFFFF",
        highlightSecondaryContrast: "#FFFFFF",
        highlightTertiary: "#30D158",
        
        alertError: "#FF453A",
        alertSuccess: "#30D158",
        alertWarning: "#FFD60A",
        
        separatorLine: "#3D3D3D",
        separatorLineHighlightPrimary: "#0A84FF",
        separatorLineHighlightSecondary: "#64D2FF",
        separatorLineSecondary: "#2C2C2C",
        
        myTicketsLost: "#FF453A",
        myTicketsLostFaded: "#8C2022",
        myTicketsWon: "#30D158",
        myTicketsWonFaded: "#1A732F",
        myTicketsOther: "#FFD60A",
        
        statsHome: "#0A84FF",
        statsAway: "#5E5CE6",
        
        scroll: "#636366",
        
        borderDrop: "#3D3D3D",
        
        bubblesPrimary: "#0A84FF",
        
        headerGradient1: "#0A84FF",
        headerGradient2: "#64D2FF",
        headerGradient3: "#32ADE6",
        cardBorderLineGradient1: "#3D3D3D",
        cardBorderLineGradient2: "#636366",
        cardBorderLineGradient3: "#3D3D3D",
        liveBorderGradient1: "#FF453A",
        liveBorderGradient2: "#FF9F0A",
        liveBorderGradient3: "#FF453A",
        messageGradient1: "#0A84FF",
        messageGradient2: "#64D2FF",
        
        navBanner: "#1F1F1F",
        navBannerActive: "#2C2C2C",
        
        gameHeader: "#2C2C2C",
        
        backgroundOddsHeroCard: "#2C2C2C"
    )
} 
