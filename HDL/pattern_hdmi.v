
/*
 * HDMI出力用のパターン生成モジュール
 *
 * 役割は大きく2つ。
 *
 *   ① patternモジュールで映像信号を作る
 *
 *   ② rgb2dvi_0 IPでRGB映像信号をHDMI信号に変換する
 *
 *
 * 全体の流れ
 *
 *        CLK
 *         |
 *         v
 *   +-------------+
 *   |   pattern   |
 *   | 画面パターン |
 *   +------+------+
 *          |
 *          | RGB / HS / VS / DE / PCK
 *          v
 *   +-------------+
 *   |  rgb2dvi_0  |
 *   | RGB -> HDMI |
 *   +------+------+
 *          |
 *          v
 *       HDMI端子
 *
 */

module pattern_hdmi(
    input           CLK,       // FPGAの基本クロック
    input           RST,       // リセット信号

    // HDMIクロックの差動出力
    output          HDMI_CLK_N,
    output          HDMI_CLK_P,

    // HDMI映像データの差動出力（3レーン）
    output  [2:0]   HDMI_N,
    output  [2:0]   HDMI_P
);


/*------------------------------------------------------------
 * patternとrgb2dvi_0の間で使用する信号
 *------------------------------------------------------------*/

// RGB各8bit、合計24bit
wire [7:0] VGA_R, VGA_G, VGA_B;

// 水平同期・垂直同期
wire VGA_HS, VGA_VS;

// 表示有効信号
wire VGA_DE;

// ピクセルクロック
wire PCK;


/*------------------------------------------------------------
 * ① 画面パターンを生成する
 *------------------------------------------------------------*/

pattern pattern(
    .CLK    (CLK),
    .RST    (RST),

    .VGA_R  (VGA_R),
    .VGA_G  (VGA_G),
    .VGA_B  (VGA_B),

    .VGA_HS (VGA_HS),
    .VGA_VS (VGA_VS),
    .VGA_DE (VGA_DE),

    .PCK    (PCK)
);


/*------------------------------------------------------------
 * ② RGB映像信号をHDMI信号へ変換する
 *
 * rgb2dvi_0はVivadoで生成したIPのモジュール名。
 *
 * rgb2dvi_0 : IPのモジュール名
 * rgb2dvi_inst : この回路内でのインスタンス名
 *
 * インスタンス名は自分で決められる。
 * IPのモジュール名は生成されたテンプレートに合わせる。
 *------------------------------------------------------------*/

rgb2dvi_0 rgb2dvi_inst (

    // HDMIクロック出力
    .TMDS_Clk_p  (HDMI_CLK_P),
    .TMDS_Clk_n  (HDMI_CLK_N),

    // HDMIデータ出力
    .TMDS_Data_p (HDMI_P),
    .TMDS_Data_n (HDMI_N),

    // リセット
    .aRst        (RST),

    // RGB映像データ（R、G、Bの順に連結）
    .vid_pData   ({VGA_R, VGA_G, VGA_B}),

    // 表示有効信号
    .vid_pVDE    (VGA_DE),

    // 水平同期信号
    .vid_pHSync  (VGA_HS),

    // 垂直同期信号
    .vid_pVSync  (VGA_VS),

    // ピクセルクロック
    .PixelClk    (PCK)

);

endmodule