# Music Organizer RPG Program - Flowchart and Analysis

## Overview
This document contains the flowchart and detailed analysis of the Music Organizer RPG program (`MUSICPGM.SQLRPGLE`). The program provides a complete CRUD interface for managing a music database using IBM i RPG with SQL Server connectivity.

## Program Flowchart

```mermaid
flowchart TD
    START([START]) --> INIT[Initialize Program]
    INIT --> CONNECT[Connect to Database]
    CONNECT --> CONN_CHK{Connection Successful?}
    
    CONN_CHK -->|Yes| LOAD[Load Music List from Database]
    CONN_CHK -->|No| ERR_MSG[Display Error Message]
    
    LOAD --> DISPLAY[Display Subfile Screen]
    ERR_MSG --> DISPLAY
    
    DISPLAY --> INPUT[Wait for User Input]
    INPUT --> KEY_CHK{Function Key or Option?}
    
    %% Function Key Processing
    KEY_CHK -->|F3 Exit| EXIT_FLAG[Set Exit Flag]
    KEY_CHK -->|F5 Refresh| REFRESH[Refresh List]
    KEY_CHK -->|F6 Add| ADD_NEW[Add New Song]
    KEY_CHK -->|F12 Cancel| CANCEL[Cancel Operation]
    KEY_CHK -->|Enter/Options| PROCESS[Process Options]
    
    REFRESH --> LOAD
    CANCEL --> DISPLAY
    
    %% Add New Song Flow
    ADD_NEW --> ADD_SCREEN[Display Detail Screen for New Song]
    ADD_SCREEN --> ADD_ACTION{User Action?}
    ADD_ACTION -->|F3/F12| ADD_CANCEL[Cancel Add]
    ADD_ACTION -->|Enter| ADD_SAVE[Generate ID and Save to Database]
    ADD_SAVE --> ADD_SUCCESS{Save Successful?}
    ADD_SUCCESS -->|Yes| ADD_OK[Show Success and Refresh List]
    ADD_SUCCESS -->|No| ADD_ERROR[Show Error Message]
    ADD_OK --> LOAD
    ADD_ERROR --> ADD_SCREEN
    ADD_CANCEL --> DISPLAY
    
    %% Process Subfile Options
    PROCESS --> OPTION_CHK{Which Option?}
    OPTION_CHK -->|2 Change| EDIT[Edit Song]
    OPTION_CHK -->|4 Delete| DELETE[Delete Song]
    OPTION_CHK -->|5 Display| VIEW[Display Song Details]
    OPTION_CHK -->|9 Add| ADD_NEW
    OPTION_CHK -->|None/Continue| CHECK_EXIT
    
    %% Edit Song Flow
    EDIT --> EDIT_LOAD[Load Song Details]
    EDIT_LOAD --> EDIT_FOUND{Song Found?}
    EDIT_FOUND -->|No| NOT_FOUND[Song Not Found]
    EDIT_FOUND -->|Yes| EDIT_SCREEN[Display Detail Screen for Edit]
    EDIT_SCREEN --> EDIT_ACTION{User Action?}
    EDIT_ACTION -->|F3/F12| EDIT_CANCEL[Cancel Edit]
    EDIT_ACTION -->|Enter| EDIT_SAVE[Update Database]
    EDIT_SAVE --> EDIT_SUCCESS{Update Successful?}
    EDIT_SUCCESS -->|Yes| EDIT_OK[Show Success and Refresh List]
    EDIT_SUCCESS -->|No| EDIT_ERROR[Show Error Message]
    EDIT_OK --> LOAD
    EDIT_ERROR --> EDIT_SCREEN
    EDIT_CANCEL --> DISPLAY
    
    %% Delete Song Flow
    DELETE --> DEL_LOAD[Get Song Details]
    DEL_LOAD --> DEL_FOUND{Song Found?}
    DEL_FOUND -->|No| NOT_FOUND
    DEL_FOUND -->|Yes| DEL_CONFIRM[Delete from Database]
    DEL_CONFIRM --> DEL_SUCCESS{Delete Successful?}
    DEL_SUCCESS -->|Yes| DEL_OK[Show Success and Refresh List]
    DEL_SUCCESS -->|No| DEL_ERROR[Show Error Message]
    DEL_OK --> LOAD
    DEL_ERROR --> DISPLAY
    
    %% Display Song Flow
    VIEW --> VIEW_LOAD[Load Song Details]
    VIEW_LOAD --> VIEW_FOUND{Song Found?}
    VIEW_FOUND -->|No| NOT_FOUND
    VIEW_FOUND -->|Yes| VIEW_SCREEN[Display Details Read-Only]
    VIEW_SCREEN --> VIEW_DONE[Press Enter to Return]
    VIEW_DONE --> DISPLAY
    
    %% Exit Check and Cleanup
    NOT_FOUND --> DISPLAY
    EXIT_FLAG --> CHECK_EXIT
    CHECK_EXIT{Exit Program?}
    CHECK_EXIT -->|No| DISPLAY
    CHECK_EXIT -->|Yes| DISCONNECT[Disconnect Database]
    DISCONNECT --> END_PROG([END])
    
    %% Styling
    classDef startEnd fill:#90EE90,stroke:#333,stroke-width:2px
    classDef decision fill:#FFD700,stroke:#333,stroke-width:2px
    classDef process fill:#87CEEB,stroke:#333,stroke-width:2px
    classDef error fill:#FFB6C1,stroke:#333,stroke-width:2px
    classDef database fill:#DDA0DD,stroke:#333,stroke-width:2px
    
    class START,END_PROG startEnd
    class CONN_CHK,KEY_CHK,ADD_ACTION,ADD_SUCCESS,EDIT_FOUND,EDIT_ACTION,EDIT_SUCCESS,DEL_FOUND,DEL_SUCCESS,VIEW_FOUND,CHECK_EXIT decision
    class LOAD,REFRESH,DEL_CONFIRM,EDIT_SAVE,ADD_SAVE database
    class ERR_MSG,ADD_ERROR,EDIT_ERROR,DEL_ERROR,NOT_FOUND error
```

## Program Flow Summary

The **Music Organizer RPG Program** follows this main flow:

### 1. Initialization Phase
- Program starts and connects to SQL Server database (`organiste`)
- Loads music records from the `Music` table into a subfile
- Displays the main subfile screen with music list

### 2. Main Processing Loop
The program enters a loop that continues until the user exits:
- **Display subfile screen** with current music records
- **Wait for user input** (function keys or subfile options)

### 3. Function Key Processing
- **F3**: Exit program
- **F5**: Refresh music list from database
- **F6**: Add new song
- **F12**: Cancel current operation
- **Enter**: Process selected subfile options

### 4. Subfile Option Processing
- **Option 2 (Change)**: Edit selected song details
- **Option 4 (Delete)**: Delete selected song from database
- **Option 5 (Display)**: View song details (read-only)
- **Option 9 (Add New)**: Add new song (alternative to F6)

### 5. Database Operations
- **Add Song**: Generate new ID, insert record, refresh list
- **Edit Song**: Load current data, allow changes, update database
- **Delete Song**: Remove record from database, refresh list
- **Display Song**: Show details in read-only mode

### 6. Error Handling
- SQL errors are caught and displayed to user
- Program-level errors are handled with monitor blocks
- Connection failures are reported with appropriate messages

### 7. Program Termination
- Disconnect from database
- Clean up resources and exit

## Key Program Components

### Main Procedures
1. **`main()`** - Entry point, coordinates overall program flow
2. **`connectToDatabase()`** - Establishes SQL Server connection
3. **`disconnectFromDatabase()`** - Closes database connection
4. **`loadMusicList()`** - Populates subfile with database records
5. **`displaySubfile()`** - Shows main screen and handles function keys
6. **`processUserActions()`** - Processes subfile options and function keys
7. **`addNewSong()`** - Handles new record creation
8. **`editSong()`** - Manages record updates
9. **`displaySong()`** - Shows read-only record details
10. **`deleteSong()`** - Removes records from database

### Database Schema
The program works with a `Music` table containing:
- **Id** (char(4)) - Primary key
- **SongId** (packed(4,0)) - Numeric identifier
- **SongName** (varchar(200)) - Song title
- **SongDescription** (varchar(500)) - Song description
- **SongCategory** (varchar(100)) - Music category
- **SongLink** (varchar(500)) - URL or link
- **SongAuthor** (varchar(200)) - Artist/author
- **CreatedDate** (date) - Creation timestamp
- **CreatedBy** (varchar(100)) - User who created record

### User Interface
The program uses two main screens defined in `MUSICDSPF.DSPF`:
1. **Subfile Screen (`SFLCTL`)** - Lists music records with options
2. **Detail Screen (`MUSICDETAIL`)** - Shows/edits individual record details

## Technical Features
- **SQL Server Integration** via ODBC connection
- **Subfile Processing** for list management
- **Error Handling** with monitor blocks
- **Transaction Management** for database operations
- **User-friendly Interface** with function key navigation
- **CRUD Operations** (Create, Read, Update, Delete)

The program demonstrates modern RPG programming practices including SQL integration, structured error handling, and modular procedure design while maintaining the traditional IBM i user interface paradigm.