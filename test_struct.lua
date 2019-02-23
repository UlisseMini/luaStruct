local struct = require "struct"

local tests = {
  {
    name = "people";     -- testname
    obj  = struct {      -- the struct to use
      -- a person must have a name and an age
      name = "";
      age  = 0;
    },

    -- test cases to execute
    tests = {
      {
        fail = false; -- do we expect this test to fail
        name = "bob";
        age  = 30;
      },
      {
        fail = true;
        name = 10;
        age  = "jerry";
      }
    },
  },
  {
    name = "functions";
    obj  = struct {
      hi = function() end,
    },

    tests = {
      {
        fail = false;
        hi   = function() end
      },
      {
        fail = true;
        hi   = "bobcat"
      },
      {
        fail = true;
        hi   = nil
      },
    }
  },
  {
    name = "nested";
    obj  = struct {
      top = 0;
      sub = {
        num = 0
      }
    },

    tests = {
      {
        fail = false;
        top = 10;
        sub = {
          num = 10;
        },
      },
      {
        fail = true;
        sub = {
          num = 10;
        },
      },
      {
        fail = true;
        top = 10;
        sub = {}
      },
      {
        fail = true;
        top = 10;
        sub = {
          {num = 10}
        }
      },
    }
  },
}

-- helper function
local printf = function(s, ...)
  io.write( s:format( ... ) )
end

-- run all the tests
local failures, ran = 0, 0
local start = os.clock()
for _, test in pairs(tests) do
  -- write the test group we're running
  printf("testing '%s'\n", test.name)

  local passed = true
  -- run the test cases and check for errors.
  for n, tc in pairs(test.tests) do
    shouldFail = tc.fail
    printf("  sub-%d"..string.rep(" ", 4), n)

    -- run it
    ok, err = pcall(function()
      tc.fail = nil
      local obj = test.obj(tc)
    end)

    -- if it passed but should have failed raise an error
    if ok and shouldFail then
      printf("  FAIL | should have failed)\n", n)
      passed = false
    -- if it failed but should not have raise an error
    elseif not ok and not shouldFail then
      printf("  FAIL | should not have failed\n", n)
      passed = false
    else
      printf("  | PASS\n", n)
    end

    ran = ran + 1
  end
  if passed then
    print("PASSED\n")
  else
    print("FAILED\n")
    failures = failures + 1
  end
end

printf("%d test failures, %d tests ran in %.4fs\n", failures, ran, os.clock() - start)
