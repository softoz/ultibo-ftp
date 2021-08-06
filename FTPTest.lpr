program FTPTest;

{$mode objfpc}{$H+}

{$define use_tftp}    // if PI not connected to LAN and set for DHCP then remove this

uses
  RaspberryPi3,
  GlobalConfig,
  GlobalConst,
  GlobalTypes,
  Platform,
  Threads,
  SysUtils,
  Classes,
  Ultibo,
  Console,
  uLog,
{$ifdef use_tftp}
  uTFTP,
{$endif}
  Winsock2, uFTP
  { Add additional units here };

var
  Console1, Console2, Console3 : TWindowHandle;
  IPAddress : string;
  FTPServer : TFTPserver;
  uc : TUserCred;

procedure Log1 (s : string);
begin
  ConsoleWindowWriteLn (Console1, s);
end;

procedure Log2 (s : string);
begin
  ConsoleWindowWriteLn (Console2, s);
end;

procedure Log3 (s : string);
begin
  ConsoleWindowWriteLn (Console3, s);
end;

procedure Msg2 (Sender : TObject; s : string);
begin
  Log2 ('TFTP - ' + s);
end;

function WaitForIPComplete : string;
var
  TCP : TWinsock2TCPClient;
begin
  TCP := TWinsock2TCPClient.Create;
  Result := TCP.LocalAddress;
  if (Result = '') or (Result = '0.0.0.0') or (Result = '255.255.255.255') then
    begin
      while (Result = '') or (Result = '0.0.0.0') or (Result = '255.255.255.255') do
        begin
          sleep (1000);
          Result := TCP.LocalAddress;
        end;
    end;
  TCP.Free;
end;

procedure WaitForSDDrive;
begin
  while not DirectoryExists ('C:\') do sleep (500);
end;

begin
  Console1 := ConsoleWindowCreate (ConsoleDeviceGetDefault, CONSOLE_POSITION_LEFT, true);
  Console2 := ConsoleWindowCreate (ConsoleDeviceGetDefault, CONSOLE_POSITION_TOPRIGHT, false);
  Console3 := ConsoleWindowCreate (ConsoleDeviceGetDefault, CONSOLE_POSITION_BOTTOMRIGHT, false);
  SetLogProc (@Log1);
  Log1 ('FTP Server TEST (pjde Dec 2017).');
  WaitForSDDrive;
  Log1 ('SD Drive ready.');
  IPAddress := WaitForIPComplete;
  Log1 ('Network ready.');

{$ifdef use_tftp}
  Log2 ('TFTP - Enabled.');
  Log2 ('TFTP - Syntax "tftp -i ' + IPAddress + ' PUT kernel7.img"');
  SetOnMsg (@Msg2);

{$endif}

  Log2 ('');
  // create FTP Server
  FTPServer := TFTPServer.Create;
  // add user accounts and options
  uc := FTPServer.AddUser ('admin', 'admin', 'C:\');
  uc.Options := [foCanAddFolder, foCanChangeFolder, foCanDelete, foCanDeleteFolder, foRebootOnImg];
  uc := FTPServer.AddUser ('user', '', 'C:\');
  uc.Options := [foRebootOnImg];
  uc := FTPServer.AddUser ('anonymous', '', 'C:\');
  uc.Options := [foRebootOnImg];
  // use standard FTP port
  FTPServer.BoundPort := 21;
  // set it running
  FTPServer.Active := true;
  Log3 ('Open Windows Explorer and enter "ftp://' + IPAddress + '".');
  Log3 ('Right Click within Windows Explorer and select "Login as.." to change user.');
  Log3 ('Tested on Windows 7.');
  Log3 ('');
  ThreadHalt (0);
end.

