# Music Organizer - Compile Instructions
# 
# This script contains the commands to compile the Music Organizer program
# Run these commands on your IBM i system in the appropriate library
#
# Prerequisites:
# 1. Create a library for the program (e.g., MUSICLIB)
# 2. Upload the source files to the IBM i system
# 3. Add the source files to appropriate source physical files

# Step 1: Create Display File
CRTDSPF FILE(MUSICLIB/MUSICDSPF) SRCFILE(MUSICLIB/QDDSSRC) SRCMBR(MUSICDSPF)

# Step 2: Compile SQL RPG Program  
CRTSQLRPGI OBJ(MUSICLIB/MUSICPGM) SRCFILE(MUSICLIB/QRPGLESRC) SRCMBR(MUSICPGM) 
           OBJTYPE(*PGM) RPGPPOPT(*EVENTF) COMPILEOPT('OPTION(*EVENTF)')
           DBGVIEW(*SOURCE) CLOSQLCSR(*ENDMOD)

# Alternative compile with precompiler options:
# CRTSQLRPGI OBJ(MUSICLIB/MUSICPGM) SRCFILE(MUSICLIB/QRPGLESRC) SRCMBR(MUSICPGM)
#            SRCFILE2(MUSICLIB/QRPGCPYSRC) OPTION(*EVENTF) 
#            DBGVIEW(*SOURCE) COMPILEOPT('OPTION(*EVENTF *SHOWINC)')

# Step 3: Create Command (Optional - for easy program execution)
# CRTCMD CMD(MUSICLIB/MUSICCMD) PGM(MUSICLIB/MUSICPGM) 
#        SRCFILE(MUSICLIB/QCMDSRC) SRCMBR(MUSICCMD)

echo "Compilation commands prepared."
echo "Upload source files to IBM i and run the CRTDSPF and CRTSQLRPGI commands."
echo ""
echo "To run the program after compilation:"
echo "CALL MUSICLIB/MUSICPGM"