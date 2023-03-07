import sys
import json
from PIL import Image

if (len(sys.argv) < 5):
    print("usage: 2color.py imagefile binary-a binary-b nametable")
    sys.exit()

imagefile = sys.argv[1]
input_image = Image.open(imagefile).convert("RGB")

def _int_to_8bit(c):
    return bin(c)[2:].zfill(8)

def get_tile(image, x, y, tile_width=8, tile_height=16):
  tile = []
  for j in range(y*tile_height, (y*tile_height)+tile_height): 
    for i in range(x*tile_width, (x*tile_width)+tile_width):
      pixel = image.getpixel((i, j))
      tile.append(1 if pixel[0] else 0)
  return tuple(tile)

width = input_image.width // 8
height = input_image.height // 16

tiles = []
for j in range(0, height):
  for i in range(0, width):
    tiles.append(get_tile(input_image, i, j))

tileset = list(set(tiles))
tileA = b''
tileB = b''

def interlace(tile):
  setA = []
  setB = []

  for j in range(0, 16):
    row = []
    for i in range(0, 8):
      row.append(tile[i + j*8])
    if (j%2):
      setA.append(row)
    else:
      setB.append(row)
  return (setA, setB)

def tile_to_nes(tile):
  nes = bytearray()
  for row in tile:
    bits = 0
    for bit in row:
      bits = (bits << 1) + bit
    nes.append(bits)
  for _ in range(0, 8):
    nes.append(0)
  return nes

setA = b''
setB = b''

for tile in tileset:
  interlaced = interlace(tile)
  setA += tile_to_nes(interlaced[0])
  setB += tile_to_nes(interlaced[1])

def pad_to_8k(set):
  while (len(set) < 8192):
    set += b'\0'
  return set

setA = pad_to_8k(setA)
setB = pad_to_8k(setB)

outfile1 = sys.argv[2]
outfile2 = sys.argv[3]

with open(outfile1, "wb") as fileo:
  fileo.write(setA)
with open(outfile2, "wb") as fileo:
  fileo.write(setB)

empty_row = [0 for _ in range(0, 32)]
table = empty_row + [tileset.index(i) for i in tiles] + empty_row
attributes = [0 for _ in range(0, 64)]

nametable = table + attributes
outfile3 = sys.argv[4]
with open(outfile3, "wb") as fileo:
  fileo.write(bytes(nametable))
