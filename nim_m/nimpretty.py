# nimpretty のキーバインドが効かないので
import os
import glob
import subprocess

# 最新更新のファイルを nimpretty
file_list = sorted(
    glob.glob('*.nim'), key=lambda f: os.stat(f).st_mtime, reverse=True
)
subprocess.run(f"nimpretty {file_list[0]}", shell=True)

# exe だけを削除
file_list = glob.glob('*.exe')
for v in file_list:
    os.remove(v)
