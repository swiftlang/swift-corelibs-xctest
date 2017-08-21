// RUN: %{swiftc} %s -o %T/PerformanceMisuse
// RUN: %T/PerformanceMisuse > %t || true
// RUN: %{xctest_checker} %t %s

#if os(macOS)
    import SwiftXCTest
#else
    import XCTest
#endif

// CHECK: Test Suite 'All tests' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Suite '.*\.xctest' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+

// CHECK: Test Suite 'PerformanceMisuseTestCase' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
class PerformanceMisuseTestCase: XCTestCase {

    // CHECK: Test Case 'PerformanceMisuseTestCase.test_whenMeasuringMultipleInOneTest_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    func test_whenMeasuringMultipleInOneTest_fails() {
        // CHECK: .*/Misuse/main.swift:[[@LINE+1]]: Test Case 'PerformanceMisuseTestCase.test_whenMeasuringMultipleInOneTest_fails' measured.*
        measure {}
        // CHECK: .*/Misuse/main.swift:[[@LINE+1]]: error: PerformanceMisuseTestCase.test_whenMeasuringMultipleInOneTest_fails : API violation - Can only record one set of metrics per test method.
        measure {}
        // CHECK: .*/Misuse/main.swift:[[@LINE+1]]: error: PerformanceMisuseTestCase.test_whenMeasuringMultipleInOneTest_fails : API violation - Can only record one set of metrics per test method.
        measureMetrics([.wallClockTime], automaticallyStartMeasuring: true) {}
    }
    // CHECK: Test Case 'PerformanceMisuseTestCase.test_whenMeasuringMultipleInOneTest_fails' failed \(\d+\.\d+ seconds\)

    // CHECK: Test Case 'PerformanceMisuseTestCase.test_whenMeasuringMetricsAndNotStartingOrEnding_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    func test_whenMeasuringMetricsAndNotStartingOrEnding_fails() {
        // CHECK: .*/Misuse/main.swift:[[@LINE+1]]: error: PerformanceMisuseTestCase.test_whenMeasuringMetricsAndNotStartingOrEnding_fails : API violation - startMeasuring\(\) must be called during the block.
        measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {}
    }
    // CHECK: Test Case 'PerformanceMisuseTestCase.test_whenMeasuringMetricsAndNotStartingOrEnding_fails' failed \(\d+\.\d+ seconds\)

    // CHECK: Test Case 'PerformanceMisuseTestCase.test_whenMeasuringMetricsAndStoppingWithoutStarting_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    func test_whenMeasuringMetricsAndStoppingWithoutStarting_fails() {
        measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
            // CHECK: .*/Misuse/main.swift:[[@LINE+1]]: error: PerformanceMisuseTestCase.test_whenMeasuringMetricsAndStoppingWithoutStarting_fails : API violation - Cannot stop measuring before starting measuring.
            self.stopMeasuring()
        }
    }
    // CHECK: Test Case 'PerformanceMisuseTestCase.test_whenMeasuringMetricsAndStoppingWithoutStarting_fails' failed \(\d+\.\d+ seconds\)

    // CHECK: Test Case 'PerformanceMisuseTestCase.test_whenMeasuringMetricsAndStartingTwice_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    func test_whenMeasuringMetricsAndStartingTwice_fails() {
        measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
            self.startMeasuring()
            // CHECK: .*/Misuse/main.swift:[[@LINE+1]]: error: PerformanceMisuseTestCase.test_whenMeasuringMetricsAndStartingTwice_fails : API violation - Already called startMeasuring\(\) once this iteration.
            self.startMeasuring()
        }
    }
    // CHECK: Test Case 'PerformanceMisuseTestCase.test_whenMeasuringMetricsAndStartingTwice_fails' failed \(\d+\.\d+ seconds\)

    // CHECK: Test Case 'PerformanceMisuseTestCase.test_whenMeasuringMetricsAndStoppingTwice_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    func test_whenMeasuringMetricsAndStoppingTwice_fails() {
        measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
            self.startMeasuring()
            self.stopMeasuring()
            // CHECK: .*/Misuse/main.swift:[[@LINE+1]]: error: PerformanceMisuseTestCase.test_whenMeasuringMetricsAndStoppingTwice_fails : API violation - Already called stopMeasuring\(\) once this iteration.
            self.stopMeasuring()
        }
    }
    // CHECK: Test Case 'PerformanceMisuseTestCase.test_whenMeasuringMetricsAndStoppingTwice_fails' failed \(\d+\.\d+ seconds\)

    // CHECK: Test Case 'PerformanceMisuseTestCase.test_startMeasuringOutsideOfBlock_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    func test_startMeasuringOutsideOfBlock_fails() {
        // CHECK: .*/Misuse/main.swift:[[@LINE+1]]: error: PerformanceMisuseTestCase.test_startMeasuringOutsideOfBlock_fails : API violation - Cannot start measuring. startMeasuring\(\) is only supported from a block passed to measureMetrics\(...\).
        startMeasuring()
    }
    // CHECK: Test Case 'PerformanceMisuseTestCase.test_startMeasuringOutsideOfBlock_fails' failed \(\d+\.\d+ seconds\)

    // CHECK: Test Case 'PerformanceMisuseTestCase.test_stopMeasuringOutsideOfBlock_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    func test_stopMeasuringOutsideOfBlock_fails() {
        // CHECK: .*/Misuse/main.swift:[[@LINE+1]]: error: PerformanceMisuseTestCase.test_stopMeasuringOutsideOfBlock_fails : API violation - Cannot stop measuring. stopMeasuring\(\) is only supported from a block passed to measureMetrics\(...\).
        stopMeasuring()
    }
    // CHECK: Test Case 'PerformanceMisuseTestCase.test_stopMeasuringOutsideOfBlock_fails' failed \(\d+\.\d+ seconds\)

    // CHECK: Test Case 'PerformanceMisuseTestCase.test_startMeasuringAfterBlock_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    func test_startMeasuringAfterBlock_fails() {
        // CHECK: .*/Misuse/main.swift:[[@LINE+1]]: Test Case 'PerformanceMisuseTestCase.test_startMeasuringAfterBlock_fails' measured.*
        measure {}
        // CHECK: .*/Misuse/main.swift:[[@LINE+1]]: error: PerformanceMisuseTestCase.test_startMeasuringAfterBlock_fails : API violation - Cannot start measuring. startMeasuring\(\) is only supported from a block passed to measureMetrics\(...\).
        startMeasuring()
    }
    // CHECK: Test Case 'PerformanceMisuseTestCase.test_startMeasuringAfterBlock_fails' failed \(\d+\.\d+ seconds\)

    // CHECK: Test Case 'PerformanceMisuseTestCase.test_stopMeasuringAfterBlock_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    func test_stopMeasuringAfterBlock_fails() {
        // CHECK: .*/Misuse/main.swift:[[@LINE+1]]: Test Case 'PerformanceMisuseTestCase.test_stopMeasuringAfterBlock_fails' measured.*
        measure {}
        // CHECK: .*/Misuse/main.swift:[[@LINE+1]]: error: PerformanceMisuseTestCase.test_stopMeasuringAfterBlock_fails : API violation - Cannot stop measuring. stopMeasuring\(\) is only supported from a block passed to measureMetrics\(...\).
        stopMeasuring()
    }
    // CHECK: Test Case 'PerformanceMisuseTestCase.test_stopMeasuringAfterBlock_fails' failed \(\d+\.\d+ seconds\)

    // CHECK: Test Case 'PerformanceMisuseTestCase.test_measuringNoMetrics_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    func test_measuringNoMetrics_fails() {
        // CHECK: .*/Misuse/main.swift:[[@LINE+1]]: error: PerformanceMisuseTestCase.test_measuringNoMetrics_fails : API violation - At least one metric must be provided to measure.
        measureMetrics([], automaticallyStartMeasuring: true) {}
    }
    // CHECK: Test Case 'PerformanceMisuseTestCase.test_measuringNoMetrics_fails' failed \(\d+\.\d+ seconds\)

    // CHECK: Test Case 'PerformanceMisuseTestCase.test_measuringUnknownMetric_fails' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    func test_measuringUnknownMetric_fails() {
        // CHECK: .*/Misuse/main.swift:[[@LINE+1]]: error: PerformanceMisuseTestCase.test_measuringUnknownMetric_fails : API violation - Unknown metric: UnladenAirspeedVelocity
        measureMetrics([XCTPerformanceMetric("UnladenAirspeedVelocity")], automaticallyStartMeasuring: true) {}
    }
    // CHECK: Test Case 'PerformanceMisuseTestCase.test_measuringUnknownMetric_fails' failed \(\d+\.\d+ seconds\)

    static var allTests = {
        return [
                   ("test_whenMeasuringMultipleInOneTest_fails", test_whenMeasuringMultipleInOneTest_fails),
                   ("test_whenMeasuringMetricsAndNotStartingOrEnding_fails", test_whenMeasuringMetricsAndNotStartingOrEnding_fails),
                   ("test_whenMeasuringMetricsAndStoppingWithoutStarting_fails", test_whenMeasuringMetricsAndStoppingWithoutStarting_fails),
                   ("test_whenMeasuringMetricsAndStartingTwice_fails", test_whenMeasuringMetricsAndStartingTwice_fails),
                   ("test_whenMeasuringMetricsAndStoppingTwice_fails", test_whenMeasuringMetricsAndStoppingTwice_fails),
                   ("test_startMeasuringOutsideOfBlock_fails", test_startMeasuringOutsideOfBlock_fails),
                   ("test_stopMeasuringOutsideOfBlock_fails", test_stopMeasuringOutsideOfBlock_fails),
                   ("test_startMeasuringAfterBlock_fails", test_startMeasuringAfterBlock_fails),
                   ("test_stopMeasuringAfterBlock_fails", test_stopMeasuringAfterBlock_fails),
                   ("test_measuringNoMetrics_fails", test_measuringNoMetrics_fails),
                   ("test_measuringUnknownMetric_fails", test_measuringUnknownMetric_fails),
        ]
    }()
}
// CHECK: Test Suite 'PerformanceMisuseTestCase' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed \d+ tests, with 12 failures \(12 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

XCTMain([testCase(PerformanceMisuseTestCase.allTests)])

// CHECK: Test Suite '.*\.xctest' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed \d+ tests, with \d+ failures \(\d+ unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Test Suite 'All tests' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed \d+ tests, with \d+ failures \(\d+ unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
