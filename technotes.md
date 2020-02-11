# Coffee machine

*This is research on my coffee machine. My understanding of it. Might contain error. Handle with care.*

## Services

- `COFFEE_MACHINE_SERVICE_UUID` is `06aa1910-f22a-11e3-9daa-0002a5d5c51b` (**0x1910**). Handles 0x0c - 0x19
- `AEROCCINO_SERVICE_UUID` is `06aa1920-f22a-11e3-9daa-0002a5d5c51b` (**0x1920**). Handles 0x1a - 0x27
- Error service  is `06aa1930-f22a-11e3-9daa-0002a5d5c51b` (**0x1930**). Handles 0x28 - 0x2d
- Cup size and volume is  `06aa1940-f22a-11e3-9daa-0002a5d5c51b` (**0x1940**). Handles 0x2e - 0x39
- `ORDER_SERVICE_UUID is `06aa1950-f22a-11e3-9daa-0002a5d5c51b` (**0x1950**). Handles 0x3a +

### Coffee machine service

| Characteristic name | Service UUID | Characteristic UUID | Handle | Comments | 
| --------------------------- | ----------------- | -------------------------- | ----------| --------------- |
| Machine information | 0x1910         | 0x3A21 | 0x0010 | 00 6c 00 6d 00 7d 00 76 xx ... |
|                                |                       |              |             | Hardware version, bootloader version, firmware, bluetooth firmware, BT MAC |
| Serial                       | 0x1910          | 0x3A31 | 0x0012 | This is ASCII: 31 36 30 36 39 44 ... (serial number). |
|                                |                       |             |             | This is the only characteristics that can be read without pairing |
| Authentication Key   | 0x1910          | 0x3A41 | 0x0014 | Write only. |
| Pairing key state      | 0x1910          | 0x3A51 | 0x0016 | ABSENT (0), PRESENT(1 or 2), UNDEFINED (3). I got 02.|
|                                |                       |             | 0x0017 | To activate notifications |                          
| Onboarding             | 0x1910           | 0x3A61 | 0x0019 | Cannot be read. |


#### Machine information

- 00 6c = Hardware version
- 00 6d = Bootloader version
- 00 7d = Firmware version
- 00 76 = Bluetooth firmware version
- Device MAC address.


### Aeroccino service

| Characteristic name | Service UUID | Characteristic UUID | Handle | Comments | 
| --------------------------- | ----------------- | -------------------------- | ----------| --------------- |
|                                |                      | 0x3a11                    | 0x000e | |
| Machine status         | 0x1920         | 0x3A12                   | 0x001c | You can get notifications. Or read. |
|                                |                      |                               |             | e.g. 40 02 01 90 00 00 0e f8 |
|                                |                       |                              | 0x001d | To activate notifications |          
| Machine Specific      | 0x1920          | 0x3A22 		        | 0x001f | When you open the lid: 00. When it is closed: 02 |
|                                |                       |                              | 0x0020 | To activate notifications |          
| Schedule brew         | 0x1920 | 0x3A32 | 0x0022 | Read programmed brew. Will be TT TT DD DD DD DD (T=type, F=temperature, D=duration).  If not scheduled 00 00 00 00 00 00  |
| Brew Key                  | 0x1920 | 0x3A42 | 0x0024 | To cancel brew, write: 03 06 01 02. |
|                                 |             |             |              | To brew now, write: 03 05 07 04 SS SS SS SS TT TT where SS is the delay in seconds and TT is the coffee type. |
|                                 |             |             |              | To brew with temperature,  03 05 07 04 SS SS SS SS TT TT FF |
|                                 |             |             |              | To write a recipe, 01 16 08 00 00 .. recipe |
|                                 |             |             |              | To schedule brew, 03 05 07 04 SS SS SS SS TT TT |
|                                 |             |             |              | To schedule brew with temperature, 03 05 07 04 SS SS SS SS TT TT FF |
|                                 |             |             |              | payload: 03 07 00 |
| Response brew         | 0x1920 | 0x3A52 | 0x0026 |   |
|                                 |             |             |              | c3 05 02 24 12 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 |
|                                 |             |             |              | If you try to brew americano: c3 05 02 36 01 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 |
|                                 |             |             |              | If you try to brew 3: 83 05 01 20 80 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 |
|                                 |             |             |              | If you try to brew espresso: 83 05 01 20 80 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00  |
|                                 |            |              |              | If you try to brew a ristretto: 83 05 01 20 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 |
|                                 |             |             |              | If you cancel: 83 06 01 20 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 |
|                                 |            |              |              | If you try to brew a americano: c3 05 02 36 01 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 |
|                                |                       |    | 0x0027 | To activate notifications |


#### Brewing coffee (0x0024)

##### Coffee Type

- RISTRETTO 0
- ESPRESSO 1
- LUNGO 2
- AMERICANO 5
- HOT WATER 4

Note that some coffee pots only have RISTRETTO (0), ESPRESSO (1) and LUNGO (2)**. 

##### Brew now

To brew now, 

`03 05 07 04 SS SS SS SS TT TT`

- where TT is coffee type,
- and SS is the seconds delay to brew

You can apparently also set the temperature: `03 05 07 04 SS SS SS SS TT TT FF` where FF is the temperature position. But I see no difference in resulting temperature.


###### Recipe


- RECIPE_PREFIX: 01 16 + 08
- RECIPE_ID: 00 00
- List of ingredient volumes where you select either coffee or water:
  Coffee: 01 CC CC where CC is coffee volume in ml
  Water: 02 WW WW where WW is water volume in ml
- Finish with 00 00 00

`01 16 08 00 00...`

A recipe is normally a given volume in mL of coffee then water, or water then coffee. With a temperature.
The acceptable range for coffee is 15mL to 130mL.
The acceptable range for water is 25mL to 300mL.

**My coffee maker does not support recipes**


#### Brew Response

OK starts with `83`:

- 05 = brewing coffee
- 06 = cancel


ERRORs start with `c3 05 02`.
- 08 = SLIDER_OPEN +1
- 12 = SLIDER_NOT_BEEN_OPENED + 1


Americano:
- c3 05 02 36 01 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00
- c3 05 02 36 01 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00

Coffee type 3:
- 83 05 01 20 80 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00

Espresso:
- 83 05 01 20 80 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00

Ristretto:
- 83 05 01 20 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
- 83 05 01 20 80 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00

Ristretto with temperature:
- 83 05 01 20 80 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00
- 83 05 01 20 80 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00

Cancel:
- 83 06 01 20 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
- 83 06 01 20 80 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00

Ristretto with open lid:
- c3 05 02 24 08 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00

Ristretto without opened lid:
- c3 05 02 24 12 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00

Ristretto without enough water?
- c3 05 03 24 01 04 80 00 00 00 00 00 00 00 00 00 00 00 00 00

### 0x1930

| Characteristic name | Service UUID | Characteristic UUID | Handle | Comments | 
| --------------------------- | ----------------- | -------------------------- | ----------| --------------- |
| Error Selection	  | 0x1930 | 0x3A13 | 0x002a | 00 |
| Error Information     | 0x1930 | 0x3A23 | 0x002c | 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 |

This does not change even if the slider hasn't been opened.


### 0x1940

| Characteristic name | Service UUID | Characteristic UUID | Handle | Comments | 
| --------------------------- | ----------------- | -------------------------- | ----------| --------------- |
| Write Cup Size  Target     | 0x1940         | 0x3A14 | 0x0030 | 0 is ristretto, 1=espresso, 2=lungo... 00 00 |
| Volume                    | 0x1940         | 0x3A24 | 0x0032 | VV VV FF FF where VV is the volume in ml converted to hex. FF FF for -1. 00 00 00 00 |
|                                | 0x1940         | 0x3A34 | 0x0035 | |
| Water Hardness and StandBy Delay | 0x1940 | 0x3A44 | 0x0038 |  |
|                                 |             |             |               | format is SS SS HH where HH is water hardness level (int <= 4), and SS is the seconds for the stand by delay: 07 08 04 00 |

Cup size:

- RISTRETTO or HOT_WATER_VTP2: 0
- ESPRESSO or ESPRESSO_VTP2: 1
- LUNGO: 2
- AMERICANO_COFFEE or AMERICANO_COFFEE_VTP2: 3
- AMERICANO_WATER: 4
- AMERICANO_XL_COFFEE: 5
- AMERICANO_XL_WATER: 6

Normal volumes are (from doc):

- ristretto 25ml
- espresso 40ml
- lungo 110ml

Acceptable ranges are:

- ristretto: 15-30ml
- espresso: 30-70ml
- lungo: 70-130ml

Water hardness and standby:

SS = stand by delay option seconds
HH = water hardness level
xx SS SS
HH xx xx

### 0x1950

| Characteristic name | Service UUID | Characteristic UUID | Handle | Comments | 
| --------------------------- | ----------------- | -------------------------- | ----------| --------------- |
| Stock                       | 0x1950 | 0x3A15 | 0x003c | 00 0e - Corresponds to the app's stock. |
| Stock threshold        | 0x1950 | 0x3A25 | 0x003f |  00 05 |
| Stock Key                | 0x1950 | 0x3A35 | 0x0041 | 00 00 00 00 |
|                                | 0x1950 | 0x3a45 | 0x0043 | 01 |

### Not on my machine

| Characteristic name | Service UUID | Characteristic UUID |  Comments | 
| --------------------------- | ----------------- | -------------------------- | --------------- |
| UiLanguage | 0x19A0 | 0x3A1A | |
| Country Config | 0x1990 | 0x3A79 | |
| Get Network Config | 0x1990 | 0x3A29 |
| Set Network Config | 0x1990 | 0x3A19 |
| Query Scan SSID | 0x1990 | 0x3A39 | |
| Read Scan SSID | 0x1990 | 0x3A49 | |

## Buttons

| Command                                         | Action                                  |
| ------------------------------------------------ | ------------------------------------- |
| RISTRETTO + LUNGO 6 sec -> Flash | After filling water tank |
| LUNGO + ESPRESSO 3 sec                | OFF |
| SLIDER                                             | ON |
| Command OFF, then ESPRESSO + LUNGO 5 sec -> Blink | Factory reset |
| RISTRETTO + ESPRESSO, then remove plug                    | Unpair |
