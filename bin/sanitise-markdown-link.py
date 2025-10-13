#!/usr/bin/env python3
import sys

def sanitize_markdown_links(text):
    result = []
    i = 0
    L = len(text)
    while i < L:
        # look for start of a link
        if text[i] == '[':
            end_text = text.find('](', i)
            if end_text != -1:
                link_text = text[i+1:end_text]
                # now parse the URL with balanced-parens
                j = end_text + 2
                depth = 1
                while j < L and depth:
                    if text[j] == '(':
                        depth += 1
                    elif text[j] == ')':
                        depth -= 1
                    j += 1
                # if we found a matching ')'
                if depth == 0:
                    url = text[end_text+2 : j-1]
                    # percent-encode any literal parens in the URL
                    url_enc = url.replace('(', '%28').replace(')', '%29')
                    result.append(f"[{link_text}]({url_enc})")
                    i = j
                    continue
        # otherwise, just copy the character
        result.append(text[i])
        i += 1
    return ''.join(result)

if __name__ == '__main__':
    original = sys.stdin.read()
    sys.stdout.write(sanitize_markdown_links(original))
