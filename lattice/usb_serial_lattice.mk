PROJECT=usb_serial_lattice
VERILOG_SOURCES=usb_serial_lattice.v pllModule.v ../RTL/usb_class/usb_serial_top.v ../RTL/usbfs_core/usbfs_core_top.v ../RTL/usbfs_core/usbfs_bitlevel.v ../RTL/usbfs_core/usbfs_packet_rx.v ../RTL/usbfs_core/usbfs_packet_tx.v ../RTL/usbfs_core/usbfs_transaction.v

include hx8k.mk
