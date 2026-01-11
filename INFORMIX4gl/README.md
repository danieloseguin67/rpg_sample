# Music Organizer - Informix 4GL Program

This program connects to an Informix database to manage a Music table. It provides a menu-driven interface for viewing, adding, editing, and deleting music records.

## Features

- **View Music List**: Displays all songs in a list format with scrolling
- **Add New Songs**: F6 key or menu option to add new music records
- **Edit Songs**: F2 key or menu option to modify existing song details  
- **Delete Songs**: F4 key or menu option to remove songs from the database
- **Display Details**: F5 key or menu option to view song details in read-only mode
- **Database Connection**: Connects to Informix database "organiste"

## Files Included

1. **musicorg.4gl** - Main 4GL program with database integration
2. **musiclist.per** - Form file for the music list display
3. **songdetail.per** - Form file for song detail input/display
4. **compile.sh** - Unix/Linux compilation script
5. **compile.bat** - Windows compilation batch file

## Database Configuration

The program connects to:
- **Database**: organiste (Informix database)

### Music Table Structure
```sql
CREATE TABLE music (
    id              CHAR(4) PRIMARY KEY,
    songid          SERIAL NOT NULL,
    songname        VARCHAR(200) NOT NULL,
    songdesc        VARCHAR(500),
    songcat         VARCHAR(100),
    songlink        VARCHAR(500),
    songauth        VARCHAR(200),
    createddate     DATE,
    createdby       VARCHAR(100)
);
```

## Setup Instructions

### 1. Database Setup
First create the database and table:
```sql
CREATE DATABASE organiste;
DATABASE organiste;

CREATE TABLE music (
    id              CHAR(4) PRIMARY KEY,
    songid          SERIAL NOT NULL,
    songname        VARCHAR(200) NOT NULL,
    songdesc        VARCHAR(500),
    songcat         VARCHAR(100),
    songlink        VARCHAR(500),
    songauth        VARCHAR(200),
    createddate     DATE,
    createdby       VARCHAR(100)
);
```

### 2. Environment Setup
Make sure Informix environment is properly set up:
```bash
export INFORMIXDIR=/opt/informix
export INFORMIXSERVER=your_server_name
export PATH=$INFORMIXDIR/bin:$PATH
```

### 3. Compilation
#### Linux/Unix:
```bash
chmod +x compile.sh
./compile.sh
```

#### Windows:
```batch
compile.bat
```

### 4. Running the Program
#### Linux/Unix:
```bash
./musicorg
```

#### Windows:
```batch
musicorg.exe
```

## Program Operation

### Main Menu Options:
- **Add**: Add a new song to the database
- **Change**: Modify an existing song's details
- **Delete**: Remove a song from the database (with confirmation)
- **Display**: View song details in read-only mode
- **Refresh**: Reload the music list from database
- **Exit**: Exit the program

### Function Keys:
- **F2**: Change selected song
- **F4**: Delete selected song
- **F5**: Display song details
- **F6**: Add new song
- **F8**: Refresh list
- **ESC**: Exit program or cancel operation
- **CTRL-W**: Save changes (in detail screens)

### Navigation:
- Use arrow keys to navigate through the music list
- Select a record and use function keys or menu options to perform operations
- All database operations include error handling and user feedback

## Sample Data
You can insert some sample data to test the program:
```sql
INSERT INTO music VALUES ('0001', 0, 'Bohemian Rhapsody', 
    'Epic rock opera song', 'Rock', 'https://example.com/bohemian', 
    'Queen', TODAY, USER);
    
INSERT INTO music VALUES ('0002', 0, 'Hotel California', 
    'Classic rock song', 'Rock', 'https://example.com/hotel', 
    'Eagles', TODAY, USER);
```

## Error Handling

The program includes comprehensive error handling for:
- Database connection issues
- SQL execution errors
- Invalid data entry
- Missing records
- Form navigation errors

## Technical Notes

### Differences from RPG Version:
1. **Database**: Uses Informix instead of SQL Server
2. **Interface**: Menu-driven instead of subfile-based
3. **Forms**: Uses Informix .per forms instead of DDS display files
4. **SQL**: Uses Informix SQL syntax and functions
5. **Navigation**: Different navigation model (menu vs subfile)

### 4GL Language Features Used:
- Database cursors and SQL operations
- Dynamic arrays for data storage
- Window management for multi-screen interface
- Form handling with INPUT and DISPLAY statements
- Function key handling and menu processing
- Error handling with status checking

## Troubleshooting

### Common Issues:
1. **Database connection fails**: Check INFORMIXSERVER and database existence
2. **Forms don't compile**: Verify form syntax and field names match program
3. **Program crashes**: Check database permissions and table structure
4. **Function keys don't work**: Verify terminal type supports function keys

### Debug Mode:
To run with debug information, compile with:
```bash
c4gl -g -o musicorg musicorg.4gl
```

## Version History

- **v1.0**: Initial release with basic CRUD operations
- Equivalent functionality to RPG version
- Support for Linux/Unix and Windows platforms

## License

This is a sample program for educational purposes demonstrating Informix 4GL database programming techniques.