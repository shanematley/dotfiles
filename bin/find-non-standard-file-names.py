#!/usr/bin/env python
"""
Finds files in this directory that have characters that may not be accepted in
all OSs, e.g.:

- Non-ASCII
- Forbidden characters
- Trailing dot or space
"""

import os
import re

for root, dirs, files in os.walk("."):
    for fname in files:
        path = os.path.join(root, fname)

        # Non-ASCII check
        if not all(ord(c) < 128 for c in fname):
            print(f"Non-ASCII:            {path}")
            continue

        # Forbidden characters
        if re.search(r'[:/\\|?*]', fname):
            print(f"Forbidden characters: {path}")
            continue

        # Trailing dot or space
        if fname.endswith('.') or fname.endswith(' '):
            print(f"Trailing dot/space:   {path}")
            continue
