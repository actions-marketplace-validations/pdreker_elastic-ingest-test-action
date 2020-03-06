#!/bin/sh

# Wait 100s for elastic to come up
ELASTIC_LIVE=0
echo "WAITING for elasticsearch to become live"
for i in $(seq 1 10); do
    curl -s http://$INPUT_ELASTIC_HOST:$INPUT_ELASTIC_PORT
    if [ $? -eq 0 ]; then
        echo "SUCCESS elasticsearch live"
        ELASTIC_LIVE=1
        break
    else
        echo "Elastic not ready yet."
        sleep 10
    fi
done

if [ $ELASTIC_LIVE -ne 1 ]; then
    echo "FAILED: elasticsearch unreachable at $INPUT_ELASTIC_HOST:$INPUT_ELASTIC_PORT"
    exit 1
fi

RESULT=0

echo "Deploying pipes from $GITHUB_WORKSPACE/$INPUT_TESTDIR"
for PIPE in $GITHUB_WORKSPACE/$INPUT_TESTDIR/pipe*.json; do
    python3 /elasticcheck.py --prepare http://$INPUT_ELASTIC_HOST:$INPUT_ELASTIC_PORT $PIPE
    if [ $? -ne 0 ]; then
        RESULT=1
    fi
done

echo "Running tests from $GITHUB_WORKSPACE/$INPUT_TESTDIR"
for TEST in $GITHUB_WORKSPACE/$INPUT_TESTDIR/test*.json; do
    python3 /elasticcheck.py http://$INPUT_ELASTIC_HOST:$INPUT_ELASTIC_PORT $TEST
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