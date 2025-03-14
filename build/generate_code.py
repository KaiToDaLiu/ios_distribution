import qrcode
import sys
data = sys.argv[1]
path = sys.argv[2]
img = qrcode.make(data)
img.save(path)