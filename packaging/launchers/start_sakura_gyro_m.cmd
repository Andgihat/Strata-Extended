@echo off
chcp 65001 >nul
title Sakura Qwen 3.8 Flash Next Gyro-M (CP2 PLE, Strata-Extended Engine)

set "PYTHON_EXE=C:\Users\Andgihat\AppData\Local\Strata\terminal\0.1.52\python\python.exe"
set "SERVER_PY=C:\Users\Andgihat\AppData\Local\Strata\components\control\0.1.57\serve\server.py"
set "CONFIG_DFLASH2=C:\Users\Andgihat\AppData\Local\Strata\launch\sakura-gyro-m-256k.json"
set "CONFIG_DFLASH2_131K=C:\Users\Andgihat\AppData\Local\Strata\launch\sakura-gyro-m-256k-131k.json"
set "CONFIG_NODRAFT=C:\Users\Andgihat\AppData\Local\Strata\launch\sakura-gyro-m-256k-nodraft.json"
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
echo   Sakura Qwen 3.8 Flash Next Gyro-M @ 256K (Strata-Extended)
echo ============================================================
echo   Model:        Sakura-Qwen3.8-Flash-Next-Gyro-M-K512-TQ2_0-CP2-v1.gguf (51.0 GB)
echo   Architecture: MoE ~125B (512 experts, CP2 PLE N-Gram)
echo   Speculation:  DFlash2 Trellis Viterbi + Native Head (100%% Bit-Exact Parity)
echo   KV Cache:     Hardware FP8 E4M3 Blackwell sm_120 (32K / 131K VRAM Resident, 0 PCIe Lag)
echo   Context:      Full 256,000 tokens (256K, 32K sliding window)
echo   Memory:       6,636 VRAM slots (8.07 GB) + 18.9 GB RAM Lock + SSD Profile
echo   CPU Pool:     512-bit Zen 5 AVX-512 VNNI (11.7 GB/s, 1.49x FFN Speedup)
echo   MoE Prefetch: Foresight Swap + Predictive Overlapped DMA (Zero PCIe Lag)
echo   Profile:      Optimized sakura_expert_profile.bin (19k pairs)
echo   Multimodal:   Vision CPU (On-Demand Elastic: 0 MB RAM until image requested)
echo   GPU:          NVIDIA RTX 5060 Ti 16 GB VRAM
echo   API Port:     %PORT% (http://127.0.0.1:%PORT%/v1)
echo ------------------------------------------------------------
"%PYTHON_EXE%" -c "import psutil; vm = psutil.virtual_memory(); avail = vm.available / (1024**3); print(f'   Доступно ОЗУ: {avail:.1f} ГБ ' + ('[ОТЛИЧНО: Полный RAM Lock активен!]' if avail >= 15.6 else f'[ЧАСТИЧНЫЙ RAM LOCK: {avail:.1f} ГБ]'))"
echo ------------------------------------------------------------
echo   [1] DFlash2 + PURE QUALITY [Tail-Skip 0, 100%% MoE, ~48-52 t/s, 32K FP8]
echo   [2] DFlash2 + BALANCED     [Tail-Skip 5, Trellis Viterbi ~62-70 t/s, 32K FP8]
echo   [3] DFlash2 + ULTRA-TURBO  [Tail-Skip 7, Trellis Viterbi ~75-85+ t/s, 32K FP8] (Enter)
echo   [4] DFlash2 + DEEP CONTEXT [Tail-Skip 7, 131,072 Resident FP8, Zero PCIe lag at 100k+]
echo   [5] Pure Decode            [100%% MoE, without DFlash2 speculation, ~23.5 t/s, 32K FP8]
echo   [6] DFlash2 + CaDDTree     [Active Tree Verification: Tree-Attention branch recovery, 32K FP8]
echo ============================================================
echo.

set "MODE=%~1"
if "%MODE%"=="" set /p MODE="  Select mode [1-6, Enter=3]: "
if "%MODE%"=="" set "MODE=3"

if "%MODE%"=="1" goto mode1
if "%MODE%"=="2" goto mode2
if "%MODE%"=="3" goto mode3
if "%MODE%"=="4" goto mode4
if "%MODE%"=="5" goto mode5
if "%MODE%"=="6" goto mode6
echo   Invalid choice, starting default mode [3]...
goto mode3

:mode1
echo   ^>^> Mode: DFlash2 + 100%% MoE [PURE QUALITY: all experts evaluated, ~48-52 t/s, 32K FP8]
set "STRATA_ROUTE_TAIL_SKIP=0"
set "STRATA_SPEC=7"
set "STRATA_DRAFT_CAP=7"
set "STRATA_DRAFT_CONF=0.25"
set "STRATA_DF2_HEAD=native"
set "CONFIG_JSON=%CONFIG_DFLASH2%"
goto run

:mode2
echo   ^>^> Mode: DFlash2 + BALANCED [Tail-Skip 5: Trellis Viterbi ~62-70 t/s, 32K FP8]
set "STRATA_ROUTE_TAIL_SKIP=5"
set "STRATA_SPEC=7"
set "STRATA_DRAFT_CAP=7"
set "STRATA_DRAFT_CONF=0.25"
set "STRATA_DF2_HEAD=native"
set "CONFIG_JSON=%CONFIG_DFLASH2%"
goto run

:mode3
echo   ^>^> Mode: DFlash2 + ULTRA-TURBO [Tail-Skip 7: Trellis Viterbi ~75-85+ t/s top speed, 32K FP8]
set "STRATA_ROUTE_TAIL_SKIP=7"
set "STRATA_SPEC=7"
set "STRATA_DRAFT_CAP=7"
set "STRATA_DRAFT_CONF=0.25"
set "STRATA_DF2_HEAD=native"
set "CONFIG_JSON=%CONFIG_DFLASH2%"
goto run

:mode4
echo   ^>^> Mode: DFlash2 + DEEP CONTEXT [Tail-Skip 7, 131,072 VRAM Resident FP8, Zero PCIe Stalls]
set "STRATA_ROUTE_TAIL_SKIP=7"
set "STRATA_SPEC=7"
set "STRATA_DRAFT_CAP=7"
set "STRATA_DRAFT_CONF=0.25"
set "STRATA_DF2_HEAD=native"
set "CONFIG_JSON=%CONFIG_DFLASH2_131K%"
goto run

:mode5
echo   ^>^> Mode: Pure Decode [No speculation, 100%% MoE, 32K FP8]
set "STRATA_ROUTE_TAIL_SKIP=0"
set "CONFIG_JSON=%CONFIG_NODRAFT%"
goto run

:mode6
echo   ^>^> Mode: DFlash2 + CaDDTree [Active Tree Verification, Tail-Skip 5, 32K FP8]
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

echo   ^>^> Starting Strata HTTP API Server...
echo   ^>^> OpenAI API: http://127.0.0.1:%PORT%/v1
echo   ^>^> Config:     %CONFIG_JSON%
echo   ^>^> Press Ctrl+C to stop.
echo.

"%PYTHON_EXE%" "%SERVER_PY%" --engine strata --config "%CONFIG_JSON%" --port %PORT%

if errorlevel 1 pause
