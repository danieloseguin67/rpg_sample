      // Music Organizer Program
      // Connects to SQL Server to manage Music table
      
      ctl-opt dftactgrp(*no) actgrp(*caller) main(main) bnddir('QC2LE');
      
      // Copy display file
      copy musicdspf,suffix(fmt);
      
      // SQL communication area
      exec sql include sqlca;
      
      // Global variables
      dcl-s gMsgText varchar(78);
      dcl-s gAction char(1);
      dcl-s gExit ind inz(*off);
      dcl-s gConnected ind inz(*off);
      
      // Subfile variables
      dcl-s sfRRN packed(4: 0);
      dcl-s sfOption char(1);
      dcl-s sfSongId packed(4: 0);
      dcl-s sfSongName char(50);
      dcl-s sfAuthor char(30);
      
      // Detail screen variables
      dcl-s detSongId packed(4: 0);
      dcl-s detSongName varchar(200);
      dcl-s detSongDesc varchar(500);
      dcl-s detSongCat varchar(100);
      dcl-s detSongLink varchar(500);
      dcl-s detSongAuth varchar(200);
      dcl-s detCreatedBy varchar(100);
      dcl-s detCreatedDate date;
      
      // Connection string variables
      dcl-s connString varchar(500);
      
      //------------------------------------------------------------------
      // Main procedure
      //------------------------------------------------------------------
      dcl-proc main;
        
        monitor;
          connectToDatabase();
          loadMusicList();
          
          dow not gExit;
            displaySubfile();
            processUserActions();
          enddo;
          
          disconnectFromDatabase();
          
        on-error;
          gMsgText = 'Program error occurred. Press F3 to exit.';
          displaySubfile();
        endmon;
        
      end-proc;
      
      //------------------------------------------------------------------
      // Connect to SQL Server database
      //------------------------------------------------------------------
      dcl-proc connectToDatabase;
        
        monitor;
          // Connect to SQL Server
          connString = 'Driver={ODBC Driver 17 for SQL Server};'
                     + 'Server=localhost;'
                     + 'Database=organiste;'
                     + 'UID=user;'
                     + 'PWD=password;'
                     + 'Trusted_Connection=no;';
          
          exec sql connect to organiste user 'user' using 'password';
          
          if sqlcode <> 0;
            gMsgText = 'Connection failed. SQLCODE: ' + %char(sqlcode);
          else;
            gConnected = *on;
            gMsgText = 'Connected to organiste database successfully.';
          endif;
          
        on-error;
          gMsgText = 'Error connecting to database.';
        endmon;
        
      end-proc;
      
      //------------------------------------------------------------------
      // Disconnect from database
      //------------------------------------------------------------------
      dcl-proc disconnectFromDatabase;
        
        if gConnected;
          exec sql disconnect organiste;
          gConnected = *off;
        endif;
        
      end-proc;
      
      //------------------------------------------------------------------
      // Load music list into subfile
      //------------------------------------------------------------------
      dcl-proc loadMusicList;
        
        dcl-s tempId char(4);
        dcl-s tempSongId packed(4: 0);
        dcl-s tempName varchar(200);
        dcl-s tempAuthor varchar(200);
        
        monitor;
          // Clear subfile
          *in35 = *on;
          write sflctl;
          *in35 = *off;
          
          sfRRN = 0;
          
          // Load data from Music table
          exec sql declare c1 cursor for
            select SongId, SongName, coalesce(SongAuthor, '') as SongAuthor
            from Music
            order by SongId;
          
          exec sql open c1;
          
          if sqlcode = 0;
            exec sql fetch c1 into :tempSongId, :tempName, :tempAuthor;
            
            dow sqlcode = 0;
              sfRRN += 1;
              clear sfl;
              sfOption = ' ';
              sfSongId = tempSongId;
              sfSongName = %subst(tempName : 1 : 50);
              sfAuthor = %subst(tempAuthor : 1 : 30);
              
              write sfl;
              
              exec sql fetch c1 into :tempSongId, :tempName, :tempAuthor;
            enddo;
            
            exec sql close c1;
            
            if sfRRN = 0;
              gMsgText = 'No music records found.';
            else;
              gMsgText = %char(sfRRN) + ' music records loaded.';
            endif;
          else;
            gMsgText = 'Error loading music list. SQLCODE: ' + %char(sqlcode);
          endif;
          
        on-error;
          gMsgText = 'Error occurred while loading music list.';
        endmon;
        
      end-proc;
      
      //------------------------------------------------------------------
      // Display subfile screen
      //------------------------------------------------------------------
      dcl-proc displaySubfile;
        
        msgctl = gMsgText;
        user = %trim(%userid());
        *in64 = *off; // Show message
        
        exfmt sflctl;
        
        *in64 = *on;  // Hide message
        
        // Check function keys
        if *in03;  // F3 = Exit
          gExit = *on;
        endif;
        
      end-proc;
      
      //------------------------------------------------------------------
      // Process user actions from subfile
      //------------------------------------------------------------------
      dcl-proc processUserActions;
        
        dcl-s i packed(4: 0);
        
        // Check function keys first
        if *in05;  // F5 = Refresh
          loadMusicList();
          return;
        endif;
        
        if *in06;  // F6 = Add
          addNewSong();
          return;
        endif;
        
        if *in12;  // F12 = Cancel
          gMsgText = 'Operation cancelled.';
          return;
        endif;
        
        // Process subfile options
        readc sfl;
        
        dow not %eof();
          if sfOption <> ' ';
            select;
              when sfOption = '2';  // Change
                editSong(sfSongId);
              when sfOption = '4';  // Delete
                deleteSong(sfSongId);
              when sfOption = '5';  // Display
                displaySong(sfSongId);
              when sfOption = '9';  // Add new (alternative)
                addNewSong();
              other;
                gMsgText = 'Invalid option: ' + sfOption;
            endsl;
            
            // Clear the option after processing
            sfOption = ' ';
            update sfl;
          endif;
          
          readc sfl;
        enddo;
        
      end-proc;
      
      //------------------------------------------------------------------
      // Add new song
      //------------------------------------------------------------------
      dcl-proc addNewSong;
        
        dcl-s newId char(4);
        dcl-s exit ind inz(*off);
        
        // Clear detail fields
        clear musicdetail;
        detSongId = 0;
        detCreatedDate = %date();
        detCreatedBy = %trim(%userid());
        
        dow not exit;
          msg = 'Enter new song details. Press Enter to save.';
          exfmt musicdetail;
          
          if *in03 or *in12;  // F3 or F12 = Cancel
            exit = *on;
            gMsgText = 'Add cancelled.';
          else;
            // Generate new ID
            exec sql select coalesce(max(cast(Id as int)), 0) + 1 
                     into :detSongId
                     from Music;
            
            newId = %editc(detSongId : 'Z');
            
            monitor;
              exec sql insert into Music 
                (Id, SongName, SongDescription, SongCategory, SongLink, SongAuthor, CreatedDate, CreatedBy)
                values (:newId, :detSongName, :detSongDesc, :detSongCat, :detSongLink, :detSongAuth, :detCreatedDate, :detCreatedBy);
              
              if sqlcode = 0;
                gMsgText = 'Song added successfully.';
                loadMusicList();
                exit = *on;
              else;
                msg = 'Error adding song. SQLCODE: ' + %char(sqlcode);
              endif;
              
            on-error;
              msg = 'Error occurred while adding song.';
            endmon;
          endif;
        enddo;
        
      end-proc;
      
      //------------------------------------------------------------------
      // Edit existing song
      //------------------------------------------------------------------
      dcl-proc editSong;
        dcl-pi *n;
          pSongId packed(4: 0) const;
        end-pi;
        
        dcl-s exit ind inz(*off);
        dcl-s recordId char(4);
        
        // Load song details
        exec sql select Id, SongName, coalesce(SongDescription, ''), coalesce(SongCategory, ''),
                        coalesce(SongLink, ''), coalesce(SongAuthor, ''), coalesce(CreatedBy, '')
                 into :recordId, :detSongName, :detSongDesc, :detSongCat, 
                      :detSongLink, :detSongAuth, :detCreatedBy
                 from Music
                 where SongId = :pSongId;
        
        if sqlcode <> 0;
          gMsgText = 'Song not found.';
          return;
        endif;
        
        detSongId = pSongId;
        
        dow not exit;
          msg = 'Change song details. Press Enter to save.';
          exfmt musicdetail;
          
          if *in03 or *in12;  // F3 or F12 = Cancel
            exit = *on;
            gMsgText = 'Edit cancelled.';
          else;
            monitor;
              exec sql update Music 
                set SongName = :detSongName,
                    SongDescription = :detSongDesc,
                    SongCategory = :detSongCat,
                    SongLink = :detSongLink,
                    SongAuthor = :detSongAuth
                where Id = :recordId;
              
              if sqlcode = 0;
                gMsgText = 'Song updated successfully.';
                loadMusicList();
                exit = *on;
              else;
                msg = 'Error updating song. SQLCODE: ' + %char(sqlcode);
              endif;
              
            on-error;
              msg = 'Error occurred while updating song.';
            endmon;
          endif;
        enddo;
        
      end-proc;
      
      //------------------------------------------------------------------
      // Display song details (read-only)
      //------------------------------------------------------------------
      dcl-proc displaySong;
        dcl-pi *n;
          pSongId packed(4: 0) const;
        end-pi;
        
        dcl-s recordId char(4);
        
        // Load song details
        exec sql select Id, SongName, coalesce(SongDescription, ''), coalesce(SongCategory, ''),
                        coalesce(SongLink, ''), coalesce(SongAuthor, ''), coalesce(CreatedBy, '')
                 into :recordId, :detSongName, :detSongDesc, :detSongCat, 
                      :detSongLink, :detSongAuth, :detCreatedBy
                 from Music
                 where SongId = :pSongId;
        
        if sqlcode <> 0;
          gMsgText = 'Song not found.';
          return;
        endif;
        
        detSongId = pSongId;
        msg = 'Song details (display only). Press Enter to return.';
        exfmt musicdetail;
        
      end-proc;
      
      //------------------------------------------------------------------
      // Delete song
      //------------------------------------------------------------------
      dcl-proc deleteSong;
        dcl-pi *n;
          pSongId packed(4: 0) const;
        end-pi;
        
        dcl-s recordId char(4);
        dcl-s songName varchar(200);
        
        // Get song name for confirmation
        exec sql select Id, SongName
                 into :recordId, :songName
                 from Music
                 where SongId = :pSongId;
        
        if sqlcode <> 0;
          gMsgText = 'Song not found.';
          return;
        endif;
        
        // For simplicity, we'll just delete without confirmation screen
        // In a real application, you'd want a confirmation dialog
        monitor;
          exec sql delete from Music where Id = :recordId;
          
          if sqlcode = 0;
            gMsgText = 'Song "' + %trim(songName) + '" deleted successfully.';
            loadMusicList();
          else;
            gMsgText = 'Error deleting song. SQLCODE: ' + %char(sqlcode);
          endif;
          
        on-error;
          gMsgText = 'Error occurred while deleting song.';
        endmon;
        
      end-proc;