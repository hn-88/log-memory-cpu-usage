# log-memory-cpu-usage
Log memory and CPU usage to a CSV file every minute on *nix.

## Usage
```
chmod +x log_usage.sh
./log_usage.sh                  # logs to ~/system_usage.csv
./log_usage.sh /path/to/my.csv  # or choose your own file
```
To keep it running after you close the terminal, use `nohup ./log_usage.sh &` or run it inside `tmux`/`screen`. If using `nohup`, use `pkill -f log_usage.sh` to stop it.

A full day is about 60 KB and a year is roughly 22 MB, so you could leave it running for a long time without any disk space concern. The main practical limit would be the spreadsheet: Google Sheets handles a year of per-minute data (about 525,000 rows) poorly, so for long runs you'd want to import only a slice of it or start a new file periodically.
