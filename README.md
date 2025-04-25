# docker-vnc-playwright

> This is still work in progress. Use at own risk.

This image provides a way to execute Playwright tests inside a container and to witness the execution with noVNC. 

The aim is to provide a way to execute e2e tests inside a container environment like Kubernetes, where you can hardly access databases via JDBC from outside the cluster, for example. When everything runs inside a container inside the cluster, you have access to database services and other non-http accessible resources that you might want to / have to set up for your tests.

## Build and run the image

Clone this repository and execute:

```bash
docker build --no-cache --progress=plain -t playwright-vnc .
```

To run the image, you can pass the following options to the `docker run` command.

For instance, you can pass your ssh keys inside the container to allow `git` to clone the repository. Make sure that the mounted ssh files are readable to the `ubuntu` user inside the container. You can also mount your Maven `settings.xml` to be used for the test run. 

It is recommended to mount a volume to `/home/ubuntu/tests/` and `/home/ubuntu/.m2` to save execution time (prevents full git clone and Maven dependency download).

```bash
docker run -it --rm --name playwright-vnc-container -p 5999:5999 -p 6081:6081 \
-e REPO_URL='<git-repo-url>' \
-e BRANCH_NAME='<branch-name>' \
-e GIT_SUB_DIR='<dir-in-repo/subdir/>' \
-v './ssh-mount-files/id_rsa:/home/ubuntu/ssh-mnt/id_rsa' \
-v './ssh-mount-files/id_rsa.pub:/home/ubuntu/ssh-mnt/id_rsa.pub' \
-v './ssh-mount-files/known_hosts:/home/ubuntu/ssh-mnt/known_hosts' \
-v '<path-to-maven-settings>/settings.xml:/opt/maven/conf/settings.xml' \
-v '<local-git-repo-containing-tests>:/home/ubuntu/tests/' \
-v '</home/goetz/.m2-tmp/>:/home/ubuntu/.m2/' \
playwright-vnc
```

After that, you should be able to connect to noVNC: http://localhost:6081/. 
