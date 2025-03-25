import sys
from datetime import datetime

# /opt/homebrew/bin/python3 text_writer.py ${IP_ADDRESS} ${CURRENT_TIME} /Users/daliu_kt/Desktop/job/GitHub/ios_distribution/index.html
# python3 text_writer.py 10.18.26.77 2025_03_25_16_07_07 /Users/daliu_kt/Desktop/job/GitHub/ios_distribution/index2.html
if len(sys.argv) < 1:
    print("未传递参数")
    exit(0)
local_ip = sys.argv[1] # 10.18.26.77
date_name = sys.argv[2] # 2025_03_25_16_07_07
file_name = sys.argv[3] # /Users/daliu_kt/Desktop/job/GitHub/ios_distribution/index.html
print("第一个参数:", sys.argv[1])  # 获取第一个参数
print("第二个参数:", sys.argv[2])  # 获取第一个参数
print("第二个参数:", sys.argv[3])  # 获取第一个参数

# 2025_03_25_16_07_07 ->
dt = datetime.strptime(date_name, "%Y_%m_%d_%H_%M_%S")
format_date_name = dt.strftime("%Y-%m-%d %H:%M:%S")

str = f"""
    <DOCTYPE html>
        <html lang="utf-8">
        <head>
            <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
            <meta http-equiv="Pragma" content="no-cache">
            <meta http-equiv="Expires" content="0">
            <meta charset="utf-8">
            <title>Kaito</title>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0" />

            <style type="text/css">
                .center {{
                    text-align: center;
                }}
                img {{
                    width: 120px;
                    height: 120px;
                }}
                .vertical {{
                    display: grid;
                    place-items: center;
                    margin-left: 35px;
                    margin-top: 15px;
                }}
            </style>
        </head>

        <body>
            <h1 class="center">Install kaito app on your iPhone</h1>
            <div style="display: flex; justify-content: center;">
                <div class="vertical">
                    <img src="build/{date_name}/qrcode.jpg" alt="scan it with iphone camera">
                    {format_date_name}
                </div>
            </div>
            <hr />
            For ShangHai team, visit <a href="http://{local_ip}:8080/" />{local_ip}</a>
        </body>
    </html>
    """

with open(file_name, "w", encoding="utf-8") as f:
    f.write(str)