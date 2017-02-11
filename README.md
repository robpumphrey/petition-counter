# petition-counter

A simple script to collect signatures counts from 
https://petition.parliament.uk/petitions/ and present in a chart
using the [plot.ly Javascript library](https://ploy.ly).

To collect stats from petition 171928 every 60 seconds run:
```
petition-counter.sh -p 171928 -i 60
```

This will create 2 files, 171928.html and 171928.json. The html file contains the presentation, and the json file contains
the collected data. The script will ensure the json file is valid and you can look at the data as soon as you have collected
more than 2 data points. Ctrl-C to stop the script. Re-run to collect more data. You can restart as you like and change the
sample interval.

Also see [the petition-counter sample dataset](https://rcp.certus-tech.com/d/171928.html) from the petition
[Prevent Donald Trump from making a State Visit to the United Kingdom](https://petition.parliament.uk/petitions/171928).