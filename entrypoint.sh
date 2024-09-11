#!/bin/bash

# Capture input variables
DEFECTDOJO_URL=$1
DEFECTDOJO_API_KEY=$2
ENGAGEMENT_ID=$3
REPO_TOKEN=$4
TARGET_URL=$5

# Run Horusec scan
horusec start --project-path . -D
horusec start --project-path . --output-format json --json-output-file horusec-report.json -D

# Run Dependency-Check scan
./dependency-check/bin/dependency-check.sh --project "MyProject" --scan "./" --format "XML" --out "dependency-check-report.xml"

# Run OWASP ZAP scan
docker run --rm -v $(pwd):/zap/wrk/ -t owasp/zap2docker-stable zap-baseline.py -t $TARGET_URL -r zap_report.xml

# Run Dastardly scan
docker run --rm -v $(pwd):/src dastardly-ci/dastardly scan --project . --output dastardly-report.xml

# Upload results to DefectDojo
curl -X POST "$DEFECTDOJO_URL/api/v2/import-scan/" \
     -H "Authorization: Token $DEFECTDOJO_API_KEY" \
     -F 'scan_type=Horusec Scan' \
     -F "engagement=$ENGAGEMENT_ID" \
     -F 'file=@horusec-report.json' \
     -F 'active=true' \
     -F 'verified=true'

curl -X POST "$DEFECTDOJO_URL/api/v2/import-scan/" \
     -H "Authorization: Token $DEFECTDOJO_API_KEY" \
     -F 'scan_type=Dependency Check Scan' \
     -F "engagement=$ENGAGEMENT_ID" \
     -F 'file=@dependency-check-report.xml' \
     -F 'active=true' \
     -F 'verified=true'

curl -X POST "$DEFECTDOJO_URL/api/v2/import-scan/" \
     -H "Authorization: Token $DEFECTDOJO_API_KEY" \
     -F 'scan_type=ZAP Scan' \
     -F "engagement=$ENGAGEMENT_ID" \
     -F 'file=@zap_report.xml' \
     -F 'active=true' \
     -F 'verified=true'

curl -X POST "$DEFECTDOJO_URL/api/v2/import-scan/" \
     -H "Authorization: Token $DEFECTDOJO_API_KEY" \
     -F 'scan_type=Burp Dastardly Scan' \
     -F "engagement=$ENGAGEMENT_ID" \
     -F 'file=@dastardly-report.xml' \
     -F 'active=true' \
     -F 'verified=true'
