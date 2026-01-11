# Music Organizer - Informix 4GL Program
# This file establishes a connection to the Informix database and provides functionality
# for managing records in the Music table. It may include operations such as querying,
# inserting, updating, or deleting music-related data.
# Connects to Informix database to manage Music table

DATABASE organiste

DEFINE m_music_arr ARRAY[200] OF RECORD
    songid          INTEGER,
    songname        CHAR(50),
    author          CHAR(30),
    selected        CHAR(1)
END RECORD

DEFINE m_curr_rec RECORD
    songid          INTEGER,
    songname        CHAR(200),
    songdesc        CHAR(500),
    songcat         CHAR(100),
    songlink        CHAR(500),
    songauth        CHAR(200),
    createdby       CHAR(100),
    createddate     DATE
END RECORD

DEFINE m_message    CHAR(78)
DEFINE m_arr_size   INTEGER
DEFINE m_curr_row   INTEGER
DEFINE m_choice     CHAR(1)

MAIN
    DEFER INTERRUPT
    CLEAR SCREEN
    
    CALL setup_database()
    
    IF status = 0 THEN
        CALL load_music_list()
        CALL main_menu()
    END IF
    
    CLOSE WINDOW music_list
END MAIN

FUNCTION setup_database()
    WHENEVER ERROR CONTINUE
    
    # Create Music table if it doesn't exist
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
    )
    
    # Don't worry about error if table already exists
    LET status = 0
END FUNCTION

FUNCTION load_music_list()
    DEFINE i INTEGER
    
    LET m_arr_size = 0
    LET i = 1
    
    WHENEVER ERROR CONTINUE
    DECLARE music_cursor CURSOR FOR
        SELECT songid, songname, NVL(songauth, '') 
        FROM music 
        ORDER BY songid
    
    FOREACH music_cursor INTO m_music_arr[i].songid, 
                              m_music_arr[i].songname,
                              m_music_arr[i].author
        LET m_music_arr[i].selected = " "
        LET i = i + 1
        IF i > 200 THEN
            EXIT FOREACH
        END IF
    END FOREACH
    
    LET m_arr_size = i - 1
    
    IF m_arr_size = 0 THEN
        LET m_message = "No music records found in database"
    ELSE
        LET m_message = m_arr_size USING "###", " music records loaded"
    END IF
END FUNCTION

FUNCTION main_menu()
    DEFINE done INTEGER
    
    LET done = 0
    LET m_curr_row = 1
    
    OPEN WINDOW music_list AT 2,2 WITH FORM "musiclist"
        ATTRIBUTE(BORDER, MESSAGE LINE LAST)
    
    WHILE NOT done
        CALL display_music_list()
        
        MENU "Music Organizer"
            COMMAND "Add" "Add new song (F6)"
                CALL add_new_song()
                CALL load_music_list()
                
            COMMAND "Change" "Change selected song (F2)"
                IF m_arr_size > 0 THEN
                    CALL change_song(m_music_arr[m_curr_row].songid)
                    CALL load_music_list()
                ELSE
                    ERROR "No records to change"
                END IF
                
            COMMAND "Delete" "Delete selected song (F4)" 
                IF m_arr_size > 0 THEN
                    CALL delete_song(m_music_arr[m_curr_row].songid)
                    CALL load_music_list()
                ELSE
                    ERROR "No records to delete"
                END IF
                
            COMMAND "Display" "Display song details (F5)"
                IF m_arr_size > 0 THEN
                    CALL display_song(m_music_arr[m_curr_row].songid)
                ELSE
                    ERROR "No records to display"
                END IF
                
            COMMAND "Refresh" "Refresh list (F8)"
                CALL load_music_list()
                
            COMMAND "Exit" "Exit program (ESC)"
                LET done = 1
                
            ON KEY (F2)
                IF m_arr_size > 0 THEN
                    CALL change_song(m_music_arr[m_curr_row].songid)
                    CALL load_music_list()
                END IF
                
            ON KEY (F4) 
                IF m_arr_size > 0 THEN
                    CALL delete_song(m_music_arr[m_curr_row].songid)
                    CALL load_music_list()
                END IF
                
            ON KEY (F5)
                IF m_arr_size > 0 THEN
                    CALL display_song(m_music_arr[m_curr_row].songid)
                END IF
                
            ON KEY (F6)
                CALL add_new_song()
                CALL load_music_list()
                
            ON KEY (F8)
                CALL load_music_list()
                
        END MENU
    END WHILE
END FUNCTION

FUNCTION display_music_list()
    DEFINE i INTEGER
    
    DISPLAY "Music Organizer - Database: organiste" AT 1,20
    DISPLAY "Type option, press Enter or use function keys" AT 3,2
    DISPLAY "F2=Change  F4=Delete  F5=Display  F6=Add  F8=Refresh  ESC=Exit" AT 4,2
    
    DISPLAY "ID   Song Name                                      Author" AT 6,2
    DISPLAY "---- ------------------------------------------------ ------------------------------" AT 7,2
    
    FOR i = 1 TO m_arr_size
        DISPLAY m_music_arr[i].songid USING "####", " ",
                m_music_arr[i].songname CLIPPED, " ",
                m_music_arr[i].author CLIPPED 
                AT 7+i, 2
    END FOR
    
    MESSAGE m_message
END FUNCTION

FUNCTION add_new_song()
    DEFINE new_id       CHAR(4)
    DEFINE max_songid   INTEGER
    DEFINE done         INTEGER
    
    LET done = 0
    
    # Get next available ID
    SELECT MAX(songid) INTO max_songid FROM music
    IF max_songid IS NULL THEN
        LET max_songid = 0
    END IF
    LET max_songid = max_songid + 1
    LET new_id = max_songid USING "####"
    
    INITIALIZE m_curr_rec.* TO NULL
    LET m_curr_rec.songid = max_songid
    LET m_curr_rec.createddate = TODAY
    LET m_curr_rec.createdby = USER
    
    OPEN WINDOW song_detail AT 5,5 WITH FORM "songdetail"
        ATTRIBUTE(BORDER, MESSAGE LINE LAST)
    
    MESSAGE "Enter new song details. ESC=Cancel, CTRL-W=Save"
    
    INPUT BY NAME m_curr_rec.songname,
                  m_curr_rec.songdesc,
                  m_curr_rec.songcat,
                  m_curr_rec.songlink,
                  m_curr_rec.songauth
        WITHOUT DEFAULTS
        
        AFTER FIELD songname
            IF m_curr_rec.songname IS NULL OR 
               LENGTH(m_curr_rec.songname CLIPPED) = 0 THEN
                ERROR "Song name is required"
                NEXT FIELD songname
            END IF
            
        ON KEY (CONTROL-W)
            IF m_curr_rec.songname IS NOT NULL AND
               LENGTH(m_curr_rec.songname CLIPPED) > 0 THEN
                CALL save_new_song(new_id)
                LET done = 1
                EXIT INPUT
            ELSE
                ERROR "Song name is required"
            END IF
            
    END INPUT
    
    CLOSE WINDOW song_detail
END FUNCTION

FUNCTION save_new_song(p_id)
    DEFINE p_id CHAR(4)
    
    WHENEVER ERROR CONTINUE
    
    INSERT INTO music (id, songname, songdesc, songcat, songlink, 
                       songauth, createddate, createdby)
    VALUES (p_id, m_curr_rec.songname, m_curr_rec.songdesc,
            m_curr_rec.songcat, m_curr_rec.songlink,
            m_curr_rec.songauth, m_curr_rec.createddate,
            m_curr_rec.createdby)
    
    IF status = 0 THEN
        LET m_message = "Song added successfully"
    ELSE  
        LET m_message = "Error adding song. Status: ", status USING "-####"
    END IF
END FUNCTION

FUNCTION change_song(p_songid)
    DEFINE p_songid     INTEGER
    DEFINE rec_id       CHAR(4)
    DEFINE done         INTEGER
    
    LET done = 0
    
    # Load existing record
    SELECT id, songname, NVL(songdesc,''), NVL(songcat,''),
           NVL(songlink,''), NVL(songauth,''), NVL(createdby,'')
    INTO rec_id, m_curr_rec.songname, m_curr_rec.songdesc,
         m_curr_rec.songcat, m_curr_rec.songlink,
         m_curr_rec.songauth, m_curr_rec.createdby
    FROM music
    WHERE songid = p_songid
    
    IF status != 0 THEN
        ERROR "Song not found"
        RETURN
    END IF
    
    LET m_curr_rec.songid = p_songid
    
    OPEN WINDOW song_detail AT 5,5 WITH FORM "songdetail"
        ATTRIBUTE(BORDER, MESSAGE LINE LAST)
    
    MESSAGE "Change song details. ESC=Cancel, CTRL-W=Save"
    
    INPUT BY NAME m_curr_rec.songname,
                  m_curr_rec.songdesc,
                  m_curr_rec.songcat,
                  m_curr_rec.songlink,
                  m_curr_rec.songauth
    
        AFTER FIELD songname
            IF m_curr_rec.songname IS NULL OR 
               LENGTH(m_curr_rec.songname CLIPPED) = 0 THEN
                ERROR "Song name is required"
                NEXT FIELD songname
            END IF
            
        ON KEY (CONTROL-W)
            IF m_curr_rec.songname IS NOT NULL AND
               LENGTH(m_curr_rec.songname CLIPPED) > 0 THEN
                CALL save_changed_song(rec_id)
                LET done = 1
                EXIT INPUT
            ELSE
                ERROR "Song name is required"
            END IF
            
    END INPUT
    
    CLOSE WINDOW song_detail
END FUNCTION

FUNCTION save_changed_song(p_id)
    DEFINE p_id CHAR(4)
    
    WHENEVER ERROR CONTINUE
    
    UPDATE music SET 
        songname = m_curr_rec.songname,
        songdesc = m_curr_rec.songdesc,
        songcat = m_curr_rec.songcat,
        songlink = m_curr_rec.songlink,
        songauth = m_curr_rec.songauth
    WHERE id = p_id
    
    IF status = 0 THEN
        LET m_message = "Song updated successfully"
    ELSE
        LET m_message = "Error updating song. Status: ", status USING "-####"
    END IF
END FUNCTION

FUNCTION display_song(p_songid)
    DEFINE p_songid     INTEGER
    DEFINE rec_id       CHAR(4)
    
    # Load existing record
    SELECT id, songname, NVL(songdesc,''), NVL(songcat,''),
           NVL(songlink,''), NVL(songauth,''), NVL(createdby,''),
           createddate
    INTO rec_id, m_curr_rec.songname, m_curr_rec.songdesc,
         m_curr_rec.songcat, m_curr_rec.songlink,
         m_curr_rec.songauth, m_curr_rec.createdby,
         m_curr_rec.createddate
    FROM music
    WHERE songid = p_songid
    
    IF status != 0 THEN
        ERROR "Song not found"
        RETURN
    END IF
    
    LET m_curr_rec.songid = p_songid
    
    OPEN WINDOW song_detail AT 5,5 WITH FORM "songdetail"
        ATTRIBUTE(BORDER, MESSAGE LINE LAST)
    
    MESSAGE "Song details (display only). Press any key to return"
    
    DISPLAY BY NAME m_curr_rec.songid,
                    m_curr_rec.songname,
                    m_curr_rec.songdesc,
                    m_curr_rec.songcat,
                    m_curr_rec.songlink,
                    m_curr_rec.songauth,
                    m_curr_rec.createdby,
                    m_curr_rec.createddate
    
    PROMPT " " FOR CHAR key
    
    CLOSE WINDOW song_detail
END FUNCTION

FUNCTION delete_song(p_songid)
    DEFINE p_songid     INTEGER
    DEFINE song_name    CHAR(200)
    DEFINE rec_id       CHAR(4)
    DEFINE response     CHAR(1)
    
    # Get song name for confirmation
    SELECT id, songname INTO rec_id, song_name
    FROM music
    WHERE songid = p_songid
    
    IF status != 0 THEN
        ERROR "Song not found"
        RETURN
    END IF
    
    # Confirm deletion
    LET m_message = "Delete song '", song_name CLIPPED, "'? (Y/N)"
    MESSAGE m_message
    
    PROMPT "Delete this song? (Y/N): " FOR response
    
    IF UPSHIFT(response) = "Y" THEN
        WHENEVER ERROR CONTINUE
        DELETE FROM music WHERE id = rec_id
        
        IF status = 0 THEN
            LET m_message = "Song '", song_name CLIPPED, "' deleted successfully"
        ELSE
            LET m_message = "Error deleting song. Status: ", status USING "-####"
        END IF
    ELSE
        LET m_message = "Delete cancelled"
    END IF
END FUNCTION