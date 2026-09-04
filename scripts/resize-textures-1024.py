import sys, glob, os
from PIL import Image
d = sys.argv[1]
for p in glob.glob(os.path.join(d, '*.png')):
    if not p.endswith(('_diffuse.png','_normal.png','_roughness.png','_metallic.png')): continue
    im = Image.open(p)
    if im.size != (1024, 1024):
        im.resize((1024, 1024), Image.LANCZOS).save(p, optimize=True)
    print(os.path.basename(p), Image.open(p).size)
