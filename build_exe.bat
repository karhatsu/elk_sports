@ECHO off
rem Builds two hirviurheilu.zip files containing the exe file and the SQLite3 database file (only in the second zip).
rem Dependencies:
rem - ocra: gem install ocra
rem - 7za.exe: http://7-zip.org/download.html (the command line version)

@ECHO on
SET RAILS_ENV=winoffline-prod
SET BUNDLE_GEMFILE=Gemfile-windows
CALL bundle exec rake elk_sports:offline:create_db
CALL del log\*.log
CALL move db\offline-dev.sqlite3 ..
SET RAILS_ENV=
CALL move bin\wkhtmltopdf-amd64 ..
CALL cd ..
CALL ocra elk_sports\start.rb elk_sports --no-dep-run --add-all-core --gemfile elk_sports\Gemfile-windows --gem-all --dll sqlite3.dll --dll ssleay32-1.0.0-msvcrt.dll --output hirviurheilu.exe --icon elk_sports\public\favicon.ico --chdir-first --no-lzma --innosetup elk_sports\hirviurheilu-offline.iss -- server
CALL 7za a HirviurheiluOffline-asennus.zip Output\HirviurheiluOffline-asennus.exe
CALL move wkhtmltopdf-amd64 elk_sports\bin
CALL move offline-dev.sqlite3 elk_sports\db
CALL cd elk_sports
