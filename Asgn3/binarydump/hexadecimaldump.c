// $Id: hexadecimaldump.c,v 1.3 2016-10-26 13:57:00-07 - - $

//
// Dump out files in binary.
//

#include <ctype.h>
#include <errno.h>
#include <fcntl.h>
#include <libgen.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

char *execname = NULL;
int exit_status = EXIT_SUCCESS;

void syserror (char *filename) {
   exit_status = EXIT_FAILURE;
   fflush (NULL);
   fprintf (stderr, "%s: %s: %s\n",
            execname, filename, strerror (errno));
   fflush (NULL);
}

void hex_dump (char *filename, int in_fdes) {
   printf ("%s:\n", filename);
   ssize_t offset = 0;
   for (;;) {
      char buffer[16];
      ssize_t nbytes = read (in_fdes, buffer, sizeof buffer);
      if (nbytes < 0) syserror (filename);
      if (nbytes == 0) break;
      printf ("%4zd", offset);
      offset += nbytes;
      for (ssize_t ichar = 0; ichar < 16; ++ichar) {
         if (ichar % 4 == 0) printf (" ");
         if (ichar < nbytes) {
            printf ("%02X", (unsigned char) buffer[ichar]);
         }else {
            printf ("  ");
         }
      }
      printf (" |");
      for (ssize_t ichar = 0; ichar < 16; ++ichar) {
          if (ichar < nbytes) {
             char byte = buffer[ichar];
             printf ("%c", isprint (byte) ? byte : '.');
          }else {
             printf (" ");
          }
      }
      printf ("|\n");
   }
}


int main (int argc, char **argv) {
   execname = basename (argv[0]);
   if (argc == 1) {
      hex_dump ("-", STDIN_FILENO);
   }else {
      for (int argi = 1; argi < argc; ++argi) {
         char *filename = argv[argi];
         if (strcmp (filename, "-") == 0) {
            hex_dump ("-", STDIN_FILENO);
         }else {
            int in_fdes = open (filename, O_RDONLY);
            if (in_fdes < 0) {
               syserror (filename);
            }else {
               hex_dump (filename, in_fdes);
               int rc = close (in_fdes);
               if (rc < 0) syserror (filename);
            }
         }
      }
   }
   return exit_status;
}

