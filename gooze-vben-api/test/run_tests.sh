#!/bin/bash

TestName=$1

echo "========================================"
echo "  Gooze CMS Backend API Tests"
echo "========================================"
echo ""

cd "$(dirname "$0")/.."

if [ -n "$TestName" ]; then
    echo "Running test: $TestName"
    go test -v ./test -run "$TestName"
else
    echo "Running all tests..."
    echo ""
    echo "--- Category Tests ---"
    go test -v ./test -run "TestCategory"

    echo ""
    echo "--- Tag Tests ---"
    go test -v ./test -run "TestTag"
fi

echo ""
echo "========================================"
echo "  Test execution completed"
echo "========================================"
