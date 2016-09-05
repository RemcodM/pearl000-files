
import sys
import re
r=re.compile('[ \t]+')  # allow space and tab as separator

addr=0

# this is a routine at 0200 which prints the byte in r16 as 8 ascii binary digits to the rs232 port at 9600 baud
print("""
:020400000F9358
:02040200009167
:02040400C10035
:0204060003FDF4
:020408000FC023
:02040A0000E010
:02040C0000935B
:02040E00C50027
:0204100007E6FD
:02041200009355
:02041400C40022
:0204160008E0FC
:0204180000934F
:02041A00C1001F
:02041C000EE0F0
:02041E00009349
:02042000C20018
:0204220000E4F4
:02042400009343
:02042600C6000E
:020428000F9132
:02042A000F922F
:02042C002F930C
:02042E000F932A
:020430001F9318
:0204320028E0C0
:02043400009036
:02043600C00004
:0204380005FEBF
:02043A00FCCFF5
:02043C0018E1C5
:02043E00000FAD
:02044000111F8A
:02044200109315
:02044400C600F0
:020446002A95F5
:02044800A9F712
:02044A00009020
:02044C00C000EE
:02044E0005FEA9
:02045000FCCFDF
:02045200002E7A
:020454000AE0BC
:02045600009311
:02045800C600DC
:02045A00002D73
:02045C001F91EE
:02045E000F91FC
:020460002F91DA
:020462000F90F9
:020464000895F9""");

while True:
  s=sys.stdin.readline()
  if (s==''): break
#  print ("--- "+s)
  s=r.split(s)
  for a in s:
     if (a==''): continue;
     if (a[0]=='#'): break
     if (a[0]<' '): break
     if (a[0]=='!'):
        addr=int(a[1:],16)*2
        continue
     try:
        i=int(a,16)
        lo=i&0xff
        hi=i>>8
        print(":02{0:04X}00{1:02X}{2:02X}{3:02X}".format(addr, lo, hi, (-hi-lo-(addr&0xff)-(addr>>8)-2)&0xff) );
        addr+=2
     except:
        break;

print(":00000001FF");

