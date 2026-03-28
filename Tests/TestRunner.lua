-- MythicLootMap Test Runner
-- Run via: /mlm test

local MythicLootMap = MythicLootMap

local TestRunner = {}
MythicLootMap.TestRunner = TestRunner

local results = {
    passed = 0,
    failed = 0,
    errors = {},
}

function TestRunner:Assert(condition, message)
    if condition then
        results.passed = results.passed + 1
    else
        results.failed = results.failed + 1
        table.insert(results.errors, message or "Assertion failed")
    end
end

function TestRunner:AssertEqual(expected, actual, message)
    local msg = (message or "") .. string.format(" (expected: %s, got: %s)", tostring(expected), tostring(actual))
    self:Assert(expected == actual, msg)
end

function TestRunner:AssertNotNil(value, message)
    self:Assert(value ~= nil, (message or "Value") .. " should not be nil")
end

function TestRunner:AssertNil(value, message)
    self:Assert(value == nil, (message or "Value") .. " should be nil")
end

function TestRunner:AssertTrue(value, message)
    self:Assert(value == true, (message or "Value") .. " should be true")
end

function TestRunner:AssertFalse(value, message)
    self:Assert(value == false or not value, (message or "Value") .. " should be false")
end

function TestRunner:AssertTableLength(tbl, expectedLen, message)
    local actual = 0
    for _ in pairs(tbl) do actual = actual + 1 end
    self:AssertEqual(expectedLen, actual, (message or "Table length"))
end

function TestRunner:Reset()
    results.passed = 0
    results.failed = 0
    results.errors = {}
end

function TestRunner:RunAll()
    self:Reset()

    local suites = {
        MythicLootMap.TestData,
        MythicLootMap.TestCompare,
        MythicLootMap.TestFilters,
    }

    for _, suite in ipairs(suites) do
        if suite and suite.Run then
            local ok, err = pcall(suite.Run, suite, self)
            if not ok then
                results.failed = results.failed + 1
                table.insert(results.errors, "Suite error: " .. tostring(err))
            end
        end
    end

    self:PrintResults()
end

function TestRunner:PrintResults()
    print("|cFF00FF00MythicLootMap Tests|r")
    print(string.format("  Passed: |cFF00FF00%d|r", results.passed))
    print(string.format("  Failed: |cFFFF0000%d|r", results.failed))

    if #results.errors > 0 then
        print("  Errors:")
        for i, err in ipairs(results.errors) do
            print(string.format("    %d. |cFFFF0000%s|r", i, err))
        end
    end
end
