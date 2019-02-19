#!/bin/bash
# pre-req, xml_split, curl, perl, sed, zip
# install on amazon-ami yum install perl-XML-Twig
# install on mac os x
#       sudo perl -MCPAN -e shell
#       install XML::Twig
#
# MODIFY VARIABLES BELOW

URL=https://ams.americanarchive.org/xml/pbcore/key/b5f3288f3c6b6274c3455ec16a2bb67a/digitized/1/modified_date/20130601
PAGE=1
TOTAL_PAGES=10
BATCH_SIZE=10
OUTPUT=`pwd`/output/

#                     #
# DO NOT MODIFY BELOW #
#                     #

mkdir -p $OUTPUT
batch_number=0

for (( page=$PAGE; page<=$TOTAL_PAGES; page++ ))
do
        echo "Processing Page $page"
        mkdir -p ./tmp
        url=$URL/page/$page
        curl -s $url > ./tmp/tmp.xml
        cd ./tmp
        xml_split -c pbcoreDescriptionDocument tmp.xml
        mkdir -p ./split_out
        batch_item=0
        for file in $(ls tmp-*.xml)
        do
                #echo "processing#$file"
                perl -pe "s/cpb-aacip\/([0-9]+)-(.*?)</cpb-aacip_600-\2</g" $file > ./split_out/tmp_out.xml
                doc_id=`perl -0777 -ne 'print $1 if /(cpb-aacip_600-.*?)</s' ./split_out/tmp_out.xml`
                #echo "found docid#$doc_id"
                mv $file ./split_out/$doc_id.xml
                ((batch_item++))
                if [ $(( batch_item % BATCH_SIZE )) -eq 0 ]
                then
                        ((batch_number++))
                        batch="batch-$batch_number.zip"
                        cd ./split_out
                        zip --quiet $batch cpb-aacip_600-*.xml
                        cp -v $batch $OUTPUT
                        cd ../
                        rm -Rf ./split_out
                        mkdir ./split_out
                        echo "Processed batch#$batch_number"
                fi
        done
        echo "Processed Page#$page with items#$batch_item"
done