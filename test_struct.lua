local struct = require "struct"

-- helper functions
local printf  = function (s, ...) io.write( s:format( ... ) ) end
local sprintf = function (s, ...) return s:format( ... )      end

local tests = {
  {
    name = "people",     -- testname
    obj  = struct {      -- the struct to use
      -- a person must have a name and an age
      name = "",
      age  = 0,
    },

    -- test cases to execute
    tests = {
      {
        fail = false, -- do we expect this test to fail
        verify = function(obj)
          if obj.name ~= "bob" then
            return string.format("want name: bob, got name: '%s'", obj.name)
          end

          if obj.age ~= 30 then
            return string.format("want age: 30, got age: %d", obj.age)
          end
        end,

        name = "bob",
        age  = 30,
      },
      {
        fail = true,
        name = 10,
        age  = "jerry",
      }
    },
  },
  {
    name = "functions",
    obj  = struct {
      hi = function() end,
    },

    tests = {
      {
        fail = false,
        hi   = function() end
      },
      {
        fail = true,
        hi   = "bobcat"
      },
      {
        fail = false,
        hi   = nil
      },
    }
  },
  {
    name = "nested",
    obj  = struct {
      top = 0,
      sub = {
        num = 0
      }
    },

    tests = {
      {
        fail = false,
        top = 10,
        sub = {
          num = 10,
        },
      },
      {
        -- will not fail because of defaults
        fail = false,
        top = 10,
        sub = {}
      },
      {
        fail = true,
        top = 10,
        sub = {
          {num = 10}
        }
      },
    },
  },
  {
    name = "unwanted",
    obj  = struct {
      name = "",
      age  = 0,
    },

    tests = {
      {
        fail = true,

        name     = "foo",
        age      = 10,
        unwanted = "invalid field",
      },
      {
        fail = true,

        name     = "bar",
        age      = 10,
        unwanted = {}
      },
    },
  },

  {
    name = "methods",
    obj  = struct {name = ""},

    -- create some methods
    init = function (obj)
      function obj:hello()     return self.name.." says hello!" end
      function obj.echo(thing) return thing                     end
    end,

    tests = {
      {
        fail = false,
        verify = function (o)
          if type(o.hello) ~= "function" then
            return "object does not have method 'hello'"
          end

          local msg = o:hello()

          if msg ~= "bobby says hello!" then
            return string.format("want: 'bobby says hello!', got '%s'", msg)
          end
        end,

        name = "bobby"
      },
      {
        fail = false,
        verify = function (o)
          if type(o.echo) ~= "function" then
            return "object does not have method 'echo'"
          end

          local m = o.echo("hello")
          if m ~= "hello" then
            return string.format("want: 'hello', got '%s'", m)
          end
        end,

        name = "jerry"
      },
    }
  },
  {
    name = "defaults",
    obj = struct {
      name = "jen",
      age  = 10,
    },

    tests = {
      {
        verify = function (o)
          if o.age ~= 10 then
            return string.format("want age 10; got age %s", o.age)
          end
        end,
        fail = false,

        name = "bob",
      },
      {
        verify = function (o)
          if o.name ~= 'jen' then
            return string.format("want name 'jen'; got name '%s'", o.name)
          end

          if o.age ~= 11 then
            return string.format("want age: 11 (non default), got age %d", o.age)
          end
        end,
        fail = false,

        age = 11,
      },
    }
  },

  {
    name = "nested defaults",
    obj  = struct {
      sub = {
        n = 10,
      },
    },

    tests = {
      {
        fail = false,
        verify = function (o)
          if o.sub.n ~= 10 then
            return string.format("want o.sub.n: 10; got %d", o.sub.n)
          end
        end,

        sub = nil
      },
    }
  },
}

-- returns ok (bool), message (string)
local function runTest (n, tc, group)
    printf("  sub-%d%s",n, string.rep(" ", 4), n)

    -- check for an init function
    if type(group.init) == "function" then
      group.init(group.obj)
    end

    -- so we can verify the returned object
    local obj
    shouldFail = tc.fail
    verify     = tc.verify

    -- run it
    local ok, err = pcall(function()
      tc.fail   = nil
      tc.verify = nil
      tc.init   = nil

      obj = group.obj(tc)
    end)

    -- if it passed but should have failed raise an error
    if ok and shouldFail then
      return false, sprintf("  | FAIL: should have failed, but did not)")
    end

    -- if it failed but should not have raise an error
    if not ok and not shouldFail then
      return false, sprintf("  | FAIL: %s", err)
    end

    -- if it has a verify function execute it
    if type(verify) == "function" then
      if not obj then
        return false, sprintf("  | FAIL: returned object is nil (verify object)")
      end

      err = verify(obj)
      if err ~= nil then
        return false, sprintf("  | FAIL: %s (verify object)", err, n)
      end
    end

    -- all the tests passed, return ok
    return true, sprintf("  | PASS")
end

-- run all the tests
local failures, ran = 0, 0
local start = os.clock()
for _, tGroup in pairs(tests) do
  -- write the test group we're running
  printf("testing '%s'\n", tGroup.name)

  -- run the test cases and check for errors.
  local passed = true
  for n, tc in pairs(tGroup.tests) do
    local subPassed, msg = runTest(n, tc, tGroup)
    print(msg)

    if not subPassed then
      passed = false
    end

    ran = ran + 1
  end

  -- print the message for the test group we ran
  if passed then
    print("PASSED\n")
  else
    print("FAILED\n")
    failures = failures + 1
  end
end

printf("%d group failures, %d tests ran in %.4fs\n", failures, ran, os.clock() - start)
