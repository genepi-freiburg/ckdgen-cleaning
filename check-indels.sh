zcat HRC.r1-1.GRCh37.wgs.mac5.sites.tab.gz | awk '{ if (length($4) > 1 || length($5) > 1) { print $1, $2, $8; } }'

