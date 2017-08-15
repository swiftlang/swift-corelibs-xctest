// RUN: %{swiftc} %s -o %T/Performance
// RUN: %T/Performance > %t || true
// RUN: %{xctest_checker} %t %s

#if os(macOS)
    import SwiftXCTest
#else
    import XCTest
#endif

// CHECK: Test Suite 'All tests' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Suite '.*\.xctest' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+

// CHECK: Test Suite 'PerformanceTestCase' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
class PerformanceTestCase: XCTestCase {

    // CHECK: Test Case 'PerformanceTestCase.test_measureBlockIteratesTenTimes' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: .*/Performance/main.swift:[[@LINE+4]]: Test Case 'PerformanceTestCase.test_measureBlockIteratesTenTimes' measured \[Time, seconds\] .*
    // CHECK: Test Case 'PerformanceTestCase.test_measureBlockIteratesTenTimes' passed \(\d+\.\d+ seconds\)
    func test_measureBlockIteratesTenTimes() {
        var iterationCount = 0
        measure(block: {
            iterationCount += 1
        })
        XCTAssertEqual(iterationCount, 10)
    }

    // CHECK: Test Case 'PerformanceTestCase.test_measuresMetricsWithAutomaticStartAndStop' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: .*/Performance/main.swift:[[@LINE+4]]: Test Case 'PerformanceTestCase.test_measuresMetricsWithAutomaticStartAndStop' measured \[Time, seconds\] .*
    // CHECK: Test Case 'PerformanceTestCase.test_measuresMetricsWithAutomaticStartAndStop' passed \(\d+\.\d+ seconds\)
    func test_measuresMetricsWithAutomaticStartAndStop() {
        var iterationCount = 0
        measureMetrics([.wallClockTime], automaticallyStartMeasuring: true, for: {
            iterationCount += 1
        })
        XCTAssertEqual(iterationCount, 10)
    }

    // CHECK: Test Case 'PerformanceTestCase.test_measuresMetricsWithManualStartAndStop' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: .*/Performance/main.swift:[[@LINE+3]]: Test Case 'PerformanceTestCase.test_measuresMetricsWithManualStartAndStop' measured \[Time, seconds\] .*
    // CHECK: Test Case 'PerformanceTestCase.test_measuresMetricsWithManualStartAndStop' passed \(\d+\.\d+ seconds\)
    func test_measuresMetricsWithManualStartAndStop() {
        measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
            self.startMeasuring()
            self.stopMeasuring()
        }
    }

    // CHECK: Test Case 'PerformanceTestCase.test_measuresMetricsWithoutExplicitStop' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: .*/Performance/main.swift:[[@LINE+3]]: Test Case 'PerformanceTestCase.test_measuresMetricsWithoutExplicitStop' measured \[Time, seconds\] .*
    // CHECK: Test Case 'PerformanceTestCase.test_measuresMetricsWithoutExplicitStop' passed \(\d+\.\d+ seconds\)
    func test_measuresMetricsWithoutExplicitStop() {
        measureMetrics([.wallClockTime], automaticallyStartMeasuring: false) {
            self.startMeasuring()
        }
    }

    // CHECK: Test Case 'PerformanceTestCase.test_hasWallClockAsDefaultPerformanceMetric' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: Test Case 'PerformanceTestCase.test_hasWallClockAsDefaultPerformanceMetric' passed \(\d+\.\d+ seconds\)
    func test_hasWallClockAsDefaultPerformanceMetric() {
        XCTAssertEqual(PerformanceTestCase.defaultPerformanceMetrics, [.wallClockTime])
    }

    // CHECK: Test Case 'PerformanceTestCase.test_printsValuesAfterMeasuring' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: .*/Performance/main.swift:[[@LINE+3]]: Test Case 'PerformanceTestCase.test_printsValuesAfterMeasuring' measured \[Time, seconds\] average: \d+.\d{3}, relative standard deviation: \d+.\d{3}%, values: \[\d+.\d{6}, \d+.\d{6}, \d+.\d{6}, \d+.\d{6}, \d+.\d{6}, \d+.\d{6}, \d+.\d{6}, \d+.\d{6}, \d+.\d{6}, \d+.\d{6}\], performanceMetricID:org.swift.XCTPerformanceMetric_WallClockTime, maxPercentRelativeStandardDeviation: \d+.\d{3}%, maxStandardDeviation: \d.\d{3}
    // CHECK: Test Case 'PerformanceTestCase.test_printsValuesAfterMeasuring' passed \(\d+\.\d+ seconds\)
    func test_printsValuesAfterMeasuring() {
        measure {}
    }

    // CHECK: Test Case 'PerformanceTestCase.test_abortsMeasurementsAfterTestFailure' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    func test_abortsMeasurementsAfterTestFailure() {
        var iterationCount = 0
        measure {
            iterationCount += 1
            // CHECK: .*/Performance/main.swift:[[@LINE+1]]: error: PerformanceTestCase.test_abortsMeasurementsAfterTestFailure : XCTAssertLessThan failed: \("3"\) is not less than \("3"\) -
            XCTAssertLessThan(iterationCount, 3)
        }
        XCTAssertEqual(iterationCount, 3)
    }
    // CHECK: Test Case 'PerformanceTestCase.test_abortsMeasurementsAfterTestFailure' failed \(\d+\.\d+ seconds\)

    // CHECK: Test Case 'PerformanceTestCase.test_measuresWallClockTimeInBlock' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    func test_measuresWallClockTimeInBlock() {
        var hasWaited = false
        // CHECK: .*/Performance/main.swift:[[@LINE+2]]: Test Case 'PerformanceTestCase.test_measuresWallClockTimeInBlock' measured \[Time, seconds\] average: \d+.\d{3}, relative standard deviation: \d+.\d{3}%, values: \[1.\d{6}, 0.\d{6}, 0.\d{6}, 0.\d{6}, 0.\d{6}, 0.\d{6}, 0.\d{6}, 0.\d{6}, 0.\d{6}, 0.\d{6}\], performanceMetricID:org.swift.XCTPerformanceMetric_WallClockTime, maxPercentRelativeStandardDeviation: \d+.\d{3}%, maxStandardDeviation: \d.\d{3}
        // CHECK: .*/Performance/main.swift:[[@LINE+1]]: error: PerformanceTestCase.test_measuresWallClockTimeInBlock : failed: The relative standard deviation of the measurements is \d+.\d{3}% which is higher than the max allowed of \d+.\d{3}%.
        measure {
            if !hasWaited {
                Thread.sleep(forTimeInterval: 1)
                hasWaited = true
            }
        }
    }
    // CHECK: Test Case 'PerformanceTestCase.test_measuresWallClockTimeInBlock' failed \(\d+\.\d+ seconds\)

    static var allTests = {
        return [
                   ("test_measureBlockIteratesTenTimes", test_measureBlockIteratesTenTimes),
                   ("test_measuresMetricsWithAutomaticStartAndStop", test_measuresMetricsWithAutomaticStartAndStop),
                   ("test_measuresMetricsWithManualStartAndStop", test_measuresMetricsWithManualStartAndStop),
                   ("test_measuresMetricsWithoutExplicitStop", test_measuresMetricsWithoutExplicitStop),
                   ("test_hasWallClockAsDefaultPerformanceMetric", test_hasWallClockAsDefaultPerformanceMetric),
                   ("test_printsValuesAfterMeasuring", test_printsValuesAfterMeasuring),
                   ("test_abortsMeasurementsAfterTestFailure", test_abortsMeasurementsAfterTestFailure),
                   ("test_measuresWallClockTimeInBlock", test_measuresWallClockTimeInBlock),
        ]
    }()
}
// CHECK: Test Suite 'PerformanceTestCase' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed \d+ tests, with 2 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

XCTMain([testCase(PerformanceTestCase.allTests)])

// CHECK: Test Suite '.*\.xctest' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed \d+ tests, with \d failures? \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Test Suite 'All tests' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed \d+ tests, with \d failures? \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
