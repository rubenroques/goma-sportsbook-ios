#!/usr/bin/env python3
"""
Tool to remove Xcode template header comments from Swift files.

This script recursively searches for Swift files and removes the standard
Xcode file header comments that are automatically added when creating new files.

Author: Claude Code
Date: August 26, 2025
"""

import os
import sys
import re
import argparse
import shutil
import subprocess
from pathlib import Path
from typing import List, Set, Optional, Tuple


class XcodeCommentRemover:
    """Main class for removing Xcode template comments from Swift files."""
    
    def __init__(self, root_path: str, dry_run: bool = True, create_backup: bool = False):
        self.root_path = Path(root_path).resolve()
        self.dry_run = dry_run
        self.create_backup = create_backup
        self.ignored_patterns = set()
        self.processed_files = []
        self.modified_files = []
        
        # Load .gitignore patterns
        self._load_gitignore_patterns()
        
    def _load_gitignore_patterns(self):
        """Load .gitignore patterns to respect ignored files."""
        gitignore_path = self.root_path / '.gitignore'
        if gitignore_path.exists():
            with open(gitignore_path, 'r', encoding='utf-8') as f:
                for line in f:
                    line = line.strip()
                    if line and not line.startswith('#'):
                        # Convert gitignore pattern to regex-like pattern
                        pattern = line.replace('*', '.*').replace('/', os.sep)
                        self.ignored_patterns.add(pattern)
        
        # Always ignore common build directories
        self.ignored_patterns.update([
            '.*build.*',
            '.*DerivedData.*',
            '.*xcuserdata.*',
            '.*node_modules.*',
            '.*\.git.*',
            '.*__pycache__.*',
            '.*\.build.*'
        ])
    
    def _is_ignored_path(self, file_path: Path) -> bool:
        """Check if a file path should be ignored based on .gitignore patterns."""
        relative_path = str(file_path.relative_to(self.root_path))
        
        for pattern in self.ignored_patterns:
            if re.search(pattern, relative_path):
                return True
        return False
    
    def _detect_xcode_comment_block(self, content: str) -> Tuple[bool, int]:
        """
        Detect if the file starts with an Xcode template comment block.
        Returns (has_comment_block, end_line_number)
        """
        lines = content.splitlines()
        
        # Must start with "//"
        if not lines or not lines[0].strip().startswith('//'):
            return False, 0
        
        # Look for the typical Xcode pattern:
        # //
        # //  FileName.swift
        # //  ModuleName
        # //
        # //  Created by Author on Date.
        # //
        
        comment_end = 0
        in_comment_block = True
        found_filename = False
        found_created = False
        
        for i, line in enumerate(lines):
            stripped = line.strip()
            
            # Empty comment line or comment with content
            if stripped == '//' or stripped.startswith('// '):
                comment_end = i
                
                # Check for filename pattern (ends with .swift)
                if '.swift' in stripped:
                    found_filename = True
                
                # Check for "Created by" pattern
                if 'Created by' in stripped or 'created by' in stripped.lower():
                    found_created = True
                    
            elif stripped == '':
                # Empty line after comment block
                if in_comment_block:
                    comment_end = i
                    break
            else:
                # Non-comment line
                break
        
        # Only consider it an Xcode template if we found both filename and created patterns
        is_template = found_filename and found_created and comment_end > 0
        
        return is_template, comment_end + 1 if is_template else 0
    
    def _remove_comment_block(self, content: str) -> Optional[str]:
        """Remove the Xcode comment block from the content."""
        has_comment, end_line = self._detect_xcode_comment_block(content)
        
        if not has_comment:
            return None
        
        lines = content.splitlines()
        
        # Skip empty lines after the comment block
        while end_line < len(lines) and lines[end_line].strip() == '':
            end_line += 1
        
        # Return the content without the comment block
        remaining_lines = lines[end_line:]
        return '\n'.join(remaining_lines) + '\n' if remaining_lines else ''
    
    def _create_backup(self, file_path: Path):
        """Create a backup of the original file."""
        backup_path = file_path.with_suffix(file_path.suffix + '.backup')
        shutil.copy2(file_path, backup_path)
        print(f"  📁 Backup created: {backup_path}")
    
    def process_file(self, file_path: Path) -> bool:
        """Process a single Swift file. Returns True if file was modified."""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                original_content = f.read()
            
            # Try to remove the comment block
            new_content = self._remove_comment_block(original_content)
            
            if new_content is None:
                # No Xcode template comment found
                return False
            
            if new_content == original_content:
                # Content unchanged
                return False
            
            # File needs modification
            relative_path = file_path.relative_to(self.root_path)
            
            if self.dry_run:
                print(f"  🔍 Would modify: {relative_path}")
                # Show a preview of changes
                original_lines = original_content.splitlines()[:10]
                new_lines = new_content.splitlines()[:5]
                print(f"      Removing {len(original_lines) - len(new_lines)} lines of comments")
                return True
            else:
                # Actually modify the file
                if self.create_backup:
                    self._create_backup(file_path)
                
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                
                print(f"  ✅ Modified: {relative_path}")
                return True
                
        except Exception as e:
            print(f"  ❌ Error processing {file_path}: {e}")
            return False
    
    def find_swift_files(self) -> List[Path]:
        """Find all Swift files in the project, respecting .gitignore."""
        swift_files = []
        
        for file_path in self.root_path.rglob('*.swift'):
            if not self._is_ignored_path(file_path):
                swift_files.append(file_path)
        
        return sorted(swift_files)
    
    def process_all_files(self):
        """Process all Swift files in the project."""
        swift_files = self.find_swift_files()
        
        if not swift_files:
            print("❌ No Swift files found!")
            return
        
        print(f"🔎 Found {len(swift_files)} Swift files to analyze")
        
        if self.dry_run:
            print("🚨 DRY RUN MODE - No files will be modified")
        
        print()
        
        modified_count = 0
        
        for file_path in swift_files:
            self.processed_files.append(file_path)
            
            if self.process_file(file_path):
                modified_count += 1
                self.modified_files.append(file_path)
        
        # Summary
        print(f"\n📊 Summary:")
        print(f"   Files analyzed: {len(swift_files)}")
        print(f"   Files with Xcode comments: {modified_count}")
        
        if self.dry_run and modified_count > 0:
            print(f"\n💡 To actually remove the comments, run with --apply flag")
        elif modified_count > 0:
            print(f"\n✅ Successfully processed {modified_count} files")
        else:
            print(f"\n🎉 No Xcode template comments found!")


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Remove Xcode template header comments from Swift files",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python remove_xcode_comments.py /path/to/project                    # Dry run
  python remove_xcode_comments.py /path/to/project --apply            # Actually remove
  python remove_xcode_comments.py /path/to/project --apply --backup   # Remove with backups
        """
    )
    
    parser.add_argument(
        'path',
        help='Path to the project directory containing Swift files'
    )
    
    parser.add_argument(
        '--apply',
        action='store_true',
        help='Actually modify files (default is dry-run mode)'
    )
    
    parser.add_argument(
        '--backup',
        action='store_true',
        help='Create backup files before modifying (only with --apply)'
    )
    
    parser.add_argument(
        '--verbose', '-v',
        action='store_true',
        help='Verbose output'
    )
    
    args = parser.parse_args()
    
    # Validate path
    if not os.path.exists(args.path):
        print(f"❌ Error: Path '{args.path}' does not exist")
        sys.exit(1)
    
    if not os.path.isdir(args.path):
        print(f"❌ Error: Path '{args.path}' is not a directory")
        sys.exit(1)
    
    # Show backup warning if needed
    if args.backup and not args.apply:
        print("⚠️  Warning: --backup flag ignored in dry-run mode")
    
    print("🛠️  Xcode Comment Remover")
    print(f"📁 Target directory: {args.path}")
    print()
    
    # Process files
    remover = XcodeCommentRemover(
        root_path=args.path,
        dry_run=not args.apply,
        create_backup=args.backup and args.apply
    )
    
    remover.process_all_files()


if __name__ == '__main__':
    main()