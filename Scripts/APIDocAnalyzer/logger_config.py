import logging
import sys
from typing import Optional

def setup_logger(name: str = 'APIDocAnalyzer', level: str = 'INFO', log_file: Optional[str] = None) -> logging.Logger:
    """
    Configure and return a logger with consistent formatting.

    Args:
        name: Logger name
        level: Logging level ('DEBUG', 'INFO', 'WARNING', 'ERROR')
        log_file: Optional file path to write logs to
    """
    # Create logger
    logger = logging.getLogger(name)
    logger.setLevel(getattr(logging, level.upper()))

    # Clear any existing handlers
    logger.handlers = []

    # Create formatters
    console_formatter = logging.Formatter('%(levelname)-8s %(message)s')
    file_formatter = logging.Formatter('%(asctime)s - %(levelname)-8s - %(message)s')

    # Console handler
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setFormatter(console_formatter)
    logger.addHandler(console_handler)

    # File handler if specified
    if log_file:
        file_handler = logging.FileHandler(log_file)
        file_handler.setFormatter(file_formatter)
        logger.addHandler(file_handler)

    return logger

# Log level mapping for verbose flag
def get_log_level(verbose: bool) -> str:
    """Return appropriate log level based on verbose flag."""
    return 'DEBUG' if verbose else 'INFO'