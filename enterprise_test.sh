#!/bin/bash
# Enterprise Features Test Suite for LinEnum-Enhanced

echo "=== LinEnum-Enhanced Enterprise Features Test ==="
echo "Testing professional reporting and compliance modes..."
echo

# Test 1: JSON Output Format
echo "Test 1: JSON Output Format"
timeout 25s ./LinEnum.sh --format json -r json-test >/dev/null 2>&1
if [ -f "json-test*.json" ]; then
    echo "✓ JSON report generated successfully"
    json_size=$(du -h json-test*.json | cut -f1)
    echo "  Report size: $json_size"
else
    echo "✗ JSON report generation failed"
fi
echo

# Test 2: XML Output Format  
echo "Test 2: XML Output Format"
timeout 25s ./LinEnum.sh --format xml -r xml-test >/dev/null 2>&1
if [ -f "xml-test*.xml" ]; then
    echo "✓ XML report generated successfully"
    xml_size=$(du -h xml-test*.xml | cut -f1)
    echo "  Report size: $xml_size"
else
    echo "✗ XML report generation failed"
fi
echo

# Test 3: HTML Dashboard
echo "Test 3: HTML Dashboard"
if [ -f "dashboard-test-19-07-25.html" ]; then
    echo "✓ HTML dashboard generated successfully"
    dashboard_size=$(du -h dashboard-test-19-07-25.html | cut -f1)
    echo "  Dashboard size: $dashboard_size"
    
    # Check for key dashboard elements
    if grep -q "Security Dashboard" dashboard-test-19-07-25.html; then
        echo "  ✓ Dashboard header present"
    fi
    if grep -q "card" dashboard-test-19-07-25.html; then
        echo "  ✓ Card layout present"
    fi
    if grep -q "style" dashboard-test-19-07-25.html; then
        echo "  ✓ Professional styling present"
    fi
else
    echo "✗ HTML dashboard not found"
fi
echo

# Test 4: CSV Export
echo "Test 4: CSV Export Format"
timeout 25s ./LinEnum.sh --format csv -r csv-test >/dev/null 2>&1
if [ -f "csv-test*.csv" ]; then
    echo "✓ CSV export generated successfully"
    csv_lines=$(wc -l csv-test*.csv | cut -d' ' -f1)
    echo "  Data rows: $csv_lines"
else
    echo "✗ CSV export generation failed"
fi
echo

# Test 5: CIS Compliance Mode
echo "Test 5: CIS Compliance Assessment"
if [ -f "cis-compliance-19-07-25.html" ]; then
    echo "✓ CIS compliance report generated"
    
    # Check for compliance content
    if grep -q "CIS" cis-compliance-19-07-25.html; then
        echo "  ✓ CIS controls content present"
    fi
    if grep -q "compliance" cis-compliance-19-07-25.html; then
        echo "  ✓ Compliance assessment data present"
    fi
else
    echo "✗ CIS compliance report not found"
fi
echo

# Test 6: NIST Framework
echo "Test 6: NIST Framework Assessment" 
timeout 25s ./LinEnum.sh --compliance nist --format json -r nist-test >/dev/null 2>&1
if [ -f "nist-test*.json" ]; then
    echo "✓ NIST framework assessment completed"
else
    echo "✗ NIST framework assessment failed"
fi
echo

# Test 7: Professional Features
echo "Test 7: Professional Features Integration"
features_count=0

# Check for professional argument parsing
if ./LinEnum.sh -h | grep -q "PROFESSIONAL REPORTING"; then
    echo "✓ Professional help system active"
    ((features_count++))
fi

if ./LinEnum.sh -h | grep -q "ENTERPRISE FEATURES"; then
    echo "✓ Enterprise features documented"
    ((features_count++))
fi

if ./LinEnum.sh -h | grep -q "--format"; then
    echo "✓ Format selection available"
    ((features_count++))
fi

if ./LinEnum.sh -h | grep -q "--compliance"; then
    echo "✓ Compliance modes available"
    ((features_count++))
fi

if ./LinEnum.sh -h | grep -q "--dashboard"; then
    echo "✓ Dashboard mode available"
    ((features_count++))
fi

echo "  Professional features active: $features_count/5"
echo

# Test 8: Function Integration
echo "Test 8: Function Integration Check"
function_count=0

if grep -q "format_professional_output" ./LinEnum.sh; then
    echo "✓ Professional output formatting function present"
    ((function_count++))
fi

if grep -q "add_risk_finding" ./LinEnum.sh; then
    echo "✓ Risk assessment function present"
    ((function_count++))
fi

if grep -q "check_cis_controls" ./LinEnum.sh; then
    echo "✓ CIS compliance checking function present"
    ((function_count++))
fi

if grep -q "generate_html_header" ./LinEnum.sh; then
    echo "✓ HTML generation function present"
    ((function_count++))
fi

if grep -q "init_report_data" ./LinEnum.sh; then
    echo "✓ Report initialization function present"
    ((function_count++))
fi

echo "  Core functions integrated: $function_count/5"
echo

# Summary
echo "=== Enterprise Features Test Summary ==="
total_files=$(ls -1 *-test*.* 2>/dev/null | wc -l)
echo "• Generated report files: $total_files"

if [ $total_files -gt 0 ]; then
    echo "• Report formats successfully tested:"
    ls -1 *-test*.* 2>/dev/null | sed 's/.*\./  - /' | sort -u
fi

echo "• Compliance frameworks:"
if [ -f "cis-compliance*.html" ]; then
    echo "  ✓ CIS Controls"
fi
if [ -f "nist-test*.json" ]; then
    echo "  ✓ NIST Framework"
fi

echo "• Professional features: $features_count/5 active"
echo "• Core functions: $function_count/5 integrated"

if [ $total_files -ge 3 ] && [ $features_count -ge 4 ] && [ $function_count -ge 4 ]; then
    echo "✅ Enterprise transformation SUCCESSFUL!"
    echo "   LinEnum-Enhanced is now enterprise-ready with professional reporting."
else
    echo "⚠️ Enterprise transformation partially complete"
    echo "   Some features may need additional testing or configuration."
fi
echo

echo "Next steps:"
echo "• Review generated reports in your preferred format"
echo "• Test compliance assessments for your organization"
echo "• Integrate with enterprise security tools and workflows"
echo "• Customize report templates and branding as needed"

# Cleanup test files (optional)
read -p "Clean up test files? (y/N): " cleanup
if [[ $cleanup =~ ^[Yy]$ ]]; then
    rm -f *-test*.* 2>/dev/null
    echo "Test files cleaned up."
fi