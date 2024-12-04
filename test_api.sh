#!/bin/bash

BASE_URL="http://127.0.0.1:8080"

# Helper function to print test results
function test_endpoint() {
  local METHOD=$1
  local ENDPOINT=$2
  local HEADERS=$3
  local BODY=$4
  local EXPECTED_STATUS=$5
  local TEST_NAME=$6

  echo "=== Running Test: $TEST_NAME ==="

  RESPONSE=$(curl -s -o response.txt -w "%{http_code}" -X $METHOD "$BASE_URL$ENDPOINT" $HEADERS -d "$BODY")
  HTTP_STATUS=$(cat response.txt | tail -n 1)

  if [[ "$RESPONSE" == "$EXPECTED_STATUS" ]]; then
    echo "PASS: $TEST_NAME"
  else
    echo "FAIL: $TEST_NAME"
    echo "Expected Status: $EXPECTED_STATUS, Got: $RESPONSE"
    echo "Response Body:"
    cat response.txt
  fi
  echo "======================================"
}

# 1. Test Valid Sequence Generation
test_endpoint \
  "POST" \
  "/sequence" \
  "-H 'Content-Type: application/json'" \
  '{"elementType": "character", "elementId": 1, "comment": "Testing valid sequence generation"}' \
  "200" \
  "Valid Sequence Generation"

# 2. Test Invalid Path
test_endpoint \
  "POST" \
  "/invalid-path" \
  "-H 'Content-Type: application/json'" \
  '{"elementType": "character", "elementId": 1, "comment": "Testing invalid path"}' \
  "404" \
  "Invalid Path Test"

# 3. Test Missing Content-Type Header
test_endpoint \
  "POST" \
  "/sequence" \
  "" \
  '{"elementType": "character", "elementId": 1, "comment": "Testing missing Content-Type"}' \
  "400" \
  "Missing Content-Type Header Test"

# 4. Test Unsupported Method
test_endpoint \
  "GET" \
  "/sequence" \
  "" \
  "" \
  "405" \
  "Unsupported HTTP Method Test"

# 5. Test Unsupported Content-Type
test_endpoint \
  "POST" \
  "/sequence" \
  "-H 'Content-Type: application/xml'" \
  "<xml><elementType>character</elementType><elementId>1</elementId><comment>Testing unsupported content type</comment></xml>" \
  "415" \
  "Unsupported Content-Type Test"

echo "All tests complete."

