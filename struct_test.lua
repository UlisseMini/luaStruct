local struct = require "struct"

-- test helpers
local function printf(s, ...) print(s:format(...)) end

local function shouldErr(f)
  local ok, err = pcall(f)
  if not ok then
    error(err)
  end
end

-- test functions go in here
local test = {}

function test:people()
  local person = struct{
    name = "";
    age  = 0;
  }

  local tests = {
    {
      name = "bob";
      age = 50;

      shouldFail = false
    },
    {
      name = 30;
      age = "jerry";

      shouldFail = true
    },
    {
      shouldFail = true
    },
    {
      name = {"bob"};
      age = {50};

      shouldFail = true
    },
  }

  for n, tc in pairs(tests) do
    if tc.shouldFail then
      local ok, err = pcall(function()
        tc.shouldFail = nil
        local tp = person(tc)
      end)

      if ok then
        error(string.format("subtest %d: should have failed", n))
      end
    else
      -- it should not fail, run it normally if it fails it will
      -- go up the call stack.
      tc.shouldFail = nil
      local tp = person(tc)
    end
  end
end

function test:nested()
  local nested = struct{
    name = "";
    sub = {
      age = 0;
    };
  }

  local tests = {
    {
      name = "bobby";
      sub = {
        age = 2;
      };

      shouldFail = false;
    },
    {
      name = 10;
      sub = {
        age = 2;
      };

      shouldFail = true
    },
    {
      name = "valid";
      sub = {
        age = "foo";
      };

      shouldFail = true
    },
  }

  for n, tc in pairs(tests) do
    if tc.shouldFail then
      local ok, err = pcall(function()
        tc.shouldFail = nil
        local tp = nested(tc)
      end)

      if ok then
        error(string.format("subtest %d: should have failed", n))
      end
    else
      -- it should not fail, run it normally if it fails it will
      -- go up the call stack.
      tc.shouldFail = nil
      local tp = nested(tc)
    end
  end
end

-- run all the tests
local failures, ran = 0, 0

for testName, testFn in pairs(test) do
  -- write the test we're running + the padding
  io.write("test:"..testName..string.rep(" ", 20-#testName))

  -- run it and check for errors
  ok, err = pcall(testFn)
  if not ok then
    print(" | FAIL ("..err..")")
    failures = failures + 1
  else
    print(" | PASS")
  end

  ran = ran + 1
end

printf("%d test failures, %d tests ran", failures, ran)
