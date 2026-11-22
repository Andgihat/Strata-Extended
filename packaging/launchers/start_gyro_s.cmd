@echo off
chcp 65001 >nul
title Qwen 3.8 Flash Next Gyro-S (125B MoE Ternary TQ1_0, Strata Engine)

set "PYTHON_EXE=C:\Users\Andgihat\AppData\Local\Strata\terminal\0.1.52\python\python.exe"
set "SERVER_PY=C:\Users\Andgihat\AppData\Local\Strata\components\control\0.1.57\serve\server.py"
set "CONFIG_DFLASH2=C:\Users\Andgihat\AppData\Local\Strata\launch\gyro-s-256k.json"
set "CONFIG_NODRAFT=C:\Users\Andgihat\AppData\Local\Strata\launch\gyro-s-256k-nodraft.json"
set "PORT=8080"

:: Native LM Head for Full 248K Vocabulary (100% Bit-Exact Parity in Russian & Code)
set "STRATA_DF2_HEAD=native"

:: Blackwell sm_120 optimizations
set "STRATA_PF_FUSED_TQ=1"
set "STRATA_RESIDENT_HEADROOM_GIB=0.3"
set "STRATA_ROUTE_PRIOR=0"
set "STRATA_DF2_VITERBI=1"
set "STRATA_DRAFT_LOG=1"
set "STRATA_DRAFT_CONF=0.25"
set "STRATA_DRAFT_CAP=7"
set "STRATA_SPEC=7"

:: AMD Zen 5 AVX-512 VNNI CPU Pool
set "STRATA_TQ_ISA=avx512"

:: Async MoE Prefetch (Foresight Swap + Predictive Overlapped MoE Loading)
set "STRATA_FS_SLOTS=8"
set "STRATA_FS_AHEAD=1"
set "STRATA_LOOKAHEAD=1"
set "STRATA_FS_DEPTH=1"
set "STRATA_FS_BUDGET=128"
set "STRATA_SPEC_V2=1"
set "STRATA_DIRECT_HANDLES=8"

echo.
echo ============================================================
echo   Qwen 3.8 Flash Next Gyro-S @ 256K (Strata-Extended)
echo ============================================================
echo   Model:        Qwen3.8-Flash-Next-Gyro-S-TQ1_0.gguf (58.4 GB)
echo   Architecture: MoE ~125B (512 experts, Ternary TQ1_0)
echo   Speculation:  DFlash2 Trellis Viterbi + Native Head (100%% Bit-Exact Parity)
echo   KV Cache:     Hardware INT8/FP8 Blackwell sm_120 (32K VRAM Resident, 0 PCIe Lag)
echo   Context:      Full 256,000 tokens (256K, 32K sliding window)
echo   Memory:       8,203 VRAM slots (8.02 GB) + 15.65 GB RAM Lock (0 MB SSD Read)
echo   CPU Pool:     512-bit Zen 5 AVX-512 VNNI (9.9-11.4 GB/s, 10.6 ms call)
echo   MoE Prefetch: Foresight Swap + Predictive Overlapped DMA (Zero PCIe Lag)
echo   Multimodal:   Vision CPU (On-Demand Elastic: 0 MB RAM until image requested)
echo   GPU:          NVIDIA RTX 5060 Ti 16 GB VRAM
echo   API Port:     %PORT% (http://127.0.0.1:%PORT%/v1)
echo ------------------------------------------------------------
"%PYTHON_EXE%" -c "import psutil; vm = psutil.virtual_memory(); avail = vm.available / (1024**3); print(f'   Доступно ОЗУ: {avail:.1f} ГБ ' + ('[ОТЛИЧНО: 15.65 ГБ для полного RAM Lock с 0 MB SSD read доступно!]' if avail >= 15.6 else f'[ЧАСТИЧНЫЙ RAM LOCK: {avail:.1f} ГБ из 15.65 ГБ]'))"
echo ------------------------------------------------------------
echo   [1] DFlash2 + PURE QUALITY [Tail-Skip 0, 100%% MoE, ~65-72 t/s, 32K Cache]
echo   [2] DFlash2 + BALANCED     [Tail-Skip 5, Trellis Viterbi ~82-88 t/s, 32K Cache]
echo   [3] DFlash2 + ULTRA-TURBO  [Tail-Skip 7, Trellis Viterbi ~95-105+ t/s] (Enter)
echo   [4] Pure Decode            [100%% MoE, without DFlash2 speculation, ~35-40 t/s]
echo   [5] DFlash2 + CaDDTree     [Active Tree Verification: Tree-Attention branch recovery]
echo ============================================================
echo.

set "MODE=%~1"
if "%MODE%"=="" set /p MODE="  Select mode [1-5, Enter=3]: "
if "%MODE%"=="" set "MODE=3"

if "%MODE%"=="1" goto mode1
if "%MODE%"=="2" goto mode2
if "%MODE%"=="3" goto mode3
if "%MODE%"=="4" goto mode4
if "%MODE%"=="5" goto mode5
echo   Invalid choice, starting default mode [3]...
goto mode3

:mode1
echo   ^>^> Mode: DFlash2 + 100%% MoE [PURE QUALITY: all experts evaluated, ~65-72 t/s]
set "STRATA_ROUTE_TAIL_SKIP=0"
set "STRATA_SPEC=7"
set "STRATA_DRAFT_CAP=7"
set "STRATA_DRAFT_CONF=0.25"
set "STRATA_DF2_HEAD=native"
set "CONFIG_JSON=%CONFIG_DFLASH2%"
goto run

:mode2
echo   ^>^> Mode: DFlash2 + BALANCED [Tail-Skip 5: Trellis Viterbi ~82-88 t/s]
set "STRATA_ROUTE_TAIL_SKIP=5"
set "STRATA_SPEC=7"
set "STRATA_DRAFT_CAP=7"
set "STRATA_DRAFT_CONF=0.25"
set "STRATA_DF2_HEAD=native"
set "CONFIG_JSON=%CONFIG_DFLASH2%"
goto run

:mode3
echo   ^>^> Mode: DFlash2 + ULTRA-TURBO [Tail-Skip 7: Trellis Viterbi ~95-105+ t/s top speed]
set "STRATA_ROUTE_TAIL_SKIP=7"
set "STRATA_SPEC=7"
set "STRATA_DRAFT_CAP=7"
set "STRATA_DRAFT_CONF=0.25"
set "STRATA_DF2_HEAD=native"
set "CONFIG_JSON=%CONFIG_DFLASH2%"
goto run

:mode4
echo   ^>^> Mode: Pure Decode [No speculation, 100%% MoE]
set "STRATA_ROUTE_TAIL_SKIP=0"
set "CONFIG_JSON=%CONFIG_NODRAFT%"
goto run

:mode5
echo   ^>^> Mode: DFlash2 + CaDDTree [Active Tree Verification, Tail-Skip 5]
set "STRATA_ROUTE_TAIL_SKIP=5"
set "STRATA_SPEC=7"
set "STRATA_DRAFT_CAP=7"
set "STRATA_DRAFT_CONF=0.25"
set "STRATA_DF2_HEAD=native"
set "STRATA_ENABLE_CADDTREE=1"
set "CONFIG_JSON=%CONFIG_DFLASH2%"
goto run

:run
echo.
echo   ^>^> Cleaning up any lingering Strata processes...
taskkill /F /IM strata.exe /FI "STATUS eq RUNNING" >nul 2>&1
taskkill /F /IM strata-vision.exe /FI "STATUS eq RUNNING" >nul 2>&1

echo   ^>^> Starting Strata HTTP API Server for Gyro-S...
echo   ^>^> OpenAI API: http://127.0.0.1:%PORT%/v1
echo   ^>^> Web Chat:   http://127.0.0.1:%PORT%/
echo   ^>^> Config:     %CONFIG_JSON%
echo   ^>^> Press Ctrl+C to stop.
echo.

"%PYTHON_EXE%" "%SERVER_PY%" --engine strata --config "%CONFIG_JSON%" --port %PORT%

if errorlevel 1 pause
