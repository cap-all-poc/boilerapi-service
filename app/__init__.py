from importlib import metadata

try:
    # The distribution name is the same as specified in pyproject.toml
    __version__: str = metadata.version("boilerapi-app")
except metadata.PackageNotFoundError:
    # When running from source without installation, provide a fallback
    __version__ = "0.0.0"

__all__ = ["__version__"]