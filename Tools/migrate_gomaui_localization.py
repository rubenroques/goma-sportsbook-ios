#!/usr/bin/env python3
"""
GomaUI Localization Migration Script

Automatically migrates hardcoded UI strings in GomaUI components to use LocalizationProvider.
Matches strings against existing BetssonCameroonApp localizations.

Usage:
    python3 tools/migrate_gomaui_localization.py --dry-run  # Preview only
    python3 tools/migrate_gomaui_localization.py            # Execute migration
"""

import re
import os
import sys
import argparse
from pathlib import Path
from typing import Dict, List, Tuple, Optional, Set
from dataclasses import dataclass
from difflib import SequenceMatcher


# ============================================================================
# Data Classes
# ============================================================================

@dataclass
class StringLiteral:
    """Represents a string literal found in Swift code"""
    value: str
    line_number: int
    context: str  # Surrounding code context
    file_path: str
    full_line: str


@dataclass
class MigrationResult:
    """Result of processing a single string"""
    string_literal: StringLiteral
    action: str  # "MIGRATED", "SKIPPED", "NEW_KEY_NEEDED", "REQUIRES_REVIEW"
    localization_key: Optional[str]
    reason: str
    matched_value: Optional[str] = None
    has_variables: bool = False
    has_pluralization: bool = False


# ============================================================================
# Module 1: Swift String Extractor
# ============================================================================

class SwiftStringExtractor:
    """Extracts string literals from Swift files with context"""

    # Pattern to match string literals while avoiding comments
    STRING_PATTERN = re.compile(r'"([^"\\]|\\.)*"')

    # Patterns to identify the context where string is used
    CONTEXT_PATTERNS = {
        'setTitle': re.compile(r'\.setTitle\s*\(\s*"[^"]*"\s*,'),
        'text_assignment': re.compile(r'\.text\s*=\s*"[^"]*"'),
        'title_assignment': re.compile(r'\.title\s*=\s*"[^"]*"'),
        'placeholder': re.compile(r'\.placeholder\s*=\s*"[^"]*"'),
        'UILabel_init': re.compile(r'UILabel\([^)]*"[^"]*"'),
        'UIButton_init': re.compile(r'UIButton\([^)]*"[^"]*"'),
    }

    def extract_string_literals(self, swift_file_path: str) -> List[StringLiteral]:
        """Extract all string literals with their context from a Swift file"""
        results = []

        try:
            with open(swift_file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()

            for line_num, line in enumerate(lines, 1):
                # Skip comments
                if line.strip().startswith('//') or line.strip().startswith('*'):
                    continue

                # Find all string literals in the line
                matches = self.STRING_PATTERN.finditer(line)
                for match in matches:
                    string_with_quotes = match.group(0)
                    string_value = string_with_quotes[1:-1]  # Remove quotes

                    # Get context (lines around it)
                    context_start = max(0, line_num - 3)
                    context_end = min(len(lines), line_num + 2)
                    context = ''.join(lines[context_start:context_end])

                    results.append(StringLiteral(
                        value=string_value,
                        line_number=line_num,
                        context=context,
                        file_path=swift_file_path,
                        full_line=line.strip()
                    ))

        except Exception as e:
            print(f"Error reading {swift_file_path}: {e}")

        return results


# ============================================================================
# Module 2: String Classifier
# ============================================================================

class StringClassifier:
    """Classifies strings as UI text or technical strings"""

    # Patterns that indicate a string should be SKIPPED (not UI text)
    SKIP_PATTERNS = [
        # Image names
        (r'UIImage\s*\(\s*named:\s*"', 'UIImage named'),
        (r'\.imageset', 'Image asset name'),
        (r'_icon', 'Icon identifier'),
        (r'_image', 'Image identifier'),
        (r'_bar_icon', 'Bar icon identifier'),

        # Identifiers
        (r'\.identifier\s*=', 'Identifier assignment'),
        (r'reuseIdentifier', 'Reuse identifier'),
        (r'accessibilityIdentifier', 'Accessibility identifier'),

        # Notifications
        (r'NotificationCenter', 'Notification name'),
        (r'Notification\.Name', 'Notification name'),

        # UserDefaults
        (r'UserDefaults.*forKey:', 'UserDefaults key'),

        # Bundle resources
        (r'Bundle\.module', 'Bundle resource'),
        (r'Bundle\.main', 'Bundle resource'),

        # Color names
        (r'UIColor\s*\(\s*named:', 'Color name'),

        # Storyboard/XIB
        (r'\.storyboard', 'Storyboard name'),
        (r'\.xib', 'XIB name'),

        # Segue identifiers
        (r'segueIdentifier', 'Segue identifier'),

        # Keys (generally)
        (r'Key\s*=', 'Key constant'),

        # File extensions
        (r'\.\w{2,4}"', 'File extension'),

        # URLs/Schemes
        (r'https?://', 'URL'),
        (r'://','URL scheme'),
    ]

    # Patterns that strongly indicate UI text
    UI_TEXT_INDICATORS = [
        'setTitle(',
        '.text =',
        '.title =',
        '.placeholder =',
        'UILabel(',
        'UIButton(',
        'attributedText',
        'NSAttributedString',
        'NSLocalizedString',
        'localized(',
    ]

    def is_ui_text(self, string_literal: StringLiteral) -> Tuple[bool, str]:
        """
        Determine if string is UI text that should be localized
        Returns: (should_localize, reason)
        """
        value = string_literal.value
        context = string_literal.context
        full_line = string_literal.full_line

        # Skip empty strings
        if not value or len(value.strip()) == 0:
            return (False, "Empty string")

        # Skip very short strings (likely technical)
        if len(value) == 1 and not value.isalpha():
            return (False, f"Single non-alpha character: '{value}'")

        # Check skip patterns
        for pattern, reason in self.SKIP_PATTERNS:
            if re.search(pattern, context) or re.search(pattern, full_line):
                return (False, reason)

        # Check if it's a UI text indicator
        for indicator in self.UI_TEXT_INDICATORS:
            if indicator in context or indicator in full_line:
                return (True, f"UI text indicator: {indicator}")

        # If it contains spaces and multiple words, likely UI text
        if ' ' in value and len(value.split()) > 1:
            # But not if it's a file path or identifier
            if '/' not in value and '_' not in value:
                return (True, "Multi-word string (likely UI text)")

        # Check if it starts with uppercase (common for UI labels)
        if value[0].isupper() and len(value) > 3:
            return (True, "Capitalized string (likely UI label)")

        # Default: skip (be conservative)
        return (False, "No clear UI text indicator")


# ============================================================================
# Module 3: Localization Matcher
# ============================================================================

class LocalizationMatcher:
    """Matches strings against existing localizations"""

    def __init__(self, english_strings_file: str):
        self.localization_map: Dict[str, str] = {}  # value -> key
        self.key_map: Dict[str, str] = {}  # key -> value
        self.load_localizations(english_strings_file)

    def load_localizations(self, file_path: str):
        """Parse Localizable.strings file"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()

            # Pattern: "key" = "value";
            pattern = re.compile(r'"([^"]+)"\s*=\s*"([^"]+)"\s*;')

            for line in lines:
                match = pattern.search(line)
                if match:
                    key = match.group(1)
                    value = match.group(2)
                    self.localization_map[value] = key
                    self.key_map[key] = value

            print(f"Loaded {len(self.localization_map)} localization entries")

        except Exception as e:
            print(f"Error loading localizations: {e}")

    def find_exact_match(self, ui_string: str) -> Optional[str]:
        """Return existing key if exact match found"""
        return self.localization_map.get(ui_string)

    def find_fuzzy_match(self, ui_string: str, threshold: float = 0.8) -> List[Tuple[str, str, float]]:
        """
        Find potential matches with similarity score
        Returns: List of (key, value, similarity_score)
        """
        matches = []

        for value, key in self.localization_map.items():
            similarity = SequenceMatcher(None, ui_string.lower(), value.lower()).ratio()
            if similarity >= threshold:
                matches.append((key, value, similarity))

        return sorted(matches, key=lambda x: x[2], reverse=True)

    def suggest_new_key(self, ui_string: str, component_name: str) -> str:
        """Generate snake_case key following convention"""
        # Extract component base name
        component_base = Path(component_name).stem.replace('View', '').replace('ViewModel', '')

        # Convert to snake_case
        component_snake = self._to_snake_case(component_base)

        # Generate key from string
        string_snake = self._to_snake_case(ui_string)

        # Limit length
        if len(string_snake) > 30:
            string_snake = string_snake[:30]

        return f"{component_snake}_{string_snake}"

    def _to_snake_case(self, text: str) -> str:
        """Convert text to snake_case"""
        # Remove special characters
        text = re.sub(r'[^\w\s]', '', text)
        # Convert to lowercase and replace spaces with underscores
        text = text.lower().strip().replace(' ', '_')
        # Remove multiple underscores
        text = re.sub(r'_+', '_', text)
        return text


# ============================================================================
# Module 4: Code Transformer
# ============================================================================

class CodeTransformer:
    """Transforms Swift code to use LocalizationProvider"""

    def replace_string_with_localization(
        self,
        swift_content: str,
        string_literal: StringLiteral,
        localization_key: str
    ) -> str:
        """
        Replace string literal with LocalizationProvider call
        """
        lines = swift_content.split('\n')
        line_idx = string_literal.line_number - 1

        if line_idx >= len(lines):
            return swift_content

        original_line = lines[line_idx]

        # Create replacement
        old_string = f'"{string_literal.value}"'
        new_string = f'LocalizationProvider.string("{localization_key}")'

        # Replace in line
        if old_string in original_line:
            modified_line = original_line.replace(old_string, new_string, 1)
            lines[line_idx] = modified_line

        return '\n'.join(lines)

    def ensure_import(self, swift_content: str, module: str = "GomaUI") -> str:
        """Ensure import statement exists"""
        lines = swift_content.split('\n')

        # Check if import already exists
        for line in lines:
            if f'import {module}' in line:
                return swift_content

        # Find where to insert (after other imports)
        insert_idx = 0
        for i, line in enumerate(lines):
            if line.startswith('import '):
                insert_idx = i + 1

        # Insert import
        lines.insert(insert_idx, f'import {module}')

        return '\n'.join(lines)


# ============================================================================
# Module 5: Migration Reporter
# ============================================================================

class MigrationReporter:
    """Generates comprehensive migration reports"""

    def __init__(self):
        self.migrated: List[MigrationResult] = []
        self.skipped: List[MigrationResult] = []
        self.new_keys_needed: List[MigrationResult] = []
        self.requires_review: List[MigrationResult] = []

    def add_result(self, result: MigrationResult):
        """Add a migration result"""
        if result.action == "MIGRATED":
            self.migrated.append(result)
        elif result.action == "SKIPPED":
            self.skipped.append(result)
        elif result.action == "NEW_KEY_NEEDED":
            self.new_keys_needed.append(result)
        elif result.action == "REQUIRES_REVIEW":
            self.requires_review.append(result)

    def generate_report(self, output_file: str):
        """Generate comprehensive markdown report"""
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write("# GomaUI Localization Migration Report\n\n")
            f.write(f"Generated: {self._timestamp()}\n\n")

            # Summary
            f.write("## Summary\n\n")
            f.write(f"- **Migrated**: {len(self.migrated)}\n")
            f.write(f"- **Skipped**: {len(self.skipped)}\n")
            f.write(f"- **New Keys Needed**: {len(self.new_keys_needed)}\n")
            f.write(f"- **Requires Review**: {len(self.requires_review)}\n\n")

            # Migrated
            if self.migrated:
                f.write("## ✅ Successfully Migrated\n\n")
                for result in self.migrated:
                    f.write(f"### {Path(result.string_literal.file_path).name}:{result.string_literal.line_number}\n")
                    f.write(f"- **String**: `\"{result.string_literal.value}\"`\n")
                    f.write(f"- **Key**: `{result.localization_key}`\n")
                    if result.matched_value:
                        f.write(f"- **Matched**: `\"{result.matched_value}\"`\n")
                    if result.has_variables:
                        f.write(f"- **⚠️ Contains variables - verify format**\n")
                    if result.has_pluralization:
                        f.write(f"- **⚠️ May need pluralization handling**\n")
                    f.write(f"- **Reason**: {result.reason}\n\n")

            # New Keys Needed
            if self.new_keys_needed:
                f.write("## 🆕 New Localization Keys Needed\n\n")
                for result in self.new_keys_needed:
                    f.write(f"### {Path(result.string_literal.file_path).name}:{result.string_literal.line_number}\n")
                    f.write(f"- **String**: `\"{result.string_literal.value}\"`\n")
                    f.write(f"- **Suggested Key**: `{result.localization_key}`\n")
                    f.write(f"- **Reason**: {result.reason}\n\n")

            # Requires Review
            if self.requires_review:
                f.write("## ⚠️ Requires Manual Review\n\n")
                for result in self.requires_review:
                    f.write(f"### {Path(result.string_literal.file_path).name}:{result.string_literal.line_number}\n")
                    f.write(f"- **String**: `\"{result.string_literal.value}\"`\n")
                    f.write(f"- **Key**: `{result.localization_key or 'N/A'}`\n")
                    f.write(f"- **Reason**: {result.reason}\n\n")

            # Skipped
            if self.skipped:
                f.write("## ⏭️ Skipped (Not UI Text)\n\n")
                skipped_reasons: Dict[str, List[MigrationResult]] = {}
                for result in self.skipped:
                    if result.reason not in skipped_reasons:
                        skipped_reasons[result.reason] = []
                    skipped_reasons[result.reason].append(result)

                for reason, results in skipped_reasons.items():
                    f.write(f"### {reason} ({len(results)} strings)\n\n")
                    for result in results[:5]:  # Show first 5 of each type
                        f.write(f"- `\"{result.string_literal.value}\"` ")
                        f.write(f"({Path(result.string_literal.file_path).name}:{result.string_literal.line_number})\n")
                    if len(results) > 5:
                        f.write(f"- ... and {len(results) - 5} more\n")
                    f.write("\n")

        print(f"\n📄 Report generated: {output_file}")

    def generate_new_keys_file(self, output_file: str):
        """Generate file with new localization keys"""
        if not self.new_keys_needed:
            print("No new keys needed")
            return

        with open(output_file, 'w', encoding='utf-8') as f:
            f.write("// New localization keys to add to Localizable.strings\n")
            f.write("// Add these to both en.lproj and fr.lproj (with translations)\n\n")

            for result in self.new_keys_needed:
                f.write(f"// No exact match found\n")
                f.write(f'"{result.localization_key}" = "{result.string_literal.value}";\n\n')

        print(f"📝 New keys file generated: {output_file}")

    def print_summary(self):
        """Print summary to console"""
        print("\n" + "="*70)
        print("MIGRATION SUMMARY")
        print("="*70)
        print(f"✅ Migrated:          {len(self.migrated)}")
        print(f"🆕 New Keys Needed:   {len(self.new_keys_needed)}")
        print(f"⚠️  Requires Review:   {len(self.requires_review)}")
        print(f"⏭️  Skipped:           {len(self.skipped)}")
        print("="*70 + "\n")

    def _timestamp(self):
        from datetime import datetime
        return datetime.now().strftime("%Y-%m-%d %H:%M:%S")


# ============================================================================
# Main Migration Engine
# ============================================================================

class MigrationEngine:
    """Orchestrates the migration process"""

    def __init__(
        self,
        gomaui_dir: str,
        localizations_file: str,
        dry_run: bool = False
    ):
        self.gomaui_dir = gomaui_dir
        self.dry_run = dry_run

        self.extractor = SwiftStringExtractor()
        self.classifier = StringClassifier()
        self.matcher = LocalizationMatcher(localizations_file)
        self.transformer = CodeTransformer()
        self.reporter = MigrationReporter()

    def find_swift_files(self) -> List[str]:
        """Find all Swift files in GomaUI components"""
        components_dir = Path(self.gomaui_dir)
        swift_files = list(components_dir.rglob("*.swift"))

        # Exclude certain files
        exclude_patterns = ['Tests', 'Preview', '.build']
        swift_files = [
            str(f) for f in swift_files
            if not any(pattern in str(f) for pattern in exclude_patterns)
        ]

        return swift_files

    def process_file(self, swift_file: str) -> List[MigrationResult]:
        """Process a single Swift file"""
        print(f"Processing: {Path(swift_file).name}")

        results = []

        # Extract strings
        string_literals = self.extractor.extract_string_literals(swift_file)

        # Process each string
        for string_literal in string_literals:
            result = self.process_string(string_literal)
            results.append(result)
            self.reporter.add_result(result)

        return results

    def process_string(self, string_literal: StringLiteral) -> MigrationResult:
        """Process a single string literal"""

        # Classify
        is_ui, reason = self.classifier.is_ui_text(string_literal)

        if not is_ui:
            return MigrationResult(
                string_literal=string_literal,
                action="SKIPPED",
                localization_key=None,
                reason=reason
            )

        # Try exact match
        key = self.matcher.find_exact_match(string_literal.value)

        if key:
            # Exact match found
            has_vars = '{' in string_literal.value or '%' in string_literal.value
            has_plural = self._detect_pluralization(string_literal.value)

            if has_vars or has_plural:
                action = "REQUIRES_REVIEW" if (has_vars and has_plural) else "MIGRATED"
            else:
                action = "MIGRATED"

            return MigrationResult(
                string_literal=string_literal,
                action=action,
                localization_key=key,
                reason=f"Exact match found",
                matched_value=string_literal.value,
                has_variables=has_vars,
                has_pluralization=has_plural
            )

        # No exact match - suggest new key
        suggested_key = self.matcher.suggest_new_key(
            string_literal.value,
            string_literal.file_path
        )

        return MigrationResult(
            string_literal=string_literal,
            action="NEW_KEY_NEEDED",
            localization_key=suggested_key,
            reason="No exact match found in existing localizations"
        )

    def apply_migrations(self, results: List[MigrationResult], file_path: str):
        """Apply migrations to a file"""
        if self.dry_run:
            return

        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()

            # Apply only MIGRATED (exact matches), skip NEW_KEY_NEEDED
            migrations_applied = False
            for result in results:
                if result.action == "MIGRATED" and result.localization_key:
                    content = self.transformer.replace_string_with_localization(
                        content,
                        result.string_literal,
                        result.localization_key
                    )
                    migrations_applied = True

            # Only modify file if we actually applied migrations
            if not migrations_applied:
                return

            # Ensure import
            content = self.transformer.ensure_import(content)

            # Write back
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)

            print(f"  ✅ Updated: {Path(file_path).name}")

        except Exception as e:
            print(f"  ❌ Error updating {file_path}: {e}")

    def _detect_pluralization(self, text: str) -> bool:
        """Detect if string likely needs pluralization"""
        plural_indicators = ['more', 'less', 'X ', ' X', '%d', 'games', 'items', 'legs']
        return any(indicator in text for indicator in plural_indicators)

    def run(self):
        """Run the migration process"""
        print("\n" + "="*70)
        print("GOMAUI LOCALIZATION MIGRATION")
        print("="*70)
        print(f"Mode: {'DRY RUN (no files will be modified)' if self.dry_run else 'LIVE (files will be modified)'}")
        print(f"GomaUI Directory: {self.gomaui_dir}")
        print("="*70 + "\n")

        # Find all Swift files
        swift_files = self.find_swift_files()
        print(f"Found {len(swift_files)} Swift files\n")

        # Process each file
        for swift_file in swift_files:
            results = self.process_file(swift_file)

            # Apply migrations if not dry run
            if results:
                self.apply_migrations(results, swift_file)

        # Generate reports
        print("\nGenerating reports...")
        self.reporter.generate_report("migration_report.md")
        self.reporter.generate_new_keys_file("new_localization_keys.txt")
        self.reporter.print_summary()


# ============================================================================
# Main Entry Point
# ============================================================================

def main():
    parser = argparse.ArgumentParser(description='Migrate GomaUI strings to LocalizationProvider')
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Preview changes without modifying files'
    )
    parser.add_argument(
        '--gomaui-dir',
        default='Frameworks/GomaUI/GomaUI/Sources/GomaUI/Components',
        help='Path to GomaUI components directory'
    )
    parser.add_argument(
        '--localizations',
        default='BetssonCameroonApp/App/Resources/Language/en.lproj/Localizable.strings',
        help='Path to English Localizable.strings file'
    )

    args = parser.parse_args()

    # Verify paths exist
    if not os.path.exists(args.gomaui_dir):
        print(f"Error: GomaUI directory not found: {args.gomaui_dir}")
        sys.exit(1)

    if not os.path.exists(args.localizations):
        print(f"Error: Localizations file not found: {args.localizations}")
        sys.exit(1)

    # Run migration
    engine = MigrationEngine(
        gomaui_dir=args.gomaui_dir,
        localizations_file=args.localizations,
        dry_run=args.dry_run
    )

    engine.run()


if __name__ == '__main__':
    main()
