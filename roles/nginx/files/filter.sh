#!/bin/bash

for f in $@;
do
        echo $f;
        for host in $(grep -iE '\x|hack|root|config|user|auth|login|page|robot|admin|webfig|manager' $f | cut -f1 -d\  | sort -u | grep -vE '188\.244\.6\.41|192\.168\.8\.|127\.0\.0\.1|81\.88\.216\.249');
        do
                if grep -Fq $host /etc/nginx/acl/blacklist.conf; then
                        echo YES > /dev/null;
                else
                        name='unknown';
                        host $host &> /dev/null;
                        if [ $? -ne 0 ]; then
                                name='filtered by regexp';
                        else
                                name=$(host $host | head -n1 | awk '{print $NF}');
                        fi;
                        echo -e "  - ${host}/32 \t# $name";
                fi;
        done;
done
