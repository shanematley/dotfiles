#/usr/bin/env python3

import sys

def stream_to_marked(data):
    from AppKit import NSPasteboard
    pb = NSPasteboard.pasteboardWithName_("mkStreamingPreview")
    pb.clearContents()
    pb.setString_forType_(data, 'public.utf8-plain-text')

d = []

for line in sys.stdin:
    d.append(line)
stream_to_marked("\n".join(d))

