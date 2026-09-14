import sys
from pathlib import Path


args = list(sys.argv)
args.pop(0) # Lose the name

d = {}
while 0 < len(args):
    l = args.pop(0)
    p = Path(args.pop(0))
    names = p.read_text().splitlines()
    if l in d: raise RuntimeError(f"duplicate file '{l}'")
    d[l] = names

print(f"""
module Names exposing ( {', '.join(d.keys())} )

import Array exposing (Array)


{'\n\n\n'.join(
      ""
      + f"{lang} : Array String\n"
      + f"{lang} =\n"
      + f"  Array.fromList\n"
      + f"    [ {'\n    , '.join(f'"{n}"' for n in names)}\n"
      + f"    ]"
      for lang, names in d.items()
)}
""".strip())
