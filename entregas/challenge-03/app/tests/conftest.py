import sys
from pathlib import Path

# Ensure app module is importable when running pytest from project root
sys.path.append(str(Path(__file__).resolve().parents[1]))
