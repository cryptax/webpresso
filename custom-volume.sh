#!/usr/bin/expect -f
# sudo apt-get install expect
# see https://pantz.org/software/expect/expect_examples_and_tips.html

#log_user 0

send_user "========= Customize Volume =========\n"
send_user "              by @cryptax\n"

# first argument: cup size to modify 0 (ristretto), 1 (espresso), 2 (lungo)
# second argument: xx where xx is volume in mL in hex

set cuptype [lindex $argv 0];
set cupvolume [lindex $argv 1];
send_user "Asking to customize cuptype=$cuptype with  cupvolume=$cupvolume"

set prompt "#"
set address "D2:A7:4C:76:F3:E0"
set timeout 2

# Launching bluetoothctl
send_user "Launching bluetoothctl..."
spawn bluetoothctl
expect {
    timeout { send_user "Failed to launch bluetoothctl\n"; exit 1 }
    $prompt
}
send_user "done\n"


# Connect
send_user "Connecting..."
set timeout 30
send "connect $address\r"
expect {
    timeout { send_user "Failed to connect. If this persists, try to power off/on adapter and scan.\n"; exit 2}
    "Error" { send_user "Connection failed. Welcome to BLE! Try again\n"; exit 3 }
    "Connection successful"
}
send_user "done\n"

# Wait for all characteristics and descriptors to be enumerated
#set timeout 10
#expect {
#    timeout { send_user "Failed to enumerate characteristics\n"; exit 3 }
#    "/org/bluez/hci0/dev_D2_A7_4C_76_F3_E0/service003a/char0042"
#}
#send_user "Enumeration done\n"

# Authorization
set timeout 1
send "menu gatt\r"
expect {
    timeout { send_user "Failed to change to gatt menu\n"; exit 4 }
    $prompt
}
send_user "Sending authorization code...\n"
send "select-attribute /org/bluez/hci0/dev_D2_A7_4C_76_F3_E0/service000c/char0013\r"
expect {
    timeout { send_user "Failed to select authorization characteristic\n"; exit 5 }
    $prompt
}
send "write \"0x87 0xa9 0xa7 0xc1 0xd7 0xff 0xb0 0x00\"\r"
expect {
    timeout { send_user "Failed to write authorization\n"; exit 6 }
    "Attempting to write"
}

# Modify cup size
send_user "Selecting cup...\n"
send "select-attribute /org/bluez/hci0/dev_D2_A7_4C_76_F3_E0/service002e/char002f\r"
expect {
    timeout { send_user "Failed to select Lungo cup characteristic\n"; exit 7 }
    $prompt
}
send "write \"0x00 0x0$cuptype\"\r"
expect {
    timeout { send_user "Failed to write Lungo cup characteristic\n"; exit 8 }
    $prompt
}
send "read\r"
expect {
    timeout { send_user "Failed to read back Lungo cup characteristic\n"; exit 9 }
    string tolower "00 0$cuptype"
}

send_user "Setting volume...\n"
send "select-attribute /org/bluez/hci0/dev_D2_A7_4C_76_F3_E0/service002e/char0031\r"
expect {
    timeout { send_user "Failed to select volume characteristic\n"; exit 10 }
    $prompt
}
send "write \"0x00 0x$cupvolume 0xff 0xff\"\r"
expect {
    timeout { send_user "Failed to write volume characteristic\n"; exit 11 }
    $prompt
}
#send "read\r"
#expect {
#    timeout { send_user "Failed to read back volume characteristic\r"; exit 12 }
#    string tolower "00 $cupvolume ff ff"
#}

send_user "Cup volume modified with success\n"
send "back\r"
send "disconnect\r"
send "quit\r"
expect eof
send_user "Bye!\n"
exit 0



