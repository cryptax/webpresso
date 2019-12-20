#!/usr/bin/expect -f
# sudo apt-get install expect
# see https://pantz.org/software/expect/expect_examples_and_tips.html


#log_user 0

send_user "========= Brew =========\n"
send_user "              by @cryptax\n"
send_user "\nMake sure lid has been opened to insert coffee and closed\n\n"

# one argument should be 0 (ristretto), 1 (espresso), 2 (lungo)

set cuptype [lindex $argv 0];
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
send_user "Setting authorization code...\n"
send "select-attribute /org/bluez/hci0/dev_D2_A7_4C_76_F3_E0/service000c/char0013\r"
expect {
    timeout { send_user "Failed to select authorization characteristic\n"; exit 5 }
    $prompt
}
# Make sure to enter your own authorization code here, it will probably be different!
send "write \"0x86 0xa8 0x12 0x5f 0x06 0x4e 0xf4 0x2f\"\r"
expect {
    timeout { send_user "Failed to write authorization\n"; exit 6 }
    "Attempting to write"
}

# Brew !
send "select-attribute /org/bluez/hci0/dev_D2_A7_4C_76_F3_E0/service001a/char0023\r"
expect {
    timeout { send_user "Failed to select brewing characteristic\n"; exit 7 }
    $prompt
}

set timeout 2
send_user "Brew coffee!...\n"
send "write \"0x03 0x05 0x07 0x04 0x00 0x00 0x00 0x00 0x00 0x0$cuptype\"\r"
expect {
    timeout { send_user "Failed to brew\n"; exit 8 }
    "Attempting to write"
}

# check response
send_user "Check response...\n"
send "select-attribute /org/bluez/hci0/dev_D2_A7_4C_76_F3_E0/service001a/char0025\r"
expect {
    timeout { send_user "Failed to select response characteristic\n"; exit 9 }
    $prompt
}

sleep 2
set timeout 5
send "read\r"
expect {
    timeout { send_user "Failed to select response characteristic\n"; exit 10 }
    "c3 05 02 36 01" { send_user "This coffee machine does not support Americano\n"; exit 11 }
    "c3 05 02 24 08" { send_user "The slider is open\n"; exit 12 }
    "c3 05 02 24 12" { send_user "You haven't inserted any coffee capsule\n"; exit 13}
    "c3 05 03 24 01" { send_user "Please fill the water tank\n"; exit 14 }
    "83 05" { send_user "Success, enjoy your coffee\n" }
    "83 06" { send_user "Operation canceled.\n"; exit 15 }
}


send "back\r"
send "disconnect\r"
send "quit\r"
expect eof
send_user "Bye!\n"




