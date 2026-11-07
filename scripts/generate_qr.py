import qrcode
import os

url = "https://moulendrabalaji.github.io/reelhouse-movie-explorer/"
output_path = os.path.join("docs", "screenshots", "live_app_qr.png")

qr = qrcode.QRCode(
    version=1,
    error_correction=qrcode.constants.ERROR_CORRECT_H,
    box_size=10,
    border=4,
)
qr.add_data(url)
qr.make(fit=True)

img = qr.make_image(fill_color="#FFB020", back_color="#0E0C0A")
img.save(output_path)
print(f"QR Code successfully generated at {output_path}")
