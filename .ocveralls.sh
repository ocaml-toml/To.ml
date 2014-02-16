# Set JOB_ID and SERVICE_NAME
if [ ! -z "$TRAVIS" ]
then
    JOB_ID="$TRAVIS_JOB_ID"
    SERVICE_NAME="travis-ci"

elif [ ! -z "$CIRCLECI" ]
then
    JOB_ID="$CIRCLE_BUILD_NUM"
    SERVICE_NAME="circleci"

elif [ ! -z "$SEMAPHORE" ]
then
    JOB_ID="REVISION"
    SERVICE_NAME="semaphore"

elif [ ! -z "$JENKINS_URL" ]
then
    JOB_ID="$BUILD_ID"
    SERVICE_NAME="jenkins"

elif [ "$CI_NAME" = "codeship" ]
then
    JOB_ID="$CI_BUILD_NUMBER"
    SERVICE_NAME="codeship"

else
    echo "Unsupported CI service. Exiting with 1."
    exit 1;
fi

JSON_FILE="$SERVICE_NAME-$JOB_ID.json"

# generate json
bisect-report -coveralls-property service_job_id $JOB_ID \
    -coveralls-property service_name $SERVICE_NAME -coveralls $JSON_FILE $*

#send json
curl -F json_file=@$JSON_FILE https://coveralls.io/api/v1/jobs
