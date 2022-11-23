#!/bin/bash
export VERSION="1.7.0"

### Variables, change as needed
### Default Options overwritten by opts/args
CERTHOME='/ifs/data/Isilon_Support/.SSLCERTS' 
DEST=""                                         # Can be specified here
PASSWORD=""
LOGFILE="$0.log"
COUNTRY="US"      # Testing Use
STATE="Unk"       # Testing Use
LOCALITY="Unk"    # Testing Use
ORG="Unk"         # Testing Use
DAYS=3650         # Certificate expirate length in days, default 10 years
SSHOPTIONS="-o PreferredAuthentications=publickey" #-o StrictHostKeyChecking=no 
PAYLOAD="/tmp/payload"
#https://mywiki.wooledge.org/BashFAQ/050
############ CHANGE NOTHING BELOW THIS LINE ############
# Known Issues
# - Cannot validate the cert gen input fields, to many reasons why invalid entries may fail, easiest is to use default values
# - Does not handle individual policy encryption, only whole cluster
# - ssh commands with pipes is somewhat fragile and difficult to check stdout/err/exit on, see TODOs
###########
# TODOs
#
# add support for -r argument
# change all ssh commands to deployed scripts to capture stdout/stderr/exitcode
################################################################
DELAY=0

# Place header in logfile so we know where we started this run
echo "################################################################" >> $LOGFILE
echo "  DATE  -  TIME     : Line# : Message" >> $LOGFILE
echo "################################################################" >> $LOGFILE

############ CHANGE NOTHING BELOW THIS LINE ############
### Functions
delay () { 
  sleep $DELAY 
  }

localcmd () {
  logit "LOCALCMD: $CMD" $LINENO
  RESULT=$($CMD 2>&1)
  RETCODE=$?
  logit "Result: $RETCODE - $RESULT" $LINENO
  return $RETCODE
}

remotecmd () {
  logit "SSHCMD: ssh root@$DEST $CMD 2>&1" $LINENO
  echo $CMD >/tmp/payload
  scp -q /tmp/payload root@$DEST:
  RESULT=$(ssh root@$DEST bash payload 2>&1)
  RETCODE=$?
  logit "Result: $RETCODE - $RESULT" $LINENO
  return $RETCODE
}

clear_cmd () {
  CMD=""
}
clear_result () {
  RESULT=""
}

check_result () {
  if [[ "$RESULT" == "$1" ]]; then
    logit "Result Good" $LINENO
  else
    die "Error in Result: $RESULT" $LINENO
  fi
}

check_result_not_empty () {
  [[ "$RESULT" == "" ]] && die "Empty Result" $LINENO
}

clean_payload () {
  [[ ! -e "$PAYLOAD" ]] && return
  rm -f "$PAYLOAD" die "Error Removing Payload: $PAYLOAD" $LINENO
  ssh $SSHOPTIONS root@$DEST rm -f "$PAYLOAD" && return || die "Error Removing $DEST:$PAYLOAD" $LINENO
  }

check_payload () {
  [[ $(cat "$PAYLOAD") == "$1" ]] && logit "Payload Matches" $LINENO || die "Mismatch in $PAYLOAD" $LINENO
}

deploy_payload () {
  logit "PAYLOAD: $1" $LINENO
  echo -n "$JSON" > "$PAYLOAD"
  check_payload "$JSON" && logit "Success deploying payload" $LINENO || die "Error Deploying payload" $LINENO
  logit "Deploying $PAYLOAD to $DEST" $LINENO
  RESULT=$(scp /tmp/payload $DEST:$PAYLOAD 2>&1)
  [[ $? == 0 ]] && logit "Success Deploying $PAYLOAD" $LINENO || die "Error Deploying Payload: $RESULT"
}

logit () {
    timestamp=$(date +%y/%m/%d-%H:%M:%S)
    printf "%-20s:%-7s:%-50s\n" "$timestamp" "  $2" " $1" >>$LOGFILE
}

die () {
    echo "$1"
    logit "$1" $2
    exit 1
}

check_onefs_ver () {
  # Check OneFS Version >= 8.2.2
  logit "checking OneFS Version" $LINENO
  vers=$(echo $1 | sed 's/v//g')
  maj=$(echo $vers | awk -F \. '{print$1}')
  min=$(echo $vers | awk -F \. '{print$2}')
  sub=$(echo $vers | awk -F \. '{print$3}')
  logit "Source Version: $vers : -$maj-$min-$sub-" $LINENO
  if [ "$maj" -lt 8 ]; then 
    die "OneFS 8.2.2+ Required" $LINENO
  else
    logit "$maj >= 8" $LINENO
  fi

  [ "$maj" -eq 8 ] && [ "$min" -lt 2 ] && die "OneFS 8.2.2+ Required" || logit "$maj = 8 : $min < 2" $LINENO
  [ "$maj" -eq 8 ] && [ "$min" -eq 2 ] && [ "$sub" -lt 2 ] && die "OneFS 8.2.2+ Required" || logit "$maj = 8 : $min = 2 : $sub < 2" $LINENO

}

check_time_sync () {
  #Test Date for synchronization
  TIME=$(date +%s)
  DTIME=$(ssh $SSHOPTIONS root@"$DEST" date +%s)
  logit "Source Time: $TIME" $LINENO
  logit "Dest Time: $DTIME" $LINENO
  if [[ $(($TIME-$DTIME)) -gt 10 ]]; then
      die "Time out of Sync, configure NTP or AD auth to sync before continuing" $LINENO
  fi

}

genssh () {
    #Gen Passwordless ssh keys for target cluster
    if [[ ! -f /root/.ssh/id_rsa.pub ]]; then
        logit "No ssh keys, generating" $LINENO
        RESULT=$(ssh-keygen -t rsa -P "" -f /root/.ssh/id_rsa 2>&1)
        logit "$RESULT" $LINENO
    fi

    echo "Attempting to connect to the destination cluster, accept the fingerprint (type yes) and enter the root password when prompted"

    # Set var for ssh pub key to be added to target host
    keystring=$(cat /root/.ssh/id_rsa.pub)
    logit "Keystring: $keystring" $LINENO
  
    logit "Setup passwordless ssh" $LINENO
    # Has to be done in one command, ignoring errors, so user only has to enter password once
    CMD="mkdir /root/.ssh 2>/dev/null; chmod 600 /root/.ssh; echo \"$keystring\" >> /root/.ssh/authorized_keys"
    logit "REMOTE COMMAND: $CMD" $LINENO
    RESULT=$(ssh root@$DEST "$CMD")
    logit "RESULT: $RESULT" $LINENO
    check_result ""
    clear_result && clear_cmd

    # If performed correctly no second password required.
    logit "Check for key in authorized_keys on target" $LINENO
    CMD="cat /root/.ssh/authorized_keys | grep `hostname` >/dev/null && echo success"
    remotecmd
    check_result "success"
    clear_result && clear_cmd
}

printeula () {
    logit "Presenting EULA for acceptance"  $LINENO
    echo "Copyright (c) 2022, Dell Inc."
    echo "All rights reserved."
    echo
    echo "Redistribution and use in source and binary forms, with or without"
    echo "modification, are permitted provided that the following conditions are met:"
    echo 
    echo "    * Redistributions of source code must retain the above copyright"
    echo "    notice, this list of conditions and the following disclaimer."
    echo "    * Redistributions in binary form must reproduce the above copyright"
    echo "    notice, this list of conditions and the following disclaimer in the"
    echo "    documentation and/or other materials provided with the distribution."
    echo "    * Neither the name of the Dell, Inc. nor the"
    echo "    names of its contributors may be used to endorse or promote products"
    echo "    derived from this software without specific prior written permission."
    echo
    echo 'THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND'
    echo 'ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED'
    echo 'WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE'
    echo 'DISCLAIMED. IN NO EVENT SHALL Dell, Inc. BE LIABLE FOR ANY DIRECT, INDIRECT,'
    echo 'INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT'
    echo 'LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR'
    echo 'PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF'
    echo 'LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE'
    echo 'OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF'
    echo 'ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.'
    echo
    echo 'Type "ACCEPT" to accept this license and proceed with the script: '
    read response
    [[ "$response" == "ACCEPT" ]] && logit "eula accepted" $LINENO || die "eula rejected, aborting" $LINENO
}

phase1 () {
    # We need a central home to store certificates
    # /ifs/data/Isilon_Support path chosen for longevity
    logit "Phase 1 - Source Certificate Generation" $LINENO
    logit "---------------------------------------" $LINENO
    # Create $CERTHOME Dir
    logit "Step 1: Create $CERTHOME dir" $LINENO
    RESULT=$(mkdir -p $CERTHOME 2>&1)
    [[ $? ]] || die "ERROR: $? - $RESULT" $LINENO && logit "Success: $? - $RESULT" $LINENO
    clear_result
    logit "Step 1: $CERTHOME created successfully"  $LINENO

    # Set Permissions on $CERTHOME
    logit "---------------------------------------" $LINENO
    logit "Step 2: Set Permissions on $CERTHOME" $LINENO
    RESULT=$(chmod -R 600 $CERTHOME 2>&1)
    [[ $? ]] || die "ERROR: $? - $RESULT" $LINENO && logit "Success: $? - $RESULT" $LINENO
    clear_result
    logit "Step 2: permissions set successfully" $LINENO

    # Generate root CA key    
    # Root Key
    logit "---------------------------------------" $LINENO
    logit "Step 3: Generate root CA key" $LINENO
    RESULT=$(openssl genrsa -aes256 -passout pass:$PASSWORD -out $CERTHOME/rootCA.key 4096 2>&1)
    [[ $? ]] || die "ERROR: $? - $RESULT" $LINENO && logit "Success: $? - $RESULT" $LINENO
    clear_result
    logit "Step 3: rootCA.key created successfully"  $LINENO
    delay

    # Root Certificate
    logit "---------------------------------------" $LINENO
    logit "Step 4: Generate root CA certificate" $LINENO
    RESULT=$(openssl req -x509 -new -passin pass:$PASSWORD -key $CERTHOME/rootCA.key -subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORG/CN=ROOTCA" -sha256 -days $DAYS -out $CERTHOME/rootCA.pem 2>&1) 
    [[ $? ]] || die "ERROR: $? - $RESULT" $LINENO && logit "Success: $? - $RESULT" $LINENO
    logit "Step 4:  rootCA.pem created successfully"  $LINENO
    delay

    # Source Cluster Certificate
    logit "---------------------------------------" $LINENO
    logit "Step 5: Generate source cluster certificate" $LINENO
    RESULT=$(openssl genrsa -aes256 -passout pass:$PASSWORD -out $CERTHOME/source_cluster_key.key 4096 2>&1)
    [[ $? ]] || die "ERROR: $? - $RESULT" $LINENO && logit "Success: $? - $RESULT" $LINENO
    clear_result
    logit "Step 5: source_cluster_key.key created successfully" $LINENO
    delay

    # Source Cluster CSR Certificate
    logit "---------------------------------------" $LINENO
    logit "Step 6: Generate source cluster csr certificate" $LINENO
    RESULT=$(openssl req -new -passin pass:$PASSWORD -key $CERTHOME/source_cluster_key.key -subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORG/CN=SOURCECLUSTER" -out $CERTHOME/source_cluster_csr.pem 2>&1)
    [[ $? ]] || die "ERROR: $? - $RESULT" $LINENO && logit "Success: $? - $RESULT" $LINENO
    clear_result
    logit "Step 6:  source_cluster_csr.pem created successfully"  $LINENO
    delay

    # Source Cluster PEM Certificate
    logit "---------------------------------------" $LINENO
    logit "Step 7: Generate source cluster pem certificate" $LINENO
    RESULT=$(openssl x509 -req -passin pass:$PASSWORD -in $CERTHOME/source_cluster_csr.pem -CA $CERTHOME/rootCA.pem -CAkey $CERTHOME/rootCA.key -CAcreateserial -out $CERTHOME/source_cluster_cert.pem -days $DAYS -sha256 2>&1)
    [[ $? ]] || die "ERROR: $? - $RESULT" $LINENO && logit "Success: $? - $RESULT" $LINENO
    clear_result
    logit "Step 7: source cluster pem certificate created successfully" $LINENO
    logit "---------------------------------------" $LINENO
    logit "Phase 1 Completed Successfully" $LINENO
}

phase2 () {
    logit "Phase 2 - Dest Certificate Generation" $LINENO

    # Remote Create $CERTHOME
    logit "---------------------------------------" $LINENO
    logit "Step 1: $DEST Create $CERTHOME dir" $LINENO
    RESULT=$(ssh root@$DEST mkdir -p $CERTHOME 2>&1)
    [[ $? ]] || die "ERROR: $? - $RESULT" $LINENO && logit "Success: $? - $RESULT" $LINENO
    clear_result
    logit "Step 1: $CERTHOME created successfully" $LINENO

    # Copy local $CERTHOME to Remote
    logit "---------------------------------------" $LINENO
    logit "Step 2: Copy local $CERTHOME to $DEST:$CERTHOME" $LINENO
    RESULT=$(scp -r $CERTHOME/* $DEST:$CERTHOME)
    [[ $? ]] || die "ERROR: $? - $RESULT" $LINENO && logit "Success: $? - $RESULT" $LINENO
    clear_result
    logit "Step 2: $CERTHOME copied successfully" $LINENO
    delay

    # Generate Target Cluster Key
    logit "---------------------------------------" $LINENO
    logit "Step 3: Generate Target Cluster Key" $LINENO
    RESULT=$(ssh root@$DEST openssl genrsa -aes256 -passout pass:$PASSWORD -out $CERTHOME/target_cluster_key.key 4096 2>&1)
    [[ $? ]] || die "ERROR: $? - $RESULT" $LINENO && logit "Success: $? - $RESULT" $LINENO
    clear_result
    logit "Step 3: Target Cluster Key generated successfully" $LINENO
    delay

    # Generate Target Cluster CSR Certificate
    logit "---------------------------------------" $LINENO
    logit "Step 4: Generate Target Cluster CSR Certificate" $LINENO
    CMD="openssl req -new -passin pass:$PASSWORD -key $CERTHOME/target_cluster_key.key -subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORG/CN=TARGETCLUSTER" -out $CERTHOME/target_cluster_csr.pem"
    remotecmd || die "ssh failure running $CMD" $LINENO
    clear_result && clear_cmd
    logit "Step 4: Target Cluster CSR Certificate generated successfully" $LINENO
    delay

    # Generate Target Cluster Certificate
    logit "---------------------------------------" $LINENO
    logit "Step 5: Generate Target Cluster Certificate" $LINENO
    RESULT=$(ssh root@$DEST openssl x509 -req -in $CERTHOME/target_cluster_csr.pem -CA $CERTHOME/rootCA.pem -CAkey $CERTHOME/rootCA.key -passin pass:$PASSWORD -CAcreateserial -out $CERTHOME/target_cluster_cert.pem -days $DAYS -sha256 2>&1)
    [[ $? ]] || die "ERROR: $? - $RESULT" $LINENO && logit "Success: $? - $RESULT" $LINENO
    clear_result
    logit "Step 5: Target Cluster Certificate generated successfully" $LINENO
    delay

    # Copy remote $CERTHOME to local
    logit "---------------------------------------" $LINENO
    logit "Step 6: Copy remote $DEST:$CERTHOME to $CERTHOME" $LINENO
    RESULT=$(scp -r $DEST:$CERTHOME/* $CERTHOME 2>&1)
    [[ $? ]] || die "ERROR: $? - $RESULT" $LINENO && logit "Success: $? - $RESULT" $LINENO
    clear_result
    logit "Step 6: $CERTHOME copied successfully" $LINENO
}

phase3 () {
    logit "Phase 3 - Source Certificate Install" $LINENO

    # Add rootCA.pem to cluster CA
    logit "---------------------------------------" $LINENO
    logit "Step 1: Add rootCA.pem to cluster CA" $LINENO
    RESULT=$(echo "{\"name\": \"SyncIQ\", \"certificate_path\": \"/ifs/data/Isilon_Support/.SSLCERTS/rootCA.pem\"}" | /usr/bin/isi_papi_tool POST /7/certificate/authority >/dev/null 2>&1)
    [[ $? ]] || die "ERROR: $? - $RESULT" $LINENO && logit "Success: $? - $RESULT" $LINENO
    clear_result

    RESULT=$(isi certificate authority list | grep synciq)
    [[ $? ]] || die "ERROR: $? - $RESULT" $LINENO && logit "Success: $? - $RESULT" $LINENO
    clear_result
    logit "Step 1: Successfully Added rootCA.pem to cluster CA" $LINENO

    # Added target_cluster_cert.pem to synciq peer certificates
    logit "---------------------------------------" $LINENO
    logit "Step 2: Add target_cluster_cert.pem to synciq peer certificates" $LINENO
    RESULT=$(echo '{"name": "SyncIQ", "certificate_path": "/ifs/data/Isilon_Support/.SSLCERTS/target_cluster_cert.pem"}' | /usr/bin/isi_papi_tool POST /7/sync/certificates/peer >/dev/null 2>&1| grep 2[0-9][0-9])
    [[ $? ]] || die "ERROR: $? - $RESULT" $LINENO && logit "Success: $? - $RESULT" $LINENO
    clear_result
    logit "Step 2: Successfully Added target_cluster_cert.pem to synciq peer certificates" $LINENO
  
    # Add server certificate to cluster
    logit "---------------------------------------" $LINENO
    logit "Step 3: Add server certificate to cluster" $LINENO
    RESULT=$(echo '{"certificate_key_path": "/ifs/data/Isilon_Support/.SSLCERTS/source_cluster_key.key", "certificate_key_password": "'$PASSWORD'", "name": "SyncIQ", "certificate_path": "/ifs/data/Isilon_Support/.SSLCERTS/source_cluster_cert.pem"}' | /usr/bin/isi_papi_tool POST /7/sync/certificates/server >/dev/null 2>&1|grep 2[0-9][0-9])
    [[ $? ]] || die "ERROR: $? - $RESULT" $LINENO && logit "Success: $? - $RESULT" $LINENO
    clear_result
    logit "Step 3: Successfully Added server certificate to cluster" $LINENO

    # Step 4: Add server certificate to cluster
    logit "---------------------------------------" $LINENO
    logit "Step 4: Add server certificate to cluster" $LINENO
    RESULT=$(echo '{"certificate_key_path": "/ifs/data/Isilon_Support/.SSLCERTS/source_cluster_key.key", "certificate_key_password": "'$PASSWORD'", "name": "SyncIQ", "certificate_path": "/ifs/data/Isilon_Support/.SSLCERTS/source_cluster_cert.pem"}' | /usr/bin/isi_papi_tool POST /7/sync/certificates/server >/dev/null 2>&1|grep 2[0-9][0-9])
    [[ $? ]] || die "ERROR: $? - $RESULT" $LINENO && logit "Success: $? - $RESULT" $LINENO
    clear_result
    logit "Step 4: Successfully Added server certificate to cluster" $LINENO

    # Step 5: Define server certificate in SyncIQ settings
    logit "---------------------------------------" $LINENO
    logit "Step 5: get last server certificate" $LINENO
    RESULT=$(isi sync certificates server list --no-header --no-footer)
    [[ $? ]] || die "ERROR: $? - $RESULT" $LINENO && logit "Success: $? - $RESULT" $LINENO
    check_result_not_empty 
    SERVER=$(echo "$RESULT" | awk '{print$1}' | tail -1)
    logit "SERVER: $SERVER" $LINENO
    RESULT=$(isi sync certificates server view $SERVER)
    [[ $? ]] || die "ERROR: $? - $RESULT" $LINENO && logit "Success: $? - $RESULT" $LINENO 
    CERTID=$(echo "$RESULT" | grep ID: | awk '{print$2}')
    logit "CERTID: $CERTID" $LINENO
    clear_result
    RESULT=$(echo "{\"cluster_certificate_id\": \"$CERTID\"}" | /usr/bin/isi_papi_tool PUT /7/sync/settings 2>&1 | grep "2[0-9][0-9]")
    [[ $? ]] || die "ERROR: $? - $RESULT" $LINENO && logit "Success: $? - $RESULT" $LINENO  
    clear_result
    logit "Step 5: Successfully Added server certificate to cluster" $LINENO
}

phase4 () {
    clean_payload
    logit "Clean Payload: $(clean_payload)" $LINENO
    logit "Phase 4 - Dest Certificate Install" $LINENO
    logit "---------------------------------------" $LINENO
    logit "Step 1: Add rootCA to remote host CA" $LINENO
    JSON='{"name": "SyncIQ", "certificate_path": "/ifs/data/Isilon_Support/.SSLCERTS/rootCA.pem"}'
    deploy_payload "$JSON"
    clear_result
    RESULT=$(ssh $SSHOPTIONS root@$DEST cat $PAYLOAD \| /usr/bin/isi_papi_tool POST /7/certificate/authority 2>&1 >/dev/null)
    [[ $? ]] || die "ERROR: $? - $RESULT" $LINENO && logit "Success: $? - $RESULT" $LINENO 
    clean_payload && clear_result 
    RESULT=$(ssh $SSHOPTIONS root@$DEST /usr/bin/isi_papi_tool GET /7/certificate/authority 2>&1)
    echo "$RESULT" | grep SyncIQ >/dev/null && logit "Step 1: Successfully added rootCA to remote host CA" $LINENO || die "Step 1: Did not find the SyncIQ CA on $DEST, $RESULT" $LINENO
    clear_result

    logit "---------------------------------------" $LINENO
    logit "Step 2: Remote import peer cert" $LINENO
    JSON='{"name": "SyncIQ", "certificate_path": "/ifs/data/Isilon_Support/.SSLCERTS/source_cluster_cert.pem"}'
    deploy_payload "$JSON"
    clear_result
    RESULT=$(ssh $SSHOPTIONS root@$DEST cat $PAYLOAD \| /usr/bin/isi_papi_tool POST /7/sync/certificates/peer 2>&1 >/dev/null)
    [[ $? ]] || die "ERROR: $? - $RESULT" $LINENO && logit "Success: $? - $RESULT" $LINENO 
    clean_payload && clear_result 
    RESULT=$(ssh $SSHOPTIONS root@$DEST /usr/bin/isi_papi_tool GET /7/sync/certificates/peer 2>&1)
    echo "$RESULT" | grep SyncIQ >/dev/null && logit "Step 2: Success Remote import peer cert" $LINENO || die "Step 2: Error Remote import peer cert failed on $DEST, $RESULT" $LINENO
    clear_result
        
    logit "---------------------------------------" $LINENO
    logit "Step 3: Remote import server sync cert" $LINENO
    JSON="{\"certificate_key_path\": \"/ifs/data/Isilon_Support/.SSLCERTS/target_cluster_key.key\", \"certificate_key_password\": \"$PASSWORD\", \"name\": \"SyncIQ\", \"certificate_path\": \"/ifs/data/Isilon_Support/.SSLCERTS/target_cluster_cert.pem\"}"
    deploy_payload "$JSON"
    clear_result
    RESULT=$(ssh $SSHOPTIONS root@$DEST cat $PAYLOAD \| /usr/bin/isi_papi_tool POST /7/sync/certificates/server 2>&1 >/dev/null)
    [[ $? ]] || die "ERROR: $? - $RESULT" $LINENO && logit "Success: $? - $RESULT" $LINENO 
    clean_payload && clear_result 
    RESULT=$(ssh $SSHOPTIONS root@$DEST /usr/bin/isi_papi_tool GET /7/sync/certificates/server 2>&1)
    echo "$RESULT" | grep SyncIQ >/dev/null && logit "Step 3: Successful Remote import server sync cert" $LINENO || die "Step 3: Remote import server sync cert on $DEST, $RESULT" $LINENO
    clear_result
 
    logit "---------------------------------------" $LINENO
    logit "Step 4: Remote set cluster cert id" $LINENO
    RESULT=$(ssh $SSHOPTIONS root@$DEST isi sync certificates server list --no-header --no-footer)
    [[ $? ]] || die "ERROR: $? - $RESULT" $LINENO && logit "Success: $? - $RESULT" $LINENO 
    check_result_not_empty
    RESULT=$(echo $RESULT |awk '{print$1}' | tail -1)
    [[ $? ]] || die "ERROR: $? - $RESULT" $LINENO && logit "Success: $? - $RESULT" $LINENO 
    check_result_not_empty
    RESULT=$(ssh $SSHOPTIONS root@$DEST isi sync certificates server view $RESULT)
    [[ $? ]] || die "ERROR: $? - $RESULT" $LINENO && logit "Success: $? - $RESULT" $LINENO 
    check_result_not_empty

    RESULT=$(echo $RESULT | grep ID: | awk '{print$2}')
    [[ $? ]] || die "ERROR: $? - $RESULT" $LINENO && logit "Success: $? - $RESULT" $LINENO 
    check_result_not_empty
    CERTID=$RESULT

    JSON="{\"cluster_certificate_id\": \"$CERTID\"}"
    deploy_payload "$JSON"
    clear_result
    RESULT=$(ssh $SSHOPTIONS root@$DEST cat $PAYLOAD \| /usr/bin/isi_papi_tool PUT /7/sync/settings 2>&1 >/dev/null)
    [[ $? ]] || die "ERROR: $? - $RESULT" $LINENO && logit "Success: $? - $RESULT" $LINENO 
    clean_payload && clear_result 
    RESULT=$(ssh $SSHOPTIONS root@$DEST /usr/bin/isi_papi_tool GET /7/sync/settings 2>&1)
    logit "RESULT: $RESULT" $LINENO
    RESULT=$(echo "$RESULT" | sed -e '1,5d' |python2 -c "import sys, json; print json.load(sys.stdin)['settings']['cluster_certificate_id']")
    logit "RESULT: $RESULT" $LINENO
    [[ "$RESULT"  == "$CERTID" ]] && logit "Step 4: Successfully remote set cluster cert id" $LINENO || die "Step 4: Error remote set cluster cert id on $DEST, $RESULT-$CERTID" $LINENO
}

phase5 () {
    logit "Phase 5 - Testing Encrypted SyncIQ" $LINENO
    mkdir /ifs/encsynctestdir || return $?
    logit "created /ifs/encsynctestdir" $LINENO
    dd if=/dev/zero of=/ifs/encsynctestdir/testfile.dd bs=1M count=10 >/dev/null 2>&1 || return $?
    logit "created dummy 10M file"  $LINENO
    isi sync policies create encryptedpolicy sync /ifs/encsynctestdir $DEST /ifs/encsynctestdir --target-certificate-id=$(isi sync certificates peer view $(isi sync certificates peer list --no-header --no-footer | awk '{print$1}') | grep ID: | awk '{print$2}') || return $?
    logit "created sync test policy named: encryptedpolicy" $LINENO
    isi sync jobs start encryptedpolicy || return $?
    logit "Waiting for policy to complete" $LINENO
    sleep 30
    logit "Getting the SyncIQ report for test policy" $LINENO
    results=$(isi sync reports view encryptedpolicy 1 | grep 'State:' |awk '{print$2}')
    logit "Completed with status: $results" $LINENO
    [[ "$results" == "finished" ]] && logit "Test policy completed successfully" || die $(isi sync reports view encryptedpolicy 1)
}

phase6 () {
    logit "Phase 6 - Cleanup" $LINENO
    logit "Removing encryptedpolicy used for testing" $LINENO
    isi sync policies delete -f encryptedpolicy || die "Error removing test policy" $LINENO
    sleep 15
    logit "Removing target sync folder"  $LINENO
    ssh $SSHOPTIONS root@$DEST rm -rf /ifs/encsynctestdir || die "Error removing target data folder /ifs/encsynctestdir" $LINENO
    rm -rf /ifs/encsynctestdir

    # if [[ "$1" == "True" ]]; then
    #     logit "Removing Dest ssh key authorization"
    #     ssh $SSHOPTIONS root@$DEST rm -f /root/.ssh/authorized_keys || die "Error removing ssh authorized_keys"
    #     # logit "Removing local generated ssh keys"
    #     # ssh $SSHOPTIONS root@$DEST sed -i \'/root@$(hostname)/d\' ~/.ssh/authorized_keys || die "error removing ssh key authorization"
    #     # ssh $SSHOPTIONS root@$DEST cat /root/.ssh/authorized_keys \| grep -v root@\$(hostname) \> /root/.ssh/authorized_keys.tmp && \
    #     # ssh $SSHOPTIONS root@$DEST cp /root/.ssh/authorized_keys.tmp /root/.ssh/authorized_keys || die "Error removing authorized_keys entry"
    #     rm -f /root/.ssh/id_rsa && \
    #     rm -f /root/.ssh/id_rsa.pub || die "Error removing local ssh keys"
    # fi
}

localtests () {
  logit "############# Local Tests #############" $LINENO
  # Must be root
  CMD="whoami"
  localcmd || die "whoami command not found" $LINENO
  clear_cmd
  [[ "$RESULT" == "root" ]] || die "Must be root" && logit "Confirmed root user" $LINENO
  clear_result && clear_cmd

  # Checking if $CERTHOME exists
  # -d file is a directory
  # -L file is a symbolic link
  # 
  logit "Checking if $CERTHOME exists..." $LINENO
  CMD="ls $CERTHOME"
  localcmd && die "This script should only be run once per cluster"  $LINENO || logit "$CERTHOME does not exist, continuing" $LINENO
  clear_result && clear_cmd

  # Must be OneFS
  CMD="uname"
  localcmd || die "uname command not found" $LINENO
  check_result "Isilon OneFS" && logit "$RESULT"  $LINENO || die "Must be run on OneFS"  $LINENO
  clear_result && clear_cmd

  #Must be OneFS version >= 8.2.2
  logit "Checking version of OneFS locally" $LINENO
  CMD="uname -r"
  localcmd || die "$RESULT" $LINENO
  check_onefs_ver "$RESULT"
  clear_result && clear_cmd
  
  # Must not have synciq certificates (net new installs only)
  logit "Checking server certificates locally" $LINENO
  CMD="isi sync cert server list --no-header --no-footer"
  localcmd || die "Error getting isi sync cert server list" $LINENO
   [[ "$RESULT" == "" ]] && logit "isi sync cert server list empty"  $LINENO || die "Must not have any isi sync server certificates" $LINENO
  clear_result && clear_cmd

  logit "Checking peer certificates locally" $LINENO
  CMD="isi sync cert peer list --no-header --no-footer"
  localcmd || die "Error getting isi sync cert peer list"
  [[ "$RESULT" == "" ]] && logit "isi sync cert peer list empty" $LINENO || die "Must not have any isi sync peer certificates" $LINENO
  clear_result && clear_cmd
  
  # Must not have synciq policies
  logit "Checking for existing synciq policies" $LINENO
  CMD="isi sync policies list --no-header --no-footer"
  localcmd || die "Error getting isi sync policies list"
  [[ "$RESULT" == "" ]] && logit "no synciq policies in place proceeding" $LINENO || die "existing synciq policies, aborting" $LINENO
  clear_result && clear_cmd
}

remotetests () {
  logit "############# Remote Tests #############" $LINENO
  # Remote Tests
  logit "Check the version of OneFS on the target" $LINENO
  CMD="uname -r | sed 's/v//g'"
  remotecmd || die "ssh failure running $CMD" $LINENO
  check_onefs_ver "$RESULT"
  clear_result && clear_cmd

  # Remote Check if $CERTHOME exists
  # -d file is a directory
  # -L file is a symbolic link
  logit "Remote Checking if $CERTHOME exists..." $LINENO
  CMD="[ ! -e \"$CERTHOME\" ]"
  remotecmd || die "This script should only be run once per cluster" $LINENO && logit "$CERTHOME does not exist, continuing" $LINENO
  clear_result && clear_cmd

  # Must be OneFS
  CMD="uname"
  remotecmd || die "ssh failure running $CMD" $LINENO
  [[ "$RESULT" == "Isilon OneFS" ]] && logit "$RESULT"  $LINENO || die "Must be run on OneFS"  $LINENO
  clear_result && clear_cmd
  
  #Must be OneFS version >= 8.2.2
  logit "Checking version of OneFS remotely" $LINENO
  CMD="uname -r"
  remotecmd || die "ssh failure running $CMD" $LINENO
  check_onefs_ver "$RESULT"
  clear_result && clear_cmd

  # Must not have synciq certificates (net new installs only)
  logit "Checking server certificates locally" $LINENO
  CMD="isi sync cert server list --no-header --no-footer"
  remotecmd || die "ssh failure running $CMD"
  [[ "$RESULT" == "" ]] && logit "isi sync cert server list empty" $LINENO || die "Must not have any isi sync server certificates" $LINENO
  clear_result && clear_cmd

  logit "Checking peer certificates locally" $LINENO
  CMD="isi sync cert peer list --no-header --no-footer"
  remotecmd || die "ssh failure running $CMD"
  [[ "$RESULT" == "" ]] && logit "isi sync cert peer list empty"  $LINENO || die "Must not have any isi sync peer certificates" $LINENO
  clear_result && clear_cmd
  
  # Must not have synciq policies
  logit "Checking for existing synciq policies" $LINENO
  CMD="isi sync policies list --no-header --no-footer"
  remotecmd || die "ssh failure running $CMD" $LINENO
  [[ "$RESULT" == "" ]] && logit "no synciq policies in place proceeding" $LINENO || die "existing synciq policies, aborting" $LINENO
  clear_result && clear_cmd

  # test by comparing hostnames
  logit "Checking to be sure source and target are different clusters by hostname" $LINENO
  CMD="hostname"
  localcmd || die "local failure running $CMD" $LINENO
  LOCALNAME="$RESULT"
  clear_result
  remotecmd || die "ssh failure running $CMD" $LINENO
  REMOTENAME="$RESULT"
  clear_result && clear_cmd
  [[ "$LOCALNAME" == "$REMOTENAME" ]] && die "Destination cannot be same as source cluster" $LINENO || logit "Source and Target hostnames are not the same, continuing" $LINENO
}

startup () {
  logit "############# Startup #############" $LINENO
  ## Startup Tests
  # Logging the variables
  logit "Dest: $DEST" $LINENO
  logit "CertHome: $CERTHOME" $LINENO
  logit "LogFile: $LOGFILE" $LINENO
  logit "Country: $COUNTRY" $LINENO
  logit "State: $STATE" $LINENO
  logit "Locality: $LOCALITY" $LINENO
  logit "Days: $DAYS" $LINENO

  localtests

  # Test passwordless ssh
  ssh $SSHOPTIONS -o StrictHostKeyChecking=no root@$DEST "echo" # >/dev/null 2>&1
  [[ "$?" -eq 0 ]] && logit "passwordless ssh configured" $LINENO || genssh && DELETEKEYS="True"
  
  remotetests
  
  check_time_sync
}

main() {
  echo "################################################################################"
  printf "%-10s %-40s %-27s#\n" "Phase#" "Description" "Duration"
  printf "%-10s%-40s%-27s#\n" "----------|" "----------------------------------------|" "---------------------------"
  
  printf "%-10s %-40s %-27s#\n" "Phase 1" "Source Certificate Generation" "~5s"
  phase1
  
  printf "%-10s %-40s %-27s#\n" "Phase 2" "Dest Certificate Generation" "~5s"
  phase2
  
  printf "%-10s %-40s %-27s#\n" "Phase 3" "Source Certificate Install" "~5s"
  phase3

  printf "%-10s %-40s %-27s#\n" "Phase 4" "Dest Certificate Install" "~5s"
  phase4

  printf "%-10s %-40s %-27s#\n" "Phase 5" "Testing Encrypted SyncIQ" "~35s"
  phase5

  printf "%-10s %-40s %-27s#\n" "Phase 6" "Cleanup" "~20s"
  phase6 $DELETEKEYS 
  echo "################################################################################"
  echo
  echo "Success!"
  echo
  echo "To enable encryption for a SyncIQ policy: use the following command to set the --target-certificate-id AFTER creating the policy:"
  echo
  echo "isi sync policies modify \$POLICYNAME --target-certificate-id=\$(isi sync certificates peer view \$(isi sync certificates peer list --no-header --no-footer | awk '{print\$1}') | grep ID: | awk '{print\$2}')"
  echo
  echo "To confirm that a policy is configured for encryption run the following:"
  echo
  echo "isi sync policies view \$POLICYNAME | grep \"Target Certificate\""
  echo
  sleep 1
  echo COMPLETE
}

cleanup () { echo "clean"
  printeula
  # Test passwordless ssh
  ssh "$SSHOPTIONS" -o StrictHostKeyChecking=no root@"$DEST" "echo"  >/dev/null 2>&1
  [[ "$?" -eq 0 ]] && logit "passwordless ssh configured" $LINENO || genssh && DELETEKEYS="True" 
  
  # DR Cert Cleanup
  logit "DR Cert Cleanup" $LINENO
  CMD="/usr/bin/isi_papi_tool DELETE /7/certificate/authority/SyncIQ"
  ssh "$SSHOPTIONS" root@"$DEST" "$CMD" | grep "2[0-9][0-9]" || logit "Error: $CMD" $LINENO
  CMD="/usr/bin/isi_papi_tool DELETE /7/sync/certificates/peer/SyncIQ"
  ssh "$SSHOPTIONS" root@"$DEST" "$CMD" | grep "2[0-9][0-9]" || logit "Error: $CMD" $LINENO
  CMD="/usr/bin/isi_papi_tool DELETE /7/sync/certificates/server/SyncIQ"
  ssh "$SSHOPTIONS" root@"$DEST" "$CMD" | grep "2[0-9][0-9]" || logit "Error: $CMD" $LINENO
  
  # Prod Cert Cleanup
  logit "Prod Cert Cleanup" $LINENO
  /usr/bin/isi_papi_tool DELETE /7/sync/certificates/server/SyncIQ | grep "2[0-9][0-9]" || logit "Error: $CMD" $LINENO
  /usr/bin/isi_papi_tool DELETE /7/sync/certificates/peer/SyncIQ | grep "2[0-9][0-9]" || logit "Error: $CMD" $LINENO
  /usr/bin/isi_papi_tool DELETE /7/certificate/authority/SyncIQ | grep "2[0-9][0-9]" || logit "Error: $CMD" $LINENO
  
  # Remote Dir Cleanup
  logit "Remote Dir Cleanup" $LINENO
  ssh "$SSHOPTIONS" root@"$DEST" rm -rf "$CERTHOME" || logit "Error Removing Remote $CERTHOME" $LINENO

  logit "Remote ssh keys cleanup" $LINENO
  ssh "$SSHOPTIONS" root@"$DEST" rm -rf /root/.ssh/authorized_keys || logit "Error Removing Remote ssh keys" $LINENO
  
  # Local Dir Cleanup
  logit "Local Dir Cleanup" $LINENO
  rm -rf $CERTHOME || logit "Error Removing local $CERTHOME" $LINENO
}

USAGE () {
    cat <<EOF 
  $0 -t \$TARGETCLUSTERIP -p \$ROOT_CA_PASSWORD

    -h | --help) - Print this usage message
    -t | --targetclusterip) - IP on first node of target cluster reachable from source cluster (required)
    -p | --password) - Password used to encrypt the root CA certificate and sign other certs (required)
    -c | --certhome) - Path on /ifs to keep the certificates (default=$CERTHOME)
    -l | --logfile) - path of file to store the log for this script (default=$LOGFILE)
    -d | --days) - Number of days until the certificates expire (default=$DAYS)
    -r |--runbook - Print the commands required for each phase so the user can run manually (future)
    --country) - Country for the certificates (default=$COUNTRY)
    --state) - State for the certificates (default=$STATE)
    --locality) - Locality for the certificates (default=$LOCALITY)
    --org) - Organization for the certificates (default=ORG)

  Example:

    # $0 -t 172.16.10.20 -p pass1234 -d 719 --country UK --locality London --org "MerryWeathers Inc"
EOF
    exit 10
}

myInvocation="$(printf %q "$BASH_SOURCE")$( (($#)) && printf ' %q' "$@")"

[[ $# == 0 ]] && USAGE

POSITIONAL_ARGS=()

# Arg Handling
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      USAGE
      ;;
    -c|--certhome)
      CERTHOME="$2"
      shift # past argument
      shift # past value
      ;;
    -p|--password)
      PASSWORD="$2"
      shift # past argument
      shift # past value
      ;;
    -l|--logfile)
      LOGFILE=$2
      shift # past argument
      shift # past value
      ;;
    -t|--targetclusterip)
      DEST=$2
      shift # past argument
      shift # past value
      ;;
    --country)
      COUNTRY=$2
      shift # past argument
      shift # past value
      ;;
    --state)
      STATE=$2
      shift # past argument
      shift # past value
      ;;
    --locality)
      LOCALITY=$2
      shift # past argument
      shift # past value
      ;;
    --org)
      ORG=$2
      shift # past argument
      shift # past value
      ;;
    -z|--zcleanup)
      CLEAN="yes"
      shift # past argument
      shift # past value
      ;;
    --phase)
      PHASE=$2        
      shift # past argument
      shift # past value
      ;;
    -d|--days)
      DAYS=$2
      shift # past argument
      shift # past value
      ;;      
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

[[ "$DEST"  == "" ]] && USAGE
[[ "$PASSWORD"  == "" ]] && USAGE

#Scrub spaces from ORG
ORG=$(echo $ORG | sed 's/\ /\-/g')

## Logic
################################################################
# Cleanup old run
# or
# Run one or all phases
################################################################
logit "Called via: $myInvocation" $LINENO
if [[ "$CLEAN" == "yes" ]]; then
  logit "Cleanup Mode Selected" $LINENO
  cleanup && echo "Cleanup Complete" || echo "Error cleaning up" 
  exit 0
fi

if [[ $PHASE == "" ]]; then
  startup 
  printeula
  main
else
  echo "Starting for PHASE $PHASE"
  if   [[ "$PHASE" == "1" ]]; then
    startup 
    printeula
    phase1
  elif [[ "$PHASE" == "2" ]]; then    
    phase2
  elif [[ "$PHASE" == "3" ]]; then    
    phase3
  elif [[ "$PHASE" == "4" ]]; then    
    phase4
  elif [[ "$PHASE" == "5" ]]; then    
    phase5
  elif [[ "$PHASE" == "6" ]]; then    
    phase6
  else
    echo "Unknown Phase: $PHASE"
  fi
fi