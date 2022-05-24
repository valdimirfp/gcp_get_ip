#!/bin/bash

# получаем список проектов
gcp_projects=$(gcloud projects list --format="get(PROJECT_ID)")
#echo $gcp_projects

#получаем список зон заведенных в проекты 
gcp_zones=$(gcloud projects list --format="get(PROJECT_ID)" | while read pr; do gcloud dns managed-zones list --project $pr -q 2> /dev/null | grep -v DESCRIP | awk '{print $1}' ; done)
#echo $gcp_zones

# получаем список А записей на основании списка проектов и зон
for pr in $gcp_projects
do
 for zn in $gcp_zones
 do
   gcloud dns record-sets list --zone $zn --filter TYPE=A --project $pr -q 2> /dev/null | awk '{print $4}' >> gcp_ip_A_dns_"$(date +"%d-%m-%Y")".txt
 done
done

# получаем список внешних адресов
gcloud projects list --format="get(PROJECT_ID)" | while read pr; do gcloud compute addresses list --project $pr -q 2> /dev/null| awk '/EXTERNAL/ && !/RESERVED/ {print $2 }' ; done >> gcp_ip_A_dns_*

# удалить повторы и строки начинающиеся с 10
awk '!x[$0]++' gcp_ip_A_dns_* | sed '/^10/d' >> gcp_ip_A_dns_"$(date +"%d-%m-%Y")"_SORT.txt

echo "END script"
