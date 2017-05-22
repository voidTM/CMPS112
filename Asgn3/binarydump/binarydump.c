// $Id: binarydump.c,v 1.5 2016-10-26 13:54:07-07 - - $

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

void binary_dump (char *filename, int in_fdes) {
   printf ("%s:\n", filename);
   char buffer[4];
   ssize_t offset = 0;
   for (;;) {
      ssize_t nbytes = read (in_fdes, buffer, sizeof buffer);
      if (nbytes < 0) syserror (filename);
      if (nbytes <= 0) break;
      printf ("%4zd", offset);
      offset += nbytes;
      for (ssize_t ichar = 0; ichar < nbytes; ++ichar) {
         printf (" ");
         for (int bit = 0x80; bit != 0; bit >>= 1) {
            printf ("%d", (buffer[ichar] & bit) != 0);
         }
      }
      printf ("\n");
      printf ("%4s", "");
      for (ssize_t ichar = 0; ichar < nbytes; ++ichar) {
          int byte = buffer[ichar] & 0xFF;
          printf (" %03o %02X %c",
                  byte, byte, isgraph (byte) ? byte : ' ');
      }
      printf ("\n");
   }
   printf ("%4zd\n", offset);
}


int main (int argc, char **argv) {
   execname = basename (argv[0]);
   if (argc == 1) {
      binary_dump ("-", STDIN_FILENO);
   }else {
      for (int argi = 1; argi < argc; ++argi) {
         char *filename = argv[argi];
         if (strcmp (filename, "-") == 0) {
            binary_dump ("-", STDIN_FILENO);
         }else {
            int in_fdes = open (filename, O_RDONLY);
            if (in_fdes < 0) {
               syserror (filename);
            }else {
               binary_dump (filename, in_fdes);
               int rc = close (in_fdes);
               if (rc < 0) syserror (filename);
            }
         }
      }
   }
   return exit_status;
}
