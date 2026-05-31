# SGLA Synthesis + Innovus Flow

此版本入口為 `top_sgla_innovus`，特色：

- 純可合成 RTL（不含 `real`、`$exp/$sqrt`、`initial` 計算流程）
- memory 先用 `sgla_map_bank`（reg-array）替代，後續可換 SRAM macro
- bbox 解碼走定點路徑（argmax + size/offset + map_box_back）

## 1) 先準備 map 資料（可由 Python 匯出）

依序將以下 map 寫入：

- `map_sel=0`: score
- `map_sel=1`: size_w
- `map_sel=2`: size_h
- `map_sel=3`: off_x
- `map_sel=4`: off_y

`map_waddr` 範圍：`0 .. (FEAT_SZ*FEAT_SZ-1)`。

## 2) 跑綜合（Genus）

在此目錄填好 `run_genus.tcl` 內的 `LIB_SETUP`（或直接 source 你的 library 設定）。

```tcl
genus -f run_genus.tcl
```

輸出重點：

- `top_sgla_innovus_syn.v`
- `top_sgla_innovus_syn.sdc`
- `top_sgla_innovus_syn.dat`（write_design -innovus）

## 3) 跑 Innovus

在 `run_innovus.tcl` 填好：

- `init_lef_file`
- `init_mmmc_file`
- `streamOut` map/merge 路徑

```tcl
innovus -init run_innovus.tcl
```

## 注意

- `bbox_decode` 內 `search_size_q` 目前定義為 **預先算好的 `search_size/resize_factor`（Q format）**。
- 若要替換成真正 SRAM macro，建議先保留現有 module I/O，再把 `sgla_map_bank` 替換為 macro wrapper。

