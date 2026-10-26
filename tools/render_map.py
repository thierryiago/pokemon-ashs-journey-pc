# Desenha um mapa a partir do JSON de map_to_json.rb, com os tilesets e autotiles do jogo.
# Uso: python3 tools/render_map.py /tmp/map033.json /tmp/map033.png [--full]   (--full = escala 1:1)
import json,sys
from PIL import Image
import os
G=os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "Graphics") + "/"
m=json.load(open(sys.argv[1])); W,H,Z,D=m['w'],m['h'],m['z'],m['d']
T=Image.open(G+"Tilesets/"+m['ts']+".png").convert("RGBA")
AT=[]
for n in m['at']:
    try: AT.append(Image.open(G+"Autotiles/"+n+".png").convert("RGBA") if n else None)
    except Exception: AT.append(None)
P=[[27,28,33,34],[5,28,33,34],[27,6,33,34],[5,6,33,34],[27,28,33,12],[5,28,33,12],[27,6,33,12],[5,6,33,12],[27,28,11,34],[5,28,11,34],[27,6,11,34],[5,6,11,34],[27,28,11,12],[5,28,11,12],[27,6,11,12],[5,6,11,12],[25,26,31,32],[25,6,31,32],[25,26,31,12],[25,6,31,12],[15,16,21,22],[15,16,21,12],[15,16,11,22],[15,16,11,12],[29,30,35,36],[29,30,11,36],[5,30,35,36],[5,30,11,36],[39,40,45,46],[5,40,45,46],[39,6,45,46],[5,6,45,46],[25,30,31,36],[15,16,45,46],[13,14,19,20],[13,14,19,12],[17,18,23,24],[17,18,11,24],[41,42,47,48],[5,42,47,48],[37,38,43,44],[37,6,43,44],[13,18,19,24],[13,14,43,44],[37,42,43,48],[17,18,47,48],[13,18,43,48],[1,2,7,8]]
out=Image.new("RGBA",(W*32,H*32),(0,0,0,255))
cache={}
def tile(i):
    if i in cache: return cache[i]
    t=None
    if i>=384:
        n=i-384; t=T.crop(((n%8)*32,(n//8)*32,(n%8)*32+32,(n//8)*32+32))
    elif i>=48:
        a=AT[i//48-1] if i//48-1<len(AT) else None
        if a is not None:
            t=Image.new("RGBA",(32,32))
            if a.height==32:  # single-tile autotile
                t=a.crop((0,0,32,32))
            else:
                for q,idx in enumerate(P[i%48]):
                    idx-=1; sx=(idx%6)*16; sy=(idx//6)*16
                    t.paste(a.crop((sx,sy,sx+16,sy+16)),((q%2)*16,(q//2)*16))
    cache[i]=t; return t
for z in range(Z):
  for y in range(H):
    for x in range(W):
      i=D[x+W*(y+H*z)]
      if i: 
        t=tile(i)
        if t: out.alpha_composite(t,(x*32,y*32))
full = len(sys.argv) > 3 and sys.argv[3] == "--full"
img = out.convert("RGB")
(img if full else img.resize((W*16,H*16))).save(sys.argv[2])
