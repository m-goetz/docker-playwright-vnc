#!/bin/bash
# Copy the contents of ssh key and known_hosts
if [ -f "/home/ubuntu/ssh-mnt/id_rsa" ]; then
    cat /home/ubuntu/ssh-mnt/id_rsa > /home/ubuntu/.ssh/id_rsa
fi
if [ -f "/home/ubuntu/ssh-mnt/id_rsa.pub" ]; then
    cat /home/ubuntu/ssh-mnt/id_rsa.pub > /home/ubuntu/.ssh/id_rsa.pub
fi
if [ -f "/home/ubuntu/ssh-mnt/known_hosts" ]; then
    cat /home/ubuntu/ssh-mnt/known_hosts > /home/ubuntu/.ssh/known_hosts
    chmod 600 /home/ubuntu/.ssh/known_hosts
fi

# Copy mvn settings.xml
if [ -f "/home/ubuntu/mvn/settings.xml" ]; then
    cat /home/ubuntu/mvn/settings.xml > /opt/maven/conf/settings.xml
fi

# Checking out Git repo
git config --global --add safe.directory /home/ubuntu/tests
if [ -d "/home/ubuntu/tests/.git" ]; then
  echo "Git repo found inside /home/ubuntu/tests ..."
  git fetch
else
  echo "Cloning $REPO_URL into /home/ubuntu/tests ..."
  git clone $REPO_URL /home/ubuntu/tests
fi;
cd "/home/ubuntu/tests"
git checkout $BRANCH_NAME

# Start the vncserver, websockify, nginx, maven
/usr/bin/vncserver :99 -SecurityTypes None -geometry 1600x900 2>&1 | sed "s/^/\x1b[34m[Xtigervnc ]\x1b[0m /" & 
sleep 1
websockify -D --web=/usr/share/novnc/ 6080 localhost:5999 2>&1 | sed "s/^/\x1b[36m[NoVNC     ]\x1b[0m /" &
sleep 3
/usr/sbin/nginx 2>&1 | sed "s/^/\x1b[32m[nginx     ]\x1b[0m /" &
cd /home/ubuntu/tests/$GIT_SUB_DIR && /opt/maven/bin/mvn --version && DISPLAY=:99 /opt/maven/bin/mvn clean test 2>&1 | sed "s/^/\x1b[33m[maven     ]\x1b[0m /" &
sleep 10
tail -f /home/ubuntu/.vnc/*.log | sed "s/^/\x1b[34m[Xtigervnc ]\x1b[0m /" &
tail -f /dev/null