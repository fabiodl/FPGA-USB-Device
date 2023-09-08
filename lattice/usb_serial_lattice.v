
//--------------------------------------------------------------------------------------------------------
// Module  : fpga_top_usb_serial
// Type    : synthesizable, fpga top
// Standard: Verilog 2001 (IEEE1364-2001)
// Function: example for usb_serial_top
//--------------------------------------------------------------------------------------------------------

module usb_serial_lattice (
                           // clock
                           input wire  clk12mhz,
                           // reset button
                           input wire  button, // connect to a reset button, 0=reset, 1=release. If you don't have a button, tie this signal to 1.
                           // LED
                           output wire led, // 1: USB connected , 0: USB disconnected
                           // USB signals
                           output wire usb_dp_pull, // connect to USB D+ by an 1.5k resistor
                           inout       usb_dp, // connect to USB D+
                           inout       usb_dn, // connect to USB D-
                           // debug output info, only for USB developers, can be ignored for normally use
                           output wire uart_tx       // If you want to see the debug info of USB device core, please connect this UART signal to host-PC (UART format: 115200,8,n,1), otherwise you can ignore this signal.

                           );


   wire                                clk_locked;
   wire                                clk60mhz;


   //-------------------------------------------------------------------------------------------------------------------------------------
   // The USB controller core needs a 60MHz clock, this PLL module is to convert clk12mhz to clk60mhz
   // This PLL module is only available on Lattice devices.
   // If you use other FPGA families, please use their compatible primitives or IP-cores to generate clk60mhz
   //-------------------------------------------------------------------------------------------------------------------------------------

   pllModule #(.DIVR(0),.DIVF(79),.DIVQ(4))  pllModule60 (.clkin(clk12mhz),.clkout(clk60mhz),.lock(clk_locked));




   //-------------------------------------------------------------------------------------------------------------------------------------
   // USB-CDC Serial port device
   //-------------------------------------------------------------------------------------------------------------------------------------

   // here we simply make a loopback connection for testing, but convert lowercase letters to uppercase.
   // When using minicom/hyperterminal/serial-assistant to send data from the host to the device, the send data will be returned.
   wire [ 7:0]                         recv_data;
   wire                                recv_valid;
   wire [ 7:0]                         send_data = (recv_data >= 8'h61 && recv_data <= 8'h7A) ? (recv_data - 8'h20) : recv_data;   // lowercase -> uppercase

   usb_serial_top #(
                    .DEBUG           ( "FALSE"             )    // If you want to see the debug info of USB device core, set this parameter to "TRUE"
                    ) u_usb_serial (
                                    .rstn            ( clk_locked & button ),
                                    .clk             ( clk60mhz            ),
                                    // USB signals
                                    .usb_dp_pull     ( usb_dp_pull         ),
                                    .usb_dp          ( usb_dp              ),
                                    .usb_dn          ( usb_dn              ),
                                    // USB reset output
                                    .usb_rstn        ( led                 ),   // 1: connected , 0: disconnected (when USB cable unplug, or when system reset (rstn=0))
                                    // CDC receive data (host-to-device)
                                    .recv_data       ( recv_data           ),   // received data byte
                                    .recv_valid      ( recv_valid          ),   // when recv_valid=1 pulses, a data byte is received on recv_data
                                    // CDC send data (device-to-host)
                                    .send_data       ( send_data           ),   //
                                    .send_valid      ( recv_valid          ),   // loopback connect recv_valid to send_valid
                                    .send_ready      (                     ),   // ignore send_ready, ignore the situation that the send buffer is full (send_ready=0). So here it will lose data when you send a large amount of data
                                    // debug output info, only for USB developers, can be ignored for normally use
                                    .debug_en        (                     ),
                                    .debug_data      (                     ),
                                    .debug_uart_tx   ( uart_tx             )
                                    );



endmodule
