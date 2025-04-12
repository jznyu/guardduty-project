#!/bin/bash

source localIps.sh

echo
echo '***********************************************************************'
echo '* SSH Brute Force Test                                               *'
echo '* This script simulates an SSH brute force attack on the target      *'
echo '* Linux instance. It uses multiple methods to ensure GuardDuty       *'
echo '* detection thresholds are met.                                      *'
echo '***********************************************************************'
echo

if [ ! -f "users" ]; then
  echo "Creating users file..."
  echo "ec2-user" > users
  echo "admin" >> users
  echo "root" >> users
fi

echo "Target IP: $BASIC_LINUX_TARGET"
echo "Starting SSH brute force attack simulation..."


echo "Method 1: Direct SSH connection attempts (50 tries)"
for i in {1..50}; do
  echo "SSH attempt $i"
  ssh -o StrictHostKeyChecking=no -o ConnectTimeout=1 ec2-user@$BASIC_LINUX_TARGET -i compromised_keys/fakekey.pem 2>/dev/null || true
  ssh -o StrictHostKeyChecking=no -o ConnectTimeout=1 root@$BASIC_LINUX_TARGET -i compromised_keys/fakekey.pem 2>/dev/null || true
  sleep 0.5
done

echo
echo "Method 2: Using Crowbar tool for SSH key-based attacks (10 iterations)"
for j in {1..10}; do
  echo "Crowbar iteration $j"
  sudo ./crowbar/crowbar.py -b sshkey -s $BASIC_LINUX_TARGET/32 -U users -k ./compromised_keys
  sleep 1
done

echo
echo "Method 3: Trying with different key names"
for key in {1..10}; do
  echo "Testing with alternative key $key"
  ssh -o StrictHostKeyChecking=no -o ConnectTimeout=1 ec2-user@$BASIC_LINUX_TARGET -i compromised_keys/compromised$key.pem 2>/dev/null || true
  sleep 0.5
done

echo
echo '*****************************************************************************************************'
echo 'Expected GuardDuty Finding:'
echo
echo 'SSH Brute Force with Compromised Keys'
echo 'Expecting two findings - one for the outbound and one for the inbound detection'
echo 'Outbound: Instance ' $RED_TEAM_IP ' is performing SSH brute force attacks against ' $BASIC_LINUX_TARGET
echo 'Finding Type: UnauthorizedAccess:EC2/SSHBruteForce'
echo '*****************************************************************************************************'
echo
echo "SSH brute force attack simulation completed. GuardDuty may take 10-30 minutes to generate findings."
