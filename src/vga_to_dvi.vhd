library ieee ;
  use ieee.std_logic_1164.all ;
  use ieee.std_logic_unsigned.all;
  use ieee.numeric_std.all;

entity vga_to_dvi is
  port (
    I_RESET         : in  std_logic;
    I_CLK           : in  std_logic;
    I_VGA_R         : in  std_logic_vector(3 downto 0);
    I_VGA_G         : in  std_logic_vector(3 downto 0);
    I_VGA_B         : in  std_logic_vector(3 downto 0);
    I_HSYNC         : in  std_logic;
    I_VSYNC         : in  std_logic;
    I_BLANK         : in  std_logic;
    o_tmds_clk_n    :out  std_logic;
    o_tmds_clk_p    :out  std_logic;
    o_tmds_d_n      :out  std_logic_vector(2 downto 0);
    o_tmds_d_p      :out  std_logic_vector(2 downto 0)
    );
end entity;

architecture rtl of vga_to_dvi is
  signal active_q     : std_logic;
  signal vsync        : std_logic;
  signal hsync        : std_logic;
  signal VGA_HSYNC    : std_logic;
  signal VGA_VSYNC    : std_logic;
  signal de           : std_logic;
  signal clk_pixel    : std_logic;
  signal clk_5x_pixel : std_logic;
  signal pll_lock     : std_logic;
  signal tmds         : std_logic_vector(2 downto 0); 

component Gowin_rPLL_hdmi is
    port (
        clkout: out std_logic;
        lock: out std_logic;
        reset: in std_logic;
        clkin: in std_logic
    );
end component;

component CLKDIV
    generic (
        DIV_MODE : STRING := "2";
        GSREN: in string := "false"
    );
    port (
        CLKOUT: out std_logic;
        HCLKIN: in std_logic;
        RESETN: in std_logic;
        CALIB: in std_logic
    );
end component;

component DVI_TX_Top
port (
  I_rst_n: in std_logic;
  I_serial_clk: in std_logic;
  I_rgb_clk: in std_logic;
  I_rgb_vs: in std_logic;
  I_rgb_hs: in std_logic;
  I_rgb_de: in std_logic;
  I_rgb_r: in std_logic_vector(7 downto 0);
  I_rgb_g: in std_logic_vector(7 downto 0);
  I_rgb_b: in std_logic_vector(7 downto 0);
  O_tmds_clk_p: out std_logic;
  O_tmds_clk_n: out std_logic;
  O_tmds_data_p: out std_logic_vector(2 downto 0);
  O_tmds_data_n: out std_logic_vector(2 downto 0)
);
end component;

begin

clock_generator2: Gowin_rPLL_hdmi
port map (
      clkin  => I_CLK,
      clkout => clk_5x_pixel,
      reset  => not I_RESET,
      lock   => pll_lock
    );

clock_divider2: CLKDIV
generic map (
    DIV_MODE => "5",
    GSREN  => "false"
)
port map (
    CALIB  => '0',
    clkout => clk_pixel,
    hclkin => clk_5x_pixel,
    resetn => pll_lock
    );

  process
  begin
    wait until rising_edge(clk_pixel);
    hsync     <= I_HSYNC;
    vsync     <= I_VSYNC;
    active_q  <= I_BLANK;
    VGA_HSYNC <= hsync;
    VGA_VSYNC <= vsync;
    de        <= active_q;
  end process;

dvi: DVI_TX_Top
    port map (
      I_rst_n => pll_lock,
      I_serial_clk => clk_5x_pixel,
      I_rgb_clk => clk_pixel,
      I_rgb_vs => VGA_VSYNC,
      I_rgb_hs => VGA_HSYNC,
      I_rgb_de => not de,
      I_rgb_r => I_VGA_R & "0000",
      I_rgb_g => I_VGA_G & "0000",
      I_rgb_b => I_VGA_B & "0000",
      O_tmds_clk_p => O_tmds_clk_p,
      O_tmds_clk_n => O_tmds_clk_n,
      O_tmds_data_p => o_tmds_d_p,
      O_tmds_data_n => o_tmds_d_n
    );

end;
