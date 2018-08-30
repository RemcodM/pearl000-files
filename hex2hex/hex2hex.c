
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>


int main(void)
{
   {
      // there's a couple of sillynesses conspiring
      // 1- the arduino programming firmware prudently doesn't perform the chip erase command, since on this atmega blocks are erased anyway when programming
      // 2- avrdude does send the chip erase command, henceforth assumes the chip is entirely blank, causing verification errors if there are gaps in the address range to be programmed (because avrdude apparently does try to verify the data in those gaps)
      // 3- avrdude assumes that if an entire block needs to be set to 0xff, it can simply skip that block while programming, since it already did a chip erase...
      // 1 by itself is fine, if it weren't for 2 showing up in our use because we have the rs232 send routine further down the memory causing a gap in the address range
      // a simple work around would be for hex2hex to put 0xff in the intermediate memory range, but because of 3 that gets ignored
      // therefore, we write one word of non-0xff to each intermediate block to force it to be programmed
      // and we do that at the beginning of the .hex-file, so it can be overwritten by user data
      printf(    // to force programming of all intermediate blocks
      ":020000000000FE\n"
      ":0200800000007E\n"
      ":020100000000FD\n"
      ":0201800000007D\n"
      ":020200000000FC\n"
      ":0202800000007C\n"
      ":020300000000FB\n"
      ":0203800000007B\n");
      printf(     // the rs232 routine
      ":020400000F9358\n"
      ":02040200009167\n"
      ":02040400C10035\n"
      ":0204060003FDF4\n"
      ":020408000FC023\n"
      ":02040A0000E010\n"
      ":02040C0000935B\n"
      ":02040E00C50027\n"
      ":0204100007E6FD\n"
      ":02041200009355\n"
      ":02041400C40022\n"
      ":0204160008E0FC\n"
      ":0204180000934F\n"
      ":02041A00C1001F\n"
      ":02041C000EE0F0\n"
      ":02041E00009349\n"
      ":02042000C20018\n"
      ":0204220000E4F4\n"
      ":02042400009343\n"
      ":02042600C6000E\n"
      ":020428000F9132\n"
      ":02042A000F922F\n"
      ":02042C002F930C\n"
      ":02042E000F932A\n"
      ":020430001F9318\n"
      ":0204320028E0C0\n"
      ":02043400009036\n"
      ":02043600C00004\n"
      ":0204380005FEBF\n"
      ":02043A00FCCFF5\n"
      ":02043C0018E1C5\n"
      ":02043E00000FAD\n"
      ":02044000111F8A\n"
      ":02044200109315\n"
      ":02044400C600F0\n"
      ":020446002A95F5\n"
      ":02044800A9F712\n"
      ":02044A00009020\n"
      ":02044C00C000EE\n"
      ":02044E0005FEA9\n"
      ":02045000FCCFDF\n"
      ":02045200002E7A\n"
      ":020454000AE0BC\n"
      ":02045600009311\n"
      ":02045800C600DC\n"
      ":02045A00002D73\n"
      ":02045C001F91EE\n"
      ":02045E000F91FC\n"
      ":020460002F91DA\n"
      ":020462000F90F9\n"
      ":020464000895F9\n");
   }

   char s[1024];
   int addr=0;
   while (fgets(s,1024,stdin)) {
      char *p;
      p=s;
      do {
         while (isspace(*p)) p++;
         if (*p==0) {
	    // The following piece of code results in the program exiting if the last line from stdin
	    // has no EOL.
            //if (p[-1]!='\r' && p[-1]!='\n') { fprintf(stderr,"Line too long: %s\n",s); exit(1); }
	    if( (p == s) &s[1023]) { fprintf(stderr,"Line too long: %s\n",s); exit(1); }
            break;
         }
         if (*p=='#') break;
         if (*p==';') break;
         if (*p=='!') {
            int l=0;
            int r=sscanf(p+1,"%x%n",&addr,&l);
            if (r!=1) { fprintf(stderr,"Invalid address: %s\n",p); exit(1); }
            addr*=2;   // because addresses in the intel-hex file count bytes, while the AVR counts 16-bit words
            p+=l+1;
         } else {
            int l=0;
            int data;
            int r=sscanf(p,"%x%n",&data,&l);
            if (r!=1) { fprintf(stderr,"Invalid data: %s\n",p); exit(1); }
            p+=l;
            int lo,hi;
            lo=data&0xff;
            hi=data>>8;
            printf(":02%04X00%02X%02X%02X\n", addr, lo, hi, (-hi-lo-(addr&0xff)-(addr>>8)-2)&0xff);
            if (addr>=0x400 && addr<0x464) { fprintf(stderr,"Warning: overwriting RS232 routine\n"); }
            addr+=2;  // again, because the AVR words are 2 bytes
         }
      } while (1);
   }
   printf(":00000001FF\n");
}

