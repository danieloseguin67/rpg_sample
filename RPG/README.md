# Music Organizer - RPG Program

This program connects to a SQL Server database to manage a Music table. It provides a subfile interface for viewing, adding, editing, and deleting music records.

## Features

- **View Music List**: Displays all songs in a subfile format
- **Add New Songs**: F6 key or option 9 to add new music records
- **Edit Songs**: Option 2 to modify existing song details
- **Delete Songs**: Option 4 to remove songs from the database
- **Display Details**: Option 5 to view song details in read-only mode
- **Database Connection**: Connects to SQL Server database "organiste" on localhost

## Files Included

1. **MUSICDSPF.DSPF** - Display file with subfile for music list and detail screen
2. **MUSICPGM.SQLRPGLE** - Main RPG program with SQL integration
3. **compile.sh** - Compilation commands for IBM i

## Database Configuration

The program connects to:
- **Server**: localhost
- **Database**: organiste  
- **Username**: user 
- **Password**: password

### Music Table Structure
```sql
[Id] [char](4) NOT NULL (Primary Key)
[SongId] [int] IDENTITY(1,1) NOT NULL
[SongName] [nvarchar](200) NOT NULL
[SongDescription] [nvarchar](500) NULL
[SongCategory] [nvarchar](100) NULL
[SongLink] [nvarchar](500) NULL
[SongAuthor] [nvarchar](200) NULL
[CreatedDate] [date] NULL
[CreatedBy] [nvarchar](100) NULL
```

## Setup Instructions

### 1. IBM i System Setup
```
CRTLIB LIB(MUSICLIB) TEXT('Music Organizer Library')
ADDLIBLE MUSICLIB
```

### 2. Create Source Physical Files
```
CRTSRCPF FILE(MUSICLIB/QDDSSRC) RCDLEN(112)
CRTSRCPF FILE(MUSICLIB/QRPGLESRC) RCDLEN(112)
```

### 3. Upload Source Files
Transfer the source files to IBM i:
- MUSICDSPF.DSPF → MUSICLIB/QDDSSRC(MUSICDSPF)
- MUSICPGM.SQLRPGLE → MUSICLIB/QRPGLESRC(MUSICPGM)

### 4. Compile Display File
```
CRTDSPF FILE(MUSICLIB/MUSICDSPF) SRCFILE(MUSICLIB/QDDSSRC) SRCMBR(MUSICDSPF)
```

### 5. Compile RPG Program
```
CRTSQLRPGI OBJ(MUSICLIB/MUSICPGM) SRCFILE(MUSICLIB/QRPGLESRC) SRCMBR(MUSICPGM) 
           OBJTYPE(*PGM) RPGPPOPT(*EVENTF) COMPILEOPT('OPTION(*EVENTF)')
           DBGVIEW(*SOURCE) CLOSQLCSR(*ENDMOD)
```

## Running the Program

```
CALL MUSICLIB/MUSICPGM
```

## Program Navigation

### Main Screen (Subfile)
- **F3** = Exit program
- **F5** = Refresh the music list
- **F6** = Add new song
- **F12** = Cancel current operation
- **Enter** = Process selected options

### Subfile Options
- **2** = Change/Edit song
- **4** = Delete song  
- **5** = Display song details
- **9** = Add new song (alternative to F6)

### Detail Screen (Add/Edit)
- **F3** = Exit without saving
- **F12** = Cancel and return to list
- **Enter** = Save changes

## Error Handling

The program includes error handling for:
- Database connection failures
- SQL operation errors
- Invalid user input
- Network connectivity issues

## Security Notes

⚠️ **Important**: This program contains hardcoded database credentials for demonstration purposes. In production:

1. Use a secure credential management system
2. Implement proper authentication
3. Use encrypted connections
4. Follow your organization's security policies

## Troubleshooting

### Common Issues

1. **Connection Failed**
   - Verify SQL Server is running
   - Check network connectivity
   - Confirm database credentials
   - Ensure ODBC driver is installed

2. **Compilation Errors**
   - Verify source file locations
   - Check library list
   - Ensure proper authority to compile

3. **Runtime Errors**
   - Check SQLCODE values for specific SQL errors
   - Verify database table exists
   - Confirm user has appropriate database permissions

## Technical Details

- **Language**: ILE RPG with embedded SQL
- **Display**: 24x80 character screen
- **Database**: SQL Server via ODBC
- **Subfile**: Supports up to 999 records with 14 records per page
- **Character Encoding**: CCSID compatible with IBM i and SQL Server

## Support

For issues or enhancements:
1. Check the program message area for specific error codes
2. Review job logs for detailed error information  
3. Verify database connectivity using IBM i Navigator or ACS
4. Test SQL statements independently using STRSQL