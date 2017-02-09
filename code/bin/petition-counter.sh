#!/bin/bash
INTERVAL=1800
usage() {
cat <<__end_of_usage__
####################################################################
##
## Count signatures in a petition.parliament.uk petition
##
##  -p <petition number>
##  -i <interval in seconds> defaults to ${INTERVAL}
##  -H show this message
## 
## https://github.com/robpumphrey/petition-counter
## 
####################################################################
__end_of_usage__
}

PETITION=

# get args
while getopts "p:i:H" argname; do
  case $argname in
    p) PETITION=$OPTARG ;;
    i) INTERVAL=$OPTARG ;;
    H) usage
      exit 0;;
    :) error "Option '$OPTARG' requires an argument.";;
    ?) error "Unknown option: $OPTARG";;
    *) error;;
  esac
done

# check args
if [ "${PETITION}" = "" ]; then
  usage
  echo ""
  echo "Need to specify a petition with -p <petition number>"
  exit 1
fi
if [ "${INTERVAL}" = "" ]; then
  usage
  echo ""
  echo "Need to specify a petition with -p <petition number>"
  exit 1
fi
# check petition exists
if ! curl -s -I "https://petition.parliament.uk/petitions/${PETITION}/count.json" | grep -q "HTTP/1.1 200 OK" ; then
  echo "No such petition ${PETITION}"
  echo "Check https://petition.parliament.uk/petitions/${PETITION}"
  exit 1
fi

# Create html file if required
if [ ! -e ${PETITION}.html ]; then
cat <<__endofhtml__ > ${PETITION}.html
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html lang="en">
<head>
<script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
<script type="text/javascript" src="${PETITION}.json"></script>
</head>
<body>
<h2>Data for <a href="https://petition.parliament.uk/petitions/${PETITION}">Petition ${PETITION}</a></h2>
<div id="m2" style="width: 1000px; height: 400px;"></div>
<div id="dm2" style="width: 1000px; height: 400px;"></div>
<script>
function toDateTime(secs) {
    var t = new Date(1970, 0, 1); // Epoch
    t.setSeconds(secs);
    return t;
}
var x = [];
var y = [];
var dy = [];
for(var i=0; i< data.length; i++) {
  x.push(toDateTime(data[i].date));
  y.push(data[i].signature_count);
  if ( i > 0 ) {
    var interval = data[i].date - data[i - 1].date
    dy.push (3600*(data[i].signature_count - data[i - 1].signature_count)/interval);
  } else {
    dy.push (0);
  }
}
var layout = {
  xaxis: { type: 'date', title: 'Date' },
  yaxis: { title: 'Petition Count' }
};
var dlayout = {
  xaxis: { type: 'date', title: 'Date' },
  yaxis: { title: 'Sigs/Hour' }
};
var m2 = [{x: x, y: y, type: 'line'}];
Plotly.newPlot('m2', m2, layout);
var dm2 = [{x: x,y: dy,type: 'line'}];
Plotly.newPlot('dm2', dm2, dlayout);
</script>
</body>
</html>
__endofhtml__
fi

sep=","
if [ ! -e ${PETITION}.json ]; then
  echo "var data = [" > ${PETITION}.json
  echo "];" >> ${PETITION}.json
  sep=""
fi

while [ 1 = 1 ]; do
  d=`date +%s`
  json=`curl -s "https://petition.parliament.uk/petitions/${PETITION}/count.json" | sed 's/}/, "date":'$d'}/'`
  sed -i '$i'"${sep}${json}" ${PETITION}.json
  sep=","
  sleep ${INTERVAL}
done
