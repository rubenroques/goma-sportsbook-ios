#!/usr/bin/env python3
"""
Xcode Build Script for Sportsbook iOS project
Enhanced version with better LLM integration and incremental build optimizations
"""

import argparse
import os
import subprocess
import sys
import re
import shutil
from enum import Enum
from typing import List, Dict, Optional, Tuple, Union
from dataclasses import dataclass

# ANSI colors for terminal output
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'  # No Color

class OutputLevel(Enum):
    NORMAL = "normal"          # Show all build output with beautification
    VERBOSE = "verbose"        # Show all output including commands
    ERRORS_ONLY = "errors-only"  # Show only errors
    WARNINGS_UP = "warnings-up"   # Show warnings and errors
    LLM_FRIENDLY = "llm-friendly"  # Machine-readable format

    def get_xcbeautify_args(self) -> List[str]:
        """Get the appropriate xcbeautify arguments for this output level"""
        if self == OutputLevel.VERBOSE:
            return ["--preserve-unbeautified"]
        elif self == OutputLevel.ERRORS_ONLY:
            return ["--quieter", "--disable-logging"]
        elif self == OutputLevel.WARNINGS_UP:
            return ["--quiet", "--disable-logging"]
        elif self == OutputLevel.NORMAL:
            return ["--disable-logging"]
        else:  # LLM_FRIENDLY doesn't use xcbeautify
            return []

@dataclass
class BuildError:
    """Structured representation of a build error"""
    file_path: str
    line_number: int
    column_number: Optional[int]
    message: str
    severity: str  # "error", "warning", or "note"
    code: Optional[str] = None

    def to_dict(self) -> Dict:
        """Convert to dictionary for JSON serialization"""
        return {
            "file": self.file_path,
            "line": self.line_number,
            "column": self.column_number,
            "message": self.message,
            "severity": self.severity,
            "code": self.code
        }

    def __str__(self) -> str:
        """String representation of the error"""
        location = f"{self.file_path}:{self.line_number}"
        if self.column_number:
            location += f":{self.column_number}"

        code_str = f" [{self.code}]" if self.code else ""
        return f"{self.severity.upper()}{code_str}: {self.message} at {location}"

class XcodeBuildRunner:
    def __init__(self):
        self.project_path = "Sportsbook.xcodeproj"
        self.available_schemes = {
            "Core frameworks and services": [
                "ServicesProvider", "SharedModels", "DictionaryCoding",
                "Extensions", "GomaAssets", "Theming"
            ],
            "Features and UI components": [
                "HeaderTextField", "CountrySelectionFeature", "RegisterFlow",
                "AdresseFrancaise", "NotificationsService"
            ],
            "Client applications": [
                "ATP", "Betsson PROD", "Betsson UAT", "Crocobet",
                "DAZN", "EveryMatrix", "GOMASports", "SportRadar PROD",
                "SportRadar UAT", "GomaSportRadar"
            ],
            "Tests": [
                "SportsbookTests"
            ]
        }
        self.provisioning_domain = "developerservices2.apple.com"
        self.domain_blocked = False

    def check_xcodebuild(self) -> bool:
        """Check if xcodebuild is installed and available"""
        try:
            subprocess.run(["which", "xcodebuild"],
                          check=True,
                          stdout=subprocess.PIPE,
                          stderr=subprocess.PIPE)
            return True
        except subprocess.CalledProcessError:
            return False

    def check_xcbeautify(self) -> bool:
        """Check if xcbeautify is installed and available"""
        try:
            subprocess.run(["which", "xcbeautify"],
                          check=True,
                          stdout=subprocess.PIPE,
                          stderr=subprocess.PIPE)
            return True
        except subprocess.CalledProcessError:
            return False

    def block_provisioning_domain(self, args) -> bool:
        """Block Apple's provisioning domain in /etc/hosts to speed up builds"""
        if not args.block_provisioning_checks:
            return False

        try:
            if args.output_level != OutputLevel.LLM_FRIENDLY:
                print(f"{Colors.YELLOW}Blocking {self.provisioning_domain} to speed up build...{Colors.NC}")

            # Add domain to /etc/hosts
            cmd = ["sudo", "bash", "-c", f"echo '127.0.0.1 {self.provisioning_domain}' >> /etc/hosts"]
            subprocess.run(cmd, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            self.domain_blocked = True
            return True
        except subprocess.CalledProcessError as e:
            if args.output_level != OutputLevel.LLM_FRIENDLY:
                print(f"{Colors.RED}Failed to block provisioning domain: {e}{Colors.NC}")
                print(f"{Colors.YELLOW}Build will continue but may be slower. Try running with sudo next time.{Colors.NC}")
            return False

    def unblock_provisioning_domain(self, args) -> None:
        """Unblock Apple's provisioning domain in /etc/hosts"""
        if not self.domain_blocked:
            return

        try:
            if args.output_level != OutputLevel.LLM_FRIENDLY:
                print(f"{Colors.YELLOW}Unblocking {self.provisioning_domain}...{Colors.NC}")

            # Remove domain from /etc/hosts
            escaped_domain = self.provisioning_domain.replace('.', r'\.')
            cmd = ["sudo", "sed", "-i", "", f"/{escaped_domain}/d", "/etc/hosts"]
            subprocess.run(cmd, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            self.domain_blocked = False
        except subprocess.CalledProcessError as e:
            if args.output_level != OutputLevel.LLM_FRIENDLY:
                print(f"{Colors.RED}Failed to unblock provisioning domain: {e}{Colors.NC}")
                print(f"{Colors.RED}WARNING: You may need to manually remove '{self.provisioning_domain}' from /etc/hosts{Colors.NC}")

    def clean_derived_data(self, output_level: OutputLevel) -> None:
        """Clean Xcode's DerivedData directory"""
        if output_level not in [OutputLevel.ERRORS_ONLY, OutputLevel.LLM_FRIENDLY]:
            print(f"{Colors.YELLOW}Cleaning DerivedData...{Colors.NC}")

        derived_data_path = os.path.expanduser("~/Library/Developer/Xcode/DerivedData")
        if os.path.exists(derived_data_path):
            try:
                shutil.rmtree(derived_data_path)
            except Exception as e:
                print(f"{Colors.RED}Error cleaning DerivedData: {e}{Colors.NC}")

    def build_command(self, args) -> List[str]:
        """Construct the xcodebuild command with all options and flags"""
        cmd = ["xcodebuild"]

        # Project
        cmd.extend(["-project", self.project_path])

        # Scheme
        cmd.extend(["-scheme", args.scheme])

        # Configuration
        cmd.extend(["-configuration", args.configuration])

        # Destination
        cmd.extend(["-destination", args.destination])

        # Base build settings
        cmd.extend([
            "SWIFT_VERSION=5",
            "IPHONEOS_DEPLOYMENT_TARGET=13.0",
            "ENABLE_TESTING=YES",
            "DEBUG_INFORMATION_FORMAT=dwarf",
            "SWIFT_OPTIMIZATION_LEVEL=-Onone",
            "GCC_OPTIMIZATION_LEVEL=0",
            "ENABLE_BITCODE=NO",
            # Add code signing flag based on the argument
            f"CODE_SIGNING_ALLOWED={'YES' if args.enable_code_signing else 'NO'}",
            "-UseModernBuildSystem=YES"  # Modern build system for better incremental builds
        ])

        # Add -quiet flag only for non-verbose output modes
        if args.output_level != OutputLevel.VERBOSE:
            cmd.append("-quiet")

        # For incremental builds, add optimization flags
        if args.action == "build":
            cmd.extend([
                "-parallelizeTargets",
                "-skipUnavailableActions",
                "-hideShellScriptEnvironment"
            ])

        # Add the action (build, test, clean)
        cmd.append(args.action)

        return cmd

    def parse_errors(self, output: str) -> List[BuildError]:
        """Parse build output to extract structured error information"""
        errors = []

        # Regular expressions for different error formats

        # 1. xcbeautify colored output format
        # Format: ❌ /path/to/file.swift:123:45: [31merror message[0m
        xcbeautify_error_pattern = re.compile(
            r'(?:❌|⚠️)\s+([^:]+):(\d+):(\d+)?:\s+\[\d+;(\d+)m(.*?)\[\d+m'
        )

        # 2. Standard compiler error format
        # Format: /path/to/file.swift:123:45: error: error message
        compiler_error_pattern = re.compile(
            r'([^:\s]+\.(?:swift|m|h|mm|cpp|c|xib|storyboard))(?::(\d+))?(?::(\d+))?:\s+(error|warning|note):\s+(.*)'
        )

        # 3. Raw build error format (common in xcodebuild output)
        # Format: error: <message>
        raw_error_pattern = re.compile(
            r'^(error|warning|note):\s+(.*?)$'
        )

        # 4. Failed command format
        # Format: The following build commands failed:
        failed_commands_pattern = re.compile(
            r'The following build commands failed:'
        )

        # 5. Command failure details
        # Format: \tCompileSwift normal arm64 /path/to/file.swift
        command_failure_pattern = re.compile(
            r'\t([^\s]+)\s+.*?\s+([^\s].*)'
        )

        lines = output.split('\n')
        in_failed_commands_section = False
        failed_files = set()

        for line in lines:
            if not line.strip():
                continue

            # Check for failed commands section (captures file paths of failing files)
            if failed_commands_pattern.search(line):
                in_failed_commands_section = True
                continue

            if in_failed_commands_section:
                cmd_match = command_failure_pattern.search(line)
                if cmd_match:
                    command, file_path = cmd_match.groups()
                    if file_path.endswith(('.swift', '.m', '.h', '.mm', '.cpp', '.c', '.xib', '.storyboard')):
                        failed_files.add(file_path)

            # Pattern 1: xcbeautify formatted errors
            match = xcbeautify_error_pattern.search(line)
            if match:
                file_path, line_num, col_num, severity_code, message = match.groups()
                severity = "error" if severity_code == "31" else "warning"

                errors.append(BuildError(
                    file_path=file_path,
                    line_number=int(line_num) if line_num else 0,
                    column_number=int(col_num) if col_num else None,
                    message=message.strip(),
                    severity=severity
                ))
                continue

            # Pattern 2: Standard compiler errors
            match = compiler_error_pattern.search(line)
            if match:
                file_path, line_num, col_num, severity, message = match.groups()

                errors.append(BuildError(
                    file_path=file_path,
                    line_number=int(line_num) if line_num else 0,
                    column_number=int(col_num) if col_num else None,
                    message=message.strip(),
                    severity=severity
                ))
                continue

            # Pattern 3: Raw errors (without file info)
            match = raw_error_pattern.search(line)
            if match:
                severity, message = match.groups()

                # Find the closest file path in the message or use a generic one
                file_path = "unknown"
                for path in failed_files:
                    if path in message:
                        file_path = path
                        break

                errors.append(BuildError(
                    file_path=file_path,
                    line_number=0,
                    column_number=None,
                    message=message.strip(),
                    severity=severity
                ))

        # If we have raw errors but no file-specific errors, try to combine them
        if errors and any(e.file_path == "unknown" for e in errors):
            for error in errors:
                if error.file_path == "unknown":
                    for path in failed_files:
                        error.file_path = path
                        break

        return errors

    def run_build(self, args) -> Tuple[int, str, List[BuildError]]:
        """Execute the build command and return the result code, output, and structured errors"""
        cmd = self.build_command(args)
        use_beautifier = self.check_xcbeautify() and args.output_level != OutputLevel.LLM_FRIENDLY

        if args.output_level != OutputLevel.LLM_FRIENDLY:
            print(f"{Colors.YELLOW}Building {args.scheme} ({args.configuration})...{Colors.NC}")
        else:
            # Simple progress indicator for LLM mode
            print("BUILD_STATUS: RUNNING (large projects can take several minutes)")

        # Print command for all output levels
        if use_beautifier:
            xcbeautify_cmd = ["xcbeautify"] + OutputLevel(args.output_level).get_xcbeautify_args()
            print(f"{Colors.BLUE}Executing: {' '.join(cmd)} | {' '.join(xcbeautify_cmd)}{Colors.NC}")
        else:
            print(f"{Colors.BLUE}Executing: {' '.join(cmd)}{Colors.NC}")

        try:
            if use_beautifier:
                # Pipe through xcbeautify for better formatting
                process = subprocess.Popen(cmd,
                                        stdout=subprocess.PIPE,
                                        stderr=subprocess.STDOUT,
                                        text=True)

                # Get xcbeautify arguments based on output level
                xcbeautify_cmd = ["xcbeautify"] + OutputLevel(args.output_level).get_xcbeautify_args()

                beautifier = subprocess.Popen(xcbeautify_cmd,
                                           stdin=process.stdout,
                                           stdout=subprocess.PIPE,
                                           stderr=subprocess.STDOUT,
                                           text=True)

                process.stdout.close()  # Allow process to receive a SIGPIPE

                output = ""
                for line in iter(beautifier.stdout.readline, ''):
                    if args.output_level == OutputLevel.VERBOSE:
                        print(line, end='')
                    output += line

                return_code = process.wait()
                beautifier.wait()

                # Parse errors from the output
                errors = self.parse_errors(output)

                return return_code, output, errors
            else:
                # For LLM mode, we want to show some indication of progress
                process = subprocess.Popen(cmd,
                                        stdout=subprocess.PIPE,
                                        stderr=subprocess.STDOUT,
                                        text=True)

                output = ""
                progress_counter = 0
                progress_chars = ['.', '..', '...']

                # Process output as it comes
                for line in iter(process.stdout.readline, ''):
                    output += line

                    # Show progress indicator for LLM mode
                    if args.output_level == OutputLevel.LLM_FRIENDLY:
                        if "Compiling" in line or "Linking" in line:
                            phase = "COMPILING" if "Compiling" in line else "LINKING"
                            progress_counter = (progress_counter + 1) % 3
                            print(f"BUILD_STATUS: {phase}{progress_chars[progress_counter]}", end='\r')

                return_code = process.wait()

                # Parse errors from the output
                errors = self.parse_errors(output)

                return return_code, output, errors

        except Exception as e:
            if args.output_level == OutputLevel.LLM_FRIENDLY:
                print(f"BUILD_STATUS: ERROR - {str(e)}")
            return 1, str(e), []

    def process_output(self, return_code: int, output: str, errors: List[BuildError], args) -> int:
        """Process and display the build output according to the selected mode"""
        output_level = args.output_level

        if output_level == OutputLevel.VERBOSE:
            # Output already displayed in run_build for verbose mode
            pass
        elif output_level == OutputLevel.ERRORS_ONLY:
            if return_code != 0:
                print(f"{Colors.RED}Build failed with errors:{Colors.NC}")
                if errors:
                    for error in errors:
                        if error.severity == "error":
                            print(f"{Colors.RED}{error}{Colors.NC}")
                else:
                    print("No specific error message found, but build failed.")
            else:
                print(f"{Colors.GREEN}Build succeeded with no errors.{Colors.NC}")
        elif output_level == OutputLevel.LLM_FRIENDLY:
            # Machine-readable format optimized for LLM token usage
            if return_code != 0:
                print("\nBUILD_STATUS: FAILED")
                if errors:
                    # Group errors by file for more structured reporting
                    errors_by_file = {}
                    for error in errors:
                        if error.severity == "error":
                            if error.file_path not in errors_by_file:
                                errors_by_file[error.file_path] = []
                            errors_by_file[error.file_path].append(error)

                    if errors_by_file:
                        print("ERRORS:")
                        for file_path, file_errors in errors_by_file.items():
                            print(f"  FILE: {file_path}")
                            for error in file_errors:
                                line_info = f":{error.line_number}" if error.line_number else ""
                                print(f"    Line{line_info}: {error.message}")
                    else:
                        # If we couldn't extract structured errors, try to find error messages in output
                        error_lines = re.findall(r'(error:.*)', output)
                        if error_lines:
                            print("ERRORS:")
                            for i, line in enumerate(error_lines[:5]):  # Limit to first 5 errors
                                print(f"  {line.strip()}")
                            if len(error_lines) > 5:
                                print(f"  ... and {len(error_lines) - 5} more errors")
                        else:
                            print("No specific error details available.")
                else:
                    # If no structured errors found but build failed, try to extract some error info
                    error_lines = re.findall(r'(error:.*)', output)
                    if error_lines:
                        print("ERRORS:")
                        for i, line in enumerate(error_lines[:5]):  # Limit to first 5 errors
                            print(f"  {line.strip()}")
                        if len(error_lines) > 5:
                            print(f"  ... and {len(error_lines) - 5} more errors")
                    else:
                        print("No specific error details available.")
            else:
                print("\nBUILD_STATUS: SUCCESS")
        else:  # Normal or warnings-up mode
            # Show errors and warnings
            if errors:
                errors_shown = 0
                for error in errors:
                    if error.severity == "error" or (output_level == OutputLevel.WARNINGS_UP and error.severity == "warning"):
                        color = Colors.RED if error.severity == "error" else Colors.YELLOW
                        print(f"{color}{error}{Colors.NC}")
                        errors_shown += 1
                        if errors_shown >= 20:  # Limit number of errors shown
                            remaining = len([e for e in errors if e.severity in ("error", "warning")]) - errors_shown
                            if remaining > 0:
                                print(f"{Colors.YELLOW}... and {remaining} more errors/warnings{Colors.NC}")
                            break

        # Show final status for normal and verbose modes
        if output_level not in [OutputLevel.ERRORS_ONLY, OutputLevel.LLM_FRIENDLY]:
            if return_code == 0:
                print(f"{Colors.GREEN}✓ Build succeeded{Colors.NC}")
            else:
                print(f"{Colors.RED}✗ Build failed{Colors.NC}")

        return return_code

    def list_available_schemes(self) -> None:
        """Print the available schemes in a formatted way"""
        print("\nAvailable schemes:")

        for category, schemes in self.available_schemes.items():
            print(f"{category}:")
            for scheme in schemes:
                print(f"  - {scheme}")
            print()

    def run(self, args) -> int:
        """Main execution method"""
        # Convert string output level to enum
        args.output_level = OutputLevel(args.output_level)

        # Check if xcodebuild is available
        if not self.check_xcodebuild():
            print(f"{Colors.RED}Error: xcodebuild command not found{Colors.NC}")
            return 1

        # Clean if requested
        if args.clean:
            self.clean_derived_data(args.output_level)

        # Block provisioning domain if requested
        blocked = self.block_provisioning_domain(args)

        try:
            # Run the build
            return_code, output, errors = self.run_build(args)

            # Process and display output
            result = self.process_output(return_code, output, errors, args)

            return result
        finally:
            # Always unblock provisioning domain if it was blocked
            if blocked:
                self.unblock_provisioning_domain(args)


def parse_args():
    """Parse command-line arguments"""
    parser = argparse.ArgumentParser(
        description="Enhanced Xcode build script for Sportsbook iOS project",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )

    parser.add_argument(
        "-s", "--scheme",
        required=True,
        help="Build scheme (required)"
    )

    parser.add_argument(
        "-c", "--configuration",
        default="Debug",
        choices=["Debug", "Release"],
        help="Build configuration (Debug/Release, default: Debug)"
    )

    parser.add_argument(
        "-d", "--destination",
        default="platform=iOS Simulator,name=iPhone 16",
        help="Build destination (default: platform=iOS Simulator,name=iPhone 16)"
    )

    parser.add_argument(
        "-a", "--action",
        default="build",
        choices=["build", "test", "clean"],
        help="Build action (build/test/clean, default: build)"
    )

    parser.add_argument(
        "--clean",
        action="store_true",
        help="Clean build folder before building"
    )

    # Add new arguments for performance optimization
    parser.add_argument(
        "--enable-code-signing",
        action="store_true",
        help="Enable code signing (disabled by default to speed up builds)"
    )

    parser.add_argument(
        "--block-provisioning-checks",
        action="store_true",
        default=True,
        help="Block Apple provisioning checks during build (default: enabled)"
    )

    parser.add_argument(
        "--no-block-provisioning-checks",
        action="store_false",
        dest="block_provisioning_checks",
        help="Don't block Apple provisioning checks during build"
    )

    output_group = parser.add_mutually_exclusive_group()
    output_group.add_argument(
        "-v", "--verbose",
        action="store_const",
        dest="output_level",
        const="verbose",
        help="Show verbose output including all commands"
    )

    output_group.add_argument(
        "-w", "--warnings-up",
        action="store_const",
        dest="output_level",
        const="warnings-up",
        help="Show warnings and errors (default)"
    )

    output_group.add_argument(
        "-eo","--errors-only",
        action="store_const",
        dest="output_level",
        const="errors-only",
        help="Show only error messages"
    )

    output_group.add_argument(
        "--llm-mode",
        action="store_const",
        dest="output_level",
        const="llm-friendly",
        help="Output format optimized for LLM processing"
    )

    parser.set_defaults(output_level="warnings-up")  # Changed default to warnings-up

    args = parser.parse_args()

    return args


def main():
    """Main entry point"""
    try:
        args = parse_args()
        runner = XcodeBuildRunner()

        if args.scheme == "list":
            runner.list_available_schemes()
            return 0

        return runner.run(args)

    except KeyboardInterrupt:
        print(f"\n{Colors.YELLOW}Build interrupted by user.{Colors.NC}")
        return 130
    except Exception as e:
        print(f"{Colors.RED}Error: {e}{Colors.NC}")
        return 1


if __name__ == "__main__":
    sys.exit(main())