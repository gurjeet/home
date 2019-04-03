#/bin/bash

set -e

# Code to download the list of all potentially available domains on park.io

cd /tmp
rm page*.json auctions.json
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
cat page*.json | jq -Cr '.domains[] | .name' | grep -E '^([a-z]){0,2}\..+$' | sed 's"\(.*\)"https://park.io/domains/view/\1"' | xargs -n1 open

# cat auctions.json | jq -Cr '.auctions[] | .name' | grep -E '^([a-z]){0,2}\..+$' | less
cat auctions.json | jq -Cr '.auctions[] | .name' | grep -E '^([a-z]){0,2}\..+$' | sed 's"\(.*\)"https://park.io/auctions/view/\1"' | xargs -n1 open

open https://park.io/auctions/view/college.ly
open https://park.io/auctions/view/asset.ly
open https://park.io/auctions/view/ubuntu.io
open https://park.io/auctions/view/authorise.me

# cat page*.json | jq -Cr '.domains[] | .name' | less

# https://park.io/domains/view/XXXX

