#/bin/bash

set -e

# Code to download the list of all potentially available domains on park.io

cd /tmp
rm -f page*.json auctions.json
per_page_limit=10000

wget -O header.json https://park.io/domains/index/all/page:1.json?limit=1
num_domains=$(cat header.json | jq '.count')
num_pages=$(echo "$num_domains / $per_page_limit + 1" | bc)

for (( i = 1; i <= $num_pages; ++i )); do
    wget -O page$i.json "https://park.io/domains/index/all/page:$i.json?limit=$per_page_limit";
    sleep 3;
done;

wget -O auctions.json https://park.io/auctions.json

# cat page*.json | jq -Cr '.domains[] | .name' | grep -E '^([a-z]){0,2}\..+$' | less
cat page*.json | jq -Cr '.domains[] | .name' | grep -E '^([a-z0-9]){0,2}\..+$' | grep -v '\d' | sed 's"\(.*\)"https://park.io/domains/view/\1"' | xargs --no-run-if-empty -n1 open
cat page*.json | jq -Cr '.domains[] | .name' | grep -E '^([a-z0-9]){0,2}\..+$' | grep '\d' | sed 's"\(.*\)"https://park.io/domains/view/\1"' | xargs --no-run-if-empty -n1 open

# cat auctions.json | jq -Cr '.auctions[] | .name' | grep -E '^([a-z]){0,2}\..+$' | less
cat auctions.json | jq -Cr '.auctions[] | .name' | grep -E '^([a-z0-9]){0,2}\..+$' | grep -v '\d' | sed 's"\(.*\)"https://park.io/auctions/view/\1"' | xargs --no-run-if-empty -n1 open
cat auctions.json | jq -Cr '.auctions[] | .name' | grep -E '^([a-z0-9]){0,2}\..+$' | grep '\d' | sed 's"\(.*\)"https://park.io/auctions/view/\1"' | xargs --no-run-if-empty -n1 open

CUSTOM_DOMAINS=" "
for D in $CUSTOM_DOMAINS; do
    open https://park.io/domains/view/$D
done

CUSTOM_AUCTIONS=" svelte.io toyota.io earth.vc"
for D in $CUSTOM_AUCTIONS; do
    open https://park.io/auctions/view/$D
done

open 'https://park.io/domains/view/7zip.info'

DayOfMonthWithSuffix() {
    # The first param is the offset from current date.
    #
    # %e emits a leading space for single-digit numbers. Strip it using echo
    # command.
    #
    # The below commands assume GNU date utility
    local dom=$(echo $(date --date "$1" +%e))

    local suffix=$(
    case "$dom" in
        (1|21|31) echo "st";;
        (2|22)    echo "nd";;
        (3|23)    echo "rd";;
        (*)       echo "th";;
    esac)

    # Emit day-of-month with the suffix
    echo "$dom$suffix"
}

# Search, on Google, only for those appraised domains that are to be auctioned today
open 'https://www.google.com/search?q=site:park.io+"appraised+value"+"End Date"+"'"$(date +'%b '$(DayOfMonthWithSuffix)' %Y')"'"'
open 'https://www.google.com/search?q=site:park.io+"appraised+value"+"End Date"+"'"$(date +'%b '$(DayOfMonthWithSuffix '+1 day')' %Y')"'"'

