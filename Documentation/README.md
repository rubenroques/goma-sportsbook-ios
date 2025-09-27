# Sportsbook iOS Documentation Index

## 📖 Overview

This repository contains comprehensive documentation for the Sportsbook iOS workspace, covering architecture patterns, feature implementations, development guides, and system specifications.

---

## 🏗️ Core Documentation (Essential Reading)

Essential architectural and development guides that form the foundation of the project.

| Document | Purpose | Last Updated | Size | Description |
|----------|---------|--------------|------|-------------|
| [MVVM.md](Core/MVVM.md) | Architecture Guide | Jul 26, 2025 | 18KB | Complete MVVM-C architecture patterns with UIKit. Core principle: "Views are dumb, ViewModels are smart, ViewControllers are coordinators" |
| [UI_COMPONENT_GUIDE.md](Core/UI_COMPONENT_GUIDE.md) | Component Development | Jul 26, 2025 | 23KB | Standard patterns for creating custom UI Views and ViewControllers with lazy property initialization |
| [API_DEVELOPMENT_GUIDE.md](Core/API_DEVELOPMENT_GUIDE.md) | API Integration | Sep 16, 2025 | 12KB | Step-by-step guide for adding new API endpoints with 3-layer model architecture |

---

## 🏛️ Architecture Documentation

System design and architectural decisions.

| Document | Purpose | Last Updated | Size | Description |
|----------|---------|--------------|------|-------------|
| [overview.md](architecture/overview.md) | System Overview | Jul 29, 2025 | 8KB | High-level architecture overview |
| [services_provider.md](architecture/services_provider.md) | Services Layer | Jul 29, 2025 | 10KB | ServicesProvider framework architecture |
| [SP_Architecture_V2.md](architecture/SP_Architecture_V2.md) | Enhanced Architecture | Jul 29, 2025 | 15KB | Version 2 of ServicesProvider architecture |
| [match-details-data-architecture-report.md](architecture/match-details-data-architecture-report.md) | Match Details | Jul 29, 2025 | 9KB | Data architecture for match details functionality |

---

## 🚀 Features Documentation

Feature-specific implementation guides and technical reports.

### Banking & Payments
| Document | Purpose | Last Updated | Size | Description |
|----------|---------|--------------|------|-------------|
| [BANKING_FEATURE_TECHNICAL_REPORT.md](Features/Banking/BANKING_FEATURE_TECHNICAL_REPORT.md) | Banking Implementation | Sep 16, 2025 | 10KB | Platform-agnostic analysis of deposit & withdraw implementation with unified banking flow design |

### Recommendation System
| Document | Purpose | Last Updated | Size | Description |
|----------|---------|--------------|------|-------------|
| [BET-RECOMMENDATION-SYSTEM-API-GUIDE.md](Features/RecSys/BET-RECOMMENDATION-SYSTEM-API-GUIDE.md) | RecSys API Integration | Sep 16, 2025 | 12KB | Complete guide for integrating ML-powered bet recommendations with 3 distinct APIs |
| [RecSys-Frontend-Integration-Guide.md](Features/RecSys/RecSys-Frontend-Integration-Guide.md) | Frontend Integration | Sep 16, 2025 | 6KB | Frontend implementation guide for recommendation system |
| [RecSys-Frontend-Integration-Guide.pdf](Features/RecSys/RecSys-Frontend-Integration-Guide.pdf) | PDF Reference | Sep 16, 2025 | 168KB | PDF version of frontend integration guide |

### EveryMatrix Integration
| Document | Purpose | Last Updated | Size | Description |
|----------|---------|--------------|------|-------------|
| [EVERYMATRIX_MAINTENANCE_HANDLING.md](Features/EveryMatrix/EVERYMATRIX_MAINTENANCE_HANDLING.md) | Maintenance Mode | Sep 16, 2025 | 7KB | Handling WAMP WebSocket maintenance mode issues and splash screen fixes |
| [EveryMatrix-Score-API-Findings.md](Features/EveryMatrix/EveryMatrix-Score-API-Findings.md) | Score API Research | Sep 27, 2025 | 7KB | Latest findings and analysis of EveryMatrix Score API implementation |

### Casino
| Document | Purpose | Last Updated | Size | Description |
|----------|---------|--------------|------|-------------|
| [00-CASINO_IMPLEMENTATION_JOURNAL.md](Casino/00-CASINO_IMPLEMENTATION_JOURNAL.md) | Implementation Journal | Aug 1, 2025 | 6KB | Development journal for casino feature implementation |
| [01-API_INVESTIGATION.md](Casino/01-API_INVESTIGATION.md) | API Research | Aug 1, 2025 | 8KB | Casino API investigation and integration findings |
| [02-NEXT_STEPS_DETAILED.md](Casino/02-NEXT_STEPS_DETAILED.md) | Implementation Plan | Aug 1, 2025 | 11KB | Detailed next steps for casino feature development |
| [03-IMPLEMENTATION_REFERENCES.md](Casino/03-IMPLEMENTATION_REFERENCES.md) | Reference Guide | Aug 1, 2025 | 12KB | Implementation references and patterns for casino features |
| [04-TESTING_REQUIREMENTS.md](Casino/04-TESTING_REQUIREMENTS.md) | Testing Strategy | Aug 1, 2025 | 8KB | Casino feature testing requirements and procedures |
| [UI-tasks/](Casino/UI-tasks/) | UI Components | Aug 1, 2025 | - | Detailed UI component specifications for casino interface |

### Filtering System
| Document | Purpose | Last Updated | Size | Description |
|----------|---------|--------------|------|-------------|
| [FILTERS_ARCHITECTURE_REPORT.md](Filters/FILTERS_ARCHITECTURE_REPORT.md) | Filter Architecture | Aug 4, 2025 | 10KB | Architecture report for event filtering system |
| [web-filters-technical-investigation.md](Filters/web-filters-technical-investigation.md) | Technical Investigation | Aug 4, 2025 | 9KB | Technical investigation of web-based filtering implementation |
| [EVENTS_FILTERING_SYSTEM_ANALYSIS.md](Filters/EVENTS_FILTERING_SYSTEM_ANALYSIS.md) | System Analysis | Sep 16, 2025 | 18KB | Comprehensive analysis of events filtering system |

---

## 🔧 Design Patterns & Components

Component patterns and architectural guidelines.

| Document | Purpose | Last Updated | Size | Description |
|----------|---------|--------------|------|-------------|
| [TABLEVIEW_CELL_COMPONENT_PATTERN.md](Patterns/TABLEVIEW_CELL_COMPONENT_PATTERN.md) | TableView Cells | Sep 16, 2025 | 5KB | Pattern for GomaUI components in UITableView cells with synchronous data access |
| [TopBarContainerArchitecture.md](Patterns/TopBarContainerArchitecture.md) | Navigation Architecture | Sep 24, 2025 | 11KB | Top bar container architecture and implementation patterns |
| [COORDINATOR_IMPLEMENTATION_GAPS.md](Patterns/COORDINATOR_IMPLEMENTATION_GAPS.md) | Coordinator Pattern | Sep 24, 2025 | 9KB | Analysis of coordinator pattern implementation gaps |
| [CoordinatorRefactorPlan.md](Patterns/CoordinatorRefactorPlan.md) | Refactor Planning | Sep 24, 2025 | 16KB | Comprehensive plan for coordinator pattern refactoring |

---

## 🛠️ Development Tools & Debugging

Tools, utilities, and debugging guides for development workflow.

| Document | Purpose | Last Updated | Size | Description |
|----------|---------|--------------|------|-------------|
| [GOMA_LOGGER_FRAMEWORK_DESIGN.md](Tools/GOMA_LOGGER_FRAMEWORK_DESIGN.md) | Logging Framework | Sep 16, 2025 | 14KB | Professional iOS logging framework design to replace 397 print() statements |
| [Xcode-MCP-Client-Guide.md](Tools/Xcode-MCP-Client-Guide.md) | MCP Integration | Jul 29, 2025 | 2KB | Guide for Xcode MCP client integration |
| [CASHOUT_API_DEBUG_REPORT.md](Tools/CASHOUT_API_DEBUG_REPORT.md) | API Debugging | Sep 24, 2025 | 4KB | Cashout API debugging procedures and troubleshooting |

---

## 📚 Legacy Documentation

Older documentation that may still contain valuable information but is not actively maintained.

| Document | Purpose | Last Updated | Size | Description |
|----------|---------|--------------|------|-------------|
| [serviceprovider_adapter.md](Legacy/serviceprovider_adapter.md) | Provider Adapter | Jul 29, 2025 | 23KB | Legacy service provider adapter documentation |
| [sportsbook-ios-data-flow-diagrams.md](Legacy/sportsbook-ios-data-flow-diagrams.md) | Data Flow Diagrams | Jul 29, 2025 | 22KB | Legacy data flow architecture diagrams |
| [development/white_labeling.md](Legacy/development/white_labeling.md) | White Labeling | Jul 29, 2025 | 12KB | Legacy white labeling implementation guide |

---

## 📦 Archive

Historical documentation preserved for reference.

| Document | Purpose | Date Archived | Size | Description |
|----------|---------|---------------|------|-------------|
| [mixmatch_references.md](Archive/mixmatch_references.md) | Mix Match Feature | Jul 29, 2025 | 88KB | Comprehensive references for mix match feature (largest doc in archive) |
| [qa_test_list.md](Archive/qa_test_list.md) | QA Testing | Jul 29, 2025 | 20KB | Historical QA test procedures |
| [EveryMatrix-Integration-Report.md](Archive/EveryMatrix-Integration-Report.md) | Integration Report | Jul 29, 2025 | 5KB | Historical EveryMatrix integration analysis |
| [ServerDynamicTheming.md](Archive/ServerDynamicTheming.md) | Dynamic Theming | Jul 29, 2025 | 10KB | Server-driven dynamic theming implementation |
| [v2_project_structure_proposal.md](Archive/v2_project_structure_proposal.md) | Structure Proposal | Jul 29, 2025 | 7KB | Version 2 project structure proposals |
| [mixmatch_feature_implementation.md](Archive/mixmatch_feature_implementation.md) | Mix Match Implementation | Jul 29, 2025 | 6KB | Mix match feature implementation details |
| [mixmatch_implementation_summary.md](Archive/mixmatch_implementation_summary.md) | Implementation Summary | Jul 29, 2025 | 3KB | Summary of mix match implementation |
| [TableView to collection.md](Archive/TableView%20to%20collection.md) | Migration Guide | Jul 29, 2025 | 4KB | TableView to collection view migration |

---

## 📝 Development Journal

Active development logs documenting day-to-day progress, bug fixes, and feature implementations.

📁 **[DevelopmentJournal/](DevelopmentJournal/)** - Contains 90+ daily development entries from June 2025 to present, tracking all major implementations, refactors, and architectural decisions.

See [DevelopmentJournal/README.md](DevelopmentJournal/README.md) for index and organization.

---

## 📊 Documentation Statistics

- **Total Documents**: 130+ files
- **Core Documentation**: 3 essential guides (53KB)
- **Feature Documentation**: 20+ feature-specific guides
- **Architecture**: 4 system design documents
- **Development Tools**: 3 tooling guides
- **Legacy/Archive**: 10+ historical documents
- **Development Journal**: 90+ daily entries
- **Documentation Coverage**: From Jul 2025 to present
- **Largest Document**: `mixmatch_references.md` (88KB)
- **Most Recent**: Updated Sep 27, 2025

---

## 🔍 Quick Navigation

### By Topic
- **New to the project?** Start with [Core Documentation](#-core-documentation-essential-reading)
- **Implementing features?** Check [Features Documentation](#-features-documentation)
- **Architectural decisions?** See [Architecture Documentation](#️-architecture-documentation)
- **Component patterns?** Review [Design Patterns](#-design-patterns--components)
- **Debugging issues?** Use [Development Tools](#️-development-tools--debugging)
- **Daily progress?** Browse [Development Journal](DevelopmentJournal/)

### By Recency
- **Latest (Sep 2025)**: EveryMatrix Score API, Banking Features, Casino Implementation
- **August 2025**: Casino UI Components, Filters Architecture
- **July 2025**: MVVM Architecture, UI Component Guide, Core Documentation

---

*Last Updated: September 27, 2025*
*Total Documentation Size: ~1.2MB*