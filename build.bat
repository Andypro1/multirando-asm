@echo off
del build\main.sfc
cd resources
asar.exe -wno1030 --symbols=wla --symbols-path=../build/main.sym ../src/main.asm ../build/main.sfc
cd ..