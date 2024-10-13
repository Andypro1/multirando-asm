@echo off
del build\main_m1.sfc
resources\asar.exe -DSTANDALONE=1 --symbols=wla --symbols-path=build\main_m1.sym src\m1\standalone.asm build\main_m1.sfc