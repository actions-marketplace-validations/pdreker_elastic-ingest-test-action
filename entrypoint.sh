#!/bin/sh

docker_run="docker run -d -p 9200:9200 -p 9300:9300 --name elastic -e 'discovery.type=single-node' elasticsearch:$INPUT_ELASTIC_VERSION"

echo "RUNNING: $docker_run"
sh -c "$docker_run"


# Wait 100s for elastic to come up
echo "WAITING for elasticsearch to become live"
for i in $(seq 1 10); do
    curl -s http://localhost:9200
    if [ $? -eq 0 ]; then
        echo "SUCCESS elasticsearch live"
        break
    else
        echo "Elastic not ready yet."
        sleep 10
    fi
done

docker logs elastic
netstat -tulpen

ls -lR $GITHUB_WORKSPACE

RESULT=0

echo "Deploying pipes from $GITHUB_WORKSPACE/$INPUT_TESTDIR"
for PIPE in $GITHUB_WORKSPACE/$INPUT_TESTDIR/pipe*.json; do
    python3 /elasticcheck.py --prepare http://localhost:9200 $PIPE
    if [ $? -ne 0 ]; then
        RESULT=1
    fi
done

echo "Running tests from $GITHUB_WORKSPACE/$INPUT_TESTDIR"
for TEST in $GITHUB_WORKSPACE/$INPUT_TESTDIR/test*.json; do
    python3 /elasticcheck.py http://localhost:9200 $TEST
    if [ $? -ne 0 ]; then
        RESULT=2
    fi
done

if [ $RESULT -eq 0 ]; then
    echo ::set-output name=RESULT::SUCCESS
    echo SUCCESS
elif [ $RESULT -eq 1 ]; then
    echo ::set-output name=RESULT::PIPEFAILED
    echo PIPEFAILED
    exit 1
elif [ $RESULT -eq 2 ]; then
    echo ::set-output name=RESULT::FAILED
    echo FAILED
    exit 2
fi