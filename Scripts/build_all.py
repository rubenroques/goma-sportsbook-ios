#!/usr/bin/env python3
"""
Script to build all schemes in the correct order for the Sportsbook iOS project.
This script reuses the XcodeBuildRunner from build.py to avoid code duplication.
"""

import sys
import argparse
from build import XcodeBuildRunner, OutputLevel, Colors

class BuildAllRunner:
    def __init__(self):
        self.builder = XcodeBuildRunner()
        # Define build order by categories
        self.build_order = {
            "Core frameworks": [
                "ServicesProvider",
                "SharedModels",
                "DictionaryCoding",
                "Extensions",
                "GomaAssets",
                "Theming"
            ],
            "Features": [
                "HeaderTextField",
                "CountrySelectionFeature",
                "RegisterFlow",
                "AdresseFrancaise",
                "NotificationsService"
            ],
            "Sports data": [
                "SportRadar PROD",
                "SportRadar UAT",
                "GomaSportRadar"
            ],
            "Client apps": [
                "ATP",
                "Betsson PROD",
                "Betsson UAT",
                "Crocobet",
                "DAZN",
                "EveryMatrix",
                "GOMASports"
            ],
            "Tests": [
                "SportsbookTests"
            ]
        }

    def build_all(self, args):
        """Build all schemes in the correct order"""
        total_schemes = sum(len(schemes) for schemes in self.build_order.values())
        current_scheme = 0
        failed_schemes = []

        for category, schemes in self.build_order.items():
            if args.output_level != OutputLevel.LLM_FRIENDLY:
                print(f"\n{Colors.BLUE}Building {category}...{Colors.NC}")

            for scheme in schemes:
                current_scheme += 1
                if args.output_level != OutputLevel.LLM_FRIENDLY:
                    print(f"\n{Colors.YELLOW}[{current_scheme}/{total_schemes}] Building {scheme}...{Colors.NC}")
                else:
                    print(f"BUILD_STATUS: BUILDING {scheme} ({current_scheme}/{total_schemes})")

                # Update args with current scheme
                args.scheme = scheme

                # Run the build
                return_code, output, errors = self.builder.run_build(args)

                # Process the output
                if return_code != 0:
                    failed_schemes.append(scheme)
                    if args.output_level == OutputLevel.LLM_FRIENDLY:
                        print(f"BUILD_STATUS: FAILED {scheme}")
                    else:
                        print(f"{Colors.RED}Failed to build {scheme}{Colors.NC}")

                    if not args.continue_on_error:
                        print(f"{Colors.RED}Build process stopped due to error. Use --continue-on-error to build all schemes regardless of failures.{Colors.NC}")
                        return 1
                elif args.output_level == OutputLevel.LLM_FRIENDLY:
                    print(f"BUILD_STATUS: SUCCESS {scheme}")

        # Final status report
        if args.output_level == OutputLevel.LLM_FRIENDLY:
            print("\nBUILD_ALL_STATUS:", "FAILED" if failed_schemes else "SUCCESS")
            if failed_schemes:
                print("FAILED_SCHEMES:", ", ".join(failed_schemes))
        else:
            if failed_schemes:
                print(f"\n{Colors.RED}Build completed with failures in the following schemes:{Colors.NC}")
                for scheme in failed_schemes:
                    print(f"{Colors.RED}- {scheme}{Colors.NC}")
            else:
                print(f"\n{Colors.GREEN}All schemes built successfully!{Colors.NC}")

        return 1 if failed_schemes else 0

def parse_args():
    """Parse command-line arguments"""
    parser = argparse.ArgumentParser(
        description="Build all schemes for the Sportsbook iOS project"
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
        "--clean",
        action="store_true",
        help="Clean DerivedData before building"
    )

    parser.add_argument(
        "--continue-on-error",
        action="store_true",
        help="Continue building remaining schemes even if some fail"
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
        "--errors-only",
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

    parser.set_defaults(output_level="warnings-up")

    args = parser.parse_args()
    args.output_level = OutputLevel(args.output_level)
    args.action = "build"  # Always build for build_all

    return args

def main():
    """Main entry point"""
    try:
        args = parse_args()
        runner = BuildAllRunner()

        if args.clean:
            runner.builder.clean_derived_data(args.output_level)

        return runner.build_all(args)

    except KeyboardInterrupt:
        print(f"\n{Colors.YELLOW}Build interrupted by user.{Colors.NC}")
        return 130
    except Exception as e:
        print(f"{Colors.RED}Error: {e}{Colors.NC}")
        return 1

if __name__ == "__main__":
    sys.exit(main())